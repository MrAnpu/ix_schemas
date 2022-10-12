local TFAVOX_FRAMEWORK_PATH = "tfa_vox/framework/"

function TFAVOX_Root_Initialize()
	
	local files, folders = file.Find(TFAVOX_FRAMEWORK_PATH.."*","LUA")
	
	for k, v in pairs(files) do
		
		if SERVER then 
			include(TFAVOX_FRAMEWORK_PATH..v)
			AddCSLuaFile(TFAVOX_FRAMEWORK_PATH..v)
		elseif CLIENT then
			include(TFAVOX_FRAMEWORK_PATH..v)
		end
		
	end
	
end

hook.Add("Initialize","TFAVOX_Root_Initialize",TFAVOX_Root_Initialize)