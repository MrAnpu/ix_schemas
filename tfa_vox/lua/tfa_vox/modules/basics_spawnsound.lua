if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Spawn Sounds"
MODULE.description = "Plays a sound when a player spawns"
MODULE.author = "TFA"
MODULE.realm = "shared"

local function spawnfunc( ply )
	ply.TFAVOX_Spawn_Last = CurTime()
	if SERVER then
		TFAVOX_ResetNexts(ply)

		timer.Simple( ply.ChangedModelTime or 0, function()

			if IsValid(ply) and ply.TFAVOX_Sounds and TFAVOX_IsValid(ply) and ply:Alive() then

				local sndtbl = ply.TFAVOX_Sounds['main']

				if sndtbl then

					local ind = "TFAVOX_Ply_"..ply:EntIndex().."_SpawnSound"
					timer.Create(ind,0.1,0,function()
						if !IsValid(ply) then print("notisvalid") timer.Remove(ind) end
						if ply.TFAVOX_IsFullySpawned then
							TFAVOX_PlayVoicePriority( ply, sndtbl.spawn, 2, true )
							timer.Remove(ind)
						end
					end)

				end

			end

		end)

		ply.ChangedModelTime = 0

		if TFAVOX_IsValid(ply) then
			TFAVOX_Init(ply)

			if ply:Alive() then
				local mdl = ply:GetModel()
				ply.TFAVOX_Old_Model_PS = ply.TFAVOX_Old_Model_PS or mdl
				if mdl!=ply.TFAVOX_Old_Model_PS then
					TFAVOX_Init(ply,true,true)
					return
				end
				ply.TFAVOX_Old_Model_PS = mdl
			end
		else
			TFAVOX_StopAll(ply)
		end

		ply.TFAVOX_Sounds_Next["jump"] = CurTime()+0.25
		ply.TFAVOX_Sounds_Next["pickup"] = CurTime()+0.25
		ply.TFAVOX_Sounds_Next["heal"] = CurTime()+0.25
	end
end

if SERVER then
	util.AddNetworkString("TFAVOX_Spawn_FullySpawned")
	net.Receive("TFAVOX_Spawn_FullySpawned",function(len,ply)
		ply.TFAVOX_IsFullySpawned = true
		--if game.SinglePlayer() then
			spawnfunc(ply)
		--end
	end)
end

hook.Add("TFAVOX_InitializePlayer","TFAVOX_SpawnIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}

			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].spawn = mdtbl.main.spawn
			end

		end
	end

end)

hook.Add("PlayerSpawn","TFAVOX_SpawnPS", spawnfunc)

TFA_VOX_SPAWN_HASSENTSPAWNNET = true

hook.Add("HUDPaint", "TFAVOX_SpawnPS_init",function()
	if !TFA_VOX_SPAWN_HASSENTSPAWNNET then return end

	if IsValid(LocalPlayer()) then

		timer.Simple(0.1,function()
			net.Start("TFAVOX_Spawn_FullySpawned")
			net.SendToServer()
		end)

		TFA_VOX_SPAWN_HASSENTSPAWNNET = false

	end
end)
