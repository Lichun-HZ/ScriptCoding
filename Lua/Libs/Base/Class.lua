#!/usr/bin/lua

---Create an Class.
---@param classname string @The name of the class
---@param Super table|nil @Base Class
local Class = function(classname, Super)
    -- 若Super不为nil，则必须是一个table
    if Super ~= nil then
        local superType = type(Super)
        if superType ~= "table" then
            error("Super must be a table, " .. superType)
        end
    end

    local cls = {}           -- 创建类表
    cls.Name = classname     -- 设置类名
    cls.Super = Super        -- 设置基类

    cls.__index = cls        -- 设置__index为自身

    -- GetClass不用每个实例都有，直接放到class表中，实例访问时调用class表的
    cls.GetClass = function()
        return cls  -- upvalue, GetClass用.或者:访问都行
    end

    -- 设置基类为该类的metatable
    if Super ~= nil then
        setmetatable(cls, Super)
    else
        cls.Ctor = function()    -- 基类默认构造函数
        end
    end

    -- 创建实例函数
    cls.New = function(self, ...)
        local inst = {}

        -- 若有基类，调用基类的new，会调用基类的Ctor
        --if cls.Super ~= nil then
        --    inst = cls.Super:New(...)
        --end

        setmetatable(inst, self) -- 设置类表为实例表的metatable
        inst.Ctor(inst, ...)  -- 对实例调用类的构造函数

        return inst
    end

    return cls
end

return Class