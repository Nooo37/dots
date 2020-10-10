local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local helpers = require("ui.helpers")

local titlebar_size = beautiful.titlebar_size or 20

local separators = { height = 0, width = 9 }

-- [[ Arrow
  -- Right
function separators.arrow_right(col1, col2)
    local widget = wibox.widget.base.make_widget()
    widget.col1 = col1
    widget.col2 = col2
    widget.fit = function(m, w, h)
        return separators.width, separators.height
    end

    widget.update = function(col1, col2)
        widget.col1 = col1
        widget.col2 = col2
        widget:emit_signal("widget::redraw_needed")
    end

    widget.draw = function(mycross, wibox, cr, width, height)
        if widget.col2 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(widget.col2))
            cr:new_path()
            cr:move_to(0, 0)
            cr:line_to(width, height/2)
            cr:line_to(width, 0)
            cr:close_path()
            cr:fill()

            cr:new_path()
            cr:move_to(0, height)
            cr:line_to(width, height/2)
            cr:line_to(width, height)
            cr:close_path()
            cr:fill()
        end

        if widget.col1 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(widget.col1))
            cr:new_path()
            cr:move_to(0, 0)
            cr:line_to(width, height/2)
            cr:line_to(0, height)
            cr:close_path()
            cr:fill()
        end
   end

   return widget
end

  -- Left
function separators.arrow_left(col1, col2)
    local widget = wibox.widget.base.make_widget()
    widget.col1 = col1
    widget.col2 = col2

    widget.fit = function(m, w, h)
        return separators.width, separators.height
    end

    widget.update = function(col1, col2)
        widget.col1 = col1
        widget.col2 = col2
        widget:emit_signal("widget::redraw_needed")
    end

    widget.draw = function(mycross, wibox, cr, width, height)
        if widget.col1 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(widget.col1))
            cr:new_path()
            cr:move_to(width, 0)
            cr:line_to(0, height/2)
            cr:line_to(0, 0)
            cr:close_path()
            cr:fill()

            cr:new_path()
            cr:move_to(width, height)
            cr:line_to(0, height/2)
            cr:line_to(0, height)
            cr:close_path()
            cr:fill()
        end

        if widget.col2 ~= "alpha" then
            cr:new_path()
            cr:move_to(width, 0)
            cr:line_to(0, height/2)
            cr:line_to(width, height)
            cr:close_path()

            cr:set_source_rgb(gears.color.parse_color(widget.col2))
            cr:fill()
        end
   end

   return widget
end

local arrow_left = separators.arrow_left
local arrow_right = separators.arrow_right

local function create_titlebar_button(fg_color)
    return wibox.widget {
            arrow_left("alpha", fg_color),
            arrow_left(fg_color, "alpha"),
            layout = wibox.layout.fixed.horizontal,
        }
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        if c.maximized == true then c.maximized = false end
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.resize(c)
    end))
    local borderbuttons = gears.table.join(
                              awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end), awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end))

    local close_btn = create_titlebar_button(beautiful.xcolor1)
    close_btn:connect_signal("button::press", function() c:kill() end)
    local maxi_btn = create_titlebar_button(beautiful.xcolor3)
    maxi_btn:connect_signal("button::press", function() c.maximized = not c.maximized end)
    local mini_btn = create_titlebar_button(beautiful.xcolor2)
    mini_btn:connect_signal("button::press", function() c.minimized = true end)


    awful.titlebar(c, {position = "top", size = titlebar_size, bg}):setup{
        { -- Left
            --            awful.titlebar.widget.iconwidget(c),
            helpers.horizontal_pad(dpi(15)),
            {
              text = c.name,
              font = "Sans 9",
              widget = wibox.widget.textbox,
            },
            arrow_right("alpha", beautiful.xcolor5),
            arrow_right(beautiful.xcolor5, "alpha"),
            layout = wibox.layout.fixed.horizontal
        },
        { -- Middle
            -- buttons = buttons,
            nil,
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            helpers.horizontal_pad(dpi(5)),
            mini_btn,
            helpers.horizontal_pad(dpi(5)),
            maxi_btn,
            helpers.horizontal_pad(dpi(5)),
            close_btn,

            helpers.horizontal_pad(dpi(5)),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)
