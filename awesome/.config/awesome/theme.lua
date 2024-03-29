-- theme

local gears = require("gears")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local naughty = require("naughty")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()

local helpers = require("helpers") -- only for notification appearance
local farbig = require("module.farbig")

local home_path = os.getenv("HOME")
local config_path = home_path .. "/.config/awesome/"

-- inherent from default file (only for the icons)
local theme = dofile("/usr/share/awesome/themes/default/theme.lua")

local handle = io.popen("cat /sys/class/dmi/id/chassis_type")

theme.is_on_pc = tonumber(handle:read("*a")) == 3 -- 3 is for desktop PCs

local function read_colorscheme()
    local io = require("io")
    local os = require("os")
    local f = io.open(os.getenv("HOME") .. "/.colorscheme", "rb")
    local colorscheme = f:read("a*")
    f:close()
    colorscheme = colorscheme:gsub("%s+", "")
    return colorscheme
end

theme.weather_city = "Regensburg"
theme.config_path = config_path
theme.wallpaper = home_path .."/pics/wallpapers/night-blue.png"

theme.corner_radius = dpi(8) --14   8
theme.border_radius = dpi(6) --14   8
theme.font          = "sans 8"

-- Variables set for theming the menu:
theme.menu_submenu_icon = config_path.."default/submenu.png" --TODO wtf
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    5, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

theme.font          = "sans 8"
theme.colorscheme   = read_colorscheme() or "gruvbox-dark-hard"
local colors = farbig.get(theme.colorscheme)


-- colors
theme.xfg                    = colors.base05 or xrdb.foreground or "#FFFFFF"
theme.xbg                    = colors.base00 or xrdb.background or "#1A2026"
-- theme.xbgdark                = colors.base00 or xrdb.bgdark  or "#aa1010"---"#14181d"
-- theme.xbglight               = colors.base00 or xrdb.bglight or "#526170"
theme.xcolor0                = colors.base01 or xrdb.color0  or "#242D35"
theme.xcolor8                = colors.base03 or xrdb.color8  or "#526170"
theme.xcolor1                = colors.base08 or xrdb.color1  or "#FB6396"
theme.xcolor9                = colors.base08 or xrdb.color9  or "#F92D72"
theme.xcolor2                = colors.base09 or xrdb.color2  or "#94CF95"
theme.xcolor10               = colors.base09 or xrdb.color10 or "#6CCB6E"
theme.xcolor3                = colors.base0A or xrdb.color3  or "#F692B2"
theme.xcolor11               = colors.base0A or xrdb.color11 or "#F26190"
theme.xcolor4                = colors.base0B or xrdb.color4  or "#6EC1D6"
theme.xcolor12               = colors.base0B or xrdb.color12 or "#4CB9D6"
theme.xcolor5                = colors.base0C or xrdb.color5  or "#CD84C8"
theme.xcolor13               = colors.base0C or xrdb.color13 or "#C269BC"
theme.xcolor6                = colors.base0E or xrdb.color6  or "#7FE4D2"
theme.xcolor14               = colors.base0E or xrdb.color14 or "#58D6BF"
theme.xcolor7                = colors.base05 or xrdb.color7  or "#CFCFCF"
theme.xcolor15               = colors.base05 or xrdb.color15 or "#F4F5F2"

theme.xbg2                   = colors.base01 --"#00000044"

theme.bg_normal              = theme.xbg
theme.bg_focus               = theme.xcolor0
theme.bg_urgent              = theme.xcolor9
theme.bg_minimize            = theme.xcolor8
theme.bg_systray             = theme.xbg

theme.fg_normal              = theme.xfg
theme.fg_focus               = theme.xcolor4
theme.fg_urgent              = theme.xbg
theme.fg_minimize            = theme.xbg

theme.statusbar_width        = dpi(35)
theme.gap_single_client      = false
theme.useless_gap            = dpi(5)

-- borders
local black = "#303030"
theme.border_width           = dpi(0)
theme.border_normal          = black -- theme.xbg
theme.border_focus           = black -- theme.xbg
theme.border_marked          = black -- theme.xcolor10

theme.tooltip_fg             = theme.fg_normal
theme.tooltip_bg             = theme.bg_normal


-- taglist
theme.taglist_bg             = "alpha"
theme.taglist_bg_focus       = "alpha"
theme.taglist_fg_focus       = theme.xcolor6
theme.taglist_bg_urgent      = "alpha"
theme.taglist_fg_urgent      = theme.xcolor1
theme.taglist_bg_occupied    = "alpha"
theme.taglist_fg_occupied    = theme.xfg
theme.taglist_bg_empty       = "alpha"
theme.taglist_fg_empty       = theme.xfg
theme.taglist_bg_volatile    = "#00000000"
theme.taglist_fg_volatile    = theme.xcolor15

theme.taglist_squares_sel    = theme_assets.taglist_squares_sel(0, theme.fg_normal)
theme.taglist_squares_unsel  = theme_assets.taglist_squares_unsel(0, theme.fg_normal)


-- tasklist
theme.tasklist_bg_focus      = theme.xbg
theme.tasklist_fg_focus      = theme.xcolor2
theme.tasklist_bg_urgent     = theme.xcolor8
theme.tasklist_fg_urgent     = theme.xcolor1
theme.tasklist_bg_normal     = "alpha" --theme.xbg
theme.tasklist_fg_normal     = theme.xfg
theme.tasklist_bg_minimize   = theme.xcolor0
theme.tasklist_fg_minimize   = theme.xcolor0

theme.tasklist_plain_task_name = true
theme.tasklist_disable_task_name = false

-- titlebar
theme.titlebar_fg_normal     = theme.xfg
theme.titlebar_bg_normal     = theme.xcolor0
theme.titlebar_fg            = theme.xfg
theme.titlebar_bg            = theme.xbg
theme.titlebar_fg_focus      = theme.xcolor15
theme.titlebar_bg_focus      = theme.xcolor6

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = config_path.."default/submenu.png"
theme.menu_height = dpi(16)
theme.menu_width  = dpi(100)

theme.hotkeys_group_margin = dpi(40)
-- theme.hotkeys_shape = helpers.rrect(theme.border_radius)
theme.hotkeys_border_color = theme.xcolor1
theme.hotkeys_border_width = theme.border_width
theme.hotkeys_modifiers_fg = theme.xcolor8
theme.hotkeys_label_fg = theme.xbg
theme.hotkeys_label_bg = theme.xcolor5


-- Recolor Layout icons:
theme = theme_assets.recolor_layout(theme, theme.fg_normal)

-- layoutlist
theme.layoutlist_border_color = theme.xcolor8
theme.layoutlist_border_width = theme.border_width
theme.layoutlist_shape_selected = gears.shape.squircle
theme.layoutlist_bg_selected = theme.xcolor4

-- Notifications

theme.notification_font          = theme.font
theme.notification_bg            = theme.xbg
theme.notification_fg            = theme.xfg
theme.notification_border_width  = theme.border_width
theme.notification_border_color  = theme.xcolor8
theme.notification_position      = "top_right"
theme.notification_shape         = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 10) end
theme.notification_margin        = 5
theme.notification_max_width     = 500
theme.notification_max_height    = 400
theme.notification_icon_size     = 50

naughty.config.defaults['icon_size']  = 50
naughty.config.defaults.timeout       = 5
naughty.config.defaults.position      = "top_right"
naughty.config.defaults.bg            = theme.xbg
naughty.config.defaults.border_width  = theme.popup_border_width or 0
naughty.config.defaults.margin        = 10
naughty.config.padding                = 50
naughty.config.spacing                = 10


-- bling
theme.playerctl_backend = "playerctl_lib"
theme.dont_swallow_classname_list = {"firefox", "Gimp", "Google-chrome", "Thunar"}
-- theme.mstab_tabbar_position = "right"
theme.mstab_bar_height = 35
theme.mstab_font = "JetBrains Mono Nerd Font 10"
theme.mstab_dont_resize_slaves = false
theme.mstab_bar_padding = 0
theme.mstab_bar_ontop = true
theme.flash_focus_start_opacity = 0.8
theme.flash_focus_step = 0.05
theme.tabbar_bg_focus_inactive = "#ff0000"
theme.tabbar_fg_focus_inactive = "#000000"
theme.tabbar_bg_normal_inactive = "#00ff00"
theme.tabbar_fg_normal_inactive = "#0000ff"
theme.tabbar_bg_normal = theme.xbg2
theme.tabbar_fg_normal = theme.xfg
theme.tabbar_bg_focus = theme.xbg
theme.tabbar_fg_focus = theme.xcolor4
theme.tabbar_style = "default"
theme.tabbed_spawn_in_tab = true
theme.tabbar_disable = true
theme.tabbar_font = "JetBrains Mono Nerd Font 10"
theme.tabbar_position = "bottom"
theme.tabbar_AA_radius = 10

theme.tag_preview_widget_border_radius = theme.border_radius
theme.tag_preview_client_border_radius = 2
theme.tag_preview_client_opacity = 1
theme.tag_preview_client_bg = "#000000"
theme.tag_preview_client_border_color = theme.xcolor8
theme.tag_preview_client_border_width = 0
theme.tag_preview_widget_bg = theme.xcolor0
theme.tag_preview_widget_border_color = theme.xcolor0
theme.tag_preview_widget_border_width = 4
theme.tag_preview_widget_margin = 2

-- task preview widget
--theme.task_preview_widget_border_radius = theme.border_radius -- Border radius of the widget (With AA)
--theme.task_preview_widget_bg = theme.xbg2 -- The bg color of the widget
--theme.task_preview_widget_fg = theme.xbg -- The bg color of the widget
--theme.task_preview_widget_border_color = theme.xbg -- The border color of the widget
--theme.task_preview_widget_border_width = 3 -- The border width of the widget
--theme.task_preview_widget_margin = 20 -- The margin of the widget

-- window switcher
theme.window_switcher_widget_bg = theme.xbg2 -- The bg color of the widget
theme.window_switcher_widget_border_width = 6 -- The border width of the widget
theme.window_switcher_widget_border_radius = 10 -- The border radius of the widget
theme.window_switcher_widget_border_color = theme.xbg -- The border color of the widget
theme.window_switcher_clients_spacing = 15 -- The space between each client item
theme.window_switcher_client_icon_horizontal_spacing = 5 -- The space between client icon and text
theme.window_switcher_client_width = 150 -- The width of one client widget
theme.window_switcher_client_height = 250 -- The height of one client widget
theme.window_switcher_client_margins = 20 -- The margin between the content and the border of the widget
theme.window_switcher_thumbnail_margins = 10 -- The margin between one client thumbnail and the rest of the widget
theme.thumbnail_scale = false -- If set to true, the thumbnails fit policy will be set to "fit" instead of "auto"
theme.window_switcher_name_margins = 10 -- The margin of one clients title to the rest of the widget
theme.window_switcher_name_valign = "center" -- How to vertically align one clients title
theme.window_switcher_name_forced_width = 200 -- The width of one title
theme.window_switcher_name_font = "Sans 11" -- The font of all titles
theme.window_switcher_name_normal_color = theme.xfg -- The color of one title if the client is unfocused
theme.window_switcher_name_focus_color = theme.xcolor1 -- The color of one title if the client is focused
theme.window_switcher_icon_valign = "center" -- How to vertially align the one icon
theme.window_switcher_icon_width = 40 -- Thw width of one icon

-- other
-- naughty.config.shape = helpers.rrect(5)
theme.toolbar_font = "JetBrains Mono Nerd Font 12"

theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.xbg, theme.xfg
)

awesome.connect_signal("chcolor", function(colorscheme)
    local beautiful = require("beautiful")
    if colorscheme then
        beautiful.colorscheme = colorscheme
    else
        beautiful.colorscheme = read_colorscheme() or "amarenal"
        awesome.emit_signal("chcolor", beautiful.colorscheme)
    end
    local new_colors = farbig.get(beautiful.colorscheme)
    beautiful.xfg      = new_colors.base05 or xrdb.foreground or "#FFFFFF"
    beautiful.xbg      = new_colors.base00 or xrdb.background or "#1A2026"
    beautiful.xbg2     = new_colors.base01 or xrdb.bglight or "#526170"
    beautiful.xcolor0  = new_colors.base01 or xrdb.color0  or "#242D35"
    beautiful.xcolor8  = new_colors.base03 or xrdb.color8  or "#526170"
    beautiful.xcolor1  = new_colors.base08 or xrdb.color1  or "#FB6396"
    beautiful.xcolor9  = new_colors.base08 or xrdb.color9  or "#F92D72"
    beautiful.xcolor2  = new_colors.base09 or xrdb.color2  or "#94CF95"
    beautiful.xcolor10 = new_colors.base09 or xrdb.color10 or "#6CCB6E"
    beautiful.xcolor3  = new_colors.base0A or xrdb.color3  or "#F692B2"
    beautiful.xcolor11 = new_colors.base0A or xrdb.color11 or "#F26190"
    beautiful.xcolor4  = new_colors.base0B or xrdb.color4  or "#6EC1D6"
    beautiful.xcolor12 = new_colors.base0B or xrdb.color12 or "#4CB9D6"
    beautiful.xcolor5  = new_colors.base0C or xrdb.color5  or "#CD84C8"
    beautiful.xcolor13 = new_colors.base0C or xrdb.color13 or "#C269BC"
    beautiful.xcolor6  = new_colors.base0E or xrdb.color6  or "#7FE4D2"
    beautiful.xcolor14 = new_colors.base0E or xrdb.color14 or "#58D6BF"
    beautiful.xcolor7  = new_colors.base05 or xrdb.color7  or "#CFCFCF"
    beautiful.xcolor15 = new_colors.base05 or xrdb.color15 or "#F4F5F2"
end)

return theme
