-- THIS WORK IS NOT ALL MINE
-- Special thanks to javacafe, who also based their work off of eredarion, who also based their work off of elenapan
--
-- https://github.com/JavaCafe01/dotfiles/



-- NOTE:
-- This widget runs a script in the background
-- When awesome restarts, its process will remain alive!
-- Don't worry though! The cleanup script that runs in rc.lua takes care of it :)

local theme = require("theme")
local awful = require("awful")
local gears = require("gears")
local gcolor = require("gears.color")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local dpi = require("beautiful.xresources").apply_dpi

local helpers = require("ui.helpers")
local pad = helpers.pad

local creator = {}

creator.create = function()
  local active_color = {
    type = 'linear',
    from = { 0, 0 },
    to = { 300, 50 }, -- replace with w,h later
    stops = {
      { 0.00, beautiful.xcolor4  },
      { 0.55, beautiful.xcolor5  }
    }
  }
  local mpd_slider = require("ui.widget.mpd_slider").create(active_color, beautiful.xcolor8)
  -- Set colors
  ------------------------------------------------------------
  local title_color =  beautiful.xcolor3
  local artist_color = beautiful.xcolor4
  local paused_color = beautiful.xcolor1
  ------------------------------------------------------------

  local artist_fg
  local artist_bg

  local seek_state = false


  -- Progressbar
  ------------------------------------------------------------

  local bar = wibox.widget {
      value         = 64,
      max_value     = 100,
      forced_height = dpi(8),
      forced_width  = dpi(180),
      color     = beautiful.xcolor4,
      background_color = beautiful.xcolor0,
      shape         = helpers.rrect(dpi(6)),
      bar_shape   = helpers.rrect(dpi(6)),
      widget        = wibox.widget.progressbar
  }

  local bar_timer = gears.timer {
      timeout   = 3,
      call_now  = true,
      autostart = true,
      callback  = function()
          awful.spawn.easy_async_with_shell("mpc -f '%time%'", function(stdout)
                  bar.value = tonumber(stdout:match('[(]+(%d+)'))
              end
          )
      end
  }
  ------------------------------------------------------------


  -- Poster (image)
  ------------------------------------------------------------
  local box_image = wibox.widget {
      shape = helpers.rrect(dpi(10)),
      widget = wibox.widget.imagebox
  }
  -- box_image.image = icons.music
  local image_cont = wibox.widget {
    box_image,
    shape              = helpers.rrect(dpi(6)),
    bg                 = "44444433", --beautiful.xcolor8 .. "33",
    widget             = wibox.container.background
  }
  ------------------------------------------------------------


  -- Text lines
  ------------------------------------------------------------
  local mpd_title = wibox.widget.textbox("Title")
  local mpd_artist = wibox.widget.textbox("Artist")
  mpd_title:set_font("Noto Sans 15")
  mpd_title:set_valign("top")
  mpd_artist:set_font("Noto Sans Bold 13")
  mpd_artist:set_valign("top")

  local text_area = wibox.layout.fixed.vertical()
  text_area:add(wibox.container.constraint(mpd_title, "exact", nil, dpi(26)))
  text_area:add(wibox.container.constraint(mpd_artist, "exact", nil, dpi(26)))
  ------------------------------------------------------------


  -- Control line
  ------------------------------------------------------------
  local btn_color = beautiful.xcolor15
  -- playback buttons
  local player_buttons = wibox.layout.fixed.horizontal()

  local prev_button = wibox.widget.textbox(helpers.colorize_text(" ⏮ ", beautiful.xcolor6))
  prev_button.font = "Hack 25"
  helpers.add_hover_cursor(prev_button, "hand1")
  player_buttons:add(wibox.container.margin(prev_button, dpi(0), dpi(0), dpi(6), dpi(6)))

  local play_button = wibox.widget.textbox(helpers.colorize_text(" ⏵ ", beautiful.xcolor6))
  play_button.font = "Hack 25"
  helpers.add_hover_cursor(play_button, "hand1")
  player_buttons:add(wibox.container.margin(play_button, dpi(0), dpi(0), dpi(6), dpi(6)))

  local next_button = wibox.widget.textbox(helpers.colorize_text(" ⏭ ", beautiful.xcolor6))
  next_button.font = "Hack 25"
  helpers.add_hover_cursor(next_button, "hand1")
  player_buttons:add(wibox.container.margin(next_button, dpi(0), dpi(0), dpi(6), dpi(6)))
  ------------------------------------------------------------


  -- Full line
  local buttons_align = wibox.layout.align.horizontal()
  buttons_align:set_expand("outside")
  buttons_align:set_middle(player_buttons)

  local control_align = wibox.layout.align.horizontal()
  control_align:set_middle(buttons_align)
  control_align:set_right(nil)
  control_align:set_left(nil)
  ------------------------------------------------------------


  -- Bring it all together
  ------------------------------------------------------------
  local align_vertical = wibox.layout.align.vertical()
  align_vertical:set_top(text_area)
  -- align_vertical:set_middle(control_align)
  -- align_vertical:set_bottom(wibox.container.constraint(bar, "exact", nil, dpi(8)))
  local area = wibox.layout.fixed.horizontal()
  area:add(image_cont)
  area:add(wibox.container.margin(align_vertical, dpi(10), dpi(10), 0, 0))

  local complete = wibox.layout.fixed.vertical()
  complete:add(wibox.widget({area, forced_height=dpi(75), forced_width=dpi(200), widget=wibox.container.margin}))
  complete:add(wibox.widget({mpd_slider, forced_height=dpi(50), forced_width=dpi(200), widget=wibox.container.margin}))
  complete:add(wibox.widget({control_align, forced_height=dpi(50), forced_width=dpi(200), widget=wibox.container.margin}))

  local main_wd = wibox.widget {
    complete,
    left = dpi(3),
    right = dpi(3),
    forced_width = dpi(200),
    forced_height = dpi(180),
    widget = wibox.container.margin
  }
  ------------------------------------------------------------
  --------------------------------------------------------------------------------


  -- Buttons
  ------------------------------------------------------------
  bar:buttons(gears.table.join(
                           awful.button({ }, 1, function ()
                               seek_state = true
                               awful.spawn.with_shell("mpc seek +6%")
                               bar_timer:emit_signal("timeout")
                           end),
                           awful.button({ }, 3, function ()
                               seek_state = true
                               awful.spawn.with_shell("mpc seek -6%")
                               bar_timer:emit_signal("timeout")
                           end),
                           awful.button({ }, 4, function ()
                               seek_state = true
                               awful.spawn.with_shell("mpc seek +3%")
                               bar_timer:emit_signal("timeout")
                           end),
                           awful.button({ }, 5, function ()
                               seek_state = true
                               awful.spawn.with_shell("mpc seek -3%")
                               bar_timer:emit_signal("timeout")
                           end)
                      )
  )
  image_cont:buttons(gears.table.join(
                           awful.button({ }, 1, function ()
                               awful.spawn.with_shell("mpc toggle")
                           end)))
  text_area:buttons(gears.table.join(
                           awful.button({ }, 1, function ()
                               awful.spawn.with_shell("mpc toggle")
                           end)))
  play_button:buttons(gears.table.join(
                           awful.button({ }, 1, function ()
                               awful.spawn.with_shell("mpc toggle")
                           end)))
  prev_button:buttons(gears.table.join(
                           awful.button({ }, 1, function ()
                               awful.spawn.with_shell("mpc prev")
                           end)))
  next_button:buttons(gears.table.join(
                           awful.button({ }, 1, function ()
                               awful.spawn.with_shell("mpc next")
                           end)))
  ------------------------------------------------------------


  -- Notification
  ------------------------------------------------------------
  local last_notification_id
  local function send_notification(artist, title, icon)
    notification = naughty.notify({
        title =  artist,
        text = title,
        icon = icon,
        icon_size = 70,
        width = dpi(280),
        font = "Mononoki Nerd Font 14",
        timeout = 6,
        hover_timeout = 180,
        replaces_id = last_notification_id
    })
    last_notification_id = notification.id
  end
  ------------------------------------------------------------

  local music_directory = "music"
  local default_art = os.getenv("HOME") .. "/music/covers/0DEFAULT.png"
  -- Main script
  ------------------------------------------------------------
  local script = [[bash -c '
    IMG_REG="(front|cover|art)\.(jpg|jpeg|png|gif)$"

    file=`mpc current -f %file%`
    basefilename="${file%.mp3}"
    picfilename=`echo "$basefilename"".jpeg"`

    info=`mpc -f "%artist%@@%title%@"`

    if ]] .. '[ -f "$HOME/music/covers/$picfilename" ]' .. [[; then
      cover="$HOME/music/covers/$picfilename"
    else
      cover="]] .. default_art .. [["
    fi

    echo $info"##"$cover"##"
  ']]
  ------------------------------------------------------------


  -- Update widget
  ------------------------------------------------------------
  local function update_widget()
    awful.spawn.easy_async(script,
      function(stdout)
        -- n=require("naughty")
        -- n.notify({test="akjf", text=stdout})

        bar_timer:emit_signal("timeout")

        local artist = stdout:match('(.*)@@')
        local title = stdout:match('@@(.*)@')
        local cover_path = stdout:match('##(.*)##')
        local status = stdout:match('%[(.*)%]')
        status = string.gsub(status, '^%s*(.-)%s*$', '%1')

        local artist_span = artist
        local title_span  = helpers.colorize_text(title, beautiful.xcolor3)

        if status == "paused" then
          bar_timer:stop()
          artist_fg = paused_color
          title_fg = paused_color
          play_button.markup = helpers.colorize_text("⏵", beautiful.xcolor6)
        else -- TODO notification is fucked :(
          bar_timer:start()
          artist_fg = artist_color
          title_fg = title_color
          play_button.markup = helpers.colorize_text("⏸", beautiful.xcolor6)
          -- you can put send_notificatoin(artist_span, title_span, cover_path) here
          -- if true then --sidebar.visible == false then
          --   --bar_timer:stop()
          --   -- n=require("naughty")
          --   -- n.notify({title=title_span, text=artist_span, icon=cover_path, replace_id=1})
          --   send_notification(artist_span, title_span, cover_path)
          -- end

        end

        -- Escape &'s
        title = string.gsub(title, "&", "&amp;")
        artist = string.gsub(artist, "&", "&amp;")

        if cover_path == default_art then 
            box_image:set_image(gcolor.recolor_image(cover_path, beautiful.xcolor6))
        else 
            box_image:set_image(cover_path)
        end 

        mpd_title.markup = helpers.colorize_text(title, title_fg)
        mpd_artist.markup = helpers.colorize_text(artist, artist_fg)

        collectgarbage()
      end
    )
  end

  update_widget()
  ------------------------------------------------------------


  -- To wait "events" and refresh widget
  ------------------------------------------------------------
  local mpd_script = [[
    bash -c '
      mpc idleloop player
    ']]

  awful.spawn.with_line_callback(mpd_script, {
                                   stdout = function(line)
                                    if (seek_state) then
                                      seek_state = false
                                    else
                                      update_widget()
                                    end
                                   end
  })
  ------------------------------------------------------------


  return main_wd
end

return creator
