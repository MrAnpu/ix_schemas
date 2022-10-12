if SERVER then

	--Autoreload Support

	for k,v in pairs( player.GetAll() ) do
		if IsValid(v) then TFAVOX_Init(v,true,true) end
	end

	--Tick

	hook.Add("Tick","TFAVOX_TickMain",function()

		local pltbl = player.GetAll()
		for k, ply in pairs(pltbl) do
			local mdl = ply:GetModel()

			local pm_cv = ply:GetInfo("cl_playermodel")
			ply.TFAVOX_PM_CVOld = ply.TFAVOX_PM_CVOld or pm_cv

			if ply:Alive() then
				ply.TFAVOX_Old_Model = ply.TFAVOX_Old_Model or mdl
				if mdl!=ply.TFAVOX_Old_Model then
					TFAVOX_Init(ply,true,true)
				end
				ply.TFAVOX_Old_Model = mdl
				ply.ChangedModelTime = 0.2
			end

			if TFAVOX_IsValid(ply) then

				TFAVOX_Init(ply)

			end
		end

	end)

	--Spawn

	hook.Add("PlayerSpawn","aTFAVOX_SpawnDelayer",function( ply )
		ply.TFAVOX_Spawn_Last = CurTime()
		if IsValid(ply) then
			TFAVOX_ResetNexts( ply )
			ply.TFAVOX_Sounds_Next["heal"] = CurTime()+0.25
			ply.TFAVOX_HasBeenSpawnProtected = true
		end
	end)

end
