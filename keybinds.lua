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
    {{general.modkey, "Shift"}, "z", "sh '"..os.getenv("HOME").."/.Soft/switch_input.sh'", [5]="Switch input to another screen" },
    {{}, "Print", "bash -c 'import -window root -frame png:- "..os.getenv("HOME").."/Pictures/$(date +%y-%m-%d_%T).png'", [5] = "Make a screenshot"},
  }
local prepared = {}
for k, v in ipairs(bindings)
do
  prepared = awful.util.table.join(prepared,
    awful.key(v[1], v[2], function() awful.util.spawn(v[3]) if v[4] then v[4]() end end, {description = v[5] or "Start "..v[3]} )
  )
end

return prepared
