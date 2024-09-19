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
    cls.Ctor = function()    -- 默认构造函数
    end

    -- GetClass不用每个实例都有，直接放到class表中，实例访问时调用class表的
    cls.GetClass = function()
        return cls  -- upvalue, GetClass用.或者:访问都行
    end

    -- 设置基类为该类的metatable
    if Super ~= nil then
        setmetatable(cls, Super)
    end

    -- 创建实例函数
    cls.New = function()  -- upvalue, new用.或者:访问都行
        local inst = {}

        -- 若有基类，调用基类的new，会调用基类的Ctor
        if cls.super ~= nil then
            inst = cls.super:New()
        end

        setmetatable(inst, cls) -- 设置类表为实例表的metatable
        inst:Ctor()  -- 对实例调用类的构造函数

        return inst
    end

    return cls
end

---@class BaseClass
---@field public x integer
---@field public y integer
BaseClass = Class("BaseClass")

-- 替换掉默认构造函数，类表在Class中无法调用构造函数，因为那时候构造函数还是默认的空function
-- 在这里替换之后，可以对类表掉构造函数，但看起来就比较ugly了。因此类表中是没有构造函数中设置的
-- 这些参数的，每个实例的表中有自己的一份参数。
function BaseClass:Ctor()
    self.x = 0
    self.y = 0
end

-- BaseClass:Ctor() -- 对类调构造函数，这样类表中就会有该类的参数的默认值。

-- 可对类定义一个静态构造函数，里面设置该类的静态成员，但调用方式也是比较ugly，只能在定义后手动调用。
-- 但这种设计对于lua来说无法保证，访问可以通过类名或者实例名来访问，但设置只能通过类名，不能通过实例名，
-- 否则该实例就有自己的拷贝了。lua无法从语言角度来强制。
function BaseClass.SCtor()
    BaseClass.sx = 9
end

BaseClass.SCtor() -- 调用类静态构造函数

function BaseClass:Print()
    print(self.x,self.y,self.sx)
end

---@class DerivedClass : BaseClass
---@field public z integer
DerivedClass = Class("DerivedClass", BaseClass)
function DerivedClass:Ctor()
    self.z = 0
end

function DerivedClass:Print()
    print(self.x,self.y,self.z,self.sx)
end

---@type BaseClass
local a = BaseClass:New()
local a1 = BaseClass:New()

---@type DerivedClass
local b = DerivedClass:New()
local b1 = DerivedClass:New()

local aClass = a:GetClass()
local bClass = b:GetClass()

a:Print()
a1:Print()
b:Print()
b1:Print()

-- 行为与luaoppFramework一样，但之前实例中已经有自己独立的拷贝了
a.x = 10
b.z = 100

-- 对a调用sz赋值后，a拥有自己的拷贝，其他实例还是使用BaseClass的
a.sx = 99

a:Print()
a1:Print()
b:Print()
b1:Print()

--[[
输出：
    0	0	9
    0	0	9
    0	0	0	9
    0	0	0	9
    10	0	99
    0	0	9
    0	0	100	9
    0	0	0	9
--]]

return