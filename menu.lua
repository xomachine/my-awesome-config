local awful = require("awful")
local beautiful = require("beautiful")
local menugen = require("menubar.menu_gen")
local mutil = require("menubar.utils")
local notify = require("naughty").notify
local general = require("general")
local hotkeys_popup = require("awful.hotkeys_popup").widget


  --local appmenu = generate_appmenu()--menugen.generate()
local myawesomemenu = {
   { "Горячие клавиши", function() return false, hotkeys_popup.show_help end},
   { "Помощь", general.terminal .. " -e man awesome" },
   { "Конфигурация", general.editor_cmd .. " " .. awesome.conffile  },
   { "Проверка", general.terminal .. " -e \"bash -c 'Xephyr :1 2>/dev/null & sleep 1s; DISPLAY=:1 awesome;'\""},
   { "Перезапуск", awesome.restart },
   { "Выйти", function() awesome.quit() end}
}
-- Favorites menu
local favoritesmenu = {
   { "Обозреватель", general.browser },
   { "Терминал", general.terminal },
   { "Файлы", general.filemanager }
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


