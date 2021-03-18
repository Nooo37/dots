local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("beautiful").xresources.apply_dpi
local beautiful = require("beautiful")


local helpers = require("ui.helpers")

local statusbar_font = "JetBrainsMono NF Bold 9"
local highlight_width = 5

local statusbar_width = dpi(35)


local function format_progress_bar(bar)
    bar.shape = helpers.rrect(beautiful.border_radius - 3)
    bar.bar_shape = helpers.rrect(beautiful.border_radius - 3)
    bar.background_color = beautiful.xcolor0
    return bar
end

local function format_entry(wid, inner_pad)
    return {
                    {
                        {
                            wid,
                            margins = dpi(inner_pad or 5),
                            widget = wibox.container.margin
                        },
                        bg = beautiful.xcolor0,
                        shape = helpers.rrect(beautiful.border_radius - 3),
                        widget = wibox.container.background
                    },
                    margins = dpi(5),
                    widget = wibox.container.margin
    }
end

--{{{ Clock


local hourtextbox = wibox.widget.textclock("%H") -- old:  %a, %d %b %R
hourtextbox.font = statusbar_font
hourtextbox.markup = helpers.colorize_text(hourtextbox.text, beautiful.xcolor4)
hourtextbox.align = "center"
hourtextbox.valign = "center"

local minutetextbox = wibox.widget.textclock("%M") -- old:  %a, %d %b %R
minutetextbox.font = statusbar_font
minutetextbox.markup = helpers.colorize_text(minutetextbox.text, beautiful.xcolor4)
minutetextbox.align = "center"
minutetextbox.valign = "center"

hourtextbox:connect_signal("widget::redraw_needed", function()
  hourtextbox.markup = helpers.colorize_text(hourtextbox.text, beautiful.xcolor3)
end)

-- hourtextbox:emit_signal("widget::redraw_needed")
-- minutetextbox:emit_signal("widget::redraw_needed")

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
    bg = beautiful.xcolor0,
    widget = wibox.container.background
}

local datetooltip = awful.tooltip {};
datetooltip.shape = helpers.prrect(beautiful.border_radius - 3, true, true,
                                       false, false)
datetooltip.preferred_alignments = {"middle", "front", "back"}
datetooltip.mode = "outside"
datetooltip:add_to_object(clockbox)
datetooltip.text = os.date("%d.%m.%y")

---}}}

---{{{
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
battery_tooltip.shape = helpers.prrect(beautiful.border_radius - 3, true, true,
                                       false, false)
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

---}}}

---{{{ taglist buttons
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
---}}}

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
                                top = 5,
                                bottom = 5,
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
       buttons = taglist_buttons
   }


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
   }

   -- Create the wiboxa
   s.mywibox = wibox {
       width = statusbar_width,
       height = s.geometry.height - 4*beautiful.useless_gap,
       x = 0,
       y = 2 * beautiful.useless_gap,
       ontop = true,
       visible = true,
       shape = helpers.prrect(beautiful.border_radius, false, true, true, false),
       bg = beautiful.xbg,
   }

   s.mywibox:setup {
       layout = wibox.layout.align.vertical,
       -- expand = "none",
       { -- Top widgets
           layout = wibox.layout.fixed.vertical,
           helpers.vertical_pad(10),
           format_entry(s.mytaglist),
       },
       nil, -- Middle widgets
       { -- Bottom widgets
           layout = wibox.layout.fixed.vertical,
           helpers.vertical_pad(8),
           battery,
           format_entry(clockbox),
           format_entry(s.mylayoutbox),
           helpers.vertical_pad(6),
       },
   }

   awesome.connect_signal("toggle::bar", function()
                              s.mywibar.visible = not s.mywibar.visible
                              s.mywibox.visible = not s.mywibox.visible
   end)

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
           s.mywibox.y = 0
       else
           s.mywibox.shape = helpers.prrect(beautiful.border_radius, false, true, true, false)
           s.mywibox.height = s.geometry.height - 4*beautiful.useless_gap
           s.mywibox.y = 2*beautiful.useless_gap
       end
   end

   -- connect all important signals
   tag.connect_signal("tagged", function(t, c) update_bar(t, c) end)
   tag.connect_signal("untagged", function(t, c) update_bar(t, c) end)
   tag.connect_signal("property::selected", function(t) update_bar(t) end)
   client.connect_signal("property::minimized", function(c) local t = c.first_tag update_bar(t) end)


end)


return doit
