if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Taunt Sounds"
MODULE.description = "Plays a sound when a player taunts"
MODULE.author = "TFA"
MODULE.realm = "shared"

hook.Add("TFAVOX_InitializePlayer","TFAVOX_TauntIP",function(ply)
	
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl and mdtbl.taunt then
			
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}
			
			ply.TFAVOX_Sounds['taunt'] = TFAVOX_FullCopy( mdtbl.taunt )
			
		end
	end
	
end)

hook.Add("PlayerShouldTaunt", "TFAVOX_Taunts", function(ply, act)
	if !IsValid(ply) or !ply.IsPlayer or !ply:IsPlayer() then return end
	if TFAVOX_IsValid(ply) then
				
		if ply.TFAVOX_Sounds then
		
			local sndtbl = ply.TFAVOX_Sounds['taunt'] 
			
			if sndtbl then
				TFAVOX_PlayVoicePriority( ply, sndtbl[act or 0], 10 )
			end
			
		end
	end
end)