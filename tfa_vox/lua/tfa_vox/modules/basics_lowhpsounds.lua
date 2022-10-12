if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Low Health Sounds"
MODULE.description = "Plays a sound when a player is at low health"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = {
	["threshold"] = {
		["name"] = "Health Threshold",
		["description"] = "Vocalise when you go under this health",
		["type"] = "integer",
		["min"] = 0,
		["max"] = 100,
		["default"] = 35
	}
}

function MODULE:GetThreshold()
	return TFAVOX_GetModuleOption( self, "threshold", 35 )
end

local myclassv = MODULE.class or MODULE.classname or "basics_lowhpsounds"

hook.Add("TFAVOX_InitializePlayer","TFAVOX_CritIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}

			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].crithit = mdtbl.main.crithit
				ply.TFAVOX_Sounds['main'].crithealth = mdtbl.main.crithealth
			end

		end
	end

end)

hook.Add("PlayerTick","TFAVOX_CritPT",function( ply )

	if SERVER and IsValid(ply) and ply.TFAVOX_Sounds then
		local hp = ply:Health()
		local hpdelta = hp-(ply.TFAVOX_CritPT_OldHP or hp)
		ply.TFAVOX_CritPT_OldHP = hp

		if hp>(ply.SoundCritHealthNum or self:GetThreshold() ) or !ply:Alive() or hp<0 then
			ply.TFAVOX_NextCritSoundHit = true
			ply.TFAVOX_NextLowHPSound = -1
		elseif ply:Alive() then
			ply.TFAVOX_NextPriorityVoiceCall = ply.TFAVOX_NextPriorityVoiceCall or 0
			if ply.TFAVOX_Sounds.main and CurTime()>math.max( ply.TFAVOX_NextPriorityVoiceCall * ( ply.TFAVOX_NextCritSoundHit and 0 or 1 ), ply.TFAVOX_NextLowHPSound or 0) then
				local soundtbl = ( ply.TFAVOX_NextCritSoundHit ) and ply.TFAVOX_Sounds.main["crithit"] or ply.TFAVOX_Sounds.main["crithealth"]
				local snd = TFAVOX_GetSoundTableSound(soundtbl)
				if snd then
					if ply.TFAVOX_NextCritSoundHit then
						ply.TFAVOX_NextPriorityVoiceCall = -1
					end
					TFAVOX_PlayVoicePriority( ply, soundtbl, ply.TFAVOX_NextCritSoundHit and 10 or -5, ply.TFAVOX_NextCritSoundHit )
					ply.TFAVOX_NextCritSoundHit = false
					ply.TFAVOX_NextLowHPSound = ply.TFAVOX_NextPriorityVoiceCall
				end
			end
		end
	end

end)
