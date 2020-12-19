local beautiful = require("beautiful")
local wibox = require("wibox")
local c_slider = require("ui.widget.slider")
local awful = require("awful")

local creator = {}

creator.create = function(fg_color, bg_color)
  local mat_slider = c_slider.create(fg_color, bg_color)
  local slider =
    wibox.widget {
    read_only = false,
    widget = mat_slider
  }

  slider:connect_signal('property::value', function()
      local handle = io.popen([[mpc | grep -o \(.*\) | tr -d "(%)"]])
      local current_percentage = handle:read("*a")
      handle:close()
      -- local n = require("naughty")
      -- n.notify({text="CP: "..tostring(current_percentage), title="SV: ".. tostring(slider.value)})

      current_percentage = tonumber(current_percentage)
      if current_percentage ~= nil then
        -- the following condition exists because otherwise it microjumps back all the time
        -- try it yourself and delete the condition if you dare to :)
        if slider.value > (current_percentage + 2) or slider.value < (current_percentage - 2) then
          awful.util.spawn_with_shell('mpc seek ' .. tostring(slider.value) .. '%')
          -- local n = require("naughty")
          -- n.notify({text=tostring(slider.value)})
        end
      end
  end)

  awesome.connect_signal("evil::mpd_passed",
    function(percentage)
      if tonumber(percentage) ~= nil then
        slider:set_value(tonumber(percentage)/1.001)
        collectgarbage('collect')
      end
  end)

  return slider
end

return creator
