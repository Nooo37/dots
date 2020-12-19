-- Provides:
-- evil::disk
--      used (integer - giga bytes)
--      total (integer - giga bytes)

local awful = require("awful")

local update_interval = 60*60*3 -- every 3 hours

-- Use /dev/sdxY according to your setup
local disk_script = [[
    bash -c "
    df -kh /dev/nvme0n1p2 | tail -1 | awk '{printf "%d@%d", $4, $3}'
    "
]]

local function update_widget(disk_space)
    disk.markup = disk_space .. "B free"
end

-- Periodically get disk space info
awful.widget.watch(disk_script, update_interval, function(_, stdout)
    -- Get `available` and `used` instead of `used` and `total`,
    -- since the total size reported by the `df` command includes
    -- the 5% storage reserved for `root`, which is misleading.
    -- my try

    local handle = io.popen("df -kh /dev/nvme0n1p2 | tail -1 | awk '{printf \"%d@%d\", $4, $3}'")
    local result = handle:read("*a")
    handle:close()

    --

    local available = result:match('^(.*)@') --stdout:match('^(.*)at')
    local used = result:match('@(.*)$')  --stdout:match('at^(.*)$')
    awesome.emit_signal("evil::disk", tonumber(used), tonumber(available) + tonumber(used))
end)
