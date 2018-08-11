local awful = require("awful")
local wibox = require("wibox")
local modkey = require("general").modkey

local originalscreen = screen.primary
local orig_geom = originalscreen.geometry
local hiddenscreen = screen.fake_add(0, orig_geom.height, orig_geom.width, orig_geom.height)
awful.tag.new({"visible"}, screen[1], awful.layout.layouts[1])
awful.tag.new({"invisible"}, hiddenscreen, awful.layout.suit.floating)

local Tag = {}
function Tag.new(name, selector)
  local faketable = {
    clients = {},
    hidden = true,
    selector = selector or function(a) end,
    name = name
  }
  return setmetatable(faketable, { __index = Tag })
end

function Tag:hide()
  for i, v in pairs(self.clients) do
    print(tostring(i).." = "..tostring(v))
    print(tostring(hiddenscreen.index))
    v:move_to_screen(hiddenscreen.index)
  end
  self.hidden = true
  self.selector(true)
end

function Tag:show()
  for i, v in pairs(self.clients) do
    v:move_to_screen(originalscreen.index)
  end
  self.hidden = false
  self.selector(false)
end

function Tag:toggle()
  if self.hidden then self:show() else self:hide() end
end

function Tag:attach(c)
  print("Attaching "..tostring(c).." to tag "..self.name)
  self.clients[c.window] = c
end

function Tag:detach(c)
  print("Detaching "..tostring(c).." from tag "..self.name)
  self.clients[c.window] = nil
end

local TagManager = {}

function TagManager.new(tagnames)
  local faketable = {
    taglist = {},
    selectedtag = nil,
  }
  local buttons = {}
  local self = setmetatable(faketable, { __index = TagManager })
  for i, v in pairs(tagnames) do
    local tagwidget = wibox.widget{
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
      widget = wibox.container.background,
    }
    local selector = function (is_selected)
      if is_selected then
        tagwidget.bg = "#00a000"
      else
        tagwidget.bg = nil
      end
    end
    tagwidget.tag = Tag.new(v, selector)
    tagwidget.id = v
    self.taglist[v] = tagwidget.tag
    local keybinds = awful.util.table.join(
      awful.button({ }, 1, function(t) print("Switching tag to "..t.widget.id) self:view_only(t.widget.id) end),
      awful.button({ modkey }, 1, function(t)
                                print("Mod+1 pressed!")
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
    print("Client ".. tostring(c).." is attached to the tag "..tostring(self.selectedtag))
    if self.selectedtag then self:move_to_tag(c, self.selectedtag) end
  end)
  client.connect_signal("unmanage", function(c)
    print("Client ".. tostring(c).." is detached from all the tags")
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
  self.selectedtag = tagname
  for i, v in pairs(self.taglist) do
    if i == tagname then v:show() else v:hide() end
  end
end

function TagManager:move_to_tag(c, tagname)
  if not self.taglist[tagname] then error("Tag "..tostring(tagname).." does not exists!") end
  if type(c.virtualtags) == "table" then
    -- remove the c from all the tags in the table
    print("Virtualtags is a table!")
    for i, v in pairs(c.virtualtags) do
      print("Trying to detach from "..tostring(v).." of type "..type(v))
      if type(v) == "string" and self.taglist[v] then
        self.taglist[v]:detach(c)
      end
    end
  end
  c.virtualtags = {tagname}
  print("Client moved to tag "..tagname)
  self.taglist[tagname]:attach(c)
  if self.selectedtag ~= tagname then self.taglist[tagname]:hide() end
end

return {
  factory = function(screen)
    local tagman = TagManager.new({"1", "2", "3", "4", "5", "6", "7", "8", "9"})
    return tagman.widget
  end,
  bindings = {},
}
