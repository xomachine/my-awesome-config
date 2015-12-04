local module = {}
local awful = require("awful")
local beautiful = require("beautiful")
-- local menugen = require("menubar.menu_gen")

function create_launcher()
  --local terminal = "termite"
  myawesomemenu = {
     { "Помощь", terminal .. " -e man awesome" },
     { "Редактировать конфигурацию", "gvim " .. awesome.conffile },
     { "Перезапуск awesome", awesome.restart },
     { "Выйти", awesome.quit }
  }
  -- Favorites menu
  favoritesmenu = {
     { "Обозреватель", "firefox" },
     { "Терминал", terminal },
     { "Файловый менеджер", "pcmanfm" }
  }
  systemmenu = {
     { "Перезагрузка", "reboot" },
     { "Выключение", "shutdown -h now" },
  }

  mymainmenu = awful.menu({ items = { { "Избранное", favoritesmenu },
                                      { "awesome", myawesomemenu, beautiful.awesome_icon },
                                      { "Система", systemmenu },
                                      { "Открыть терминал", terminal }
                                    }
                          })

  mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                       menu = mymainmenu })
  return mylauncher
end

module.create_launcher = create_launcher
return module
