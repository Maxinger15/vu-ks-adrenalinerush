local ADRENALIN_DURATION = 15
local spreadDecrease = 0.65
local recoilDecrease = 0.65
--local reloadDecrese = 0.3

local debug = false
local activate = false
local reset = false
local running = false
local curStep = nil
local first = true

local deviationScaleFactorZoom = 1
local gameplayDeviationScaleFactorZoom = 1
local deviationScaleFactorNoZoom = 1
local gameplayDeviationScaleFactorNoZoom = 1
local shootingRecoilDecreaseScale = 1
local firstShotRecoilMultiplier = 1

local timer = ADRENALIN_DURATION

if debug then
	NetEvents:Subscribe(
		"vu-ks-adrenalinerush:Enable",
		function(player)
			activate = true
			timer = 9000000000
			Events:Dispatch("Killstreak:showNotification", json.encode({title="Adrenaline rush",message="Activated"}))
		end
	)
	NetEvents:Subscribe(
	"vu-ks-adrenalinerush:Disable",
	function(player)
		reset = true
		Events:Dispatch("Killstreak:showNotification", json.encode({title="Adrenaline rush",message="Deaktivated"}))
	end
)
end

Events:Subscribe(
	"vu-ks-adrenalinerush:Invoke",
	function(stepNr)
		print("Killstreak enabled")
		curStep = stepNr
		activate = true
		running = true
		Events:Dispatch("Killstreak:newTimer", json.encode({duration = ADRENALIN_DURATION, text = "Adrenaline rush"}))
		Events:Dispatch("Killstreak:usedStep", curStep,true)
	end
)

Events:Subscribe(
	"WeaponFiring:Update",
	function(weaponFiring)
		if first == true then
			if weaponFiring.gunSway == nil then
				return
			end
			gun = GunSwayData(weaponFiring.gunSway.data)
			gun:MakeWritable()
			deviationScaleFactorZoom = gun.deviationScaleFactorZoom
			gameplayDeviationScaleFactorZoom = gun.gameplayDeviationScaleFactorZoom
			deviationScaleFactorNoZoom = gun.deviationScaleFactorNoZoom
			gameplayDeviationScaleFactorNoZoom = gun.gameplayDeviationScaleFactorNoZoom
			shootingRecoilDecreaseScale = gun.shootingRecoilDecreaseScale
			firstShotRecoilMultiplier = gun.firstShotRecoilMultiplier
			first = false
		end
		if activate then
			if weaponFiring.gunSway == nil then
				return
			end
			gun = GunSwayData(weaponFiring.gunSway.data)
			gun:MakeWritable()
			gun.deviationScaleFactorZoom = gun.deviationScaleFactorZoom * spreadDecrease
			gun.gameplayDeviationScaleFactorZoom = gun.gameplayDeviationScaleFactorZoom * spreadDecrease
			gun.deviationScaleFactorNoZoom = gun.deviationScaleFactorNoZoom * spreadDecrease
			gun.gameplayDeviationScaleFactorNoZoom = gun.gameplayDeviationScaleFactorNoZoom  * spreadDecrease

			gun.shootingRecoilDecreaseScale = gun.shootingRecoilDecreaseScale * recoilDecrease
			gun.firstShotRecoilMultiplier = gun.firstShotRecoilMultiplier * recoilDecrease
			print("modified soldier")
			--FireLogicData(FiringFunctionData(WeaponFiringData(weaponFiring.data).primaryFire).fireLogic).reloadTime = FireLogicData(FiringFunctionData(WeaponFiringData(weaponFiring.data).primaryFire).fireLogic).reloadTime * reloadDecrese
			activate = false
		end
		if reset then
			if weaponFiring.gunSway == nil then
				return
			end
			gun = GunSwayData(weaponFiring.gunSway.data)
			gun:MakeWritable()
			gun.deviationScaleFactorZoom = deviationScaleFactorZoom
			gun.gameplayDeviationScaleFactorZoom = gameplayDeviationScaleFactorZoom
			gun.deviationScaleFactorNoZoom = deviationScaleFactorNoZoom
			gun.gameplayDeviationScaleFactorNoZoom = gameplayDeviationScaleFactorNoZoom

			gun.shootingRecoilDecreaseScale = shootingRecoilDecreaseScale
			gun.firstShotRecoilMultiplier = firstShotRecoilMultiplier
			print("Reseted Soldier")
			--FireLogicData(FiringFunctionData(WeaponFiringData(weaponFiring.data).primaryFire).fireLogic).reloadTime = FireLogicData(FiringFunctionData(WeaponFiringData(weaponFiring.data).primaryFire).fireLogic).reloadTime / reloadDecrese
			reset = false
		end
	end
)
Events:Subscribe(
	"Engine:Update",
	function(dt)
		if running then
			if timer > 0 then
				timer = timer -dt
			else
				reset = true
				Events:Dispatch("Killstreak:Finished", curStep)
				timer = ADRENALIN_DURATION
			end
		end
	end
)

Events:Subscribe(
	"Engine:Message",
	function(message)
		-- weapon change
		if message.type == 638585794 then
			activate = true
		end
	end
)
