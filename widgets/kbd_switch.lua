local awful = require("awful")
local widget = require("wibox.widget")
local gears = require("gears")
--local notify = require("naughty").notify
 -- Keyboard map indicator and changer

local new = function(key1, key2)
	-- Keyboard map indicator and changer
	local kbdcfg = {}
	kbdcfg.clients = {} -- memory of layout for each window
	kbdcfg.cmd = "setxkbmap"
	kbdcfg.layout = { { "us", "", "US" }, { "ru", "", "RU" } }
	kbdcfg.default = 1  -- us is our default layout
	kbdcfg.current = kbdcfg.default
	kbdcfg.desktop = kbdcfg.default -- when no window focused
  kbdcfg.frozen_focus = false
	kbdcfg.widget = widget.textbox()
	kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
	kbdcfg.switch = function ()
	  kbdcfg.set(kbdcfg.current % #(kbdcfg.layout) + 1)
	  if client.focus then
	    kbdcfg.clients[client.focus.window] = kbdcfg.current
	    if kbdcfg.current == kbdcfg.default then
	      kbdcfg.clients[client.focus.window] = nil
	    end
	  else
	    kbdcfg.desktop = kbdcfg.current
	  end
	end
	kbdcfg.gotfocus = function (c)
	  if not c then
	    kbdcfg.set(kbdcfg.desktop)
      return
	  end
    if kbdcfg.frozen_focus then return end
	  if kbdcfg.clients[c.window] then
	    kbdcfg.set(kbdcfg.clients[c.window])
	  else
	    kbdcfg.set(kbdcfg.default)
	  end
	end
  
	kbdcfg.set = function (l)
	  kbdcfg.current = l
	  local t = kbdcfg.layout[kbdcfg.current]
	  kbdcfg.widget:set_text(" " .. t[3] .. " ")
	  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
	end

	client.connect_signal("focus", kbdcfg.gotfocus)
	client.connect_signal("unmanage", function(c) kbdcfg.clients[c.window] = nil end)
	 -- Mouse bindings
	kbdcfg.widget:buttons(
	  awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
	  )
        -- Set keybind for layout switch
  root.keys(awful.util.table.join(root.keys(),
    awful.key({key1, }, key2, function()
      kbdcfg.switch()
      end)))
  
  -- Keyboard switch to default when using a hotkeys
  kbdcfg.keytimer = gears.timer({timeout = 2})
  kbdcfg.keytimer:connect_signal("timeout", function()
    kbdcfg.frozen_focus = false
    kbdcfg.gotfocus(client.focus)
  end)
  local mod_pressed = function()
    kbdcfg.set(kbdcfg.default)
    kbdcfg.frozen_focus = true
    awful.keygrabber.stop()
    kbdcfg.keytimer:again()
  end
  local mkey = awful.key({}, "Super_L", mod_pressed)
  local ckey = awful.key({}, "Control_L", mod_pressed)
  root.keys(awful.util.table.join(root.keys(),
   mkey,ckey))
  key.connect_signal("press", function(a, b, c) if kbdcfg.frozen_focus then kbdcfg.keytimer:again() end end)

  return kbdcfg
end
return function (screen)
  screen.kbd_switch = new("Shift", "Control_L")
  return screen.kbd_switch.widget
end
