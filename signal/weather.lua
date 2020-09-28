-- Provides:
-- evil::weather
--      emote (string - emoji for weather)
--      temp (integer - temperatur in °C)
--      wind (integer - wind velocity in km/h)

local awful = require("awful")
local beautiful = require("beautiful")

local city = beautiful.weather_city or "Berlin"

local update_interval = 180 -- every 3 minutes

-- Use /dev/sdxY according to your setup
local disk_script = [[
    sh -c '
    wttr_str=`curl wttr.in/]] .. city .. [[?format=2`
    g=`echo $wttr_str`
    emoji=`echo "$g"| awk {print $2}`
    echo $emoji
    '
]]
-- emoji=`echo $wGhearmailtttr_str | awk '{print $1}'`
-- temp=`echo $wttr_str | awk '{print $2}'`
-- wind=`echo $wttr_str | awk '{print $3}'`
-- echo $emoji

-- Periodically get disk space info
awful.widget.watch(disk_script, update_interval, function(_, stdout)
  require("naughty").notify({title=stdout})
end)
