local ox_inventory = exports.ox_inventory

---@type table<number, table>
local pendingPrescriptions = {}

local function dbg(msg)
    print(('[lation_oxyrun] %s'):format(msg))
end

---------------------------------------------------------
-- ITEM COUNT
---------------------------------------------------------

lib.callback.register('lation_oxyrun:hasItem', function(source, item)
    return ox_inventory:Search(source, 'count', item) or 0
end)

---------------------------------------------------------
-- START MISSION (PAY + GIVE BLANK PRESCRIPTION)
---------------------------------------------------------

lib.callback.register('lation_oxyrun:startOxyRun', function(source, price)
    price = tonumber(price) or 0

    if price <= 0 then
        dbg(('startOxyRun invalid price src=%s price=%s'):format(source, price))
        return false
    end

    if Config.UseInventoryMoney then
        local moneyItem = Config.InventoryMoneyItem or 'money'
        local removed = ox_inventory:RemoveItem(source, moneyItem, price)

        if not removed then
            dbg(('startOxyRun failed removeItem src=%s item=%s amount=%s'):format(source, moneyItem, price))
            return false
        end
    else
        local Player = exports.qbx_core:GetPlayer(source)
        if not Player then
            dbg(('startOxyRun no player src=%s'):format(source))
            return false
        end

        local moneyType = Config.AccountMoneyType or 'cash'
        local ok = Player.Functions.RemoveMoney(moneyType, price, 'lation_oxyrun')

        if not ok then
            dbg(('startOxyRun failed RemoveMoney src=%s type=%s amount=%s'):format(source, moneyType, price))
            return false
        end
    end

    local added = ox_inventory:AddItem(source, Config.BlankPrescription, Config.BlankPrescriptionRewardAmount or 1)

    if not added then
        dbg(('startOxyRun failed AddItem src=%s item=%s'):format(source, Config.BlankPrescription))
        return false
    end

    dbg(('startOxyRun SUCCESS src=%s price=%s'):format(source, price))
    return true
end)

---------------------------------------------------------
-- VALIDATE SCRIPT + REWARD BOTTLE
---------------------------------------------------------

lib.callback.register('lation_oxyrun:getItemMetadata', function(source)
    local inputData = pendingPrescriptions[source]

    if not inputData then
        dbg(('getItemMetadata no pending src=%s'):format(source))
        return false
    end

    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then
        dbg(('getItemMetadata no player src=%s'):format(source))
        return false
    end

    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    local function clean(str)
        return string.lower((str or ''):gsub('[^%w]', ''))
    end

    ---------------------------------------------------------
    -- DEBUG OUTPUT
    ---------------------------------------------------------

    dbg("===== PRESCRIPTION DEBUG =====")
    dbg("Character Name: " .. playerName)
    dbg("Typed Name: " .. tostring(inputData[1]))
    dbg("Typed Doctor: " .. tostring(inputData[6]))
    dbg("Checkbox (Acute Pain): " .. tostring(inputData[4]))
    dbg("================================")

    ---------------------------------------------------------
    -- DOCTOR VALIDATION (ANY CONFIG DOCTOR ALLOWED)
    ---------------------------------------------------------

    local doctorValid = false

    for _, doctor in ipairs(Config.DoctorNames) do
        if clean(doctor) == clean(inputData[6]) then
            doctorValid = true
            break
        end
    end

    ---------------------------------------------------------
    -- FRAUD CHECK
    ---------------------------------------------------------

    local isFraud =
        clean(playerName) ~= clean(inputData[1]) or
        not doctorValid or
        not inputData[4]

    ox_inventory:RemoveItem(source, Config.SignedPerscription, 1)

    if isFraud then
        dbg("Prescription marked FRAUDULENT")
        lib.callback.await('lation_oxyrun:fakeScript', source)
        pendingPrescriptions[source] = nil
        return false
    end

    dbg("Prescription VALID - giving bottle")

    ox_inventory:AddItem(source, Config.OxyBottleItem, Config.OxyBottleQuantity or 1)
    pendingPrescriptions[source] = nil

    return true
end)

---------------------------------------------------------
-- ITEM USAGE HANDLER
---------------------------------------------------------

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)

    if name == Config.BlankPrescription then
        dbg(('usedItem blank_prescription src=%s slot=%s'):format(playerId, slotId))

        local inputData = lib.callback.await('lation_oxyrun:fillPrescriptionInfo', playerId)
        if not inputData then return end

        pendingPrescriptions[playerId] = inputData

        ox_inventory:RemoveItem(playerId, Config.BlankPrescription, 1)

        local newMetadata = {
            patient = inputData[1],
            address = inputData[2],
            acute = inputData[4],
            doctor = inputData[6],
        }

        ox_inventory:AddItem(playerId, Config.SignedPerscription, 1, newMetadata)
        return
    end

    if name == Config.OxyBottleItem then
        dbg(('usedItem oxy_bottle src=%s slot=%s'):format(playerId, slotId))

        local opened = lib.callback.await('lation_oxyrun:openOxyBottle', playerId)
        if not opened then return end

        ox_inventory:RemoveItem(playerId, Config.OxyBottleItem, 1)
        ox_inventory:AddItem(playerId, Config.OxyPillItem, Config.OxyPillQuantity or 1)
        return
    end

    if name == Config.OxyPillItem then
        dbg(('usedItem oxycontin src=%s slot=%s'):format(playerId, slotId))

        local used = lib.callback.await('lation_oxyrun:useOxycontin', playerId)
        if not used then return end

        ox_inventory:RemoveItem(playerId, Config.OxyPillItem, 1)

        if Config.EnableEffects and Config.EnableEffects.enable then
            if Config.EnableEffects.health and Config.EnableEffects.health.enable then
                lib.callback.await('lation_oxyrun:setPedHealth', playerId)
            end
            if Config.EnableEffects.armor and Config.EnableEffects.armor.enable then
                lib.callback.await('lation_oxyrun:setPedArmor', playerId)
            end
        end
    end
end)
