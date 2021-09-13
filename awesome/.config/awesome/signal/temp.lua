-- Provides:
-- evil::temp
--      temperature (integer)

-- dependencies: sensors

awful = require("awful")

local update_interval = 5
local temp_script = [[
bash -c "
sensors | grep Tdie.*C | tr -d 'Tdie:+C°' | tr -d ' '
"]]

awful.widget.watch(temp_script, update_interval, function(_, stdout)
  awesome.emit_signal("evil::temp", tonumber(stdout))
end)
