-- my awesome config

pcall(require, "luarocks.loader") -- seems to be standard
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful")
local helpers = require("ui.helpers")

beautiful.init(require("theme")) -- intialize the theme

awful.util.tagnames = {"1", "2"} -- declare tag names

require("bad") -- everything except for that require statement is 4.3 compatible

---{{{ error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

---}}}

---{{{ bling
local bling = require("bling")
bling.module.flash_focus.enable()
bling.signal.playerctl.enable()
bling.module.window_swallowing.start()

-- bling.module.wallpaper.setup {                             
--     change_timer = 1000,                      
--     set_function = bling.module.wallpaper.setters.random,
--     wallpaper = { "~/pics/wallpapers/" },  
--     recursive = false, 
--     position = "maximized",                   
-- }

---}}}

---{{{ Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    bling.layout.mstab,
    bling.layout.centered,
    -- bling.layout.horizontal,
    bling.layout.vertical,
    bling.layout.equalarea,
    -- awful.layout.suit.floating,
    awful.layout.suit.max
}
awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
---}}}

---{{{ require
require("signal")({"volume", "mpd", "temp", "cpu", "ram", "newsboat",
                   "disk", "weather", "brightness_desktop"})
require("ui.bar.fragmented")
require("ui.dashboard.vertical_round")
require("ui.popup.layout_box")
require("ui.popup.volume_adjust")
require("ui.popup.mpd_notify")
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
        },
        callback = awful.client.setslave
    },

    -- {rule_any = {type = {"normal"}}, properties = {titlebars_enabled = true}},

    {
        rule_any = { type = {"normal", "dialog"} },
        properties = { ontop = true }
    },          

    {
        rule_any = { instance = { "spad" } },
        properties = { floating = true, placement = awful.placement.centered },
        callback = require("ui.titlebar.scratchpad"),
    },
    {
        rule_any = { instance = { "smusic" } },
        properties = { floating = true, x = 460, y = 750, height = 300, width = 1000 },
    },
    -- {
        -- rule_any = { instance = { "discord" } },
        -- properties = { floating = true, x = 360, y = 90, height = 900, width = 1200 }
        -- properties = { floating = true }
    -- },
}
---}}}

---{{{ on client spawn
client.connect_signal("manage",function(c)
    if c.class == "aw-qt" then -- close that weird aw-qt window for me please
        c:kill()
    end 
end)
---}}}

---{{{ borders but not on maximized clients
local border_width  = beautiful.border_width  or 2
local border_normal = beautiful.border_normal or "#cccccc"
local border_focus  = beautiful.border_focus  or "#ff0000"

function border_adjust(c)
    if c.maximized or c.first_tag.layout.name == "max" then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused().clients == 1 then
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
end

-- client.connect_signal("focus", border_adjust)
-- client.connect_signal("property::maximized", border_adjust)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
---}}}

---{{{ rounded corners but not on maximized clienta
local corner_radius = beautiful.corner_radius or 0

local function is_maximized(c)
    local function _fills_screen()
        local wa = c.screen.workarea
        local cg = c:geometry()
        return wa.x == cg.x and wa.y == cg.y and wa.width == cg.width and wa.height == cg.height
    end
    return c.maximized or (not c.floating and _fills_screen())
end

-- client.connect_signal("property::geometry", function(c)
--     if is_maximized(c) then
--         c.shape = function(cr,w,h)
--             gears.shape.rounded_rect(cr,w,h,0)
--         end
--     else
--         c.shape = function(cr,w,h)
--            gears.shape.rounded_rect(cr,w,h, corner_radius)
--         end
--     end
-- end)
---}}}

---{{{ Notify when cpu temp rises above 65°C
awesome.connect_signal("evil::temp", function(temp)
    if temp > 65 then
        naughty.notify({title="[!] CPU is getting hot", text="Currently at " .. tostring(temp) .. "°C"})
    end
end)
---}}}

---{{{ needed doing scratchpad and "launch or focus" for sxhkd keybinds
local scratchpad = require("module.scratchpad")

awesome.connect_signal("toggle::scratchpad", function()
                          scratchpad.toggle("alacritty --class spad", {instance = "spad"},
                                            {sticky=true, autoclose=true, floating=true,
                                             geometry={ x = 360, y = 90, height = 900, width = 1200 }})
end)

awesome.connect_signal("toggle::music", function()
                          scratchpad.toggle("alacritty --class smusic -e $HOME/.config/ncmpcpp/ncmpcpp-ueberzug/ncmpcpp-ueberzug",
                                            {instance = "smusic"}, {sticky=true, autoclose=true})
end)

awesome.connect_signal("toggle::discord", function()
                          scratchpad.toggle("discord", {instance = "discord"},
                                            {sticky=true, autoclose=false, floating=true,
                                             geometry={ x = 360, y = 90, height = 900, width = 1200 }})
end)

awesome.connect_signal("toggle::webs", function()
                          scratchpad.toggle("brave", {instance = "brave-browser"},
                                            {sticky=false, autoclose=false})
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
---}}}

---{{{ Essentially just backup keybinds, should sxhkd fails
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local hotkeys_popup = require("awful.hotkeys_popup").widget

local globalkeys = my_table.join(
   awful.key({ modkey,           }, "p", function() awful.util.spawn(beautiful.terminal:lower() or "xterm") end,
              {description = "launch terminal", group = "launch"}),
   awful.key({ modkey,           }, "s", hotkeys_popup.show_help,
              {description = "show help", group="awesome"})
)

root.keys(globalkeys)
---}}}

---{{{ start with bar disabled
awesome.emit_signal("toggle::bar")
---}}}


--{{{ Experimenting with stuff
-- local function create_icon(icon, fg) 
--     local btn_thing = wibox.widget.textbox("")
--     btn_thing.align = "center"
--     btn_thing.valign = "center"
--     btn_thing.font = "JetBrainsMono Nerd Font 8"
--     btn_thing.markup = helpers.colorize_text(icon, fg)
--     return btn_thing
-- end

-- local function create_btn(icon, fg, bg)
--    local btn_icon = create_icon(icon, fg)
   
-- end

-- client.connect_signal("manage", function(c)
--     if c.class ~= "Alacritty" or not c.floating then return end
--     local btn_radius = 15

--     local btn_minimize = wibox({
--           screen = awful.screen.focused(),
--           x = c.x,
--           y = c.y,
--           width = 2 * btn_radius,
--           height = 2 * btn_radius,
--           shape = gears.shape.circle,
--           bg = beautiful.xcolor0,
--           ontop = true,
--           visible = true
--     })

--     local btn_maximize = wibox({
--           screen = awful.screen.focused(),
--           x = c.x,
--           y = c.y,
--           width = 2 * btn_radius,
--           height = 2 * btn_radius,
--           shape = gears.shape.circle,
--           bg = beautiful.xcolor0,
--           ontop = true,
--           visible = true
--     })

--     local btn_close = wibox({
--           screen = awful.screen.focused(),
--           x = c.x,
--           y = c.y,
--           width = 2 * btn_radius,
--           height = 2 * btn_radius,
--           shape = gears.shape.circle,
--           bg = beautiful.xcolor0,
--           ontop = true,
--           visible = true
--     })

--     local icon_minimize = create_icon("絛", beautiful.xcolor3)
--     local icon_maximize = create_icon("", beautiful.xcolor4)
--     local icon_close    = create_icon("", beautiful.xcolor1)
    
--     btn_minimize:setup { layout = wibox.layout.align.vertical, nil, icon_minimize, nil }
--     btn_maximize:setup { layout = wibox.layout.align.vertical, nil, icon_maximize, nil }
--     btn_close:setup    { layout = wibox.layout.align.vertical, nil, icon_close, nil }

--     function adjust_titlebox()
--        btn_minimize.x = c.x + c.width - 9 * btn_radius
--        btn_minimize.y = c.y - 0.75 * btn_radius
--        btn_maximize.x = c.x + c.width - 6 * btn_radius
--        btn_maximize.y = c.y - 0.75 * btn_radius
--        btn_close.x = c.x + c.width - 3 * btn_radius
--        btn_close.y = c.y - 0.75 * btn_radius
--     end

--     adjust_titlebox()
    
--     c:connect_signal("property::position", adjust_titlebox)
--     c:connect_signal("property::size", adjust_titlebox)

--     c:connect_signal("unfocus", function()
--                         btn_minimize.visible = false
--                         btn_maximize.visible = false
--                         btn_close.visible = false
--     end)
--     c:connect_signal("focus", function()
--                         btn_minimize.visible = true
--                         btn_maximize.visible = true
--                         btn_close.visible = true
--     end)
--     c:connect_signal("unmanage", function()
--                         btn_minimize.visible = false
--                         btn_minimize = nil
--                         btn_maximize = nil
--                         btn_close = nil
--     end)
-- end)
-- --}}}

--{{{ sloppy focus
client.connect_signal("mouse::enter", function(c)
                        c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
--}}}

---{{{
local function update_mastercount(t)
   if t.layout.name ~= "tile" then return end
   local counter = 0
   for idx, c in ipairs(t:clients()) do
      if not c.floating then counter = counter + 1 end
   end
   if counter > 3 then
      t.master_count = 2
   else
      t.master_count = 1
   end
end
tag.connect_signal("tagged", update_mastercount)
tag.connect_signal("untagged", update_mastercount)
---}}}

awful.spawn.with_shell("$HOME/code/dots/scripts/autostart")

-- collectgarbage("setpause", 160)
-- collectgarbage("setstepmul", 400)

-- awesome.connect_signal("refresh", function() collectgarbage("collect") end)
