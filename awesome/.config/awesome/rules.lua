-- rules

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local client = client

--{{{ rules
-- Rules to apply to new clients (through the "manage" signal).

-- keybinds to resize clients (will be applied later)
local modkey = "Mod4"
local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

awful.rules.rules = {
    {
        rule = { }, -- Whitelisting tiling applications
        except_any = {
            instance = {
                "org.gnome.Nautilus", "evince", "zathura", "spad",
                "emacs", "org.wezfurlong.wezterm", "Alacritty", "urxvt",
                "brave-browser", "Firefox", "chromium",
                "Com.github.xournalpp.xournalpp", "org.gnome.glade"
            }
        },
        properties = { floating = true }
    },
    {
        rule = { },  -- All clients will match this rule.
        properties = {
            focus = awful.client.focus.filter,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            titlebars_enabled = false,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen +
                awful.placement.centered
        },
        callback = awful.client.setslave
    },
    {
        rule_any = { properties = { floating = true } },
        properties = { above = true }
    },
    {
        rule_any = { instance = { "consoom" } },
        properties = { placement = awful.placement.bottom_right, ontop = true }
    },
    -- {
    --     rule_any = { instance = { "discord" } },
    --     properties = { tag = "2", switchtotag = true }
    -- },
    {
        rule_any = { instance = { "discord", "lollypop" } },
        properties = {
                ontop = true,
                tag = "2",
                switchtotag = true,
        },
        callback = awful.titlebar.hide,
    },
}
--}}}

--{{{ titlebar only for floating windows
-- client.connect_signal("property::floating", function(c)
--         if not c.floating or c.instance == "discord.com__app" then
--                 awful.titlebar.hide(c)
--         else
--                 awful.titlebar.show(c)
--         end
-- end)

--}}}

--{{{ sloppy focus
client.connect_signal("mouse::enter", function(c)
                          c:emit_signal("request::activate", "mouse_enter",
                                        {raise = false})
end)
--}}}

---{{{ on client spawn
client.connect_signal("manage",function(c)
    if c.class == "aw-qt" or c.class == "gromit-mpx" then c:kill() end
end)
---}}}

---{{{ rounded corners but not on maximized clienta
local function is_maximized(c)
    local function _fills_screen()
        local wa = c.screen.workarea
        local cg = c:geometry()
        return wa.x == cg.x and wa.y == cg.y and wa.width == cg.width and
            wa.height == cg.height
    end
    return c.maximized or (not c.floating and _fills_screen())
end


local function update_geo(c)
    if is_maximized(c) then
        c.shape = function(cr,w,h)
            gears.shape.rounded_rect(cr,w,h,0)
        end
    else
        c.shape = function(cr,w,h)
           gears.shape.rounded_rect(cr,w,h, beautiful.border_radius or 0)
        end
    end
end

client.connect_signal("property::geometry", update_geo)
---}}}
