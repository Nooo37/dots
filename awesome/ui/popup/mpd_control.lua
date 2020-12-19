local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")


local offsetx = dpi(350)
local offsety = dpi(350)
local screen = awful.screen.focused()
local helpers = require("ui.helpers")
-- local icon_theme = "sheet"
-- local icons = require("icons")
-- icons.init(icon_theme)

--
-- local vol_slider = require("widgets.vol_slider")


local popup_border_width  = beautiful.popup_border_width
local popup_timeout       = beautiful.popup_timeout
local popup_border_color  = beautiful.popup_border_color
local popup_icon_color    = beautiful.xfg
local popup_background    = beautiful.xbg
local popup_corner_radius = beautiful.corner_radius
local popup_timeout       = 6

local mpd_adjust = wibox({
   screen = awful.screen.focused(),
   x = screen.geometry.width - offsetx - dpi(30),
   y = screen.geometry.height - offsety + dpi(120),
   width = offsetx,
   height = dpi(200),
   shape = helpers.rrect(popup_corner_radius),
   visible = false,
   border_width = popup_border_width,
   border_color = popup_border_color,
   bg = popup_background,
   ontop = true
})


local mpd_widget = require("ui.widget.mpd").create()

mpd_adjust:setup {
   layout = wibox.layout.align.vertical,
   {
      wibox.container.margin(
         mpd_widget, dpi(14), dpi(20), dpi(20), dpi(20)
      ),
      forced_height = offsety * 0.75,
      -- direction = "east",
      layout = wibox.layout.align.vertical-- wibox.container.rotate
   }
}

-- create a 3 second timer to hide the mpd adjust
-- component whenever the timer is started
local hide_mpd_adjust = gears.timer {
   timeout = popup_timeout,
   autostart = true,
   callback = function()
      mpd_adjust.visible = false
   end
}

-- show mpd-adjust when "mpd_change" signal is emitted
awesome.connect_signal("evil::mpd",
  function(artist, title, paused, _)
    if not paused then
      if mpd_adjust.visible then
        hide_mpd_adjust:again()
      else
        mpd_adjust.visible = true
        hide_mpd_adjust:start()
      end
    end
  end
)
