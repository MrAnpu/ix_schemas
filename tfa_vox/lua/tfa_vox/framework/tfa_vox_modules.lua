if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("TFAVOX_Module_Status")
	util.AddNetworkString("TFAVOX_Module_Option")
	util.AddNetworkString("tfa_vox_requestreset")

	local ranktable = {
		["somerank"] = true
	}

	function IsInRankTable(ply)
		if ranktable[ply:GetUserGroup()] then return true end return false
	end

	net.Receive("TFAVOX_Module_Status", function(len,ply)

		if ( !IsValid(ply) or  !ply:IsAdmin() ) and !IsInRankTable(ply) then return end

		local class = net.ReadString()
		local active = net.ReadBool()

		TFAVOX_Modules_SetStatus( class, active )
	end)

	net.Receive("TFAVOX_Module_Option", function(len,ply)

		if ( !IsValid(ply) or  !ply:IsAdmin() ) and !IsInRankTable(ply) then return end

		local class = net.ReadString()
		local option = net.ReadString()
		local valtbl = net.ReadTable()

		if valtbl then
			local val = valtbl[1]
			TFAVOX_Modules_SetOption( class, option, val )
		end
	end)

	net.Receive("tfa_vox_requestreset", function(len,ply)

		if ( !IsValid(ply) or  !ply:IsAdmin() ) and !IsInRankTable(ply) then return end

		for k,v in pairs(TFAVOX_Modules) do

			if v.options then
				for l,b in pairs(v.options) do
					TFAVOX_Modules_SetOption( v.class, l, b.default or b.value )
				end
			end

			if v.activedefault==nil or v.activedefault then

				TFAVOX_Modules_SetStatus( v.class, true )

			else

				TFAVOX_Modules_SetStatus( v.class, false )

			end
		end
	end)
end

if CLIENT then
	net.Receive("TFAVOX_Module_Option", function()
		local class = net.ReadString()
		local option = net.ReadString()
		local valtbl = net.ReadTable()

		if valtbl then
			local val = valtbl[1]
			TFAVOX_Modules_SetOption( class, option, val )
		end
	end)

	net.Receive("TFAVOX_Module_Status", function()
		local class = net.ReadString()
		local active = net.ReadBool()
		TFAVOX_Modules_SetStatus( class, active )
	end)

	function TFAVOX_Modules_RequestStatus( class, active )
		--TFAVOX_Modules[class] = TFAVOX_Modules[class] or {}
		--TFAVOX_Modules[class].active = active

		net.Start("TFAVOX_Module_Status")
		net.WriteString( class )
		net.WriteBool( active )
		net.SendToServer()

	end

	function TFAVOX_Modules_RequestModuleOption( mod, option, value )
		if !mod or !mod.options then return end
		local opttbl = mod.options[option]
		local val  = TFAVOX_Modules_SQL_ConvertDataFrom( value, opttbl.type )

		if CLIENT and mod and mod.class and val!=nil then
			net.Start("TFAVOX_Module_Option")
			net.WriteString( mod.class )
			net.WriteString( option )
			net.WriteTable( { val } )
			net.SendToServer()
		end

	end

end

concommand.Add("tfa_vox_module_set_active",function(ply,cmd,args,argStr)
	if ply.IsAdmin and ply:IsAdmin() then
		if args[1] and args[2] then
			local class = args[1]
			class = string.lower( isstring(class) and class or tostring(class) )
			class = string.Trim(class," ")

			local active = args[2]
			if isstring(active) then
				active = string.lower(active)
				active = string.Trim(active," ")
				if active=="true" or active=="1" then
					active = true
				else
					active = false
				end
			elseif isnumber(active) then
				active = (active>0.5) and true or false
			else
				active = active and true or false
			end

			TFAVOX_Modules_SetStatus( class, active )

		end
	end
end,
function( cmdAutocomplete, argsAutocomplete)
	local ret = {}

	argsAutocomplete = string.TrimLeft( argsAutocomplete ) -- Remove any spaces before or after.
	argsAutocomplete = string.lower( argsAutocomplete )

	local exp = string.Explode(" ",argsAutocomplete )
	local spacecount = math.min( #exp, string.len( string.Trim( argsAutocomplete ) ) )

	if spacecount==2 then
		if string.len(exp[2] or "") == 0 then
			table.insert(ret,cmdAutocomplete.." "..exp[1].." 1")
			table.insert(ret,cmdAutocomplete.." "..exp[1].." 0")
		end
	elseif exp[1] then
		for k,v in pairs(TFAVOX_Modules) do
			if string.find(v.class,exp[1]) then
				table.insert(ret,cmdAutocomplete.." "..v.class)
			end
		end
	elseif spacecount<3 then
		for k,v in pairs(TFAVOX_Modules) do
			if string.find(v.class,exp[1]) then
				table.insert(ret,"tfa_vox_setmodule".." "..v.class)
			end
		end
	end

	table.sort(ret,function(a,b)
		return tostring(a)<tostring(b)
	end)



	return ret
end,
"Enable/disable a TFA VOX module.  Use like tfa_vox_setmodule modulename 1/0",
FCVAR_SERVER_CAN_EXECUTE)

local TFAVOX_TypeSuggestions = {
	["int"] = "wholenumber",
	["integer"] = "wholenumber",
	["float"] = "number",
	["double"] = "number",
	["string"] = "word",
	["bool"] = "true/false",
	["boolean"] = "true/false",
	["vector"] = "vector",
	["color"] = "color"
}

concommand.Add("tfa_vox_module_set_option",function(ply,cmd,args,argStr)
	if ply.IsAdmin and ply:IsAdmin() then
		if args[1] and args[2] and args[3] then

			TFAVOX_Modules_SetOption( args[1], args[2], args[3] )

			hook.Call("TFAVOX_SQL_SaveMod",GM)

		end
	end
end,
function( cmdAutocomplete, argsAutocomplete)
	local ret = {}

	argsAutocomplete = string.TrimLeft( argsAutocomplete ) -- Remove any spaces before or after.
	argsAutocomplete = string.lower( argsAutocomplete )

	local exp = string.Explode(" ",argsAutocomplete )
	local spacecount = math.min( #exp, string.len( string.Trim( argsAutocomplete ) ) )

	if spacecount==3 then
		if string.len(exp[3] or "") == 0 then
			local tmptbl = TFAVOX_Modules[exp[1]]
			if tmptbl and tmptbl.options then
				local optbl = tmptbl.options[exp[2] or ""]
				if optbl then
					table.insert(ret,cmdAutocomplete.." "..exp[1].." "..exp[2].." "..TFAVOX_TypeSuggestions[optbl.type or "string"])
				end
			end
		end
	elseif exp[2] and (spacecount>0) then
		local tmptbl = TFAVOX_Modules[exp[1]]
		if tmptbl and tmptbl.options then
			for k,v in pairs(tmptbl.options ) do
				if string.find(k,exp[2]) then
					table.insert(ret,cmdAutocomplete.." "..exp[1].." "..k)
				end
			end
		end
	elseif exp[1] or spacecount==0 then
		for k,v in pairs(TFAVOX_Modules) do
			if string.find(v.class,exp[1] or "") then
				table.insert(ret,cmdAutocomplete.." "..v.class)
			end
		end
	end

	table.sort(ret,function(a,b)
		return tostring(a)<tostring(b)
	end)



	return ret
end,
"Set a TFA VOX Module Option.  Follow autocomplete.",
FCVAR_SERVER_CAN_EXECUTE)


concommand.Add("tfa_vox_module_reloadall",function(ply,cmd,args,argStr)
	if IsValid(ply) and ply:IsAdmin() then
		TFAVOX_Modules_Initialize()
	end
end, nil, "Reload all TFA VOX modules.",FCVAR_SERVER_CAN_EXECUTE)
TFAVOX_MODULE_PATH = "tfa_vox/modules/"

TFAVOX_MODULE_DEFAULT = {
	["class"] = "default",
	["realm"] = "shared",
	["name"] = "base module",
	["description"] = "does nothing",
	["author"] = "TFA",
	["hooks"] = {},
	["options"] = {}
}

MODULE = {}

TFAVOX_Modules = TFAVOX_Modules or {}

function TFAVOX_Modules_SetStatus( class, active, request )

	if SERVER then
		TFAVOX_Modules[class] = TFAVOX_Modules[class] or {}

		if active==nil then
			active = TFAVOX_Modules[class].activedefault
			if active==nil then active = true end
		end

		local haschanged = false

		if ( !TFAVOX_Modules[class].active and active ) or ( TFAVOX_Modules[class].active and !active ) then
			haschanged = true
		end

		TFAVOX_Modules[class].active = active

		if haschanged and TFAVOX_Modules[class].active and TFAVOX_Modules[class].OnEnable then TFAVOX_Modules[class].OnEnable(TFAVOX_Modules[class]) end

		if haschanged and !TFAVOX_Modules[class].active and TFAVOX_Modules[class].OnDisable then TFAVOX_Modules[class].OnDisable(TFAVOX_Modules[class]) end

		TFAVOX_NetworkActive( TFAVOX_Modules[class] )
		hook.Call("TFAVOX_SQL_SaveMod",GM, TFAVOX_Modules[class] )
	end

	if CLIENT then
		TFAVOX_Modules[class] = TFAVOX_Modules[class] or {}

		local haschanged = false

		if ( !TFAVOX_Modules[class].active and active ) or ( TFAVOX_Modules[class].active and !active ) then
			haschanged = true
		end

		if ( !TFAVOX_Modules[class].realm or ( TFAVOX_Modules[class].realm == "shared" or TFAVOX_Modules[class].realm == "server" ) ) and request then
			TFAVOX_Modules_RequestStatus( class, active )
		elseif ( TFAVOX_Modules[class].realm and TFAVOX_Modules[class].realm == "client" ) and request then
			TFAVOX_Modules[class].active = active
			hook.Call("TFAVOX_SQL_SaveMod",GM, TFAVOX_Modules[class] )
		elseif !request then
			TFAVOX_Modules[class].active = active
		end

		TFAVOX_Modules[class].active = active

		if haschanged and TFAVOX_Modules[class].active and TFAVOX_Modules[class].OnEnable then TFAVOX_Modules[class].OnEnable(TFAVOX_Modules[class]) end

		if haschanged and !TFAVOX_Modules[class].active and TFAVOX_Modules[class].OnDisable then TFAVOX_Modules[class].OnDisable(TFAVOX_Modules[class]) end
	end

end

function TFAVOX_FullCopy( outertable )
	local tbl = {}
	for k,v in pairs( outertable ) do
		if istable(v) then
			tbl[k] = TFAVOX_FullCopy(v)
		else
			tbl[k] = v
		end
	end
	return tbl
end

function TFAVOX_Modules_Register( input )
	local tbl = TFAVOX_FullCopy( input )
	local class = tbl.class
	TFAVOX_Modules[class] = tbl
	for k,v in pairs(TFAVOX_MODULE_DEFAULT) do
		if TFAVOX_Modules[class][k] == nil then
			TFAVOX_Modules[class][k] = v
		end
	end
end

local SQL_DataTypes = {
	["int"] = "integer",
	["integer"] = "integer",
	["float"] = "float",
	["double"] = "float",
	["string"] = "string",
	["bool"] = "boolean",
	["boolean"] = "boolean",
	["vector"] = "string",
	["color"] = "string"
}

function TFAVOX_Modules_SQL_ConvertDataFrom( value, typev )
	local output = value

	if typev == "string" then
		if !isstring(value) then
			output = tostring(value)
		else
			output = value
		end
	elseif typev == "int" or typev == "integer" then
		if !isnumber(value) then
			output = math.Round(tonumber(value) or 0)
		else
			output = math.Round(value)
		end
	elseif typev == "float" or typev == "double" then
		if !isnumber(value) then
			output = tonumber(value)
		else
			output = value
		end
	elseif typev == "bool" or typev == "boolean" then
		if !isbool(value) then
			output = tobool(value)
		else
			output = value
		end
	elseif typev == "color" then
		if istable(value) and !IsColor(value) then
			output = Color(value.r or 255,value.g or 255, value.b or 255, value.a or 255)
		elseif !IsColor(value) then
			local col = Color(255,255,255,255)
			local expstr = string.Explode(" ",string.Trim(value," ") )
			if expstr[1] then col.r= tonumber(expstr[1]) or 255 end
			if expstr[2] then col.g = tonumber(expstr[2]) or 255 end
			if expstr[3] then col.b = tonumber(expstr[3]) or 255 end
			if expstr[4] then col.a = tonumber(expstr[4]) or 255 end
			output = col
		else
			output = value
		end
	elseif typev == "vector" then
		if !isvector(value) then
			if isstring(value) then
				local vec = Vector()
				local expstr = string.Explode(" ",string.Trim(value," ") )
				if expstr[1] then vec.x = tonumber(expstr[1]) end
				if expstr[2] then vec.y = tonumber(expstr[2]) end
				if expstr[3] then vec.z = tonumber(expstr[3]) end
				output = vec
			else
				output = Vector()
			end
		else
			output = value
		end
	end

	return output
end

function TFAVOX_Modules_SQL_ConvertDataTo( value, typev )

	if isstring(typev) then
		typev = typev .. ""
	elseif isnumber(typev) then
		typev = typev * 1
	elseif isvector(typev) then
		typev = typev * 1
	elseif istable(typvev) then
		typev = table.Copy(typev)
	end

	local output = value

	if typev == "string" then
		if !isstring(value) then
			output = tostring(value)
		else
			output = value
		end
	elseif typev == "int" or typev == "integer" then
		if !isnumber(value) then
			output = math.Round(tonumber(value))
		else
			output = math.Round(value)
		end
	elseif typev == "float" or typev == "double" then
		if !isnumber(value) then
			output = tonumber(value)
		else
			output = value
		end
	elseif typev == "bool" or typev == "boolean" then

		if !isbool(value) then
			output = tobool(value)
		else
			output = value
		end

		output = output and 1 or 0

	elseif typev == "color" then
		if !isstring(value) then
			output = ""
			if value and value.r then
				output = output .. tostring(value.r) .. " "
			end
			if value and value.g then
				output = output .. tostring(value.g) .. " "
			end
			if value and value.b then
				output = output .. tostring(value.b) .. " "
			end
			if value and value.a then
				output = output .. tostring(value.a)
			end
		end
	elseif typev == "vector" then
		if !isstring(value) then
			output = ""
			if value and value.x then
				output = output .. tostring(value.x) .. " "
			end
			if value and value.y then
				output = output .. tostring(value.y) .. " "
			end
			if value and value.z then
				output = output .. tostring(value.z) .. " "
			end
		end
	end

	return isstring(output) and ( "'"..output.."'" ) or tostring(output)
end

function TFAVOX_Modules_SetOption( class, option, value, request )

	if !TFAVOX_Modules or !TFAVOX_Modules[class] or !TFAVOX_Modules[class].options then return end

	TFAVOX_Modules_SetModuleOption( TFAVOX_Modules[class], option, value, request )

end

function TFAVOX_Modules_SetModuleOption( mod, option, value, request )

	if !mod or !mod.options then return end
	local opttbl = mod.options[option]
	if !opttbl then return end

	if SERVER then
		TFAVOX_Modules[mod.class].options[option].value = TFAVOX_Modules_SQL_ConvertDataFrom( value, opttbl.type )
		TFAVOX_NetworkOption( mod, option )
		hook.Call("TFAVOX_SQL_SaveModOptions",GM, mod )
	end

	if CLIENT then
		if ( !mod.realm or ( mod.realm == "shared" or mod.realm == "server" ) ) and request then
			TFAVOX_Modules_RequestModuleOption( mod, option, value )
		elseif mod.realm and ( mod.realm == "client" ) and request then
			mod.options[option].value = TFAVOX_Modules_SQL_ConvertDataFrom( value, opttbl.type )
			TFAVOX_Modules[mod.class] = mod
			hook.Call("TFAVOX_SQL_SaveModOptions",GM, mod )
			--TFAVOX_Modules_SQL_Save_Options( mod.class )
		elseif !request then
			mod.options[option].value = TFAVOX_Modules_SQL_ConvertDataFrom( value, opttbl.type )
			TFAVOX_Modules[mod.class] = mod
		end
	end

end

function TFAVOX_Modules_SQL_GetModuleOptionsString( mod )
	if !mod or !mod.options then return "" end
	local query = ""
	local keys = table.GetKeys( mod.options )

	table.sort(keys,function(a,b)
		return tostring(a)<tostring(b)
	end)

	for _,k in ipairs(keys) do
		local v = mod.options[k]
		query = query .. k .. " " .. ( SQL_DataTypes[ v.type ] or v.type ) .. ", "
	end
	query = string.TrimRight(query," ")
	query = string.TrimRight(query,",")

	return query
end

function TFAVOX_NetworkActive( mod, ply )

	if !mod or ( mod.IsPlayer and mod:IsPlayer() ) then

		for k,v in pairs(TFAVOX_Modules) do
			TFAVOX_NetworkActive(v,ply or mod)
		end

		return
	end

	if mod.realm != "client" then
		timer.Simple(0,function()
			net.Start("TFAVOX_Module_Status")
			net.WriteString( mod.class )
			net.WriteBool( mod.active )
			if IsValid(ply) then net.Send(ply) else net.Broadcast() end
		end)
	end

end

function TFAVOX_NetworkOption( mod, option, ply )

	if !mod or ( mod.IsPlayer and mod:IsPlayer() ) then

		for k,v in pairs(TFAVOX_Modules) do
			TFAVOX_NetworkOption(v,mod)
		end

		return
	end

	if !option or ( !isstring(option) and option.IsPlayer and option:IsPlayer() ) then

		for k,v in pairs(mod.options) do
			if option and !isstring(option) then ply = option end
			TFAVOX_NetworkOption(mod,k, ply)
		end

		return
	end

	if !mod.realm or mod.realm == "shared" then
		net.Start("TFAVOX_Module_Option")
		net.WriteString( mod.class )
		net.WriteString( option )
		net.WriteTable( { mod.options[option].value } )

		if IsValid(ply) then net.Send(ply) else net.Broadcast() end
	end

end

function TFAVOX_Modules_Initialize()
	local _G = _G

	local _ENV = {
		self = {},
		hook = {
			Add = function(hookname, id, callback)
				local class = MODULE.class

				hook.Add(hookname, id, function(...)
					local _module = TFAVOX_Modules[class]
					if not _module.active then return end

					if not _module.__env then
						_module.__env = { self = {} }

						setmetatable(_module.__env, {
							__index = _G,
							__newindex = function(self, k, v)
								_G[k] = v
							end
						})

						setmetatable(_module.__env.self, {__index = _module})
					end

					setfenv(callback, _module.__env)

					local A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z = callback(...)

					if A ~= nil then
						return A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
					end
				end)
			end
		}
	}

	setmetatable(_ENV.hook, {
		__index = _G.hook,
		__newindex = function(self, k, v)
			_G.hook[k] = v
		end
	})

	setmetatable(_ENV, {
		__index = _G,
		__newindex = function(self, k, v)
			_G[k] = v
		end
	})

	local files, _ = file.Find(TFAVOX_MODULE_PATH .. "*","LUA")

	for _, fileName in ipairs(files) do
		local classn = string.Replace(fileName:lower(), ".lua", "")
		MODULE = {}--table.Copy(TFAVOX_MODULE_DEFAULT)

		MODULE.class = classn

		function MODULE:GetOption(opt, fallback)
			return TFAVOX_GetModuleOption(self, opt, fallback)
		end

		setmetatable(_ENV.self, {
			__index = MODULE,
			__newindex = function(self, k, v)
				MODULE[k] = v
			end
		})

		local module = CompileFile(TFAVOX_MODULE_PATH .. fileName)
		setfenv(module, _ENV)
		ProtectedCall(module)

		if SERVER then
			AddCSLuaFile(TFAVOX_MODULE_PATH .. fileName)
		end

		MODULE.class = classn

		TFAVOX_Modules_Register(MODULE)
	end

	MODULE = nil

	for k,mod in pairs(TFAVOX_Modules) do

		if mod.options then
			for l,b in pairs( mod.options ) do
				if b.value == nil then b.value = b.default end
			end
		end

		if SERVER then
			if mod.active==nil then
				mod.active = ( mod.activedefault == nil ) and true or mod.activedefault
			end
			TFAVOX_NetworkActive( mod )
		end

	end

	timer.Simple(0,function()

		for k,mod in pairs(TFAVOX_Modules) do

			hook.Call("TFAVOX_SQL_LoadMod",GM, mod )
			hook.Call("TFAVOX_SQL_LoadModOptions",GM, mod )

		end

	end)

end

TFAVOX_Modules_Initialize()


hook.Add("PlayerSpawn","TFA_VOX_Modules_Spawn",function(ply)

	timer.Simple(0,function()
		if SERVER then
			if IsValid(ply) and !ply.HasBeenVoxModulesNetworked then
				ply.HasBeenVoxModulesNetworked = true
				TFAVOX_NetworkActive( ply )
				TFAVOX_NetworkOption( ply )
			end
		end
	end)
end)

--[[ External Utils ]]--

function TFAVOX_GetModuleOption( modi, option, fallback )
	local mod
	if isstring(modi) then mod = TFAVOX_Modules[modi] else mod = TFAVOX_Modules[modi.class] or modi end
	if !mod then return fallback end
	if !mod.options then return fallback end
	if !mod.options[option] then return fallback end

	if mod.options[option].value == nil then
		if mod.options[option].default == nil then
			return fallback
		else
			return mod.options[option].default
		end
	end

	return mod.options[option].value
end
