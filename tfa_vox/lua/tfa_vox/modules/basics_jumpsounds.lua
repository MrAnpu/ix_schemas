if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Jump Sounds"
MODULE.description = "Plays a sound when a player jumps"
MODULE.author = "TFA"
MODULE.realm = "shared"

hook.Add("TFAVOX_InitializePlayer","TFAVOX_JumpIP",function(ply)
	
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then
			
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}
			
			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}
			
			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].jump = mdtbl.main.jump
			end
			
		end
	end
	
end)

hook.Add("KeyPress", "TFAVOX_Jump", function(ply, key)
	if ( SERVER and ply:Alive() and key==IN_JUMP and ply:IsOnGround() and !ply:InVehicle() and ply:GetMoveType() != MOVETYPE_NOCLIP and TFAVOX_IsValid(ply) ) then
		
		if CurTime()<(ply.TFAVOX_Spawn_Last or -999)+0.2 then return end
		
		if ply.TFAVOX_Sounds then
		
			local sndtbl = ply.TFAVOX_Sounds['main'] 
			
			if sndtbl then
				TFAVOX_PlayVoicePriority( ply, sndtbl.jump, -1 )
			end
			
		end
		
	end
end)