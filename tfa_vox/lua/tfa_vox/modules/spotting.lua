if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Spotting"
MODULE.description = "Allows the player to spot NPCs and other players using e, increasing damage for a period."
MODULE.author = "Bull and TFA"
MODULE.realm = "shared"
MODULE.options = {
	['player_en'] = {
		["name"] = "Player Spotting Enabled",
		["description"] = "Allow spotting players?",
		["type"] = "bool",
		["default"] = true
	},
	['npc_en'] = {
		["name"] = "NPC Spotting Enabled",
		["description"] = "Allow spotting NPCs?",
		["type"] = "bool",
		["default"] = true
	},
	["player_mult"] = {
		["name"] = "Player Damage Multiplier",
		["description"] = "Damage multiplier when a player is spotted.",
		["type"] = "integer",
		["min"] = 100,
		["max"] = 300,
		["default"] = 125
	},
	["npc_mult"] = {
		["name"] = "NPC Damage Multiplier",
		["description"] = "Damage multiplier when a NPC is spotted.",
		["type"] = "integer",
		["min"] = 100,
		["max"] = 300,
		["default"] = 150
	}
}

local SpottingTime = 5
local Color = Color(255,0,0,255)

local DamageEnabledNPC = true
local DamageEnabledPlayer = true

local DamageMulPlayer = 1.25
local DamageMulNPC = 2

local TFAVOX_NPCTypes = {
	--combine
	["npc_combinedropship"] = "combine",
	["npc_combine_s"] = "combine",
	["npc_combinegunship"] = "combine",
	["npc_cremato2"] = "combine",
	["npc_cremator"] = "combine",
	["npc_hunter"] = "combine",
	["npc_helicopter"] = "combine",
	["npc_rollermine"] = "combine",
	["npc_manhack"] = "manhack",
	-- metropolice
	["npc_metropolice"] = "cp",
	["npc_vehicledriver"] = "cp",
	-- scanner
	["npc_cscanner"] = "scanner",
	["npc_clawscanner"] = "scanner",
	["npc_stalker"] = "scanner",
	["npc_strider"] = "scanner",
	-- turret
	["npc_turret_ceiling"] = "turret",
	["npc_turret_floor"] = "turret",
	-- sniper
	["npc_sniper"] = "sniper",
	["proto_sniper"] = "sniper",
	-- allies (CLASS_PLAYER_ALLY)
	["npc_citizen"] = "ally",
	["monster_barney"] = "ally",
	["npc_magnusson"] = "ally",
	["npc_gman"] = "ally",
	["npc_fisherman"] = "ally",
	["npc_eli"] = "ally",
	["npc_barney"] = "ally",
	["npc_kleiner"] = "ally",
	["npc_mossman"] = "ally",
	["npc_alyx"] = "ally",
	["npc_monk"] = "ally",
	["npc_dog"] = "ally",
	--zombies
	["npc_headcrab_fast"] = "headcrab",
	["npc_headcrab_poison"] = "headcrab",
	["npc_headcrab"] = "headcrab",
	["npc_fastzombie"] = "zombie",
	["npc_poisonzombie"] = "zombie",
	["npc_zombie"] = "zombie",
	["npc_fastzombie_torso"] = "zombie",
	["npc_zombie_torso"] = "zombie",
	["npc_zombine"] = "zombie",
	-- antlions (CLASS_ANTLION)
	["npc_antlion"] = "antlion",
	["npc_antlionguard"] = "antlion",
	["npc_ichthyosaur"] = "antlion",
	-- barnacle (CLASS_BARNACLE)
	["npc_barnacle"] = "barnacle",
}

hook.Add("OnNPCKilled","TFAVOX_NetworkNPCDeath",function(npc,attacker,inflictor)
	if IsValid(npc) then npc:SetNWBool("dead",true) end
end)

hook.Add("TFAVOX_InitializePlayer","TFAVOX_TauntIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl and mdtbl.spot then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['spot'] = TFAVOX_FullCopy( mdtbl.spot )

		end
	end

end)


if SERVER then

	local ServerSpotCur
	local TFAVOX_IsNPC = TFAVOX_IsNPC

	util.AddNetworkString("TFAVOX_Spotted")

	hook.Add( "KeyPress", "VOX_Spotting", function( ply, key )

		if !ply:Alive() then return end

		if ( key == IN_USE ) then
			local ent

			if ( ply.GetEyeTrace ) then
				local et = ply:GetEyeTrace()
				if et then
					ent = et.Entity
				end
			end

			if ( IsValid(ent) and (ent:IsPlayer() or TFAVOX_IsNPC(ent) ) ) then

				if ent:IsPlayer() and !( ( self.options["player_en"].value ) or (  self.options["player_en"].value == nil and  self.options["player_en"].default ) ) then return end
				if TFAVOX_IsNPC(ent) and !( ( self.options["npc_en"].value ) or (  self.options["npc_en"].value == nil and  self.options["npc_en"].default ) ) then return end

				if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.spot then
					local spottbl = ply.TFAVOX_Sounds.spot
					local generictbl = spottbl["generic"]

					local class = ent:GetClass()

					-- if entity is NPC:
					-- 1. look up by classname
					-- 2. fallback to simplified category name if classname key not present
					-- 3. fallback to "generic" if both fails
					local sndtbl = TFAVOX_IsNPC(ent) and (spottbl[class] or spottbl[TFAVOX_NPCTypes[class] or "generic"] or generictbl) or generictbl

					if !sndtbl or !sndtbl.sound then
						sndtbl = generictbl
					end

					if sndtbl then
						TFAVOX_PlayVoicePriority( ply, sndtbl, 1 )
					end

				end

				ServerSpotCur = CurTime()+SpottingTime
				net.Start("TFAVOX_Spotted")
				net.WriteEntity(ent)
				net.Send(ply)
			end

		end

	end )

	hook.Add("ScaleNPCDamage","VOX_Spotting",function( ply, hitgroup, dmginfo )
		if ( (CurTime()<( ServerSpotCur or CurTime() )) ) then
			dmginfo:ScaleDamage( ( self.options["npc_mult"].value or self.options["npc_mult"].default ) / 100 )
		end
	end)

	hook.Add("ScalePlayerDamage","VOX_Spotting",function( npc, hitgroup, dmginfo )
		if ( (CurTime()<( ServerSpotCur or CurTime() )) )  then
			dmginfo:ScaleDamage( ( self.options["player_mult"].value or self.options["player_mult"].default ) / 100 )
		end
	end)

end

if CLIENT then

	local SpottedEntity
	local ClientSpotCur

	net.Receive('TFAVOX_Spotted',function()
		local ent = net.ReadEntity()

		if IsValid(ent) then

			ClientSpotCur= CurTime()+SpottingTime
			SpottedEntity = ent

		end

	end)


	hook.Add("PreDrawHalos","VOX_Spotting",function()

		local ct = CurTime()

		if( ct >= ( ClientSpotCur or ct ) ) then
			SpottedEntity = nil
		else
			if IsValid(SpottedEntity) and ( !SpottedEntity.Alive or SpottedEntity:Alive() ) and ( !SpottedEntity.Health or SpottedEntity:Health()>0 ) and !SpottedEntity:GetNWBool("dead",false) then
				halo.Add({SpottedEntity},ColorAlpha(Color,Color.a*( ClientSpotCur - ct )/SpottingTime ))
			end
		end

	end)
end
