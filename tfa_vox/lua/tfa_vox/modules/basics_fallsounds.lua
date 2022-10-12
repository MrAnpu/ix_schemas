if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Fall Sounds"
MODULE.description = "Plays a sound when a player falls"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = {
	["triggertime"] = {
		["name"] = "Trigger Time",
		["description"] = "Minimum falling time to play a sound",
		["type"] = "float",
		["min"] = 0,
		["max"] = 1,
		["default"] = 0.1
	},
	["fallingvel"] = {
		["name"] = "Fall Velocity",
		["description"] = "Minimum falling velocity to play a sound",
		["type"] = "int",
		["min"] = 0,
		["max"] = 1000,
		["default"] = 100
	},
	["fallingdistance"] = {
		["name"] = "Fall Distance",
		["description"] = "Minimum distance beneath the player to play a sound",
		["type"] = "int",
		["min"] = 0,
		["max"] = 1000,
		["default"] = 220
	}

}

local TFAVOX_FallingTime_Default = 0.1
local TFAVOX_FallingVel_Default = 250

hook.Add("TFAVOX_InitializePlayer","TFAVOX_FallIP",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}

			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].fall = mdtbl.main.fall
			end

		end
	end

end)

local dvec = Vector()

hook.Add("PlayerTick","TFAVOX_FallPT",function( ply )

	local trigvel,trigtime
	trigvel = TFAVOX_FallingVel_Default
	trigtime = TFAVOX_FallingTime_Default

	if self and self.options then
		if self.options.fallingvel and self.options.fallingvel.value then
			trigvel = self.options.fallingvel.value
		end
		if self.options.triggertime and self.options.triggertime.value then
			trigtime = self.options.triggertime.value
		end
		if self.options.fallingdistance and self.options.fallingdistance.value then
			dvec.z = self.options.fallingdistance.value * -1
		end
	end

	if SERVER and IsValid(ply) and ply.TFAVOX_Sounds then
		ply.TFAVOX_Sounds_Next["fall"] = ply.TFAVOX_Sounds_Next["fall"] or -1
		local vel = ply:GetVelocity()
		if ply:Alive() and !ply:OnGround() and !ply:InVehicle() and ply:WaterLevel() <=0 and ply:GetMoveType()!=MOVETYPE_NOCLIP and ( -vel.z>trigvel or vel:Length()>ply:GetRunSpeed()*1.75 ) then
			if not util.QuickTrace(ply:GetPos(),dvec,ply).Hit then
				ply.TFAVOX_Sounds_Next["fall"] = ply.TFAVOX_Sounds_Next["fall"] or -1
				ply.TFAVOX_FallingStart = ply.TFAVOX_FallingStart or CurTime()
				if CurTime()>ply.TFAVOX_FallingStart+trigtime then
					local sndtbl = ply.TFAVOX_Sounds['main']

					if sndtbl then
						TFAVOX_PlayVoicePriority( ply, sndtbl.fall, 3 )
					end
				end
			end
		else

			if ply.TFAVOX_FallingStart and CurTime()<( ply.TFAVOX_NextPriorityVoiceCall or CurTime() ) then
				TFAVOX_StopTableKey( ply, ply.TFAVOX_Sounds['main'], "fall" )
				ply.TFAVOX_Sounds_Next["fall"] = -1
				if ply.TFAVOX_PriorityVoiceCall and ply.TFAVOX_PriorityVoiceCall==3 then
					ply.TFAVOX_NextPriorityVoiceCall = -1
				end
			end
			ply.TFAVOX_FallingStart = nil
		end
	end

end)
