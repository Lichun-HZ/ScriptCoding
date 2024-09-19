local Task = require("Lua.Libs.LTask.Task")
local TaskManager = require("Lua.libs.LTask.TaskManager")

---@class Await
local Await = {}

--[[
等待一个异步函数执行完成，异步函数会封装成一个协程。
1. 若该异步函数一次执行完成，则WaitForFunction直接返回其返回值，不需要挂起当前协程。
2. 若该异步函数执行过程被挂起，则将当前协程也挂起，直到异步函数协程执行完成，再恢复当前协程。
--]]
---@param Func function @需要等待执行完成的函数
---@param ... any @ 函数的参数
---@return any @返回Func的返回值，若Func需返回多个参数，放到一个table数组里，不要直接返回多个参数
function Await.WaitForFunction(Func, ...)
    local task = Task:New(Func)

    --等待函数的Task自动运行
    task:Start(...)

    --若等待函数一次执行完成（无yield或者等待条件开始时就已完成），直接返回其返回值
    if task:IsFinished() then
        return task:GetValue()
    end

    local currentThread = coroutine.running()
    local currentTask = TaskManager.tasks[currentThread]

    -- 设置依赖和被依赖
    task.Subsequent = {currentTask}
    currentTask.CurrentWaited = {task}

    -- 进入Suspend状态（yield），下次Resume的时候需传入依赖task的返回值
    currentTask.Status = ELTaskStatus.Suspended
    currentTask.WaitType = ELTaskWaiteType.Wait_Task
    return coroutine.yield()
end

--[[
等待一组tasks完成。
1. 若所有tasks已处于完成状态，则WaitForTasks直接返回它们的返回值，不需要挂起当前协程。
2. 若有其中之一task还未完成，则将当前协程也挂起，直到所有tasks执行完成，再恢复当前协程。
--]]
---@param tasks table<Task>
function Await.WaitForTasks(tasks)
    local currentThread = coroutine.running()
    local currentTask = TaskManager.tasks[currentThread]

    local taskResults = {}
    local needWait = false
    for _,v in ipairs(tasks) do
        if v:IsFinished() then
            table.insert(taskResults, v:GetValue())
        else
            needWait = true -- 若有一个依赖的Task未完成，继续等待
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

    -- 进入Suspend状态（yield），下次Resume的时候需传入依赖task的返回值
    currentTask.CurrentWaited = tasks
    currentTask.Status = ELTaskStatus.Suspended
    currentTask.WaitType = ELTaskWaiteType.Wait_Task

    return coroutine.yield()
end

--[[
等待nTicks次TaskManager:Tick()
--]]
---@param nTicks integer @ 等待n次TaskManager:Tick()
function Await.WaitForTicks(nTicks)
    local currentThread = coroutine.running()
    local currentTask = TaskManager.tasks[currentThread]

    currentTask.ResumeFrame = TaskManager.TickFrame + nTicks
    currentTask.WaitType = ELTaskWaiteType.Wait_Tick
    coroutine.yield()
end

--[[
等待nTicks次TaskManager:Tick()
--]]
---@param interval number @ 等待interval秒
function Await.WaitForTime(interval)
    local currentThread = coroutine.running()
    local currentTask = TaskManager.tasks[currentThread]

    currentTask.ResumeTime = TaskManager.TickTime + interval
    currentTask.WaitType = ELTaskWaiteType.Wait_Time
    coroutine.yield()
end

return Await