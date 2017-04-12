local awful = require("awful")
local notify = require("naughty").notify
local widget = require("wibox.widget")
local terminal = require("general").terminal

AudioWidget = {}


local function get_volume(state)
  return string.match(state, "%[%d%d?%d?%%%]")
end
local function get_mute(state)
  return string.match(state, "%[[a-z][a-z][a-z]?%]")
end
local function get_state(cb)
  awful.spawn.easy_async("amixer get Master", cb)
end
function AudioWidget:do_and_notify(todo, toshow)
  local cb = function(state, se, er, ec)
    local message = toshow(state)
    local n = notify({text=message,
      replaces_id = self.curr_id})
    self.curr_id = n.id
  end
  awful.spawn.easy_async(todo, cb)
end
function AudioWidget:crease(direction)
  local cb = function(s)
    local v = get_volume(s)
    self.widget:set_text(v)
    return v
  end
  self:do_and_notify("amixer set Master 2"..tostring(direction), cb)
end
function AudioWidget:decrease()
  self:crease("-")
end
function AudioWidget:increase()
  self:crease("+")
end
function AudioWidget:mute()
  self:do_and_notify("amixer set Master toggle", on_mute_status)
  local on_mute_status = function(status)
    local state = get_mute(status)
    if state == "[on]" then
      state = get_volume(status)
    end
    self.widget:set_text(tostring(state))
    return "Звук: "..tostring(state)
  end
end
function AudioWidget:new()
  --local av = {
  --  curr_id = nil,
  --  widget = widget.textbox()
  --}
  local av = AudioWidget
  av.curr_id = nil
  av.widget = widget.textbox()
  return av
end

return function(screen)
  local awidget = AudioWidget:new()

  local buts = {
    awful.button({ }, 1, function()
      awful.spawn(terminal .. " -e alsamixer")      
    end),
    awful.button({ }, 2, function() awidget:mute() end),
    awful.button({ }, 4, function() awidget:increase() end),
    awful.button({ }, 5, function() awidget:decrease() end)
  }
  awidget.widget:buttons(awful.util.table.join(unpack(buts)))
  
  get_state(function(s) awidget.widget:set_text(tostring(get_volume(s))) end)
  local bindings = {
    awful.key({}, "XF86AudioMute", function() awidget:mute() end),
    awful.key({}, "XF86AudioRaiseVolume", function() awidget:increase() end),
    awful.key({}, "XF86AudioLowerVolume", function() awidget:decrease() end),
  }
  root.keys(awful.util.table.join(
    root.keys(), unpack(bindings)))
  return awidget
end

