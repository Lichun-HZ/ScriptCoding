#!/usr/bin/lua

require("lldebugger").start()
require("Lua.Libs.Base.Lib")
require("Lua.Libs.LTask.Lib")

---@class MyAsyncTask : AsyncTask
local MyAsyncTask = Base.Class("MyAsyncTask", LTask.AsyncTask)

function MyAsyncTask.Ctor(inst, Func)
    --print("MyAsyncTask.Ctor Called: ", inst)
    MyAsyncTask.Super.Ctor(inst, Func)
    inst.AsyncValue = 1
end

function MyAsyncTask:SetAsyncValue(value)
    print("MyAsyncTask:SetAsyncValue: ", value)
    self:OnAsyncFinished(value)
end

function Task1(p1, p2)
    print("Task1 Begin: ", p1, p2)
    LTask.Await.WaitForTime(2)
    print("Task1 End")
    return p1 + p2
end

function Task2(p1, p2)
    print("Task2 Begin: ", p1, p2)
    local ret = LTask.Await.WaitForFunction(Task1, p1, p2)
    print("Task2 End")
    return ret
end

function AsyncTask1(p1, p2)
    print("AsyncTask1 Begin: ", p1, p2)
    coroutine.yield()
    print("AsyncTask1 End")
end

function MainTask(task1, task2, p1)
    print("MainTask Begin: ", p1)
    print("MainTask Waiting Task1,2")

    local ret = LTask.Await.WaitForTasks({task1, task2})
    print("MainTask Waited Task1,2, get ", ret[1], ret[2])
    print("MainTask End")
end

local task1 = MyAsyncTask:New(AsyncTask1)
local task2 = LTask.Task:New(Task2)

task1:Start(1, 2)
task2:Start(100, 200)

local mainTask = LTask.Task:New(MainTask)

local i = 0
while i < 100 do
    if i == 3 then
        mainTask:Start(task1, task2, 100)
    end
    if i == 6 then
        task1:SetAsyncValue(99999)
    end
    LTask.TaskManager:Tick(0.1)
    i = i + 1
end