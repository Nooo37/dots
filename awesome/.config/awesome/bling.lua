-- all my bling related config goes here

local awesome, root, client = awesome, root, client
local beautiful = require("beautiful")

-- local awestore = require("awestore")
local bling = require("module.bling")
local rubato = require("module.rubato")
local naughty = require("naughty")

-- require("module.bling.widget.app_launcher")

-- awesome.connect_signal("bling::playerctl::position",
-- function(interval_sec, length_sec, player_name)
--     naughty.notify {text=tostring(interval_sec).." "..tostring(length_sec)}
-- end)

local scratch_y = rubato.timed {
    pos = awful.screen.focused().geometry.height + 10,
    rate = 144,
    easing = rubato.quadratic,
    intro = 0.1,
    duration = 0.3,
    awestore_compat = true
}

local scrat = bling.module.scratchpad {
    command = "alacritty --class=scratchterm",
    rule = {instance = "scratchterm"},
    sticky = true,
    autoclose = false,
    floating = true,
    geometry = {x=820, y=0, height=520, width=920},
    reapply = true,
    dont_focus_before_close = false,
    rubato = { y = scratch_y }
}

awesome.connect_signal("test", function() scrat:toggle() end)

-- bling.module.window_swallowing.start()   -- activates window swallowing

bling.widget.window_switcher.enable {}

-- FLASH FOCUS and PLAYERCTL SIGNAL
bling.module.flash_focus.enable()
bling.signal.playerctl.enable()

-- TAG and TASK PREVIEW
local margin_edge = 10

bling.widget.tag_preview.enable {
    show_client_content = false,
    x = beautiful.statusbar_width + margin_edge,
    y = beautiful.useless_gap / 2,
    scale = 0.2,
    honor_padding = false,
    honor_workarea = true
}

bling.widget.task_preview.enable {
    x = beautiful.statusbar_width + margin_edge,
    y = beautiful.useless_gap / 2,
    height = 200,
    width = 200,
}

-- bling.widget.window_switcher.enable {}

-- WALLPAPER

-- don't really need the module for that but whatever
bling.module.wallpaper.setup {
   wallpaper = { beautiful.wallpaper }
}

-- awful.screen.connect_for_each_screen(function(s)
--     bling.module.tiled_wallpaper("", s, {
--         fg = beautiful.xcolor0,
--         bg = beautiful.xbg,
--         offset_y = 25,
--         offset_x = 25,
--         font = "JetBrainsMono NF",
--         font_size = 30,
--         padding = 100,
--         zickzack = true
--     })
-- end)
--
-- local rubato = require("rubato")
-- local anim_y = rubato.timed {
--     easing = rubato.quadratic,
--     intro = 0.4,
--     duration = 1,
-- }
-- local anim_x = rubato.timed {
--     easing = rubato.quadratic,
--     intro = 0.4,
--     duration = 1,
-- }

-- SCRATCHPADS
-- local anim_y1 = awestore.tweened(1100, {
--     duration = 200,
--     easing = awestore.easing.cubic_in_out
-- })
-- 
-- local anim_y2 = awestore.tweened(1100, {
--     duration = 200,
--     easing = awestore.easing.cubic_in_out
-- })

local term_scratch = bling.module.scratchpad:new { command = "wezterm start --class spad",
                                      rule = { instance = "spad" },
                                      sticky=false, autoclose=false, floating=false,
                                      dont_focus_before_close = true
      --                                geometry={x=360, y=90, height=900, width=1200},
}
awesome.connect_signal("toggle::scratchpad", function() term_scratch:toggle() end)
-- term_scratch:connect_signal("turn_on", function() naughty.notify {title="turn on term"} end)
-- term_scratch:connect_signal("turn_off", function() naughty.notify {title="turn off term"} end)

local webs_scratch = bling.module.scratchpad:new { command = "brave",
                                      rule = { instance = "brave-browser" },
                                      sticky=false, autoclose=false, floating=false,
}
awesome.connect_signal("toggle::webs", function() webs_scratch:toggle() end)


local chat_anim = {
    y = rubato.timed {
        pos = 1090,
        rate = 120,
        easing = rubato.quadratic,
        intro = 0.01,
        duration = 0.05,
        awestore_compat = true
    }
}
local disc_scratch = bling.module.scratchpad:new{ command = "discord", --"~/code/dots/scripts/disc",
                                      rule = { instance = "discord" },
                                      sticky=false,
                                      autoclose=false,
                                      floating=true,
                                      geometry={x=360, y=90, height=900, width=1200},
                                      reapply=true,
                                      rubato = chat_anim
                                      -- awestore={x=anim_x, y=anim_y},
}
awesome.connect_signal("toggle::discord", function() disc_scratch:toggle() end)

local music_anim = {
    y = rubato.timed {
        pos = 1090,
        rate = 120,
        easing = rubato.quadratic,
        intro = 0.05,
        duration = 0.1,
        awestore_compat = true
    }
}
local music_scratch = bling.module.scratchpad:new { command = "lollypop",
                                      rule = { instance = "lollypop" },
                                      sticky=true, autoclose=false,
                                      floating=true, reapply=true,
                                      geometry={x=460, y=550, height=500, width=1000},
                                      rubato = music_anim
                                      -- animation={x=nil, y=anim_y},
}
awesome.connect_signal("toggle::music", function() music_scratch:toggle() end)

local emacs_scratch = bling.module.scratchpad:new { command = "emacs --name emacsscratch",
                                      rule = { instance = "emacsscratch" },
                                      sticky=false, autoclose=false, floating=true,
                                      geometry={x=360, y=90, height=900, width=1200},
}
awesome.connect_signal("toggle::emacsscratch", function() emacs_scratch:toggle() end)

local thunar_scratch = bling.module.scratchpad:new { command = "nautilus",
                                      rule = { instance = "nautilus" },
                                      sticky=false, autoclose=false,
                                      floating=true, reapply=false,
                                      geometry={x=460, y=550, height=500, width=1000},
                                      -- awestore={x=nil, y=anim_y2},
}
awesome.connect_signal("toggle::thunar", function() thunar_scratch:toggle() end)

local scratchs = {term_scratch, webs_scratch, disc_scratch, music_scratch, emacs_scratch}

awesome.connect_signal("scratch::turn_off", function()
    for _, scr in ipairs(scratchs) do
        scr:turn_off()
    end
end)

-- if bling.widget.window_switcher ~= nil then
        -- bling.widget.window_switcher.enable { 
                -- hide_window_switcher_key = 'e'
        -- }
-- end


return require("module.bling")
