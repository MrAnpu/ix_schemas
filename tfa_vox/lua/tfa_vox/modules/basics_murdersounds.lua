if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Murder Sounds"
MODULE.description = "Plays a sound when a player murders"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = {
	["chance"] = {
		["name"] = "Sound Chance",
		["description"] = "X% chance to play a murder sound",
		["type"] = "integer",
		["min"] = 0,
		["max"] = 100,
		["default"] = 20
	},
	["doplayers"] = {
		["name"] = "Player on Player Kills",
		["description"] = "Do sounds play when a player murders another player?",
		["type"] = "bool",
		["default"] = true
	},
	["donpcs"] = {
		["name"] = "Player on NPC Kills",
		["description"] = "Do sounds play when a player murders a NPC?",
		["type"] = "bool",
		["default"] = true
	},
	["psuedorandom"] = {
		["name"] = "Psuedorandom",
		["description"] = "Be more random-seeming than true random?",
		["type"] = "bool",
		["default"] = true
	}
}

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

local self = MODULE
local non_callout_deaths = 0
local TFAVOX_IsNPC = TFAVOX_IsNPC

function MODULE:GetSoundForced()
	if !self:GetOption("psuedorandom") then return end
	if non_callout_deaths > ( 100/self:GetOption("chance") - 1 ) then return true end
	if non_callout_deaths < -( 100/self:GetOption("chance") - 1 ) then return false end
end

hook.Add("TFAVOX_InitializePlayer","TFAVOX_MurderIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl and mdtbl.murder then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['murder'] = TFAVOX_FullCopy( mdtbl.murder )

		end
	end

end)

function TFAVOX_MurderCheck( target, attacker)
	if IsValid(attacker) and attacker.IsPlayer and attacker:IsPlayer() and attacker.TFAVOX_Sounds and attacker.TFAVOX_Sounds['murder'] then
		local ply = attacker
		if TFAVOX_IsValid(ply) and ply:Alive() then
			if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.murder then

				local murdtbl = ply.TFAVOX_Sounds.murder
				local generictbl = murdtbl["generic"]

				local class = target:GetClass()

				-- if entity is NPC:
				-- 1. look up by classname
				-- 2. fallback to simplified category name if classname key not present
				-- 3. fallback to "generic" if both fails
				local sndtbl = TFAVOX_IsNPC(target) and (murdtbl[class] or murdtbl[TFAVOX_NPCTypes[class] or "generic"] or generictbl) or generictbl

				local sndinner = TFAVOX_GetSoundTableSound(sndtbl)

				if !sndinner then
					sndtbl = generictbl
				end

				if sndtbl then
					TFAVOX_PlayVoicePriority( ply, sndtbl, 0 )
				end

			end
		end
	end
end

--local killsoundchancecvar

hook.Add("OnNPCKilled","TFAVOX_NPC_Murder",function(npc,attacker,inflictor)

	--if !killsoundchancecvar then killsoundchancecvar = GetConVar("sv_tfa_vox_killsound_chance") end

	--if math.random(1,100)<=killsoundchancecvar:GetInt() then

	if !self:GetOption("donpcs") then
		return
	end

	if !IsValid(attacker) then return end

	local dosnd = self:GetSoundForced()
	if dosnd == nil then dosnd = ( math.random(1,100)  <= self:GetOption("chance") ) end

	if ( dosnd ) then

		if attacker:IsWeapon() and IsValid(attacker.Owner) then attacker = attacker.Owner end

		TFAVOX_MurderCheck(npc,attacker)

		non_callout_deaths = math.min(0,non_callout_deaths-1)

	else

		non_callout_deaths = math.max(0,non_callout_deaths+1)

	end

	--end
end)

hook.Add("DoPlayerDeath","TFAVOX_PLY_Murder",function(victim,attacker,dmginfo)

	--if !killsoundchancecvar then killsoundchancecvar = GetConVar("sv_tfa_vox_killsound_chance") end

	if !self:GetOption("doplayers") then
		return
	end

	if !IsValid(attacker) then return end

	local dosnd = self:GetSoundForced()
	if dosnd == nil then dosnd = ( math.random(1,100)  <= self:GetOption("chance") ) end

	if ( dosnd ) then
		if attacker==victim then return end
		if attacker:IsWeapon() and IsValid(attacker.Owner) then attacker = attacker.Owner end

		TFAVOX_MurderCheck(victim,attacker)

		non_callout_deaths = math.min(0,non_callout_deaths-1)

	else

		non_callout_deaths = math.max(0,non_callout_deaths+1)

	end
end)
