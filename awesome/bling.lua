-- all my bling related config goes here

local awesome, root, client = awesome, root, client
local beautiful = require("beautiful")

local awestore = require("awestore")
local bling = require("module.bling")

-- FLASH FOCUS and PLAYERCTL SIGNAL
bling.module.flash_focus.enable()
bling.signal.playerctl.enable()

-- TAG and TASK PREVIEW
local margin_edge = 10

bling.widget.tag_preview.enable {
    show_client_content = true,
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

-- WALLPAPER

-- don't really need the module for that but whatever
bling.module.wallpaper.setup {
   wallpaper = { beautiful.wallpaper }
}

--[[
awful.screen.connect_for_each_screen(function(s)
    bling.module.tiled_wallpaper("", s, {
        fg = beautiful.xcolor0,
        bg = beautiful.xbg,
        offset_y = 25,
        offset_x = 25,
        font = "JetBrainsMono NF",
        font_size = 30,
        padding = 100,
        zickzack = true
    })
end)
--]]

-- SCRATCHPADS
local anim_y1 = awestore.tweened(1100, {
    duration = 200,
    easing = awestore.easing.cubic_in_out
})

local anim_y2 = awestore.tweened(1100, {
    duration = 200,
    easing = awestore.easing.cubic_in_out
})

local term_scratch = bling.module.scratchpad { command = "alacritty --class spad",
                                      rule = { instance = "spad" },
                                      sticky=false, autoclose=false, floating=false,
                                      dont_focus_before_close = true
      --                                geometry={x=360, y=90, height=900, width=1200},
}
awesome.connect_signal("toggle::scratchpad", function() term_scratch:toggle() end)
-- term_scratch:connect_signal("turn_on", function() naughty.notify {title="turn on term"} end)
-- term_scratch:connect_signal("turn_off", function() naughty.notify {title="turn off term"} end)

local webs_scratch = bling.module.scratchpad { command = "brave",
                                      rule = { instance = "brave-browser" },
                                      sticky=false, autoclose=false, floating=false,
}
awesome.connect_signal("toggle::webs", function() webs_scratch:toggle() end)

local disc_scratch = bling.module.scratchpad{ command = "~/code/dots/scripts/disc",
                                      rule = { instance = "discord" },
                                      sticky=false, autoclose=false, floating=true,
                                      geometry={x=360, y=90, height=900, width=1200},
                                      reapply=true,
                                      awestore={x=nil, y=anim_y1},
}
awesome.connect_signal("toggle::discord", function() disc_scratch:toggle() end)

local music_scratch = bling.module.scratchpad { command = "lollypop",
                                      rule = { instance = "lollypop" },
                                      sticky=true, autoclose=false,
                                      floating=true, reapply=true,
                                      geometry={x=460, y=550, height=500, width=1000},
                                      awestore={x=nil, y=anim_y2},
}
awesome.connect_signal("toggle::music", function() music_scratch:toggle() end)

local emacs_scratch = bling.module.scratchpad { command = "emacs --name emacsscratch",
                                      rule = { instance = "emacsscratch" },
                                      sticky=false, autoclose=false, floating=true,
                                      geometry={x=360, y=90, height=900, width=1200},
}
awesome.connect_signal("toggle::emacsscratch", function() emacs_scratch:toggle() end)

local thunar_scratch = bling.module.scratchpad { command = "nautilus",
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

-- bling.widget.window_switcher.enable {  }


return require("module.bling")
