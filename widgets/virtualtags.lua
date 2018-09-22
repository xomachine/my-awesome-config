local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modkey = require("general").modkey

local originalscreen = screen.primary
local orig_geom = originalscreen.geometry
awful.tag.new({"visible"}, screen[1], awful.layout.layouts[1])
local function makefakescreen()
  local hs = screen.fake_add(0, orig_geom.height, orig_geom.width, orig_geom.height)
  return hs
end
local hiddenscreen = makefakescreen()
local hiddenaddr = tostring(hiddenscreen)
local hiddenindex = hiddenscreen.index
screen.connect_signal("removed", function(s)
  local saddr = tostring(s)
  if hiddenaddr == saddr then hiddenaddr = false end
  --print("removed: "..saddr)
end)
local Tag = {}
function Tag.new(name, notifier)
  local faketable = {
    clients = {},
    hidden = true,
    notifier = notifier or {active = function(a) end, clients = function (a) end},
    name = name,
    lastfocus = false
  }
  return setmetatable(faketable, { __index = Tag })
end

function Tag:hide()
  --print("Screen count: "..tostring(screen:count()))
  local focus = (not self.hidden) and client.focus
  for i, v in pairs(self.clients) do
    if focus and focus.window == i then self.lastfocus = focus end
    v:move_to_screen(hiddenindex)
  end
  self.hidden = true
  self.notifier.active(true)
end

function Tag:show()
  local first = self.lastfocus
  for i, v in pairs(self.clients) do
    if not first then first = v end
    v:move_to_screen(originalscreen.index)
  end
  if first then first:jump_to() end
  self.hidden = false
  self.notifier.active(false)
end

function Tag:toggle()
  if self.hidden then self:show() else self:hide() end
end

function Tag:attach(c)
  --print("Attaching "..tostring(c).." to tag "..self.name)
  if not hiddenaddr then
    hiddenscreen = makefakescreen()
    hiddenaddr = tostring(hiddenscreen)
    hiddenindex = hiddenscreen.index
    --print("Created screen with index "..tostring(hiddenindex))
  end
  self.clients[c.window] = c
  self.notifier.clients(true)
  if not self.lastfocus then self.lastfocus = c end
end

function Tag:detach(c)
  --print("Detaching "..tostring(c).." from tag "..self.name)
  if self.lastfocus and self.lastfocus.window == c.window then
    self.lastfocus = false
  end
  self.clients[c.window] = nil
  local exist = false
  for i, v in pairs(self.clients) do
    exist = true
    if self.hidden then break end
    if v:isvisible() then
      v:jump_to()
      break
    end
  end
  if not exist then
    self.notifier.clients(false)
    self.lastfocus = false
  end
end

local TagManager = {}

local globalbinds = {}
function TagManager.new(tagnames)
  local faketable = {
    taglist = {},
    selectedtag = nil,
  }
  local buttons = {}
  local self = setmetatable(faketable, { __index = TagManager })
  for i, v in pairs(tagnames) do
    local clientsign = wibox.widget {
      align  = 'left',
      valign = 'top',
      markup = '+',
      widget = wibox.widget.textbox,
      visible = false
    }
    local tagwidget = wibox.widget{
      {
        {
          {
            markup = v,
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
          },
          widget = wibox.container.margin,
          left = 2,
          right = 2,
          top = 2,
          bottom = 2,
        },
        clientsign,
        layout = wibox.layout.stack,
      },
      bg = beautiful.bg_normal,
      widget = wibox.container.background,
    }
    globalbinds = awful.util.table.join(globalbinds,
      awful.key({ modkey }, "#" .. i + 9,
                function ()
                  --print("Mod+"..tostring(i))
                  self:view_only(v)
                end,
                {description = "view tag #"..i, group = "virtualtag"}),
      -- awful.key({ modkey, "Control" }, "#" .. i + 9,
      --           function ()
      --           end,
      --           {description = "toggle tag #" .. i, group = "virtualtag"}),
      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function ()
                    --print("Mod+Shift+"..tostring(i))
                    if client.focus then
                      self:move_to_tag(client.focus, v)
                    end
                  end,
                {description = "move focused client to tag #"..i, group = "virtualtag"})
    )
    local guinotifier = {
      active = function (is_selected)
        if is_selected then tagwidget.bg = beautiful.bg_selected
        else tagwidget.bg = beautiful.bg_normal end
      end,
      clients = function (exist)
        --print("Clients indicator visibility: "..tostring(exist))
        clientsign:set_visible(exist)
      end
    }
    tagwidget.tag = Tag.new(v, guinotifier)
    tagwidget.id = v
    self.taglist[v] = tagwidget.tag
    local keybinds = awful.util.table.join(
      awful.button({ }, 1, function(t) self:view_only(t.widget.id) end),
      awful.button({ modkey }, 1, function(t)
                                --print("Mod+1 pressed!")
                                if client.focus then
                                    self:move_to_tag(client.focus, t.widget.id)
                                end
                            end)
      --awful.button({ }, 3, awful.tag.viewtoggle),
      --awful.button({ modkey }, 3, function(t)
      --                          if client.focus then
      --                              client.focus:toggle_tag(t)
      --                          end
      --                      end),
      --awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
      --awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)

    )
    tagwidget:buttons(keybinds)
    table.insert(buttons, tagwidget)
  end
  client.connect_signal("manage", function(c)
    --print("Client ".. tostring(c).." is attached to the tag "..tostring(self.selectedtag))
    if self.selectedtag then self:move_to_tag(c, self.selectedtag) end
  end)
  client.connect_signal("unmanage", function(c)
    --print("Client ".. tostring(c).." is detached from all the tags")
    for k, v in pairs(self.taglist) do
      v:detach(c)
    end
    c.virtualtags = nil
  end)
  buttons.layout = wibox.layout.flex.horizontal
  self.widget = wibox.widget(buttons)
  self:view_only(tagnames[1])
  return self
end

function TagManager:view_only(tagname)
  local coords = mouse.coords()
  for i, v in pairs(self.taglist) do
    if i ~= tagname then v:hide() end
  end
  self.taglist[tagname]:show()
  mouse.coords(coords)
  self.selectedtag = tagname
end

function TagManager:move_to_tag(c, tagname)
  if not self.taglist[tagname] then error("Tag "..tostring(tagname).." does not exists!") end
  --if self.selectedtag ~= tagname then self.taglist[tagname]:hide() end
  local coords = mouse.coords()
  if self.selectedtag ~= tagname then c:move_to_screen(hiddenscreen) end
  if type(c.virtualtags) == "table" then
    -- remove the c from all the tags in the table
    for i, v in pairs(c.virtualtags) do
      if type(v) == "string" and self.taglist[v] then
        self.taglist[v]:detach(c)
      end
    end
  end
  c.virtualtags = {tagname}
  self.taglist[tagname]:attach(c)
  mouse.coords(coords)
  --print("Client moved to tag "..tagname)
end

local tagman = TagManager.new({"1", "2", "3", "4", "5", "6", "7", "8", "9"})
--print(awful.wibar.bg)
--local beautiful = require("beautiful")
--for k, v in pairs(beautiful) do
--  print(tostring(k)..": "..tostring(v))
--
--end
return {
  factory = function(screen)
    return tagman.widget
  end,
  bindings = globalbinds,
}
