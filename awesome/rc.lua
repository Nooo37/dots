-- my awesome config

pcall(require, "luarocks.loader")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local awesome = awesome

require("awful.autofocus")

beautiful.init(require("theme")) -- intialize the theme
require("bar")
require("titlebar")
require("rules")
require("popup_layout")
require("popup_volume")
require("signal") { "volume", "temp", "cpu", "disk", "ram", "weather" } -- "mpd", "newsboat"
require("bling") -- my bling configs (ie scratchpads, previews etc)
if awesome.version ~= "v4.3" then require("notif") end -- everything except for that require is 4.3 compatible

if beautiful.is_on_pc then -- on desktop
    require("signal") {"brightness_desktop"}
else -- on laptop
    require("signal") {"battery", "brightness_laptop"}
end

-- initalize layouts, tags
local bling = require("module.bling")
awful.util.tagnames = {"1", "2"} -- declare tag names
awful.layout.layouts = {
    awful.layout.suit.tile,
    bling.layout.mstab,
    bling.layout.equalarea,
    bling.layout.centered,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}
awful.screen.connect_for_each_screen(function(s)
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
end)

-- call autostart script
awful.spawn.with_shell("$HOME/code/dots/scripts/autostart")

--- Notify when cpu temp rises above 65°C
awesome.connect_signal("evil::temp", function(temp)
    if temp > 65 then
        naughty.notify {title="[!] CPU is getting hot",
                        text="Currently at " .. tostring(temp) .. "°C"}
    end
end)

--- Notify on music change
local last_notify = {}
awesome.connect_signal("bling::playerctl::title_artist_album", function(title, artist, album)
    last_notify = naughty.notify {
      title=tostring(title),
      text=tostring(artist),
      icon = gears.surface.load_uncached_silently(album),
      timeout=2,
      replaces_id=last_notify.id,
    }
end)

-- awful.spawn("alacritty")
