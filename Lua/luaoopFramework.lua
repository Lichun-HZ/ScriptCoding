#!/usr/bin/lua
--[[
    对luaoopTest的提炼
--]]

require("lldebugger").start()

---Create an Class.
---@param classname string @The name of the class
---@param Super table @Base Class
function Class(classname, Super)
    -- 若Super不为nil，则必须是一个table
    if Super ~= nil then
        local superType = type(Super)
        if superType ~= "table" then
            error("Super must be a table, " .. superType)
        end 
    end

    local cls = {}           -- 创建类表
    cls.name = classname     -- 设置类名
    cls.super = Super        -- 设置基类
    cls.__index = cls        -- 设置__index为自身

    -- GetClass不用每个实例都有，直接放到class表中，实例访问时调用class表的
    cls.GetClass = function()
        return cls  -- upvalue, GetClass用.或者:访问都行
    end

    -- 设置基类为该类的metatable
    if Super ~= nil then
        setmetatable(cls, Super)
    end

    -- 创建实例函数
    cls.New = function(self)  -- no upvalue, new只能用:访问
        local inst = {}

        -- 若有基类，调用基类的new，这里因为没干什么，也可以不用调
        if self.super ~= nil then
            inst = self.super:New()
        end

        setmetatable(inst, self)
        return inst
    end

    return cls
end

---@class BaseClass 
---@field public x integer
---@field public y integer
BaseClass = Class("BaseClass")
BaseClass.x = 0
BaseClass.y = 0

function BaseClass:Print()
    print(self.x,self.y)
end

---@class DerivedClass : BaseClass
---@field public z integer
DerivedClass = Class("DerivedClass", BaseClass)
DerivedClass.z = 0

function DerivedClass:Print()
    print(self.x,self.y,self.z)
end

---@type BaseClass
local a = BaseClass:New()

---@type DerivedClass
local b = DerivedClass:New()

local aClass = a:GetClass()
local bClass = b:GetClass()

a:Print()
b:Print()

-- 第一次设置时，实例的变量才会登记到实例的表里，否则都使用类表里的
a.x = 10
b.z = 100

a:Print()
b:Print()

--[[
输出：
    0	0
    0	0	0
    10	0
    0	0	100
--]]

return