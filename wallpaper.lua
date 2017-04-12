local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")

local wallpaper = beautiful.wallpaper

local custompath = io.open(".config/awesome/wallpaper.path")
if custompath ~= nil then
    beautiful.wallpaper = custompath:read()
    custompath:close()
end
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(set_wallpaper)

