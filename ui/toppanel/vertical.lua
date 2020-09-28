-- Since that wibar makes use of gaps, you should change "gap_single_client" to true
-- TODO add support for change gap size on the fly

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("beautiful").xresources.apply_dpi
local beautiful = require("beautiful")


local helpers = require("ui.helpers")

local statusbar_font = "Hack Bold 9"
local highlight_width = 5

--{{{ Clock

local clocktextbox = wibox.widget.textclock("%R\n%d.%m") -- old:  %a, %d %b %R
clocktextbox.font = statusbar_font

local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_width = highlight_width,
          bg = beautiful.xcolor1,
          widget  = wibox.container.background,
}

local clockbox = wibox.widget {
  helpers.horizontal_pad(4),
  {
      clocktextbox,
      top   = 5,
      bottom = 5,
      widget = wibox.container.margin
  },
  temp_wid,
  layout = wibox.layout.align.horizontal,
}

--}}}

--{{{ Volume

local volumetextbox = wibox.widget.textbox("?%")
volumetextbox.font = statusbar_font

awesome.connect_signal("evil::volume", function(volume_int, muted)
  if muted then --🕨
    volumetextbox.text = "mut"
  elseif volume_int < 10 then --🕨
    volumetextbox.text = " " .. tostring(volume_int) .. "%"
  elseif volume_int < 50 then --🕩
    volumetextbox.text = " " ..  tostring(volume_int) .. "%"
  else --🕪
    volumetextbox.text = " " .. tostring(volume_int) .. "%"
  end
end)

local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_width = highlight_width,
          bg = beautiful.xcolor12,
          widget  = wibox.container.background,
}


local volumebox = wibox.widget {
  helpers.horizontal_pad(4),
  {
      volumetextbox,
      top   = 5,
      bottom = 5,
      widget = wibox.container.margin
  },
  temp_wid,
  layout = wibox.layout.align.horizontal,
}

--}}}

--{{{ systray

local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_width = highlight_width,
          bg = beautiful.xcolor10,
          widget  = wibox.container.background,
}

local systraybox = wibox.widget {
  helpers.horizontal_pad(10),
  {
      {
          wibox.widget.systray(false),
          bg = "#00000000",
          forced_height = dpi(13),
          widget = wibox.container.background
      },
      top   = 5,
      bottom = 5,
      widget = wibox.container.margin
  },
  temp_wid,
  layout = wibox.layout.align.horizontal
}

--}}}

awful.screen.connect_for_each_screen(function(s)

   -- Create a custom taglist widget
   s.mytaglist = awful.widget.taglist {
       screen  = s,
       filter  = awful.widget.taglist.filter.all,
       style   = {
           shape = gears.shape.rectangle,
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
                      helpers.horizontal_pad(5),
                      {
                         {
                           id     = 'text_role',
                           widget = wibox.widget.textbox,
                         },
                         top   = 5,
                         bottom = 5,
                         left  = 5,
                         right = 5,
                         widget = wibox.container.margin
                       },
                       {
                         {
                           text = "",
                           widget = wibox.widget.textbox,
                         },
                         id = 'background_role',
                         forced_width = highlight_width,
                         widget  = wibox.container.background,
                      },
                      layout = wibox.layout.align.horizontal,
       },
       buttons = awful.util.taglist_buttons
   }

   local statusbar_width = 62
   -- Create the wibar
   s.mywibox = awful.wibar({ position = "left", screen = s, width = statusbar_width, bg="#00000000", opacity=0, ontop=false, visible=true })
   -- Create the wibox
   s.mybar = wibox {
      x = 2*beautiful.useless_gap,
      y = 2*beautiful.useless_gap,
      bg = beautiful.xbg,
      fg = beautiful.xfg,
      shape = helpers.rrect(beautiful.corner_radius),
      height = s.geometry.height - 4*beautiful.useless_gap,
      width = statusbar_width - 2*beautiful.useless_gap,
      visible = true
   }

   s.mybar:setup {
       layout = wibox.layout.align.vertical,
       -- expand = "none",
       { -- Top widgets
           layout = wibox.layout.fixed.vertical,
           helpers.vertical_pad(10),
           s.mytaglist,
       },
       {
          nil, -- Middle widgets lol
          layout = wibox.layout.align.vertical,
       },
       { -- Bottom widgets
           layout = wibox.layout.fixed.vertical,
           systraybox,
           helpers.vertical_pad(8),
           volumebox,
           helpers.vertical_pad(8),
           clockbox,
           helpers.vertical_pad(15),
           -- datebox,
       },
   }
end)
