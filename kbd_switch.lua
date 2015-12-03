local awful = require("awful")
local widget = require("wibox.widget")
local naughty = require("naughty")
 -- Keyboard map indicator and changer
local module = {}

module.new = function(key1, key2)
	-- Keyboard map indicator and changer
	kbdcfg = {}
	kbdcfg.clients = {}
	kbdcfg.cmd = "setxkbmap"
	kbdcfg.layout = { { "us", "", "US" }, { "ru", "", "RU" } }
	kbdcfg.default = 1  -- us is our default layout
	kbdcfg.current = kbdcfg.default
	kbdcfg.widget = widget.textbox()
	kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
	kbdcfg.switch = function ()
	  kbdcfg.set(kbdcfg.current % #(kbdcfg.layout) + 1)
	  if client.focus then
	    kbdcfg.clients[client.focus.window] = kbdcfg.current
	    if kbdcfg.current == kbdcfg.default then
	      kbdcfg.clients[client.focus.window] = nil
	    end
	  end
	end
	kbdcfg.gotfocus = function (c)
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


        return kbdcfg
end

return module
