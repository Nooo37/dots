local farbig = require("farbig")
local colors = farbig.get("nord")

local function get_xrdb(name)
    local handle = io.popen("xrdb -q | grep '" .. tostring(name) .. "' | awk '{ print $2 }' | tr -d '\n'")
    return handle:read("*a")
end

local function get_color(num)
    return get_xrdb("color" .. tostring(num) .. ":")
end

local c = {
--    fg = get_xrdb("foreground"),
--    bg = get_xrdb("background"),
--    black = get_color(0),
--    red = get_color(1),
--    green = get_color(2),
--    yellow = get_color(3),
--    blue = get_color(4),
--    magenta = get_color(5),
--    cyan = get_color(6),
--    white = get_color(7),
--    gray = get_color(8),
    fg = colors.base05,
    bg = colors.base00,
    black = colors.base01,
    red = colors.base08,
    green = colors.base0B,
    yellow = colors.base0A,
    blue = colors.base0D,
    magenta = colors.base09,
    cyan = colors.base0C,
    white = colors.base04,
    gray = colors.base03,
}


return c
