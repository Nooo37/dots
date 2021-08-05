local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi   = require("beautiful").xresources.apply_dpi
local awesome, mouse = awesome, mouse

local helpers = require("helpers")

local bar_height = dpi(10)
local vol_bar = wibox.widget {
        max_value = 1,
        min_value = 1,
        value = 0.5,
        forced_height = bar_height,
        forced_width = dpi(250),
        bar_shape = helpers.rrect(dpi(3)),
        shape = helpers.rrect(dpi(3)),
        color = beautiful.xcolor2,
        background_color = "alphe", --beautiful.xcolor8,
        widget = wibox.widget.progressbar
}

local pop = awful.popup {
        widget = {
                {
                        -- helpers.horizontal_pad(dpi(20)),
                        {
                                {
                                        {
                                                -- wibox.widget.imagebox(beautiful.awesome_icon),
                                                {
                                                        markup = helpers.colorize_text("墳", beautiful.xcolor2),
                                                        font = "JetBrainsMono Nerd Font Bold 12",
                                                        -- color = beautiful.xbg,
                                                        widget = wibox.widget.textbox,
                                                },
                                                wibox.widget.textbox("huhu"),
                                                bg = beautiful.xbg,
                                                shape = helpers.rrect(dpi(beautiful.border_radius)),
                                                widget = wibox.container.background,
                                        },
                                        margins = dpi(5),
                                        widget = wibox.container.margin
                                },
                                valign = "center",
                                halign = "center",
                                widget = wibox.container.place
                        },
                        {
                                {
                                        {
                                                {
                                                        {
                                                                wibox.widget.textbox(""),
                                                                bg = beautiful.xcolor8,
                                                                shape = helpers.rrect(dpi(10)),
                                                                widget = wibox.container.background
                                                        },
                                                        margins = bar_height / 4,
                                                        widget = wibox.container.margin
                                                },
                                                vol_bar,
                                                layout = wibox.layout.stack,
                                        },
                                        margins = dpi(14),
                                        widget = wibox.container.margin
                                },
                                bg = beautiful.xbg,
                                shape = helpers.rrect(dpi(beautiful.border_radius)),
                                widget = wibox.container.background,
                        },
                        -- helpers.horizontal_pad(dpi(20)),
                        layout = wibox.layout.fixed.horizontal
                },
                margins = dpi(0),
                widget = wibox.container.margin
        },
        bg = beautiful.xbg2,
        y = (1080 - 70),
        x = (1920 - 300) / 2,
        visible = false,
        ontop = true,
        shape = helpers.rrect(dpi(10)),
}

local hide = gears.timer.start_new(5, function() pop.visible = false end)

awesome.connect_signal("evil::volume", function(perc, _)
        vol_bar.value = perc / 100
        pop.visible = true
        hide:again()
end)

