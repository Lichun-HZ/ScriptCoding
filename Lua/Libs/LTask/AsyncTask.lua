require("Lua.Libs.Base.Lib")
local Task = require("Lua.Libs.LTask.Task")
local TaskManager = require("Lua.libs.LTask.TaskManager")

---@class AsyncTask:Task
---@field AsyncValue any        @ Value returned by async opperation
---@field AsyncFinished boolean @ Dose async opperation returned?
local AsyncTask = Base.Class("AsyncTask", Task)

---@param inst AsyncTask
---@param Func function
function AsyncTask.Ctor(inst, Func)
    --print("AsyncTask.Ctor Called: ", inst)
    AsyncTask.Super.Ctor(inst, Func)
    inst.AsyncFinished = false
end

function AsyncTask:IsFinished()
    return self.Status == ELTaskStatus.Dead and self.AsyncFinished
end

function AsyncTask:GetValue()
    return self.AsyncValue
end

-- 当异步操作完成后，将异步的结果作为参数调用OnAsyncFinished
function AsyncTask:OnAsyncFinished(value)
    self.AsyncValue = value
    self.AsyncFinished = true

    -- 若异步函数已执行完成，调TaskComplete
    if self.Status == ELTaskStatus.Dead then
        TaskManager:OnTaskComplete(self)
    end
end

return AsyncTask