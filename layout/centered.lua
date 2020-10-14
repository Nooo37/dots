local gcolor = require("gears.color")
local beautiful = require("beautiful")
local pairs = pairs

local mylayout = {}

mylayout.name = "centered"
function mylayout.arrange(p)
    local area
    area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local num_of_clients_in_left_pane  = math.floor((#p.clients - 1)/2)
    local num_of_clients_in_right_pane = #p.clients - 1 - num_of_clients_in_left_pane
    local iterable_of_client_on_right_pane = 0
    local iterable_of_client_on_left_pane  = 0
    local mwfact = t.master_width_factor 
    for idx, c in pairs(p.clients) do
      local g
      -- Special case: One client
      if #p.clients == 1 then -- if only one client make fullscreen and leave
        g = {
          x = area.x,
          y = area.y,
          width = area.width,
          height = area.height,
        }
      -- Special case: Two clients
      elseif idx == 1 and #p.clients == 2 then -- if client is master and there are two clients in total
        g = {
          x = area.x,
          y = area.y,
          width = area.width * mwfact,
          height = area.height,
        }
      elseif idx == 2 and #p.clients == 2 then -- if client is slave and there are two clients in total
          g = {
            x = area.x + area.width * mwfact,
            y = area.y,
            width = area.width * (1-mwfact),
            height = area.height,
          }
      -- Normal case: More than 2 clients
      elseif idx == 1 then -- if client is master (and there more than 2 clients in total)
        g = {
          x = area.x + (1-mwfact)/2 * area.width,
          y = area.y,
          width = area.width * mwfact,
          height = area.height,
        }
      else -- if client is slave
        if idx % 2 == 0 then -- if client on right pane
          g = {
            x = area.x + mwfact * area.width + (1-mwfact)/2 * area.width,
            y = area.y + iterable_of_client_on_right_pane * (area.height/num_of_clients_in_right_pane),
            width = (1-mwfact)/2 * area.width,
            height = area.height/num_of_clients_in_right_pane,
          }
          iterable_of_client_on_right_pane = iterable_of_client_on_right_pane + 1
        else -- if client on left pane
          g = {
            x = area.x,
            y = area.y + iterable_of_client_on_left_pane * (area.height/num_of_clients_in_left_pane),
            width = (1-mwfact)/2 * area.width,
            height = area.height/num_of_clients_in_left_pane,
          }
          iterable_of_client_on_left_pane = iterable_of_client_on_left_pane + 1
        end
      end
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
