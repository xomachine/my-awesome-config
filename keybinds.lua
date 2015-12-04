
local awful = require("awful")
local notify = require("naughty").notify

local bindings = {
    -- {modifiers = {}, key = "", command = "", func = function end }
    {{}, "XF86AudioMute", "amixer set Master toggle",
      function()
        notify({text = "Sound: " ..
          awful.util.pread(
            "amixer get Master | grep -o '\\[[a-z]\\{2,3\\}\\]'"
          )
        })
      end
    },
    {{}, "XF86AudioPrev", "amixer set Master 2-",
      function()
        notify({text = "Sound: " ..
          awful.util.pread(
            "amixer get Master | grep -o '\\[[0-9]\\{2,3\\}%\\]'"
          )
        })
      end
    },
    {{}, "XF86AudioNext", "amixer set Master 2+",
      function()
        notify({text = "Sound: " ..
          awful.util.pread(
            "amixer get Master | grep -o '\\[[0-9]\\{2,3\\}%\\]'"
          )
        })
      end
    },
    {{}, "XF86HomePage", "luakit",},
    {{}, "XF86Launch1", "lowriter",},
    {{}, "XF86Launch2", "localc",},
    {{}, "XF86Launch3", "loimpress", },
  }
local prepared = {}
for k, v in ipairs(bindings)
do
  prepared = awful.util.table.join(prepared,
    awful.key(v[1], v[2], function() awful.util.spawn(v[3]) if v[4] then v[4]() end end )
  )
end
root.keys(awful.util.table.join(root.keys(), prepared))
