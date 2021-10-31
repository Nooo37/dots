local farbig = require('farbig')
farbig.set_names({
    "bg",
    "black",
    "bg0",
    "gray",
    "fg2",
    "fg",
    "fg3",
    "bg3",
    "red",
    "orange",
    "yellow",
    "green",
    "cyan",
    "blue",
    "purple",
    "brown"
})
local io = require("io")
local os = require("os")
local f = io.open(os.getenv("HOME") .. "/.colorscheme", "rb")
local scheme = f:read("a*")
f:close()
scheme = scheme:gsub("%s+", "")
local colors = farbig.get(scheme or "amarena")
--vim.api.nvim_echo({{tostring(os.getenv('HOME')), 'None'}, {'', 'None'}}, false, {})

return colors
