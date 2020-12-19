local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("beautiful").xresources.apply_dpi
local beautiful = require("beautiful")


local helpers = require("ui.helpers")

local statusbar_font = "Hack Bold 9"
local highlight_width = 5

--{{{ Clock

local clocktextbox = wibox.widget.textclock("%R") -- old:  %a, %d %b %R
clocktextbox.font = statusbar_font
clocktextbox.markup = helpers.colorize_text(clocktextbox.text, beautiful.xcolor3)
clocktextbox.align = "center"
clocktextbox.valign = "center"

clocktextbox:connect_signal("widget::redraw_needed", function()
  clocktextbox.markup = helpers.colorize_text(clocktextbox.text, beautiful.xcolor3)
end)

local clockbox = wibox.widget {
  {
      clocktextbox,
      top   = 5,
      bottom = 5,
      widget = wibox.container.margin
  },
  bg = beautiful.xbglight,
  widget = wibox.container.background
}

--}}}

--{{{ Date

local datetextbox = wibox.widget.textclock("%d.%m") -- old:  %a, %d %b %R
datetextbox.font = statusbar_font
datetextbox.align = "center"
datetextbox.valign = "center"

local datebox = datetextbox
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
                      nil,
                      {
                         {
                              nil,
                             {
                                {
                                  id     = 'text_role',
                                  align  = "center",
                                  valign = "center",
                                  widget = wibox.widget.textbox,
                                },
                                top   = 5,
                                bottom = 5,
                                left  = 5,
                                right = 5,
                                widget = wibox.container.margin
                              },
                              nil,
                              layout = wibox.layout.align.horizontal,
                         },
                         id = 'background_role',
                         forced_width = highlight_width,
                         widget  = wibox.container.background,
                      },
                      nil,
                      layout = wibox.layout.align.horizontal,
       },
       buttons = awful.util.taglist_buttons
   }

   local statusbar_width = dpi(40)
   -- Create the wibar
   s.mywibar = awful.wibar({ position = "left", screen = s, width = statusbar_width, bg=beautiful.xbg, opacity=1, ontop=false, visible=true })
   -- Create the wibox

   s.mywibar:setup {
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
           helpers.vertical_pad(8),
           -- bar,
           helpers.vertical_pad(8),
           volumebox,
           helpers.vertical_pad(8),
           clockbox,
           helpers.vertical_pad(4),
           datebox,
           helpers.vertical_pad(15),
           -- datebox,
       },
   }

   awesome.connect_signal("toggle::bar", function() 
        s.mywibar.visible = not s.mywibar.visible
   end)
end)
