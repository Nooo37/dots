local beautiful = require("beautiful")
local wibox = require("wibox")
local c_slider = require("ui.widget.slider")
local awful = require("awful")

local creator = {}

creator.create = function(fg_color, bg_color)

  mat_slider = c_slider.create(fg_color, bg_color)

  local slider =
    wibox.widget {
    read_only = false,
    widget = mat_slider
  }

  slider:connect_signal('property::value', function()
      awful.util.spawn_with_shell('amixer -D pulse sset Master ' .. tostring(slider.value) .. '%')
  end)

  awesome.connect_signal("evil::volume",
    function(volume, mute)
      slider:set_value(tonumber(volume))
      collectgarbage('collect')
    end
  )

  return slider

end

return creator
