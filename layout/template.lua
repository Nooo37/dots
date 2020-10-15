local gcolor = require("gears.color")
local beautiful = require("beautiful")
local math = math

local mylayout = {}

mylayout.name = "template"

function mylayout.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster
    
    -- iterate through masters
    for idx=1,nmaster do
        local c = p.clients[idx]
        local g = {
            x = area.x,
            y = area.y,
            width = area.width,
            height = area.height,
        }
        p.geometries[c] = g
    end 

    -- iterate through slaves
    for idx=1,nslaves do
        local c = p.clients[idx+nmaster]
        local g = {
            x = area.x,
            y = area.y,
            width = area.width,
            height = area.height,
        }
        p.geometries[c] = g
    end
end

local icon_raw = beautiful.config_path .. "/icon/layouts/centered.png"

local function get_icon()
    if icon_raw ~= nil then 
        return gcolor.recolor_image(icon_raw, beautiful.fg_normal)
    else
        return nil
    end 
end 

return {
    layout = mylayout,
    icon_raw = icon_raw,
    get_icon = get_icon,
}

