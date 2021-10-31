local vim = vim
local M = {}

-- Some setups
--require('nvim-autopairs').setup()
--require('nvim_comment').setup()

M.colors = function()
    local base16 = require("base16")
    local colors = require("colors")
    local theme_array = {
    	colors.base00, colors.base01, colors.base02, colors.base03,
    	colors.base04, colors.base05, colors.base06, colors.base07,
    	colors.base08, colors.base09, colors.base0A, colors.base0B,
    	colors.base0C, colors.base0D, colors.base0E, colors.base0F,
    }
    for idx, v in ipairs(theme_array) do -- remove all #
        theme_array[idx] = v:sub(2)
    end
    local theme = base16.theme_from_array(theme_array)
    base16(theme, true)
end

-- Indent highlights
M.blankline = function()
        vim.g.indentLine_enabled = 1
        vim.g.indent_blankline_chat = "▏"

        vim.g.indent_blankline_filetype_exclude = {"help", "terminal", "dashboard"}
        vim.g.indent_blankline_buftype_exclude = {"terminal"}

        vim.g.indent_blankline_show_trailing_blankline_indent = false
        vim.g.indent_blankline_show_first_indent_level = false
end

-- Treesitter
M.treesitter = function()
    require('nvim-treesitter.configs').setup {
        ensure_installed = {
            "javascript", "html", "java", "c", "cpp", "bash", "rust", "lua"
        },
        highlight = {enable = true, use_languagetree = true},
    }
end

M.lspkind = function()
    -- LSP kind (makes lsp completion tool nicer)
    require('lspkind').init {
        with_text = true,
    
        preset = 'codicons',
    
        symbol_map = {
          Text = '',
          Method = 'ƒ',
          Function = '',
          Constructor = '',
          Variable = '',
          Class = '',
          Interface = 'ﰮ',
          Module = '',
          Property = '',
          Unit = '',
          Value = '',
          Enum = '了',
          Keyword = '',
          Snippet = '﬌',
          Color = '',
          File = '',
          Folder = '',
          EnumMember = '',
          Constant = '',
          Struct = ''
        },
    }
end

return M
