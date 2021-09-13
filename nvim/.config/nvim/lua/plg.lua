local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn

-- bootstrap packer
local install_path = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim ' ..
                install_path)
    execute 'packadd packer.nvim'
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'norcalli/nvim.lua'

    -- epic telescope navigation
    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }

    -- epic treesitter colors
    use {
        'nvim-treesitter/nvim-treesitter',
        config = require("msc").treesitter,
        run = ':TSUpdate'
    }
    -- Nvim Built in LSP configs
    use {
        "neovim/nvim-lspconfig",
        config = function() require 'plugins.lsp' end
    }

    -- Nvim LSP extensions and completion
    use "nvim-lua/lsp_extensions.nvim"
    use "nvim-lua/completion-nvim"
    use "onsails/lspkind-nvim"

    -- auto cloasing parens
    use "windwp/nvim-autopairs"

    -- commenting out
    use "terrortylor/nvim-comment"

    -- Auto complete stuff
    use "nvim-treesitter/completion-treesitter"

    -- .editorconfig support
    use "editorconfig/editorconfig-vim"


    -- pug highlight
    -- use "digitaltoad/vim-pug"

    -- VISUALS

    -- indent highlights
    use {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufRead",
        setup = require("msc").blankline,
    }

    -- tabbar
    --use {
    --    'akinsho/nvim-bufferline.lua',
    --    config = function() require 'plugins.bufferbar' end,
    --    requires = {'kyazdani42/nvim-web-devicons'}
    --}

    -- statusbar
    use {
        'glepnir/galaxyline.nvim',
        branch = 'main',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    use "nekonako/xresources-nvim"
end)
