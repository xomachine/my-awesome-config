local awful = require("awful")

return function(screen)
  screen.prompt = awful.widget.prompt({prompt = "Запуск: "})
  return screen.prompt
end

