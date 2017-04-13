local general = require("general")
local awful = require("awful")
local notify = require("naughty").notify

local bindings = {
    -- {modifiers = {}, key = "", command = "", func = function end }
    {{}, "XF86HomePage", general.browser,},
    {{}, "XF86Launch1", "lowriter",},
    {{}, "XF86Launch2", "localc",},
    {{}, "XF86Launch3", "loimpress", },
    --{{}, "XF86Search", os.getenv("FILEMANAGER") or "pcmanfm-qt", },
    {{}, "XF86Mail", general.filemanager, },
    {{}, "Print", "bash -c 'import -window root -frame png:- "..os.getenv("HOME").."/Pictures/$(date +%y-%m-%d_%T).png'", },
  }
local prepared = {}
for k, v in ipairs(bindings)
do
  prepared = awful.util.table.join(prepared,
    awful.key(v[1], v[2], function() awful.util.spawn(v[3]) if v[4] then v[4]() end end, {description = "Start "..v[3]} )
  )
end
root.keys(awful.util.table.join(root.keys(), prepared))
