local function get_xrdb(name)
    local handle = io.popen("xrdb -q | grep '" .. tostring(name) .. "' | awk '{ print $2 }' | tr -d '\n'")
    return handle:read("*a")
end

local function get_color(num)
    return get_xrdb("color" .. tostring(num) .. ":")
end

local c = {
    fg = get_xrdb("foreground"),
    bg = get_xrdb("background"),
    black = get_color(0),
    red = get_color(1),
    green = get_color(2),
    yellow = get_color(3),
    blue = get_color(4),
    magenta = get_color(5),
    cyan = get_color(6),
    white = get_color(7),
    gray = get_color(8),
    redB = get_color(9),
    greenB = get_color(10),
    yellowB = get_color(11),
    blueB = get_color(12),
    magentaB = get_color(13),
    cyanB = get_color(14),
    whiteB = get_color(15),
}


return c
