local wezterm = require("wezterm");

local function get_xrdb(name)
    local handle = io.popen("xrdb -q | grep '" .. tostring(name) .. "' | awk '{ print $2 }' | tr -d '\n'")
    return handle:read("*a")
end

local function get_color(num)
    return get_xrdb("color" .. tostring(num) .. ":")
end

local c = {
    fg = get_xrdb("foreground"),
    bg = get_xrdb("background"),
    black = get_color(0),
    red = get_color(1),
    green = get_color(2),
    yellow = get_color(3),
    blue = get_color(4),
    magenta = get_color(5),
    cyan = get_color(6),
    white = get_color(7),
    gray = get_color(8),
    redB = get_color(9),
    greenB = get_color(10),
    yellowB = get_color(11),
    blueB = get_color(12),
    magentaB = get_color(13),
    cyanB = get_color(14),
    whiteB = get_color(15),
}

return {
    font = wezterm.font("JetBrainsMono NF"),
    font_size = 9.0,
    line_height = 1.0,
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    scrollback_lines = 3500,
    enable_scroll_bar = false,

    -- keys
    disable_default_key_bindings = true,
    keys = {
        {key="t", mods="CTRL", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
        {key="w", mods="CTRL", action=wezterm.action{CloseCurrentTab={confirm=false}}},
        {key="PageUp", mods="CTRL", action=wezterm.action{MoveTabRelative=-1}},
        {key="PageDown", mods="CTRL", action=wezterm.action{MoveTabRelative=1}},
    },

    -- padding
    window_padding = {
        left = 12,
        right = 12,
        top = 8,
        bottom = 8,
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
        ansi = {c.black, c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, c.white},
        brights = {c.gray, c.redB, c.greenB, c.yellowB, c.blueB, c.magentaB, c.cyanB, c.whiteB},
        
        tab_bar = {
            background = c.bg,
            active_tab = {
                bg_color = c.black,
                fg_color = c.cyan,
                intensity = "Normal",
                underline = "None",
                italic = false,
                strikethrough = false,
            },
            inactive_tab = {
                bg_color = c.bg,
                fg_color = c.fg,
            },
            inactive_tab_hover = {
                bg_color = c.bg,
                fg_color = c.fg,
                italic = true,
            },
        },
    },
}
