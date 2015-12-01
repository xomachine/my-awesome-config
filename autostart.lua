local module = {}
local awful = require("awful")
local utils = require("menubar.utils")

function is_running(ete)
  if not ete then
      return true
  end
  local answer = awful.util.pread("pgrep -c -u" .. os.getenv("USER") .. " -f '" .. ete .. "'")
  if string.sub(answer, 1, 1) == "0" then
    return false
  end
  return true
end

-- Автозапуск
function autostart(dir)
    if not dir then
        do return nil end
    end
    local fd = io.popen("ls -1 -F " .. dir)
    if not fd then
        do return nil end
    end
    for file in fd:lines() do
        local c= string.sub(file,-1)   -- последний символ
        if c=='*' then  -- исполняемые файлы
            executable = string.sub( file, 1,-2 )
            print("Автозапуск Awesome. Запускается: " .. executable)
            local start_cmd = dir .. "/" .. executable .. ""
            if is_running(start_cmd) then
              print(executable .. " is already started!")
            else
              awful.util.spawn_with_shell(start_cmd) -- запуск в фоне
            end
        elseif c=='@' then  -- символические ссылки
            print("Автозапуск Awesome. Симнолические ссылки пропускаются: " .. file)
        elseif c=='p' then
            print("Probably desktop file")
            local length = string.len(file)
            if length > 8 then
              local extention = string.sub(file, -7)
              if extention == "desktop" then
                print("Executing desktop file")
                local dfile = utils.parse(dir .. "/" .. file)
                print(dfile.Exec)
                if is_running(dfile.Exec) then
                  print(file .. " is already started!")
                else
                  awful.util.spawn_with_shell(dfile.Exec)
                end
              end
            end
        else
            print ("Автозапуск Awesome. Игнорируем файл " .. file .. " , т.к. не является исполняемым.")
        end
    end
    io.close(fd)
end

local autostart_dir = os.getenv("HOME") .. "/.config/autostart"

function do_autostart()
  autostart(autostart_dir)
end
module.do_autostart = do_autostart

return module
