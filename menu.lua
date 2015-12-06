local module = {}
local awful = require("awful")
local beautiful = require("beautiful")
local menugen = require("menubar.menu_gen")
local mutil = require("menubar.utils")
local notify = require("naughty").notify

module.create_launcher = function()
  --local terminal = "termite"
  local desktops = mutil.parse_dir("/usr/share/applications")
  local maincategories = {AudioVideo = {"Мультимедиа", {}},
                          Audio = {"Звук", {}},
                          Video = {"Видео", {}},
                          Developement = {"Разработка", {}},
                          Education = {"Образование", {}},
                          Game = {"Игры", {}},
                          Graphics = {"Графика", {}},
                          Network = {"Интернет", {}},
                          Office = {"Офис", {}},
                          Science = {"Наука", {}},
                          Settings = {"Настройки", {}},
                          System = {"Система", {}},
                          Utility = {"Утилиты", {}},
                          Others = {"Другие", {}}
                  }

  appmenu = {} --menugen.generate()
  for i, desktop in ipairs(desktops) do
    local category = "Others"
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
      exec = "sh -c \"cd '"..dir.."'; "..desktop.Exec.."\""
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
    --notify({text = appname..": ".. exec, timeout = 0})
    table.insert(maincategories[category][2], {appname, exec, icon})
    ::continue::
  end
  for i, submenu in pairs(maincategories) do
    table.insert(appmenu, submenu)
  end
  myawesomemenu = {
     { "Помощь", terminal .. " -e man awesome" },
     { "Конфигурация", "gvim " .. awesome.conffile },
     { "Перезапуск", awesome.restart },
     { "Выйти", awesome.quit }
  }
  -- Favorites menu
  favoritesmenu = {
     { "Обозреватель", "firefox" },
     { "Терминал", terminal },
     { "Файлы", "pcmanfm" }
  }
  systemmenu = {
     { "Перезагрузка", "reboot" },
     { "Выключение", "shutdown -h now" },
  }

  mymainmenu = awful.menu({ items = { { "Избранное", favoritesmenu },
                                      { "Applications", appmenu },
                                      { "awesome", myawesomemenu, beautiful.awesome_icon },
                                      { "Система", systemmenu },
                                    }
                          })

  mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                       menu = mymainmenu })
  return mylauncher
end

return module
