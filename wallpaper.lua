local beautiful = require("beautiful")
local gears = require("gears")

local wallpaper = beautiful.wallpaper

local custompath = io.open(".config/awesome/wallpaper.path")
if custompath ~= nil then
    beautiful.wallpaper = custompath:read()
    custompath:close()
end

