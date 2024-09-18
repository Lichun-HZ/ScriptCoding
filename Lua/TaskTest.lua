#!/usr/bin/lua

require("lldebugger").start()
local TaskManager = require("Lua.Libs.LTask.TaskManager")

function Task1(p1, p2)
    print("Task1 Begin: ", p1, p2)
    coroutine.yield(10)
    print("Task1 End")
    return p1 + p2
end

function Task2(p1, p2)
    print("Task2 Begin: ", p1, p2)
    local ret = TaskManager:WaitForFunction(Task1, p1, p2)
    print("Task2 End")
    return ret
end

function MainTask(task1, task2, p1)
    print("MainTask Begin: ", p1)
    print("MainTask Waiting Task1,2")

    local ret = TaskManager:WaitForTasks({task1, task2})
    print("MainTask Waited Task1,2, get ", ret[1], ret[2])
    print("MainTask End")
end

local task1 = TaskManager:NewTask(Task1, false)
local task2 = TaskManager:NewTask(Task2, true, 100, 200)

local mainTask = TaskManager:NewTask(MainTask, false)

local i = 0
while i < 10 do
    if i == 3 then
        mainTask:Start(task1, task2, 100)
    end
    if i == 6 then
        task1:Start(1, 2)
    end
    TaskManager:Tick()
    i = i + 1
end