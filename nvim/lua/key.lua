local lsp_opts = {noremap = true, silent = true}

local mappings = {
   -- General
   { "n", "<C-s>", [[:w <CR>]],          nil }, -- save on C-s, why not
   { "n", "<C-f>", [[/]],                nil }, -- search on C-f, why not
   { "",  "<C-m>", [[:CommentToggle<CR>]], nil},  -- Commenter Keybinding
   { "",  "j",     [[v:count ? "j" : "gj"]], {expr = true}}, -- Move wrapped lines normally
   { "",  "k",     [[v:count ? "k" : "gk"]], {expr = true}}, -- Move wrapped lines normally
   { "n", "<Esc>", [[:noh<CR>]], nil}, -- use ESC in normal to turn off highlights

   -- LSP
   { "n", "<Leader>r",    [[:lua vim.lsp.buf.rename()<CR>]], lsp_opts},
   { "n", "<Leader>d",    [[:lua vim.lsp.buf.definition()<CR>]], lsp_opts},
   { "n", "<Leader>h",    [[:lua vim.lsp.buf.hover()<CR>]], lsp_opts},
   { "n", "<Leader>c",    [[:lua vim.lsp.buf.code_action()<CR>]], lsp_opts},

   -- Telescope
   { "n", "<Leader>f",    [[:Telescope find_files<CR>]], nil},
   { "n", "<Leader>b",    [[:Telescope buffers<CR>]], nil},
   { "n", "<Leader>g",    [[:Telescope live_grep<CR>]], nil},
}

for _, map in ipairs(mappings) do
    local opts = map[4] or { silent = true }
    vim.api.nvim_set_keymap(map[1], map[2], map[3], opts)
end
