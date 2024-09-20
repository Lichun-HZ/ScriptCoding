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
--    error('Task1 error')
    sss.r = 1

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

function hello2()
    sss.r = 1
    return 100, 200
end

function errorhandler(error)
    print(error)
    print(debug.traceback())
end

function hello()
    local status, result = xpcall(hello2, errorhandler)
    if status then
        print("Get Result: ", result)
    else
        print("Error: ", result)
    end
end

function MainTask(task1, task2, p1)
    print("MainTask Begin: ", p1)
    print("MainTask Waiting Task1,2")

    local ret = LTask.Await.WaitForTasks({task1, task2})
    print("MainTask Waited Task1,2, get ", ret[1], ret[2])
    print("MainTask End")
end

hello()

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