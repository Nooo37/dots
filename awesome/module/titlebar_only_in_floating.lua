-- MODULE titlebar_only_in_floating
-- creates titlebars with awful.titlebar only when the client is floating

-- Requires `titlebars_enabled = false` for all clients in awful.rules

local awful = require("awful")

-- Toggle titlebar on or off depending on s. Creates titlebar if it doesn't exist
local function setTitlebar(client, s)
    if s then
        if client.titlebar == nil then
            client:emit_signal("request::titlebars", "rules", {})
        end
        awful.titlebar.show(client)
    else
        awful.titlebar.hide(client)
    end
end

--Toggle titlebar on floating status change
client.connect_signal("property::floating", function(c)
    setTitlebar(c, c.floating)
end)

-- Hook called when a client spawns
client.connect_signal("manage", function(c)
    setTitlebar(c, c.floating or c.first_tag.layout == awful.layout.suit.floating)
end)

-- Show titlebars on tags with the floating layout
tag.connect_signal("property::layout", function(t)
    -- New to Lua ?
    -- pairs iterates on the table and return a key value pair
    -- I don't need the key here, so I put _ to ignore it
    for _, c in pairs(t:clients()) do
        if t.layout == awful.layout.suit.floating then
            setTitlebar(c, true)
        else
            setTitlebar(c, false)
        end
    end
end)
