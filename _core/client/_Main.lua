local Tunnel = module("_core", "libs/Tunnel")
local Proxy = module("_core", "libs/Proxy")

API = Tunnel.getInterface("API")
cAPI = {}
Tunnel.bindInterface("API", cAPI)
Proxy.addInterface("API", cAPI)

AddEventHandler(
	"playerSpawned",
	function()
		TriggerServerEvent("pre_playerSpawned")
	end
)

AddEventHandler(
	"onResourceStart",
	function(resourceName)
		if (GetCurrentResourceName() ~= resourceName) then
			return
		end
		TriggerServerEvent("API:addReconnectPlayer")
	end
)

Citizen.CreateThread(
	function()
		SetMinimapHideFow(true)
		Citizen.InvokeNative(0x63E7279D04160477, true)
	end
)

function cAPI.getPosition()
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
	return x, y, z
end

function cAPI.teleport(x, y, z, spawn)
	SetEntityCoords(PlayerPedId(), x + 0.0001, y + 0.0001, z + 0.0001, 1, 0, 0, 1)
end

function cAPI.teleportSpawn(coordinate)
	local coords = json.decode(coordinate)
	cAPI.CameraWithSpawnEffect(coords)
	SetEntityCoords(PlayerPedId(), coords.x + 0.0001, coords.y + 0.0001, coords.z + 0.0001, 1, 0, 0, 1)
end

-- return vx,vy,vz
function cAPI.getSpeed()
	local vx, vy, vz = table.unpack(GetEntityVelocity(PlayerPedId()))
	return math.sqrt(vx * vx + vy * vy + vz * vz)
end

function cAPI.setModel(modelo)
	SetEntityAlpha(PlayerPedId(), 0)
	local model = GetHashKey(modelo)
	RequestModel(model)
	cAPI.LoadModel(model)
	Citizen.InvokeNative(0xED40380076A31506, PlayerId(), model)            
	Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true)
	SetModelAsNoLongerNeeded(model)
	SetEntityAlpha(PlayerPedId(), 255)
	return true
end

function cAPI.removeClothes(hash)
	local ped = PlayerPedId()
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), hash, 0)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
	return true
end

function cAPI.setClothes(hash)
	local Clothe = json.decode(hash)
	if hash ~= "{}" then
		for _, index in pairs(Clothes) do
			for k, v in pairs(Clothe) do
				if Clothes[_].name == k then
					if cAPI.removeClothes(Clothes[_].hash) then
						local modelHash = tonumber(v)
						cAPI.LoadModel(modelHash)
						Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), modelHash, true, true, true)
					end
				end
			end
		end
	else
		for k, v in pairs(DefaultClothes) do
			if GetEntityModel(PlayerPedId()) == GetHashKey(k) then
				for _, index in pairs(v) do
					for value, parameter in pairs(Clothes) do
						if Clothes[value].name == _ then
							if cAPI.removeClothes(Clothes[_].hash) then
								local modelHash = tonumber(v)
								cAPI.LoadModel(modelHash)
								Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), index, true, true, true)
							end
						end
					end
				end
			end
		end
	end
	return true
end

function cAPI.setDados(hash)
	local Dados = json.decode(hash)
	if Dados then
		local ArrayDados = { 
			Dados.head, Dados.hair, Dados.torso, Dados.legs, Dados.eyes, Dados.bodySize, Dados.teeth, Dados.mustache
		}
		for _,index in pairs(ArrayDados) do
			Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), tonumber(index), true, true, true)
		end
		return true
	end
end

function cAPI.getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
	local pitch = GetGameplayCamRelativePitch()
	local x = -math.sin(heading * math.pi / 180.0)
	local y = math.cos(heading * math.pi / 180.0)
	local z = math.sin(pitch * math.pi / 180.0)
	local len = math.sqrt(x * x + y * y + z * z)
	if len ~= 0 then
		x = x / len
		y = y / len
		z = z / len
	end
	return x, y, z
end

function cAPI.getNearestPlayers(radius)
	local r = {}
	local ped = PlayerPedId()
	local pid = PlayerId()
	local pCoords = GetEntityCoords(ped)

	for _, v in pairs(GetActivePlayers()) do
		local player = GetPlayerFromServerId(v)
		local pPed = GetPlayerPed(player)
		local pPCoords = GetEntityCoords(pPed)
		local distance = #(pCoords - pPCoords)
		if distance <= radius then
			r[GetPlayerServerId(player)] = distance
		end
	end

	-- for k, v in pairs(players) do
	-- 	local player = GetPlayerFromServerId(k)
	-- 	if v and player ~= pid and NetworkIsPlayerConnected(player) then
	-- 		local oped = GetPlayerPed(player)
	-- 		local x, y, z = table.unpack(GetEntityCoords(oped, true))
	-- 		local distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, true)
	-- 		if distance <= radius then
	-- 			r[GetPlayerServerId(player)] = distance
	-- 		end
	-- 	end
	-- end
	return r
end

function cAPI.getNearestPlayer(radius)
	local p = nil
	local players = cAPI.getNearestPlayers(radius)
	local min = radius + 10.0
	for k, v in pairs(players) do
		if v < min then
			min = v
			p = k
		end
	end
	return p
end

local weaponModels = {
	"weapon_melee_hatchet",
	"weapon_thrown_throwing_knives",
	"weapon_lasso",
	"weapon_pistol_mauser",
	"weapon_pistol_semiauto",
	"weapon_pistol_volcanic",
	"weapon_repeater_carbine",
	"weapon_repeater_henry",
	"weapon_rifle_varmint",
	"weapon_shotgun_repeating",
	"weapon_revolver_cattleman",
	"weapon_revolver_doubleaction",
	"weapon_revolver_schofield",
	"weapon_revolver_schofield",
	"weapon_revolver_schofield",
	"weapon_rifle_boltaction",
	"weapon_sniperrifle_carcano",
	"weapon_sniperrifle_carcano",
	"weapon_rifle_springfield",
	"weapon_shotgun_doublebarrel",
	"weapon_shotgun_pump",
	"weapon_shotgun_repeating",
	"weapon_shotgun_sawedoff",
	"weapon_bow",
	"weapon_thrown_dynamite0",
	"weapon_thrown_molotov",
	"weapon_melee_electric_lantern",
	"weapon_melee_torch",
	"weapon_fishingrod"
}

function cAPI.getWeapons()
	local ped = PlayerPedId()

	local ammo_types = {}

	local weapons = {}
	for k, v in pairs(weaponModels) do
		local hash = GetHashKey(v)
		if HasPedGotWeapon(ped, hash) then
			local atype = GetPedAmmoTypeFromWeapon(ped, hash)
			if ammo_types[atype] == nil then
				ammo_types[atype] = true
				weapons[v] = GetAmmoInPedWeapon(ped, hash)
			else
				weapons[v] = 0
			end
		end
	end

	return weapons
end

function cAPI.replaceWeapons(weapons)
	local old_weapons = cAPI.getWeapons()
	cAPI.giveWeapons(weapons, true)
	return old_weapons
end

function cAPI.giveWeapon(weapon, ammo, clear_before)
	cAPI.giveWeapons(
		{
			weapon = ammo
		},
		clear_before
	)
end

function cAPI.giveWeapons(weapons, clear_before)
	local ped = PlayerPedId()

	if clear_before then
		RemoveAllPedWeapons(ped, true, true)
	end

	for weapon, ammo in pairs(weapons) do
		local hash = GetHashKey(weapon)

		GiveWeaponToPed_2(
			PlayerPedId(),
			hash,
			ammo or 0,
			false,
			true,
			GetWeapontypeGroup(hash),
			ammo > 0,
			0.5,
			1.0,
			0,
			true,
			0,
			0
		)
		Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), hash, 0, false, true)
		Citizen.InvokeNative(0x5FD1E1F011E76D7E, PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash), ammo)
	end
end

function cAPI.setArmour(amount)
	SetPedArmour(PlayerPedId(), amount)
end

function cAPI.getArmour()
	return GetPedArmour(PlayerPedId())
end

function cAPI.setHealth(amount)
	SetEntityHealth(PlayerPedId(), math.floor(amount))
end

function cAPI.getHealth()
	return GetEntityHealth(PlayerPedId())
end

local prompResult = nil

function cAPI.prompt(title, default_text)
	SendNUIMessage({act = "prompt", title = title, text = tostring(default_text)})
	SetNuiFocus(true)
	while prompResult == nil do
		Citizen.Wait(10)
	end
	local _temp = prompResult
	prompResult = nil
	return _temp
end

RegisterNUICallback(
	"prompt",
	function(data, cb)
		if data.act == "close" then
			SetNuiFocus(false)
			prompResult = data.result
		end
	end
)

local requests = {}

function cAPI.request(text, time)
	local id = math.random(999999)
	SendNUIMessage({act = "request", id = id, text = tostring(text), time = time})

	-- !!! OPTIMIZATION
	-- Stop the loop while the time has passed

	while requests[id] == nil do
		Citizen.Wait(10)
	end

	local _temp = requests[id] or false
	requests[id] = nil
	return _temp
end

RegisterNUICallback(
	"request",
	function(data, cb)
		if data.act == "response" then
			requests[data.id] = data.ok
		end
	end
)

Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(3)
			if IsControlJustPressed(1, 166) then
				SendNUIMessage({act = "event", event = "yes"})
			end
			if IsControlJustPressed(1, 167) then
				SendNUIMessage({act = "event", event = "no"})
			end
		end
	end
)

local noclip = false
local noclip_speed = 10.0

function cAPI.toggleNoclip()
	noclip = not noclip
	if noclip then
		SetEntityInvincible(PlayerPedId(), true)
		SetEntityVisible(PlayerPedId(), false, false)
		NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
	else
		SetEntityInvincible(PlayerPedId(), false)
		SetEntityVisible(PlayerPedId(), true, false)
		NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
	end
end

Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(0)
			SetEntityMaxHealth(PlayerPedId(), 150)
			SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
			if noclip then
				local ped = PlayerPedId()
				local x, y, z = cAPI.getPosition()
				local dx, dy, dz = cAPI.getCamDirection()
				local speed = noclip_speed
				SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)

				if IsControlPressed(0, 0x8FD015D8) then
					x = x + speed * dx
					y = y + speed * dy
					z = z + speed * dz
				end

				if IsControlPressed(0, 0xD27782E3) then
					x = x - speed * dx
					y = y - speed * dy
					z = z - speed * dz
				end

				if IsControlPressed(0, 0x8FFC75D6) then -- SHIFT
					noclip_speed = 10.0
				elseif IsControlPressed(0, 0xDB096B85) then -- CTRL
					noclip_speed = 0.2
				else
					noclip_speed = 1.0
				end

				SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
			end
		end
	end
)

function cAPI.teleportToWaypoint()
	if not IsWaypointActive() then
		return
	end

	local x, y, z = table.unpack(GetWaypointCoords())

	local ground
	local groundFound = false
	local groundCheckHeights = {
		0.0,
		50.0,
		100.0,
		150.0,
		200.0,
		250.0,
		300.0,
		350.0,
		400.0,
		450.0,
		500.0,
		550.0,
		600.0,
		650.0,
		700.0,
		750.0,
		800.0,
		850.0,
		900.0,
		950.0,
		1000.0,
		1050.0,
		1100.0
	}

	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	if IsPedInAnyVehicle(ped) then
		ped = veh
	end

	for i, height in ipairs(groundCheckHeights) do
		SetEntityCoordsNoOffset(ped, x, y, height, 0, 0, 1)

		RequestCollisionAtCoord(x, y, z)
		while not HasCollisionLoadedAroundEntity(ped) do
			RequestCollisionAtCoord(x, y, z)
			Citizen.Wait(1)
		end
		Citizen.Wait(20)

		ground, z = GetGroundZFor_3dCoord(x, y, height)
		if ground then
			z = z + 1.0
			groundFound = true
			break
		end
	end

	if not groundFound then
		z = 1200
		GiveDelayedWeaponToPed(PlayerPedId(), 0xFBAB5776, 1, 0)
	end

	RequestCollisionAtCoord(x, y, z)
	while not HasCollisionLoadedAroundEntity(ped) do
		RequestCollisionAtCoord(x, y, z)
		Citizen.Wait(1)
	end

	SetEntityCoordsNoOffset(ped, x, y, z, 0, 0, 1)
end

function cAPI.playAnim(dict, anim, speed)
	if not IsEntityPlayingAnim(PlayerPedId(), dict, anim) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(100)
		end
		TaskPlayAnim(PlayerPedId(), dict, anim, speed, 1.0, -1, 0, 0, 0, 0, 0, 0, 0)
	end
end

function cAPI.createVehicle(modelName)
	local modelHash = GetHashKey(modelName)

	if not IsModelValid(modelHash) then
		return
	end

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)
		while not HasModelLoaded(modelHash) do
			Citizen.Wait(10)
		end
	end

	local ped = PlayerPedId()
	local nveh = CreateVehicle_2(mhash, GetEntityCoords(ped), GetEntityHeading(ped), true, false, true)

	SetVehicleOnGroundProperly(nveh)
	SetEntityAsMissionEntity(nveh, true, true)
	TaskWarpPedIntoVehicle(ped, nveh, -1)
	SetModelAsNoLongerNeeded(mhash)
	SetVehicleDirtLevel(nveh, 0)
end

function cAPI.isPlayingAnimation(dict, anim)
	local ped = PlayerPedId()
	return IsEntityPlayingAnim(ped, dict, anim, 3)
end

function cAPI.clientConnected(bool)
	if bool then
		ShutdownLoadingScreenNui()
		ShutdownLoadingScreen()
	end
end

function cAPI.notify(_message)
	local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", _message, Citizen.ResultAsLong())
	SetTextScale(0.25, 0.25)
	SetTextCentre(1)
	Citizen.InvokeNative(0xFA233F8FE190514C, str)
	Citizen.InvokeNative(0xE9990552DEC71600)
end

function cAPI.DrawText(str, x, y, w, h, enableShadow, r, g, b, a, centre, font)
	local str = CreateVarString(10, "LITERAL_STRING", str)
	SetTextScale(w, h)
	SetTextColor(math.floor(r), math.floor(g), math.floor(b), math.floor(a))
	SetTextCentre(centre)
	if enableShadow then
		SetTextDropshadow(1, 0, 0, 0, 255)
	end
	Citizen.InvokeNative(0xADA9255D, font)
	DisplayText(str, x, y)
end

function cAPI.LoadModel(hash)
	local waiting = 0
	while not HasModelLoaded(hash) do
		waiting = waiting + 100
		Citizen.Wait(100)
		if waiting > 100 then
			RequestModel(hash)
			break
		end
	end
	return true
end

function cAPI.StartFade(timer)
    DoScreenFadeOut(timer)
    while IsScreenFadingOut() do
        Citizen.Wait(1)
    end
end

function cAPI.EndFade(timer)
    ShutdownLoadingScreen()
    DoScreenFadeIn(timer)
    while IsScreenFadingIn() do
        Citizen.Wait(1)
    end
end  

function cAPI.CameraWithSpawnEffect(coords)
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 621.67,374.08,873.24, 300.00,0.00,0.00, 100.00, false, 0) -- CAMERA COORDS
	PointCamAtCoord(cam, coords.x,coords.y,coords.z+200)
	SetCamActive(cam, true)
	cAPI.EndFade(500)
	RenderScriptCams(true, false, 1, true, true)
	Citizen.Wait(500)
	cam3 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x,coords.y,coords.z+200, 300.00,0.00,0.00, 100.00, false, 0)
	PointCamAtCoord(cam3, coords.x,coords.y,coords.z+200)
	SetCamActiveWithInterp(cam3, cam, 3900, true, true)
	Citizen.Wait(3900)
	cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x,coords.y,coords.z+200, 300.00,0.00,0.00, 100.00, false, 0)
	PointCamAtCoord(cam2, coords.x,coords.y,coords.z+2)
	SetCamActiveWithInterp(cam2, cam3, 3700, true, true)
	RenderScriptCams(false, true, 500, true, true)
	SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z+0.5)
	Citizen.Wait(500)
	Citizen.Wait(3000)
	DestroyAllCams(true)
end