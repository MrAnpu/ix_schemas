-- rename and put to lua/tfa_vox/packs

TFAVOX_Models = TFAVOX_Models or {}


local model = "models/player/player.mdl" --<< REPLACE THIS WITH YOUR TARGET MODEL, USE FORWARD SLASHES


--[[CONVENIENCE FUNCTIONS, DO NOT EDIT FROM THIS POINT UNTIL CLEAR ]]--

local tmptbl = string.Split(model,"/")
local mdlprefix = tmptbl[#tmptbl] or model
mdlprefix = string.Replace(mdlprefix,".mdl","")
if model == "models/player/player.mdl" then return end

--[[CLEAR]]--

--[[
--To give VOX sound paths, I recommend TFAVOX_GenerateSound.
--TFAVOX_GenerateSound( mdlprefix, "sound_event_here", { "path/to/sound1.wav", "path/to/sound2.wav", "path/to/sound3.wav" }
--You may have as many sounds as you want in the GenerateSound table ^^
--Please have at least one.

--If you insist on doing things manually, ['sound'] can be a TABLE | { "sound1.wav", "sound2.wav", "sound3.wav" } | or a STRING  | "snd" |
--Manual sounds require soundscripts.

--TFA VOX will now automatically calculate delays.
--If you need to manually override, feed ['delay'] with a TABLE | {min,max} | or a NUMBER | 999 |
]]--

TFAVOX_Models[model] = {
	['main'] = {--subtable id
		['heal'] = {--event id
			['delay']= nil,--delay ( nil to autocalc )
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "heal", { "snd1", "snd2", "snd3" } ) --sound path(s)
		},
		['healmax'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "healmax", { "snd1", "snd2", "snd3" } )
		},
		['crithit'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "crithit", { "snd1", "snd2", "snd3" } )
		},
		['crithealth'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "crithealth", { "snd1", "snd2", "snd3" } )
		},
		['death'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "death", { "snd1", "snd2", "snd3" } )
		},
		['spawn'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spawn", { "snd1", "snd2", "snd3" } )
		},
		['pickup'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "pickup", { "snd1", "snd2", "snd3" } )
		},
		['reload'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "reload", { "snd1", "snd2", "snd3" } )
		},
		['noammo'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "noammo", { "snd1", "snd2", "snd3" } )
		},
		['fall'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "fall", { "snd1", "snd2", "snd3" } )
		},
		['jump'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "jump", { "snd1", "snd2", "snd3" } )
		},
		['step'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "step", { "snd1", "snd2", "snd3" } )
		}
	},
	['murder'] = {
		['combine'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdcomb", { "snd1", "snd2", "snd3" } )
		},
		['cp'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdcp", { "snd1", "snd2", "snd3" } )
		},
		['zombie'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdzomb", { "snd1", "snd2", "snd3" } )
		},
		['headcrab'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdhc", { "snd1", "snd2", "snd3" } )
		},
		['antlion'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdant", { "snd1", "snd2", "snd3" } )
		},
		['barnacle'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdbarn", { "snd1", "snd2", "snd3" } )
		},
		['manhack'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdmh", { "snd1", "snd2", "snd3" } )
		},
		['scanner'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdsca", { "snd1", "snd2", "snd3" } )
		},
		['sniper'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdsni", { "snd1", "snd2", "snd3" } )
		},
		['turret'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdtur", { "snd1", "snd2", "snd3" } )
		},
		['ally'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdally", { "snd1", "snd2", "snd3" } )
		},
		-- ['npc_pigeon'] = { -- classname overrides category entry
			-- ['delay']= nil,
			-- ['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdpigeon", { "snd1", "snd2", "snd3" } )
		-- },
		['generic'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "murdgener", { "snd1", "snd2", "snd3" } )
		}
	},
	['spot'] = {
		['combine'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotcomb", { "snd1", "snd2", "snd3" } )
		},
		['cp'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotcp", { "snd1", "snd2", "snd3" } )
		},
		['zombie'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotzom", { "snd1", "snd2", "snd3" } )
		},
		['headcrab'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spothc", { "snd1", "snd2", "snd3" } )
		},
		['antlion'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotant", { "snd1", "snd2", "snd3" } )
		},
		['barnacle'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotbarn", { "snd1", "snd2", "snd3" } )
		},
		['manhack'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotmh", { "snd1", "snd2", "snd3" } )
		},
		['scanner'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotsca", { "snd1", "snd2", "snd3" } )
		},
		['sniper'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotsni", { "snd1", "snd2", "snd3" } )
		},
		['turret'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spottur", { "snd1", "snd2", "snd3" } )
		},
		['ally'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotally", { "snd1", "snd2", "snd3" } )
		},
		-- ['npc_crow'] = { -- classname overrides category entry
			-- ['delay']= nil,
			-- ['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotcrow", { "snd1", "snd2", "snd3" } )
		-- },
		['generic'] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "spotgener", { "snd1", "snd2", "snd3" } )
		}
	},
	['taunt'] = {
		[ACT_GMOD_GESTURE_AGREE] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_GESTURE_AGREE", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_GESTURE_BECON] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_GESTURE_BECON", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_GESTURE_BOW] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_GESTURE_BOW", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_GESTURE_DISAGREE] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_GESTURE_DISAGREE", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_TAUNT_SALUTE] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_TAUNT_SALUTE", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_GESTURE_WAVE] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_GESTURE_WAVE", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_TAUNT_PERSISTENCE] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_TAUNT_PERSISTENCE", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_TAUNT_MUSCLE] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_TAUNT_MUSCLE", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_TAUNT_LAUGH] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_TAUNT_LAUGH", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_GESTURE_POINT] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_GESTURE_POINT", { "snd1", "snd2", "snd3" } )
		},
		[ACT_GMOD_TAUNT_CHEER] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_GMOD_TAUNT_CHEER", { "snd1", "snd2", "snd3" } )
		},
		[ACT_SIGNAL_FORWARD] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_SIGNAL_FORWARD", { "snd1", "snd2", "snd3" } )
		},
		[ACT_SIGNAL_GROUP] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_SIGNAL_GROUP", { "snd1", "snd2", "snd3" } )
		},
		[ACT_SIGNAL_HALT] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "ACT_SIGNAL_HALT", { "snd1", "snd2", "snd3" } )
		}
	},
	['damage'] = {
		[HITGROUP_GENERIC] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_GENERIC", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_HEAD] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_HEAD", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_CHEST] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_CHEST", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_STOMACH] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_STOMACH", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_LEFTARM] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_LEFTARM", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_RIGHTARM] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_RIGHTARM", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_LEFTLEG] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_LEFTLEG", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_RIGHTLEG] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_RIGHTLEG", { "snd1", "snd2", "snd3" } )
		},
		[HITGROUP_GEAR] = {
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "HITGROUP_GEAR", { "snd1", "snd2", "snd3" } )
		}
	},
	['callouts'] = {
		['agree'] = { -- callout classname in these quotes
			['name'] = "Agree",--Callout friendly name ( what you see in the wheel )
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "Wheel_Agree", { "snd1", "snd2", "snd3" } )
		},
		['disagree'] = { -- callout classname in these quotes
			['name'] = "Disagree",--Callout friendly name ( what you see in the wheel )
			['delay']= nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "Wheel_Disagree", { "snd1", "snd2", "snd3" } )
		}
	},
	['external'] = { --Completely optional, allows you to integrate with external mods
		['bash'] = { -- Used by TFA Base
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "Bash", { "snd1", "snd2", "snd3" } )
		}
	}
}
