
ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


function HasPharmaJob()
    local playerJob = ESX.GetPlayerData().job.name 
    return playerJob == Config.PharmaJob
end

function isBoss()
    local playerJobGrade  = ESX.GetPlayerData().job.grade_name 
    return playerJobGrade == "boss"
end


for location, data in pairs(Config.Pharmacy.Locations) do
    lib.zones.box({
        coords = data.pos,
        size = vec3(1, 1, 1),
        rotation = 0,
        debug = true, 
        inside = function(self)
            if location == "Tray2" then
                lib.showTextUI(data.text)

                if IsControlJustReleased(0, 38) then 
                    TriggerEvent('eth-pharmacy:getJobActions', location)
                end
            elseif HasPharmaJob() then
                lib.showTextUI(data.text)

                if IsControlJustReleased(0, 38) then
                    if location == "MedicineCabinet"  then
                        TriggerEvent('eth-pharmacy:getJobActions', location)
                    elseif location == "PublicStash" then
                        TriggerEvent('eth-pharmacy:getJobActions', location)
                    elseif location == "Tray1"  then
                        TriggerEvent('eth-pharmacy:getJobActions', location)
                    elseif location == "BossAction" then
                        if not isBoss() then return end
                        TriggerEvent('eth-pharmacy:getJobActions', location)
                    elseif location == "BossStash" then
                        if not isBoss() then return end
                        TriggerEvent('eth-pharmacy:getJobActions', location)
                    elseif location == "PaymentCashier" or location == "StoreCashier" then
                        TriggerEvent('eth-pharmacy:getJobActions', location)
                    end
                end
            else
                lib.hideTextUI()
            end
        end,
        onExit = function(self)
            lib.hideTextUI()
        end
    })
end




RegisterNetEvent('eth-pharmacy:getJobActions')
AddEventHandler('eth-pharmacy:getJobActions', function(action)
    if not HasPharmaJob then return end
    if action == "PublicStash" then
        exports.ox_inventory:openInventory('stash', {id='pharmacy-stash-1'})
    elseif action == "Tray1" then
        exports.ox_inventory:openInventory('stash', {id='pharmacy-tray-1'})
    elseif action == "Tray2"  then
        exports.ox_inventory:openInventory('stash', {id='pharmacy-tray-1'})
    elseif action == "MedicineCabinet" then
        exports.ox_inventory:openInventory('stash', {id='pharma_medcabinet'})
    elseif action == "BossAction" then
        TriggerEvent('esx_society:openBossMenu', Config.PharmaJob)
    elseif action == "BossStash" then
        exports.ox_inventory:openInventory('stash', {id='pharmacy-boss-1'})
    elseif action == "StoreCashier" then
       CreateReceipt(Config.PharmaJob)
    elseif action == "PaymentCashier" then
        OpenReceiptMenu(Config.PharmaJob)
    end
end)


RegisterNetEvent('eth-pharmacy:GetPrescriptions')
AddEventHandler('eth-pharmacy:GetPrescriptions', function(inventory, slot , itemMetaData)
    if lib.progressBar({
        duration = 25000, 
        label = 'Getting medicine from cabinet',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = 'mp_common', 
            clip = 'givetake1_a'  
        }
    }) then 
        TriggerServerEvent('eth-pharmacy:ReceivePrescriptions' , inventory , slot ,itemMetaData)
    else 
        print('Action cancelled')
    end
end)


function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end



--- CASHIER 


RegisterNetEvent('eth-pharmacy:cashierActions')
AddEventHandler('eth-pharmacy:cashierActions', function(object)
    if object.action == "CreateReceipt" then
        local inputData = lib.inputDialog("Create Receipt", {
            { type = 'input', label = "Receipt Label", required = true }, 
            { type = 'number', label = "Receipt Amount", required = true }
        })
        
        if not inputData then return end
        
        local label = inputData[1] 
        local amount = tonumber(inputData[2])
        TriggerServerEvent('eth-pharmacy:addCashierBill', amount, label) 
    elseif object.action == "ReceiptMenu" then     
        local SendMenu = {
            {
                title = "Receipt Menu",
                description = '',
                icon = 'fas fa-file-invoice-dollar',
                disabled = true
            }
        }
        
        local data = lib.callback.await('eth-pharmacy:getAvailableBills', false)
        if not data then
            Notify({
                title = 'Pharmacy',
                description = 'Create a bill first!',
                type = 'error',
                duration = 5000
            })
            return
        end
        

        for i = 1, #data do
            local theData = data[i]
            SendMenu[#SendMenu + 1] = {
                title = theData.title,
                description = "Amount: $" .. ESX.Math.GroupDigits(theData.amount) ,
                icon = 'fas fa-list',
                disabled = true 
            }
        end
        
        SendMenu[#SendMenu + 1] = {
            title = "Close",
            description = '',
            icon = 'fas fa-times',
            event = 'ox_lib:closeMenu' 
        }
        

        lib.registerContext({
            id = 'receipt_menu',
            title = 'Receipt Menu',
            options = SendMenu
        })
        
        lib.showContext('receipt_menu')
    elseif object.action == 'pay' then
        local moneyCount = exports.ox_inventory:Search('count', 'money')
        if moneyCount >= object.amount then
            TriggerServerEvent('eth-pharmacy:payCashierBill', object.value, object.amount, object.biller)
        else
            Notify({ title = 'Pharmacy', description = 'You don\'t have enough money.', duration = 5000 ,type = 'error', })
        end   
    end
end)


function CreateReceipt(shop)
    local menuOptions = {
        {
            title = "Cashier Menu",
            disabled = true
        },
        {
            title = "Create a receipt",
            description = "Create a receipt",
            icon = 'fas fa-file-invoice-dollar',
            onSelect = function()
                TriggerEvent("eth-pharmacy:cashierActions", { action = "CreateReceipt" })
            end
        },
        {
            title = "Open Receipt Menu",
            description = "Open the receipt menu",
            icon = 'fas fa-list',
            onSelect = function()
                TriggerEvent("eth-pharmacy:cashierActions", { action = 'ReceiptMenu' })
            end
        }
    }

    lib.registerContext({
        id = 'create_receipt_menu',
        title = 'Receipt Menu',
        options = menuOptions
    })
    
    lib.showContext('create_receipt_menu')
end


function OpenReceiptMenu(shop)
    local menuOptions = {}

    local data = lib.callback.await('eth-pharmacy:getAvailableBills', false, shop)
    
    if not data then
        Notify({
            title = 'Pharmacy',
            description = 'Create a bill first!',
            type = 'error',
            duration = 5000,
        })
        return
    end

    table.insert(menuOptions, {
        title = "Receipt Menu",
        disabled = true
    })

    for i = 1, #data do
        local theData = data[i]
        table.insert(menuOptions, {
            title = theData.title,
            description = "Amount: $" .. ESX.Math.GroupDigits(theData.amount),
            icon = 'fas fa-list',
            onSelect = function()
                TriggerEvent("eth-pharmacy:cashierActions", {
                    action = 'pay',
                    biller = theData.biller,
                    amount = theData.amount,
                    shop = shop,
                    value = i
                })
            end
        })
    end

    -- Add close option
    table.insert(menuOptions, {
        title = "Close",
        onSelect = function()
            lib.hideContext()
        end
    })

    lib.registerContext({
        id = 'receipt_menu',
        title = 'Receipt Menu',
        options = menuOptions
    })
    
    lib.showContext('receipt_menu')
end

-- -- Blips Creation
Citizen.CreateThread(function()
    -- Ensure the MedicineCabinet location and position are defined in the configuration
    if Config.Pharmacy and Config.Pharmacy.Locations["MedicineCabinet"] and Config.Pharmacy.Locations["MedicineCabinet"].pos then
        local blipPos = Config.Pharmacy.Locations["MedicineCabinet"].pos
        local blip = AddBlipForCoord(blipPos.x, blipPos.y, blipPos.z)
        
        -- Set up the blip's appearance and behavior
        SetBlipSprite(blip, 403) 
        SetBlipScale(blip, 0.6) 
        --SetBlipAsShortRange(blip, true) 
        SetBlipColour(blip, 3)  
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Pharmacy") 
        EndTextCommandSetBlipName(blip)
    else
        print("Error: Pharmacy location or position not defined in Config.")
    end
end)


---- NOTIFY 

function Notify(data)
    ESX.ShowNotification(data.type,data.duration, data.description, data.title)
end


RegisterNetEvent('eth-pharmacy:Notify')
AddEventHandler('eth-pharmacy:Notify', function(data)
    Notify(data)
end)