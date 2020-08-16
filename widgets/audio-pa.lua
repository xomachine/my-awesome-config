local awful = require("awful")
local gears = require("gears")
local notify = require("naughty").notify
local widget = require("wibox.widget")
local unpack = unpack or table.unpack

local AudioWidget = {
  master_sink = "@DEFAULT_SINK@",
  master_source = "@DEFAULT_SOURCE@",
  msgid = nil,
  widgets = {}
}

local function parse_volume(volstr)
  local result = {}
  for vol in string.gmatch(volstr, "%s(%d+%%)%s") do
    table.insert(result, vol)
  end
  return result
end

local function get_default_sink_source(pactl_list, setter)
  local sink, source = nil, nil
  local cb = function (line)
    if sink == nil then
      sink = string.match(line, "^Default Sink: (.*)$")
      if sink ~= nil then return end
    end
    if source == nil then
      source = string.match(line, "^Default Source: (.*)$")
    end
  end
  local done_cb = function()
    for sname, stable in pairs(pactl_list.Sink) do
      if stable.Name == sink then sink = sname  end
    end
    for sname, stable in pairs(pactl_list.Source) do
      if stable.Name == source then source = sname end
    end
    setter(sink, source)
  end
  awful.spawn.with_line_callback("bash -c 'LANG= pactl info'",
                                 {stdout=cb, output_done=done_cb})
end

local function parse_pactl_list(on_done)
  local result = {
    Source = {},
    Sink = {},
    Client = {},
    unsorted = {}
  }
  local toplvl = ""
  local subtype = "unsorted"
  local scndlvl = ""
  local cb = function(line)
    if string.match(line, "^%s%s%S.*$") then
    -- Third lvl directives
      if string.find(line, "=") then
        local k, v = string.match(line, "^%s%s([^=]+)%s+=%s+\"(.*)\"$")
        if k ~= nil then result[subtype][toplvl][scndlvl][k] = v end
      else
        table.insert(result[subtype][toplvl][scndlvl], line)
      end
    elseif string.match(line, "^%s%S.*$") then
    -- Second level directives
      local k, v = string.match(line, "^%s(%S[^:]+):%s*(.*)$")
      if k ~= nil then
        scndlvl = k
        if string.len(v) == 0 then result[subtype][toplvl][k] = {}
        else result[subtype][toplvl][k] = v end
      end
    elseif string.match(line, "^%S.*$") then
    -- Top lvl directives
      subtype, toplvl = string.match(line, "^([^#]+) #(%d+)$")
      if result[subtype] == nil then result[subtype] = {} end
      result[subtype][toplvl] = {}
    elseif string.match(line, "^%s .*$") then
      result[subtype][toplvl][scndlvl] = result[subtype][toplvl][scndlvl]..line
    end
  end
  local donecb = function ()
    on_done(result)
    collectgarbage("collect")
  end
  awful.spawn.with_line_callback("bash -c 'LANG= pactl list'",
                                 {stdout = cb, output_done = donecb})
end

function AudioWidget.redraw_all(pactl_list)
  local mastersink = pactl_list.Sink[AudioWidget.master_sink]
  if not mastersink then return end
  local vol = parse_volume(mastersink.Volume)
  local mute = mastersink.Mute
  local _,_,bal = string.find(mastersink.Volume, "balance (%d+%.%d+)")
  if mute == "yes" then
    AudioWidget.displayState("Звук", "off")
  elseif bal == "0.00" then
    AudioWidget.displayState("Громкость", tostring(vol[1]))
  else
    AudioWidget.displayState("Громкость", tostring(vol[1]).."|"..tostring(vol[2]))
  end
end

function AudioWidget.update_volume()
  parse_pactl_list(AudioWidget.redraw_all)
end

function AudioWidget.update_defaults(pactl_list)
  get_default_sink_source(pactl_list, function (sink, source)
    AudioWidget.master_sink = sink
    AudioWidget.master_source = source
    AudioWidget.redraw_all(pactl_list)
  end)
end

function AudioWidget.change_volume(value)
  awful.spawn.easy_async("pactl set-sink-volume "..AudioWidget.master_sink..
                         " "..value, AudioWidget.update_volume)
end

function AudioWidget.toggle_mute()
  awful.spawn.easy_async("pactl set-sink-mute "..AudioWidget.master_sink..
                         " toggle", AudioWidget.update_volume)
end

function AudioWidget.displayState(message, state)
  local n = notify({text=message .. ": " .. state, replaces_id=AudioWidget.msgid})
  AudioWidget.msgid = n.id
  for widget, _ in pairs(AudioWidget.widgets) do
    widget:set_state(state)
  end
end

function AudioWidget:set_state(state)
  self.widget:set_text("["..state.."]")
end

function AudioWidget.new()
  local av = {}
  av.widget = widget.textbox()
  av.msgid = nil
  local buts = {
    awful.button({}, 1, function() awful.spawn.spawn("pavucontrol") end),
    awful.button({}, 2, function() AudioWidget.toggle_mute() end),
    awful.button({}, 4, function() AudioWidget.change_volume("+3%") end),
    awful.button({}, 5, function() AudioWidget.change_volume("-3%") end),
  }
  av.widget:buttons(awful.util.table.join(unpack(buts)))
  AudioWidget.update_volume()
  AudioWidget.widgets[av] = true
  return setmetatable(av, {__index=AudioWidget})
end

parse_pactl_list(AudioWidget.update_defaults)

return {
  factory = function(screen)
    local aw = AudioWidget.new()
    return aw
  end,
  bindings = gears.table.join(
      awful.key({}, "XF86AudioMute", function() AudioWidget.toggle_mute() end),
      awful.key({}, "XF86AudioRaiseVolume",
                function() AudioWidget.change_volume("+3%") end),
      awful.key({}, "XF86AudioLowerVolume",
                function() AudioWidget.change_volume("-3%") end)
  )
}

