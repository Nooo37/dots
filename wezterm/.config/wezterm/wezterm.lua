local wezterm = require("wezterm");
local c = require("color")

local keys = {
        -- browser like tabbing
        { key="t", mods="CTRL", action=wezterm.action{SpawnTab="CurrentPaneDomain"} },
        { key="w", mods="CTRL", action=wezterm.action{CloseCurrentTab={confirm=true}} },
        { key="PageUp", mods="CTRL|SHIFT", action=wezterm.action{MoveTabRelative=-1} },
        { key="PageDown", mods="CTRL|SHIFT", action=wezterm.action{MoveTabRelative=1} },
        { key="PageUp", mods="CTRL", action=wezterm.action{ActivateTabRelative=-1} },
        { key="PageDown", mods="CTRL", action=wezterm.action{ActivateTabRelative=1} },
        -- scrolling
        { key="UpArrow", mods="CTRL|SHIFT", action=wezterm.action{ScrollByLine=-1} },
        { key="DownArrow", mods="CTRL|SHIFT", action=wezterm.action{ScrollByLine=1} },
        -- multiplexing
        { key="g", mods="CTRL|SHIFT", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}} },
        { key="f", mods="CTRL|SHIFT", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}} },
        --{ key="x", mods="CTRL|SHIFT", action=wezterm.action{CloseCurrentPane={confirm=true}} },
        { key="h", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Left"} },
        { key="l", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Right"} },
        { key="k", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Up"} },
        { key="j", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Down"} },
        { key="Tab", mods="CTRL|SHIFT", action=wezterm.action{ActivateTabRelative=1} },
        -- standard copy/paste
        { key="c", mods="CTRL|SHIFT", action=wezterm.action{CopyTo="Clipboard"} },
        { key="v", mods="CTRL|SHIFT", action=wezterm.action{PasteFrom="Clipboard"} },
        { key="Insert", mods="SHIFT", action=wezterm.action{PasteFrom="Clipboard"} },
        -- font size
        { key="+", mods="CTRL", action="IncreaseFontSize" },
        { key="-", mods="CTRL", action="DecreaseFontSize" },
        -- copymode
        { key="x", mods="CTRL", action="ActivateCopyMode" },
}

-- browser like eg ctrl-3 for focusing the third tab
for i = 1, 8 do
    table.insert(keys, {
        key = tostring(i),
        mods = "CTRL",
        action = wezterm.action { ActivateTab=(i-1) },
    })
end

return {
    font = wezterm.font("JetBrainsMono NF"),
    font_size = 9.0,
    line_height = 1.0,
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    scrollback_lines = 3500,
    enable_scroll_bar = false,
    default_cursor_style = "SteadyUnderline",
    check_for_updates = false,
    inactive_pane_hsb = { hue = 1.0, saturation = 1.0, brightness = 1.0 },

    -- keys
    keys = keys,
    disable_default_key_bindings = true,

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
        ansi =    {c.black, c.red,  c.green,  c.yellow,  c.blue,  c.magenta,  c.cyan,  c.white},
        brights = {c.gray,  c.redB, c.greenB, c.yellowB, c.blueB, c.magentaB, c.cyanB, c.whiteB},

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
                bg_color = c.bg,
                fg_color = c.fg,
                italic = true,
            },
        },
    },
}
