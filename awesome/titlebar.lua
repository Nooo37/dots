local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local awesome, client, mouse = awesome, client, mouse

local helpers = require("helpers")
local titlebar_height = dpi(40)
local titlebar_bg_primary = beautiful.xbg
local titlebar_bg_secondary = beautiful.xbg2

local function shape_arc_thingy_left(cr, width, height)
                local radius = width < height and width / 2 or height / 2
                cr:arc(width - radius, height - radius, radius, math.pi * 2, math.pi / 2)
                cr:line_to(width, height)
                cr:close_path()
end

local function shape_arc_thingy_right(cr, width, height)
                local radius = width < height and width / 2 or height / 2
                cr:arc(radius, height - radius, radius, math.pi / 2 , math.pi)
                cr:line_to(0, height)
                cr:close_path()
end

local function create_buttons(c)
        local function create_one_button(color, func)
                local temp_wid = wibox.widget {
                        wibox.widget.textbox(""),
                        shape = gears.shape.circle,
                        forced_width = dpi(10),
                        bg = color,
                        widget = wibox.container.background
                }
                temp_wid:buttons(gears.table.join(awful.button({ }, 1, func)))
                local old_cursor, old_wibox
                temp_wid:connect_signal("mouse::enter", function()
                        local wb = mouse.current_wibox
                        old_cursor, old_wibox = wb.cursor, wb
                        wb.cursor = "hand1"
                end)
                temp_wid:connect_signal("mouse::leave", function()
                        if old_wibox then
                                old_wibox.cursor = old_cursor
                                old_wibox = nil
                        end
                end)
                return temp_wid
        end

        local close_button = create_one_button(beautiful.xcolor1, function() c:kill() end)
        local max_button = create_one_button(beautiful.xcolor3, function() c.maximized = not c.maximized end)
        local min_button = create_one_button(beautiful.xcolor2, function() c.minimized = true end)

        return wibox.widget {
                helpers.horizontal_pad(dpi(12)),
                min_button,
                helpers.horizontal_pad(dpi(12)),
                max_button,
                helpers.horizontal_pad(dpi(12)),
                close_button,
                helpers.horizontal_pad(dpi(12)),
                layout = wibox.layout.fixed.horizontal
        }
end

local function create_thing(wid, bg)
        return wibox.widget {
                {
                        {
                                wibox.widget.textbox(""),
                                bg = bg,
                                shape = shape_arc_thingy_left,
                                forced_width = dpi(10),
                                widget = wibox.container.background
                        },
                        {
                                {
                                        helpers.horizontal_pad(dpi(3)),
                                        wid,
                                        helpers.horizontal_pad(dpi(3)),
                                        layout = wibox.layout.fixed.horizontal
                                },
                                bg = bg,
                                shape = helpers.prrect(dpi(10), true, true, false, false),
                                widget = wibox.container.background
                        },
                        {
                                wibox.widget.textbox(""),
                                bg = bg,
                                shape = shape_arc_thingy_right,
                                forced_width = dpi(10),
                                widget = wibox.container.background
                        },
                        layout = wibox.layout.fixed.horizontal
                },
                top   = dpi(6),
                -- left  = dpi(6),
                right = - dpi(6),
                widget = wibox.container.margin
        }
end

local function create_thing_icon(c, ...)
        return create_thing({
                {
                        client = c,
                        widget = awful.widget.clienticon,
                },
                widget = wibox.container.margin,
                margins = dpi(10),
        }, ...)
end

client.connect_signal("request::titlebars", function(c)
        local buttons = gears.table.join(
                awful.button( {}, 1, function()
                        c:emit_signal("request::activate", "titlebar", {raise = true})
                        awful.mouse.client.move(c)
                    end),
                awful.button( {}, 3, function()
                        c:emit_signal("request::activate", "titlebar", {raise = true})
                        awful.mouse.client.resize(c)
                    end)
        )

        local tabbed_icons = wibox.widget {
        	layout = wibox.layout.fixed.horizontal,
        	spacing = dpi(4),
        }


        tabbed_icons:add(create_thing_icon(c, titlebar_bg_primary))

        awful.titlebar(c, {
                position = "top",
                size = titlebar_height,
                bg = titlebar_bg_secondary,
                fg = beautiful.xfg,
        }):setup{
                {
                        helpers.horizontal_pad(dpi(9)),
                        tabbed_icons,
                        layout = wibox.layout.fixed.horizontal
                },
                {
                        wibox.widget.textbox(""),
                        buttons = buttons,
                        expand = "none",
                        layout = wibox.layout.flex.horizontal
                },
                {
                        create_thing(
                                create_buttons(c),
                                titlebar_bg_primary
                        ),
                        helpers.horizontal_pad(dpi(9)),
                        layout = wibox.layout.fixed.horizontal
                },
                layout = wibox.layout.align.horizontal
        }

        local function contains(t, v)
                for _, u in ipairs(t) do
                        if u == v then return true end
                end
                return false
        end

        awesome.connect_signal("bling::tabbed::update", function(group)
        	local focused = group.clients[group.focused_idx]
        	if contains(group.clients, c) then
        		tabbed_icons:reset()
        		for _, ct in ipairs(group.clients) do
        			tabbed_icons:add(create_thing_icon(ct,
                                        ct == focused and titlebar_bg_primary or "alpha"))
        		end
        	end
        end)
end)

