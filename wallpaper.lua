local awful = require("awful")
local gears = require("gears")

local function get_wallpapers_iterator()
    local wallpapers = {}
    local custompath = io.open(".config/awesome/wallpaper.path")
    if custompath ~= nil then
        for image_path in custompath:lines() do
            if image_path ~= "" then
                wallpapers[#wallpapers+1] = image_path
            end
        end
        custompath:close()
    end
    local wallpapers_len = #wallpapers
    if wallpapers_len > 0 then
        return function(s)
            local index = s.index % wallpapers_len
            return wallpapers[index+1]
        end
    end
end

local wallpapers_iterator = get_wallpapers_iterator()

local function set_wallpaper(s)
    -- Wallpaper
    if wallpapers_iterator ~= nil then
        local wallpaper = wallpapers_iterator(s)
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(set_wallpaper)

