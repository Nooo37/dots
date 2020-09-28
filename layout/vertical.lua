local gcolor = require("gears.color")
local beautiful = require("beautiful")
local pairs = pairs

local mylayout = {}

mylayout.name = "vertical"
function mylayout.arrange(p)
    local area
    area = p.workarea
    local i = 0
    for _, c in pairs(p.clients) do
            local g = {
                    x = area.x + i * (area.width / #p.clients),
                    y = area.y,
                    width = area.width / #p.clients,
                    height = area.height
            }
            p.geometries[c] = g
            i = i + 1
    end
end

local icon_raw = beautiful.config_path .. "/icon/layouts/vertical.png"

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
