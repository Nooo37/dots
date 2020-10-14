local awful = require("awful")
local beautiful = require("beautiful")


-- -- manual layout
local machi = require("layout.machi")
beautiful.layout_machi = machi.get_icon()
local editor = machi.editor.create()

local vertical = require("layout.vertical")
beautiful.layout_vertical = vertical.get_icon()

local horizontal = require("layout.horizontal")
beautiful.layout_horizontal = horizontal.get_icon()

local centered = require("layout.centered")
beautiful.layout_centered = centered.get_icon()

-- awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
    --require("layout.centerwork"),
    centered.layout,
    vertical.layout,
    --strange.layout,
    awful.layout.suit.tile,
    --horizontal.layout,
    machi.default_layout,
    awful.layout.suit.spiral,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}


awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
