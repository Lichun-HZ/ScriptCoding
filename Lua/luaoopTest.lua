#!/usr/bin/lua
require("lldebugger").start()

--类的声明，这里声明了类名还有属性，并且给出了属性的初始值
---@class Class
---@field x integer
---@field y integer
Class = {x=0,y=0}

--设置元表的索引，想模拟类的话，这步操作很关键
Class.__index = Class

--构造方法，构造方法的名字是随便起的，习惯性命名为new()
---@return Class
---@param x integer
---@param y integer
function Class.new(x,y)
    --创建一个新表instance，代表新的对象
    local instance = {}

    --将instance的元表设定为Class，因为Class.__index就是Class表，所以instance.访问不存在的元素时，会在Class表中查询。
    setmetatable(instance, Class)

    --属性值初始化，在此之前访问instance.x，因为instance表中没有x，会访问Class.x。
    --instance.x = x设置instance.x，因为元表Class中没有__newindex，所以会为表instance创建x，这个x就相当于instance自己的变量值
    --在instance.x = x之后，如果再访问instance.x，就会访问instance表自己的，而不会再访问Class.x。
    --因此，instance表中的变量只有在第一次赋值时才会创建，否则会一直访问Class表中的。这刚好无论是行为上还是性能上都是最好的，
    --不设置时，每个实例都用类的默认值，哪个实例设置了，就为其单独分配一个自己的变量，之后就访问自己的，其他实例还是共用类的。
    instance.x = x
    instance.y = y

    return instance  --返回自身
end

 --这里定义类的其他方法
function Class:print()
    print(self.x,self.y)
end

function Class:plus()
    self.x = self.x + 1
    self.y = self.y + 1
end

--声明了新的属性Z
---@class SubClass : Class
---@field z integer
SubClass = {z = 0}

--还是和类定义一样，表索引设定为自身
SubClass.__index = SubClass

--设置元表为Class，因为Class.__index为Class，所以当变量在SubClass中找不到时，会到Class表中查找。
setmetatable(SubClass, Class)

--这里是构造方法，这个new是SubClass表中的，Class表中有一个自己的new
---@return SubClass
function SubClass.new(x,y,z)
    --这个语句相当于其他语言的super ，可以理解为调用父类的构造函数
    local instance = Class.new(x,y)

    --将对象的元表更新为SubClass类（否则为Class类，就无法访问SubClass的变量和函数）
    setmetatable(instance, SubClass)

    --新的属性初始化，如果没有将会按照声明=0
    --instance.z = z

    return instance
end

 --定义一个新的方法
function SubClass:go()
    self.x = self.x + 10
end

 --重定义父类的方法，相当于override
function SubClass:print()
    print(self.x,self.y,self.z)
end

local a = Class.new(1, 2)
a:plus()
a:print()

local b = SubClass.new(10, 20, 30)
b:plus()
b:print()
b.z = 30
b:print()

--[[

关键代码：

Class = {x=0,y=0}
Class.__index = Class

SubClass = {z = 0}
SubClass.__index = SubClass
setmetatable(SubClass, Class)

local a = {}
setmetatable(a, Class)

local b = {}
setmetatable(b, SubClass)

--]]