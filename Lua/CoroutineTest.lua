#!/usr/bin/lua
-- https://www.cnblogs.com/thammer/p/18112064
local co

function routine()
    print("在协程主体函数执行时，查询到的协程状态:", coroutine.status(co))
    coroutine.yield()
    print("退出协程了")
end

function test1()
    co = coroutine.create(routine)
    print("刚创建完协程时的状态:", coroutine.status(co))
    coroutine.resume(co)
    print("调用resume启动协程，yield后的状态:", coroutine.status(co))
    coroutine.resume(co)
    print("协程退出后的状态:", coroutine.status(co))
end

--[[ 
协程状态	          说明
running	    运行状态，协程主体函数正在执行时的状态
suspended	挂起状态，协程调用yeild，或者刚刚创建完成时的状态
normal	    正常状态，协程已激活（resume），但是执行序列不在此协程中，通常是协程嵌套时
dead	    死亡状态，协程主体函数执行完毕，或者主体函数执行异常，停止后的状态
--]]

local co1, co2

function routine1()
    print("第一级协程")
    print("在第一级协程查询到的第一级协程状态:", coroutine.status(co1))
    print("在第一级协程查询到的第二级协程状态:", coroutine.status(co2))
    coroutine.resume(co2)
    print("第一级协程退出了")
end

function routine2()
    print("第二级协程")
    print("在第二级协程查询到的第一级协程状态:", coroutine.status(co1))
    print("在第二级协程查询到的第二级协程状态:", coroutine.status(co2))
    print("第二级协程退出了")
end

function test2()
    co1 = coroutine.create(routine1)
    co2 = coroutine.create(routine2)
    coroutine.resume(co1)
end

--[[ 
1. 入口程序第一次调用resume，激活协程，进入协程函数体时：这时进行了一次执行权的切换，resume的所有参数"a", "b"（除了第一个thread类型参数），都传递给了协程函数体的参数p1, p2。
2. 协程执行序列调用yield让出执行权，执行序列回到入口函数体resume调用的返回前夕， yield的参数"c", "d"将作为resume的从第二开始的返回值列表，执行权回到入口函数体。
3. 入口函数体继续执行序列，第二次调用resume，执行权再次回协程执行序列，此时协程执行序列位于上一步yield调用的返回前夕，resume传递的参数e就作为了yield的返回值，协程执行序列继续执行。
4. 协程函数体执行到返回，让出执行权，返回值作为上一步入口函数体执行序列的第二次resume调用的返回值，执行序列再次回到入口函数体，此时协程死亡，状态变成dead。
5. 入口函数体再次执行resume,由于此时协程已经死了，所以resume执行结果是失败的，返回执行结果false和错误信息
--]]
function test3()
    local co = coroutine.create(function(p1, p2)
        print("传递给协程主函数体的参数:", p1, p2)
        while true do
            local yieldRet;
            yieldRet = coroutine.yield("c", "d")
            print("协程第一次调用yield的返回值列表:", yieldRet)
            local coRet = "f"
            return coRet
        end
    end)

    local resRet, value1, value2 = coroutine.resume(co, "a", "b")
    print("第一次调用resume的返回值列表:", resRet, value1, value2)
     
    resRet, value1 = coroutine.resume(co, "e")
    print("第二次调用resume的返回值列表:", resRet, value1)
     
    resRet, value1 = coroutine.resume(co, "g")
    print("第三次调用resume的返回值列表:", resRet, value1)
end

test1()
test2()
test3()