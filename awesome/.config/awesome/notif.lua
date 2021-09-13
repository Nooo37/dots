-- notification config, requires 4.4 :-:

local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awesome = awesome

local helpers = require("helpers")

local icon_size = 65

naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(icon_size)
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.timeout = 8
naughty.config.defaults.title = "System Notification"
naughty.config.defaults.padding = dpi(10)
naughty.config.defaults.position = "top_right"
naughty.config.defaults.bg = beautiful.xbg

naughty.config.presets.normal = {
    font = "JetBrainsMono Nerd Font 10",
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal
}

naughty.config.presets.low = {
    font = "JetBrainsMono Nerd Font 10",
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal
}


naughty.connect_signal("request::display", function(n)
    n.timeout = 8
    local noti_icon = n.icon or n.app_icon
    local noti_title = helpers.colorize_text(n.title, beautiful.xcolor6)
    local noti_message = n.message
    naughty.layout.box {
        notification = n,
        type = "notification",
        bg = "alpha",
        widget_template = {
            {
                {
                    -- {
		       { -- left part with icon
			  {
                                {
                                    image = noti_icon,
                                    forced_height = icon_size,
                                    resize = true,
                                    clip_shape = helpers.rrect(10),
                                    widget = wibox.widget.imagebox
                                },
			     margins = dpi(8), -- between image and outter border
			     widget = wibox.container.margin
			  },
			  bg = beautiful.xbg2,
			  widget = wibox.container.background
		       },
		       { -- right part with text
                                {
		                   {
		                      nil,
		                      {
		                 	{
		                 	   markup = noti_title,
		                 	   font = "JetBrainsMono Nerd Font 14",
		                 	   widget = wibox.widget.textbox
		                 	},
                                        helpers.vertical_pad(3),
		                 	{
		                 	   markup = noti_message,
		                 	   font = "JetBrainsMono Nerd Font 9",
		                 	   widget = wibox.widget.textbox
		                 	},
		                 	layout = wibox.layout.fixed.vertical
		                      },
		                      naughty.list.actions,
		                      layout = wibox.layout.align.vertical
		                   },
		                   margins = dpi(10),
		                   shape = helpers.rrect(5),
		                   bg = beautiful.xcolor1,
		                   widget = wibox.container.margin
                                },
                                id = "background_id",
                                widget = naughty.container.background
		       },
		       fill_space = true,
		       layout = wibox.layout.fixed.horizontal
                },
                strategy = "max",
                width = 300,
                widget = wibox.container.constraint
            },
            shape = helpers.rrect(beautiful.border_radius),
            widget = wibox.container.background
    }
	} -- end of widget_template

end)

naughty.connect_signal("added", function(notification)
    if (notification.app_name and notification.app_name == "Brave") or (notification.clients[1] and notification.clients[1].class == "Brave-browser") then
        naughty.destroy_all_notifications(awful.screen.focused(), naughty.notificationClosedReason.dismissedByUser)
    end
end)

