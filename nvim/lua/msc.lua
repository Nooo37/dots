local vim = vim
local M = {}

-- Some setups
require('nvim-autopairs').setup()
require('nvim_comment').setup()

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
require('nvim-treesitter.configs').setup {
    ensure_installed = {
        "javascript", "html", "java", "c", "cpp", "bash", "rust", "lua"
    },
    highlight = {enable = true, use_languagetree = true},
}

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

return M
