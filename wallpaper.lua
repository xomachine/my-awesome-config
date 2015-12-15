local beautiful = require("beautiful")
local gears = require("gears")

local wallpaper = beautiful.wallpaper

local custompath = io.open(".config/awesome/wallpaper.path")
if custompath ~= nil then
    wallpaper = custompath:read()
    custompath:close()
end
-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(
        wallpaper, s, false)
    end
end
-- }}}