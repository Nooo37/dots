-- my awesome config

pcall(require, "luarocks.loader") -- seems to be standard
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful")
local helpers = require("ui.helpers")

awful.spawn.with_shell("$HOME/code/dots/scripts/autostart")

beautiful.init(require("theme")) -- intialize the theme

awful.util.tagnames = {"1", "2", "web"} -- declare tag names

require("bad") -- everything except for that require statement is 4.3 compatible

require("module.sloppy_focus")
require("module.error_handling")

--{{{ bling
local bling = require("bling")
bling.module.flash_focus.enable()
-- bling.module.window_swallowing.start()

-- bling.module.wallpaper.setup {                             
--     change_timer = 1000,                      
--     set_function = bling.module.wallpaper.setters.random,
--     wallpaper = { "~/pics/wallpapers/" },  
--     recursive = false, 
--     position = "maximized",                   
-- }

--}}}

--{{{ Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    bling.layout.mstab,
    bling.layout.centered,
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

-- keybinds to resize clients (will be applied later)
local modkey       = "Mod4"
local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

awful.rules.rules = {
    {
        rule = { },  -- All clients will match this rule.
        properties = {
	     -- border_width = beautiful.border_width or 0,
             -- border_color = beautiful.border_normal or "#000000",
             focus = awful.client.focus.filter,

             raise = true,
             keys = clientkeys,
             buttons = clientbuttons,
             screen = awful.screen.preferred,
             titlebars_enabled = true,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
	    }
    },

    {rule_any = {type = {"normal"}}, properties = {titlebars_enabled = true}},

    {
        rule_any = { type = {"normal", "dialog"} },
        properties = { ontop = true }
    },          

    {
        rule_any = { instance = { "scratchpad" } },
        properties = { floating = true, placement = awful.placement.centered },
        callback = require("ui.titlebar.scratchpad"),
    },
    {
        rule_any = { instance = { "scratchmusic" } },
        properties = { floating = true, x = 460, y = 750, height = 300, width = 1000 },
    },
    {
        rule_any = { instance = { "discord" } },
        properties = { floating = true, x = 460, y = 140, height = 800, width = 1000 }
    },
    {
       rule = { instance = "brave-browser" },
       properties = { tag = "web", screen = 1, switchtotag = true }
    }
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

--{{{ needed doing scratchpad and "launch or focus" for sxhkd keybinds
local scratchpad = require("module.scratchpad")

awesome.connect_signal("toggle::scratchpad", function()
    scratchpad.toggle("alacritty --class scratchpad", {instance = "scratchpad"}, true)
end)

awesome.connect_signal("toggle::scratchmusic", function()
    scratchpad.toggle("alacritty --class scratchmusic -e $HOME/.config/ncmpcpp/ncmpcpp-ueberzug/ncmpcpp-ueberzug", {instance = "scratchmusic"}, true)
end)

awesome.connect_signal("toggle::scratchdiscord", function()
    scratchpad.toggle("discord", {instance = "discord"}, false)
end)

local function launch_or_focus(application)
    -- if the appication is already open, focus it otherwise open an instance
    local is_app = function(c)
        return awful.rules.match(c, {instance = application}) or awful.rules.match(c, {class = application})
    end
    for c in awful.client.iterate(is_app) do
        if c.first_tag then 
            c.minimized = false
            c.first_tag:view_only()
            client.focus = c
            c:raise()
            return
        elseif c.bling_tabbed then 
            local tabobj = c.bling_tabbed
            local tag = tabobj.clients[tabobj.focused_idx].first_tag
            tag:view_only()
            tabobj.clients[tabobj.focused_idx].minimized = false
            client.focus = tabobj.clients[tabobj.focused_idx]
            client.focus:raise()
            bling.module.tabbed.iter()
            launch_or_focus(application) -- recurisve :flushed:
            return
        end
    end
    awful.util.spawn(application)
end

awesome.connect_signal("launch_or_focus", launch_or_focus)
--}}}

--{{{ Essentially just backup keybinds, should sxhkd fails
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local hotkeys_popup = require("awful.hotkeys_popup").widget

local globalkeys = my_table.join(
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


--{{{ Experimenting with stuff
local function create_icon(icon, fg) 
    local btn_thing = wibox.widget.textbox("")
    btn_thing.align = "center"
    btn_thing.valign = "center"
    btn_thing.font = "JetBrainsMono Nerd Font 8"
    btn_thing.markup = helpers.colorize_text(icon, fg)
    return btn_thing
end

local function create_btn(icon, fg, bg)
   local btn_icon = create_icon(icon, fg)
   
end

client.connect_signal("manage", function(c)
    if c.class ~= "Alacritty" or not c.floating then return end
    local btn_radius = 15

    local btn_minimize = wibox({
          screen = awful.screen.focused(),
          x = c.x,
          y = c.y,
          width = 2 * btn_radius,
          height = 2 * btn_radius,
          shape = gears.shape.circle,
          bg = beautiful.xcolor0,
          ontop = true,
          visible = true
    })

    local btn_maximize = wibox({
          screen = awful.screen.focused(),
          x = c.x,
          y = c.y,
          width = 2 * btn_radius,
          height = 2 * btn_radius,
          shape = gears.shape.circle,
          bg = beautiful.xcolor0,
          ontop = true,
          visible = true
    })

    local btn_close = wibox({
          screen = awful.screen.focused(),
          x = c.x,
          y = c.y,
          width = 2 * btn_radius,
          height = 2 * btn_radius,
          shape = gears.shape.circle,
          bg = beautiful.xcolor0,
          ontop = true,
          visible = true
    })

    local icon_minimize = create_icon("絛", beautiful.xcolor3)
    local icon_maximize = create_icon("", beautiful.xcolor4)
    local icon_close    = create_icon("", beautiful.xcolor1)
    
    btn_minimize:setup { layout = wibox.layout.align.vertical, nil, icon_minimize, nil }
    btn_maximize:setup { layout = wibox.layout.align.vertical, nil, icon_maximize, nil }
    btn_close:setup    { layout = wibox.layout.align.vertical, nil, icon_close, nil }

    function adjust_titlebox()
       btn_minimize.x = c.x + c.width - 9 * btn_radius
       btn_minimize.y = c.y - 0.75 * btn_radius
       btn_maximize.x = c.x + c.width - 6 * btn_radius
       btn_maximize.y = c.y - 0.75 * btn_radius
       btn_close.x = c.x + c.width - 3 * btn_radius
       btn_close.y = c.y - 0.75 * btn_radius
    end

    adjust_titlebox()
    
    c:connect_signal("property::position", adjust_titlebox)
    c:connect_signal("property::size", adjust_titlebox)

    c:connect_signal("unfocus", function()
                        btn_minimize.visible = false
                        btn_maximize.visible = false
                        btn_close.visible = false
    end)
    c:connect_signal("focus", function()
                        btn_minimize.visible = true
                        btn_maximize.visible = true
                        btn_close.visible = true
    end)
    c:connect_signal("unmanage", function()
                        btn_minimize.visible = false
                        btn_minimize = nil
                        btn_maximize = nil
                        btn_close = nil
    end)
end)
--}}}


