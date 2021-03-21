-- layout

local awful = require("awful")
local gears = require("gears")
local gcolor = require("gears.color")
local beautiful = require("beautiful")
local math = math

local mylayout = {}

mylayout.name = "huhu"

local function is_cool(c)
    for _, v in ipairs({"emacs", "Emacs", "Alacritty"}) do
	if c.class and c.class == v then
	    return true
	end
    end
    return false
end


function mylayout.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag

    if #p.clients == 1 and is_cool(p.clients[1]) then
	local c = p.clients[1]
	local g = {
	    width = t.master_width_factor * area.width,
	    height = area.height - 4 * beautiful.useless_gap,
	    y = area.y + 2 * beautiful.useless_gap,
	    x = (1 - t.master_width_factor) * area.width / 2,
	}
	p.geometries[c] = g
    else
	awful.layout.suit.tile.right.arrange(p)
    end
end

local icon_raw = "~/.config/awesome/bling/icons/layouts/equalarea.png"

local function get_icon()
    if icon_raw ~= nil then
        return gcolor.recolor_image(icon_raw, beautiful.fg_normal)
    else
        return nil
    end
end

beautiful.layout_huhu = get_icon()

return mylayout
