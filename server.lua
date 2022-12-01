Core = {}

_VORP = exports.vorp_core:vorpAPI()

VORP = exports.vorp_inventory:vorp_inventoryApi()
TriggerEvent("getCore",function(core)
    VorpCore = core
end)


_VORP.addNewCallBack("firsJob:server:checkbucket", function(source, cb, item)
    local src = source
    local empty = VORP.getItemCount(src, 'bucket_100')
    print('empty', empty)
	if empty > 0 then
        cb(true)
    else
        TriggerClientEvent("c_notify_client_new", src, 'Вам нужно ведро с водой', 'error', 3000)
        cb(false)
    end
end)

_VORP.addNewCallBack("firsJob:server:checkminimapProp", function(source, cb)
    local src = source
    local property = {
        mapTypeOnFoot = _VORP.Get_mapTypeOnFoot,
        mapTypeOnMount = _VORP.Get_mapTypeOnMount
    }
    cb(property)
end)



RegisterServerEvent('firsJob:server:getJob')
AddEventHandler('firsJob:server:getJob', function()
    local src = source
    VORP.addItem(src, "empty_bucket", 1)
    TriggerClientEvent("c_notify_client_new", src, 'Вы получили пустое ведро', 'success', 3000)
	TriggerClientEvent("firsJob:client:getJob", src)
end)


RegisterServerEvent('firstJob:server:checkWater')
AddEventHandler('firstJob:server:checkWater', function()
    local src = source
    local empty = VORP.getItemCount(src, 'bucket_100')
	if empty > 0 then
		TriggerClientEvent("firstJob:client:checkedWater", src)
	else
		TriggerClientEvent("c_notify_client_new", src, 'Вам нужно ведро с водой', 'error', 3000)
    end
end)


RegisterServerEvent('firsJob:server:ChangeBuckets')
AddEventHandler('firsJob:server:ChangeBuckets', function()
    local src = source
    local empty = VORP.getItemCount(src, 'bucket_100')
	if empty > 0 then
        VORP.addItem(src, "empty_bucket", 1)
        VORP.subItem(src, "bucket_100", 1)
		TriggerClientEvent("firstJob:client:checkedWater", src)
        TriggerClientEvent("c_notify_client_new", src, 'Ведро снова пусто', 'normal', 3000)
	else
		TriggerClientEvent("c_notify_client_new", src, 'Вам нужно ведро с водой', 'error', 3000)
    end
end)

RegisterServerEvent('firsJob:server:pay')
AddEventHandler('firsJob:server:pay', function()
    local src = source
    TriggerEvent("vorp:addMoney", src, 0, Config.price)
    TriggerClientEvent("c_notify_client_new", src, 'Миссия успешно завершена. Вы получили обещанные $' ..Config.price, 'success', 3000)
    
end)




