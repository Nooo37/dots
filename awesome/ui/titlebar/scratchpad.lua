-- Special thanks to elenapan
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local toolbar_position = "bottom"
local toolbar_size = dpi(40)
local toolbar_bg = beautiful.xcolor0
local toolbar_font = beautiful.toolbar_font or beautiful.font or "Mono 12"
local toolbar_fg = beautiful.xcolor4 
local toolbar_enabled_initially = true

local terminal_has_to_move_after_resizing = {["scratch-term"] = true}


local create_scratchpad_titlebar_deco = function(c)
    awful.titlebar(c, {
        position = toolbar_position,
        size = toolbar_size,
        bg = toolbar_bg,
        fg = toolbar_fg,
    }):setup{
        {
                    {
                        {
                          text = "Scratchpad",
                          widget = wibox.widget.textbox,
                          valign = "center",
                          font = toolbar_font,
                        },
                        left = dpi(5),
                        right = dpi(5),
                        bottom = dpi(5),
                        top = dpi(5),
                        layout = wibox.container.margin
                    },
                    layout = wibox.layout.fixed.horizontal
        },
        valign = "center",
        layout = wibox.container.place
    }

    if not toolbar_enabled_initially then
        awful.titlebar.hide(c, toolbar_position)
    end

    c.custom_decoration = {bottom = true}
end

-- -- Didn't get that working so I'll pass the function and care about it in rc.lua
-- table.insert(awful.rules.rules, {
--     rule_any = {instance = { "scratch-term" } },
--     properties = {},
--     callback = spot_create_decoration
-- })

return create_scratchpad_titlebar_deco
