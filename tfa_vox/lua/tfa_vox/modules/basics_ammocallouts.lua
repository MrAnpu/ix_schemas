if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Basics - Ammo Callouts"
MODULE.description = "Plays a sound when a player reloads or runs out of ammo"
MODULE.author = "TFA"
MODULE.realm = "shared"

MODULE.options = {
	["doreload"] = { 
		["name"] = "Vocalise Reloads?",
		["description"] = "Vocalise when a player reloads?",
		["type"] = "bool",
		["default"] = true
	},
	["donoammo"] = { 
		["name"] = "Vocalise No Ammo",
		["description"] = "Vocalise when a player attempts to shoot but can't?",
		["type"] = "bool",
		["default"] = true
	}
}
local TFAVOX_ClipOverrides = {
	["weapon_357"]=6,
	["weapon_ar2"]=30,
	["weapon_crossbow"]=1,
	["weapon_frag"]=1,
	["weapon_pistol"]=18,
	["weapon_rpg"]=1,
	["weapon_shotgun"]=6,
	["weapon_slam"]=1,
	["weapon_smg1"]=45
}

function MODULE:GetDoReload()
	return TFAVOX_GetModuleOption( self, "doreload", true )
end

function MODULE:GetDoNoAmmo()
	return TFAVOX_GetModuleOption( self, "donoammo", true )
end

hook.Add("TFAVOX_InitializePlayer","TFAVOX_AmmoIP",function(ply)
	
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then
			
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}
			
			ply.TFAVOX_Sounds['main'] = ply.TFAVOX_Sounds['main'] or {}
			
			if mdtbl.main then
				ply.TFAVOX_Sounds['main'].reload = mdtbl.main.reload
				ply.TFAVOX_Sounds['main'].noammo = mdtbl.main.noammo
			end
			
		end
	end
	
end)

hook.Add("PlayerTick","TFAVOX_AmmoPT",function( ply )
	
	if SERVER and IsValid(ply) and ply.TFAVOX_Sounds and ply:Alive() then
		
		ply.TFAVOX_Sounds_Next["main"] = ply.TFAVOX_Sounds_Next["main"] or -1
		
		--[[Reload Sounds]]--
		
		if ply:KeyPressed(IN_RELOAD) and self:GetDoReload() then
			local wep = ply:GetActiveWeapon()
			local am = -2
			local clip = -2
			
			if IsValid(wep) then
			
				if wep.Ammo1 then
					am = wep:Ammo1()
				end
				
				if wep.GetPrimaryAmmoType then
					local at = wep:GetPrimaryAmmoType()
					am = ply:GetAmmoCount(at)
				end
				
				am = math.Round(am or -1)
				
				if wep.Clip1 then
					clip = math.Round(wep:Clip1())
				end
				
				local ClipSZ = -1
				
				ClipSZ = TFAVOX_ClipOverrides[wep:GetClass()] or ClipSZ
				
				if wep.Primary and wep.Primary.ClipSize then
					ClipSZ =  wep.Primary.ClipSize
				end
				
				local targetclipsize = ClipSZ + 1
				
				if !( wep.DisableChambering == false ) and ( wep.Shotgun or wep.Revolver or wep.DisableChambering ) then targetclipsize = ClipSZ end
				
				if ( (  clip < targetclipsize ) and clip!=-2 and ClipSZ>0 ) and ( am > 0 ) then
					local sndtbl = ply.TFAVOX_Sounds['main'] 
					
					if sndtbl then
						TFAVOX_PlayVoicePriority( ply, sndtbl.reload, 0 )
					end					
				end
			
			end
			
		end
		
		--[[No Ammo Sounds]]--
		
		if ply:KeyPressed(IN_ATTACK) and self:GetDoNoAmmo() then
			local wep = ply:GetActiveWeapon()
			local am = -2
			local clip = -2
			
			if IsValid(wep) then
			
				if wep.Ammo1 then
					am = wep:Ammo1()
				end
				
				if wep.GetPrimaryAmmoType then
					local at = wep:GetPrimaryAmmoType()
					am = ply:GetAmmoCount(at)
					if (isnumber(at) and at<=0) or ( isstring(at) and (at=="" or string.lower(at)=="none") ) then
						am = -2
					end	
				end
				
				am = math.Round(am or -1)
				
				if wep.Clip1 then
					clip = math.Round(wep:Clip1())
				end
				
				local ClipSZ = -1
				
				ClipSZ = TFAVOX_ClipOverrides[wep:GetClass()] or ClipSZ
				
				if wep.Primary and wep.Primary.ClipSize then
					ClipSZ =  wep.Primary.ClipSize
				end
				
				if ( clip <=0 and clip!=-2 and ClipSZ>0 ) and ( am <= 0 and am!=-2 ) then
					local sndtbl = ply.TFAVOX_Sounds['main'] 
					
					if sndtbl then
						TFAVOX_PlayVoicePriority( ply, sndtbl.noammo, 0 )
					end				
				end
			
			end
			
		end

	end
	
end)

