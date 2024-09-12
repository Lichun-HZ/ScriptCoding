#!/usr/bin/lua
--[[
    对luaoopTest的提炼
--]]

require("lldebugger").start()

---Create an class.
---@param classname string @The name of the class
---@param Super any @Base Class
function class(classname, Super)
    local superType = type(Super)
    if superType ~= "table" then
    local cls = {}

    error()
end