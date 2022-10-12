if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Weapon Pickup Sounds"
MODULE.description = "Plays a sound when a player grabs a gun"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = {
	["newpickups"] = {
		["name"] = "Only Vocalise New Guns",
		["description"] = "Does the player only speak when getting a new gun?",
		["type"] = "bool",
		["default"] = true
	}
}

hook.Add("TFAVOX_InitializePlayer","TFAVOX_WeaponGrabIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}

			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].pickup = mdtbl.main.pickup
			end

		end
	end

end)

local this = MODULE

hook.Add( "PlayerCanPickupWeapon", "TFAVOX_PickUp", function( ply, ent, haschecked )

	if haschecked then return end

	local cpick = hook.Call("PlayerCanPickupWeapon",GM,ply or Entity(1),ent or Entity(1),true)
	if cpick == false then return end

	if IsValid(ent) and TFAVOX_IsValid(ply) then

		local cl = ent:GetClass()

		if this.options.newpickups.value  == nil then this.options.newpickups.value  = this.options.newpickups.default end

		if CurTime()>( ply.TFAVOX_Spawn_Last or -1)+1 and ( ( ent:IsWeapon() and !ply:HasWeapon(cl) ) or !this.options.newpickups.value ) then
			if ply.TFAVOX_Sounds then

				local sndtbl = ply.TFAVOX_Sounds['main']

				if sndtbl and sndtbl.pickup then

					timer.Simple(0,function()
						if IsValid(ply) and ply:HasWeapon(cl) then
							TFAVOX_PlayVoicePriority( ply, sndtbl.pickup, 0 )
						end
					end)
					
				end

			end
		end

	end
end)
