local awful = require("awful")
local wibox = require("wibox")

local originalscreen = screen.primary
local orig_geom = originalscreen.geometry
local hiddenscreen = screen.fake_add(0, orig_geom.height, orig_geom.width, orig_geom.height)
awful.tag.new({"visible"}, screen[1], awful.layout.layouts[1])
awful.tag.new({"invisible"}, hiddenscreen, awful.layout.suit.floating)

local Tag = {}
function Tag.new()
  local faketable = {
    clients = {},
    hidden = true
  }
  return setmetatable(faketable, { __index = Tag })
end

function Tag:hide(self)
  for i, v in pairs(self.clients) do
    v:move_to_screen(hiddenscreen.index)
  end
  self.hidden = true
end

function Tag:show(self)
  for i, v in pairs(self.clients) do
    v:move_to_screen(originalscreen.index)
  end
  self.hidden = false
end

function Tag:toggle(self)
  if self.hidden then self:show() else self:hide() end
end

function Tag:attach(self, client)
  self.clients[client.window] = client
end

function Tag:detach(self, client)
  self.clients[client.window] = nil
end

local TagManager = {}

function TagManager.new(tagnames)
  local faketable = {
    taglist = {},
    selectedtag = nil,
    orderedtags = tagnames,
  }
  local buttons = {}
  for i, v in pairs(tagnames) do
    faketable.taglist[v] = Tag.new()
    local tagwidget = wibox.widget{
      markup = v,
      align  = 'center',
      valign = 'center',
      widget = wibox.widget.textbox
    }
    -- TODO: implement the mouse keybinds
    table.insert(buttons, tagwidget)
  end
  buttons.layout = wibox.layout.flex.horizontal
  faketable.widget = wibox.widget(buttons)
  return setmetatable(faketable, { __index = TagManager })
end

function TagManager:view_only(self, tagname)
  for i, v in pairs(self.taglist) do
    if i == tagname then v:show() else v:hide() end
  end
end

function TagManager:move_to_tag(self, client, tagname)
  if not self.taglist[tagname] then error("Tag "..tostring(tagname).." does not exists!") end
  if type(client.virtualtags) == "table" then
    -- remove the client from all the tags in the table
    for i, v in pairs(client.virtualtags) do
      if type(v) ~= "string" or self.taglist[v] then
      else
        self.taglist[v]:detach(client)
      end
    end
  end
  client.virtualtags = {tagname}
  self.taglist[tagname]:attach(client)
end

return {
  factory = function(screen)
    local tagman = TagManager.new({"1", "2", "3", "4", "5", "6", "7", "8", "9"})
    return tagman.widget
  end,
  bindings = {},
}
