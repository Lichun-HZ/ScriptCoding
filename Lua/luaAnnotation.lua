#!/usr/bin/lua

-- https://www.yuque.com/lichun-mverm/phfz2b/kmipuso982bblnz4

--[[
1. @class类声明注解
@class MY_TYPE[:PARENT_TYPE] [@comment]
--]]

---@class Transport @Transport Base Class
---@field public name string @add name field to class Car, you'll see it in code completion
---@field public canfly boolean @add name field to class Car, you'll see it in code completion
local Transport = {}

function Transport:test()
end

---@class Car : Transport @define class Car extends Transport
local Car = {}
setmetatable(Car, Transport)

function Car.New()
    local _car = {}
    setmetatable(_car, Car)
    return _car
end

--[[
2. @type类型标记注解
@type MY_TYPE[|OTHER_TYPE] [@comment]
--]]

---@type Car @global variable type
local myCar = Car.New()
myCar.canfly = false

--[[
3. @alias 别名注解，比如下面的 fun(type: string, data: any):void 这个其实是一个function类型，
将这个整体定义为Handler别名，以后你输入就方便了，你可以理解为c++里面的宏定义。
@alias NEW_NAME TYPE
4. @param参数类型标记注解，用@param标记函数参数类型。
@param param_name MY_TYPE[|other_type] [@comment]
--]]

---@alias Handler fun(type: string, data: any):void

---@param handler Handler
function addHandler(handler)
end

--[[
5. @return 函数返回值注解，调用该函数返回的对象，不需要再对其写@type进行标记，就可以知道其类型。
@return MY_TYPE[|OTHER_TYPE] [@comment]
--]]

---@return Car|Ship
local function create()
end

---Here car_or_ship doesn't need @type annotation, EmmyLua has already inferred the type via "create" function
local car_or_ship = create()


--[[
9. 数组类型，可以利用 MY_TYPE[] 的方式来标注一个数据类型为数组
@type MY_TYPE[]
--]]

---@type Car[]
local list = {}

local car = list[1]
-- car. and you'll see completion
car.name = 'mini'

for i, car in ipairs(list) do
    -- car. and you'll see completion
    if car.canfly then
    end
end

--[[
10. 字典类型，可以利用 table<KEY_TYPE, VALUE_TYPE> 的方式来标注一个数据类型为字典
@type table<KEY_TYPE, VALUE_TYPE>
--]]

---@type table<string, Car>
local dict = {}

local car = dict['key']
-- car. and you'll see completion

for key, car in pairs(dict) do
    -- car. and you'll see completion
end

--[[
11. 函数类型，可以利用 fun(param:MY_TYPE):RETURN_TYPE 的方式来标注一个数据类型为函数
@type fun(param:MY_TYPE):RETURN_TYPE
--]]

---@type fun(key:string):Car
local carCreatorFn1

local car = carCreatorFn1('key')
-- car. and you see code completion

---@type fun():Car[]
local carCreatorFn2

for i, car in ipairs(carCreatorFn2()) do
    -- car. and you see completion
end

--[[
12. 字面量类型，允许你指定字符串作为固定的代码提示，结合 @alias 特性可以起到类似“枚举”的效果
--]]

---@alias AHandler fun(type: string, data: any):void

---@param event string | "'onClosed'" | "'onData'"
---@param handler AHandler | "function(type, data) print(data) end"
function addEventListener(event, handler)
end

--[[
13. @see 引用
--]]

---@class Enmmy
local emmy = {}

function emmy:sayHello() end

---@see Enmmy#sayHello
local function testHello()
end
