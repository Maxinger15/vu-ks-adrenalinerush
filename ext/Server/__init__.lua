local debug = true

if debug then
    Events:Subscribe(
        "Player:Chat",
        function(player, recipientMask, message)
            if message == "!actRush" then
                NetEvents:SendToLocal("vu-ks-adrenalinerush:Enable",player)
            end
            if message == "!desRush" then
                NetEvents:SendToLocal("vu-ks-adrenalinerush:Disable",player)
            end
        end
    )
end
