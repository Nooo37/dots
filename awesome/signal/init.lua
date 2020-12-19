
-- table_of_names is just the list of signals (their filename) that should be initalized
-- usage: require("signal")({"command1", "command2 -e"})

function start_signals(table_of_names)
    for _, signal in ipairs(table_of_names) do
        require("signal." .. signal)
    end
end

return start_signals
