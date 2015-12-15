local beautiful = require("beautiful")
local gears = require("gears")

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(
        "/home/xomachine/Изображения/Arts/WallPapers/gunnm_lo_yoko_child.jpg", s, false)
    end
end
-- }}}