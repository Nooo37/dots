-- my awesome config

pcall(require, "luarocks.loader") -- seems to be standard
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful")

beautiful.init(require("theme")) -- intialize the theme
awful.util.tagnames = {"1", "2"} -- declare tag names

---{{{ require
require("signal") {"volume", "mpd", "temp", "cpu", "ram", "newsboat",
                   "disk", "weather", "brightness_desktop", "battery"}
require("ui.bar.vertical_endgame")
require("ui.dashboard.vertical_round")
require("ui.popup.layout_box")
require("ui.popup.volume_adjust")
require("bad") -- everything except for that require statement is 4.3 compatible
---}}}

---{{{ bling
local bling = require("bling")
bling.module.flash_focus.enable()
bling.signal.playerctl.enable()
-- bling.module.window_swallowing.start()

awesome.connect_signal("bling::playerctl::title_artist_album",
                       function(title, artist, album)
                           naughty.notify {
                               title=tostring(title),
                               text=tostring(artist),
                               icon=tostring(album)
                           }
end)

awful.screen.connect_for_each_screen(function(s)  
    bling.module.tiled_wallpaper("", s, {
        fg = beautiful.xcolor0,
        bg = beautiful.xbg,
        offset_y = 25,
        offset_x = 25,
        font = "JetBrainsMono NF",
        font_size = 30,
        padding = 100,
        zickzack = true
    })
end)

-- all my scratchpads
local awestore = require("awestore")
local anim_y = awestore.tweened(1100, {
    duration = 200,
    easing = awestore.easing.cubic_in_out
})

local anim_y1 = awestore.tweened(1100, {
    duration = 200,
    easing = awestore.easing.cubic_in_out
})

local anim_y2 = awestore.tweened(1100, {
    duration = 200,
    easing = awestore.easing.cubic_in_out
})

local anim_x = awestore.tweened(1920, {
    duration = 200,
    easing = awestore.easing.cubic_in_out
})

local term_scratch = bling.module.scratchpad:new { command = "wezterm start --class spad",
                                      rule = { instance = "spad" },
                                      sticky=false, autoclose=false, floating=false, 
                                      geometry={x=360, y=90, height=900, width=1200},
}
awesome.connect_signal("toggle::scratchpad", function() term_scratch:toggle() end)

local webs_scratch = bling.module.scratchpad:new { command = "brave",
                                      rule = { instance = "brave-browser" },
                                      sticky=false, autoclose=false, floating=false,
}
awesome.connect_signal("toggle::webs", function() webs_scratch:toggle() end)

local disc_scratch = bling.module.scratchpad:new { command = "discord",
                                      rule = { instance = "discord" },
                                      sticky=false, autoclose=false, floating=true, retarded=true,
                                      geometry={x=360, y=90, height=900, width=1200},
                                      reapply=true,
                                      awestore={y=anim_y1},
}
awesome.connect_signal("toggle::discord", function() disc_scratch:toggle() end)

local music_scratch = bling.module.scratchpad:new{ command = "deadbeef",
                                      rule = { instance = "deadbeef" },
                                      sticky=true, autoclose=true,
                                      floating=true, reapply=true,
                                      geometry={x=460, y=750, height=300, width=1000},
                                      reapply=true,
                                      awestore={x=anim_x2, y=anim_y2},
}
awesome.connect_signal("toggle::music", function() music_scratch:toggle() end)

local emacs_scratch = bling.module.scratchpad:new{ command = "emacs --name emacsscratch",
                                      rule = { instance = "emacsscratch" },
                                      sticky=false, autoclose=false, floating=true,
                                      geometry={x=360, y=90, height=900, width=1200},
                                      -- awestore={y=anim_y2},
}
awesome.connect_signal("toggle::emacsscratch", function() emacs_scratch:toggle() end)
---}}}

---{{{ Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    bling.layout.mstab,
    bling.layout.vertical,
    bling.layout.equalarea,
    bling.layout.centered,
    awful.layout.suit.floating,
    awful.layout.suit.max
}
awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
---}}}

---{{{ Rules
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
        rule = { }, -- Whitelisting tiling applications
        except_any = { 
            instance = { 
                "org.gnome.Nautilus", "evince", "zathura",
                "emacs", "org.wezfurlong.wezterm", "Alacritty", "urxvt",
                "brave-browser", "Firefox", "chromium",
            } 
        },
        properties = { floating = true }
    },
    {
        rule = { },  -- All clients will match this rule.
        properties = {
            focus = awful.client.focus.filter,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            titlebars_enabled = false,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen +
                awful.placement.centered
        },
        callback = awful.client.setslave
    },
    -- {
        -- rule_any = { instance = { "spad" } },
        -- properties = { floating = true, placement = awful.placement.centered },
        -- callback = require("ui.titlebar.scratchpad"),
    -- },
    {
        rule_any = { instance = { "consoom" } },
        properties = { placement = awful.placement.bottom_right }
    },
}
---}}}

---{{{ on client spawn
client.connect_signal("manage",function(c)
    if c.class == "aw-qt" then c:kill() end
end)
---}}}

---{{{ rounded corners but not on maximized clienta
local function is_maximized(c)
    local function _fills_screen()
        local wa = c.screen.workarea
        local cg = c:geometry()
        return wa.x == cg.x and wa.y == cg.y and wa.width == cg.width and
            wa.height == cg.height
    end
    return c.maximized or (not c.floating and _fills_screen())
end


local function update_geo(c)
    if is_maximized(c) then
        c.shape = function(cr,w,h)
            gears.shape.rounded_rect(cr,w,h,0)
        end
    else
        c.shape = function(cr,w,h)
           gears.shape.rounded_rect(cr,w,h, beautiful.border_radius or 0)
        end
    end
end

client.connect_signal("property::geometry", update_geo)
---}}}

---{{{ Notify when cpu temp rises above 65°C
awesome.connect_signal("evil::temp", function(temp)
    if temp > 65 then
        naughty.notify {title="[!] CPU is getting hot",
                        text="Currently at " .. tostring(temp) .. "°C"}
    end
end)
---}}}

---{{{ "launch or focus" for sxhkd keybinds
local function launch_or_focus(application)
    -- if the appication is already open, focus it otherwise open an instance
    local is_app = function(c)
        return awful.rules.match(c, {instance = application}) or
            awful.rules.match(c, {class = application})
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

-- a backup keybind, should sxhkd fail
root.keys { awful.key({ modkey,           }, "p",
                function() awful.util.spawn("alacritty") end,
              {description = "launch terminal", group = "launch"}) }
---}}}

--{{{ sloppy focus
client.connect_signal("mouse::enter", function(c)
                          c:emit_signal("request::activate", "mouse_enter",
                                        {raise = false})
end)
--}}}

awful.spawn.with_shell("$HOME/code/dots/scripts/autostart") -- autostart script

-- collectgarbage("setpause", 160)
-- collectgarbage("setstepmul", 400)
-- awesome.connect_signal("refresh", function() collectgarbage("collect") end)
