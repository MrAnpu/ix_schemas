if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Footsteps"
MODULE.description = "Custom footstep sounds"
MODULE.author = "TFA"
MODULE.realm = "shared"

hook.Add("TFAVOX_InitializePlayer","TFAVOX_TauntIP",function(ply)
	
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then
			
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}
			
			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}
			
			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].step = mdtbl.main.step
			end
			
		end
	end
	
end)
	
hook.Add("PlayerFootstep","TFAVOX_Footsteps", function(ply,pos,foot,snd,vol,filter)	

	if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds['main'] then
		local sndtbl = ply.TFAVOX_Sounds['main'].step
		local snd = TFAVOX_GetSoundTableSound(sndtbl,true)
		if snd and snd!="" then
			if string.find(snd,"wav") then
				ply:EmitSound( snd )
				return true
			end
		end
	end
	
end)