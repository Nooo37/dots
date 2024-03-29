local wezterm = require("wezterm");
local farbig = require("farbig")

local f = io.open(os.getenv("HOME") .. "/.colorscheme", "rb")
local scheme = f:read("a*")
f:close()
scheme = scheme:gsub("%s+", "")
local colors = farbig.get(scheme)

local c = {
    fg = colors.base05,
    bg = colors.base00,
    black = colors.base01,
    red = colors.base08,
    green = colors.base0B,
    yellow = colors.base0A,
    blue = colors.base0D,
    magenta = colors.base09,
    cyan = colors.base0C,
    white = colors.base04,
    gray = colors.base03,
}

local cpd = "CurrentPaneDomain"
local spawn_tab = wezterm.action{SpawnTab=cpd}
local close_tab = wezterm.action{CloseCurrentTab={confirm=true}}
local prev_tab = wezterm.action{ActivateTabRelative=-1}
local next_tab = wezterm.action{ActivateTabRelative=1}
local scroll_up = wezterm.action{ScrollByLine=-1}
local scroll_down = wezterm.action{ScrollByLine=1}
local split_horizontal = wezterm.action{SplitHorizontal={domain=cpd}}
local split_vertical = wezterm.action{SplitVertical={domain=cpd}}
local close_pane = wezterm.action{CloseCurrentPane={confirm=true}}
local pane_left = wezterm.action{ActivatePaneDirection="Left"}
local pane_right = wezterm.action{ActivatePaneDirection="Right"}
local pane_up = wezterm.action{ActivatePaneDirection="Up"}
local pane_down = wezterm.action{ActivatePaneDirection="Down"}
local copy = wezterm.action{CopyTo="Clipboard"}
local paste = wezterm.action{PasteFrom="Clipboard"}

local my_keys = {
    -- browser like tabbing
    { "t",         "CTRL|SHIFT", spawn_tab },
    { "w",         "CTRL|SHIFT", close_tab },
    { "PageUp",    "CTRL|SHIFT", prev_tab },
    { "PageDown",  "CTRL|SHIFT", next_tab },
    -- scrolling
    { "UpArrow",   "CTRL|SHIFT", scroll_up },
    { "DownArrow", "CTRL|SHIFT", scroll_down },
    -- multiplexing
    { "g",         "CTRL|SHIFT", split_horizontal },
    { "f",         "CTRL|SHIFT", split_vertical },
    { "x",         "CTRL|SHIFT", close_pane },
    { "h",         "CTRL|SHIFT", pane_left },
    { "l",         "CTRL|SHIFT", pane_right },
    { "k",         "CTRL|SHIFT", pane_up },
    { "j",         "CTRL|SHIFT", pane_down },
    { "Tab",       "CTRL|SHIFT", next_tab },
    -- standard copy/paste
    { "c",         "CTRL|SHIFT", copy },
    { "v",         "CTRL|SHIFT", paste },
    { "Insert",    "SHIFT",      paste },
    -- font size
    { "m",         "CTRL|SHIFT",     "IncreaseFontSize" },
    { "n",         "CTRL|SHIFT",     "DecreaseFontSize" },
    -- copymode
    { "x",         "CTRL",           "ActivateCopyMode" },
    -- reload config
    { "r",         "CTRL|SHIFT",     "ReloadConfiguration" },
}

local keys = {}
for _, my_key in ipairs(my_keys) do
    table.insert(keys, {
        key = my_key[1],
        mods = my_key[2],
        action = my_key[3]
    })
end

-- browser like eg ctrl-3 for focusing the third tab
for i = 1, 8 do
    table.insert(keys, {
        key = tostring(i),
        mods = "CTRL",
        action = wezterm.action { ActivateTab=(i-1) },
    })
end

return {
    -- fonts
    font = wezterm.font("JetBrainsMono Nerd Font"),
    font_size = 9.0,
    line_height = 1.0,
    -- gui
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    enable_scroll_bar = false,
    inactive_pane_hsb = {
        hue = 1.0,
        saturation = 1.0,
        brightness = 1.0
    },
    -- other
    enable_wayland = true,
    scrollback_lines = 3500,
    cursor_blink_rate = 800,
    default_cursor_style = "SteadyUnderline",
    check_for_updates = false,
    -- keys
    keys = keys,
    disable_default_key_bindings = true,

    -- padding
    window_padding = {
        left = 14,
        right = 14,
        top = 14,
        bottom = 14,
    },

    -- colors
    colors = {
        foreground = c.fg,
        background = c.bg,
        cursor_bg = c.cyan,
        cursor_fg = c.bg,
        cursor_border = c.cyan,
        scrollbar_thumb = c.blue,
        split = c.blue,
        ansi = {
            c.black,
            c.red,
            c.green,
            c.yellow,
            c.blue,
            c.magenta,
            c.cyan,
            c.white
        },
        brights = {
            c.gray,
            c.red,
            c.green,
            c.yellow,
            c.blue,
            c.magenta,
            c.cyan,
            c.white
        },
        tab_bar = {
            background = c.black,
            active_tab = {
                bg_color = c.black,
                fg_color = c.cyan,
                intensity = "Normal",
                underline = "None",
                italic = false,
                strikethrough = false,
            },
            inactive_tab = {
                bg_color = c.black,
                fg_color = c.fg,
            },
            inactive_tab_hover = {
                bg_color = c.black,
                fg_color = c.green,
                italic = true,
            },
            new_tab = {
                bg_color = c.black,
                fg_color = c.fg,
            },
            new_tab_hover = {
                bg_color = c.green,
                fg_color = c.bg,
                italic = true,
            },
        },
    },
}
