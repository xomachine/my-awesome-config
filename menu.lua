local module = {}
local awful = require("awful")
local beautiful = require("beautiful")
-- local menugen = require("menubar.menu_gen")

function create_launcher()
  --local terminal = "termite"
  myawesomemenu = {
     { "manual", terminal .. " -e man awesome" },
     { "edit config", "aporia " .. awesome.conffile },
     { "restart", awesome.restart },
     { "quit", awesome.quit }
  }
  -- Favorites menu
  favoritesmenu = {
     { "browser", "luakit" },
     { "terminal", terminal },
     { "filemanager", "pcmanfm" }
  }

  mymainmenu = awful.menu({ items = { { "Favorites", favoritesmenu },
                                      { "awesome", myawesomemenu, beautiful.awesome_icon },
                                      { "open terminal", terminal }
                                    }
                          })

  mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                       menu = mymainmenu })
  return mylauncher
end

module.create_launcher = create_launcher
return module
