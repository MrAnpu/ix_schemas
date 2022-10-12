local PLUGIN = PLUGIN

PLUGIN.name = "Player Gestures"
PLUGIN.description = "Adds gestures that can be used for certain supported animations."
PLUGIN.author = "Mr.Spooky"

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

-- Don't bother DMing me to add female variants, do it yourself.
--[[PLUGIN.gestures = { -- Mainly for the citizen_male models, or models that include the citizen male gestures
    {gesture = "g_salute", command = "Salute", id = 1444},
    {gesture = "g_antman_dontmove", command = "DontMove", id = 1445},
    {gesture = "g_antman_stayback", command = "StayBack", id = 1446},
    {gesture = "g_armsout", command = "ArmSout", id = 1447},
    {gesture = "g_armsout_high", command = "ArmSoutHigh", id = 1448},
    {gesture = "g_chestup", command = "ChestUp", id = 1449},
    {gesture = "g_clap", command = "Clap", id = 1450},
    {gesture = "g_fist_L", command = "FistLeft", id = 1451},
    {gesture = "g_fist_r", command = "FistRight", id = 1452},
    {gesture = "g_fist_swing_across", command = "FistSwing", id = 1453},
    {gesture = "g_fistshake", command = "FistShake", id = 1454},
    {gesture = "g_frustrated_point_l", command = "PointFrustrated", id = 1455},
    {gesture = "G_noway_big", command = "No", id = 1456},
    {gesture = "G_noway_small", command = "NoSmall", id = 1457},
    {gesture = "g_plead_01", command = "Plead", id = 1458},
    {gesture = "g_point", command = "Point", id = 1459},
    {gesture = "g_point_swing", command = "PointSwing", id = 1460},
    {gesture = "g_pointleft_l", command = "PointLeft", id = 1461},
    {gesture = "g_pointright_l", command = "PointRight", id = 1462},
    {gesture = "g_present", command = "Present", id = 1463},
    {gesture = "G_shrug", command = "Shrug", id = 1464},
    {gesture = "g_thumbsup", command = "ThumbsUp", id = 1465},
    {gesture = "g_wave", command = "Wave", id = 1466},
    {gesture = "G_what", command = "What", id = 1467},
    {gesture = "hg_headshake", command = "HeadShake", id = 1468},
    {gesture = "hg_nod_no", command = "HeadNo", id = 1469},
    {gesture = "hg_nod_yes", command = "HeadYes", id = 1470},
    {gesture = "hg_nod_left", command = "HeadLeft", id = 1471},
    {gesture = "hg_nod_right", command = "HeadRight", id = 1472},

    --{gesture = "hg_nod_right", command = "HeadRight", id = 1473},
}]]

--[[function PLUGIN:DoAnimationEvent(ply, event, data)
    if ( event == PLAYERANIMEVENT_CUSTOM_GESTURE ) then
        for k, v in pairs(PLUGIN.gestures) do
            if ( data == v.id ) then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence(v.gesture), 0, true)

                return ACT_INVALID
            end
        end
    end
end]]

--[[for k, v in pairs(PLUGIN.gestures) do
    local commandname = string.Replace(v.gesture, "hg_", "")
    commandname = string.Replace(commandname, "g_", "")
    commandname = string.Replace(commandname, "antman_", "")
    commandname = string.Replace(commandname, "_", " ")

    concommand.Add("ix_act_"..v.command, function(ply, cmd, args)
        --ply:DoPlayerGesture(ply, gesture, GESTURE_SLOT_CUSTOM)
        --ply:DoAnimationEvent(v.id)
    end)

    ix.command.Add("Gesture"..v.command, {
        description = "Play the "..commandname.." gesture.",
        OnCanRun = function(_, ply)
            if ply:IsFemale() then
                return "Female variants are not supported."
            end
        end,
        OnRun = function(_, ply)
            if ( SERVER ) then
                ply:ConCommand("ix_act_"..v.command)
            end
        end
    })
end]]

--[[ix.command.Add("GestureTyping", {
    description = "Play the typing gesture.",
    OnCanRun = function(_, ply)
        if ply:IsFemale() then
            return "Female variants are not supported."
        end
    end,
    OnRun = function(_, ply)
        PLUGIN:DoPlayerGesture(ply, ply:LookupSequence( "Typinggesture" ), GESTURE_SLOT_CUSTOM)
    end
})]]


function PLUGIN:Think() -- checking if it works for other players
    -- go throught each player and if they are a bot make them send a chat message every 5 seconds
    for _, v in ipairs(player.GetAll()) do
        if (v:IsBot()) then
            if (v.ixNextChat or 0) < CurTime() then
                hook.Run("PlayerSay", v, "?")
                v.ixNextChat = CurTime() + 5
            end
        end
    end
end

--[[do
    ix.command.Add("Gesture", {
        description = "Plays a gesture.",
        arguments = {
            ix.type.string
        },
        OnRun = function(self, client, str) 
            if (!SERVER) then return end

            local gestures = {}
            gestures["typing"] = {"Typinggesture"}
            gestures["keypad"] = {"Keypad G"}
            gestures["search"] = {"searchgesture"}
            gestures["punct"] = {"Kgesture01"}
            gestures["punct2"] = {"Kgesture02"}
            gestures["punct3"] = {"Kgesture03"}
            gestures["punct4"] = {"Kgesture04"}
            gestures["punct5"] = {"Kgesture05"}
            gestures["punct6"] = {"Kgesture06"}
            -- TODO: Finish
            local tab = gestures[str]
            if (!tab) then return end
            local sequence = tab[math.random(1,#tab)]
            if (!sequence) then return end
            gesture = client:LookupSequence(sequence)
            PLUGIN:DoPlayerGesture(client, gesture, GESTURE_SLOT_VCD, false)

        end
    })
end]]

if (SERVER) then
    util.AddNetworkString( "RGDoGesture" )
      
    local allowedChatTypes = {
        ["ic"] = true,
        ["w"] = true,
        ["y"] = true,
    }
    
    function PLUGIN:PrePlayerMessageSend(ply, chatType, message, bAnonymous)
        if ( allowedChatTypes[chatType] ) then
            if ( message:find("right away") ) then
                --ply:ConCommand("ix_act_what")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture08" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("over here") ) then
                --ply:ConCommand("ix_act_wave")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture04p" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("no") ) then
                --ply:ConCommand("ix_act_nosmall")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture02p" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("hold on") ) then
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture06" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("ah yes") ) then
                --ply:ConCommand("ix_act_headyes")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture07" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("umm hello") ) then
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture10" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("ah hello") ) then
                --ply:ConCommand("ix_act_present")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture10p" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("lets see") ) then
                --ply:ConCommand("ix_act_no")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture11" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("agh!") ) then
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture12" ), GESTURE_SLOT_CUSTOM)
            elseif ( message:find("perhaps") ) then
                --ply:ConCommand("ix_act_headNo")
                self:DoPlayerGesture(ply, ply:LookupSequence( "Kgesture13p" ), GESTURE_SLOT_CUSTOM)
            end
        end
    end

    function PLUGIN:DoPlayerGesture(ply, gesture, slot)
        if (!IsValid( ply )) then return end
        if (!gesture) then return end
        local slot = slot or GESTURE_SLOT_FLINCH
        print("function worked")

        net.Start("RGDoGesture")
        net.WriteEntity(ply)
        net.WriteInt(gesture, 16)
        net.WriteInt(slot, 16)
        net.Broadcast()
    end
end
 
 
if (CLIENT) then
    net.Receive( "RGDoGesture", function(len)
        local ply = net.ReadEntity()
        local gesture = net.ReadInt(16)
        local slot = net.ReadInt(16) 
        if (!IsValid( ply )) then return end
        print("net recive worked")
 
       ply:AddVCDSequenceToGestureSlot( slot, gesture, 0, 1 )
    end)
end