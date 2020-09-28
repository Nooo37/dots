-- A simple run prompt bind to [super] + [r]
-- Launcher opens after pressing [space]
-- Other Keys can launch predefined applications
-- For example [super]+[r] -> [d] would launch discord

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local keygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("ui.helpers")

local runwidget = wibox({
    visible=false,
    ontop=true,
    type="popup_menu",
    height=dpi(250),
    width=dpi(250),
    border_width = beautiful.popup_border_width,
    border_color = beautiful.popup_border_color,
    shape = helpers.rrect(beautiful.corner_radius),
    position="top"
})

local prompt =  awful.widget.prompt({
    prompt="           λ ",
    exe_callback = function(input)
        awful.spawn.easy_async_with_shell(input, function(stdout, stderr, reason, exit_code)
            if stderr ~= nil and exit_code ~=0  then
                if _notification ~= nil then
                    _notification = naughty.notify({
                        title = "Run prompt errors:",
                        replaces_id = _notification.id,
                        text = stderr
                    })
                else
                    _notification = naughty.notify({
                        title = "Run prompt errors:",
                        text = stderr
                    })
                end
            elseif stdout ~= "" then
                _notification = naughty.notify({title="Run prompt stdout: ", text=stdout})
            end
        end)
    end,
    done_callback = function()
        awful.keygrabber.stop(dashboard_grabber)
        runwidget.visible = false
    end
})

awful.placement.centered(runwidget)

local function create_textbox(markup)
    local temp_wid = wibox.widget({
        align = "left",
        valign = "left",
        -- font = "Hack 7",
        markup = markup,
        widget = wibox.widget.textbox()
    })
    return temp_wid
end

runwidget:setup {
    {
        prompt,
        create_textbox("           <u>B</u>rave"),
        create_textbox("           <u>A</u>tom"),
        create_textbox("           <u>D</u>iscord"),
        create_textbox("           <u>Z</u>im"),
        create_textbox("           <u>G</u>imp"),
        create_textbox("           <u>N</u>autilus"),
        create_textbox("           <u>E</u>vince"),
        create_textbox("           <u>O</u>kular"),
        create_textbox("           <u>F</u>ile manager (ranger)"),
        create_textbox("           <u>M</u>usic (ncmpcpp)"),
        create_textbox("           Ne<u>w</u>s (newsboat)"),
        -- padding = dpi(20),
        layout=wibox.layout.flex.vertical,
    },
    bg=beautiful.xbg,
    -- shape = helpers.rrect(0),
    border_width = dpi(5),
    border_color = beautiful.xcolor4,
    widget = wibox.container.background()
}

local function quit_popup()
  awful.keygrabber.stop(dashboard_grabber)
  runwidget.visible = false
end

awesome.connect_signal("toggle::prompt", function()
    runwidget.visible=true
    dashboard_grabber = awful.keygrabber.run(function(_, key, event)
      if key == ' ' then -- do run prompt
        awful.keygrabber.stop(dashboard_grabber)
        prompt:run()
      else
        if key == 'Escape' or key == 'q' or key == 'F1' then
          quit_popup()
        elseif key == 'd' then
          awful.util.spawn("discord")
          quit_popup()
        elseif key == 'a' then
          awful.util.spawn("atom")
          quit_popup()
        elseif key == 'z' then
          awful.util.spawn("zim")
          quit_popup()
        elseif key == 'e' then
          awful.util.spawn("evince")
          quit_popup()
        elseif key == 'f' then
          awful.spawn.with_shell(beautiful.terminal .. " -e ranger $HOME")
          quit_popup()
        elseif key == 'm' then
          awful.spawn.with_shell(beautiful.terminal .. " -e ncmpcpp")
          quit_popup()
        elseif key == 'w' then
          awful.spawn.with_shell(beautiful.terminal .. " -e newsboat")
          quit_popup()
        elseif key == 'o' then
          awful.util.spawn("okular")
          quit_popup()
        elseif key == 'b' then
          awful.util.spawn("brave")
          quit_popup()
        elseif key == 'g' then
          awful.util.spawn("gimp")
          quit_popup()
        elseif key == 'n' then
          awful.util.spawn("nautilus")
          quit_popup()
        end
      end
    end)
end)
