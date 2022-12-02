function LoadModel(model)
    print('2 LoadModel', model)
    local model = GetHashKey(model)
    RequestModel(model)
    print('5')
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
    print('6')
end



function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 150
    --DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 52, 52, 52, 190, 0)
end

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end


function blipCreate(target, bliphash)
    --удаление старого блипа(если есть)--
    --print('before blip remove', blip)
    if DoesBlipExist (blip) then
        --Citizen.InvokeNative(0xF2C3C9DA47AAA54A, blip)
        RemoveBlip(blip)
    end
    

    --[[--blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, bliphash, train) -- BLIPADDFORENTITY
    blip = Citizen.InvokeNative(0x554D9D53F696D002, 1195729388, target.x, target.y, target.z)  --1664425300
	SetBlipSprite(blip, 1195729388, true)
	SetBlipScale(blip, 0.2)

	Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Точка маршрута')
    --StartGpsMultiRoute(70, true, true)]]
    --print('vector3(target.x, target.y, target.z)', vector3(target.x, target.y, target.z), 'target',target)
    blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, vector3(target.x, target.y, target.z))
	SetBlipSprite(blip, -523921054)
	SetBlipScale(blip, 0.2)
	Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Текущая миссия')
    ClearGpsCustomRoute()
    --[[StartGpsMultiRoute(GetHashKey("COLOR_YELLOW"), true, true)
    AddPointToGpsMultiRoute(target.x, target.y, target.z)
    SetGpsCustomRouteRender(true)]]
    StartGpsMultiRoute(6, true, true)
        
    -- Add the points
    AddPointToGpsMultiRoute(target.x, target.y, target.z)
    AddPointToGpsMultiRoute(target.x, target.y, target.z)
    AddPointToGpsMultiRoute(target.x, target.y, target.z)
    AddPointToGpsMultiRoute(target.x, target.y, target.z)
    AddPointToGpsMultiRoute(target.x, target.y, target.z)
    -- Set the route to render
	SetGpsMultiRouteRender(true)
   
end

function loadModel(model)
    RequestModel(model, true)
    --print('70', model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    --print('111')
end

function SpawnHorse(horse_model, coords)  --"A_C_HORSE_ARABIAN_WHITE"
    
    --local ped = PlayerPedId()
    local horse_model = GetHashKey("A_C_Horse_MP_Mangy_Backup")--GetHashKey("A_C_HORSE_ARABIAN_WHITE")
    local model = GetHashKey(horse_model)
  
    loadModel(horse_model)
  
    local myHorse = Citizen.InvokeNative(0xD49F9B0955C367DE, horse_model, coords.x+5, coords.y+5, coords.z, 0.0, true, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, myHorse, true)
    Citizen.InvokeNative(0x9F3480FE65DB31B5, myHorse, 0)
    Citizen.InvokeNative(0x4AD96EF928BD4F9A, horse_model)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, myHorse, 0x20359E53,true,true,true) --saddle
    Citizen.InvokeNative(0xD3A7B003ED343FD9, myHorse, 0x508B80B9,true,true,true) --blanket
    Citizen.InvokeNative(0xD3A7B003ED343FD9, myHorse, 0xF0C30271,true,true,true) --bag
    Citizen.InvokeNative(0xD3A7B003ED343FD9, myHorse, 0x12F0DF9F,true,true,true) --bedroll
    Citizen.InvokeNative(0xD3A7B003ED343FD9, myHorse, 0x67AF7302,true,true,true) --stirups
    Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, myHorse)
    --print('81 myHorse', myHorse)
    return myHorse
end

function createNPC(model, pedcoords, scenario)
    LoadModel(model)
    local npc = CreatePed(model, pedcoords.x, pedcoords.y, pedcoords.z-1.0, pedcoords.w, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    return npc
    
end

function createNPCOnMount(model, pedcoords, horse)
    LoadModel(model)
    --local npc = CreatePed(model, pedcoords.x, pedcoords.y, pedcoords.z-1.0, pedcoords.w, false, true, true, true)
    local npc = CreatePedOnMount(horse, model, -1, true, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    return npc
    
end


	