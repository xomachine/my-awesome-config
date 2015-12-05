local awful = require("awful")
local notify = require("naughty").notify
local widget = require("wibox.widget")

module  = {}

module.widget = function()
  local widget = widget.textbox()
  widget.get_volume = function()
    return awful.util.pread(
      "amixer get Master | grep -o '\\[[0-9]\\{2,3\\}%\\]'"
      )
  end
  widget.curr_id = nil
  widget.get_mute = function()
    return awful.util.pread(
      "amixer get Master | grep -o '\\[[a-z]\\{2,3\\}\\]'"
      )
  end
  widget.do_and_notify = function(todo, toshow, prefix)
    awful.util.spawn(todo)
    local state = toshow()
    if not prefix then prefix = "" end
    local n = notify({text=prefix .. state,
      replaces_id = widget.curr_id})
    widget.curr_id = n.id
    return state
  end
  widget:set_text(widget.get_volume())
  local bindings = {
    awful.key({}, "XF86AudioMute", 
      function()
        local m = widget.do_and_notify(
          "amixer set Master toggle",
          widget.get_mute,
          "Звук: ")
        if m == "[on]\n" then
          widget:set_text(widget.get_volume())
        else
          widget:set_text(m)
        end
      end
    ),
    awful.key({}, "XF86AudioPrev",
      function()
        local m = widget.do_and_notify("amixer set Master 2-", widget.get_volume)
        widget:set_text(m)
      end
    ),
    awful.key({}, "XF86AudioNext",
      function()
        local m = widget.do_and_notify("amixer set Master 2+", widget.get_volume)
        widget:set_text(m)
      end
    ),
  }
  root.keys(awful.util.table.join(
    root.keys(), unpack(bindings)))
  return widget
end

module.bindkeys = function()
   
end

return module