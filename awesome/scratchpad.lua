-- Heavily modified from here: https://github.com/notnew/awesome-scratch

local awful = require("awful")
local gears = require("gears")
local helpers = require("bling.helpers")

local defaultRule = {instance = "jucktnicht"}
local scratch = {}

local function turn_off(c)
    -- there is an option to make the scratchpad sticky,
    -- so that needs to be turned off before hiding the client
    c.sticky = false
    helpers.client.turn_off(c)
end

-- new helper -> use in swallowing
local function is_child_of(c, pid)
    -- io.popen is normally discouraged. Should probably be changed 
    if tostring(c.pid) == tostring(pid) then return true end
    local pid_cmd = [[pstree -T -p -a -s ]] .. tostring(c.pid) ..
        [[ | sed '2q;d' | grep -o '[0-9]*$' | tr -d '\n']]
    local handle = io.popen(pid_cmd)
    local parent_pid = handle:read("*a")
    handle:close()
    return tostring(parent_pid) == tostring(pid) or
        tostring(parent_pid) == tostring(c.pid)
end

-- new helper
local function find(rule)
    local function matcher(c) return awful.rules.match(c, rule) end
    local clients = client.get()
    local findex  = gears.table.hasitem(clients, client.focus) or 1
    local start   = gears.math.cycle(#clients, findex + 1)

    local matches = {}
    for c in awful.client.iterate(matcher, start) do
        matches[#matches + 1] = c
    end

    return matches
end

function scratch.raise(cmd, rule, args)
    local matches = find(rule)
    if matches[1] then
       -- if a client was found, raise it and apply the properties
       c = matches[1]
       helpers.client.turn_on(c)
       c.sticky = args.sticky
       if args.geometry then 
           c:geometry(args.geometry)
       end
       if args.autoclose then
           c:connect_signal("unfocus", function(c) turn_off(c) end)
       end
       return
    else
        -- if a client was not found, spawn it, find the corresponding window,
        -- apply the properties only once (until the next closeing)
        local pid = awful.spawn.with_shell(cmd)
        if args.geometry then
            local function inital_apply(c)
                if is_child_of(c, pid) then
                    c.floating = args.floating
                    c:geometry(args.geometry)
                end
                client.disconnect_signal("manage", inital_apply)
            end
            client.connect_signal("manage", inital_apply)
        end
        if args.autoclose then 
            local function inital_autoclose(c)
                if is_child_of(c, pid) then
                    c:connect_signal("unfocus", function(c) turn_off(c) end)
                end
                client.disconnect_signal("manage", inital_autoclose)
            end
            client.connect_signal("manage", inital_autoclose)
        end
        return 
    end
end

function scratch.toggle(cmd, rule, args)
    local rule = rule or defaultRule
    if not args then args = {} end
    if client.focus and awful.rules.match(client.focus, rule) then
        turn_off(client.focus)
    else
        scratch.raise(cmd, rule, args)
    end
end

return scratch
