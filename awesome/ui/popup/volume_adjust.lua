local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("ui.helpers")

local screen = awful.screen.focused()
local popup_width = dpi(400)
local popup_height = dpi(50)
local popup_border_width      = 5
local popup_border_color      = beautiful.xcolor0
-- local progressbar_fill_color  = beautiful.xfg
local progressbar_empty_color = beautiful.xcolor8
local popup_icon_color        = beautiful.xcolor3
local popup_background        = beautiful.xbg
local popup_corner_radius     = beautiful.corner_radius or 0
local popup_timeout           = beautiful.popup_timeout or 8

local progressbar_active_color = {
  type = 'linear',
  from = { 0, 0 },
  to = { 300, 50 }, -- replace with w,h later
  stops = {
    { 0.00, beautiful.xcolor6  },
    { 0.55, beautiful.xcolor14 },
  }
}


local icon_textbox = wibox.widget{ -- 🕨🕩🕪
   font = "JetBrainsMono Nerd Font 21", 
   markup = helpers.colorize_text("🕩", popup_icon_color),
   widget = wibox.widget.textbox
}

awesome.connect_signal("evil::volume", function(percentage, muted)
  if muted then 
    icon_textbox.markup = helpers.colorize_text("ﱝ", beautiful.xcolor3) -- 🕨
  elseif percentage < 10 then
    icon_textbox.markup = helpers.colorize_text("", beautiful.xcolor3) -- 🕨
  elseif percentage < 50 then
    icon_textbox.markup = helpers.colorize_text("", beautiful.xcolor3) -- 🕩
  else
    icon_textbox.markup = helpers.colorize_text("墳", beautiful.xcolor3) -- 🕪
  end
end)


  -- create the volume_adjust component
local volume_adjust = wibox({
   screen = awful.screen.focused(),
   x = (screen.geometry.width / 2) - (popup_width / 2),
   y = screen.workarea.height - (popup_height * 1.5),
   width = popup_width,
   height = popup_height,
   shape = helpers.rrect(popup_corner_radius),
   visible = false,
   border_width = popup_border_width,
   border_color = popup_border_color,
   bg = popup_background,
   ontop = true
})

local vol_slider = require("ui.widget.vol_slider").create(progressbar_active_color, progressbar_empty_color)

volume_adjust:setup {
  layout = wibox.layout.fixed.horizontal,
  -- wibox.container.margin(
  --   icon_textbox,
  --   dpi(8), dpi(0), dpi(10), dpi(5)
  -- ),
   wibox.container.margin(
    vol_slider,
    dpi(20), dpi(20), dpi(0), dpi(0)
  ),
}


-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_adjust = gears.timer {
   timeout = popup_timeout,
   autostart = true,
   callback = function()
      volume_adjust.visible = false
   end
}

-- show volume-adjust when "volume_change" signal is emitted
awesome.connect_signal("evil::volume",
    function(volume, muted)
        -- make volume_adjust component visible
          if volume_adjust.visible then
              hide_volume_adjust:again()
          else
              volume_adjust.visible = true
              hide_volume_adjust:start()
          end
    end
)
