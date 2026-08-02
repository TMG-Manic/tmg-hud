
TMGCore = exports['tmg-core']:GetCoreObject()
PlayerData = TMGCore.Functions.GetPlayerData()



HUDMenu = Config.Menu 

local speedMultiplier = Config.UseMPH and 2.23694 or 3.6
local seatbeltOn = false
local cruiseOn = false
local showAltitude = false
local showSeatbelt = false
local nos = 0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local nitroActive = 0
local harness = 0
local hp = 100
local armed = false
local parachute = -1
local oxygen = 100
local dev = false
local playerDead = false
local showMenu = false
local showCircleB = false
local showSquareB = false
local CinematicHeight = 0.2
local w = 0
local radioActive = false


local prevPlayerStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }
local prevVehicleStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }
local prevBaseplateStats = { nil, nil, nil, nil, nil, nil, nil }

DisplayRadar(false)



local function CinematicShow(bool)
    SetBigmapActive(true, false)
    Wait(0)
    SetBigmapActive(false, false)
    if bool then
        for i = CinematicHeight, 0, -1.0 do Wait(10) w = i end
    else
        for i = 0, CinematicHeight, 1.0 do Wait(10) w = i end
    end
end

local function loadSettings(settings)
    for k, v in pairs(settings) do
        if k == 'isToggleMapShapeChecked' then
            HUDMenu.isToggleMapShapeChecked = v
            SendNUIMessage({ test = true, event = k, toggle = v })
        elseif k == 'isCinematicModeChecked' then
            HUDMenu.isCinematicModeChecked = v
            CinematicShow(v)
            SendNUIMessage({ test = true, event = k, toggle = v })
        elseif k == 'isChangeFPSChecked' then
            HUDMenu[k] = v
            local val = v and 'Optimized' or 'Synced'
            SendNUIMessage({ test = true, event = k, toggle = val })
        else
            HUDMenu[k] = v
            SendNUIMessage({ test = true, event = k, toggle = v })
        end
    end
    TMGCore.Functions.Notify(Lang:t('notify.hud_settings_loaded'), 'success')
    Wait(1000)
    TriggerEvent('hud:client:LoadMap')
end

local function saveSettings()
    SetResourceKvp('hudSettings', json.encode(HUDMenu))
end

local function hasHarness(items)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end
    local _harness = false
    if items then
        for _, v in pairs(items) do
            if v.name == 'harness' then _harness = true end
        end
    end
    harness = _harness
end



local function updatePlayerHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevPlayerStats[k] ~= v then shouldUpdate = true break end
    end
    if shouldUpdate then
        prevPlayerStats = data
        SendNUIMessage({ action = 'hudtick', show = data[1], dynamicHealth = data[2], dynamicArmor = data[3], dynamicHunger = data[4], dynamicThirst = data[5], dynamicStress = data[6], dynamicOxygen = data[7], dynamicEngine = data[8], dynamicNitro = data[9], health = data[10], playerDead = data[11], armor = data[12], thirst = data[13], hunger = data[14], stress = data[15], voice = data[16], radio = data[17], talking = data[18], armed = data[19], oxygen = data[20], parachute = data[21], nos = data[22], cruise = data[23], nitroActive = data[24], harness = data[25], hp = data[26], speed = data[27], engine = data[28], cinematic = data[29], dev = data[30], radioActive = data[31] })
    end
end

local function updateVehicleHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevVehicleStats[k] ~= v then shouldUpdate = true break end
    end
    if shouldUpdate then
        prevVehicleStats = data
        SendNUIMessage({ action = 'car', show = data[1], isPaused = data[2], seatbelt = data[3], speed = data[4], fuel = data[5], altitude = data[6], showAltitude = data[7], showSeatbelt = data[8], showSquareB = data[9], showCircleB = data[10] })
    end
end

local function updateBaseplateHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevBaseplateStats[k] ~= v then shouldUpdate = true break end
    end
    if shouldUpdate then
        prevBaseplateStats = data
        SendNUIMessage({ action = 'baseplate', show = data[1], street1 = data[2], street2 = data[3], showCompass = data[4], showStreets = data[5], showPointer = data[6], showDegrees = data[7] })
    end
end



RegisterNetEvent('TMGCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then loadSettings(json.decode(hudSettings)) end
    PlayerData = TMGCore.Functions.GetPlayerData()
    Wait(3000)
    SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent('TMGCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('TMGCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then loadSettings(json.decode(hudSettings)) end
end)

AddEventHandler('pma-voice:radioActive', function(data)
    radioActive = data
end)



RegisterCommand('menu', function()
    if showMenu then return end
    TriggerEvent('hud:client:playOpenMenuSounds')
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
    showMenu = true
end)

RegisterNUICallback('closeMenu', function(_, cb)
    TriggerEvent('hud:client:playCloseMenuSounds')
    showMenu = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterKeyMapping('menu', 'Open Menu', 'keyboard', Config.OpenMenu or Config.OpenKey or 'I')
local function restartHud()
    TriggerEvent('hud:client:playResetHudSounds')
    TMGCore.Functions.Notify(Lang:t('notify.hud_restart'), 'error')
    Wait(2600)
    SendNUIMessage({ action = 'hudtick', show = false })
    SendNUIMessage({ action = 'hudtick', show = true })
    TMGCore.Functions.Notify(Lang:t('notify.hud_start'), 'success')
end

RegisterNUICallback('restartHud', function(_, cb)
    restartHud()
    cb('ok')
end)

RegisterCommand('resethud', function()
    restartHud()
end)


local function RegisterToggle(id)
    RegisterNUICallback(id, function(_, cb)
        HUDMenu[id] = not HUDMenu[id]
        TriggerEvent('hud:client:playHudChecklistSound')
        saveSettings()
        cb('ok')
    end)
end

local toggles = { 'dynamicHealth', 'dynamicArmor', 'dynamicHunger', 'dynamicThirst', 'dynamicStress', 'dynamicOxygen', 'dynamicEngine', 'dynamicNitro', 'showOutMap', 'showOutCompass', 'showFollowCompass', 'showMapNotif', 'showFuelAlert', 'showCinematicNotif', 'changeFPS', 'showCompassBase', 'showStreetsNames', 'showPointerIndex', 'showDegreesNum', 'changeCompassFPS' }
for _, name in ipairs(toggles) do RegisterToggle(name) end



CreateThread(function()
    local wasInVehicle = false
    while true do
        local sleep = HUDMenu.isChangeFPSChecked and 500 or 50
        Wait(sleep)

        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            local playerId = PlayerId()
            local weapon = GetSelectedPedWeapon(ped)
            local vehicle = GetVehiclePedIsIn(ped, false)
            local inVeh = (vehicle ~= 0 and not IsThisModelABicycle(GetEntityModel(vehicle)))
            
            
            if not Config.WhitelistedWeaponArmed[weapon] then
                armed = (weapon ~= `WEAPON_UNARMED`)
            end
            playerDead = IsEntityDead(ped) or PlayerData.metadata['inlaststand'] or PlayerData.metadata['isdead'] or false
            parachute = GetPedParachuteState(ped)
            local oxygenVal = IsEntityInWater(ped) and (GetPlayerUnderwaterTimeRemaining(playerId) * 10) or (100 - GetPlayerSprintStaminaRemaining(playerId))
            
            local voice = 0
            if LocalPlayer.state['proximity'] then voice = LocalPlayer.state['proximity'].distance end
            
            local show = not IsPauseMenuActive() and w <= 0

            updatePlayerHud({
                show, HUDMenu.isDynamicHealthChecked, HUDMenu.isDynamicArmorChecked, HUDMenu.isDynamicHungerChecked, HUDMenu.isDynamicThirstChecked, HUDMenu.isDynamicStressChecked, HUDMenu.isDynamicOxygenChecked, HUDMenu.isDynamicEngineChecked, HUDMenu.isDynamicNitroChecked,
                GetEntityHealth(ped) - 100, playerDead, GetPedArmour(ped), thirst, hunger, stress, voice, LocalPlayer.state['radioChannel'], NetworkIsPlayerTalking(playerId), armed, oxygenVal, parachute, inVeh and nos or -1, cruiseOn, nitroActive, harness, hp, inVeh and math.ceil(GetEntitySpeed(vehicle) * speedMultiplier) or 0, inVeh and (GetVehicleEngineHealth(vehicle) / 10) or -1, HUDMenu.isCinematicModeChecked, dev, radioActive
            })

            if inVeh then
                if not wasInVehicle then DisplayRadar(true) wasInVehicle = true end
                updateVehicleHud({ show, IsPauseMenuActive(), seatbeltOn, math.ceil(GetEntitySpeed(vehicle) * speedMultiplier), math.floor(exports['LegacyFuel']:GetFuel(vehicle)), math.ceil(GetEntityCoords(ped).z * 0.5), (IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped)), not (IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped)), showSquareB, showCircleB })
            elseif wasInVehicle then
                wasInVehicle = false
                SendNUIMessage({ action = 'car', show = false, seatbelt = false, cruise = false })
                seatbeltOn, cruiseOn, harness = false, false, false
                DisplayRadar(HUDMenu.isOutMapChecked)
            end
        else
            SendNUIMessage({ action = 'hudtick', show = false })
        end
    end
end)



if not Config.DisableStress then
    CreateThread(function() 
        while true do
            Wait(10000)
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and not IsThisModelABicycle(GetEntityModel(veh)) then
                    local speed = GetEntitySpeed(veh) * speedMultiplier
                    local stressSpeed = (GetVehicleClass(veh) == 8) and Config.MinimumSpeed or (seatbeltOn and Config.MinimumSpeed or Config.MinimumSpeedUnbuckled)
                    if speed >= stressSpeed and not Config.WhitelistedVehicles[GetEntityModel(veh)] then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                end
            end
        end
    end)

    CreateThread(function() 
        while true do
            Wait(0)
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_UNARMED` and IsPedShooting(ped) and not Config.WhitelistedWeaponStress[weapon] then
                    if math.random() < Config.StressChance then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                else
                    if weapon == `WEAPON_UNARMED` then Wait(1000) end
                end
            end
        end
    end)
end


CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local effectInterval = 60000
        for _, v in pairs(Config.EffectInterval) do
            if stress >= v.min and stress <= v.max then effectInterval = v.timeout break end
        end

        if stress >= 100 then
            TriggerScreenblurFadeIn(1000.0)
            Wait(1500)
            TriggerScreenblurFadeOut(1000.0)
            if IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, 3500, 3500, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end
        elseif stress >= Config.MinimumStress then
            TriggerScreenblurFadeIn(1000.0)
            Wait(1000)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)



RegisterNetEvent('hud:client:LoadMap', function()
    local defaultAspectRatio = 1920 / 1080
    local resX, resY = GetActiveScreenResolution()
    local aspectRatio = resX / resY
    local minimapOffset = (aspectRatio > defaultAspectRatio) and (((defaultAspectRatio - aspectRatio) / 3.6) - 0.008) or 0

    if HUDMenu.isToggleMapShapeChecked == 'square' then
        RequestStreamedTextureDict('squaremap', false)
        while not HasStreamedTextureDictLoaded('squaremap') do Wait(10) end
        SetMinimapClipType(0)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
        SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
        showSquareB, showCircleB = HUDMenu.isToggleMapBordersChecked, false
    else
        RequestStreamedTextureDict('circlemap', false)
        while not HasStreamedTextureDictLoaded('circlemap') do Wait(10) end
        SetMinimapClipType(1)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'circlemap', 'radarmasksm')
        SetMinimapComponentPosition('minimap', 'L', 'B', -0.0100 + minimapOffset, -0.030, 0.180, 0.258)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.200 + minimapOffset, 0.0, 0.065, 0.20)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.015, 0.252, 0.338)
        showCircleB, showSquareB = HUDMenu.isToggleMapBordersChecked, false
    end
    SetBigmapActive(true, false)
    Wait(50)
    SetBigmapActive(false, false)
end)


CreateThread(function()
    local lastHeading = 1
    while true do
        Wait(HUDMenu.isChangeCompassFPSChecked and 50 or 0)
        local ped = PlayerPedId()
        local camRot = GetGameplayCamRot(0)
        local heading = HUDMenu.isCompassFollowChecked and tostring(TMGCore.Shared.Round(360.0 - ((camRot.z + 360.0) % 360.0))) or tostring(TMGCore.Shared.Round(360.0 - GetEntityHeading(ped)))
        if heading == '360' then heading = '0' end
        
        if heading ~= lastHeading then
            if IsPedInAnyVehicle(ped) then
                local pos = GetEntityCoords(ped)
                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                updateBaseplateHud({ true, GetStreetNameFromHashKey(s1), GetStreetNameFromHashKey(s2), HUDMenu.isCompassShowChecked, HUDMenu.isShowStreetsChecked, HUDMenu.isPointerShowChecked, HUDMenu.isDegreesShowChecked })
            elseif HUDMenu.isOutCompassChecked then
                updateBaseplateHud({ true, nil, nil, true, false, false, false })
            else
                updateBaseplateHud({ false })
            end
        end
        lastHeading = heading
    end
end)



RegisterNetEvent('hud:client:UpdateNeeds', function(h, t) hunger, thirst = h, t end)
RegisterNetEvent('hud:client:UpdateStress', function(s) stress = s end)
RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() seatbeltOn = not seatbeltOn end)
RegisterNetEvent('seatbelt:client:ToggleCruise', function() cruiseOn = not cruiseOn end)
RegisterNetEvent('hud:client:UpdateNitrous', function(l, b) nos, nitroActive = l, b end)
RegisterNetEvent('hud:client:UpdateHarness', function(h) hp = h end)

CreateThread(function() 
    while true do
        Wait(0)
        if w > 0 then
            DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
            DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
            DisplayRadar(0)
        end
        SetRadarZoom(1000)
    end
end)
