local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi   = require("beautiful").xresources.apply_dpi

local helpers = require("ui.helpers")

local dashboard_width = dpi(400)
local dashboard_border_color_normal = beautiful.xbg
local dashboard_border_color_focus = beautiful.xbg
local dashboard_border_width = 5
local secondary_bg = beautiful.xbg
local dashboard_bg = beautiful.xcolor0
local dashboard_position = "right"
local small_font = "JetBrainsMono Nerd Font Bold 20"
local bar_background = beautiful.xcolor8

--{{{ Create dashboard box

function create_box(widget) 
    local temp_wid = wibox.widget {
        {
            {
                {
                    {
                        widget,
                        forced_width = dashboard_width * 0.7,
                        left = dpi(20),
                        right = dpi(20),
                        bottom = dpi(20),
                        top = dpi(20),
                        widget = wibox.container.margin,
                    },
                    shape = helpers.rrect(beautiful.border_radius),
                    bg = secondary_bg, --"#00000077",
                    widget = wibox.container.background
                },
                margins = dashboard_border_width,
                widget = wibox.container.margin
            },
            id = "border",
            bg = dashboard_border_color_normal,
            shape = helpers.rrect(beautiful.border_radius + dashboard_border_width / 2),
            widget = wibox.container.background
        },
        forced_width = dashboard_width * 0.85,
        left = dpi(20),
        right = dpi(20),
        bottom = dpi(20),
        -- top = dpi(20),
        widget = wibox.container.margin,
    }
    temp_wid:connect_signal("mouse::enter", function()
        temp_wid:get_children_by_id("border")[1].bg = dashboard_border_color_focus
    end)
    temp_wid:connect_signal("mouse::leave", function()
        temp_wid:get_children_by_id("border")[1].bg = dashboard_border_color_normal
    end)
    return temp_wid
end

--}}}

--{{{ Create half box

local function create_half_box(heading, body)
    local temp_wid = wibox.widget {
        {
            {
                {
                    {
                        nil,
                        {
                            helpers.vertical_pad(dpi(10)),
                            heading,
                            body,
                            helpers.vertical_pad(dpi(13)),
                            layout = wibox.layout.fixed.vertical
                        },
                        nil,
                        layout = wibox.layout.align.vertical
                    },
                    bg = secondary_bg,
                    shape = helpers.rrect(beautiful.corner_radius),
                    forced_width = (dashboard_width * 0.85 - dpi(10) - 4 * dashboard_border_width) / 2,
                    widget = wibox.container.background 
                },
                margins = dashboard_border_width,
                widget = wibox.container.margin
            },
            id = "border",
            bg = dashboard_border_color_normal,
            shape = helpers.rrect(beautiful.border_radius + dashboard_border_width / 2),
            widget = wibox.container.background
        },
        left = dpi(20),
        bottom = dpi(20),
        widget = wibox.container.margin
    }
    temp_wid:connect_signal("mouse::enter", function()
        temp_wid:get_children_by_id("border")[1].bg = dashboard_border_color_focus
    end)
    temp_wid:connect_signal("mouse::leave", function()
        temp_wid:get_children_by_id("border")[1].bg = dashboard_border_color_normal
    end)
    return temp_wid
end

--}}}

--- {{{ Clock and date

local fancy_time_widget = wibox.widget.textclock("%H%M")

fancy_time_widget:connect_signal("widget::redraw_needed", function()
    fancy_time_widget.markup = fancy_time_widget.text:sub(1, 2) ..
                              helpers.colorize_text(fancy_time_widget.text:sub(3, 4), beautiful.xcolor12)
end)
fancy_time_widget.fg = beautiful.xfg
fancy_time_widget.align = "center"
fancy_time_widget.valign = "center"
fancy_time_widget.font = "JetBrainsMono Nerd Font 45"

local fancy_time = {fancy_time_widget, layout = wibox.layout.fixed.vertical}


local fancy_date_widget = wibox.widget.textclock('%A %B %d, %Y')
fancy_date_widget.markup = helpers.colorize_text(fancy_date_widget.text, beautiful.xcolor12)
fancy_date_widget:connect_signal("widget::redraw_needed", function()
    fancy_date_widget.markup = helpers.colorize_text(fancy_date_widget.text, beautiful.xcolor12)
end)
fancy_date_widget.align = "center"
fancy_date_widget.valign = "center"
fancy_date_widget.font = "Sans bold 12"

local fancy_date = {fancy_date_widget, layout = wibox.layout.fixed.vertical}

local fancy_time_box = wibox.widget {
    helpers.vertical_pad(dpi(20)),
    create_box(
        wibox.widget{
              -- helpers.vertical_pad(dpi(5)),
              fancy_time,
              fancy_date,
              helpers.vertical_pad(dpi(12)),
              layout = wibox.layout.fixed.vertical
        }
    ),
    layout = wibox.layout.fixed.vertical
}

---}}}

---{{{ bar creator

function create_blank_bar(fg_color1, fg_color2, bg_color)
  local fg_color = {
    type = 'linear',
    from = { 0, 0 },
    to = { 300, 50 }, -- replace with w,h later
    stops = {
      { 0.00, fg_color1  },
      { 0.10, fg_color1  },
      { 0.55, fg_color2  },
      { 0.85, fg_color2  }
    }
  }
  local blank_bar = wibox.widget {
    value         = 64,
    max_value     = 100,
    forced_height = dpi(10),
    forced_width  = dpi(300),
    color           = fg_color,
    background_color =  bg_color,
    shape         = helpers.rrect(dpi(6)),
    bar_shape   = helpers.rrect(dpi(6)),
    widget        = wibox.widget.progressbar
  }
  return blank_bar
end

--}}}

--{{{ cpu

local cpu_heading = wibox.widget {
  markup = helpers.colorize_text("CPU ", beautiful.xcolor1),
  font = "Hack bold 15",
  widget = wibox.widget.textbox
}

local cpu_bar = create_blank_bar(beautiful.xcolor1, beautiful.xcolor9, bar_background)

awesome.connect_signal("evil::cpu", function(percentage)
  cpu_bar.value = tonumber(percentage)
end)

--}}}

--{{{ ram

local ram_heading = wibox.widget {
  markup = helpers.colorize_text("RAM ", beautiful.xcolor2),
  font = "Hack bold 15",
  widget = wibox.widget.textbox
}

local ram_bar = create_blank_bar(beautiful.xcolor2, beautiful.xcolor10, bar_background)

awesome.connect_signal("evil::ram", function(used, total)
  ram_bar.value = tonumber(100*(used/total))
end)


--}}}

--{{{ disk

local disk_heading = wibox.widget {
  markup = helpers.colorize_text("DISK", beautiful.xcolor3),
  font = "Hack bold 15",
  widget = wibox.widget.textbox
}

local disk_bar = create_blank_bar(beautiful.xcolor3, beautiful.xcolor11, bar_background)

awesome.connect_signal("evil::disk", function(used, total)
  disk_bar.value = tonumber(100*(used/total))
end)


--}}}

--{{{ vol

local vol_heading = wibox.widget {
  markup = helpers.colorize_text("VOL ", beautiful.xcolor4),
  font = "Hack bold 15",
  widget = wibox.widget.textbox
}

local vol_bar = create_blank_bar(beautiful.xcolor4, beautiful.xcolor12, bar_background)

awesome.connect_signal("evil::volume", function(percentage)
  vol_bar.value = tonumber(percentage)
end)


--}}}

--{{{ mpd vol

local mpd_heading = wibox.widget {
  markup = helpers.colorize_text("MPD ", beautiful.xcolor6),
  font = "Hack bold 15",
  widget = wibox.widget.textbox
}

local mpd_bar = create_blank_bar(beautiful.xcolor6, beautiful.xcolor14, bar_background)

awesome.connect_signal("evil::mpd_volume", function(percentage)
  mpd_bar.value = tonumber(percentage)
end)


--}}}

--{{{ brightness

local bri_heading = wibox.widget {
  markup = helpers.colorize_text("BRI ", beautiful.xcolor5),
  font = "Hack bold 15",
  widget = wibox.widget.textbox
}

local bri_bar = create_blank_bar(beautiful.xcolor5, beautiful.xcolor13, bar_background)

awesome.connect_signal("evil::brightness", function(percentage)
  bri_bar.value = tonumber(percentage)*100
end)


--}}}

--{{{ conglomarat of bars

local perform_bar_widgets = wibox.widget {
    -- helpers.vertical_pad(dpi(5)),
    {
      helpers.horizontal_pad(dpi(15)),
      cpu_heading,
      helpers.horizontal_pad(dpi(15)),
      {
        helpers.vertical_pad(dpi(5)),
        cpu_bar,
        helpers.vertical_pad(dpi(5)),
        layout = wibox.layout.align.vertical
      },
      helpers.horizontal_pad(dpi(15)),
      layout = wibox.layout.fixed.horizontal
    },
    helpers.vertical_pad(dpi(15)),
    {
      helpers.horizontal_pad(dpi(15)),
      ram_heading,
      helpers.horizontal_pad(dpi(15)),
      {
        helpers.vertical_pad(dpi(5)),
        ram_bar,
        helpers.vertical_pad(dpi(5)),
        layout = wibox.layout.align.vertical
      },
      helpers.horizontal_pad(dpi(15)),
      layout = wibox.layout.fixed.horizontal
    },
    helpers.vertical_pad(dpi(15)),
    {
      helpers.horizontal_pad(dpi(15)),
      disk_heading,
      helpers.horizontal_pad(dpi(15)),
      {
        helpers.vertical_pad(dpi(5)),
        disk_bar,
        helpers.vertical_pad(dpi(5)),
        layout = wibox.layout.align.vertical
      },
      helpers.horizontal_pad(dpi(15)),
      layout = wibox.layout.fixed.horizontal
    },
    -- helpers.vertical_pad(dpi(5)),
    layout = wibox.layout.fixed.vertical
}

local performance_box = create_box(perform_bar_widgets)

local user_bar_widgets = wibox.widget {
    -- helpers.vertical_pad(dpi(5)),
    {
      helpers.horizontal_pad(dpi(15)),
      vol_heading,
      helpers.horizontal_pad(dpi(15)),
      {
        helpers.vertical_pad(dpi(5)),
        vol_bar,
        helpers.vertical_pad(dpi(5)),
        layout = wibox.layout.align.vertical
      },
      helpers.horizontal_pad(dpi(15)),
      layout = wibox.layout.fixed.horizontal
    },
    helpers.vertical_pad(dpi(15)),
    {
      helpers.horizontal_pad(dpi(15)),
      bri_heading,
      helpers.horizontal_pad(dpi(15)),
      {
        helpers.vertical_pad(dpi(5)),
        bri_bar,
        helpers.vertical_pad(dpi(5)),
        layout = wibox.layout.align.vertical
      },
      helpers.horizontal_pad(dpi(15)),
      layout = wibox.layout.fixed.horizontal
    },
    helpers.vertical_pad(dpi(15)),
    {
      helpers.horizontal_pad(dpi(15)),
      mpd_heading,
      helpers.horizontal_pad(dpi(15)),
      {
        helpers.vertical_pad(dpi(5)),
        mpd_bar,
        helpers.vertical_pad(dpi(5)),
        layout = wibox.layout.align.vertical
      },
      helpers.horizontal_pad(dpi(15)),
      layout = wibox.layout.fixed.horizontal
    },
    -- helpers.vertical_pad(dpi(5)),
    layout = wibox.layout.fixed.vertical
}


local user_box = create_box(user_bar_widgets)

--}}}

--{{{ newsboat

local newsboat_fg = beautiful.xcolor6

local newsboat_heading = wibox.widget({
        align = "center",
        valign = "center",
        font = small_font,
        markup = helpers.colorize_text("?", newsboat_fg),
        widget = wibox.widget.textbox()
})

awesome.connect_signal("evil::newsboat", function(unread_items)
  newsboat_heading.markup = helpers.colorize_text(tostring(unread_items), newsboat_fg)
end)


local newsboat_info = wibox.widget({
        align = "center",
        valign = "center",
        font = "Sans medium 10",
        markup = helpers.colorize_text(" <i>unread articles\nin <b>Newsboat</b></i>", newsboat_fg),
        widget = wibox.widget.textbox()
})

local news_box = create_half_box(newsboat_heading, newsboat_info)

--}}}

--{{{ cpu temp

local temp_fg = beautiful.xcolor2

local temp_heading = wibox.widget({
        align = "center",
        valign = "center",
        font = small_font,
        markup = helpers.colorize_text("?", temp_fg),
        widget = wibox.widget.textbox()
})

awesome.connect_signal("evil::temp", function(temperatur)
  temp_heading.markup = helpers.colorize_text(tostring(temperatur) .. "°C", temp_fg)
end)


local temp_info = wibox.widget({
        align = "center",
        valign = "center",
        font = "Sans medium 10",
        markup = helpers.colorize_text(" <i>Temperature\nin <b>CPU</b></i>", temp_fg),
        widget = wibox.widget.textbox()
})

local temp_box = create_half_box(temp_heading, temp_info)

--}}}

--{{{ fortune box

local fortune_command = "fortune -n 50 -s"
local fortune_update_interval = 360
-- local fortune_command = "fortune -n 140 -s computers"
local fortune = wibox.widget {
    text = "Loading your cookie...",
    align = "center",
    valign = "center",
    font = "Sans medium 10",
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

local fortune_widget = wibox.widget {
    {
        nil,
        fortune,
        layout = wibox.layout.align.horizontal,
    },
    margins = 4,
    color = "#00000000",
    widget = wibox.container.margin
}

local fortune_box = create_half_box(nil, fortune_widget)
--}}}

--{{{ weather temp

local weather_fg = beautiful.xcolor1

local weather_heading = wibox.widget({
        align = "center",
        valign = "center",
        font = small_font,
        markup = helpers.colorize_text("?", temp_fg),
        widget = wibox.widget.textbox()
})

local weather_info = wibox.widget({
        align = "center",
        valign = "center",
        font = "Sans medium 10",
        markup = helpers.colorize_text(" <i>Temperature\n<b>IRL</b></i>", weather_fg),
        widget = wibox.widget.textbox()
})

awesome.connect_signal("evil::weather", function(temp, wind, emoji)
  weather_heading.markup = helpers.colorize_text(tostring(temp) .. "°C", weather_fg)
  weather_info.markup = helpers.colorize_text(" <i>Temperature\n<b>IRL</b> (" .. tostring(wind) .. "km/h wind)</i>", weather_fg)
end)

local weather_box = create_half_box(weather_heading, weather_info)

--}}}



--{{{ mpd

local mpd_wid = require("ui.widget.mpd").create(bar_background)
local mpd_box = create_box(mpd_wid)

--}}}


--{{{ TODO finish activity watch piechart 


local piechart = wibox.widget {
    data_list = {
        { 'L1', 100 },
        { 'L2', 200 },
        { 'L3', 300 },
    },
    border_width = 1,
    border_color = beautiful.xfg,
    colors = {
        beautiful.xcolor2,
        beautiful.xcolor1,
        beautiful.xcolor5,
    },
    forced_height = dpi(65),
    widget = wibox.widget.piechart
}

function string:split(pat)
  pat = pat or '%s+'
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end
end


local activitywatch_script = [[
    bash -c "
    python $HOME/prog/python/aw_notify.py
"]]

local update_interval = 2*60

awful.widget.watch(activitywatch_script, update_interval, function(_, stdout)
    local new_data_list = {}
    -- iterate through lines
    for line in stdout:split("\n") do
        local _app = string.match(line, "^.*[a-zA-Z]")
        local _time = string.match(line, "[0-9.].*$")
        if _app ~= "" and _time ~= "" then
            -- saftey to not have empty elements in there
            if not tonumber(_time) then
                _app = ""
                _time = 0
            end
            new_data_list[#new_data_list+1] = {_app, tonumber(_time)}
        end
    end
    piechart.data_list = new_data_list
    --piechart.data_list = {{'Terminal', 2.6}, {'Internet', 3.4}}
end)

local acititywatch_box = create_half_box(piechart, nil)

--}}}

awful.screen.connect_for_each_screen(function(s)

  -- s.myplacehodler = awful.wibar({ position=dashboard_position, screen=s, width=dashboard_width , bg="#00000000", opacity=0, ontop=false, visible=false })

  local x
  local y

  if dashboard_position == "left" then
      x = s.workarea.x
      y = s.workarea.y + 2*beautiful.useless_gap
  elseif dashboard_position == "right" then
      x = s.workarea.x + s.workarea.width - dashboard_width
      y = s.workarea.y + 2*beautiful.useless_gap
  end

  s.mybar = wibox {
     x = x,
     y = y,
     bg = dashboard_bg,
     fg = beautiful.xfg,
     shape = helpers.rrect(beautiful.corner_radius),
     height = s.workarea.height - 4*beautiful.useless_gap,
     width = dashboard_width - 2*beautiful.useless_gap,
     visible = false,
     ontop = true
  }

  s.mybar:setup {
      layout = wibox.layout.fixed.vertical,
      -- expand = "none",
      fancy_time_box,
      performance_box,
      {
        news_box,
        temp_box,
        layout = wibox.layout.fixed.horizontal,
      },
      --acititywatch_box,
      user_box,
      {
	  weather_box,
	  fortune_box,
        layout = wibox.layout.fixed.horizontal,
      },
      mpd_box,
  }

  s.mybar:connect_signal("mouse::leave", function() awesome.emit_signal("toggle::dash") end)

  -- shortcut to toggle sidebar
  awesome.connect_signal("toggle::dash", function()
      -- s.myplacehodler.visible = not s.myplacehodler.visible
      s.mybar.visible = not s.mybar.visible
  end)

  -- helper function to update the sidebar
  -- should be "solid" when only one client is on the selected tag and "floating with rounded corners" if there are multiple
  local function update_sidebar(t, c)
      local clients = t:clients()
      local client_count = 0
      for _, c in ipairs(clients) do 
          if not (c.floating or c.minimized) then 
              client_count = client_count + 1
          end 
      end 
    if client_count == 1 or t.layout.name == "max" then
      s.mybar.shape = helpers.rrect(0)
      s.mybar.height = s.workarea.height
      s.mybar.width = dashboard_width
      s.mybar.y = s.workarea.y
    else
      s.mybar.shape = helpers.rrect(beautiful.corner_radius)
      s.mybar.height = s.workarea.height - 4*beautiful.useless_gap
      s.mybar.width = dashboard_width - 2*beautiful.useless_gap
      s.mybar.y = s.workarea.y + 2*beautiful.useless_gap
    end
  end

  -- connect all important signals
  -- tag.connect_signal("tagged", function(t, c) update_sidebar(t, c) end)
  -- tag.connect_signal("untagged", function(t, c) update_sidebar(t, c) end)
  -- tag.connect_signal("property::selected", function(t) update_sidebar(t) end)
  -- client.connect_signal("property::minimized", function(c) local t = c.first_tag update_sidebar(t) end)

end)
