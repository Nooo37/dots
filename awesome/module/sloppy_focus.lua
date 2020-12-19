-- MODULE sloppy_focus
-- Enable sloppy focus, so that focus follows mouse.

local beautiful = require("beautiful")

client.connect_signal("mouse::enter", function(c)
                        c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
