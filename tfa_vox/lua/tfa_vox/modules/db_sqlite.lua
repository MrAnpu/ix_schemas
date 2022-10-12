if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "SQLite"
MODULE.description = "Uses GMod's native SQL support"
MODULE.author = "TFA"
MODULE.realm = "shared" 
MODULE.options = {
	["debug"] = { 
		["name"] = "Debug",
		["description"] = "Display debug messages?",
		["type"] = "boolean",--integer,float,boolean,string,vector,color
		["default"] = false
	}
}

MODULE.OnEnable = function( self )
	
	local selfv = self or MODULE
	TFAVOX_SQLite_SaveMod( selfv )
	
end

MODULE.OnDisable = function( self )
	
	local selfv = self or MODULE
	TFAVOX_SQLite_SaveMod( selfv )
	
end

function TFAVOX_SQLite_EscapeString( str, noquotes)
	return sql.SQLStr( str or "", noquotes)
end

function TFAVOX_SQLite_Query( qry )
	return sql.Query( qry )
end

function TFAVOX_SQLite_QueryValue( qry )
	return sql.QueryValue( qry )
end

function TFAVOX_SQLite_QueryRow( qry )
	return sql.QueryRow( qry )
end

function TFAVOX_SQLite_TableExists( str )
	return sql.TableExists( sql.SQLStr( str or "", true ) )
end

function TFAVOX_SQLite_LoadMod(mod)

	if TFAVOX_SQLite_TableExists( "tfavox_sqlite_modules" ) then
	
		if !mod then
			for k,v in pairs(TFAVOX_Modules) do
				hook.Call("TFAVOX_SQL_LoadMod",GM,v)
			end
			return
			--return true
		end
		
		local safeclass = TFAVOX_SQLite_EscapeString(mod.class or "class",true) 
		
		local val = TFAVOX_SQLite_QueryValue( "SELECT Active FROM tfavox_sqlite_modules WHERE Module = '".. ( safeclass  ) .. "';" )
		
		if val!=nil then
			
			local tf = val
			if !isbool(tf) then tf = tobool(tf) end
			
			TFAVOX_Modules_SetStatus( mod.class, tf )
			
			return
			
			--return true
			
		end
		
		return
		
		--return false
		
	end
end

hook.Add("TFAVOX_SQL_LoadMod","TFAVOX_SQLite_LoadMod",TFAVOX_SQLite_LoadMod)

function TFAVOX_SQLite_SaveMod(mod)
	
	if TFAVOX_SQLite_TableExists( "tfavox_sqlite_modules" ) then
	
		if !mod then
			for k,v in pairs(TFAVOX_Modules) do
				hook.Call("TFAVOX_SQL_SaveMod",GM,v)
			end
			return
			--return true
		end
	
		local safeclass = TFAVOX_SQLite_EscapeString(mod.class or "class",true) 
		
		local val = TFAVOX_SQLite_Query( "SELECT Active FROM tfavox_sqlite_modules WHERE Module = '".. ( safeclass  ) .. "';"  )
	
		local query
		
		if val==nil then
			query = "INSERT INTO tfavox_sqlite_modules( Module, Active ) VALUES ( '".. ( safeclass ) .. "', " .. ( safeclass and "1" or "0" ) ..");"
		else
			query = "UPDATE tfavox_sqlite_modules SET Active = " .. ( mod.active and "1" or "0" )..", Module = '".. ( safeclass ).."' WHERE Module = '".. ( safeclass ) .."';"
		end
		
		TFAVOX_SQLite_Query( query  )
		
		return
		
		--return true
		
	else
		
		local query = "CREATE TABLE tfavox_sqlite_modules ( Module string, Active boolean )"
		
		TFAVOX_SQLite_Query( query  )
		
		hook.Call("TFAVOX_SQL_SaveMod",GM,mod)
		
		return
		
		--return false
		
	end
end

hook.Add("TFAVOX_SQL_SaveMod","TFAVOX_SQLite_SaveMod",TFAVOX_SQLite_SaveMod)

function TFAVOX_SQLite_LoadModOptions(mod)
		
	local safeclass = TFAVOX_SQLite_EscapeString(mod.class or "class",true)
		
	local tbln = "tfavox_sqlite_module_"..safeclass

	if TFAVOX_SQLite_TableExists( tbln ) then
		
		if !mod then
			for k,v in pairs(TFAVOX_Modules) do
				hook.Call("TFAVOX_SQL_LoadMod",GM,v)
			end
			return
			--return true
		end
		
		local query =  "SELECT * FROM " .. tbln .. ";"
		
		local results = TFAVOX_SQLite_QueryRow( query )
		
		if results and istable(results) then
			for k,v in pairs(results) do
				if v!=nil then
					TFAVOX_Modules_SetModuleOption( mod, k, v )
					TFAVOX_NetworkOption( mod, k )
				end
			end
			
			return
			
			--return true
		end
		
	end
	
	return
	
	--return false
end

hook.Add("TFAVOX_SQL_LoadModOptions","TFAVOX_SQLite_LoadModOptions",TFAVOX_SQLite_LoadModOptions)

function TFAVOX_SQLite_SaveModOptions(mod)
		
	local safeclass = TFAVOX_SQLite_EscapeString(mod.class or "class",true)
		
	local tbln = "tfavox_sqlite_module_"..safeclass
	
	local docreatetable = false

	if !TFAVOX_SQLite_TableExists( tbln ) then
		docreatetable = true
	else
		
		local querysel =  "SELECT * FROM "..tbln..";"
		local val = TFAVOX_SQLite_QueryRow( querysel )
		if val and ( table.Count(val) != table.Count(mod.options) ) then
			local query =  "DROP TABLE "..tbln..";"
			TFAVOX_SQLite_Query( query )			
			docreatetable = true
		end
	
	end
	
	if !docreatetable then
		
		local querysel =  "SELECT * FROM "..tbln..";"
		local val = TFAVOX_SQLite_QueryRow(  querysel )
		local query = ""
		
		if val==nil then
			
			query = "INSERT INTO "..tbln.." VALUES ( "
		
			local keys = table.GetKeys( mod.options )

			table.sort(keys,function(a,b) 
				return
				--return tostring(a)<tostring(b)
			end)

			for _,k in ipairs(keys) do
				v = mod.options[k]
				local nval = v.value
				if nval==nil then nval = v.default end
				
				query = query .. TFAVOX_Modules_SQL_ConvertDataTo( nval, v.type ) .. ", "
			end
			
			query = string.TrimRight(query," ")
			query = string.TrimRight(query,",")
			
			query = query .. " );"
			
			--query = "INSERT INTO tfa_vox_modules( Module, Active ) VALUES ( '".. ( safeclass ) .. "', " .. ( mod.active and "1" or "0" ) ..");"
		else
			
			query = "UPDATE "..tbln.." SET "
		
			local keys = table.GetKeys( mod.options )

			table.sort(keys,function(a,b) 
				return
				--return tostring(a)<tostring(b)
			end)

			for _,k in ipairs(keys) do
				v = mod.options[k]
				local nval = v.value
				if nval==nil then nval = v.default end
				
				query = query .. k .. " = " .. TFAVOX_Modules_SQL_ConvertDataTo( nval, v.type ) .. ", "
			end
			
			query = string.TrimRight(query," ")
			query = string.TrimRight(query,",")
			
			query = query .. ";"
		end
		
		TFAVOX_SQLite_Query( query )
		
		return
		
		--return true
		
	else
		
		local query =  "CREATE TABLE "..tbln.." ( "
		query = query .. TFAVOX_Modules_SQL_GetModuleOptionsString( mod )
		query = query .. " );"
		TFAVOX_SQLite_Query( query )
		
		hook.Call("TFAVOX_SQL_SaveModOptions",GM,mod)
		
		return
		
		--return false
		
	end
end

hook.Add("TFAVOX_SQL_SaveModOptions","TFAVOX_SQLite_SaveModOptions",TFAVOX_SQLite_SaveModOptions)