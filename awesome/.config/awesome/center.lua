local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local farbig = require("module.farbig")
local awesome, screen = awesome, screen

local helpers = require("helpers")
local Button = require("button")

local button_pad = 15
local pad = 20


-- BUTTONS

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
        b_micr:set_icon("")
        b_micr:set_label("Off")
    else
        b_micr:set_icon("")
        b_micr:set_label("On")
    end
    micro_on = not micro_on
    beautiful.discord = micro_on
end)
local b_powr = Button:new { sym = "", label = "Power" }
b_powr:on_click(function(_)
    awful.spawn.with_shell("systemctl poweroff")
end)
local b_susp = Button:new { sym = "鈴", label = "Susp" }
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


-- SLIDER

local function create_slider()
    local res = wibox.widget {
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 7,
        bar_color           = beautiful.xbg,
        handle_color        = beautiful.xfg,
        handle_shape        = gears.shape.circle,
        handle_border_color = beautiful.xfg,
        handle_border_width = 0,
        value               = 25,
        forced_height       = 30,
        widget              = wibox.widget.slider,
    }
    awesome.connect_signal("chcolor", function()
        res.bar_color = beautiful.xbg
        res.handle_color = beautiful.xfg
    end)
    return res
end
local vol_slider = create_slider()
vol_slider:connect_signal("property::value", function(_, nv)
    awful.spawn.with_shell("amixer set 'Master' " .. tostring(nv) .. "%")
end)
local bri_slider = create_slider()

-- SPLITWIDGET COLORSCHEME

local fact = 4
local split = wibox.widget {
    helpers.horizontal_pad(fact * pad),
    {
        wibox.widget.textbox(""),
        forced_height = 1,
        forced_width = 100,
        bg = beautiful.xbg,
        widget = wibox.container.background
    },
    helpers.horizontal_pad(fact * pad),
    layout = wibox.layout.align.horizontal
}

local colorscheme_label = wibox.widget {
    text = beautiful.colorscheme or "dunno",
    markup = helpers.colorize_text(beautiful.colorscheme, beautiful.xfg),
    font = "Sans 13",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}


awesome.connect_signal("chcolor", function()
    split.bg = beautiful.xbg
    colorscheme_label.text = beautiful.colorscheme:gsub("-", " ")
    colorscheme_label.markup = helpers.colorize_text(colorscheme_label.text, beautiful.xfg)
end)

local function create_container(wid)
    local res = wibox.widget { -- button box
        wid,
        bg = "#ff000000",
        border_width = 0,
        border_color = beautiful.xbg,
        shape = helpers.rrect(10),
        widget = wibox.container.background
    }
    -- TODO connnect chcolor
    return res
end

local button_con = create_container {
    nil,
    {
        helpers.vertical_pad(pad),
        {
            helpers.horizontal_pad(pad),
            b_micr.widget,
            helpers.horizontal_pad(button_pad),
            b_wifi.widget,
            helpers.horizontal_pad(button_pad),
            b_blue.widget,
            helpers.horizontal_pad(button_pad),
            b_layo.widget,
            helpers.horizontal_pad(button_pad),
            b_noti.widget,
            helpers.horizontal_pad(pad),
            layout = wibox.layout.fixed.horizontal
        },
        helpers.vertical_pad(button_pad),
        {
            helpers.horizontal_pad(pad),
            b_powr.widget, helpers.horizontal_pad(button_pad),
            b_susp.widget,
            helpers.horizontal_pad(button_pad),
            b_rebo.widget,
            helpers.horizontal_pad(button_pad),
            b_logo.widget,
            helpers.horizontal_pad(button_pad),
            b_colo.widget,
            helpers.horizontal_pad(pad),
            layout = wibox.layout.fixed.horizontal
        },
        helpers.vertical_pad(pad),
        layout = wibox.layout.fixed.vertical
    },
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
}

local color_con = create_container {
    helpers.vertical_pad(pad),
    colorscheme_label,
    helpers.vertical_pad(pad),
    layout = wibox.layout.fixed.vertical
}

local slider_con = create_container {
    helpers.horizontal_pad(pad),
    {
        helpers.vertical_pad(pad),
        vol_slider,
        helpers.vertical_pad(pad),
        bri_slider,
        helpers.vertical_pad(pad),
        layout = wibox.layout.fixed.vertical
    },
    helpers.horizontal_pad(pad),
    layout = wibox.layout.align.horizontal
}

local center = {
    button_con,
    split,
    slider_con,
    split,
    color_con,
    layout = wibox.layout.fixed.vertical
}

local outter_pad = 20
return { -- only add general padd between outter wibox and widgets here
    helpers.horizontal_pad(outter_pad),
    {
        helpers.vertical_pad(outter_pad),
        center,
        helpers.vertical_pad(outter_pad),
        layout = wibox.layout.align.vertical
    },
    helpers.horizontal_pad(outter_pad),
    layout = wibox.layout.align.horizontal
}
