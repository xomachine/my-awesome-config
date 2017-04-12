local lfs = require("lfs")
local awful = require("awful")
local beautiful = require("beautiful")
local menugen = require("menubar.menu_gen")
local mutil = require("menubar.utils")
local notify = require("naughty").notify
local general = require("general")
local terminal = general.terminal
local editor_cmd = general.editor_cmd
local hotkeys_popup = require("awful.hotkeys_popup").widget

function dump(q, n)
  for k,v in pairs(q) do
    if type(v) == "table" then
      dump(v, k)
    else
      --notify({text = (n and tostring(n)..":" or "")..tostring(k).." = "..tostring(v)})
      print((n and tostring(n)..":" or "")..tostring(k).." = "..tostring(v))
    end
  end
end

local parse_ini = function(inifile)
  local parsed = {}
  local current_top = ""
  for line in io.lines(inifile) do
    local top_entry = line:match('^%[([^%]]+)%]')
    local key, val = line:match("([^=]+)=(.*)")
    if top_entry then
      current_top = top_entry
    elseif key then
      if parsed[current_top] == nil then
        parsed[current_top] = {}
      end
      parsed[current_top][key] = val
    end
  end
  return parsed
end

local parse_categories = function(cat_dir)
  local categories = {}
  local locale = os.getenv("LANG")
  for file in lfs.dir(cat_dir) do
    if file:match('^.+directory$') then
      local category = parse_ini(cat_dir.."/"..file)
      if category["Desktop Entry"] ~= nil then
        category = category["Desktop Entry"]
        local category_name = category["Name["..locale.."]"] or category["Name["..locale:sub(1,2).."]"] or category["Name"]
        local category_icon_name = category["Icon"] or nil
        local category_icon = mutil.lookup_icon(category_icon_name)
        if category_name then
          categories[category.Name] = {category_name, {}, category_icon}
        end
      end
    end
  end
  return categories
end

local generate_appmenu = function()
  local maincategories = parse_categories("/usr/share/desktop-directories")
  local desktops = mutil.parse_dir("/usr/share/applications")
  local appmenu = {} --menugen.generate()
  for i, desktop in ipairs(desktops) do
    local category = "Other"
    local appname = "Noname"
    local exec = ""
    local icon = nil
    local dir = "."
    if desktop.Hidden == true or desktop.NoDisplay == true then
      goto continue
    end
    if desktop.Path then
      dir = desktop.Path
    end

    if desktop.Exec then
      exec = "sh -c \"cd '"..dir.."'; "..desktop.Exec:gsub('%%%a','').."\""
    end
    if desktop.Terminal == true then
      exec = terminal.." -e "..exec
    end
    if desktop.Icon then
      icon = mutil.lookup_icon(desktop.Icon)
    end
    if desktop.categories then
      for k, v in pairs(desktop.categories) do
        if maincategories[v] then
          category = v
        end
      end
    end
    if desktop.Name then
      appname = desktop.Name
    elseif desktop.GenericName then
      appname = desktop.GenericName
    end
    if maincategories[category] == nil then
      category = "Other"
    end
    table.insert(maincategories[category][2], {appname, exec, icon})
    ::continue::
  end
  for i, submenu in pairs(maincategories) do
    if #submenu[2] > 0 then
      table.insert(appmenu, submenu)
    end
  end
  return appmenu
end


  --local appmenu = generate_appmenu()--menugen.generate()
local myawesomemenu = {
   { "Горячие клавиши", function() return false, hotkeys_popup.show_help end},
   { "Помощь", terminal .. " -e man awesome" },
   { "Конфигурация", editor_cmd .. " " .. awesome.conffile  },
   { "Проверка", terminal .. " -e bash -c 'Xephyr :1 & sleep 1s; DISPLAY=:1 awesome;'"},
   { "Перезапуск", awesome.restart },
   { "Выйти", awesome.quit }
}
-- Favorites menu
local favoritesmenu = {
   { "Обозреватель", "firefox" },
   { "Терминал", terminal },
   { "Файлы", "pcmanfm" }
}
local systemmenu = {
   { "Перезагрузка", "reboot" },
   { "Выключение", "shutdown -h now" },
}

local mymainmenu = awful.menu({ items = { { "Избранное", favoritesmenu },
                                    { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Система", systemmenu },
                                  }
                        })

return mymainmenu


