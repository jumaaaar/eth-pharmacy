local swapHook
local ox_inventory = exports.ox_inventory
local PharmacyBills = {}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
       for k,v in pairs(Config.Pharmacy.Stash) do 
            ox_inventory:RegisterStash(v.id, v.label, v.slots, v.maxWeight, v.owner)
       end
    end
end)

CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(1000)
    end
    swapHook = exports.ox_inventory:registerHook('swapItems', function(payload)
        print(json.encode(payload))
        if payload.toInventory == "pharma_medcabinet" then
            local itemMetaData = payload.fromSlot
            if itemMetaData.name == Config.PrescriptionItem then
                TriggerClientEvent('eth-pharmacy:GetPrescriptions', payload.source, payload.toInventory, payload.toSlot , itemMetaData)
            end
        end
    end, {})
end)

RegisterServerEvent('eth-pharmacy:ReceivePrescriptions')
AddEventHandler('eth-pharmacy:ReceivePrescriptions', function(inventory , slot , item)
    exports.ox_inventory:RemoveItem(inventory, 'prescription', 1, nil, slot)
    exports.ox_inventory:AddItem(inventory, item.metadata.invitem, item.metadata.quantity, nil, slot)
end)



RegisterServerEvent('eth-pharmacy:addCashierBill')
AddEventHandler('eth-pharmacy:addCashierBill', function(curAmount, curTitle)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

 

    if PharmacyBills ~= nil then
        table.insert(PharmacyBills,{
            title = curTitle, 
            amount = curAmount, 
            biller = xPlayer.identifier
        })
    else
        PharmacyBills = {}
        table.insert(PharmacyBills,{
            title = curTitle, 
            amount = curAmount, 
            biller = xPlayer.identifier
        })
    end
    TriggerClientEvent('eth-pharmacy:Notify', xPlayer.source, {type = 'success', duration = 5000, title = 'Pharmacy', description = 'You created a bill.', sound = true})
end)

RegisterCommand("pays",function()
    print(json.encode(PharmacyBills))
end)

lib.callback.register('eth-pharmacy:getAvailableBills', function(source)
    if PharmacyBills ~= nil then
        return PharmacyBills
    else
        PharmacyBills = {}
        return false
    end
end)

RegisterServerEvent('eth-pharmacy:payCashierBill')
AddEventHandler('eth-pharmacy:payCashierBill', function(curId, curAmount, biller)
    local xPlayer = ESX.GetPlayerFromId(source)
    if PharmacyBills ~= nil then
        for k, v in pairs(PharmacyBills) do
            if k == curId then
                table.remove(PharmacyBills, k)
            end
        end
    end
    local SocietyCut = curAmount * 1
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.PharmaJob, function(account) account.addMoney(SocietyCut) end)
    ox_inventory:RemoveItem(xPlayer.source, 'money', curAmount)
    TriggerClientEvent('eth-pharmacy:Notify', xPlayer.source, {type = 'success', duration = 5000, title = 'Pharmacy', description = 'You paid $'..ESX.Math.GroupDigits(curAmount), sound = true})
end)
