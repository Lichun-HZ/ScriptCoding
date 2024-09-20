#!/usr/bin/lua

require("lldebugger").start()

--[[
table相关操作
--]]

--[[
table.next,
]]

local function TableTest(...)
    local m = "aaa"
	local k = "222"
	local v = "bbb"
	local t = table.pack(m, k, v)
    local tt = {m,k,v}

    local p1, q1, r1, n1 = table.unpack(t)
    local p2, q2, r2, n2 = table.unpack(tt)

    local paramBlock = {...} --或者table.pack(...)

    local localFunc = function()
        print(table.unpack(paramBlock))
    end

    localFunc()

    print(t)
end

TableTest(1,2,3)

local function metatableTest()
    local t = {hello = "hello键对应的值"}
    t.__index = t

    local a = setmetatable({}, t)

    t.__metatable = "__metatable键对应的值"
    local hello = a["hello"]

    local meta = getmetatable(a)

    setmetatable(a, {})
    print(hello)
end

metatableTest()