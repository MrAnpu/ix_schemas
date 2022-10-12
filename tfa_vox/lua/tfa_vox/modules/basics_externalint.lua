if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - External Integration"
MODULE.description = "Allows external mods to call VOX"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.options = { }

function MODULE:GetEnabled()

	if self.active == nil then
		if self.activedefault == nil then return true end
		return self.activedefault
	end

	return self.active
end

--[[
	['external'] = {
		['custom'] = {
			['sound'] = TFAVOX_GenerateSound( "TheModel", "CustomSound", {
				"vo/modelpath/customsnd.wav"
			} )
		}
	}

	ply:Vox( "custom", 4, true )
]]

hook.Add("TFAVOX_InitializePlayer","TFAVOX_External",function(ply)

	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			ply.TFAVOX_Sounds['external'] = ply.TFAVOX_Sounds['external'] or {}

			if mdtbl.external then
				ply.TFAVOX_Sounds['external'] = TFAVOX_FullCopy( mdtbl.external )
			end

		end
	end

end)

local meta = FindMetaTable("Player")

if meta then

	function meta:Vox( id, priority, interrupt )
		if !TFAVOX_Modules["basics_externalint"]:GetEnabled() then return end
		if SERVER and self.TFAVOX_Sounds then
			local sndtbl = self.TFAVOX_Sounds['external']
			if sndtbl and sndtbl[id] then
				TFAVOX_PlayVoicePriority( self, sndtbl[id], priority, interrupt )
			end
		end
	end
end
