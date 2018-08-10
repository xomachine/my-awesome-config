local module = {}

module.modkey = "Mod4"
module.terminal = os.getenv("TERMINAL") or "lxterminal"
module.editor = os.getenv("EDITOR") or "nano"
module.editor_cmd = os.getenv("VISUAL") or module.terminal .. " -e " .. module.editor
module.browser = os.getenv("BROWSER") or "firefox"
module.filemanager = os.getenv("FILEMANAGER") or "pcmanfm-qt"


return module
