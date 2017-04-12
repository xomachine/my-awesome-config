local awful = require("awful")
local wibox = require("wibox")
local dbg = require("gears.debug")

local function make_panel_for_screen(screen)
  local safeload = function(name) 
    local f, obj = pcall(function()
      return require("widgets."..name)(screen)
    end)
    if f then 
      return obj
    else
      dbg.print_warning("Cannot load "..tostring(name))
      dbg.print_warning(tostring(obj))
    end
  end
  screen.mywibox = awful.wibar({
    position = "top",
    screen = screen
  })
  screen.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
          layout = wibox.layout.fixed.horizontal,
          safeload("launcher"),
          safeload("taglist"),
          safeload("prompt"),
      },
      safeload("tasklist"), -- Middle widget
      { -- Right widgets
          layout = wibox.layout.fixed.horizontal,
          wibox.widget.systray(),
          awful.widget.keyboardlayout(),
          safeload("audio"),
          wibox.widget.textclock(),
          safeload("layoutbox")
      },
  }
end

awful.screen.connect_for_each_screen(make_panel_for_screen)

