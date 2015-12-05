local awful = require("awful")
local notify = require("naughty").notify
local widget = require("wibox.widget")


local awidget = widget.textbox()

awidget.get_volume = function()
  return awful.util.pread(
    "amixer get Master | grep -o '\\[[0-9]\\{2,3\\}%\\]'"
    )
end
awidget.curr_id = nil
awidget.get_mute = function()
  return awful.util.pread(
    "amixer get Master | grep -o '\\[[a-z]\\{2,3\\}\\]'"
    )
end
awidget.do_and_notify = function(todo, toshow, prefix)
  awful.util.spawn(todo)
  local state = toshow()
  if not prefix then prefix = "" end
  local n = notify({text=prefix .. state,
    replaces_id = awidget.curr_id})
  awidget.curr_id = n.id
  return state
end
awidget.increase = function()
  local m = awidget.do_and_notify("amixer set Master 2+", awidget.get_volume)
  awidget:set_text(m)
end
awidget.decrease = function()
  local m = awidget.do_and_notify("amixer set Master 2-", awidget.get_volume)
  awidget:set_text(m)
end
awidget.mute = function()
  local m = awidget.do_and_notify(
    "amixer set Master toggle",
    awidget.get_mute,
    "Звук: ")
  if m == "[on]\n" then
    awidget:set_text(awidget.get_volume())
  else
    awidget:set_text(m)
  end
end

local buts = {
  awful.button({ }, 1, function()
    awful.util.spawn(terminal .. " -e alsamixer")      
  end),
  awful.button({ }, 2, awidget.mute),
  awful.button({ }, 4, awidget.increase),
  awful.button({ }, 5, awidget.decrease)
}
awidget:buttons(awful.util.table.join(unpack(buts)))

awidget:set_text(awidget.get_volume())
local bindings = {
  awful.key({}, "XF86AudioMute", awidget.mute),
  awful.key({}, "XF86AudioPrev", awidget.decrease),
  awful.key({}, "XF86AudioNext", awidget.increase),
}
root.keys(awful.util.table.join(
  root.keys(), unpack(bindings)))
return awidget

