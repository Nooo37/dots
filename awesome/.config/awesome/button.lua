local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awesome, mouse = awesome, mouse

local helpers = require("helpers")

local function get_icon_color()
    return beautiful.xfg
end

local function get_label_color()
    return beautiful.xcolor8
end

local function get_bg_color()
    return beautiful.xbg
end

local Button = {}

function Button:new(args)
    local o = {}
    o.sym = wibox.widget {
        markup = helpers.colorize_text(args.sym or "?", get_icon_color()),
        align = "center",
        valign = "center",
        font = "JetBrainsMono NF 20",
        widget = wibox.widget.textbox
    }
    o.button = wibox.widget {
        o.sym,
        bg = get_bg_color(),
        shape = args.shape or gears.shape.circle,
        expand = "outside",
        widget = wibox.container.background
    }
    o.label = wibox.widget {
        markup = helpers.colorize_text(args.label or "...?", get_label_color()),
        align = "center",
        valign = "center",
        font = "Sans 9",
        widget = wibox.widget.textbox
    }
    o.widget = wibox.widget {
        {
            o.button,
            forced_height = 50,
            forced_width = 50,
            widget = wibox.container.constraint
        },
        helpers.vertical_pad(5),
        o.label,
        layout = wibox.layout.fixed.vertical
    }
    o.button:connect_signal("mouse::enter", function(c)
        c:set_bg(get_label_color())
    end)
    o.button:connect_signal("mouse::leave", function(c)
        c:set_bg(beautiful.xbg)
    end)
    o.button:connect_signal("button::press", function(c)
        c:set_bg(beautiful.xcolor2)
    end)
    o.button:connect_signal("button::release", function(c)
        c:set_bg(get_label_color())
    end)
    awesome.connect_signal("chcolor", function()
        o.label.markup = helpers.colorize_text(o.label.text, get_label_color())
        o.sym.markup = helpers.colorize_text(o.sym.text, get_icon_color())
        o.button.bg = get_bg_color()
    end)
    setmetatable(o, self)
    self.__index = self
    return o
end


function Button:set_icon(icon)
    self.sym.markup = helpers.colorize_text(icon, get_icon_color())
end

function Button:set_label(label)
    self.label.markup = helpers.colorize_text(label, get_label_color())
end

function Button:on_click(func)
    self.widget:connect_signal("button::press", function(...)
        func(...)
    end)
end

return Button
