---@class TaskManager
local TaskManager = {}
---@type table<thread, Task>
TaskManager.tasks = {}
TaskManager.TickFrame = 0
TaskManager.TickTime = 0.0
TaskManager.SafeResume = 0


--[[
检查一个task是否能够被Resume，能被Resume需要满足两个条件：
1. 该task已经Start
2. 其所有CurrentWaited都已经执行完成（dead），或者没有CurrentWaited
--]]
---@param task Task
local function CheckResumeTask(task)
    -- 如果一个task还未Start，不能Resume
    if task == nil or task.Status == ELTaskStatus.NotStart then
        return
    end

    -- 已经执行完成，不用Resume
    if task.Status == ELTaskStatus.Dead then
        TaskManager:RemoveTask(task)
        return
    end

    if task.WaitType == ELTaskWaiteType.Wait_None then
        TaskManager:ResumeTask(task)
    elseif task.WaitType == ELTaskWaiteType.Wait_Tick then
        if TaskManager.TickFrame >= task.ResumeFrame then
            TaskManager:ResumeTask(task)
        end
    elseif task.WaitType == ELTaskWaiteType.Wait_Time then
        if TaskManager.TickTime >= task.ResumeTime then
            TaskManager:ResumeTask(task)
        end
    elseif task.WaitType == ELTaskWaiteType.Wait_Task then
        -- Resume传入上次等待的所有task的返回值
        if task.CurrentWaited == nil then
            TaskManager:ResumeTask(task)
        elseif #task.CurrentWaited == 1 then
            local CurrentWaited = task.CurrentWaited[1]
            if CurrentWaited:IsFinished() then
                TaskManager:ResumeTask(task, CurrentWaited:GetValue())
            end
        else
            local taskResults = {}

            for _,v in ipairs(task.CurrentWaited) do
                -- 若有一个依赖的Task未完成，继续等待
                if v:IsFinished() then 
                    table.insert(taskResults, v:GetValue())
                else
                    return
                end
            end

            -- 激活Task，传入依赖tasks的返回值
            TaskManager:ResumeTask(task, taskResults)
        end
    end
end

---@param task Task
function TaskManager:OnTaskComplete(task)
    -- 尝试Resume Subsequent（如果所有等待的tasks都已完成）
    if task.Subsequent then
        for _,v in ipairs(task.Subsequent) do
            CheckResumeTask(v)
        end
    end

    self:RemoveTask(task)
end

--[[
激活一个Task，StartTask时会调用，其他时候由TaskManager负责Resume，
不允许外部直接调用。
--]]
---@param task Task
---@param ... unknown
function TaskManager:ResumeTask(task, ...)
    -- 保护ResumeTask不能外部调用
    if not self.SafeResume then
        error("Don Not Call ResumeTask Directly~!")
        return
    end

    -- 设置Status为running，并清空CurrentWaited
    task.Status = ELTaskStatus.Running
    task.CurrentWaited = nil
    task.WaitType = ELTaskWaiteType.Wait_None

    -- 如果协程运行出现异常，success返回false，retValue返回异常的原因，taskStatus返回dead。
    local success,retValue = coroutine.resume(task.Coroutine, ...)
    local taskStatus = coroutine.status(task.Coroutine)

    if taskStatus == "dead" then -- 运行完成
        task.Status = ELTaskStatus.Dead
        if success then
            task.Value = retValue
        else
            print("coroutine error:", retValue)
            task.Value = nil
        end

        -- 如果task已经完成，调用OnTaskComplete。对于普通task，执行完成即完成。
        -- 对应AsyncTask，需要Async操作返回才算完成。
        if task:IsFinished() then
            self:OnTaskComplete(task)
        end
    elseif taskStatus == "suspended" then
        task.Status = ELTaskStatus.Suspended
    else -- 除了dead和suspend不应该有其他状态
        error("Task Status Error: " .. coroutine.status(task.Coroutine))
    end
end

---@param task Task
---@return integer @ task id
function TaskManager:RegisterTask(task)
    -- 注册到tasks表中，数组部分便于遍历
    self.tasks[task.Coroutine] = task
    --table.insert(self.tasks, task)

    return #self.tasks
end

function TaskManager:RemoveTask(task)
    --设置为nil会清除表中对应key项
    self.tasks[task.Coroutine] = nil
    --self.tasks[task.Id] = nil
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

    -- 若所有CurrentWaited都完成了，直接将它们的返回值打包返回给调用函数，就不用yield了
    if not needWait then
        return taskResults
    end

    currentTask.CurrentWaited = tasks
    currentTask.Status = ELTaskStatus.Suspended

    -- 上面的task完成时resume的时候需要传入等待task的返回值
    return coroutine.yield()
end

---@param elapsedTime number @ 距离上一次更新的时间（秒）
function TaskManager:Tick(elapsedTime)
    print("TaskManager:Tick:", self.TickFrame, self.TickTime)

    self.SafeResume = 1

    for _,v in pairs(self.tasks) do
        CheckResumeTask(v)
    end

    self.TickFrame = self.TickFrame + 1
    self.TickTime = self.TickTime + elapsedTime

    self.SafeResume = 0
end

return TaskManager