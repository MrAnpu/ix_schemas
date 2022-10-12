if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Death Sounds"
MODULE.description = "Plays a sound when a player dies"
MODULE.author = "TFA"
MODULE.realm = "shared"

hook.Add("TFAVOX_InitializePlayer","TFAVOX_DeathIP",function(ply)
	
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then
			
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}
			
			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}
			
			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].death = mdtbl.main.death
			end
			
		end
	end
	
end)
	
hook.Add("DoPlayerDeath","TFAVOX_DeathDPD",function(ply)
	if TFAVOX_IsValid(ply) then
				
		if ply.TFAVOX_Sounds then
		
			local sndtbl = ply.TFAVOX_Sounds['main'] 
			
			if sndtbl then
	
				ply.TFAVOX_Sounds_Next["pain"] = -1
	
				TFAVOX_PlayVoicePriority( ply, sndtbl.death, 10, true )
				
				if !sndtbl.death or !sndtbl.death.sound then
					TFAVOX_StopAll( ply )				
				end
				
			else
				TFAVOX_StopAll( ply )
			end
			
		end
		
	end
end)