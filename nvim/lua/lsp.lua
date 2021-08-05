local vim = vim
local nvim_lsp = require 'lspconfig'

-- function to attach completion when setting up lsp
local on_attach = function(client, _)
    if client.resolved_capabilities.document_highlight then
        require('completion').on_attach()
        vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg='#8ec07c' guifg='#282828'
      hi LspReferenceText cterm=bold ctermbg=red guibg='#8ec07c'  guifg='#282828'
      hi LspReferenceWrite cterm=bold ctermbg=red guibg='#8ec07c' guifg='#282828'
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
    end
end

nvim_lsp.tsserver.setup {on_attach = on_attach}
nvim_lsp.clangd.setup {on_attach = on_attach}
nvim_lsp.vimls.setup {on_attach = on_attach}
nvim_lsp.bashls.setup {on_attach = on_attach}
nvim_lsp.rust_analyzer.setup {on_attach = on_attach}
nvim_lsp.sumneko_lua.setup({
  on_attach = on_attach,
  filetypes = {'lua', 'lua.luapad', 'luapad'},
  cmd = {
      "/usr/bin/lua-language-server",
      "-E",
      "/usr/share/lua-language-server/main.lua"
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ';'), },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true, -- add as many lib you want
          },
        }
      }
    }
})

-- Enable diagnostics vim.lsp.handlers["textDocument/publishDiagnostics"] =
vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
             {virtual_text = true, signs = true, update_in_insert = true})
