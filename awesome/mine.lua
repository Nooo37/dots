local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require(tostring(...):match(".*bling") .. ".helpers")

local bg_normal = beautiful.tabbar_bg_normal or beautiful.bg_normal or "#ffffff"
local fg_normal = beautiful.tabbar_fg_normal or beautiful.fg_normal or "#000000"
local bg_focus = beautiful.tabbar_bg_focus or beautiful.bg_focus or "#000000"
local fg_focus = beautiful.tabbar_fg_focus or beautiful.fg_focus or "#ffffff"
local size = beautiful.tabbar_size or dpi(40)
local border_radius = dpi(6)
local position = beautiful.tabbar_position or "top"


local function create(c, focused_bool, buttons)
    local title_temp = c.name or c.class or "-"
    local bg_temp = bg_normal

    if focused_bool then
        bg_temp = bg_focus
    end

    local    top_margin = dpi(8)
    local bottom_margin = dpi(8)
    local  right_margin = dpi(12)
    local   left_margin = dpi(12)

    if position == "right" or position == "left" then
        top_margin    = dpi(12)
        bottom_margin = dpi(12)
        right_margin  = dpi(6)
        left_margin   = dpi(6)
    end

    local top_marg, bottom_marg, right_marg, left_marg
    local marg = dpi(6)
    local box_layout = wibox.layout.align.horizontal
    local height, width
    
    if position == "right" then
        right_marg = marg
        box_layout = wibox.layout.align.vertical
        height = border_radius + (border_radius / 2)
        width = size
    elseif position == "left" then
        left_marg = marg
        box_layout = wibox.layout.align.vertical
        height = border_radius + (border_radius / 2)
        width = size
    elseif position == "top" then
        top_marg = marg
        width = border_radius + (border_radius / 2)
        height = size
    elseif position == "bottom" then
        bottom_marg = marg
        width = border_radius + (border_radius / 2)
        height = size
    end

    
    local tab_content = wibox.widget {
        {
            awful.widget.clienticon(c),
            top    = dpi(8),
            left   = dpi(10),
            right  = dpi(10),
            bottom = dpi(8),
            widget = wibox.container.margin
        },
        expand = "none",
        layout = box_layout()
    }

    local wid_temp = wibox.widget({
        buttons = buttons,
        {
            {
                {
                    wibox.widget.textbox(),
                    bg = bg_normal,
                    shape = helpers.shape.prrect(border_radius,
                       (position == "left"),
                       (position == "bottom"),
                       (position == "top"),
                       (position == "right")
                    ),
                    widget = wibox.container.background
                },
                bg = bg_temp,
                shape = gears.rectangle,
                widget = wibox.container.background
            },
            width = width, 
            height = height,
            strategy = "exact",
            layout = wibox.layout.constraint
        },
        {
            {
                tab_content,
                bg = bg_temp,
                shape = helpers.shape.prrect(border_radius,
                   (position == "top" or position == "left"),
                   (position == "top" or position == "right"),
                   (position == "bottom" or position == "right"),
                   (position == "bottom" or position == "left")
                ),
                widget = wibox.container.background
            },
            top = top_marg,
            bottom = bottom_marg,
            right = right_marg,
            left = left_marg,
            widget = wibox.container.margin
        },
        {
            {
                {
                    wibox.widget.textbox(),
                    bg = bg_normal,
                    shape = helpers.shape.prrect(border_radius,
                       (position == "bottom"),
                       (position == "left"),
                       (position == "right"),
                       (position == "top")
                    ),
                    widget = wibox.container.background
                },
                bg = bg_temp,
                shape = gears.rectangle,
                widget = wibox.container.background
            },
            width = width,  
            height = height,
            strategy = "exact",
            layout = wibox.layout.constraint
        },
        layout = box_layout()
    })
    return wid_temp
end

return {
    layout = wibox.layout.fixed.horizontal,
    create = create,
    position = position,
    size = size,
    bg_normal = bg_normal,
    bg_focus = bg_focus
}
