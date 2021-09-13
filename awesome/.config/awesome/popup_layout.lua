-- a popup that shows the available layouts when switching between them

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local helpers = require("helpers")


local function get_all_factors(number)
	--[[--
	Gets all of the factors of a given number
	@Parameter: The number to find the factors of
	@Returns: A table of factors of the number
	--]]--
	local factors = {}
	for possible_factor=1, math.sqrt(number), 1 do
		local remainder = number%possible_factor

		if remainder == 0 then
			local factor, factor_pair = possible_factor, number/possible_factor
			table.insert(factors, factor)

			if factor ~= factor_pair then
				table.insert(factors, factor_pair)
			end
		end
	end

	table.sort(factors)
	return factors
end


local all_factors = get_all_factors(#awful.layout.layouts)
local some_factor_in_the_middle = all_factors[math.floor(#all_factors/2)]


local ll = awful.widget.layoutlist {
    base_layout = wibox.widget {
        spacing         = 10,
        forced_num_cols = some_factor_in_the_middle,
        layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
        {
            {
                id            = 'icon_role',
                forced_height = 30,
                forced_width  = 30,
                widget        = wibox.widget.imagebox,
            },
            margins = 10,
            widget  = wibox.container.margin,
        },
        id              = 'background_role',
        forced_width    = 50,
        forced_height   = 50,
        shape           = gears.shape.hexagon,
        widget          = wibox.container.background,
    },
}

local layout_popup = awful.popup {
    widget = wibox.widget {
        ll,
        margins = 20,
        widget  = wibox.container.margin,
    },
    border_color = beautiful.popup_border_color,
    border_width = beautiful.popup_border_width,
    placement    = awful.placement.centered,
    ontop        = true,
    visible      = false,
    shape        = helpers.rrect(beautiful.corner_radius),
}


local hide_layout_box = gears.timer {
   timeout = 2,
   autostart = true,
   callback = function()
      layout_popup.visible = false
   end
}

-- awesome.connect_signal("toggle::layoutnav", function()
tag.connect_signal("property::layout", function(_)
    -- layout_popup.visible = not layout_popup.visible
    if layout_popup.visible then
        hide_layout_box:again()
    else
        layout_popup.visible = true
        hide_layout_box:again()
    end
end)
