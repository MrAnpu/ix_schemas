local PLUGIN = PLUGIN

util.AddNetworkString("gesture_network")

net.Receive("gesture_network",function(len,ply)
    local snd = net.ReadString()
    if IsValid(ply)and ply:Alive() then
        print(snd)
    end
end)