local gcolor = require("gears.color")
local beautiful = require("beautiful")
local pairs = pairs

local mylayout = {}

mylayout.name = "horizontal"
function mylayout.arrange(p)
    local area
    area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local mwfact = t.master_width_factor
    for idx, c in pairs(p.clients) do
      local g
      if #p.clients == 1 then -- if only one client make fullscreen and leave
        g = {
          x = area.x,
          y = area.y,
          width = area.width,
          height = area.height,
        }
      elseif idx == 1 then -- if client is master
        g = {
          x = area.x,
          y = area.y,
          width = area.width,
          height = area.height * mwfact,
        }
      else -- if client is slave
        g = {
          x = area.x,
          y = area.y + (area.height * mwfact) + (idx-2) * ((area.height * (1-mwfact)) / (#p.clients - 1)),
          width = area.width,
          height = ( area.height * (1-mwfact) ) / ( #p.clients - 1),
        }
      end
      p.geometries[c] = g
    end
end

local icon_raw = beautiful.config_path .. "/icon/layouts/horizontal.png"

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
