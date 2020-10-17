local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local naughty = require("naughty")
local gears = require("gears")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()
local gfs = require("gears.filesystem")

local helpers = require("ui.helpers") -- only for notification appearance

local config_path = os.getenv("HOME") .. "/.config/awesome/"


local theme = {}

theme.weather_city = "Berlin"

theme.terminal = "alacritty"
theme.browser  = "Firefox"
theme.editor   = "Atom"

theme.config_path = config_path
theme.wallpaper = config_path.."wallpaper.png"

theme.corner_radius = dpi(8) --14   8
theme.font          = "sans 8"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = config_path.."default/submenu.png" --TODO wtf
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- Define the image to load
theme.titlebar_close_button_normal              = config_path.."icon/titlebar/close_normal.png"
theme.titlebar_close_button_focus               = config_path.."icon/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal           = config_path.."icon/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = config_path.."icon/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive     = config_path.."icon/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = config_path.."icon/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = config_path.."icon/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = config_path.."icon/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive    = config_path.."icon/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = config_path.."icon/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = config_path.."icon/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = config_path.."icon/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive  = config_path.."icon/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = config_path.."icon/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = config_path.."icon/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = config_path.."icon/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = config_path.."icon/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = config_path.."icon/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = config_path.."icon/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = config_path.."icon/titlebar/maximized_focus_active.png"


-- You can use your own layout icons like this:
theme.layout_fairh      = config_path.."icon/layouts/fairhw.png"
theme.layout_fairv      = config_path.."icon/layouts/fairvw.png"
theme.layout_floating   = config_path.."icon/layouts/floatingw.png"
theme.layout_magnifier  = config_path.."icon/layouts/magnifierw.png"
theme.layout_max        = config_path.."icon/layouts/maxw.png"
theme.layout_fullscreen = config_path.."icon/layouts/fullscreenw.png"
theme.layout_tilebottom = config_path.."icon/layouts/tilebottomw.png"
theme.layout_tileleft   = config_path.."icon/layouts/tileleftw.png"
theme.layout_tile       = config_path.."icon/layouts/tilew.png"
theme.layout_tiletop    = config_path.."icon/layouts/tiletopw.png"
theme.layout_spiral     = config_path.."icon/layouts/spiralw.png"
theme.layout_dwindle    = config_path.."icon/layouts/dwindlew.png"
theme.layout_cornernw   = config_path.."icon/layouts/cornernww.png"
theme.layout_cornerne   = config_path.."icon/layouts/cornernew.png"
theme.layout_cornersw   = config_path.."icon/layouts/cornersww.png"
theme.layout_cornerse   = config_path.."icons/layouts/cornersew.png"

theme.icon = {
  main = config_path.."icon/tags/main.png",
  web  = config_path.."icon/tags/web.png",
  code = config_path.."icon/tags/code.png",
  read = config_path.."icon/tags/read.png",
  chat = config_path.."icon/tags/chat.png",
}


-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

theme.font          = "sans 8"

-- colors
theme.xfg                                       = xrdb.foreground or "#FFFFFF"
theme.xbg                                       = xrdb.background or "#1A2026"
theme.xbgdark                                   = xrdb.bgdark  or "#101010"---"#14181d"
theme.xbglight                                  = xrdb.bglight or "#526170"
theme.xcolor0                                   = xrdb.color0  or "#242D35"
theme.xcolor8                                   = xrdb.color8  or "#526170"
theme.xcolor1                                   = xrdb.color1  or "#FB6396"
theme.xcolor9                                   = xrdb.color9  or "#F92D72"
theme.xcolor2                                   = xrdb.color2  or "#94CF95"
theme.xcolor10                                  = xrdb.color10 or "#6CCB6E"
theme.xcolor3                                   = xrdb.color3  or "#F692B2"
theme.xcolor11                                  = xrdb.color11 or "#F26190"
theme.xcolor4                                   = xrdb.color4  or "#6EC1D6"
theme.xcolor12                                  = xrdb.color12 or "#4CB9D6"
theme.xcolor5                                   = xrdb.color5  or "#CD84C8"
theme.xcolor13                                  = xrdb.color13 or "#C269BC"
theme.xcolor6                                   = xrdb.color6  or "#7FE4D2"
theme.xcolor14                                  = xrdb.color14 or "#58D6BF"
theme.xcolor7                                   = xrdb.color7  or "#CFCFCF"
theme.xcolor15                                  = xrdb.color15 or "#F4F5F2"

theme.bg_normal     = theme.xbg
theme.bg_focus      = theme.xcolor12
theme.bg_urgent     = theme.xcolor9
theme.bg_minimize   = theme.xcolor8
theme.bg_systray    = theme.xbg

theme.fg_normal     = theme.xfg
theme.fg_focus      = theme.xbg
theme.fg_urgent     = theme.xbg
theme.fg_minimize   = theme.xbg

theme.gap_single_client = false
theme.useless_gap   = dpi(5)

-- borders
theme.border_width  = dpi(2)
theme.border_normal = theme.xcolor0
theme.border_focus  = theme.xcolor1
theme.border_marked = theme.xcolor10

theme.tooltip_fg = theme.fg_normal
theme.tooltip_bg = theme.bg_normal


-- taglist
theme.taglist_bg                                = "alpha" --theme.xcolor2
theme.taglist_bg_focus                          = theme.xcolor5-- theme.xfg
theme.taglist_fg_focus                          = theme.xfg--theme.xcolor2
theme.taglist_bg_urgent                         = theme.xcolor2
theme.taglist_fg_urgent                         = theme.xfg
theme.taglist_bg_occupied                       = "alpha"-- theme.xcolor5
theme.taglist_fg_occupied                       = theme.xfg
theme.taglist_bg_empty                          = "alpha" --theme.xcolor8
theme.taglist_fg_empty                          = theme.xcolor8
theme.taglist_bg_volatile                       = "#00000000"
theme.taglist_fg_volatile                       = theme.xcolor15

-- titlebar
theme.titlebar_fg_normal 	                      = theme.xfg
theme.titlebar_bg_normal 	                      = theme.xbg
theme.titlebar_fg 	                            = theme.xfg
theme.titlebar_bg 	                            = theme.xbg
theme.titlebar_fg_focus 	                      = theme.xcolor15
theme.titlebar_bg_focus 	                      = theme.xbgdark

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = config_path.."default/submenu.png"
theme.menu_height = dpi(16)
theme.menu_width  = dpi(100)

-- Recolor Layout icons:
theme = theme_assets.recolor_layout(theme, theme.fg_normal)

-- Recolor titlebar icons:
--
-- local function darker(color_value, darker_n)
--     local result = "#"
--     for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
--         local bg_numeric_value = tonumber("0x"..s) - darker_n
--         if bg_numeric_value < 0 then bg_numeric_value = 0 end
--         if bg_numeric_value > 255 then bg_numeric_value = 255 end
--         result = result .. string.format("%2.2x", bg_numeric_value)
--     end
--     return result
-- end
-- theme = theme_assets.recolor_titlebar(
--     theme, theme.fg_normal, "normal"
-- )
-- theme = theme_assets.recolor_titlebar(
--     theme, darker(theme.fg_normal, -60), "normal", "hover"
-- )
-- theme = theme_assets.recolor_titlebar(
--     theme, xrdb.color1, "normal", "press"
-- )
-- theme = theme_assets.recolor_titlebar(
--     theme, theme.fg_focus, "focus"
-- )
-- theme = theme_assets.recolor_titlebar(
--     theme, darker(theme.fg_focus, -60), "focus", "hover"
-- )
-- theme = theme_assets.recolor_titlebar(
--     theme, xrdb.color1, "focus", "press"
-- )

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Try to determine if we are running light or dark colorscheme:
local bg_numberic_value = 0;
for s in theme.bg_normal:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
    bg_numberic_value = bg_numberic_value + tonumber("0x"..s);
end
local is_dark_bg = (bg_numberic_value < 383)

-- Notifications appearance
naughty.config.defaults['icon_size']  = 50
naughty.config.defaults.timeout       = 5
naughty.config.defaults.position      = "top_right"
naughty.config.defaults.bg            = theme.xbg
theme.notification_border_color       = theme.popup_border_color or "#000000"
naughty.config.defaults.border_width  = theme.popup_border_width or 0
naughty.config.defaults.margin        = 10
naughty.config.padding                = 30
naughty.config.spacing                = 10

theme.notification_font          = theme.font
theme.notification_bg            = theme.xbg
theme.notification_fg 	         = theme.xfg
theme.notification_border_width  = theme.border_width
theme.notification_border_color  = theme.xcolor8
theme.notification_position      = "top_right"
-- theme.notification_shape 	       = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 10) end
-- theme.notification_opacity 	Notifications opacity.
theme.notification_margin 	     = 30
-- theme.notification_width 	Notifications width.
theme.notification_max_width     = 500
theme.notification_max_height    = 400
theme.notification_icon_size     = 50

-- collision
theme.collision_bg_focus            = theme.xcolor8
theme.collision_fg_focus 	          = theme.xbg
theme.collision_bg_center 	        = theme.xcolor8
theme.collision_resize_width 	      = 30
-- theme.collision_resize_shape 	      =
theme.collision_resize_border_width = theme.border_width
theme.collision_resize_border_color = theme.xcolor6
-- theme.collision_resize_padding 	    = ??
theme.collision_resize_bg 	        = theme.xcolor8
theme.collision_resize_fg           = theme.xcolor6
-- theme.collision_focus_shape         = theme.
theme.collision_focus_border_width  = 0
theme.collision_focus_border_color  = theme.xcolor1
-- theme.collision_focus_padding       = theme.
theme.collision_focus_bg            = theme.xcolor8
theme.collision_focus_fg            = theme.xbg
theme.collision_focus_bg_center     = theme.xcolor8
-- theme.collision_screen_shape        =
theme.collision_screen_border_width = 0 
theme.collision_screen_border_color = theme.xcolor5
-- theme.collision_screen_padding      =
theme.collision_screen_bg           = theme.xcolor8
theme.collision_screen_fg           = theme.xcolor2
theme.collision_screen_bg_focus     = theme.xcolor8
theme.collision_screen_fg_focus     = theme.xcolor1


naughty.config.shape = helpers.rrect(5)


return theme
