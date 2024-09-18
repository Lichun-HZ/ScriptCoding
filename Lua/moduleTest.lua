#!/usr/bin/lua
require("lldebugger").start()

-- require的模块会登记在_G.package.loaded表里，不会自动添加在_G表中
local mymodule = require("Lua.Libs.mymodule")

mymodule.call_priv_func()

return