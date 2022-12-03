local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local instanceNumber = 54123 -- any number






local start = false
local outTrain = false
local pedOnStation = nil
local getJobAction = false
local wagon = nil
blip = nil
local onRoute = false
local onLake = false
local onRouteBack = false
local buckets = 0
local cooldown = false

local mapTypeOnFoot
local mapTypeOnMount 


local armadillo = CircleZone:Create(vector3(-3689.62, -2611.49, -13.87), 150.0, {
    name="armadillo",
    useZ=false,
    --debugPoly=true
  })
  


  armadillo:onPlayerInOut(function(isPointInside)
    

        if isPointInside then
            currentZone = armadillo
           
            print('in')
            
        else
            print('out')
            currentZone = nil
         
        end
    
end)








local function Clear()
    --print('----', pedOnStation)
    SetEntityInvincible(pedOnStation, false)
    ClearPedTasksImmediately(pedOnStation)
    SetEntityAsNoLongerNeeded(pedOnStation)
    FreezeEntityPosition(pedOnStation, false)
    DeleteEntity(pedOnStation)
    pedOnStation = nil
   
    DeleteEntity(wagon)
    if DoesBlipExist (blip) then
       -- Citizen.InvokeNative(0xF2C3C9DA47AAA54A, blip)
       RemoveBlip(blip)
    end
    ClearGpsCustomRoute()
    SetMinimapType(mapTypeOnFoot)
    onRouteBack = false
    start = false
    outTrain = false
    
    wagon = nil
    blip = nil
    onRoute = false
    onLake = false
    onRouteBack = false
    buckets = 0
    cooldown = false


  
end







function SpawnNPC(Store)
    local v = Config.Stores[Store]
    LoadModel(v.NpcModel)
    if v.NpcAllowed then
        local npc = CreatePed(v.NpcModel, v.x, v.y, v.z, v.h, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        Config.Stores[Store].NPC = npc
    end
end

--Prompt--
local WorkGroup = GetRandomIntInRange(0, 0xffffff)
local GetWorkPrompt

local function GetWorkPromptF()
    
    Citizen.CreateThread(function()

        local str ="Взять работу"
        local wait = 0
        GetWorkPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(GetWorkPrompt, 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(GetWorkPrompt, str)
        PromptSetEnabled(GetWorkPrompt, true)
        PromptSetVisible(GetWorkPrompt, true)
        PromptSetHoldMode(GetWorkPrompt, true)
        PromptSetGroup(GetWorkPrompt, WorkGroup)
        PromptRegisterEnd(GetWorkPrompt)
        
    end)
end



local function CartCreate()
    --print('+')
    local player = PlayerPedId()
    local model = Config.locations["start"].cartmodel
    local coords = Config.locations["start"].cartcoord
    LoadModel(model)
  
    onRoute = true
    inMission = true
    wagon = CreateVehicle(model, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(wagon, coords.w)
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, wagon, 1, 0)
    SetPedIntoVehicle(player, wagon, -1)
    
    blipCreate(Config.locations["lake"].cartStopCoords, Config.locations["lake"].blipHash)
    

    TriggerEvent("vorp:ExecuteServerCallBack", "firsJob:server:checkminimapProp", function(result)
        --print('result', result)
        if result then
            mapTypeOnFoot = result.mapTypeOnFoot
            mapTypeOnMount = result.mapTypeOnMount 
            SetMinimapType(1)
        end
    end)
    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId()))+ instanceNumber)
end

local function loadWater()
    cooldown = true
    --animation--
    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_PLAYER_CHORES_BUCKET_POUR_HIGH'), 7000, true, false, false, false)
    
    Wait(7000)
    ClearPedTasksImmediately(PlayerPedId())
    --ClearPedTasks(PlayerPedId())
    TriggerServerEvent("firsJob:server:ChangeBuckets")
    Wait(1500)
    buckets = buckets - 1
    cooldown = false
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Clear()
        ClearMis()
    end
end)



RegisterNetEvent('firsJob:client:getJob')
AddEventHandler('firsJob:client:getJob', function()
    CartCreate()
end)








--[[Citizen.CreateThread(function()
    sleep = 1000
    while true do
        if notifShow then
            DrawTxt(message, 0.50, 0.90, 0.4, 0.4, true, 255, 255, 255, 255, true)
            sleep = 10
        end
        Wait(sleep)
    end
end)]]


--стартовая прорисовка педов--
Citizen.CreateThread(function()
    local npc = nil
    npc = createNPC(Config.locations["start"].pedmodel , Config.locations["start"].pedcoords, Config.locations["start"].scenario)
    while not DoesEntityExist(npc) do
        Wait(500)
    end
    pedOnStation = npc
end)

--проверка местоположения игрока для взаимодействия--
Citizen.CreateThread(function()
    sleep = 1000
    GetWorkPromptF()
    while true do
        local plpos = GetEntityCoords(PlayerPedId())
        if not getJobAction then 
            local st_coords = vec3(Config.locations["start"].pedcoords.x, Config.locations["start"].pedcoords.y, Config.locations["start"].pedcoords.z)
            local dist_to_start = #(plpos - st_coords)
            --if not getJobAction then
                if dist_to_start <= 10.0 and dist_to_start >= 3.0 then
                    DrawText3D(st_coords.x, st_coords.y, st_coords.z, 'Эй, не хочешь подзаработать?')
                    sleep = 0
                
                
                    --Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, plpos.x, plpos.y, plpos.z+1.0, 0, 0, 0, 0, 0, 0, 10.0, 10.0, 5.25, 255, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0)
                    --('textureDict, textureName', textureDict, textureName)
                    --DrawMarker(29, plpos.x, plpos.y, plpos.z, 0, 0, 0, 0, 0, 0, 10.0, 10.0, 5.25, 255, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0)

                elseif dist_to_start < 3.0 then
                    local message = 'Чертов Эдди не вышел сегодня на работу.'
                    DrawTxt(message, 0.50, 0.85, 0.4, 0.4, true, 255, 255, 255, 255, true)
                    local message = 'Скоро подойдет новый поезд, а бочка с водой почти пуста. Привези воды и получишь $' ..Config.price
                    DrawTxt(message, 0.50, 0.87, 0.4, 0.4, true, 255, 255, 255, 255, true)
                    sleep = 0

                    local getWork  = CreateVarString(10, 'LITERAL_STRING', "Станция")
                    PromptSetActiveGroupThisFrame(WorkGroup, getWork)
                    if PromptHasHoldModeCompleted(GetWorkPrompt)  then
                        --print('I get work')
                     
                        ClearPedTasksImmediately(pedOnStation)
                        SetEntityAsNoLongerNeeded(pedOnStation)
                        Citizen.Wait(700)
                        getJobAction = true
                        TriggerServerEvent('firsJob:server:getJob')
                        Citizen.Wait(700)
                        
                    end
                end
            --end
        end
        
        if onRoute then
           
            --local playerOnMout = IsPedOnMount(PlayerPedId())
            local playerOnVeh = IsPedInAnyVehicle(PlayerPedId())
            if playerOnVeh then 
                SetMinimapType(1)
            end
            sleep = 0
            local lake_coords = Config.locations["lake"].cartStopCoords
            local dist_to_place = #(plpos - lake_coords)
           -- print('onRoute', onRoute, 'blip', blip, 'dist_to_place', dist_to_place)
            if dist_to_place >= 50.0 then
                DrawTxt(Config.locations["lake"].notifText, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
            elseif dist_to_place < 50.0 and dist_to_place >= 10.0 then
                DrawTxt(Config.locations["lake"].notifText2, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
                --DrawMarker(29, lake_coords.x, lake_coords.y, lake_coords.z, 0, 0, 0, 0.0, 0, 0, 1.0, 1.0, 1.0, 0, 150, 0, 120, false, true, 2, false, nil, nil, false)
                --Citizen.InvokeNative(0x2A32FAA57B937173, Markers.Sphere, coords.x, coords.y, coords.z-0.95, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.25, color.r, color.g, color.b, color.a, 0, 0, 2, 0, 0, 0, 0)
                textureDict, textureName =  Citizen.InvokeNative(0x2A32FAA57B937173,0x07DCE236,lake_coords.x,lake_coords.y,lake_coords.z-0.9, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 3.5, 255,255,51, 250, 0, 0, 2, 0, 0, true, 0)
            elseif dist_to_place < 3.0 then
               --[[ local message = 'Нажмите [~r~Space~q~], что бы налить воду в бочку'
                local newcoords = GetEntityCoords(vagon)-GetEntityForwardVector(wagon)*5
                print('newcoords',  newcoords)    
                DrawTxt(message, 0.50, 0.87, 0.4, 0.4, true, 255, 255, 255, 255, true)
                textureDict, textureName =  Citizen.InvokeNative(0x2A32FAA57B937173,0x07DCE236,newcoords.x,newcoords.y,newcoords.z-0.9, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255,255,51, 250, 0, 0, 2, 0, 0, true, 0)
                if IsControlPressed(0, keys["SPACEBAR"]) then]]
                    onRoute = false
                    onLake = true
                    buckets = Config.locations["lake"].bucketsNeed
                --end
            end
        end

        if onLake then
            sleep = 0
            local lake_coords = Config.locations["lake"].cartStopCoords
            local dist_to_place = #(plpos - lake_coords)
            
            if dist_to_place >= 50.0 then
                DrawTxt(Config.locations["lake"].notifText3, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
            else
                local newcoords = GetEntityCoords(wagon)-(GetEntityForwardVector(wagon)*3)
                
                textureDict, textureName =  Citizen.InvokeNative(0x2A32FAA57B937173,0x07DCE236,newcoords.x,newcoords.y,newcoords.z-0.9, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 255,255,51, 250, 0, 0, 2, 0, 0, true, 0)
                --local message = 'Нажмите [~r~Space~q~], что бы налить воду в бочку'
                local message = 'Наполните бочку водой'
                DrawTxt(message, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
                local message2 = 'Осталось '..buckets..' ведер'
                DrawTxt(message2, 0.9, 0.35, 0.3, 0.3, true, 255, 255, 255, 255, true)
                --DrawText3D(newcoords.x, newcoords.y, newcoords.z, message)
                --print('onLake', onLake,  'dist_to_place', dist_to_place)
                
                local dist_to_wagon = #(plpos - newcoords)
                if dist_to_wagon <= 2.0 then
                    DrawTxt('Нажмите [~r~Space~q~] для наполнения бочки', 0.50, 0.87, 0.4, 0.4, true, 255, 255, 255, 255, true)
                    if IsControlJustReleased(0, keys["SPACEBAR"]) then
                        --print("SPACEBAR")
                        TriggerEvent("vorp:ExecuteServerCallBack", "firsJob:server:checkbucket", function(result)
                        --print('result', result)
                        if result then
                            if not cooldown then
                                loadWater()
                                if Config.locations["lake"].bucketsNeed - buckets >= Config.locations["lake"].bucketsNeed then
                                    onLake = false
                                    onRouteBack = true
                                    TriggerEvent("c_notify_client_new", 'Бочка наполнена, возвращайтесь на станцию', 'success', 7000)
                                    blipCreate(Config.locations["start"].finishCoords, Config.locations["lake"].blipHash)
                                end
                            end
                        end
                        end)
                    end
                end
            end
        end

        if onRouteBack then
            --local playerOnMout = IsPedOnMount(PlayerPedId())
            local playerOnVeh = IsPedInAnyVehicle(PlayerPedId())
            if playerOnVeh then 
                SetMinimapType(1)
            end
            sleep = 0
            local finishCoords = Config.locations["start"].finishCoords
            local dist_to_place = #(plpos - finishCoords)
            if dist_to_place >= 50.0 then
                DrawTxt(Config.locations["start"].notifText, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
            else
                textureDict, textureName =  Citizen.InvokeNative(0x2A32FAA57B937173,0x07DCE236,finishCoords.x,finishCoords.y,finishCoords.z-0.9, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 3.5, 255,255,51, 250, 0, 0, 2, 0, 0, true, 0)
                if dist_to_place <= 5.0 then
                    DrawTxt('Нажмите [~r~Space~q~] для завершения миссии', 0.50, 0.87, 0.4, 0.4, true, 255, 255, 255, 255, true)
                    if IsControlJustReleased(0, keys["SPACEBAR"]) then
                        
                        TriggerServerEvent("firsJob:server:pay")
                        Clear()
                        SheriffStart()
                    end
                end
            end
        end
    
        Wait(sleep)

    end
end)

