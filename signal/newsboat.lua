-- Provides:
-- evil::newsboat
--      unread_items (integer)

local awful = require("awful")

local update_interval = 60*30
local brightness_script = [[
   bash -c "
   python $HOME/code/python/newsboat_notify.py
"]]

-- take a look here ^^
-- https://github.com/Nooo37/pynewsboat

local old_unread_items
awful.widget.watch(brightness_script, update_interval, function(_, stdout)
  local unread_items = tonumber(stdout)
  if unread_items ~= old_unread_items then
    awesome.emit_signal("evil::newsboat", unread_items)
    old_unread_items = unread_items
  end
end)
