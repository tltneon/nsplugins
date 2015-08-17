nut.command.Register({
    adminOnly = true,
    onRun = function(client, arguments)
        local target = nut.command.FindPlayer(client, arguments[1])

        if (IsValid(target)) then
            if (!arguments[2]) then
                nut.util.Notify(nut.lang.Get("missing_arg", 2), client)

                return
            end

            local number = (arguments[2])
            target:SetTeam(number)
            target.character:SetVar("faction", number)
        end
    end

}, "plytransfer")