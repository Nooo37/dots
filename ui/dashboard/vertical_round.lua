local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi   = require("beautiful").xresources.apply_dpi

local helpers = require("ui.helpers")

local dashboard_width = dpi(400)
local secondary_bg = beautiful.xbg
local dashboard_bg = beautiful.xbgdark
local dashboard_position = "right"

--- {{{ Clock and date

local fancy_time_widget = wibox.widget.textclock("%H%M")

fancy_time_widget:connect_signal("widget::redraw_needed", function()
    fancy_time_widget.markup = fancy_time_widget.text:sub(1, 2) ..
                              helpers.colorize_text(fancy_time_widget.text:sub(3, 4), beautiful.xcolor12)
end)
fancy_time_widget.fg = beautiful.xfg
fancy_time_widget.align = "center"
fancy_time_widget.valign = "center"
fancy_time_widget.font = "JetBrains Mono 55"

local fancy_time = {fancy_time_widget, layout = wibox.layout.fixed.vertical}


local fancy_date_widget = wibox.widget.textclock('%A %B %d, %Y')
fancy_date_widget.markup = helpers.colorize_text(fancy_date_widget.text, beautiful.xcolor12)
fancy_date_widget:connect_signal("widget::redraw_needed", function()
    fancy_date_widget.markup = helpers.colorize_text(fancy_date_widget.text, beautiful.xcolor12)
end)
fancy_date_widget.align = "center"
fancy_date_widget.valign = "center"
fancy_date_widget.font = "JetBrains Mono 15"

local fancy_date = {fancy_date_widget, layout = wibox.layout.fixed.vertical}


local fancy_time_box = wibox.widget {
  {
    {
      {
          helpers.vertical_pad(dpi(25)),
          fancy_time,
          fancy_date,
          helpers.vertical_pad(dpi(25)),
          layout = wibox.layout.fixed.vertical
      },
      forced_width = dashboard_width * 0.7,
      left = dpi(20),
      right = dpi(20),
      bottom = dpi(20),
      top = dpi(20),
      widget = wibox.container.margin,
    },
    shape = helpers.rrect(beautiful.corner_radius),
    bg = secondary_bg, --"#00000077",
    widget = wibox.container.background
  },
  forced_width = dashboard_width * 0.85,
  left = dpi(20),
  right = dpi(20),
  bottom = dpi(20),
  top = dpi(20),
  widget = wibox.container.margin,
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

local cpu_bar = create_blank_bar(beautiful.xcolor1, beautiful.xcolor9, beautiful.xcolor8)

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

local ram_bar = create_blank_bar(beautiful.xcolor2, beautiful.xcolor10, beautiful.xcolor8)

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

local disk_bar = create_blank_bar(beautiful.xcolor3, beautiful.xcolor11, beautiful.xcolor8)

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

local vol_bar = create_blank_bar(beautiful.xcolor4, beautiful.xcolor12, beautiful.xcolor8)

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

local mpd_bar = create_blank_bar(beautiful.xcolor6, beautiful.xcolor14, beautiful.xcolor8)

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

local bri_bar = create_blank_bar(beautiful.xcolor5, beautiful.xcolor13, beautiful.xcolor8)

awesome.connect_signal("evil::brightness", function(percentage)
  bri_bar.value = tonumber(percentage)*100
end)


--}}}

--{{{ conglomarat of bars

local perform_bar_widgets = wibox.widget {
    helpers.vertical_pad(dpi(15)),
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
    helpers.vertical_pad(dpi(15)),
    layout = wibox.layout.fixed.vertical
}

local performance_box = wibox.widget {
  {
    {
      perform_bar_widgets,
      forced_width = dashboard_width * 0.7,
      left = dpi(20),
      right = dpi(20),
      bottom = dpi(20),
      top = dpi(20),
      widget = wibox.container.margin,
    },
    shape = helpers.rrect(beautiful.corner_radius),
    bg = secondary_bg, --"#00000077",
    widget = wibox.container.background
  },
  forced_width = dashboard_width * 0.85,
  left = dpi(20),
  right = dpi(20),
  bottom = dpi(20),
  widget = wibox.container.margin,
}

local user_bar_widgets = wibox.widget {
    helpers.vertical_pad(dpi(15)),
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
    layout = wibox.layout.fixed.vertical
}

local user_box = wibox.widget {
  {
    {
      user_bar_widgets,
      forced_width = dashboard_width * 0.7,
      left = dpi(20),
      right = dpi(20),
      bottom = dpi(20),
      top = dpi(20),
      widget = wibox.container.margin,
    },
    shape = helpers.rrect(beautiful.corner_radius),
    bg = secondary_bg, --"#00000077",
    widget = wibox.container.background
  },
  forced_width = dashboard_width * 0.85,
  left = dpi(20),
  right = dpi(20),
  bottom = dpi(20),
  widget = wibox.container.margin,
}

--}}}


--{{{ Create half box

local function create_half_box(heading, body)
  return wibox.widget {
    {
        {
          nil,
          {
            helpers.vertical_pad(dpi(15)),
            heading,
            body,
            helpers.vertical_pad(dpi(15)),
            layout = wibox.layout.fixed.vertical
          },
          nil,
          layout = wibox.layout.align.vertical
        },
      bg = secondary_bg,
      shape = helpers.rrect(dpi(20)),
      forced_width = dpi(165),
      widget = wibox.container.background
    },
    left = dpi(20),
    bottom = dpi(20),
    widget = wibox.container.margin
  }
end

--}}}


--{{{ newsboat

local newsboat_fg = beautiful.xcolor6

local newsboat_heading = wibox.widget({
        align = "center",
        valign = "center",
        font = "Sans bold 20",
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
        font = "Sans bold 20",
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
        markup = helpers.colorize_text(" <i>Temperatur\nin <b>CPU</b></i>", temp_fg),
        widget = wibox.widget.textbox()
})

local temp_box = create_half_box(temp_heading, temp_info)

--}}}

--{{{ weather temp

local weather_fg = beautiful.xcolor1

local weather_heading = wibox.widget({
        align = "center",
        valign = "center",
        font = "Sans bold 20",
        markup = helpers.colorize_text("?", temp_fg),
        widget = wibox.widget.textbox()
})

local weather_info = wibox.widget({
        align = "center",
        valign = "center",
        font = "Sans medium 10",
        markup = helpers.colorize_text(" <i>Temperatur\n<b>IRL</b></i>", weather_fg),
        widget = wibox.widget.textbox()
})

awesome.connect_signal("evil::weather", function(temp, wind, emoji)
  weather_heading.markup = helpers.colorize_text(tostring(temp) .. "°C", weather_fg)
  weather_info.markup = helpers.colorize_text(" <i>Temperatur\n<b>IRL</b> (" .. tostring(wind) .. "km/h wind)</i>", weather_fg)
end)

local weather_box = create_half_box(weather_heading, weather_info)

--}}}



--{{{ mpd

local mpd_box = wibox.widget {
  {
    {
      require("ui.widget.mpd").create(),
      forced_width = dashboard_width * 0.7,
      left = dpi(20),
      right = dpi(20),
      bottom = dpi(20),
      top = dpi(20),
      widget = wibox.container.margin,
    },
    shape = helpers.rrect(beautiful.corner_radius),
    -- forced_width = dashboard_width * 0.8,
    bg = secondary_bg, --"#00000077",
    widget = wibox.container.background
  },
  forced_width = dashboard_width * 0.85,
  left = dpi(20),
  right = dpi(20),
  bottom = dpi(20),
  widget = wibox.container.margin,
}

--}}}


awful.screen.connect_for_each_screen(function(s)

  s.myplacehodler = awful.wibar({ position=dashboard_position, screen=s, width=dashboard_width , bg="#00000000", opacity=0, ontop=false, visible=false })

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
     visible = false
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
      user_box,
      {
        weather_box,
        void_box,
        layout = wibox.layout.fixed.horizontal,
      },
      mpd_box,
  }

  -- shortcut to toggle sidebar
  awesome.connect_signal("toggle::sidebar", function()
      s.myplacehodler.visible = not s.myplacehodler.visible
      s.mybar.visible = not s.mybar.visible
  end)

  -- helper function to update the sidebar
  -- should be "solid" when only one client is on the selected tag and "floating with rounded corners" if there are multiple
  local function update_sidebar(t)
    local clients = t:clients()
    if #clients == 1 then
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
  tag.connect_signal("tagged", function(t) update_sidebar(t) end)
  tag.connect_signal("untagged", function(t) update_sidebar(t) end)
  tag.connect_signal("property::selected", function(t) update_sidebar(t) end)

end)
