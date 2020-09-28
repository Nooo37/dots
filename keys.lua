-- All Keybindings go here

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local helpers = require("ui.helpers")
local machi = require("layout.machi")
local treetile = require("layout.treetile")

local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local hotkeys_popup = require("awful.hotkeys_popup").widget

local terminal     = "alacritty"
local browser      = "firefox"


local modkey       = "Mod4"
local altkey       = "Mod1"
local modkey1      = "Control"


local is_recording = false

local function launch_or_focus(application)
  -- if the appication is already open, focus it otherwise open an instance
  local is_app = function(c)
    return awful.rules.match(c, {class = application})
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

globalkeys = my_table.join(

    -- Hotkeys Awesome
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
        {description = "show help", group="awesome"}),

    -- Tag browsing and moving current client
    awful.key({ modkey,           }, "l",      awful.tag.viewnext,
        {description = "view previous" , group = "tag"}),
    awful.key({ modkey,           }, "h",      awful.tag.viewprev,
        {description = "view nect", group = "tag"}),

    awful.key({ modkey, "Shift" }, "l", function ()
        local t = client.focus and client.focus.first_tag or nil
        if t == nil then
          return
        end
        -- TODO change that hard coded part that there are exactly 5 tags
        if t.index == 5 then
          new_tagindex = 1
        else
          new_tagindex = t.index + 1
        end
        local tag = client.focus.screen.tags[new_tagindex]
        awful.client.movetotag(tag)
        awful.tag.viewnext()
        awesome.emit_signal("toggle::nav")
    end,
    {description = "move client and view to next tag", group = "tag"}),

    awful.key({ modkey, "Shift" }, "h", function ()
        local t = client.focus and client.focus.first_tag or nil
        if t == nil then
          return
        end
        -- TODO change that hard coded part that there are exactly 5 tags
        if t.index == 1 then
          new_tagindex = 5
        else
          new_tagindex = t.index - 1
        end
        local tag = client.focus.screen.tags[new_tagindex]
        awful.client.movetotag(tag)
        awful.tag.viewprev()
        awesome.emit_signal("toggle::nav")
    end,
    {description = "move client and view to prev tag", group = "tag"}),

    -- Default client focus
    awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1)             end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1)             end,
        {description = "focus previous by index", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey, altkey }, "b", function () local s = awful.screen.focused() s.mywibox.visible = not s.mywibox.visible end,
    {description = "toggle wibox", group = "awesome"}),

    -- enter/exist windows mode
    -- awful.key({ modkey, altkey }, "w", function ()
    --     for s in screen do
    --         s.mywinbar.visible = not s.mywinbar.visible
    --         s.mywibox.visible  = not s.mywinbar.visible
    --    end
    -- end,
    -- {description = "toggle wibox", group = "awesome"}),

    -- Switch color schemes
    -- awful.key({ modkey, altkey }, "Left", function () beautiful.prev_colorscheme() end,
    --         {description = "prev colorscheme", group = "awesome"}),
    -- awful.key({ modkey, altkey }, "Right", function () beautiful.next_colorscheme() end,
    --         {description = "next colorscheme", group = "awesome"}),
    -- suspend
    awful.key({ modkey, altkey, "Shift"}, "s", function () awful.spawn.with_shell("systemctl suspend") end,
              {description = "suspend", group = "awesome"}),
    -- reboot
    awful.key({ modkey, altkey, "Shift"}, "r", function () awful.spawn.with_shell("systemctl reboot") end,
              {description = "reboot", group = "awesome"}),
    -- power off
    awful.key({ modkey, altkey, "Shift"}, "q", function () awful.spawn.with_shell("systemctl poweroff") end,
              {description = "shutdown", group = "awesome"}),


              -- =====================================================
              -- Launch
              -- =====================================================

    -- Launch dasboard awesome.emit_signal("toggle::dash")
    awful.key({ modkey,           }, "Menu", function () awesome.emit_signal("toggle::sidebar") end,
              {description = "dashboard", group = "launch"}),

    awful.key({ modkey,           }, "i", function () awesome.emit_signal("toggle::launcher") end,
              {description = "launcher launchen :)", group = "launch"}),

    -- run popup prompt
    awful.key({modkey             }, "o", function () awful.spawn.with_shell("rofi -show run") end,
              {description = "run rofi", group = "launch"}),
    -- launch or focus browser
    awful.key({ modkey,           }, "b", function () launch_or_focus(browser) end,
              {description = "browser", group = "launch"}),
    -- launch terminal
    awful.key({ modkey,           }, "t", function () awful.util.spawn(terminal) end,
              {description = "terminal", group = "launch"}),

    -- make screenrecord
    awful.key({ modkey, "Shift"   }, "r", function()
        --awful.util.spawn_with_shell('if ! killall --user $USER --ignore-case --signal INT ffmpeg; then ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 ~/pics/screenrecords/$(date +%y-%m-%d_%H-%M-%S).mp4; fi')
        awful.util.spawn_with_shell('if ! killall --user $USER --ignore-case --signal INT ffmpeg; then ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 -f pulse -ac 2 -i default  ~/pics/screenrecords/$(date +%y-%m-%d_%H-%M-%S).mp4; fi')
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
    -- make screenshot
    awful.key({ modkey, "Shift"   }, "r", function() awful.util.spawn_with_shell("newsboat --execute=reload") end,
            {description = "reload newsboat", group = "hotkeys"}),
    -- aw report
    awful.key({ modkey,           }, "p", function()
        local handle = io.popen("python $HOME/prog/python/aw_notify.py")
        local result = handle:read("*a")
        handle:close()
        naughty.notify({title="ActivityWatch Usage Report", text=result, icon=os.getenv("HOME") .. "/pics/icons/hourglass.svg", timeout=20, font="monospace 12"})

    end,
              {description = "show activitywatch report", group="hotkeys"}),
    -- just for stuff to experiment with
    awful.key({ modkey,            }, "ä", function() awful.util.spawn_with_shell("sleep 0.5; xdotool type asf") end,
              {description = "reload newsboat", group = "hotkeys"}),
    -- launch proomptbox
    awful.key({ modkey },            "r",     function () awesome.emit_signal("toggle::prompt") end,
              {description = "run run prompt", group = "hotkeys"}),
    -- kill all notifications
    awful.key({ modkey },            "ö",     function () naughty.destroy_all_notifications(nil, naughty.notificationClosedReason.dismissedByUser) end,
              {description = "close notifications", group = "hotkeys"}),

              -- =====================================================
              -- Music with MPD and MPC
              -- =====================================================

    -- prev song
    awful.key({ modkey,           }, "d", function () awful.spawn.with_shell("mpc prev") end,
              {description = "prev song (mpd)", group = "music"}),
    -- next song
    awful.key({ modkey,           }, "g", function () awful.spawn.with_shell("mpc next") end,
              {description = "next song (mpd)", group = "music"}),
    -- pause toggle
    awful.key({ modkey,           }, "f", function () awful.spawn.with_shell("mpc toggle") end,
              {description = "pause/unpause music (mpd)", group = "music"}),
    -- volume +
    awful.key({ modkey,           }, "+", function () awful.spawn.with_shell("amixer sset 'Master' 5%+") end,
              {description = "volume up", group = "music"}),
    -- volume -
    awful.key({ modkey,           }, "-", function () awful.spawn.with_shell("amixer sset 'Master' 5%-") end,
              {description = "volume down", group = "music"}),
    -- volume -
    awful.key({ modkey,           }, ".", function () awful.spawn.with_shell("amixer sset Master toggle") end,
              {description = "volume toggle mute", group = "music"}),

              -- =====================================================
              -- Layout Manipulation
              -- =====================================================

    -- shortcuts for treetile layout
    -- awful.key({ modkey,  altkey   }, "h",  treetile.horizontal,
    --           {description = "edit the current layout if it is a treetile layout", group = "layout"}),
    -- awful.key({ modkey,  altkey   }, "v",  treetile.vertical,
    --           {description = "edit the current layout if it is a treetile layout", group = "layout"}),
    -- shortcuts for machi layout
    awful.key({ modkey,           }, "<",    function () machi.default_editor.start_interactive() end,
              {description = "edit the current layout if it is a machi layout", group = "layout"}),
    awful.key({ modkey,           }, ",",    function () machi.switcher.start(client.focus) end,
              {description = "switch between windows for a machi layout", group = "layout"}),

    -- awful.key({ modkey,           }, "Enter",     function () awful.client.jumpto(1) 	end,
    --           {description = "shift focus to master", group = "layout"}),
    -- awful.key({ modkey,  "Shift"  }, "Enter",     function () awful.tag.viewidx(1) 	end,
    --           {description = "move to master and shift focus to master", group = "layout"}),
    awful.key({ modkey, altkey    }, "l",     function () awful.tag.incmwfact( 0.05)      end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, altkey    }, "h",     function () awful.tag.incmwfact(-0.05)      end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "j",     function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",     function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),

              -- =====================================================
              -- Change on the fly
              -- =====================================================

    -- Change brightness on the fly
    awful.key({ modkey, altkey }, "+", function () helpers.change_brightness_relative(0.1)   end,
              {description = "increase brightness", group = "brightness"}),
    awful.key({ modkey, altkey }, "-", function () helpers.change_brightness_relative(-0.1)  end,
              {description = "decrease brightness", group = "brightness"}),

    -- Change useless gaps on the fly
    awful.key({ modkey, "Shift" }, "+", function () helpers.resize_gaps(1)                   end,
              {description = "increment useless gaps", group = "tag"}),
    awful.key({ modkey, "Shift" }, "-", function () helpers.resize_gaps(-1)                  end,
              {description = "decrement useless gaps", group = "tag"}),


              -- =====================================================
              -- Standard commands
              -- =====================================================
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "q",  function() awesome.quit()                          end,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ altkey, "Shift" }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
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
    --awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
    --          {description = "move to screen", group = "client"}),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
    --          {description = "keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
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
        descr_move = {description = "move focused client and view to tag #", group = "tag"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
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
        awful.key({ modkey, "Control" }, "#" .. i + 9,
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
                  descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              -- tag.viewonly()
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
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

-- They annoy me more than I use them 
-- Mouse bindings
-- root.buttons(my_table.join(
--     awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
--     awful.button({ }, 4, awful.tag.viewnext),
--     awful.button({ }, 5, awful.tag.viewprev)
-- ))
