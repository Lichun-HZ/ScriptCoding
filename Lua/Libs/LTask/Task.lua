---@enum ELTaskStatus
ELTaskStatus = {
    NotStart = 0,
    Running = 1,
    Suspended = 2,
    Dead = 3
}

---@class Task
---@field Manager TaskManager
---@field Status ELTaskStatus
---@field Value any
---@field Coroutine thread
---@field Subsequent table<Task>
---@field Prerequisite table<Task>
---@field Id integer
local Task = {}
Task.__index = Task

--[[
---@param Manager TaskManager
---@param Func function
---@return Task
function Task:New(Manager, Func)
    local inst = {}
    setmetatable(inst, self)

    inst.Manager = Manager
    inst.Coroutine = coroutine.create(Func)

    return inst
end
]]

function Task:Start(...)
    self.Manager:StartTask(self, ...)
end

---@return ELTaskStatus
function Task:GetStatus()
    return self.Status
end

function Task:GetValue()
    return self.Value
end

return Task