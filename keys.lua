-- All Keybindings go here

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local helpers = require("ui.helpers")
local machi = require("layout.machi")

local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local hotkeys_popup = require("awful.hotkeys_popup").widget

local terminal     = beautiful.terminal:lower() or "urxvt"
local browser      = beautiful.browser:lower() or "firefox"
local editor       = beautiful.editor:lower() or "atom"

local modkey       = "Mod4"
local altkey       = "Mod1"
local modkey1      = "Control"

local is_recording = false

local scratch = require("module.scratchpad")
awful.util.spawn_with_shell("tmux new -s scratchpad")

local function add_tag_focus_with(application)
  -- if the appication is already open, focus it otherwise open an instance
  local is_app = function(c)
    return awful.rules.match(c, {instance = application}) or awful.rules.match(c, {class = application})
  end
  for c in awful.client.iterate(is_app) do
      local tag = c.screen.tags[c.first_tag.index]
      awful.tag.viewtoggle(tag)
      client.focus = c
      return
  end
  launch_or_focus(application)
end

local function launch_or_focus(application)
  -- if the appication is already open, focus it otherwise open an instance
  local is_app = function(c)
    return awful.rules.match(c, {instance = application}) or awful.rules.match(c, {class = application})
  end
  for c in awful.client.iterate(is_app) do
      local tag = c.screen.tags[c.first_tag.index]
      tag:view_only()
      client.focus = c
      return
  end
  awful.util.spawn(application)
end

-- TODO make work
local function send_string_to_client(s, c)
    local old_c = client.focus
    client.focus = c
    for i=1, #s do
        local char = s:sub(i,i)
        root.fake_input('key_press'  , char)
        root.fake_input('key_release', char)
    end
    client.focus = old_c
end

-- delete current focued tag
local function delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end

-- add new tag (name is the index)
local function add_tag()
    awful.tag.add(tostring(#awful.screen.focused().tags+1), {
        screen = awful.screen.focused(),
        layout = awful.layout.layouts[1] }):view_only()
end

-- rename current focused tag
local function rename_tag()
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end

            local t = awful.screen.focused().selected_tag
            if t then
                t.name = new_name
            end
        end
    }
end


local function shift_focus_and_move_client(move_back)
  local t = client.focus and client.focus.first_tag or nil
  if t == nil then
    return
  end
  if move_back then
    if t.index == 1 then
      new_tagindex = #awful.screen.focused().tags     -- TODO change in giit
    else
      new_tagindex = t.index - 1
    end
    local tag = client.focus.screen.tags[new_tagindex]
    awful.client.movetotag(tag)
    awful.tag.viewprev()
    awesome.emit_signal("toggle::nav")
  else
    if t.index == #awful.screen.focused().tags then
      new_tagindex = 1
    else
      new_tagindex = t.index + 1
    end
    local tag = client.focus.screen.tags[new_tagindex]
    awful.client.movetotag(tag)
    awful.tag.viewnext()
  end
end



globalkeys = my_table.join(

    --{{{ USEFULL, TAG BROWSING
    -- Hotkeys Awesome
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description = "show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "l",      awful.tag.viewnext,
              {description = "view previous" , group = "tag"}),
    -- Tag browsing
    awful.key({ modkey,           }, "h",      awful.tag.viewprev,
              {description = "view nect", group = "tag"}),
    -- Tag browsing + move current client to new tag
    awful.key({ modkey, "Shift" }, "l", function () shift_focus_and_move_client(false) end,
              {description = "move client and view to next tag", group = "move client"}),
    -- Tag browsing + move current client to new tag
    awful.key({ modkey, "Shift" }, "h", function () shift_focus_and_move_client(true) end,
              {description = "move client and view to prev tag", group = "move client"}),
    -- Switch client focus next
    awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1)             end,
              {description = "focus next by index", group = "client"}),
    -- Switch client focus prev
    awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1)             end,
              {description = "focus previous by index", group = "client"}),
    -- Show/Hide Wibox
    awful.key({ modkey, "Shift  " }, "z", function () awesome.emit_signal("toggle::bar") end,
              {description = "toggle wibox", group = "awesome"}), --local s = awful.screen.focused() s.mywibox.visible = not s.mywibox.visible
    -- launch proomptbox
    awful.key({ modkey },            "r",     function () awesome.emit_signal("toggle::prompt") end,
              {description = "run prompt", group = "launch"}),
    -- kill all notifications
    awful.key({ modkey },            "#",     function () naughty.destroy_all_notifications(nil, naughty.notificationClosedReason.dismissedByUser) end,
              {description = "close notifications", group = "hotkeys"}),
    --}}}
    --{{{ SYSTEM
    -- suspend
    -- awful.key({ modkey, altkey, "Shift"}, "s", function () awful.spawn.with_shell("systemctl suspend") end,
    --           {description = "suspend", group = "awesome"}),
    -- -- reboot
    -- awful.key({ modkey, altkey, "Shift"}, "r", function () awful.spawn.with_shell("systemctl reboot") end,
    --           {description = "reboot", group = "awesome"}),
    -- power off
    awful.key({ modkey,           }, "q", function () awful.spawn.with_shell("$HOME/prog/bash/exit.sh") end,
              {description = "shutdown, quit, reload and reboot everything", group = "awesome"}),
    -- clipboard history
    awful.key({ modkey,           }, "o", function () awful.spawn.with_shell("greenclip print | sed '/^$/d' | rofi -dmenu -i -c -l 20 | xargs -r -d'\\n' -I '{}' greenclip print '{}'") end,
              {description = "select from greenclip clipboard history", group = "awesome"}),
    -- try out thing
    awful.key({ modkey,           }, "u", function () awful.spawn("date") end,
              {description = "select from greenclip clipboard history", group = "awesome"}),

    --}}}
    --{{{ LAUNCH
    -- Launch dasboard awesome.emit_signal("toggle::dash")
    awful.key({ modkey,           }, "Menu", function () awesome.emit_signal("toggle::sidebar") end,
              {description = "dashboard", group = "launch"}),
    -- run popup prompt
    -- awful.key({modkey             }, "o", function () awful.spawn.with_shell("dmenu_run -c -l 20 -i") end,
    --           {description = "run rofi", group = "launch"}),
    -- launch terminal
    awful.key({ modkey,           }, "t", function () awful.util.spawn(terminal) end,
              {description = "launch terminal", group = "launch"}),
    -- launch or focus browser
    awful.key({ modkey,           }, "b", function () launch_or_focus(browser) end,
              {description = "launch browser", group = "launch"}),
    -- add tag focus with browser
    awful.key({ modkey, altkey    }, "b", function () add_tag_focus_with(browser) end,
              {description = "add focus browser", group = "launch"}),
    -- launch or focus editor
    awful.key({ modkey,           }, "v", function () launch_or_focus(editor) end,
              {description = "launch editor", group = "launch"}),
    -- add tag focus with editor
    awful.key({ modkey, altkey    }, "v", function () add_tag_focus_with(editor) end,
              {description = "add focus editor", group = "launch"}),
    -- launch or focus editor
    awful.key({ modkey,           }, "x", function () launch_or_focus("discord") end,
              {description = "launch discord", group = "launch"}),
    -- add tag focus with editor
    awful.key({ modkey, altkey    }, "x", function () add_tag_focus_with("discord") end,
              {description = "add focus discord", group = "launch"}),
    --}}}
    --{{{ MUSIC MPD VOLUME
    -- mpd prev song
    awful.key({ modkey, altkey   }, "d", function () awful.spawn.with_shell("mpc prev") end,
              {description = "[mpd] prev song", group = "music"}),
    -- mpd next song
    awful.key({ modkey, altkey   }, "g", function () awful.spawn.with_shell("mpc next") end,
              {description = "[mpd] next song", group = "music"}),
    -- mpd pause toggle
    awful.key({ modkey, altkey  }, "f", function () awful.spawn.with_shell("mpc toggle") end,
              {description = "[mpd] toggle pause", group = "music"}),
    -- mpd volume plus
    awful.key({ modkey, altkey  }, "+", function () awful.spawn.with_shell("mpc volume +5") end,
              {description = "[mpd] volume up", group = "music"}),
    -- mpd volume minus
    awful.key({ modkey, altkey  }, "-", function () awful.spawn.with_shell("mpc volume -5") end,
              {description = "[mpd] volume down", group = "music"}),
    -- volume +
    awful.key({ modkey,           }, "+", function () awful.spawn.with_shell("amixer sset 'Master' 5%+") end,
              {description = "volume up", group = "music"}),
    -- volume -
    awful.key({ modkey,           }, "-", function () awful.spawn.with_shell("amixer sset 'Master' 5%-") end,
              {description = "volume down", group = "music"}),
    -- volume -
    awful.key({ modkey,           }, ".", function () awful.spawn.with_shell("amixer sset Master toggle") end,
              {description = "volume toggle mute", group = "music"}),
    --}}}
    --{{{ TAG
    -- just for stuff to experiment with
    awful.key({ modkey,            }, "ä", function() delete_tag() end,
              {description = "delete current tag", group = "tag"}),
    -- just for stuff to experiment with
    awful.key({ modkey,            }, "ü", function() add_tag() end,
              {description = "add tag", group = "tag"}),
    -- just for stuff to experiment with
    awful.key({ modkey,            }, "ö", function() rename_tag() end,
              {description = "rename current tag", group = "tag"}),
    --}}}
    --{{{ LAYOUT
    -- enter machi editor
    awful.key({ modkey,           }, "<",    function () machi.default_editor.start_interactive() end,
              {}), -- otherwise it's creating an empty group in shortcut overview :(
              -- {description = "edit the current machi", group = "Layout"}),
    -- move clients in machi layout
    awful.key({ modkey,           }, ",",    function () machi.switcher.start(client.focus) end,
              {description = "swap clients in machi", group = "move client"}),
    -- increase master width factor
    awful.key({ modkey, altkey    }, "l",     function () awful.tag.incmwfact( 0.05)      end,
              {description = "increase master width factor", group = "layout"}),
    -- decrease master width factor
    awful.key({ modkey, altkey    }, "h",     function () awful.tag.incmwfact(-0.05)      end,
              {description = "decrease master width factor", group = "layout"}),
    -- swap clients
    awful.key({ modkey, "Shift"   }, "j",     function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "move client"}),
    -- swap clients
    awful.key({ modkey, "Shift"   }, "k",     function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "move client"}),
    -- awful.key({ modkey,           }, "Enter",     function () awful.client.jumpto(1) 	end,
    --           {description = "shift focus to master", group = "layout"}),
    -- awful.key({ modkey,  "Shift"  }, "Enter",     function () awful.tag.viewidx(1) 	end,
    --           {description = "move to master and shift focus to master", group = "layout"}),
    awful.key({ modkey,           }, "c",     function () scratch.toggle("urxvt -name scratch -e tmux attach -t scratchpad", {instance = "scratch"}) 	end,
              {description = "scratchpad terminal urxvt", group = "launch"}),
    --}}}
    --{{{ BRIGHNTESS
    -- increase brightness
    awful.key({ modkey, "Shift" }, "+", function () helpers.change_brightness_relative(0.1)   end,
              {description = "increase brightness", group = "brightness"}),
    -- decrease brightness
    awful.key({ modkey, "Shift" }, "-", function () helpers.change_brightness_relative(-0.1)  end,
              {description = "decrease brightness", group = "brightness"}),
    --}}}
    --{{{ quit/reload awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "q",  function() awesome.quit()                          end,
              {description = "quit awesome", group = "awesome"}),
    --}}}
    --{{{ LAYOUT
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
    --}}}

    -- make screenrecord
    awful.key({ modkey, "Shift"   }, "r", function()
        awful.util.spawn_with_shell('if ! killall --user $USER --ignore-case --signal INT ffmpeg; then ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 -f pulse -ac 2 -i default  ~/pics/screenrecords/$(date +%y-%m-%d_%H-%M-%S).mp4; fi')
          -- giph -s -l -c 1,1,1,0.3 -b 5 -p -5 out.gif
          -- TODO change to that ^
          -- can do only areas
        is_recording = not is_recording
        if is_recording then
            naughty.notify({title="[!] Is recording", text="mp4 will be saved at ~/pics/screenrecords", timeout=12*60*60})
        else
            naughty.destroy_all_notifications(nil, naughty.notificationClosedReason.dismissedByUser)
        end
      end,
      {description = "make screenrecord", group = "hotkeys"}),

    -- make screenshot // DEPENDS on "maim"
    awful.key({ modkey, "Shift"   }, "s", function()
        local timestamp = os.date("%y-%m-%d_%H-%M-%S")
        awful.util.spawn_with_shell('maim -s | tee >(xclip -selection clipboard -t image/png) $HOME/pics/screenshots/' .. timestamp .. '.png | xclip -selection primary')
        --"~/pics/screenshots/" .. timestamp .. ".png"
        end,
    	      {description = "make screenshot", group = "hotkeys"}),

    awful.key({ modkey,           }, "n",  function ()
        local minimized_c = awful.client.restore()
        local current_c = client.focus
        if minimized_c then -- if there is a minimized client restore it
            client.focus = minimized_c
            minimized_c:raise()
        else -- if there is no minimized client make the current client minimized
            current_c.minimized = true
        end
    end ,
                {description = "toggle minimize", group = "client"}),
    -- aw report
    awful.key({ modkey,           }, "p", function()
        local handle = io.popen("python $HOME/prog/python/aw_notify.py")
        local result = handle:read("*a")
        handle:close()
        naughty.notify({title="ActivityWatch Usage Report", text=result, icon=os.getenv("HOME") .. "/pics/icons/hourglass.svg", timeout=20, font="monospace 12"})

    end,
              {description = "show activitywatch report", group="hotkeys"})

)

clientkeys = my_table.join(

    awful.key({ modkey,         }, "w",      function (c)
      -- c:kill() would be enoguh to kill the client but i want to kill discord process if client is discord
      local kill_discord = false
      if string.sub(c.name, -7) == "Discord" then
        kill_discord = true
      end
      c:kill()
      if kill_discord then
        awful.util.spawn_with_shell("killall Discord")
      end
    end,
              {description = "close windoow", group = "hotkeys"}),

    awful.key({ modkey, "Shift" }, "f",  awful.client.floating.toggle                     ,
             {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Shift" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    -- awful.key({ mokey,          }, "Return", function (_) awful.client.jumpto(1) end)
    --           {description = "focus master", group = "client"}),
    --awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
    --          {description = "move to screen", group = "client"}),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
    --          {description = "keep on top", group = "client"}),

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize toggle", group = "client"}),

    awful.key({ modkey, altkey}, "t",
        function(c)
            local screen = c.screen
            screen.mytasklist.visible = not screen.mytasklist.visible
        end ,
        {description = "toggle tasklist", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client and view to tag #", group = "move client"}
        -- descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
    end
    globalkeys = my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Toggle tag display.
        awful.key({ modkey, altkey }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),
        -- Move client and view to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                              tag:view_only()
                          end
                     end
                  end,
                  descr_move)
        -- Toggle tag on focused client.
        -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        --           function ()
        --               if client.focus then
        --                   local tag = client.focus.screen.tags[i]
        --                   if tag then
        --                       -- tag.viewonly()
        --                       client.focus:toggle_tag(tag)
        --                   end
        --               end
        --           end,
        --           descr_toggle_focus)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)


awful.util.taglist_buttons = my_table.join(
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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

awful.util.tasklist_buttons = my_table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function()
                         local instance = nil

                         return function ()
                             if instance and instance.wibox.visible then
                                 instance:hide()
                                 instance = nil
                             else
                                 instance = awful.menu.clients({ theme = { width = 250 } })
                             end
                        end
                     end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))


-- They annoy me more than I use them
-- Mouse bindings
-- root.buttons(my_table.join(
--     awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
--     awful.button({ }, 4, awful.tag.viewnext),
--     awful.button({ }, 5, awful.tag.viewprev)
-- ))
