pcall(require, "luarocks.loader")       -- seems to be standard
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful")  -- Theme handling library


-- require("dynamite")

beautiful.init(require("theme")) -- intialize the theme

awful.util.tagnames = {"MAIN", "WEBS", "CODE", "READ", "CHAT"} -- declare tag names


-- require("tenacious")
require("module.no_single_client_borders")
require("module.no_single_client_round_corners")
-- require("module.triangular_clients")
-- require("module.titlebar_only_in_floating")
require("module.sloppy_focus")
require("module.set_wallpaper")(beautiful.wallpaper)
require("module.auto_start")({"mpd", "picom", "aw-qt", "greenclip daemon",
                              "tmux has-session -t scratchpad || tmux new-session -d -s scratchpad"})
require("module.error_handling")

require("keys")
require("layout")

require("signal")({"volume", "mpd", "temp", "cpu", "ram", "newsboat", "disk", "weather", "brightness_desktop"})


-- require("ui.titlebar.powerarrows")
-- require("ui.bar.vertical_tiny")
require("ui.bar.vertical_round")
require("ui.dashboard.vertical_round")
require("ui.popup.layout_box")
require("ui.popup.tag_box")
require("ui.popup.volume_adjust")
-- require("ui.popup.mpd_control")
require("ui.popup.bad_run_prompt")
require("ui.popup.mpd_notify")

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width or 0,
                     border_color = beautiful.border_normal or "#000000",
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
  }, properties = { titlebars_enabled = false }
    },

    { rule_any = {instance = { "scratch" }},
      properties = {},
      callback = require("ui.titlebar.scratchpad")
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

---{{{ Notify when cpu temp rises above 65°C

awesome.connect_signal("evil::temp", function(temp)
    if temp > 65 then
        naughty.notify({title="[!] CPU is getting hot", text="Currently at " .. tostring(temp) .. "°C"})
    end
end)

--}}}
