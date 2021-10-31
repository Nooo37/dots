local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local farbig = require("module.farbig")
local awesome, screen = awesome, screen

local helpers = require("helpers")
local Button = require("button")

local b_wifi = Button:new { sym = "直", label = "WLAN0"}
b_wifi:on_click(function(_) naughty.notify{text = "kjl"} end)
local b_noti = Button:new { sym = "", label = "on" }
b_noti:on_click(function(_)
    if naughty.suspended then
        naughty.suspended = false
        b_noti:set_icon("")
        b_noti:set_label("On")
    else
        naughty.suspended = true
        b_noti:set_icon("")
        b_noti:set_label("Off")
    end
end)
local bluetooth_on
local b_blue = Button:new { sym = "", label = "On" } -- 
b_blue:on_click(function(_)
    if bluetooth_on then
        b_blue:set_icon("")
        b_blue:set_label("On")
    else
        b_blue:set_icon("")
        b_blue:set_label("Off")
    end
    bluetooth_on = not bluetooth_on
end)
local b_layo = Button:new { sym = ""}
b_layo:on_click(function(_) naughty.notify{text = "kjl"} end)
local micro_on = true
local b_micr = Button:new { sym = "", label = "On" } -- 
b_micr:on_click(function(_)
    if micro_on then
        b_micr:set_icon("")
        b_micr:set_label("On")
    else
        b_micr:set_icon("")
        b_micr:set_label("Off")
    end
    micro_on = not micro_on
end)

local b_powr = Button:new { sym = "", label = "Poweroff" }
b_powr:on_click(function(_)
    awful.spawn.with_shell("systemctl poweroff")
end)
local b_susp = Button:new { sym = "鈴", label = "Suspend" }
b_susp:on_click(function(_)
    awful.spawn.with_shell("systemctl suspend")
end)
local b_rebo = Button:new { sym = "", label = "Reboot" }
b_rebo:on_click(function(_)
    awful.spawn.with_shell("systemctl reboot")
end)
local b_logo = Button:new { sym = "", label = "Logout" }
b_logo:on_click(function(_)
    -- TODO
end)
local b_colo = Button:new { sym = "", label = "Colors" }
b_colo:on_click(function(_)
    local new_scheme = farbig.all[math.random(#farbig.all)]
    awful.spawn.with_shell("$HOME/.local/bin/chcolor " .. new_scheme)
end)

local colorscheme_label = wibox.widget {
    text = beautiful.colorscheme or "dunno",
    markup = helpers.colorize_text(beautiful.colorscheme, beautiful.xfg),
    font = "Sans 13",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

awesome.connect_signal("chcolor", function()
    colorscheme_label.text = beautiful.colorscheme:gsub("-", " ")
    colorscheme_label.markup = helpers.colorize_text(colorscheme_label.text, beautiful.xfg)
end)

local pad = 15
local center = {
    nil,
    {
        helpers.vertical_pad(20),
        helpers.vertical_pad(pad),
        {
            b_micr.widget,
            helpers.horizontal_pad(pad),
            b_wifi.widget,
            helpers.horizontal_pad(pad),
            b_blue.widget,
            helpers.horizontal_pad(pad),
            b_layo.widget,
            helpers.horizontal_pad(pad),
            b_noti.widget,
            layout = wibox.layout.fixed.horizontal
        },
        helpers.vertical_pad(pad),
        {
            b_powr.widget,
            helpers.horizontal_pad(pad),
            b_susp.widget,
            helpers.horizontal_pad(pad),
            b_rebo.widget,
            helpers.horizontal_pad(pad),
            b_logo.widget,
            helpers.horizontal_pad(pad),
            b_colo.widget,
            layout = wibox.layout.fixed.horizontal
        },
        helpers.vertical_pad(1.5 * pad),
        colorscheme_label,
        helpers.vertical_pad(pad),
        layout = wibox.layout.fixed.vertical
    },
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
}


local center_width = 400
local center_height = 500
local centerbox = wibox {
    height = center_height,
    width = center_width,
    x = 20 + beautiful.statusbar_width,
    y = 20,
    visible = false,
    ontop = true,
    shape = helpers.rrect(20),
    bg = beautiful.xbg2,
}

awesome.connect_signal("toggle::dash", function()
    centerbox.visible = not centerbox.visible
end)

awesome.connect_signal("chcolor", function()
    centerbox.bg = beautiful.xbg2
end)

centerbox:setup(center)
