local awful = require("awful")
local notify = require("naughty").notify
local widget = require("wibox.widget")

local AudioWidget = {}

local function parse_volume(volstr)
  local result = {}
  for vol in string.gmatch(volstr, "%s(%d+%%)%s") do
    table.insert(result, vol)
  end
  return result
end

local function parse_pactl_list(on_done)
  local result = {
    sources = {},
    sinks = {},
    clients = {},
    unsorted = {}
  }
  local toplvl = ""
  local subtype = "unsorted"
  local scndlvl = ""
  local cb = function(line)
    if string.match(line, "^%s%s%S.*$") then
    -- Third lvl directives
      if string.find(line, "=") then
        local k, v = string.match(line, "^%s([^%s=]+)%s+=%s+(.*)$")
        if k ~= nil then
          result[subtype][toplvl][scndlvl][k] = v
        end
      else
        table.insert(result[subtype][toplvl][scndlvl], line)
      end
    elseif string.match(line, "^%s%S.*$") then
    -- Second level directives
      local k, v = string.match(line, "^%s(%S[^:]+):%s*(.*)$")
      if k ~= nil then
        scndlvl = k
        if string.len(v) == 0 then
          result[subtype][toplvl][k] = {}
        else
          result[subtype][toplvl][k] = v
        end
      end
    elseif string.match(line, "^%S.*$") then
    -- Top lvl directives
      if string.match(line, "^Client.*$") then
        subtype = "clients"
      elseif string.match(line, "^Source.*$") then
        subtype = "sources"
      elseif string.match(line, "^Sink.*$") then
        subtype = "sinks"
      else
        subtype = "unsorted"
      end
      toplvl = line
      result[subtype][toplvl] = {}
    elseif string.match(line, "^%s .*$") then
      result[subtype][toplvl][scndlvl] = result[subtype][toplvl][scndlvl]..line
    end
  end
  local donecb = function ()
    on_done(result)
  end
  awful.spawn.with_line_callback("bash -c 'LANG= pactl list'",
                                 {stdout = cb, output_done = donecb})
  return result
end

function AudioWidget:update_volume()
  local cb = function(result)
    for sname, sink in pairs(result["sinks"]) do
      local vol = parse_volume(sink["Volume"])
      local mute = sink["Mute"]
      local _,_,bal = string.find(sink["Volume"], "balance (%d+%.%d+)")
      if mute == "yes" then
        self:displayState("Звук", "[off]")
      elseif bal == "0.00" then
        self:displayState("Громкость", tostring(vol[1]))
      else
        self:displayState("Громкость", tostring(vol[1]).."|"..tostring(vol[2]))
      end
    end
  end
  parse_pactl_list(cb)
end

function AudioWidget:change_volume(value)
  local cb = function() self:update_volume() end
  awful.spawn.easy_async("pactl set-sink-volume "..self.master.." "..value, cb)
end

function AudioWidget:toggle_mute()
  local cb = function() self:update_volume() end
  awful.spawn.easy_async("pactl set-sink-mute "..self.master.." toggle", cb)
end

function AudioWidget:displayState(message, state)
  local n = notify({text=message .. ": " .. state, replaces_id=self.msgid})
  self.msgid = n.id
  self.widget:set_text("["..state.."]")
end

function AudioWidget:new()
  local av = AudioWidget
  av.widget = widget.textbox()
  av.master = "@DEFAULT_SINK@"
  av.msgid = nil
  local buts = {
    awful.button({}, 1, function() awful.spawn.spawn("pavucontrol") end),
    awful.button({}, 2, function() av:toggle_mute() end),
    awful.button({}, 4, function() av:change_volume("+3%") end),
    awful.button({}, 5, function() av:change_volume("-3%") end),
  }
  av.widget:buttons(awful.util.table.join(unpack(buts)))
  av:update_volume()
  return av
end

return function(screen)
  local awidget = AudioWidget:new()
  local bindings = {
    awful.key({}, "XF86AudioMute", function() awidget:toggle_mute() end),
    awful.key({}, "XF86AudioRaiseVolume",
              function() av:change_volume("+3%") end),
    awful.key({}, "XF86AudioLowerVolume",
              function() av:change_volume("-3%") end),
  }
  return awidget
end

