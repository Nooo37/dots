local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty       = require("naughty")
local dpi           = require("beautiful").xresources.apply_dpi
local my_table = awful.util.table or gears.table

local helpers = require("ui.helpers")

local statusbar_font = "Droid Sans Bold 7.5"


--{{{ MPD

local mpdtextbox = wibox.widget.textbox("s")
mpdtextbox.font = statusbar_font


local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_height = 5,
          bg = beautiful.xcolor2,
          widget  = wibox.container.background,
}

awesome.connect_signal("evil::mpd", function(artist, title, paused)
  if not paused then --♫‒
    mpdtextbox.text = "   " .. title:upper() .. "  -  " .. artist:upper() .. "  "
    temp_wid.forced_height = 5
  else --⏵
    mpdtextbox.text = "    "
    temp_wid.forced_height = 0
  end
end)

local mpdbox = wibox.widget {
      helpers.vertical_pad(2),
      mpdtextbox,
      temp_wid,
      layout = wibox.layout.fixed.vertical,
}

--}}}

--{{{ Clock

local clocktextbox = wibox.widget.textclock(" %R ") -- old:  %a, %d %b %R
clocktextbox.font = statusbar_font

local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_height = 5,
          bg = beautiful.xcolor1,
          widget  = wibox.container.background,
}

local clockbox = wibox.widget {
  helpers.vertical_pad(2),
  clocktextbox,
  temp_wid,
  layout = wibox.layout.fixed.vertical,
}

--}}}
--{{{ Volume


local volumetextbox = wibox.widget.textbox("?%")
volumetextbox.font = statusbar_font
awesome.connect_signal("evil::volume", function(volume_int, muted)
  if muted then --🕨
    volumetextbox.text = "    muted  "
  elseif volume_int < 10 then --🕨
    volumetextbox.text = "  " .. tostring(volume_int) .. "% "
  elseif volume_int < 50 then --🕩
    volumetextbox.text = "  " ..  tostring(volume_int) .. "% "
  else --🕪
    volumetextbox.text = "  " .. tostring(volume_int) .. "% "
  end
end)

local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_height = 5,
          bg = beautiful.xcolor4,
          widget  = wibox.container.background,
}

local volumebox = wibox.widget {
      helpers.vertical_pad(2),
      volumetextbox,
      temp_wid,
      layout = wibox.layout.fixed.vertical,
}

--}}}

awful.screen.connect_for_each_screen(function(s)
   -- Create a promptbox for each screen
   s.mypromptbox = awful.widget.prompt()

   local systraybox = wibox.widget {
     helpers.vertical_pad(2),
     {
        wibox.widget.systray(),
        bg = "#00000000",
        forced_height = dpi(13),
        widget = wibox.container.background
      },
      temp_wid,
      layout = wibox.layout.fixed.vertical
   }

   -- Create a custom taglist widget
   -- s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons) -- langweilig
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
           layout  = wibox.layout.fixed.horizontal
       },
       widget_template = {
           {
               {
                     helpers.vertical_pad(2),
                     {
                       helpers.horizontal_pad(5),
                       {
                         id     = 'text_role',
                         widget = wibox.widget.textbox,
                       },
                       helpers.horizontal_pad(5),
                       layout = wibox.layout.fixed.horizontal,
                     },
                     {
                          {
                            text = "",
                            widget = wibox.widget.textbox,
                          },
                         id = 'background_role',
                         forced_height = 5,
                         -- forced_width = 45,
                         widget  = wibox.container.background,
                     },
                   layout = wibox.layout.fixed.vertical,
               },
               left  = 18,
               right = 18,
               widget = wibox.container.margin
           },
           widget = wibox.container.background,
       },
       buttons = awful.util.taglist_buttons
   }

   -- Create the wibox
   s.mywibar = awful.wibar({ position = "top", screen = s, height = 19, bg = beautiful.xbg, fg = beautiful.xfg, opacity=1, visible=true })


   -- =====================================================
   -- The status bar -> it's all comming together
   -- =====================================================
   s.mywibar:setup {
       layout = wibox.layout.align.horizontal,
       expand = "none",
       { -- Left widgets
           layout = wibox.layout.fixed.horizontal,
           s.mytaglist,
           s.mytasklist,
           nil
       },
       {
          nil, -- Middle widgets lol
          layout = wibox.layout.align.horizontal,
       },
       { -- Right widgets
           layout = wibox.layout.fixed.horizontal,
           -- wibox.widget.systray(),
           helpers.horizontal_pad(12),
           mpdbox,
           helpers.horizontal_pad(12),
           volumebox,
           helpers.horizontal_pad(12),
           clockbox,
           helpers.horizontal_pad(6),
       },
   }
end)
