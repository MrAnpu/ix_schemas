if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Heal Sounds"
MODULE.description = "Plays a sound when a player heals"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = {
	["threshold"] = { 
		["name"] = "Health Threshold",
		["description"] = "Vocalise when you heal more than this value",
		["type"] = "integer",
		["min"] = 0,
		["max"] = 100,
		["default"] = 0
	}
}

function MODULE:GetThreshold()
	return TFAVOX_GetModuleOption( self, "threshold", 0 )
end

hook.Add("TFAVOX_InitializePlayer","TFAVOX_HealIP",function(ply)
	
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then
			
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}
			
			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}
			
			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].heal = mdtbl.main.heal
				ply.TFAVOX_Sounds['main'].healmax = mdtbl.main.healmax
			end
			
		end
	end
	
end)

hook.Add("PlayerTick","TFAVOX_HealPT",function( ply )
	if SERVER and IsValid(ply) and ply.TFAVOX_Sounds and ply.TFAVOX_HasBeenSpawnProtected then
		local al = ply:Alive()
		if !al then
			ply.TFAVOX_HasBeenSpawnProtected = false
			return
		end
		ply.TFAVOX_Heal_AliveOld = ply.TFAVOX_Heal_AliveOld or al
		local hp = ply:Health()
		ply.TFAVOX_Heal_HPOld = ply.TFAVOX_Heal_HPOld or hp
		local hpdelta = hp-ply.TFAVOX_Heal_HPOld
		local spawndied = ( ply.TFAVOX_Heal_AliveOld != al )
		ply.TFAVOX_Heal_HPOld = hp
		ply.TFAVOX_Heal_AliveOld = al
		if ply:Alive() and hpdelta>self:GetThreshold() and CurTime()>( (ply.TFAVOX_Spawn_Last or -999)+0.1 ) and !spawndied then
			
			local sndtbl = ply.TFAVOX_Sounds['main'] 
			
			timer.Simple(0.01,function()
				if sndtbl and IsValid(ply) and CurTime()>ply.TFAVOX_Sounds_Next["main"] or 0 then
					TFAVOX_PlayVoicePriority( ply, ( hp >= 100 ) and sndtbl.healmax or sndtbl.heal, 0 )
				end
			end)
		end
	end
end)