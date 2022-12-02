local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)
 
 sheriff_horse = nil
 sheriff = nil
 doctor = nil

local weaponMission = false
local sleep = 1000
local inRoute = false

function SheriffStart()
    sheriff_horse = SpawnHorse(Config.locations["sheriff"].horsemodel, Config.locations["sheriff"].spawncoords)
    --[[while not DoesEntityExist(sheriff_horse) do
        Wait(500)
    end]]
    
    sheriff = createNPCOnMount(Config.locations["sheriff"].pedmodel, GetEntityCoords(sheriff_horse), sheriff_horse)
    SetEntityHeading(sheriff_horse, Config.locations["sheriff"].spawncoords.w)
    TaskGoToEntity(sheriff, PlayerPedId(), -1, 5.0, 2.0,1073741824, 0)
    weaponMission = true
end


--Prompt--
local MissGroup = GetRandomIntInRange(0, 0xffffff)
local GetMissionPrompt 


function ClearMis()
    ClearPedTasksImmediately(doctor)
    SetEntityAsNoLongerNeeded(doctor)
    DeleteEntity(sheriff_horse)
    DeleteEntity(sheriff)
    DeleteEntity(doctor)
    sheriff_horse = nil
    sheriff = nil
    doctor = nil
    
    -- to remove the player from instance
    VORPcore.instancePlayers(0) 
end


local function GetMissionPromptF()
    
    Citizen.CreateThread(function()

        local str ="Взять задание"
        local wait = 0
        GetMissionPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        --PromptSetControlAction(GetWorkPrompt, 0x760A9C6F) --G
        PromptSetControlAction(GetMissionPrompt, 0xC7B5340A) --enter
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(GetMissionPrompt, str)
        PromptSetEnabled(GetMissionPrompt, true)
        PromptSetVisible(GetMissionPrompt, true)
        PromptSetHoldMode(GetMissionPrompt, true)
        PromptSetGroup(GetMissionPrompt, MissGroup)
        PromptRegisterEnd(GetMissionPrompt)
        
    end)
end


RegisterNetEvent('firsJob:client:startSheriff')
AddEventHandler('firsJob:client:startSheriff', function()
    SheriffStart()
end)

RegisterNetEvent('firsJob:client:getMission')
AddEventHandler('firsJob:client:getMission', function(horseID)
    --print('53 horseID', horseID)
    TriggerServerEvent('vorpstables:SetDefaultHorse', horseID)
    inRoute = true
    ClearPedTasksImmediately(sheriff)
    SetEntityAsNoLongerNeeded(sheriff)
    doctor = createNPC(Config.locations["tumbleweed"].pedmodel , Config.locations["tumbleweed"].coords, Config.locations["tumbleweed"].scenario)
    blipCreate(Config.locations["tumbleweed"].coords, Config.locations["lake"].blipHash)
    while not DoesEntityExist(npc) do
        Wait(500)
    end
end)



Citizen.CreateThread(function()
    GetMissionPromptF()
    while true do
        local plpos = GetEntityCoords(PlayerPedId())
        if weaponMission then
            sleep = 0
            local sheriffpo = GetEntityCoords(sheriff)
            local dist_to_start = #(plpos - sheriffpo)
            --if not getJobAction thenТамблевида
            if dist_to_start <= 25.0 and dist_to_start >= 3.0 then
                DrawText3D(sheriffpo.x, sheriffpo.y, sheriffpo.z+1.5, 'Эй, приятель! Погоди-ка')
               
            elseif dist_to_start <= 5.0 then
                local message = 'Беда! В городе эпидемия чумы! Нужно срочно предупредить жителей Тамблевида.'
                DrawTxt(message, 0.50, 0.87, 0.4, 0.4, true, 255, 255, 255, 255, true)
                local message = 'Возьми карту, револьвер лошадь и дуй туда, что есть силы. Если зараза доберется до них раньше тебя - все пропало, я надеюсь на тебя.'
                DrawTxt(message, 0.50, 0.9, 0.4, 0.4, true, 255, 255, 255, 255, true)
                sleep = 0
                local getMission  = CreateVarString(10, 'LITERAL_STRING', "Законник")
                PromptSetActiveGroupThisFrame(MissGroup, getMission)
                if PromptHasHoldModeCompleted(GetMissionPrompt)  then
                    print('I get work')
                    weaponMission = false
                    --getJobAction = true
                    --
                    
                    local hashname = "WEAPON_REVOLVER_CATTLEMAN"   
                    TriggerServerEvent("syn_weapons:buyweapon", "WEAPON_REVOLVER_CATTLEMAN", 0, "Ржавый ковбойский кольт")
                    
                    
                    local hashname = "ammorevolvernormal"
					TriggerServerEvent("syn_weapons:buyammo", hashname, 0, 1, "Патроны для ржавого кольта")
                    local hashname = Config.DefaultHorseModel 
                    TriggerServerEvent("vorpstables:BuyNewHorse", "Дряхлая кляча", "race", hashname)
                    Wait(1500)
                    TriggerServerEvent('firsJob:server:getMission')
                    --vorpstables:SetDefaultHorse
                    --EventHandlers["vorpstables:BuyNewHorse"] += new Action<Player, string, string, string, double>(BuyNewHorse);  `name`, `type`, `modelname`
                    Citizen.Wait(700)
                end
            end
        end
        if inRoute then
            local tumbleweedPos = vec3(Config.locations["tumbleweed"].coords.x, Config.locations["tumbleweed"].coords.y, Config.locations["tumbleweed"].coords.z)
            local dist_to_tumbleweed = #(plpos - tumbleweedPos)
            sleep = 0
            print('dist_to_tumbleweed', dist_to_tumbleweed, doctor, doctor)
            if dist_to_tumbleweed >= 20.0 then
                DrawTxt(Config.locations["tumbleweed"].notifText, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
            elseif dist_to_tumbleweed < 20.0 and dist_to_tumbleweed >= 5.0 then
                DrawTxt(Config.locations["tumbleweed"].notifText2, 0.9, 0.3, 0.4, 0.4, true, 255, 255, 255, 255, true)
            elseif dist_to_tumbleweed < 5.0  then
                DrawTxt('Нажмите [~r~Space~q~] для завершения миссии', 0.50, 0.87, 0.4, 0.4, true, 255, 255, 255, 255, true)
                if IsControlJustReleased(0, keys["SPACEBAR"]) then
                    TriggerEvent("c_notify_client_new", 'Вы успели передать важную информацию. Миссия успешно завершена.', 'success', 7000)
                    TriggerEvent("c_notify_client_new", 'Осмотритесь', 'success', 10000)
                    ClearMis()
                end
            end

        end
        Wait(sleep)
    end
end)

