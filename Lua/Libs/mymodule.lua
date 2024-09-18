-- !/usr/bin/lua
-- -*- encoding:utf-8 -*-
-- filename: mymodule.lua
-- author: 简单教程(www.twle.cn)
-- Copyright © 2015-2065 www.twle.cn. All rights reserved.

local mymodule = {}

-- 定义一个常量
mymodule.constant = "这是一个模块常量"

-- 定义一个函数
function mymodule.hello()
    io.write("这是一个定义在 mymodule 模块内的公开函数")
    io.write("Hello World!\n")
end

-- 定义一个私有函数，私有函数其实就是一个没有登记到module表中的函数

local function priv_func()
    io.write("这是一个定义在 mymodule 模块内的私有函数")
end


-- 定义一个公开函数调用 私有函数 priv_func
function mymodule.call_priv_func()
    priv_func()
end

-- 返回模块
return mymodule

-- 模块定义完成