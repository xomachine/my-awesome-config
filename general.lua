local module = {}

module.modkey = "Mod4"
module.terminal = "lxterminal"
module.editor = os.getenv("EDITOR") or "nano"
module.editor_cmd = module.terminal .. " -e " .. module.editor


return module
