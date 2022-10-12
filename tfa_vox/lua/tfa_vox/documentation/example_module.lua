if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Test Module"
MODULE.description = "Tests hook injection"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.activedefault = false
MODULE.options = {
	["sampleopt"] = { 
		["name"] = "Sample Option",
		["description"] = "Sample option",
		["type"] = "integer",--integer,float,boolean,string,vector,color
		["min"] = 0,
		["max"] = 100,
		["default"] = 100
	},
	["sampleoptfloat"] = { 
		["name"] = "Sample Float Option",
		["description"] = "Sample option that's a float",
		["type"] = "float",--integer,float,boolean,string,vector,color
		["min"] = 0,
		["max"] = 100,
		["default"] = 50.5
	},
	["sampleoptstr"] = { 
		["name"] = "Sample String Option",
		["description"] = "Sample option that's a string",
		["type"] = "string",--integer,float,boolean,string,vector,color
		["default"] = "test"
	},
	["sampleoptcol"] = { 
		["name"] = "Sample Color Option",
		["description"] = "Sample option that's a color",
		["type"] = "color",--integer,float,boolean,string,vector,color
		["default"] = Color(255,0,0,255)
	},
	["sampleoptvec"] = { 
		["name"] = "Sample Vector Option",
		["description"] = "Sample option that's a vector",
		["type"] = "vector",--integer,float,boolean,string,vector,color
		["default"] = Vector(0,0,0)
	}
}

local lastprint = -999

hook.Add("Think","TestDH",function()
	
	if CurTime()>lastprint+5 then
		lastprint = CurTime()
		print("It works!")
	end
	
end)