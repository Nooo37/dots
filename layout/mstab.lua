local gears = require("gears")
local wibox = require("wibox")
local gcolor = require("gears.color")
local beautiful = require("beautiful")

local mylayout = {}

mylayout.name = "mstab"

local height_of_tabbar = beautiful.mstab_barheight or 30
local corner_radius = beautiful.corner_radius or 4
local gaps = beautiful.useless_gap or 0
local bg_focus = beautiful.titlebar_bg_focus or "#ff0000"
local bg_normal = beautiful.titlebar_bg_normal or "#000000"

function update_tabbar(clients, t, x, y, width, height)

    local s = t.screen

    -- create the list of clients for the tabbar
    local clientlist = wibox.layout.flex.horizontal()
    for idx,c in ipairs(clients) do
        local client_text = wibox.widget.textbox(c.name)
        local client_bg = beautiful.xbg
        if c == client.focus then
            client_bg = beautiful.xcolor4
        end
        local client_box = wibox.widget {
            client_text,
            bg = client_bg,
            widget = wibox.container.background()
        }
        clientlist:add(client_box)
    end

    -- if no tabbar exists, create one
    if not s.tabbar_exists then
		s.tabbar = wibox {
    	    x = x + gaps,
		    y = y + gaps,
		    height = height - 2*gaps,
		    width = width - 2*gaps,
            shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, corner_radius) end,
		    bg = beautiful.xbg,
		    fg = beautiful.xfg,
		    visible = true
		}
        s.tabbar_exists = true
    end

    -- update the tabbar size, position and clientlist
    s.tabbar.x = x + gaps
    s.tabbar.width = width -2*gaps
    s.tabbar:setup {
         layout = wibox.layout.flex.horizontal,
         clientlist,
    }

    -- TODO the following can also be moved into the tabbar creation
    local function adjust_visiblity(t)
        if t.layout.name == "mstab" then
            s.tabbar.visible = true
        else
            s.tabbar.visible = false
        end
        if #t:clients() == 0 then
            s.tabbar.visible = false
        end
    end

    -- Change visibility of the tab bar when layout or selected tag changes
    tag.connect_signal("property::selected", function(t) adjust_visiblity(t) end)
    tag.connect_signal("property::layout", function(t, layout) adjust_visiblity(t) end)
    tag.connect_signal("tagged", function(t, c) adjust_visiblity(t) end)
    tag.connect_signal("untagged", function(t, c) adjust_visiblity(t) end)
end

function mylayout.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    local master_area_width = area.width * mwfact
    local slave_area_width = area.width - master_area_width

    -- Special case: No slaves -> full screen master width
    if nslaves < 1 then
        master_area_width = area.width
        slave_area_width = 1
    end

    -- Special case: No masters -> full screen slave width
    if nmaster == 0 then
        master_area_width = 1
        slave_area_width = area.width
    end

    -- TODO: Special case: one slave -> no tabbar

    -- Iterate through mastersj
    for idx=1,nmaster do
         local c = p.clients[idx]
         local g = {
            x = area.x,
            y = area.y+(idx-1)*(area.height/nmaster),
            width = master_area_width,
            height = area.height/nmaster,
         }
         p.geometries[c] = g
    end

    -- Iterate through slaves
    -- (also creates a list of all slave clients for update_tabbar)
    local slave_clients = {}
    for idx=1,nslaves do
         local c = p.clients[idx+nmaster]
         slave_clients[#slave_clients+1] = c
         local g = {
            x = area.x + master_area_width,
            y = area.y + height_of_tabbar,
            width = slave_area_width,
            height = area.height - height_of_tabbar,
         }
         p.geometries[c] = g
    end

    if nslaves > 0 then
        update_tabbar(slave_clients, t, area.x + master_area_width, area.y, slave_area_width, height_of_tabbar)
    end
end

local icon_raw = beautiful.config_path .. "/icon/layouts/mstab.png"

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
