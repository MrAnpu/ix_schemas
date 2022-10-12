if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Pain Sounds"
MODULE.description = "Plays a sound when a player gets hurt"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = {
	["chance"] = {
		["name"] = "Sound Chance",
		["description"] = "X% chance to play a pain sound",
		["type"] = "integer",
		["min"] = 0,
		["max"] = 100,
		["default"] = 100
	}
}

hook.Add("TFAVOX_InitializePlayer","TFAVOX_PainIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl and mdtbl.damage then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['damage'] = TFAVOX_FullCopy( mdtbl.damage )

		end
	end

end)

hook.Add("ScalePlayerDamage","TFAVOX_LocationalDamage",function(ply, hitgroup, dmginfo)

	if math.random(1,100)<= ( self.options["chance"].value or self.options["chance"].default ) then
		if SERVER and TFAVOX_IsValid(ply) and ply.TFAVOX_Sounds and ply:Alive() then

			local sndtbl = ply.TFAVOX_Sounds['damage']

			if sndtbl then
				TFAVOX_PlayVoicePriority( ply, sndtbl[hitgroup or HITGROUP_GENERIC], 4 )
			end

		end
	end

end)

hook.Add("EntityTakeDamage","TFAVOX_EntityTakeDamage",function(ply, dmginfo)

	if math.random(1,100)<= ( self.options["chance"].value or self.options["chance"].default ) then
		if SERVER then
			timer.Simple(0,function()

				if !IsValid(ply) or !ply.IsPlayer or !ply:IsPlayer() or !ply.TFAVOX_Sounds then return end
				if !ply:Alive() then return end

				local sndtbl = ply.TFAVOX_Sounds['damage']

				if sndtbl then
					TFAVOX_PlayVoicePriority( ply, sndtbl[HITGROUP_GENERIC], 4 )
				end

			end)
		end
	end

end)
