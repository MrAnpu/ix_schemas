TFAVOX_PACKS_PATH = "tfa_vox/packs/"
TFAVOX_Models = TFAVOX_Models or {}

local function FormatVar( var )
	return isstring(var) and ( "'" .. var .. "'" ) or tostring(var)
end

local function Indent( num )
	local retstr = ""
	for i = 1, (num or 0) do
		retstr = retstr .. "\t"
	end
	return retstr
end

function TableGetLuaString(tbl,indt)

	local indentlevel = indt or 0
	local retstr = ""

	local i=1
	local cnt = table.Count(tbl)

	for k,v in pairs(tbl) do
		if istable(v) then
			retstr = retstr .. Indent( indentlevel ) .. "[" .. FormatVar( k ) .. "] = {" .. "\n"
			retstr = retstr .. TableGetLuaString( v, indentlevel + 1 )
			retstr = retstr .. Indent( indentlevel ) .. "}" .. ( ( i != cnt ) and "," or "" ) .. "\n"
		else
			retstr = retstr .. Indent( indentlevel ) .. "[" .. FormatVar( k ) .. "] = " .. FormatVar( v ) .. ( ( i != cnt ) and "," or "" ) .. "\n"
		end
		i=i+1
	end

	return retstr
end

concommand.Add("tfa_vox_pack_export",
function(ply,cmd,args,argStr)
	if SERVER and ply:IsAdmin() then
		local str = ""
		str = str .. "--Written by TFA's Exporter" .. "\n"
		str = str .. "--Place in lua\\tfa_vox\\packs\\" .. "\n"
		str = str .. "TFAVOX_Models = TFAVOX_Models or {}" .. "\n"
		str = str .. "TFAVOX_Models[\"" .. ply:GetModel() .. "\"] = {" .. "\n"

		str = str .. TableGetLuaString( ply.TFAVOX_Sounds or {}, 1 )

		str = str .. "}"

		if !file.Exists("tfa_vox/","DATA") then
			file.CreateDir("tfa_vox/")
		end
		if !file.Exists("tfa_vox/exports/","DATA") then
			file.CreateDir("tfa_vox/exports/")
		end

		local f = file.Open( "tfa_vox/exports/" .. player_manager.TranslateToPlayerModelName( ply:GetModel() ) .. ".txt", "w", "DATA" )
		f:Write(str)
		f:Flush()
		f:Close()
	end
end,
function(cmd,args)

end,
"Dumps current loaded sounds into a pack file, located in /data/ with your character's playermodel name as the file name." )
function TFAVOX_Packs_Initialize()
	local files, folders = file.Find(TFAVOX_PACKS_PATH.."*","LUA")
	for k, v in pairs(files) do

		if SERVER then
			include(TFAVOX_PACKS_PATH..v)
			AddCSLuaFile(TFAVOX_PACKS_PATH..v)
		elseif CLIENT then
			include(TFAVOX_PACKS_PATH..v)
		end

	end

	--if CLIENT then PrintTable(TFAVOX_Models) end

end

function TFAVOX_PrecachePacks()
	TFAVOX_Models = TFAVOX_Models or {}

	for k,v in pairs(TFAVOX_Models) do

		for tblid,tbl in pairs(v) do

			for sndid,sndtbl in pairs(tbl) do

				if sndtbl.sound and sndtbl.sound != "" then

					if isstring(sndtbl.sound) then
						util.PrecacheSound( sndtbl.sound )
						local prop = sound.GetProperties( sndtbl.sound )
						if prop and prop.sound then

							if istable(prop.sound) then
								for _, wav in pairs(prop.sound) do
									util.PrecacheSound( wav )
								end
							elseif isstring(prop.sound) then
								util.PrecacheSound( prop.sound )
							end

						end
					else
						for k, v in pairs(sndtbl.sound) do
							util.PrecacheSound( v )
							local prop = sound.GetProperties( v )
							if prop and prop.sound then

								if istable(prop.sound) then
									for _, wav in pairs(prop.sound) do
										util.PrecacheSound( wav )
									end
								elseif isstring(prop.sound) then
									util.PrecacheSound( prop.sound )
								end

							end
						end
					end
				end

			end

		end

	end

end

TFAVOX_Packs_Initialize()
TFAVOX_PrecachePacks()

concommand.Add("tfa_vox_pack_reload",
function(ply,cmd,args,argStr)
	if SERVER and ply:IsAdmin() then
		TFAVOX_Packs_Initialize()
		TFAVOX_PrecachePacks()
		for k,v in pairs( player.GetAll() ) do
			print("Resetting the VOX of " .. v:Nick() )
			if IsValid(v) then TFAVOX_Init(v,true,true) end
		end
	end
end,
function(cmd,args)

end,
"Forecfully reload all vox packs." )

hook.Add("InitPostEntity","TFAVOX_PrecachePacks",TFAVOX_PrecachePacks)
hook.Add("InitPostEntity","TFAVOX_Packs_Initialize",TFAVOX_Packs_Initialize)
