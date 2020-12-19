-- Since that wibar makes use of gaps, you should change "gap_single_client" to true
-- TODO add support for change gap size on the fly

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("beautiful").xresources.apply_dpi
local beautiful = require("beautiful")


local helpers = require("ui.helpers")

local statusbar_font = "Hack Bold"
local statusbar_bg = beautiful.xbg
local statusbar_width = 35
local highlight_width = 4

--{{{ Clock

local clocktextbox = wibox.widget.textclock("%R") --\n%d.%m") -- old:  %a, %d %b %R
clocktextbox.font = statusbar_font .. " 8.5"

local temp_wid = wibox.widget {
          wibox.widget.textbox(""),
          forced_width = highlight_width,
          bg = beautiful.xcolor1,
          widget  = wibox.container.background,
}


local clocktextbox_rotated  = wibox.container {
    clocktextbox,
    direction = 'east',
    widget    = wibox.container.rotate
}

local clockbox = wibox.widget {
  helpers.horizontal_pad(3),
  {
      clocktextbox_rotated,
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
volumetextbox.font = statusbar_font .. " 9"

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

local volumetextbox_rotated = wibox.container {
    volumetextbox,
    direction = 'east',
    widget    = wibox.container.rotate
}

local volumebox = wibox.widget {
  helpers.horizontal_pad(4),
  {
      volumetextbox_rotated,
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

-- Define taglist_buttons
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
                )

awful.screen.connect_for_each_screen(function(s)

   -- Create a custom taglist widget
   s.mytaglist = awful.widget.taglist {
       screen  = s,
       filter  = awful.widget.taglist.filter.all,
       style   = {
           -- shape = helpers.rrect(5),
           font  = statusbar_font .. " 9"
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
                         left  = 3,
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
       buttons = taglist_buttons
   }

   -- Create the wibar
   s.mywibar = awful.wibar({ position = "left", screen = s, width = statusbar_width, bg="#00000000", opacity=0, ontop=false, visible=true })
   -- Create the wibox
   s.mywibox = wibox {
      x = 2*beautiful.useless_gap,
      y = 2*beautiful.useless_gap,
      bg = statusbar_bg,
      fg = beautiful.xfg,
      shape = helpers.rrect(beautiful.corner_radius),
      height = s.geometry.height - 4*beautiful.useless_gap,
      width = statusbar_width - 2*beautiful.useless_gap,
      visible = true
   }

   -- Create promptbox
   s.mypromptbox = awful.widget.prompt()

   s.mywibox:setup {
       layout = wibox.layout.align.vertical,
       -- expand = "none",
       { -- Top widgets
           layout = wibox.layout.fixed.vertical,
           helpers.vertical_pad(10),
           s.mytaglist,
           s.mypromptbox,
       },
       {
          nil, -- Middle widgets lol
          layout = wibox.layout.align.vertical,
       },
       { -- Bottom widgets
           layout = wibox.layout.fixed.vertical,
           -- systraybox,
           helpers.vertical_pad(8),
           volumebox,
           helpers.vertical_pad(8),
           clockbox,
           helpers.vertical_pad(15),
           -- datebox,
       },
   }

   -- helper function to update the bar
   -- should be "solid" when only one client is on the selected tag and "floating with rounded corners" if there are multiple
   local function update_bar(t, c)
     local clients = t:clients()
     local client_count = 0
     for _, c in ipairs(clients) do 
        if not(c.floating or c.minimized) then 
            client_count = client_count + 1
        end 
    end
     if client_count == 1 or t.layout.name == "max" then
       s.mywibox.shape = helpers.rrect(0)
       s.mywibox.height = s.geometry.height
       s.mywibox.width = statusbar_width
       s.mywibox.x = 0
       s.mywibox.y = 0
     else
       s.mywibox.shape = helpers.rrect(beautiful.corner_radius)
       s.mywibox.height = s.geometry.height - 4*beautiful.useless_gap
       s.mywibox.width = statusbar_width - 2*beautiful.useless_gap
       s.mywibox.x = 2*beautiful.useless_gap
       s.mywibox.y = 2*beautiful.useless_gap
     end
   end

   awesome.connect_signal("toggle::bar", function()
       s.mywibar.visible = not s.mywibar.visible
       s.mywibox.visible = not s.mywibox.visible
   end)

   -- connect all important signals
   tag.connect_signal("tagged", function(t, c) update_bar(t, c) end)
   tag.connect_signal("untagged", function(t, c) update_bar(t, c) end)
   tag.connect_signal("property::selected", function(t) update_bar(t) end)
   client.connect_signal("property::minimized", function(c) local t = c.first_tag update_bar(t) end)
end)
