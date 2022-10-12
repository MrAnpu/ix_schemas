--[[ Convenience Function ]]
--
TFAVOX_GeneratedSoundCount = 0
TFAVOX_GeneratedSoundSoftcap = math.pow(2, 16) - 8192
TFAVOX_GeneratedSoundHardcap = math.pow(2, 16) - 4096
local meta = FindMetaTable("Player")

if meta then
	local timid

	function meta:EmitSoundVOX(sndid)
		self.ESVOX_IsPlaying = self.ESVOX_IsPlaying or {}
		self.ESVOX_IsPlaying[sndid] = true
		timid = "VOX_" .. self:EntIndex() .. sndid

		if timer.Exists(timid) then
			timer.Remove(timid)
		end

		timer.Create(timid, SoundDuration(sndid), 1, function()
			self.ESVOX_IsPlaying[sndid] = false
		end)

		self:EmitSound(sndid)
	end

	function meta:StopSoundLite(sndid)
		self.ESVOX_IsPlaying = self.ESVOX_IsPlaying or {}
		if self.ESVOX_IsPlaying[sndid] then
			self.ESVOX_IsPlaying[sndid] = false
			self:StopSound(sndid)
		end
	end
end

function TFAVOX_GenerateSound(mdl, id, tbl)
	if TFAVOX_GeneratedSoundCount < TFAVOX_GeneratedSoundSoftcap then
		local ntbl = {}

		for k, v in pairs(tbl) do
			local n = string.upper("TFA_VOX." .. mdl .. "." .. id .. "." .. k)

			sound.Add({
				name = n,
				sound = v,
				channel = CHAN_VOICE,--game.SinglePlayer() and CHAN_VOICE or CHAN_STREAM,
				pitch = {97, 103},
				level = 65
			})

			ntbl[#ntbl + 1] = n
		end

		return ntbl
	else
		local n = string.upper("TFA_VOX." .. mdl .. "." .. id .. ".Sound")

		sound.Add({
			name = n,
			sound = tbl,
			channel = CHAN_VOICE,
			pitch = {97, 103},
			level = 65
		})

		return n
	end
end

function TFAVOX_IsNPC(ent) -- count nextbots as npcs
	if IsValid(ent) then
		return ent:IsNPC() or type(ent) == "NextBot"
	end

	return false
end

--[[ Main Block ]]
--
if SERVER then
	util.AddNetworkString("TFAVOX_PlayURL")

	net.Receive("TFAVOX_PlayURL", function(len, ply)
		if IsValid(ply) then
			ply.TFAVOX_NextPriorityVoiceCall = CurTime() + (net.ReadDouble() or 1)
		end
	end)

	TFAVOX_Models = TFAVOX_Models or {}
	ValidModelsTable = ValidModelsTable or {}
	TFAVOX_RSeed = 0

	function TFAVOX_IsValid(ply, debugv)
		if not IsValid(ply) then return false end
		local mdl = ply:GetModel()

		return (ply.HaveValidModel or ValidModelsTable[mdl] or TFAVOX_Models[mdl])
	end

	function TFAVOX_GetSoundTableSound(sndtbl, exact)
		if not sndtbl then return end
		local soundraw = sndtbl.sound
		if not soundraw then return end
		TFAVOX_RSeed = CurTime()
		math.randomseed(TFAVOX_RSeed)
		local soundproc = istable(soundraw) and (soundraw[math.random(1, #soundraw)]) or soundraw
		local soundprop = sound.GetProperties(soundproc)

		if exact and soundprop and soundprop.sound then
			local dubsnd = soundprop.sound

			if istable(dubsnd) then
				math.randomseed(TFAVOX_RSeed)

				return dubsnd[math.random(1, #dubsnd)]
			else
				return dubsnd
			end
		else
			return soundproc
		end
	end

	function TFAVOX_GetSoundTableDelay(sndtbl)
		local delayraw = sndtbl.delay

		if not delayraw then
			local snd = TFAVOX_GetSoundTableSound(sndtbl, true)

			return snd and SoundDuration(snd) or 1
		end

		local val = istable(delayraw) and math.Rand(delayraw[1], delayraw[2]) or (isnumber(delayraw) and delayraw or 1)

		if not isnumber(val) then
			val = 1
		end

		return val
	end

	function TFAVOX_StopAllExcept(ply, snd)
		if not ply.TFAVOX_Sounds then return end

		for k, v in pairs(ply.TFAVOX_Sounds) do
			TFAVOX_StopTable(ply, v, snd)
		end
	end

	TFAVOX_QUEUED_TICKSOUNDS = {}

	function TFAVOX_StopAllAndPlay(ply, snd)
		TFAVOX_StopAllExcept(ply, snd)
		--TFAVOX_QUEUED_TICKSOUNDS[ply] = TFAVOX_QUEUED_TICKSOUNDS[ply] or {}
		--table.insert( TFAVOX_QUEUED_TICKSOUNDS[ply], #TFAVOX_QUEUED_TICKSOUNDS[ply]+1, snd )
		TFAVOX_QUEUED_TICKSOUNDS[#TFAVOX_QUEUED_TICKSOUNDS + 1] = {ply, snd, 0}
		--timer.Simple(0.01,function()
		--	if IsValid(ply) then ply:EmitSoundVOX(snd) end
		--end)
	end

	hook.Add("Tick", "TFAVOX_PLAY_QUEUED_SOUNDS", function()
		--[[
		for k,v in pairs(TFAVOX_QUEUED_TICKSOUNDS) do
			if !IsValid(k) then
				table.RemoveByValue(TFAVOX_QUEUED_TICKSOUNDS,k)
			else
				for l,b in ipairs(v) do
					if b then
						v:EmitSoundVOX(b)
					end
				end
			end
		end
		]]
		--
		for k, v in ipairs(TFAVOX_QUEUED_TICKSOUNDS) do
			v[3] = (v[3] or 0) + 1

			if v[3] > 2 then
				math.randomseed(TFAVOX_RSeed)
				if IsValid(v[1]) then v[1]:EmitSoundVOX(v[2]) end
				table.remove(TFAVOX_QUEUED_TICKSOUNDS, k)
			end
		end
	end)

	function TFAVOX_StopAll(ply)
		if not IsValid(ply) or not ply.TFAVOX_Sounds then return end

		for k, v in pairs(ply.TFAVOX_Sounds) do
			TFAVOX_StopTable(ply, v, snd)
		end
	end

	function TFAVOX_StopTable(ply, tbl, ignoredkey)
		if not tbl then return end

		for k, v in pairs(tbl) do
			local snd = v.sound

			if snd then
				if istable(snd) then
					for l, b in pairs(snd) do
						if ignoredkey ~= b then
							ply:StopSoundLite(b)
						end
					end
				else
					if ignoredkey ~= snd then
						ply:StopSoundLite(snd)
					end
				end
			end
		end
	end

	function TFAVOX_StopTableKey(ply, tbl, key)
		if not tbl then return end
		local v = tbl[key]
		if not v then return end
		local snd = v.sound

		if snd then
			if istable(snd) then
				for l, b in pairs(snd) do
					ply:StopSoundLite(b)
				end
			else
				ply:StopSoundLite(snd)
			end
		end
	end

	function TFAVOX_PlayVoiceSafe(ply, sndtbl, soundid, resettype, delaycritsound)
		if not soundid or CurTime() > ply.TFAVOX_Sounds_Next[soundid] then
			local snd = TFAVOX_GetSoundTableSound(sndtbl)

			if snd then
				TFAVOX_StopAllAndPlay(ply, snd)

				if soundid then
					local critwait = ply.TFAVOX_Sounds_Next["crit"] or 0
					local del = CurTime() + TFAVOX_GetSoundTableDelay(sndtbl)

					if not resettype or resettype == 1 then
						for k, v in pairs(ply.TFAVOX_Sounds_Next) do
							ply.TFAVOX_Sounds_Next[k] = -1
						end
					elseif resettype == 2 then
						for k, v in pairs(ply.TFAVOX_Sounds_Next) do
							ply.TFAVOX_Sounds_Next[k] = del
						end
					end

					ply.TFAVOX_Sounds_Next[soundid] = CurTime() + TFAVOX_GetSoundTableDelay(sndtbl)

					if delaycritsound or delaycritsound == nil then
						ply.TFAVOX_Sounds_Next["crit"] = math.max(del, critwait)
					end
				end
			end
		end
	end

	function TFAVOX_FullCopy(outertable)
		local tbl = {}

		for k, v in pairs(outertable) do
			if istable(v) then
				tbl[k] = TFAVOX_FullCopy(v)
			else
				tbl[k] = v
			end
		end

		return tbl
	end

	function TFAVOX_PlayVoicePriority(ply, sndtbl, priority, command)
		if CurTime() > (ply.TFAVOX_NextPriorityVoiceCall or -1) or priority > (ply.TFAVOX_PriorityVoiceCall or 0) or (priority == (ply.TFAVOX_PriorityVoiceCall or 0) and command) then
			local snd = TFAVOX_GetSoundTableSound(sndtbl) --, true)

			if snd then
				if string.sub(snd, 1, 7) == "http://" then
					TFAVOX_StopAll(ply)
					ply.TFAVOX_PriorityVoiceCall = priority
					ply.TFAVOX_NextPriorityVoiceCall = CurTime() + 1
					net.Start("TFAVOX_PlayURL")
					net.WriteEntity(ply)
					net.WriteString(snd)
					net.Broadcast()
				else
					TFAVOX_StopAllAndPlay(ply, snd)
					local del = CurTime() + TFAVOX_GetSoundTableDelay(sndtbl)
					ply.TFAVOX_PriorityVoiceCall = priority
					ply.TFAVOX_NextPriorityVoiceCall = del
				end
			end
		end
	end

	function TFAVOX_ResetNexts(ply)
		TFAVOX_InitNexts(ply)

		for k, v in pairs(ply.TFAVOX_Sounds_Next) do
			ply.TFAVOX_Sounds_Next[k] = -1
		end
	end

	function TFAVOX_InitNexts(ply)
		if not ply.TFAVOX_Sounds_Next then
			ply.TFAVOX_Sounds_Next = {}
		end

		hook.Call("TFAVOX_InitializePlayerTimings", GM, ply, force, clean) --Expect this to be constantly called.  This makes sure the player is properly set up for TFAVOX.
	end

	local function TableFullCopy(outertable)
		local tbl = {}

		for k, v in pairs(outertable) do
			if istable(v) then
				tbl[k] = TableFullCopy(v)
			else
				tbl[k] = v
			end
		end

		return tbl
	end

	function TFAVOX_Init(ply, force, clean)
		TFAVOX_InitNexts(ply)

		if clean then
			if ply.TFAVOX_Sounds then
				for k, v in pairs(ply.TFAVOX_Sounds) do
					ply.TFAVOX_Sounds[k] = nil
				end
			end

			ply.TFAVOX_Sounds = nil
		end

		if not TFAVOX_IsValid(ply) or not ply.TFAVOX_Sounds then
			hook.Call("TFAVOX_InitializePlayer", GM, ply, force, clean)
			hook.Call("TFAVOX_InitializePlayerDone", GM, ply, force, clean)
		end

		if TFAVOX_IsValid(ply) and not ply.TFAVOX_Sounds then
			ply.HaveValidModel = false

			if ValidModelsTable then
				table.RemoveByValue(ValidModelsTable, ply:GetModel())
			end
		end
	end
end

if CLIENT then
	net.Receive("TFAVOX_PlayURL", function()
		local ent = net.ReadEntity()
		local url = net.ReadString()
		if not url then return end

		sound.PlayURL(url, "3d noblock", function(soundchannel, errorID, errorName)
			if IsValid(ent) and IsValid(soundchannel) then
				soundchannel:SetPos(ent:GetShootPos(), ent:GetAimVector())
				soundchannel:Set3DCone(120, 240, 0.75)
				soundchannel:Set3DFadeDistance(16 * 32, 16 * 300)
				soundchannel:SetVolume(1)
				local del = soundchannel:GetLength()

				if ent == LocalPlayer() then
					net.Start("TFAVOX_PlayURL")
					net.WriteDouble(del)
					net.SendToServer()
				end

				hook.Add("PreRender", url .. "update", function()
					if not IsValid(soundchannel) then
						hook.Remove("PreRender", url .. "update")
					end

					if not IsValid(ent) then
						soundchannel:Stop()

						if soundchannel.Remove then
							soundchannel:Remove()
						end
					end

					soundchannel:SetPos(ent:GetShootPos(), ent:GetAimVector())
				end)
			end
		end)
	end)
end