-- TODO finish 

local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

local helpers = require("ui.helpers")

local corner_radius = beautiful.corner_radius or 0

local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 12">%d.%m.%Y</span>')
textclock.align = "center"
textclock.valign = "center"

local date_widget = wibox.container.margin(textclock, dpi(18), dpi(8), dpi(8), dpi(8))

local offsetx = dpi(128)
local offsety = dpi(12)
local s = awful.screen.focused()
local panel = wibox({
    ontop = true,
    visible = true,
    height = dpi(50),
    width = dpi(120),
    x = s.geometry.width - dpi(120) - offsety,
    y = s.geometry.y + offsety,
    stretch = false,
    bg = beautiful.xbg,
    fg = beautiful.xfg,
    shape = helpers.rrect(corner_radius)
    -- struts = {top = dpi(32)}
})

panel:setup{layout = wibox.layout.fixed.horizontal, date_widget}


-- awful.screen.connect_for_each_screen(function(s)
--   awful.wibar({ position = "top", screen = s, ontop = false, height = 0, bg = "#00000000",  visible=true })
-- end)
