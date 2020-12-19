local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local tag = require("awful.tag")
local dpi           = require("beautiful").xresources.apply_dpi
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility


local helpers = require("ui.helpers")

local statusbar_height = 19

--{{{ MPD
local mpdtextbox = wibox.widget.textbox("s")
mpdtextbox.font = beautiful.font

awesome.connect_signal("evil::mpd", function(artist, title, paused)
    if not paused then
        mpdtextbox.text = " ♫  " .. title .. " ‒ " .. artist .. " "
        -- naughty = require("naughty")
        -- naughty.notify({title=new_text})
    else
        mpdtextbox.text = "  ⏵  "
    end
end)
--}}}

--{{{ VOLUME
local volumetextbox = wibox.widget.textbox("?%")
volumetextbox.font = beautiful.font
awesome.connect_signal("evil::volume", function(volume_int, muted)
  if muted then
    volumetextbox.text = " 🕨  muted "
  elseif volume_int < 10 then
    volumetextbox.text = " 🕨  " .. tostring(volume_int) .. "%"
  elseif volume_int < 50 then
    volumetextbox.text = " 🕩  " ..  tostring(volume_int) .. "%  "
  else
    volumetextbox.text = " 🕪  " .. tostring(volume_int) .. "%  "
  end
end)
--}}}

-- --{{{ CPU Usage
-- local cputextbox = wibox.widget.textbox("?%")
-- cputextbox.font = beautiful.font
-- awesome.connect_signal("evil::cpu", function(cpu_a)
--     cputextbox.text = " ⊠ " .. cpu_a .. "% "
-- end)
-- --}}}

-- --{{{ RAM Usage
-- local ramtextbox = wibox.widget.textbox("?")
-- ramtextbox.font = beautiful.font
-- awesome.connect_signal("evil::ram", function(used, total)
--     ramtextbox.text = " ⊟ " .. tostring(used) .. "MB "
-- end)
-- --}}}


--{{{ CLOCK
local clocktextbox = wibox.widget.textbox("?")
clocktextbox.font = beautiful.font
awful.widget.watch("date +' %a %d %b %R '", 60, function(_, stdout)
        clocktextbox.text = stdout
    end
)
--}}}


--{{{ Some powerarrow creators

local separators = { height = 0, width = 9 }

-- [[ Arrow
  -- Right
function separators.arrow_right(col1, col2)
    local widget = wibox.widget.base.make_widget()
    widget.col1 = col1
    widget.col2 = col2
    widget.fit = function(m, w, h)
        return separators.width, separators.height
    end

    widget.update = function(col1, col2)
        widget.col1 = col1
        widget.col2 = col2
        widget:emit_signal("widget::redraw_needed")
    end

    widget.draw = function(mycross, wibox, cr, width, height)
        if widget.col2 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(widget.col2))
            cr:new_path()
            cr:move_to(0, 0)
            cr:line_to(width, height/2)
            cr:line_to(width, 0)
            cr:close_path()
            cr:fill()

            cr:new_path()
            cr:move_to(0, height)
            cr:line_to(width, height/2)
            cr:line_to(width, height)
            cr:close_path()
            cr:fill()
        end

        if widget.col1 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(widget.col1))
            cr:new_path()
            cr:move_to(0, 0)
            cr:line_to(width, height/2)
            cr:line_to(0, height)
            cr:close_path()
            cr:fill()
        end
   end

   return widget
end

  -- Left
function separators.arrow_left(col1, col2)
    local widget = wibox.widget.base.make_widget()
    widget.col1 = col1
    widget.col2 = col2

    widget.fit = function(m, w, h)
        return separators.width, separators.height
    end

    widget.update = function(col1, col2)
        widget.col1 = col1
        widget.col2 = col2
        widget:emit_signal("widget::redraw_needed")
    end

    widget.draw = function(mycross, wibox, cr, width, height)
        if widget.col1 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(widget.col1))
            cr:new_path()
            cr:move_to(width, 0)
            cr:line_to(0, height/2)
            cr:line_to(0, 0)
            cr:close_path()
            cr:fill()

            cr:new_path()
            cr:move_to(width, height)
            cr:line_to(0, height/2)
            cr:line_to(0, height)
            cr:close_path()
            cr:fill()
        end

        if widget.col2 ~= "alpha" then
            cr:new_path()
            cr:move_to(width, 0)
            cr:line_to(0, height/2)
            cr:line_to(width, height)
            cr:close_path()

            cr:set_source_rgb(gears.color.parse_color(widget.col2))
            cr:fill()
        end
   end

   return widget
end

--}}}
------------


------------
-- Separators
local arrow = separators.arrow_left
local l_arrow = separators.arrow_right

function powerline_rl(cr, width, height)
    local arrow_depth, offset = height/2, 0

    -- Avoid going out of the (potential) clip area
    if arrow_depth < 0 then
        width  =  width + 2*arrow_depth
        offset = -arrow_depth
    end

    cr:move_to(offset + arrow_depth         , 0        )
    cr:line_to(offset + width               , 0        )
    cr:line_to(offset + width - arrow_depth , height/2 )
    cr:line_to(offset + width               , height   )
    cr:line_to(offset + arrow_depth         , height   )
    cr:line_to(offset                       , height/2 )
    cr:close_path()
end

local function pl(widget, bgcolor, padding)
    return wibox.container.background(wibox.container.margin(widget, 16, 16), bgcolor, powerline_rl)
end



-------------------
local clockmtextbox = wibox.widget.textbox("?")
awful.widget.watch("date +'   %R   '", 60, function(_, stdout)
        clockmtextbox.text = stdout
  end
)

local arrow_color = beautiful.xcolor2
local mbox = wibox.widget({
  layout = wibox.layout.fixed.horizontal,
  arrow("alpha", arrow_color),
  arrow(arrow_color, "alpha"),
  wibox.container.background(wibox.container.margin(clockmtextbox, 3, 4), taglist_bg),
  -- clockmtextbox,
  l_arrow("alpha", arrow_color),
  l_arrow(arrow_color, "alpha"),
})





local tag_main = wibox.container.background(wibox.widget.textbox(" [ main ] "), beautiful.xcolor2)
tag_main:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[1]
          if tag then
           tag:view_only()
        end
    end)
))



local taglist_powerarrows = wibox.widget({
  layout = wibox.layout.align.horizontal,
  l_arrow("alpha", "alpha"),
    l_arrow("alpha", beautiful.xcolor2),
  tag_main
})
--}}}

--{{{ Where it all comes together
awful.screen.connect_for_each_screen(function(s)
    -- All tags open with layout 1
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create tasklist widget
    s.mytasklist = awful.widget.tasklist {
          screen   = s,
          filter   = awful.widget.tasklist.filter.currenttags,
          buttons  = tasklist_buttons,
          style    = {
              shape  = gears.shape.powerline,
          },
          widget_template = {
              {
                  {
                      {
                          {
                              id     = 'icon_role',
                              widget = wibox.widget.imagebox,
                          },
                          margins = 2,
                          widget  = wibox.container.margin,
                      },
                      {
                          id     = 'text_role',
                          widget = wibox.widget.textbox,
                      },
                      layout = wibox.layout.fixed.horizontal,
                  },
                  left  = 10,
                  right = 10,
                  widget = wibox.container.margin
              },
              id     = 'background_role',
              widget = wibox.container.background,
          },
      }

      -- Create a taglist widget
      s.mytaglist = awful.widget.taglist {
          screen  = s,
          filter  = awful.widget.taglist.filter.all,
          style   = {
              shape = gears.shape.powerline
          },
          layout   = {
              spacing = 0,
              spacing_widget = {
                  -- color  = '#dddddd',
                  shape  = gears.shape.rectangle,
                  widget = wibox.widget.separator,
              },
              layout  = wibox.layout.fixed.horizontal
          },
          widget_template = {
              {
                  {
                      {
                        {
                          id     = 'text_role',
                          widget = wibox.widget.textbox,
                        },
                        margin = 4,
                        widget = wibox.container.margin,
                      },
                      layout = wibox.layout.align.horizontal,
                  },
                  left  = 18,
                  right = 18,
                  widget = wibox.container.margin
              },
              id     = 'background_role',
              widget = wibox.container.background,
          },
          buttons = awful.util.taglist_buttons
      }

      --------------

      -- Create the wibox
      s.mywibar = awful.wibar({ position = "top", screen = s, height = statusbar_height, bg = beautiful.xbg, fg = beautiful.xfg, opacity=1, visible=true })


      -- The status bar
      s.mywibar:setup {
          layout = wibox.layout.align.horizontal,
          expand = "none",
          { -- Left widgets
              layout = wibox.layout.fixed.horizontal,
              helpers.horizontal_pad(dpi(5)),
              s.mytaglist,
              l_arrow("alpha", "alpha"),
              l_arrow("alpha", beautiful.xcolor2),
              l_arrow(beautiful.xcolor2, "alpha"),
              s.mytasklist,
              nil
          },
          layout = wibox.layout.align.horizontal,
          -- min_widget_size = 1500,
          -- mbox,
          --clockmiddlbox, -- clock
          nil,
          { -- Right widgets
              layout = wibox.layout.fixed.horizontal,

              --
              arrow("alpha", beautiful.xcolor6),
              arrow(beautiful.xcolor6, "alpha"),
              wibox.container.background(wibox.container.margin(wibox.widget { nil, mpdtextbox, layout = wibox.layout.align.horizontal }, 3, 4), taglist_bg),
              arrow("alpha", beautiful.xcolor11),
              arrow(beautiful.xcolor11, "alpha"),
              wibox.container.background(wibox.container.margin(wibox.widget { nil, volumetextbox, layout = wibox.layout.align.horizontal }, 3, 4), taglist_bg),
              arrow("alpha", beautiful.xcolor4),
              arrow(beautiful.xcolor4, "alpha"),
              -- wibox.container.background(wibox.container.margin(wibox.widget { nil, ramtextbox, layout = wibox.layout.align.horizontal }, 3, 4), taglist_bg),
              -- arrow("alpha", beautiful.xcolor5),
              -- arrow(beautiful.xcolor5, "alpha"),
              -- wibox.container.background(wibox.container.margin(wibox.widget { nil, cputextbox, layout = wibox.layout.align.horizontal }, 3, 4), taglist_bg),
              -- arrow("alpha", beautiful.xcolor1),
              -- arrow(beautiful.xcolor1, "alpha"),
              wibox.container.background(wibox.container.margin(wibox.widget { nil, clocktextbox, layout = wibox.layout.align.horizontal }, 3, 4), taglist_bg),
              arrow("alpha", beautiful.xcolor2),
              arrow(beautiful.xcolor2, "alpha"),

              --[[ classic Powerarrows
              arrow("alpha", beautiful.xcolor6),
              wibox.container.background(wibox.container.margin(wibox.widget { mpdicon, mpdtextbox, layout = wibox.layout.align.horizontal }, 2, 3), beautiful.xcolor6),
              arrow(beautiful.xcolor6, beautiful.xcolor2),
              wibox.container.background(wibox.container.margin(wibox.widget { volicon, volumntextbox, layout = wibox.layout.align.horizontal }, 3, 3), beautiful.xcolor2),
              arrow(beautiful.xcolor2, beautiful.xcolor4),
              wibox.container.background(wibox.container.margin(wibox.widget { ramicon, ramtextbox, layout = wibox.layout.align.horizontal }, 2, 3), beautiful.xcolor4),
              arrow(beautiful.xcolor4, beautiful.xcolor2),
              wibox.container.background(wibox.container.margin(wibox.widget { cpuicon, cputextbox, layout = wibox.layout.align.horizontal }, 3, 4), beautiful.xcolor2),
              arrow(beautiful.xcolor2, beautiful.xcolor2),
              wibox.container.background(wibox.container.margin(clocktextbox, 3, 4), beautiful.xcolor2),
              arrow(beautiful.xcolor2, "alpha"),
              --]]
              helpers.horizontal_pad(dpi(5)),
          },
      }

      awesome.connect_signal("toggle::bar", function()
        s.mywibar.visible = not s.mywibar.visible
      end)
  end)
