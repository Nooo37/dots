pcall(require, "luarocks.loader") -- seems to be standard
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful") 

awful.spawn.with_shell("$HOME/code/dots/scripts/autostart")

beautiful.init(require("theme")) -- intialize the theme

awful.util.tagnames = {"1", "2"} -- declare tag names

require("module.no_single_client_round_corners")
require("module.sloppy_focus")
require("module.error_handling")

--{{{ bling
local bling = require("bling")
bling.module.flash_focus.enable()
-- bling.module.window_swallowing.start()
--}}}

--{{{ Layouts
local machi = require("module.machi")
beautiful.layout_machi = machi.get_icon()
local editor = machi.editor.create()

awful.layout.layouts = {
    awful.layout.suit.tile,
    bling.layout.mstab,
    bling.layout.centered,
    -- machi.default_layout,
    -- bling.layout.horizontal,
    bling.layout.vertical,
    awful.layout.suit.floating,
    awful.layout.suit.max
}
awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
--}}}

--{{{ require
require("signal")({"volume", "mpd", "temp", "cpu", "ram", "newsboat", "disk", "weather", "brightness_desktop"})
require("ui.bar.fragmented")
require("ui.dashboard.vertical_round")
require("ui.popup.layout_box")
require("ui.popup.volume_adjust")
require("ui.popup.mpd_notify")
--}}}


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    {
        rule = { },  -- All clients will match this rule.
        properties = {
	     border_width = beautiful.border_width or 0,
             border_color = beautiful.border_normal or "#000000",
             focus = awful.client.focus.filter,
             raise = true,
             keys = clientkeys,
             buttons = clientbuttons,
             screen = awful.screen.preferred,
             placement = awful.placement.no_overlap+awful.placement.no_offscreen
	}
    },

    {
        rule_any = { type = {"normal", "dialog"} },
        properties = { ontop = true }
    },          

    {
        rule_any = { instance = { "scratch" } },
        properties = { floating = true, placement=awful.placement.centered },
        callback = require("ui.titlebar.scratchpad")
    },
}
-- }}}


---{{{ on client spawn
client.connect_signal("manage",function(c)
    if not awesome.startup then
        awful.client.setslave(c) -- all clients spawn as slave
    end
    if c.class == "aw-qt" then -- close that weird aw-qt window for me please
        c:kill()
    end 
end)
---}}}

---{{{ Notify when cpu temp rises above 65°C
awesome.connect_signal("evil::temp", function(temp)
    if temp > 65 then
        naughty.notify({title="[!] CPU is getting hot", text="Currently at " .. tostring(temp) .. "°C"})
    end
end)
---}}}

--{{{ numered tagnames
local function update_tagnames()
    local tags = awful.screen.focused().tags
    for idx, tag in ipairs(tags) do
        tag.name = tostring(idx)
    end
end
tag.connect_signal("property::selected", update_tagnames)
--}}}

--{{{ needed doing scratchpad and "launch or focus" for sxhkd keybinds
local scratchpad = require("module.scratchpad")

awesome.connect_signal("toggle::scratchpad", function()
    scratchpad.toggle("alacritty --class scratchpad", {instance = "scratch"})
end)

local function launch_or_focus(application)
    -- if the appication is already open, focus it otherwise open an instance
    local is_app = function(c)
        return awful.rules.match(c, {instance = application}) or awful.rules.match(c, {class = application})
    end
    for c in awful.client.iterate(is_app) do
        if c.first_tag then 
            c.first_tag:view_only()
            client.focus = c
            return
        elseif c.bling_tabbed then 
            local tabobj = c.bling_tabbed
            local tag = tabobj.clients[tabobj.focused_idx].first_tag
            tag:view_only()
            client.focus = tabobj.clients[tabobj.focused_idx]
            bling.module.tabbed.iter()
            launch_or_focus(application)
            return
        end
    end
    awful.util.spawn(application)
end

awesome.connect_signal("launch_or_focus", launch_or_focus)
--}}}

--{{{ Essentially just backup keybinds when sxhkd fails
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local hotkeys_popup = require("awful.hotkeys_popup").widget
local modkey       = "Mod4"

globalkeys = my_table.join(
   awful.key({ modkey,           }, "ü", function() awful.util.spawn(beautiful.terminal:lower() or "xterm") end,
              {description = "launch terminal", group = "launch"}),
   awful.key({ modkey,           }, "s", hotkeys_popup.show_help,
              {description = "show help", group="awesome"})
)

root.keys(globalkeys)
--}}}

--{{{ start with bar disabled
awesome.emit_signal("toggle::bar")
--}}}

