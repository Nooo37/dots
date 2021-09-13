-- WARNING You do have to change the grep command that is used to use that daemon
-- TODO output of free is affected by system language. The following command
-- works for any language:
-- free -m | sed -n '2p' | awk '{printf "%d available out of %d\n", $7, $2}'

-- Provides:
-- evil::ram
--      used (integer - mega bytes)
--      total (integer - mega bytes)

local awful = require("awful")

local update_interval = 5
-- Returns the used amount of ram in percentage

local ram_script = [[
  sh -c "
  free | grep 'Speicher:' | awk '{printf \"%d@@%d@\", $7, $2}'
"]]

-- Periodically get ram info
awful.widget.watch(ram_script, update_interval, function(_, stdout)
    local available = stdout:match('(.*)@@')
    local total = stdout:match('@@(.*)@')
    if tonumber(available) ~= nil and tonumber(total) ~= nil then
      local used = math.floor((tonumber(total) - tonumber(available))/1000)
      awesome.emit_signal("evil::ram", used, math.floor(tonumber(total)/1000))
    end
end)
