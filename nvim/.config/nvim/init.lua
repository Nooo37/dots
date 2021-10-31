local modules = {
    "key", -- keybindings
    "opt", -- nvim options
    "plg", -- plugins
    "bar", -- statusbar config
    "lsp", -- lsp config
    "msc", -- other plugin config
}

for i = 1, #modules, 1 do
    pcall(require, modules[i])
end

require("msc").colors()
