-- TODO implement notification replacement

local awful = require("awful")
local naughty = require("naughty")

local script = [[bash -c '
  IMG_REG="(front|cover|art)\.(jpg|jpeg|png|gif)$"
  DEFAULT_ART="$HOME/music/covers/0DEFAULT.png"

  file=`mpc current -f %file%`
  basefilename="${file%.mp3}"
  picfilename=`echo "$basefilename"".jpeg"`

  info=`mpc -f "%artist%@@%title%@"`

  if ]] .. '[ -f "$HOME/music/covers/$picfilename" ]' .. [[; then
    cover="$HOME/music/covers/$picfilename"
  else
    cover="$DEFAULT_ART"
  fi

  echo $info"##"$cover"##"
']]

local old_notification

local function update_notify()
  awful.spawn.easy_async(script,
    function(stdout)
      -- naughty.notify({test="akjf", text=stdout})

      local artist = stdout:match('(.*)@@')
      local title = stdout:match('@@(.*)@')
      local cover_path = stdout:match('##(.*)##')
      local status = stdout:match('%[(.*)%]')
      status = string.gsub(status, '^%s*(.-)%s*$', '%1')

      if status ~= "paused" then
          old_notification = naughty.notify({title=title, text=artist, icon=cover_path})
      end

    end
  )
end

local mpd_script = [[
  bash -c '
    mpc idleloop player
  ']]

local seek_state
awful.spawn.with_line_callback(mpd_script, {
                                 stdout = function(line)
                                  if (seek_state) then
                                    seek_state = false
                                  else
                                    update_notify()
                                  end
                                 end
})
