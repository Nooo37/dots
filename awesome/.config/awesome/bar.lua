-- my vertical bar 😎

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi   = require("beautiful").xresources.apply_dpi
local awesome, client, mouse= awesome, client, mouse

local helpers = require("helpers")
local clock_wid = require("module.clock")
local awestore = require("awestore")

local statusbar_font = "JetBrainsMono NF Bold 9"
local statusbar_width = beautiful.statusbar_width
local dash_width = dpi(500)
local dash_gap = dpi(10)
local is_dash_visible = false
local statusbar_bg = beautiful.xbg2
local statusbar_second_bg = beautiful.xbg
local arc_bg = beautiful.xcolor8
local mfont = "JetBrainsMono NF Bold "

local border_width = 0
local border_color = arc_bg


local function create_button(text, font, fg, bg, shape, func)
        local text_box = wibox.widget.textbox(text)
        text_box.font = font
        text_box.markup = helpers.colorize_text(text, fg)
        text_box.align = "center"
        text_box.valign = "center"
        local widget_box = wibox.widget {
                text_box,
                bg = bg,
                shape = shape,
                widget = wibox.container.background
        }
        local old_cursor, old_wibox
        widget_box:connect_signal("mouse::enter", function()
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"
            widget_box.bg = fg
            text_box.markup = helpers.colorize_text(text, bg)
        end)
        widget_box:connect_signal("mouse::leave", function()
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
                widget_box.bg = bg
                text_box.markup = helpers.colorize_text(text, fg)
            end
        end)
        widget_box:buttons(gears.table.join(awful.button({}, 1, func)))
        return widget_box
end

local function format_entry(wid, inner_pad)
    return wibox.widget {
                    {
                        {
                            wid,
                            margins = dpi(inner_pad or 5),
                            widget = wibox.container.margin
                        },
                        bg = statusbar_second_bg,
                        shape = helpers.rrect(beautiful.border_radius - 3),
                        shape_border_color = border_color,
                        shape_border_width = border_width,
                        widget = wibox.container.background
                    },
                    margins = dpi(5),
                    widget = wibox.container.margin
    }
end

local function format_box(wid, w, h, marg)
    return wibox.widget {
            {
                    {
                        {
                            wid,
                            margins = dpi(marg or 5),
                            widget = wibox.container.margin
                        },
                        bg = statusbar_second_bg,
                        forced_width = w,
                        forced_height = h,
                        shape = helpers.rrect(beautiful.border_radius + 3),
                        shape_border_color = border_color,
                        shape_border_width = border_width,
                        widget = wibox.container.background
                    },
                    height = h,
                    width = w,
                    widget = wibox.container.constraint
            },
            left = dpi(dash_gap),
            top =  dpi(dash_gap),
            widget = wibox.container.margin
    }
end

---{{{ dashboard button
local dash_button = wibox.widget.imagebox(beautiful.awesome_icon)

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


---{{{ date
local datec = wibox.widget.textbox()
datec.font = mfont .. "20"
datec.align = "left"
datec.valign = "center"
datec.markup =  helpers.colorize_text(os.date("%d"), beautiful.xcolor6)
                .. helpers.colorize_text(".", beautiful.xfg)
                .. helpers.colorize_text(os.date("%m"), beautiful.xcolor2)
                .. helpers.colorize_text(".", beautiful.xfg)
                .. helpers.colorize_text(os.date("%y"), beautiful.xcolor5)
local dateb = wibox.widget.textbox()
dateb.font = mfont .. "12"
dateb.align = "left"
dateb.valign = "center"
dateb.markup = helpers.colorize_text(os.date("%a"), beautiful.xfg) ..
                helpers.colorize_text(", ", beautiful.xfg)
local datetext = wibox.widget {
        {
                dateb,
                helpers.horizontal_pad(2),
                datec,
                layout = wibox.layout.fixed.horizontal
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
}
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


-- music progress bar

local progress_color = {
    type = 'linear',
    from = {0, 0},
    to = {dash_width, 0},
    stops = {
        {0, beautiful.xcolor6},
        {1, beautiful.xcolor5}
    }
}
local musicprogressbar = wibox.widget {
        max_value = 1,
        value = 0.4,
        forced_height = dpi(10),
        shape         = helpers.rrect(beautiful.border_radius - 3),
        bar_shape         = helpers.rrect(beautiful.border_radius - 3),
        forced_width = dash_width - 2 * dash_gap,
        shape_border_width = 0,
        background_color = "alpha",
        color = progress_color,
        widget = wibox.widget.progressbar,
}

local musicprogress = wibox.widget {
        {
                {
                        wibox.widget.textbox(""),
                        shape = helpers.rrect(beautiful.border_radius - 3),
                        bg = arc_bg,
                        widget = wibox.container.background
                },
                margins = dpi(3),
                widget = wibox.container.margin
        },
        musicprogressbar,
        layout = wibox.layout.stack
}

awesome.connect_signal("bling::playerctl::position", function(pos, max, _) musicprogressbar.value = pos / max end)

-- music text

local text_title = wibox.widget.textbox("")
text_title.text = "_"
text_title.valign = "center"
text_title.align = "left"
text_title.font = mfont .. "20"

local text_artist = wibox.widget.textbox("")
text_artist.text = "_"
text_artist.valign = "center"
text_artist.align = "left"
text_artist.font = mfont .. "12"

awesome.connect_signal("bling::playerctl::title_artist_album", function(title, artist, _, _)
        text_title.markup = helpers.colorize_text(tostring(title), beautiful.xcolor6)
        text_artist.markup = helpers.colorize_text(tostring(artist), beautiful.xfg)
end)

local musicinfo = wibox.widget {
        {
                layout = wibox.layout.fixed.vertical,
                text_title,
                text_artist,
        },
        top = dpi(15),
        bottom = dpi(15),
        left = dpi(25),
        widget = wibox.container.margin
}

---}}}


---{{{ progressbars
local function create_arc(wid, sym, color)
        wid.colors = { color }
        wid.start_angle = math.pi * 6 / 4 -- start at top
        wid.rounded_edge = true
        wid.thickness = dpi(10)
        wid.border_width = 0
        return wibox.widget {
                { -- circle
                        {
                                wibox.widget.textbox(""),
                                shape = gears.shape.circle,
                                shape_border_color = arc_bg,
                                shape_border_width = dpi(4),
                                widget = wibox.container.background
                        },
                        margins = dpi(3),
                        widget = wibox.container.margin
                },
                { -- symbol in the middle
                                -- textw,
                                sym,
                                margins = dpi(25),
                                widget = wibox.container.margin
                },
                wid, -- progress arc
                widget = wibox.layout.stack
        }
end

local function create_default_arcchart()
        return wibox.widget {
                wibox.widget.textbox(""),
                value = 0.75,
                min_value = 0,
                max_value = 1,
                widget = wibox.container.arcchart,
        }
end

local prog_ram_arc = create_default_arcchart()
local prog_bri_arc = create_default_arcchart()
local prog_vol_arc = create_default_arcchart()
local prog_tmp_arc = create_default_arcchart()
local prog_dsk_arc = create_default_arcchart()
local prog_cpu_arc = create_default_arcchart()

local mutedg = false
local prog_ram_but = create_button("",  mfont .. "30", beautiful.xcolor6, statusbar_second_bg, gears.shape.circle, nil)
local prog_bri_but = create_button("",  mfont .. "30", beautiful.xcolor2, statusbar_second_bg, gears.shape.circle, nil)
local prog_vol_but = create_button("墳", mfont .. "30", beautiful.xcolor5, statusbar_second_bg, gears.shape.circle,
        function()
                if mutedg then
                        awful.spawn("amixer set Master unmute")
                else
                        awful.spawn("amixer set Master mute")
                end
        end)
local prog_tmp_but = create_button("",  mfont .. "30", beautiful.xcolor3, statusbar_second_bg, gears.shape.circle, nil)
local prog_dsk_but = create_button("",  mfont .. "30", beautiful.xcolor1, statusbar_second_bg, gears.shape.circle, nil)
local prog_cpu_but = create_button("",  mfont .. "30", beautiful.xcolor7, statusbar_second_bg, gears.shape.circle, nil)

awesome.connect_signal("evil::ram",        function(used, total) prog_ram_arc.value = (used / total) end)
awesome.connect_signal("evil::volume",     function(perc, muted) prog_vol_arc.value = muted and 0 or perc / 100; mutedg = muted end)
awesome.connect_signal("evil::brightness", function(perc)        prog_bri_arc.value = perc end)
awesome.connect_signal("evil::temp",       function(temp)        prog_tmp_arc.value = temp / 100 end)
awesome.connect_signal("evil::disk",       function(used, total) prog_dsk_arc.value = used / total end)
awesome.connect_signal("evil::cpu",        function(perc)        prog_cpu_arc.value = perc / 100 end)

local prog_ram = create_arc(prog_ram_arc, prog_ram_but, beautiful.xcolor6)
local prog_bri = create_arc(prog_bri_arc, prog_bri_but, beautiful.xcolor2)
local prog_vol = create_arc(prog_vol_arc, prog_vol_but, beautiful.xcolor5)
local prog_tmp = create_arc(prog_tmp_arc, prog_tmp_but, beautiful.xcolor3)
local prog_dsk = create_arc(prog_dsk_arc, prog_dsk_but, beautiful.xcolor1)
local prog_cpu = create_arc(prog_cpu_arc, prog_cpu_but, beautiful.xcolor7) -- 
---}}}

---{{{ weather
local icon_text = wibox.widget.textbox("")
icon_text.font = mfont .. "45"
icon_text.valign = "center"
local temp_text = wibox.widget.textbox("")
temp_text.font = mfont .. "17"
temp_text.valign = "center"
local wind_text = wibox.widget.textbox("")
wind_text.font = mfont .. "17"
wind_text.valign = "center"

-- TODO: finish the matching
local function emote_to_nerdfont(emo)
        emo = tostring(emo)
        emo = emo:gsub("%s+", "")
        -- if emo == "☀️" then return "" end
        -- if emo == "☁" then return "" end
        -- if emo == "⛅" then return "" end
        -- if emo == "⛈" then return "" end
        -- if emo == "🌤 " then return "" end
        -- if emo == "🌦 " then return "" end
        -- if emo == "🌧 " then return "" end
        -- if emo == "🌨 " then return "" end
        -- if emo == "🌩 " then return "" end
        -- if emo == "🌪 " then return "" end
        -- if emo == "🌫 " then return "" end
        return emo
end

awesome.connect_signal("evil::weather", function(temp, wind, emote)
        icon_text.markup = helpers.colorize_text(emote_to_nerdfont(emote), beautiful.xcolor6) --"", beautiful.xcolor6)
        temp_text.markup = helpers.colorize_text(temp .. " °C", beautiful.xfg)
        wind_text.markup = helpers.colorize_text(wind .. " km/h", beautiful.xcolor5)
end)

local weather_wid = wibox.widget {
        {
                icon_text,
                helpers.horizontal_pad(dpi(25)),
                {
                        {
                                temp_text,
                                helpers.vertical_pad(dpi(3)),
                                wind_text,
                                layout = wibox.layout.fixed.vertical
                        },
                        valign = "center",
                        widget = wibox.container.place
                },
                layout = wibox.layout.fixed.horizontal
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
}
---}}}

---{{{ layoutbox
local layoutlist = awful.widget.layoutlist {
    base_layout = wibox.widget {
        spacing         = 5,
        forced_num_cols = 3,
        layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
            {
                {
                    {
                        id            = 'icon_role',
                        forced_height = 20,
                        forced_width  = 20,
                        widget        = wibox.widget.imagebox,
                    },
                    margins = 13,
                    widget  = wibox.container.margin,
                },
                id              = 'background_role',
                -- bg = "alpha",
                forced_width    = 55,
                forced_height   = 55,
                shape           = helpers.rrect(dpi(5)),
                shape_border_color = arc_bg,
                shape_border_width = 2,
                widget          = wibox.container.background,
            },
            margins = dpi(7),
            widget = wibox.container.margin
    },
}
local layoutlist_wid = wibox.widget {
        layoutlist,
        valign = "center",
        halign = "center",
        widget = wibox.container.place
}
---}}}

---{{{ profile

local profile_img = wibox.widget.imagebox(beautiful.wallpaper)
local username = "no37" --os.getenv("USER")
local username_text = wibox.widget.textbox(username)
username_text.markup = helpers.colorize_text(username, beautiful.xcolor6)
username_text.font = mfont .. "20"
username_text.halign = "center"
username_text.align = "center"
local profile = wibox.widget {
        {
                {
                        {
                                profile_img,
                                shape = helpers.circle(dpi(50)),
                                widget = wibox.container.background
                        },
                        halign = "center",
                        widget = wibox.container.place
                },
                helpers.vertical_pad(dpi(5)),
                username_text,
                layout = wibox.layout.fixed.vertical
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
}
---}}}

---{{{ buttons
local sus_b = create_button("鈴", mfont .. "20", beautiful.xcolor5, statusbar_second_bg, gears.shape.circle, function() awful.spawn("systemctl suspend") end)
local off_b = create_button("⏻", mfont .. "22",  beautiful.xcolor6, statusbar_second_bg, gears.shape.circle, function() awful.spawn("systemctl poweroff") end)
local reb_b = create_button("", mfont .. "20",  beautiful.xcolor2, statusbar_second_bg, gears.shape.circle, function() awful.spawn("systemctl reboot") end)
---}}}

---{{{ spawn buttons
local function create_spawn_button(cmd_img)
        local widget_spawn = wibox.widget.imagebox(beautiful.config_path .. "assets/" .. cmd_img .. ".png")
        local old_cursor, old_wibox
        widget_spawn:buttons()
        widget_spawn:connect_signal("mouse::enter", function()
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"
        end)
        widget_spawn:connect_signal("mouse::leave", function()
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end)
        widget_spawn:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn(cmd_img) end)))
        return widget_spawn
end

local lollypop_spawn  = create_spawn_button("lollypop")
local alacritty_spawn = create_spawn_button("alacritty")
local thunar_spawn    = create_spawn_button("thunar")
local brave_spawn     = create_spawn_button("brave")
---}}}

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



                           require("naughty").notify{title = "hey"}
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
                           require("naughty").notify{title = "huhu"}
                           -- require('bling.widget.tabbed_misc').custom_tasklist(a, b, c, d)
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
       bg = beautiful.xbg .. "00",
       width = statusbar_width,
       opacity = 0,
       visible = true,
       type = "wibar",
   }

   -- Create the wibox
   s.mywibox = wibox {
       shape = helpers.rrect(0),
       height = s.geometry.height,
       width = dash_width + statusbar_width,
       x = - dash_width,
       y = 0,
       visible = true,
       ontop = false,
       bg = statusbar_bg,
   }

   -- mouse grabber for the sidebar, ehh
   --[[
   s.mywibox:buttons(gears.table.join(
                  awful.button({}, 1, function()
                         mousegrabber.run(function(coord)
                                s.mywibox.x = coord.x - dash_width
                                if s.mywibox.x > 0 then
                                        s.mywibox.x = 0
                                        is_dash_visible = true
                                        return false
                                end
                                if coord.x == 0 then
                                        s.mywibox.x = - dash_width
                                        is_dash_visible = false
                                        return false
                                end
                                return true
                         end, "arrow")
                  end)
   ))
   --]]

   s.mywibox:setup {
       layout = wibox.layout.align.horizontal,
       expand = "none",
       { -- the dashboard
            layout = wibox.layout.align.vertical,
            { -- top
                { -- clock, date, weather
                        format_box(clock_wid, 200, 200, 20),
                        {
                                format_box(datetext, dash_width - 3 * dash_gap - 200, 70, 0),
                                format_box(weather_wid, dash_width - 3 * dash_gap - 200, 200 - 70 - dash_gap, 0),
                                layout = wibox.layout.fixed.vertical
                        },
                        layout = wibox.layout.fixed.horizontal
                },
                { -- profile, launchers, fortune box
                        {
                                format_box(fortune, dash_width - 3 * dash_gap - 200, 130 - 3 * dash_gap, 10),
                                {
                                        format_box(wibox.widget {brave_spawn, halign="center", widget=wibox.container.place},     200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap, 15),
                                        format_box(alacritty_spawn, 200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap, 15),
                                        format_box(lollypop_spawn,  200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap, 15),
                                        format_box(thunar_spawn,    200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap, 15),
                                        layout = wibox.layout.fixed.horizontal
                                },
                                layout = wibox.layout.fixed.vertical
                        },
                        format_box(profile, 200, 180 - dash_gap, 10),
                        layout = wibox.layout.fixed.horizontal
                },
                { -- first row of arc charts
                        format_box(prog_vol, dash_width / 3 - dash_gap * 4 / 3, nil, 15),
                        format_box(prog_bri, dash_width / 3 - dash_gap * 4 / 3, nil, 15),
                        format_box(prog_ram, dash_width / 3 - dash_gap * 4 / 3, nil, 15),
                        layout = wibox.layout.fixed.horizontal
                },
                { -- second row of arc charts
                        format_box(prog_cpu, dash_width / 3 - dash_gap * 4 / 3, nil, 15),
                        format_box(prog_dsk, dash_width / 3 - dash_gap * 4 / 3, nil, 15),
                        format_box(prog_tmp, dash_width / 3 - dash_gap * 4 / 3, nil, 15),
                        layout = wibox.layout.fixed.horizontal
                },
                { -- layoutbox, buttons and wallpaper
                        format_box(layoutlist_wid, dash_width - 3 * dash_gap - 200, 100, dpi(10)),
                        {
                                {
                                        format_box(off_b, 200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap),
                                        format_box(reb_b, 200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap),
                                        format_box(sus_b, 200 / 3 - (2 / 3) * dash_gap, 200 / 3 - (2 / 3) * dash_gap),
                                        layout = wibox.layout.fixed.horizontal
                                },
                                format_box(wibox.widget.imagebox(beautiful.wallpaper), 200, nil, 0),
                                layout = wibox.layout.fixed.vertical
                        },
                        layout = wibox.layout.fixed.horizontal
                },
                layout = wibox.layout.fixed.vertical
            },
            nil, -- noone will ever notice the slightly bigger gap, yet one will notice when the lower lines don't align
            { -- bottom
                {
                    format_box(music, 100, 100, 0),
                    format_box(musicinfo, dash_width - 3 * dash_gap - 100, 100, 0),
                    layout = wibox.layout.fixed.horizontal
                },
                format_box(musicprogress, dash_width - 2 * dash_gap, nil, 14),
                helpers.vertical_pad(dash_gap),
                layout = wibox.layout.fixed.vertical
            }
       },
       nil,
       { -- the (main) statusbar
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
                    format_entry(s.mytaglist),
                    -- add_tag_box,
                    s.mytasklist,
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
                    format_entry(s.mylayoutbox),
                    helpers.vertical_pad(5),
                },
            },
       }
   }

   awesome.connect_signal("toggle::bar", function()
                              s.mywibar.visible = not s.mywibar.visible
                              s.mywibox.visible = not s.mywibox.visible
   end)


   awesome.connect_signal("toggle::dash", function()
           if is_dash_visible then
                local anim = awestore.tweened(0, {
                    duration = 200,
                    easing = awestore.easing.cubic_in_out
                })
                anim:subscribe(function(x) s.mywibox.x = - x end)
                anim:set(dash_width)
                local unsub
                unsub = anim.ended:subscribe(unsub)
                is_dash_visible = false
           else
                local anim = awestore.tweened(dash_width, {
                    duration = 200,
                    easing = awestore.easing.cubic_in_out
                })
                anim:subscribe(function(x) s.mywibox.x = - x end)
                anim:set(0)
                local unsub
                unsub = anim.ended:subscribe(unsub)
                -- s.mywibox.x = 0
                is_dash_visible = true
           end
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

