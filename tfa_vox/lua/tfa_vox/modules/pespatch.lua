if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Player Expression Script - Compatibility Patch"
MODULE.description = "Allows legacy PES scripts to work"
MODULE.author = "TFA"
MODULE.realm = "shared"

hook.Add("TFAVOX_InitializePlayer","PESPatch",function( ply, force, clean )

	if !IsValid(ply) then return end

	if clean then
		ply.SoundHealed = nil
		ply.SoundHealedMax = nil
		ply.SoundCritHP = nil
		ply.SoundLowHP = nil
		ply.SoundPlayerDeath = nil
		ply.SoundPlayerSpawn = nil
		ply.SoundPlayerPickUp = nil
		ply.SoundReload = nil
		ply.SoundPlayerNoAmmo = nil
		ply.SoundFall = nil
		ply.SoundJump = nil
		ply.SoundFootstep = nil
		ply.SoundMurderCombine = nil
		ply.SoundMurderCP = nil
		ply.SoundMurderZombie = nil
		ply.SoundMurderHeadcrab = nil
		ply.SoundMurderManhack = nil
		ply.SoundMurderScanner = nil
		ply.SoundMurderSniper = nil
		ply.SoundMurderTurret = nil
		ply.SoundMurderAlly = nil
		ply.SoundMurder = nil
		ply.SoundSpotCombine = nil
		ply.SoundSpotCP = nil
		ply.SoundSpotZombie = nil
		ply.SoundSpotHeadcrab = nil
		ply.SoundSpotManhack = nil
		ply.SoundSpotScanner = nil
		ply.SoundSpotSniper = nil
		ply.SoundSpotTurret = nil
		ply.SoundAlly = nil
		ply.SoundSpot = nil
		ply.TauntAgree = nil
		ply.TauntBecon = nil
		ply.TauntBow = nil
		ply.TauntDisAgree = nil
		ply.TauntSalute = nil
		ply.TauntWave = nil
		ply.TauntPersistence = nil
		ply.TauntMuscle = nil
		ply.TauntLaugh = nil
		ply.TauntPoint = nil
		ply.TauntCheer = nil
		ply.TauntForward = nil
		ply.TauntGroup = nil
		ply.TauntHalt = nil
		ply.SoundDamageGeneric = nil
		ply.SoundDamageHead = nil
		ply.SoundDamageChest = nil
		ply.SoundDamageStomach = nil
		ply.SoundDamageLeftArm = nil
		ply.SoundDamagerightArm = nil
		ply.SoundDamageLeftLeg = nil
		ply.SoundDamagerightLeg = nil
		ply.SoundDamageGear = nil
		ply.HaveValidModel = false
		return
	end

	if !ply.TFAVOX_Sounds and ply.HaveValidModel then ply.TFAVOX_Sounds = {}  end

	if !ply.TFAVOX_Sounds['main'] or force then
			if force and ply.TFAVOX_Sounds['main'] then table.Empty(ply.TFAVOX_Sounds['main']) end
			ply.TFAVOX_Sounds['main'] = {
				['heal'] = {
					['delay'] = ply.SoundHealedDelay or ply.SoundHealedMaxDelay,
					['sound'] = ply.SoundHealed or ply.SoundHealedMax
				},
				['healmax'] = {
					['delay'] = ply.SoundHealedMaxDelay or ply.SoundHealedDelay,
					['sound'] = ply.SoundHealedMax or ply.SoundHealed
				},
				['crithit'] = {
					['delay'] = ply.SoundCritHPDelay or ply.SoundLowHPDelay,
					['sound'] = ply.SoundCritHP
				},
				['crithealth'] = {
					['delay'] = ply.SoundLowHPDelay,
					['sound'] = ply.SoundLowHP
				},
				['death'] = {
					['delay'] = ply.SoundPlayerDeathDelay,
					['sound'] = ply.SoundPlayerDeath
				},
				['spawn'] = {
					['delay'] = ply.SoundPlayerSpawnDelay,
					['sound'] = ply.SoundPlayerSpawn
				},
				['pickup'] = {
					['delay'] = ply.SoundPlayerPickUpDelay,
					['sound'] = ply.SoundPlayerPickUp
				},
				['reload'] = {
					['delay'] = ply.SoundReloadDelay,
					['sound'] = ply.SoundReload
				},
				['noammo'] = {
					['delay'] = ply.SoundPlayerNoAmmoDelay,
					['sound'] = ply.SoundPlayerNoAmmo
				},
				['fall'] = {
					['delay'] = ply.SoundFallDelay,
					['sound'] = ply.SoundFall
				},
				['jump'] = {
					['delay'] = ply.SoundJumpDelay,
					['sound'] = ply.SoundJump
				},
				['step'] = {
					['delay'] = ply.SoundFootstepDelay,
					['sound'] = ply.SoundFootstep
				}
			}
		end

		if !ply.TFAVOX_Sounds['murder'] or force then
			if force and ply.TFAVOX_Sounds['murder'] then table.Empty(ply.TFAVOX_Sounds['murder']) end
			ply.TFAVOX_Sounds['murder'] = {
				['combine'] = {
					['delay'] = ply.SoundMurderCombineDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderCombine or ply.SoundMurder
				},
				['cp'] = {
					['delay'] = ply.SoundMurderCPDelay or ply.SoundMurderCombineDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderCP or ply.SoundMurderCombine or ply.SoundMurder
				},
				['zombie'] = {
					['delay'] = ply.SoundMurderZombieDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderZombie or ply.SoundMurder
				},
				['headcrab'] = {
					['delay'] = ply.SoundMurderHeadcrabDelay or ply.SoundMurderZombieDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderHeadcrab or ply.SoundMurderZombie or ply.SoundMurder
				},
				['manhack'] = {
					['delay'] = ply.SoundMurderManhackDelay or ply.SoundMurderCombineDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderManhack or ply.SoundMurderCombine or ply.SoundMurder
				},
				['scanner'] = {
					['delay'] = ply.SoundMurderScannerDelay or ply.SoundMurderCombineDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderScanner or ply.SoundMurderCombine or ply.SoundMurder
				},
				['sniper'] = {
					['delay'] = ply.SoundMurderSniperDelay or ply.SoundMurderCombineDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderSniper or ply.SoundMurderCombine or ply.SoundMurder
				},
				['turret'] = {
					['delay'] = ply.SoundMurderTurretDelay or ply.SoundMurderCombineDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderTurret or ply.SoundMurderCombine or ply.SoundMurder
				},
				['ally'] = {
					['delay'] = ply.SoundMurderAllyDelay or ply.SoundMurderDelay,
					['sound'] = ply.SoundMurderAlly or ply.SoundMurder
				},
				['generic'] = {
					['delay'] = ply.SoundMurderDelay,
					['sound'] = ply.SoundMurder
				}
			}
		end

		if !ply.TFAVOX_Sounds['spot'] or force then
			if force and ply.TFAVOX_Sounds['spot'] then table.Empty(ply.TFAVOX_Sounds['spot']) end

			if ply.SoundSpotCombine == "none" then ply.SoundSpotCombine = nil end
			if ply.SoundSpotCP == "none" then ply.SoundSpotCP = nil end
			if ply.SoundSpotZombie == "none" then ply.SoundSpotZombie = nil end
			if ply.SoundSpotHeadcrab == "none" then ply.SoundSpotHeadcrab = nil end
			if ply.SoundSpotManhack == "none" then ply.SoundSpotManhack = nil end
			if ply.SoundSpotScanner == "none" then ply.SoundSpotScanner = nil end
			if ply.SoundSpotTurret == "none" then ply.SoundSpotTurret = nil end
			if ply.SoundAlly == "none" then ply.SoundAlly = nil end
			if ply.SoundSpotAlly == "none" then ply.SoundSpotAlly = nil end
			if ply.SoundSpot == "none" then ply.SoundSpot = nil end

			ply.TFAVOX_Sounds['spot'] = {
				['combine'] = {
					['delay'] = ply.SoundSpotCombineDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotCombine or ply.SoundSpot or ply.SoundEnemyOther
				},
				['cp'] = {
					['delay'] = ply.SoundSpotCPDelay or ply.SoundSpotCombineDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotCP or ply.SoundSpotCombine or ply.SoundSpot or ply.SoundEnemyOther
				},
				['zombie'] = {
					['delay'] = ply.SoundSpotZombieDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotZombie or ply.SoundSpot
				},
				['headcrab'] = {
					['delay'] = ply.SoundSpotHeadcrabDelay or ply.SoundSpotZombieDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotHeadcrab or ply.SoundSpotZombie or ply.SoundSpot or ply.SoundEnemyOther
				},
				['manhack'] = {
					['delay'] = ply.SoundSpotManhackDelay or ply.SoundSpotCombineDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotManhack or ply.SoundSpotCombine or ply.SoundSpot or ply.SoundEnemyOther
				},
				['scanner'] = {
					['delay'] = ply.SoundSpotScannerDelay or ply.SoundSpotCombineDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotScanner or ply.SoundSpotCombine or ply.SoundSpot or ply.SoundEnemyOther
				},
				['sniper'] = {
					['delay'] = ply.SoundSpotSniperDelay or ply.SoundSpotCombineDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotSniper or ply.SoundSpotCombine or ply.SoundSpot or ply.SoundEnemyOther
				},
				['turret'] = {
					['delay'] = ply.SoundSpotTurretDelay or ply.SoundSpotCombineDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpotTurret or ply.SoundSpotCombine or ply.SoundSpot or ply.SoundEnemyOther
				},
				['ally'] = {
					['delay'] = ply.SoundAllyDelay or ply.SoundSpotAllyDelay or ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundAlly or ply.SoundSpotAlly or ply.SoundSpot or ply.SoundEnemyOther
				},
				['generic'] = {
					['delay'] = ply.SoundSpotDelay or ply.SoundEnemyOtherDelay,
					['sound'] = ply.SoundSpot or ply.SoundEnemyOther
				}
			}
		end

		if !ply.TFAVOX_Sounds['taunt'] or force then
			if force and ply.TFAVOX_Sounds['taunt'] then table.Empty(ply.TFAVOX_Sounds['taunt']) end
			ply.TFAVOX_Sounds['taunt'] = {
				[ACT_GMOD_GESTURE_AGREE] = {
					['delay'] = ply.TauntAgreeDelay,
					['sound'] = ply.TauntAgree
				},
				[ACT_GMOD_GESTURE_BECON] = {
					['delay'] = ply.TauntBeconDelay,
					['sound'] = ply.TauntBecon
				},
				[ACT_GMOD_GESTURE_BOW] = {
					['delay'] = ply.TauntBowDelay,
					['sound'] = ply.TauntBow
				},
				[ACT_GMOD_GESTURE_DISAGREE] = {
					['delay'] = ply.TauntDisAgreeDelay or ply.TauntDisagreeDelay,
					['sound'] = ply.TauntDisAgree or ply.TauntDisagree
				},
				[ACT_GMOD_TAUNT_SALUTE] = {
					['delay'] = ply.TauntSaluteDelay,
					['sound'] = ply.TauntSalute
				},
				[ACT_GMOD_GESTURE_WAVE] = {
					['delay'] = ply.TauntWaveDelay,
					['sound'] = ply.TauntWave
				},
				[ACT_GMOD_TAUNT_PERSISTENCE] = {
					['delay'] = ply.TauntPersistenceDelay,
					['sound'] = ply.TauntPersistence
				},
				[ACT_GMOD_TAUNT_MUSCLE] = {
					['delay'] = ply.TauntMuscleDelay,
					['sound'] = ply.TauntMuscle
				},
				[ACT_GMOD_TAUNT_LAUGH] = {
					['delay'] = ply.TauntLaughDelay,
					['sound'] = ply.TauntLaugh
				},
				[ACT_GMOD_GESTURE_POINT] = {
					['delay'] = ply.TauntPointDelay,
					['sound'] = ply.TauntPoint
				},
				[ACT_GMOD_TAUNT_CHEER] = {
					['delay'] = ply.TauntCheerDelay,
					['sound'] = ply.TauntCheer
				},
				[ACT_SIGNAL_FORWARD] = {
					['delay'] = ply.TauntForwardDelay,
					['sound'] = ply.TauntForward
				},
				[ACT_SIGNAL_GROUP] = {
					['delay'] = ply.TauntGroupDelay,
					['sound'] = ply.TauntGroup
				},
				[ACT_SIGNAL_HALT] = {
					['delay'] = ply.TauntHaltDelay,
					['sound'] = ply.TauntHalt
				},
				[ACT_GMOD_TAUNT_DANCE] = {
					['delay'] = ply.TauntDanceDelay,
					['sound'] = ply.TauntDance
				}
			}
		end

		if !ply.TFAVOX_Sounds['damage'] or force then
			if force and ply.TFAVOX_Sounds['damage'] then table.Empty(ply.TFAVOX_Sounds['damage']) end
			ply.TFAVOX_Sounds['damage'] = {
				[HITGROUP_GENERIC] = {
					['delay'] = ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_HEAD] = {
					['delay'] = ply.DMGheadDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageHead or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_CHEST] = {
					['delay'] = ply.DMGchestDelay or ply.SoundDamageChestDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageChest or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_STOMACH] = {
					['delay'] = ply.DMGstomachDelay or ply.SoundDamageStomachDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageStomach or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_LEFTARM] = {
					['delay'] = ply.DMGleftarmDelay or ply.SoundDamageArmDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageLeftArm or ply.SoundDamageArm or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_RIGHTARM] = {
					['delay'] = ply.DMGrightarmDelay or ply.SoundDamageArmDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamagerightArm or ply.SoundDamageArm or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_LEFTLEG] = {
					['delay'] = ply.DMGleftlegDelay or ply.SoundDamageLegDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageLeftLeg or ply.SoundDamageLeg or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_RIGHTLEG] = {
					['delay'] = ply.DMGrightlegDelay or ply.SoundDamageLegDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamagerightLeg or ply.SoundDamageLeg or ply.SoundDamageGeneric or ply.SoundDamage
				},
				[HITGROUP_GEAR] = {
					['delay'] = ply.SoundDamageGearDelay or ply.SoundDamageGenericDelay or ply.SoundDamageDelay,
					['sound'] = ply.SoundDamageGear or ply.SoundDamageGeneric or ply.SoundDamage
				}
			}
		end

end)

function TFAVOX_CleanPES()
	if !TFAVOX_HasCleanedPES and CurTime()>0.1 then
		hook.Remove("PlayerSpawn","PEPLAYERSPAWN")
		hook.Remove("PlayerSpawn","PEPLAYERSPAWN")
		hook.Remove("PlayerShouldTaunt","PECUSTOMTAUNTSOUNDS")
		hook.Remove("SetupMove","PEFALLINGTEST")
		hook.Remove("KeyPress","PEKEYDETECTION1")
		hook.Remove("PlayerDeathSound","PEMUTEDEFPLAYERDEATHSOUND")
		hook.Remove("PlayerDeath","PEPLAYERDEATHORMURDER")
		hook.Remove("PlayerFootstep","PEPLAYERFOOTSTEPSCUSTOM")
		hook.Remove("EntityTakeDamage","InklingPain")
		hook.Remove("ScalePlayerDamage","PEDAMAGESOUNDSANDMORE")
		hook.Remove("OnNPCKilled","PENPCKILLING")
		print("PES Cleaned")
		TFAVOX_HasCleanedPES = true
	end
end

hook.Add("Think","TFAVOX_CleanPES",TFAVOX_CleanPES)
