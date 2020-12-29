-- TODO finish 

local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

local helpers = require("ui.helpers")
local primary_bg = beautiful.xbg -- background of boxes
local secondary_bg = beautiful.xbg -- background background
local bar_height = 35
local bar_font = "JetBrainsMono Nerd Font 10"
local bar_position = "bottom"

local border_color_normal = beautiful.xcolor0
local border_color_focus = beautiful.xcolor6
local border_width = 3
local bar_hopad = 25

local function create_box(widget, forced_width) 
    local temp_wid = wibox.widget { 
        {
            {
                {
                    {
                        widget,
                        top = 2,
                        bottom = 2,
                        right = 5,
                        left = 5,
                        widget = wibox.container.margin
                    },
                    bg = primary_bg,
                    shape = helpers.rrect(beautiful.border_radius),
                    widget = wibox.container.background
                },
                margins = border_width,
                widget = wibox.container.margin
            },
            id = "border",
            bg = border_color_normal,
            shape = helpers.rrect(beautiful.border_radius),
            widget = wibox.container.background
        },
        forced_width = forced_width,
        margins = 4,
        widget = wibox.container.margin
    }
    temp_wid:connect_signal("mouse::enter", function()
        temp_wid:get_children_by_id("border")[1].bg = border_color_focus
    end)
    temp_wid:connect_signal("mouse::leave", function()
        temp_wid:get_children_by_id("border")[1].bg = border_color_normal
    end)
    return temp_wid
end

--{{{ time

local fancy_time = wibox.widget.textclock("%H:%M %a %d.%m.%y")
fancy_time.font = bar_font
fancy_time.align = "center"
fancy_time.valign = "center"
fancy_time.markup = helpers.colorize_text(fancy_time.text, beautiful.xcolor6)

fancy_time:connect_signal("widget::redraw_needed", function()
    fancy_time.markup = helpers.colorize_text(fancy_time.text, beautiful.xcolor6)
end)

local time_box = create_box({helpers.horizontal_pad(bar_hopad), fancy_time, helpers.horizontal_pad(bar_hopad), layout=wibox.layout.align.horizontal})

--}}}

--{{{ diverse box

local monstrosity = wibox.widget.textbox("")
monstrosity.font = bar_font
monstrosity.align = "center"
monstrosity.valign = "center"
monstrosity.values = {}
monstrosity.values.disk_perc = 0
monstrosity.values.ram_perc = 0
monstrosity.values.cpu_perc = 0
monstrosity.values.cpu_temp = 0

local function update_monstrosity() 
    monstrosity.markup = helpers.colorize_text(" ", beautiful.xcolor1) .. monstrosity.values.cpu_temp .. "°C" .. "    "
                        .. helpers.colorize_text(" ", beautiful.xcolor2) .. monstrosity.values.cpu_perc .. "%".. "    "
                        .. helpers.colorize_text(" ", beautiful.xcolor3) .. monstrosity.values.disk_perc .."%".. "    "
                        .. helpers.colorize_text(" ", beautiful.xcolor4) .. monstrosity.values.ram_perc .. "%" 
end


awesome.connect_signal("evil::temp", function(temp)
    monstrosity.values.cpu_temp = tostring(temp) 
    update_monstrosity()
end)

awesome.connect_signal("evil::disk", function(used, total)
    monstrosity.values.disk_perc = tostring(math.floor(used / total * 100)) 
    update_monstrosity()
end)

awesome.connect_signal("evil::ram", function(used, total)
    monstrosity.values.ram_perc = tostring(math.floor(used / total * 100)) 
    update_monstrosity()
end)

awesome.connect_signal("evil::cpu", function(perc)
    monstrosity.values.cpu_perc = tostring(perc) 
    update_monstrosity()
end)

local diverse_box = create_box({
    helpers.horizontal_pad(bar_hopad),
    monstrosity,
    helpers.horizontal_pad(bar_hopad),
    layout = wibox.layout.align.horizontal
})

--}}}

--{{{ focused client title

local title_text = wibox.widget.textbox()
title_text.font = bar_font
title_text.align = "center"
title_text.valign = "center"

client.connect_signal("focus", function(c)
    local title_temp = "-"
    if c.name then title_temp = c.name else title_temp = c.class end
    title_text.markup = helpers.colorize_text(title_temp, beautiful.xcolor1)
end)

local title_box = create_box({helpers.horizontal_pad(bar_hopad), title_text, helpers.horizontal_pad(bar_hopad), layout=wibox.layout.align.horizontal}, 3000)

--}}}

--{{{ mpd

local mpd_text = wibox.widget.textbox("")
mpd_text.font = bar_font
mpd_text.align = "center"
mpd_text.valign = "center"

awesome.connect_signal("evil::mpd", function(artist, title, paused)
    if not paused then 
        mpd_text.markup = helpers.colorize_text("♫ ", beautiful.xcolor5) .. "\"" .. helpers.colorize_text(title, beautiful.xcolor3) .. "\" by " .. helpers.colorize_text(artist, beautiful.xcolor4)
    else
        mpd_text.markup = helpers.colorize_text("♫ \"" .. title .. "\" by " .. artist, beautiful.xcolor8)
    end
end)

local mpd_box = create_box({helpers.horizontal_pad(bar_hopad), mpd_text, helpers.horizontal_pad(bar_hopad), layout = wibox.layout.align.horizontal}, 400)

helpers.add_hover_cursor(mpd_box, "hand1")
mpd_box:buttons(gears.table.join(
    awful.button({  }, 1, function() awful.spawn.with_shell("mpc toggle") end),
    awful.button({  }, 4, function() awful.spawn.with_shell("mpc next") end),
    awful.button({  }, 5, function() awful.spawn.with_shell("mpc prev") end)
))

--}}}

--{{{
local werbung = wibox.widget.textbox("Hier könnte ihre Werbung stehen")
werbung.font = bar_font
werbung.align = "center"
werbung.valign = "center"

local placeholder_box = create_box({
    helpers.horizontal_pad(bar_hopad),
    werbung,
    helpers.horizontal_pad(bar_hopad),
    layout = wibox.layout.align.horizontal
}, 3600)

placeholder_box:connect_signal("mouse::enter", function() awesome.emit_signal("toggle::sidebar") end)
-- placeholder_box:connect_signal("mouse::leave", function() awesome.emit_signal("toggle::sidebar") end)
--}}}

--{{{ taglist buttons
--
local taglist_buttons = gears.table.join(
    awful.button({  }, 1, function(t) t:view_only() end),
    awful.button({  }, 3, awful.tag.viewtoggle),
    awful.button({  }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({  }, 5, function(t) awful.tag.viewprev(t.screen) end)
) 

--}}}

awful.screen.connect_for_each_screen(function(s)
    -- Create promptbox
    s.mypromptbox = awful.widget.prompt()

    -- Create systray box with promptbox in it

    local systray_wid = wibox.widget.systray()
    -- systray_wid:set_base_size(10)
    
    local systray_box = create_box({
        layout = wibox.layout.fixed.horizontal,
        helpers.horizontal_pad(5),
        systray_wid,
        s.mypromptbox,
        helpers.horizontal_pad(5)
    })

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style = {shape = gears.shape.rectangle},
        layout = {spacing = 0, layout = wibox.layout.fixed.horizontal},
        widget_template = {
            {
                {
                    {id = 'text_role', widget = wibox.widget.textbox},
                    layout = wibox.layout.fixed.horizontal
                },
                left = 11,
                right = 11,
                top = 1,
                shape = helpers.rrect(beautiful.border_radius),
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background
        },
        buttons = taglist_buttons
    }

    helpers.add_hover_cursor(s.mytaglist, "hand1")

    s.mywibox = awful.wibar({
        position = bar_position, 
        screen = s, 
        height = bar_height, 
        bg = secondary_bg, 
        ontop = true, 
        opacity = 1
    })

    -- Add widgets to the wibox
    s.mywibox:setup{
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            -- helpers.horizontal_pad(2 * beautiful.useless_gap),
            create_box({helpers.horizontal_pad(bar_hopad), s.mytaglist, helpers.horizontal_pad(bar_hopad), layout=wibox.layout.align.horizontal}),
            diverse_box,
            title_box,
            layout = wibox.layout.fixed.horizontal
        },
        time_box,
        {
            mpd_box,
            systray_box,
            placeholder_box,
            helpers.horizontal_pad(2 * beautiful.useless_gap),
            layout = wibox.layout.fixed.horizontal
        }
    }

    awesome.connect_signal("toggle::bar", function()
        s.mywibox.visible = not s.mywibox.visible
    end)

    -- awesome.emit_signal("toggle::bar")
end)

