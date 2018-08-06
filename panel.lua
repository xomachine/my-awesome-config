local awful = require("awful")
local wibox = require("wibox")
local dbg = require("gears.debug")

local global_binds = {}

-- Each widget should return the widget factory as a first value and
-- the table of the global key bindings as the second optional value.
-- The widget factory is a function that receives the screen as an argument
-- and returns a new widget for the screen

local external_plugin_names = {
  "launcher",
  "taglist",
  "prompt",
  "tasklist",
  "kbd_switch",
  "audio",
  "layoutbox",
}

local plugins = {}
-- preloading the plugins to setup the keybinds
for i, v in pairs(external_plugin_names) do
  local ok, plugin = pcall(function() return require("widgets."..v) end)
  if ok then
    print(v..": "..tostring(plugin))
    if type(plugin) == "function" then plugins[v] = plugin
    else
      if plugin.bindings then
        global_binds = awful.util.table.join(global_binds, plugin.bindings)
      end
      print(v..": "..tostring(plugin.factory))
      if plugin.factory then plugins[v] = plugin.factory end
    end
  else
    dbg.print_warning("Can not load " .. tostring(v))
    dbg.print_warning(tostring(plugin))
  end
end
print("After load: "..tostring(#global_binds))

local function make_panel_for_screen(screen)
  local safeload = function(name) 
    local ok, obj = pcall(function()
      print(tostring(name))
      return plugins[name](screen)
    end)
    if ok then
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
          safeload("kbd_switch"),
          --awful.widget.keyboardlayout(),
          safeload("audio"),
          wibox.widget.textclock(),
          safeload("layoutbox")
      },
  }
end

awful.screen.connect_for_each_screen(make_panel_for_screen)

return global_binds
