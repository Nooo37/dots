local vim = vim
local gl = require('galaxyline')
local gls = gl.section
local condition = require('galaxyline.condition')
gl.short_line_list = {'NvimTree', 'vista', 'dbui', 'packer'}

local colors = require("colors")
--colors.bg = "#00000000"

local mode_color = {
    n = colors.cyan,
    i = colors.red,
    v = colors.blue,
    V = colors.blue,
    c = colors.red,
    no = colors.magenta,
    s = colors.orange,
    ic = colors.yellow,
    R = colors.violet,
    Rv = colors.violet,
    cv = colors.red,
    ce = colors.red,
    r = colors.cyan,
    rm = colors.cyan,
    ['r?'] = colors.cyan,
    ['!'] = colors.red,
    t = colors.red
}

local function lsp_status(status)
    local shorter_stat = ''
    for match in string.gmatch(status, "[^%s]+") do
        local err_warn = string.find(match, "^[WE]%d+", 0)
        if not err_warn then shorter_stat = shorter_stat .. ' ' .. match end
    end
    return shorter_stat
end

local buffer_not_empty = function()
    if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then return true end
    return false
end

gls.left[1] = {
    ViMode = {
        provider = function()
            -- auto change color according the vim mode
	    if mode_color[vim.fn.mode()] then
            vim.api.nvim_command('hi GalaxyViMode guifg=' ..
                                     mode_color[vim.fn.mode()])
			     end
            return '  ⬤ '
        end,
        separator = '  ',
        separator_highlight = {colors.bg, colors.bg},
        highlight = {colors.fg, colors.bg, 'bold'}
    }
}

gls.left[2] = {
    FileIcon = {
        provider = 'FileIcon',
        condition = buffer_not_empty,
        separator = ' ',
        separator_highlight = {colors.bg, colors.bg},
        highlight = {
            require('galaxyline.provider_fileinfo').get_file_icon_color,
            colors.bg
        }
    }
}

gls.left[3] = {
    FileName = {
        provider = {'FileName'},
        condition = buffer_not_empty,
        separator = '  ',
        separator_highlight = {colors.bg, colors.bg},
        highlight = {colors.fg, colors.bg, 'bold'}
    }
}

gls.left[4] = {
    FirstElement = {
        provider = function()
            return "⦁"
        end,
        separator = '  ',
        separator_highlight = {colors.bg, colors.bg},
        highlight = {colors.green, colors.bg}
    }
}

gls.left[5] = {
    lsp_status = {
        provider = function()
            local clients = vim.lsp.get_active_clients()
            if next(clients) ~= nil then
                local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                for _, client in ipairs(clients) do
                    local filetypes = client.config.filetypes
                    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                        return " LSP  "
                    end
                end
                return ""
            else
                return ""
            end
        end,
        highlight = {colors.gray, colors.bg}
    }
}

gls.left[7] = {
    DiagnosticError = {
        provider = 'DiagnosticError',
        icon = '  ',
        highlight = {colors.red, colors.bg}
    }
}

gls.left[8] = {
    DiagnosticWarn = {
        provider = 'DiagnosticWarn',
        icon = '   ',
        highlight = {colors.yellow, colors.bg}
    }
}

gls.left[9] = {
    DiagnosticHint = {
        provider = 'DiagnosticHint',
        icon = '   ',
        highlight = {colors.cyan, colors.bg}
    }
}

gls.left[10] = {
    DiagnosticInfo = {
        provider = 'DiagnosticInfo',
        icon = '  ',
        highlight = {colors.blue, colors.bg}
    }
}

gls.right[1] = {
    PerCent = {
        provider = 'LinePercent',
        separator = ' ',
        separator_highlight = {'NONE', colors.bg},
        highlight = {colors.fg, colors.bg, 'bold'}
    }
}

gls.right[2] = {
    RainbowBlue = {
        provider = function() return '⦁' end,
        separator = ' ',
        separator_highlight = {'NONE', colors.bg},
        highlight = {colors.green, colors.bg}
    }
}

gls.right[3] = {
    LineInfo = {
        provider = 'LineColumn',
        separator = ' ',
        separator_highlight = {'NONE', colors.bg},
        highlight = {colors.yellow, colors.bg}
    }
}

gls.right[4] = {
    RainbowBlue = {
        provider = function() return '⦁' end,
        separator = ' ',
        separator_highlight = {'NONE', colors.bg},
        highlight = {colors.green, colors.bg}
    }
}

gls.right[5] = {
    GitBranch = {
        provider = 'GitBranch',
        separator = '  ',
        separator_highlight = {'NONE', colors.bg},
        condition = require('galaxyline.provider_vcs').check_git_workspace,
        highlight = {colors.gray, colors.bg, 'bold'}
    }
}

local checkwidth = function()
    local squeeze_width = vim.fn.winwidth(0) / 2
    if squeeze_width > 40 then return true end
    return false
end

gls.right[6] = {
    DiffAdd = {
        provider = 'DiffAdd',
        condition = checkwidth,
        icon = '  ',
        highlight = {colors.green, colors.bg}
    }
}
gls.right[7] = {
    DiffModified = {
        provider = 'DiffModified',
        condition = checkwidth,
        icon = ' | ',
        highlight = {colors.orange, colors.bg}
    }
}
gls.right[8] = {
    DiffRemove = {
        provider = 'DiffRemove',
        condition = checkwidth,
        icon = '  ',
        highlight = {colors.red, colors.bg}
    }
}

