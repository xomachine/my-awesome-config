local awful = require("awful")
local beautiful = require("beautiful")
local mymainmenu = require("menu")
return function(screen)
  return awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
end

