require("Lua.Libs.Base.Lib")
local TaskManager = require("Lua.libs.LTask.TaskManager")

---@enum ELTaskStatus
ELTaskStatus = {
    NotStart = 0,
    Running = 1,
    Suspended = 2,
    Dead = 3
}

---@enum ELTaskWaiteType
ELTaskWaiteType = {
    Wait_None = 0,
    Wait_Task = 1,
    Wait_Tick = 2,
    Wait_Time = 3
}

---@class Task:LClass
---@field Status ELTaskStatus       @ Task Running Status
---@field WaitType ELTaskWaiteType  @ Which type of wait
---@field Value any                 @ Value the task should return
---@field Coroutine thread          @ Coroutine this task execute
---@field Subsequent table<Task>    @ Tasks dependent on this task
---@field CurrentWaited table<Task> @ Tasks this task current waited to continue
---@field Id integer                @ Id represent this task in taskmanager
---@field ResumeFrame integer       @ ELTaskWaiteType.Wait_Tick, which frame to resume
---@field ResumeTime number         @ ELTaskWaiteType.Wait_Time, which time to resume
local Task = Base.Class("Task")

---@param inst Task
---@param Func function
function Task.Ctor(inst, Func)
    --print("Task.Ctor Called: ", inst)
    inst.Status = ELTaskStatus.NotStart
    inst.Coroutine = coroutine.create(Func)
    -- 登记到TaskManager中
    inst.Id = TaskManager:RegisterTask(inst)
    inst.WaitType = ELTaskWaiteType.Wait_None
end

-- 启动该Task
---@param ... any @task function的参数
function Task:Start(...)
    TaskManager:StartTask(self, ...)
end

---@return ELTaskStatus
function Task:GetStatus()
    return self.Status
end

function Task:IsFinished()
    return self.Status == ELTaskStatus.Dead
end

function Task:GetValue()
    return self.Value
end

return Task