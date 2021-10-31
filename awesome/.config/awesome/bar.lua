-- my vertical bar 😎

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi   = require("beautiful").xresources.apply_dpi
local awesome, client, mouse = awesome, client, mouse

local helpers = require("helpers")

local statusbar_font = "JetBrainsMono NF Bold 9"
local statusbar_width = beautiful.statusbar_width
local dash_width = dpi(500)
local is_dash_visible = false
-- local statusbar_second_bg = beautiful.xbg
local arc_bg = beautiful.xcolor8
local mfont = "JetBrainsMono NF Bold "

local border_width = 0
local border_color = arc_bg


local function format_entry(wid, inner_pad)
    local bg_box = wibox.widget {
       {
           wid,
           margins = dpi(inner_pad or 5),
           widget = wibox.container.margin
       },
       bg = beautiful.xbg,
       shape = helpers.rrect(beautiful.border_radius - 3),
       shape_border_color = border_color,
       shape_border_width = border_width,
       widget = wibox.container.background
    }
    awesome.connect_signal("chcolor", function()
        bg_box:set_bg(beautiful.xbg)
    end)
    return wibox.widget {
       bg_box,
       margins = dpi(5),
       widget = wibox.container.margin
    }
end

---{{{ dashboard button
local theme_assets = require("beautiful.theme_assets")
theme_assets.awesome_icon(25, beautiful.xbg, beautiful.xfg)
local dash_button = wibox.widget.imagebox(beautiful.awesome_icon)
awesome.connect_signal("chcolor", function()
    dash_button.image = theme_assets.awesome_icon(25, beautiful.xbg, beautiful.xfg)
end)

dash_button:buttons(gears.table.join(
                  awful.button({}, 1, function() awesome.emit_signal("toggle::dash") end)
))
---}}}

---{{{ systray
local mysystray = wibox.widget.systray()
mysystray:set_horizontal(false)
mysystray:set_base_size(nil)

local icon_box = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    mysystray,
}
local systray_box = format_entry(icon_box)
systray_box.visible = false
awesome.connect_signal("toggle::systray", function() systray_box.visible = not systray_box.visible end)
---}}}

--{{{ Clock
local hourtextbox = wibox.widget.textclock("%H")
hourtextbox.font = statusbar_font
hourtextbox.markup = helpers.colorize_text(hourtextbox.text, beautiful.xcolor6)
hourtextbox.align = "center"
hourtextbox.valign = "center"

local minutetextbox = wibox.widget.textclock("%M")
minutetextbox.font = statusbar_font
minutetextbox.align = "center"
minutetextbox.valign = "center"

hourtextbox:connect_signal("widget::redraw_needed", function()
  hourtextbox.markup = helpers.colorize_text(hourtextbox.text, beautiful.xcolor6)
end)

minutetextbox:connect_signal("widget::redraw_needed", function()
    minutetextbox.markup = helpers.colorize_text(minutetextbox.text, beautiful.xfg)
end)

awesome.connect_signal("chcolor", function()
    hourtextbox.markup = helpers.colorize_text(hourtextbox.text, beautiful.xcolor6)
    minutetextbox.markup = helpers.colorize_text(minutetextbox.text, beautiful.xfg)
end)

local clockbox = wibox.widget {
    {
        {
            hourtextbox,
            minutetextbox,
            layout = wibox.layout.fixed.vertical
        },
        top   = 5,
        bottom = 5,
        widget = wibox.container.margin
    },
    bg = beautiful.xcolor0 .. "00",
    widget = wibox.container.background
}

local datetooltip = awful.tooltip {};
datetooltip.shape = helpers.prrect(beautiful.border_radius - 3, false, true, true, false)
datetooltip.preferred_alignments = {"middle", "front", "back"}
datetooltip.mode = "outside"
datetooltip:add_to_object(clockbox)
datetooltip.text = os.date("%d.%m.%y") -- just don't stay up long enough for that to change

clockbox:buttons(gears.table.join(
                  awful.button({}, 1, function() awesome.emit_signal("scratch::turn_off") end),
                  awful.button({}, 3, function() awesome.emit_signal("toggle::systray") end)
))
---}}}

---{{{ battery widget, stolen from https://github.com/JavaCafe01/
local battery_bar = wibox.widget {
    max_value = 100,
    value = 70,
    forced_width = dpi(200),
    shape = helpers.rrect(beautiful.border_radius - 3),
    bar_shape = helpers.rrect(beautiful.border_radius - 3),
    color = {
        type = 'linear',
        from = {0, 0},
        to = {55, 20},
        stops = {
            {1 + (80) / 100, beautiful.xcolor6},
            {0.75 - (80 / 100), beautiful.xcolor3},
            {1 - (80) / 100, beautiful.xcolor6}
        }
    },
    background_color = beautiful.xbg,
    border_width = dpi(0),
    border_color = beautiful.border_color,
    widget = wibox.widget.progressbar,
}

local battery_tooltip = awful.tooltip {}
battery_tooltip.shape = helpers.prrect(beautiful.border_radius - 3, false, true, true, false)
battery_tooltip.preferred_alignments = {"middle", "front", "back"}
battery_tooltip.mode = "outside"
battery_tooltip:add_to_object(battery_bar)
battery_tooltip.text = 'Not Updated'

local battery = format_entry({
        battery_bar,
        forced_height = dpi(70),
        direction = "east",
        widget = wibox.container.rotate
                             }, 9)

if beautiful.is_on_pc then
    battery.visible = false
end

awesome.connect_signal("evil::battery", function(value)
                           battery.visible = true
                           battery_bar.value = value
    battery_bar.color = {
        type = 'linear',
        from = {0, 0},
        to = {75 - (100 - value), 20},
        stops = {
            {1 + (value) / 100, beautiful.xcolor10},
            {0.75 - (value / 100), beautiful.xcolor9},
            {1 - (value) / 100, beautiful.xcolor10}
        }
    }

    local bat_icon = ' '

    if value >= 90 and value <= 100 then
        bat_icon = ' '
    elseif value >= 70 and value < 90 then
        bat_icon = ' '
    elseif value >= 60 and value < 70 then
        bat_icon = ' '
    elseif value >= 50 and value < 60 then
        bat_icon = ' '
    elseif value >= 30 and value < 50 then
        bat_icon = ' '
    elseif value >= 15 and value < 30 then
        bat_icon = ' '
    else
        bat_icon = ' '
    end

    battery_tooltip.markup =
        " " .. "<span foreground='" .. beautiful.xcolor12 .. "'>" .. bat_icon ..
            "</span>" .. value .. '% '
end)

-- Timer for charging animation
local q = 0
local g = gears.timer {
    timeout = 0.03,
    call_now = false,
    autostart = false,
    callback = function()
        if q >= 100 then q = 0 end
        q = q + 1
        battery_bar.value = q
        battery_bar.color = {
            type = 'linear',
            from = {0, 0},
            to = {75 - (100 - q), 20},
            stops = {
                {1 + (q) / 100, beautiful.xcolor10},
                {0.75 - (q / 100), beautiful.xcolor1},
                {1 - (q) / 100, beautiful.xcolor10}
            }
        }
    end
}

-- The charging animation
local running = false
awesome.connect_signal("evil::charger", function(plugged)
    if plugged then
        g:start()
        running = true
    else
        if running then
            g:stop()
            running = false
        end
    end
end)
---}}}

---{{{ taglist buttons
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ }, 2, function(t) t:delete() end),
                    awful.button({ }, 3, function(t) awful.tag.viewtoggle(t) end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
                )
---}}}


---{{{ music
local album_art = wibox.widget.imagebox()
local music = album_art
music.visible = true

local musictooltip = awful.tooltip {}
musictooltip.shape = helpers.prrect(beautiful.border_radius - 3, false, true, true, false)
musictooltip.preferred_alignments = {"middle", "front", "back"}
musictooltip.mode = "outside"
musictooltip:add_to_object(music)
musictooltip.text = "Not updated"

awesome.connect_signal("bling::playerctl::status", function(playing) music.visible = playing end)
awesome.connect_signal("bling::playerctl::player_stopped", function() music.visible = false end)
awesome.connect_signal("bling::playerctl::title_artist_album", function(title, artist, album_path)
                           musictooltip.markup = tostring(title) .. " - " .. tostring(artist)
                           music.visible = true
                           album_art:set_image(gears.surface.load_uncached_silently(album_path))
                           album_art:emit_signal("widget::redraw_needed")
end)
album_art:buttons(gears.table.join(
                  awful.button({}, 1, function()
                          awful.spawn("playerctl play-pause")
                  end),
                  awful.button({}, 4, function()
                          awful.spawn("playerctl next")
                  end),
                  awful.button({}, 5, function()
                          awful.spawn("playerctl previous")
                  end)
))

local uparr = wibox.widget.textbox("")
uparr.align = "center"
uparr.valign = "center"
uparr.markup = helpers.colorize_text("", beautiful.xcolor6)
local downarr = wibox.widget.textbox("")
downarr.align = "center"
downarr.valign = "center"
downarr.markup = helpers.colorize_text("", beautiful.xfg)
awesome.connect_signal("chcolor", function()
    uparr.markup = helpers.colorize_text("", beautiful.xcolor6)
    downarr.markup = helpers.colorize_text("", beautiful.xfg)
end)

local musicbox = wibox.widget {
    {
        {
            uparr,
            helpers.vertical_pad(2),
            music,
            helpers.vertical_pad(2),
            downarr,
            layout = wibox.layout.fixed.vertical
        },
        top   = 5,
        bottom = 5,
        widget = wibox.container.margin
    },
    bg = beautiful.xcolor0 .. "00",
    widget = wibox.container.background
}



---{{{ fortune
local fortune_command = "fortune -n 50 -s"
local fortune_update_interval = 360
local fortune = wibox.widget {
    text = "Loading your cookie...",
    align = "center",
    valign = "center",
    font = mfont .. "15",
    widget = wibox.widget.textbox
}

local update_fortune = function()
    awful.spawn.easy_async_with_shell(fortune_command, function(out)
        -- Remove trailing whitespaces
        out = out:gsub('^%s*(.-)%s*$', '%1')
        fortune.markup = "<i>"..helpers.colorize_text(out, beautiful.xcolor3).."</i>"
    end)
end

gears.timer {
    autostart = true,
    timeout = fortune_update_interval,
    single_shot = false,
    call_now = true,
    callback = update_fortune
}
---}}}

---{{{ tasklist buttons
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
            c.minimized = not c.minimized
    end),
    -- awful.button({ }, 2, function(c)
    --         c:kill()
    -- end),
    awful.button({ }, 3, function(c)
            c:kill()
    end),
    awful.button({ }, 4, function ()
	    awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
	    awful.client.focus.byidx(-1)
end))
---}}}


--- where it's all comming together

awful.screen.connect_for_each_screen(function(s)

   s.mypromptbox = awful.widget.prompt()

   s.mytaglist = awful.widget.taglist {
       screen  = s,
       filter  = awful.widget.taglist.filter.all,
       style   = {
           shape = gears.shape.rectangle,
           font = statusbar_font
       },
       layout   = {
           spacing = 0,
           layout  = wibox.layout.fixed.vertical
       },
       widget_template = {
           {
               {
                   {
                       id = 'text_role',
                       align = 'center',
                       valign = 'center',
                       widget = wibox.widget.textbox,
                   },
                   layout = wibox.layout.fixed.vertical,
               },
               top = 5,
               bottom = 5,
               widget = wibox.container.margin
           },
           id     = 'background_role',
           widget = wibox.container.background,
           create_callback = function(self, c3, _, _)
               self:connect_signal('mouse::enter', function()
                                       awesome.emit_signal("bling::tag_preview::update", c3)
                                       awesome.emit_signal("bling::tag_preview::visibility", s, true)
               end)
               self:connect_signal('mouse::leave', function()
                                       awesome.emit_signal("bling::tag_preview::visibility", s, false)
               end)
           end,
       },
       buttons = taglist_buttons
   }

   s.mytasklist = awful.widget.tasklist {
       screen  = s,
       filter   = awful.widget.tasklist.filter.currenttags,
       style   = {
           shape = helpers.rrect(beautiful.border_radius - 3),
           font  = statusbar_font
       },
       layout   = {
           spacing = 0,
           spacing_widget = {
               shape  = gears.shape.rectangle,
               widget = wibox.widget.separator,
           },
           layout  = wibox.layout.fixed.vertical
       },
       widget_template = {
           {
               {
                   {
                       {
                           id = "icon_role",
                           widget = wibox.widget.imagebox,
                       },
                       margins = dpi(5),
                       widget = wibox.container.margin
                   },
                   id = "background_role",
                   update_callback = function(a, b, c, d)
                           require('bling.widget.tabbed_misc').custom_tasklist(a, b, c, d)
                   end,
                   widget = wibox.container.background
               },
               margins = dpi(5),
               widget = wibox.container.margin
           },
           visible = true,
           create_callback = function(self, c, _, _)
                -- BLING: Toggle the popup on hover and disable it off hover
                self:connect_signal('mouse::enter', function()
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        true, c)
                end)
                self:connect_signal('mouse::leave', function()
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        false, c)
                end)
           end,

           layout = wibox.layout.fixed.vertical
       },
       buttons = tasklist_buttons,
   }


   --- One client on the tasklist looks so lonely so I'd rather have it only show up by 2 or more clients
   --local function update_tasklist_visibilty(t)
   --    s.mytasklist.visible = (#t:clients() > 1)
   --end

   --tag.connect_signal("tagged", update_tasklist_visibilty)
   --tag.connect_signal("untagged", update_tasklist_visibilty)
   --tag.connect_signal("property::selected", update_tasklist_visibilty)


   s.mylayoutbox = awful.widget.layoutbox(s)
   s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

   -- Create the wibar
   s.mywibar = awful.wibar {
       position = "left",
       screen = s,
       bg = beautiful.xbg2,
       width = statusbar_width,
       opacity = 1,
       visible = true,
       type = "wibar",
   }

   s.mywibar:setup {
       widget = wibox.container.constraint,
       width = statusbar_width,
       {
           layout = wibox.layout.align.vertical,
           expand = "none",
           width = statusbar_width,
           { -- Top widgets: button, taglist, tasklist
               layout = wibox.layout.fixed.vertical,
               helpers.vertical_pad(6),
               format_entry(dash_button, 0),
               -- format_entry(s.mytaglist),
               -- add_tag_box,
               -- s.mytasklist,
           },
           { -- Middle widgets: nothing
               layout = wibox.layout.fixed.vertical,
               nil
           },
           { -- Bottom widgets: layoutbox, time, systray, music, battery
               layout = wibox.layout.fixed.vertical,
               format_entry(musicbox, 0),
               battery,
               systray_box,
               format_entry(clockbox),
               -- format_entry(s.mylayoutbox),
               helpers.vertical_pad(5),
           },
       }
   }

   awesome.connect_signal("chcolor", function()
           s.mywibar.bg = beautiful.xbg2
   end)

   awesome.connect_signal("toggle::bar", function()
           s.mywibar.visible = not s.mywibar.visible
           s.mywibox.visible = not s.mywibox.visible
   end)

   client.connect_signal("property::maximized", function(c)
           s.mywibox.visible = not c.maximized
           s.mywibar.visible = not c.maximized
   end)

   client.connect_signal("property::fullscreen", function(c)
           s.mywibox.visible = not c.fullscreen
           s.mywibar.visible = not c.fullscreen
   end)

end)

