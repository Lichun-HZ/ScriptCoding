
---@class TaskManager
local TaskManager = {}
TaskManager.Task = require("Lua.Libs.LTask.Task")
---@type table<thread, Task>
TaskManager.tasks = {}
TaskManager.TickFrame = 0
TaskManager.SafeResume = 0


--[[
检查一个task是否能够被Resume，能被Resume需要满足两个条件：
1. 该task已经Start
2. 其所有Prerequisite都已经执行完成（dead），或者没有Prerequisite
--]]
---@param task Task
local function CheckResumeTask(task)
    -- 如果一个task还未Start，不能Resume
    if task == nil or task.Status == ELTaskStatus.NotStart then
        return
    end

    -- 已经执行完成，无法Resume
    if task.Status == ELTaskStatus.Dead then
        TaskManager.tasks[task.Coroutine] = nil
        TaskManager.tasks[task.Id] = nil
        return
    end

    -- Resume返回上次等待的所有task的返回值
    if task.Prerequisite == nil then
        TaskManager:ResumeTask(task)
    elseif #task.Prerequisite == 1 then
        local Prerequisite = task.Prerequisite[1]
        if Prerequisite.Status == ELTaskStatus.Dead then
            TaskManager:ResumeTask(task, Prerequisite.Value)
        end
    else
        local taskResults = {}

        for _,v in ipairs(task.Prerequisite) do
            -- 若有一个依赖的Task未完成，继续等待
            if v.Status == ELTaskStatus.Dead then
                table.insert(taskResults, v.Value)
            else
                return
            end
        end

        -- 激活Task，传入依赖tasks的返回值
        TaskManager:ResumeTask(task, taskResults)
    end
end

---@param task Task
---@param retValue any
local function OnTaskComplete(task, retValue)
    -- body
    task.Status = ELTaskStatus.Dead
    task.Value = retValue

    -- 尝试Resume Subsequent（如果所有等待的tasks都已完成）
    if task.Subsequent then
        for _,v in ipairs(task.Subsequent) do
            CheckResumeTask(v)
        end
    end

    --设置为nil会清除表中对应key项
    TaskManager.tasks[task.Coroutine] = nil
    TaskManager.tasks[task.Id] = nil
end

--[[
激活一个Task，StartTask时会调用，其他时候由TaskManager负责Resume，
不允许外部直接调用。
--]]
---@param task Task
---@param ... unknown
---@private
function TaskManager:ResumeTask(task, ...)
    -- 保护ResumeTask不能外部调用
    if not self.SafeResume then
        return
    end

    if task.Prerequisite then
        task.Prerequisite = {}
    end

    task.Status = ELTaskStatus.Running
    local _,retValue = coroutine.resume(task.Coroutine, ...)
    local taskStatus = coroutine.status(task.Coroutine)

    if taskStatus == "dead" then -- 运行完成
        OnTaskComplete(task, retValue)
    elseif taskStatus == "suspended" then
        task.Status = ELTaskStatus.Suspended
    else -- 除了dead和suspend不应该有其他状态
        error("Task Status Error: " .. coroutine.status(task.Coroutine))
    end
end

---@param Func function @function the task execute
---@param autoRun boolean @wheather run Task when it created
---@param ... any @ if autoRun is true, pass the param
---@return Task
function TaskManager:NewTask(Func, autoRun, ...)
    local inst = {}
    setmetatable(inst, self.Task)

    inst.Manager = self
    inst.Coroutine = coroutine.create(Func)
    inst.Status = ELTaskStatus.NotStart

    self.tasks[inst.Coroutine] = inst
    table.insert(self.tasks, inst)
    inst.Id = #self.tasks

    if autoRun then
        self:StartTask(inst, ...)
    end

    return inst
end

---@param task Task
---@param ... unknown
function TaskManager:StartTask(task, ...)
    if task.Status == ELTaskStatus.NotStart then
        self.SafeResume = 1
        TaskManager:ResumeTask(task, ...)
        self.SafeResume = 0
    end
end

---@meta 若Func需返回多个参数，放到一个table数组里，不要直接返回多个参数
---@param Func function @function the task to wait
function TaskManager:WaitForFunction(Func, ...)
    local task = self:NewTask(Func, true, ...)

    -- 若函数中没有yield，一次执行结束，直接返回其返回值
    if task.Status == ELTaskStatus.Dead then
        return task.Value
    end

    local currentThread = coroutine.running()
    local currentTask = self.tasks[currentThread]

    task.Subsequent = {currentTask}
    currentTask.Prerequisite = {task}

    currentTask.Status = ELTaskStatus.Suspended
    -- 上面的task完成时resume的时候需要传入等待task的返回值
    return coroutine.yield()
end

---@param tasks table<Task> @function the task to wait
function TaskManager:WaitForTasks(tasks)
    local currentThread = coroutine.running()
    local currentTask = self.tasks[currentThread]

    local taskResults = {}
    local needWait = false
    for _,v in ipairs(tasks) do
        -- 若有一个依赖的Task未完成，继续等待
        if v.Status == ELTaskStatus.Dead then
            table.insert(taskResults, v.Value)
        else
            needWait = true
        end

        if v.Subsequent then
            table.insert(v.Subsequent, currentTask)
        else
            v.Subsequent = {currentTask}
        end
    end

    -- 若所有Prerequisite都完成了，直接将它们的返回值打包返回给调用函数，就不用yield了
    if not needWait then
        return taskResults
    end

    currentTask.Prerequisite = tasks
    currentTask.Status = ELTaskStatus.Suspended

    -- 上面的task完成时resume的时候需要传入等待task的返回值
    return coroutine.yield()
end

function TaskManager:Tick()
    print("TaskManager:Tick:", self.TickFrame)

    self.SafeResume = 1

    for _,v in ipairs(self.tasks) do
        CheckResumeTask(v)
    end

    self.SafeResume = 0

    self.TickFrame = self.TickFrame + 1
end

return TaskManager