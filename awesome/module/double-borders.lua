local awful = require("awful")

local inner_border_size = 5

client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c, {position = "right", size = inner_border_size})
    awful.titlebar(c, {position = "left", size = inner_border_size})
    awful.titlebar(c, {position = "bottom", size = inner_border_size})
    awful.titlebar(c, {position = "top", size = inner_border_size})
end)
