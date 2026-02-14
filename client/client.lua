

local missionActive = false
local doctorList = {}
local startOxyRunPed

local getPharmacies = math.random(1, #Config.PharmacyLocations)
local selectPharmacy = Config.PharmacyLocations[getPharmacies]

local startOxyRun = lib.points.new(
    Config.StartOxyRunLocation,
    Config.StartOxyRunPedRadius
)

---------------------------------------------------------
-- RESOURCE CLEANUP
---------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and startOxyRunPed then
        DeleteEntity(startOxyRunPed)
    end
end)

---------------------------------------------------------
-- PED SPAWN
---------------------------------------------------------

local function spawnStartOxyRunPed()
    lib.requestModel(Config.startOxyRunPedModel)

    startOxyRunPed = CreatePed(
        0,
        Config.startOxyRunPedModel,
        Config.StartOxyRunLocation,
        Config.StartOxyRunPedHeading,
        false,
        true
    )

    FreezeEntityPosition(startOxyRunPed, true)
    SetBlockingOfNonTemporaryEvents(startOxyRunPed, true)
    SetEntityInvincible(startOxyRunPed, true)

    Entity(startOxyRunPed).state:set('sellDrugs', true, true)
end

---------------------------------------------------------
-- START MISSION
---------------------------------------------------------

local function startOxyRunDialog()

    if missionActive then
        return lib.notify({
            title = Config.Notifications.startOxyRunPedName,
            description = Config.Notifications.startOxyRunAlreadyStarted,
            type = 'error'
        })
    end

    local alert = lib.alertDialog({
        header = Config.AlertDialog.startOxyRunHeader,
        content = Config.AlertDialog.startOxyRunContent,
        centered = true,
        cancel = true
    })

    if alert ~= 'confirm' then return end

    local price = Config.BlankPrescriptionPrice

    if Config.RandomBlankPrescriptionPricing then
        price = math.random(Config.MinBlankPrescriptionPrice, Config.MaxBlankPrescriptionPrice)
    end

    local confirm = lib.alertDialog({
        header = Config.AlertDialog.startOxyRunPart2Header,
        content = Config.AlertDialog.startOxyRunPart2Content .. price .. ' sound?',
        centered = true,
        cancel = true
    })

    if confirm ~= 'confirm' then return end

    local success = lib.callback.await('lation_oxyrun:startOxyRun', false, price)

    if success then
        missionActive = true
    else
        lib.notify({
            title = Config.Notifications.startOxyRunPedName,
            description = "You don't have enough money.",
            type = 'error'
        })
    end
end

---------------------------------------------------------
-- NPC TARGET
---------------------------------------------------------

local startOxyRunOptions = {
    {
        name = 'startOxyRun',
        icon = Config.Target.startOxyRunIcon,
        label = Config.Target.startOxyRunLabel,
        distance = 2,
        onSelect = function()
            startOxyRunDialog()
        end
    }
}

function startOxyRun:onEnter()
    spawnStartOxyRunPed()
    exports.ox_target:addLocalEntity(startOxyRunPed, startOxyRunOptions)
end

function startOxyRun:onExit()
    if startOxyRunPed then
        exports.ox_target:removeLocalEntity(startOxyRunPed)
        DeleteEntity(startOxyRunPed)
    end
end

---------------------------------------------------------
-- PHARMACY TARGET (THIS WAS MISSING)
---------------------------------------------------------

exports.ox_target:addSphereZone({
    coords = selectPharmacy,
    radius = 2,
    debug = false,
    options = {
        {
            name = 'randomPharmacy',
            icon = Config.Target.fillScriptIcon,
            label = Config.Target.fillScriptLabel,
            canInteract = function()
                return missionActive
            end,
            onSelect = function()

                local hasItem = lib.callback.await(
                    'lation_oxyrun:hasItem',
                    false,
                    Config.SignedPerscription
                )

                if (hasItem or 0) < 1 then
                    return lib.notify({
                        title = Config.Notifications.pharmacyTitle,
                        description = Config.Notifications.pharmacyItemNotFound,
                        type = 'error'
                    })
                end

                local finished = lib.progressCircle({
                    label = Config.ProgressCircle.checkingScriptLabel,
                    duration = Config.ProgressCircle.checkingScriptDuration,
                    position = Config.ProgressCircle.position,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true }
                })

                if not finished then return end

                lib.callback.await('lation_oxyrun:getItemMetadata', false)
                missionActive = false
            end
        }
    }
})

---------------------------------------------------------
-- DOCTOR LIST
---------------------------------------------------------

local doctorList = {}
for k, v in pairs(Config.DoctorNames) do
    doctorList[k] = {
        title = v,
        icon = Config.ContextMenu.availableDoctorsIcon,
        onSelect = function()
            lib.setClipboard(v)

            lib.notify({
                title = 'Name Copied',
                description = 'Doctor\'s name has been copied down',
                position = 'top',
                icon = Config.Target.availableDoctorsIcon,
            })

        end
    }
end

exports.ox_target:addSphereZone({
    coords = Config.AvailableDoctorListLocation,
    radius = 2,
    debug = false,
    options = {
        {
            name = 'availableDoctors',
            icon = Config.Target.availableDoctorsIcon,
            label = Config.Target.availableDoctors,
            onSelect = function()
                lib.registerContext({
                    id = 'availableDoctorsMenu',
                    title = Config.ContextMenu.availableDoctorsMenuTitle,
                    options = doctorList,
                })

                lib.showContext('availableDoctorsMenu')
            end
        }
    }
})


---------------------------------------------------------
-- CLIENT CALLBACKS
---------------------------------------------------------

lib.callback.register('lation_oxyrun:fillPrescriptionInfo', function()
    return lib.inputDialog(Config.InputDialog.header, {
        {type = 'input', label = Config.InputDialog.nameLabel, required = true},
        {type = 'input', label = Config.InputDialog.addressLabel, required = true},
        {type = 'checkbox', label = Config.InputDialog.firstCheckboxLabel},
        {type = 'checkbox', label = Config.InputDialog.secondCheckboxLabel},
        {type = 'date', label = Config.InputDialog.dobLabel, required = true},
        {type = 'input', label = Config.InputDialog.doctorLabel, required = true}
    })
end)

lib.callback.register('lation_oxyrun:fakeScript', function()
    lib.alertDialog({
        header = Config.AlertDialog.fakeScriptHeader,
        content = Config.AlertDialog.fakeScriptContent,
        centered = true
    })
end)

lib.callback.register('lation_oxyrun:openOxyBottle', function()
    return lib.progressCircle({
        label = Config.ProgressCircle.openOxyBottleLabel,
        duration = Config.ProgressCircle.openOxyBottleDuration,
        canCancel = true
    })
end)

lib.callback.register('lation_oxyrun:useOxycontin', function()
    local playerPed = PlayerPedId()

    local animDict = "mp_suicide" 
    local animName = "pill"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, Config.ProgressCircle.poppingOxyDuration, 49, 0, false, false, false)

    return lib.progressCircle({
        label = Config.ProgressCircle.poppingOxyLabel,
        duration = Config.ProgressCircle.poppingOxyDuration, -- ideally 2500
        position = 'bottom',
        canCancel = false,
        onFinish = function()
            ClearPedTasks(playerPed)
        end,
        onCancel = function()
            ClearPedTasks(playerPed)
        end
    })
end)

lib.callback.register('lation_oxyrun:setPedHealth', function()
    SetEntityHealth(cache.ped, Config.EnableEffects.health.amount or 200)
end)

lib.callback.register('lation_oxyrun:setPedArmor', function()
    local currentArmor = GetPedArmour(cache.ped)
    local armorAmount = Config.EnableEffects.armor.amount or 0

    if Config.EnableEffects.armor.stack then
        local newArmor = currentArmor + armorAmount
        if newArmor > 100 then newArmor = 100 end
        SetPedArmour(cache.ped, newArmor)
    else
        if currentArmor < armorAmount then
            SetPedArmour(cache.ped, armorAmount)
        end
    end
end)
