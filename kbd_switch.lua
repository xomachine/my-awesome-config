local awful = require("awful")
local widget = require("wibox.widget")
-- local naughty = require("naughty")
 -- Keyboard map indicator and changer
local module = {}

module.new = function(key1, key2)
	-- Keyboard map indicator and changer
	kbdcfg = {}
	kbdcfg.cmd = "setxkbmap"
	kbdcfg.layout = { { "us", "", "US" }, { "ru", "", "RU" } }
	kbdcfg.current = 1  -- us is our default layout
	kbdcfg.widget = widget.textbox()
	kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
	kbdcfg.switch = function ()
	  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
	  local t = kbdcfg.layout[kbdcfg.current]
	  kbdcfg.widget:set_text(" " .. t[3] .. " ")
	  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
	end
	 -- Mouse bindings
	kbdcfg.widget:buttons(
	  awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
	  )

        root.keys(awful.util.table.join(root.keys(),
          awful.key({key1, }, key2, function()
            kbdcfg.switch()
            end)))
        return kbdcfg
end

return module
