-- MODULE no_single_client_borders
-- remove borders when there is only one client / the focused client is maximized

-- Requires the following properties
--    beautiful.border_width
--    beautiful,border_normal
--    beautiful.border_focus

local awful = require("awful")
local beautiful = require("beautiful")

local border_width  = beautiful.border_width  or 2
local border_normal = beautiful.border_normal or "#cccccc"
local border_focus  = beautiful.border_focus  or "#ff0000"

function border_adjust(c)
    if c.maximized or c.first_tag.layout.name == "max" then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused().clients == 1 then
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
end

client.connect_signal("focus", border_adjust)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
