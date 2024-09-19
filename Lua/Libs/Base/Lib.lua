Base = {}

---@class LClass
---@field Name string       @ Class Name
---@field Super table|nil   @ Super Class or nil
---@field Ctor function(inst:LClass,...)     @ Constructor, 用"."进行定义
---@field GetClass function @ Get the Class
---@field New function      @ Create a new instance
Base.LClass = {}

Base.Class = require("Lua.Libs.Base.Class")

return Base