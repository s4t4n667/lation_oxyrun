Config = {}

Config.Debug = true

---------------------------------------------------------
-- FRAMEWORK
---------------------------------------------------------

Config.UseInventoryMoney = true
Config.InventoryMoneyItem = 'money'
Config.AccountMoneyType = 'cash'

---------------------------------------------------------
-- DOCTOR NAMES
---------------------------------------------------------

Config.DoctorNames = {
    'Dr. Khantgetard',
    'Dr. Sirpeeslot',
    'Dr. Seuss',
    'Dr. Doalot',
    'Dr. Likspeen',
    'Dr. Docraak',
    'Dr. Harrysak',
    'Dr. Pepper'
}

---------------------------------------------------------
-- PHARMACY LOCATIONS
---------------------------------------------------------

Config.PharmacyLocations = {
    vec3(1142.1522, -451.8326, 66.9843),
    vec3(69.2566, -1570.2457, 29.5978),
    vec3(98.4244, -226.2621, 54.6374),
    vec3(114.2634, -4.5923, 67.8195),
    vec3(237.7168, -26.7896, 69.8964),
    vec3(213.6084, -1835.6198, 27.5606)
}

---------------------------------------------------------
-- GENERAL SETTINGS
---------------------------------------------------------

Config.startOxyRunPedModel = 'g_m_y_ballaeast_01'
Config.StartOxyRunLocation = vec3(246.7493, 370.7164, 104.7381)
Config.StartOxyRunPedHeading = 120.6238
Config.StartOxyRunPedRadius = 45

Config.BlankPrescription = 'blank_prescription'
Config.SignedPerscription = 'signed_prescription'

Config.BlankPrescriptionRewardAmount = 1
Config.BlankPrescriptionPrice = 2000

Config.RandomBlankPrescriptionPricing = true
Config.MinBlankPrescriptionPrice = 1500
Config.MaxBlankPrescriptionPrice = 3500

Config.RequireItem = false
Config.RequireItemName = 'water'
Config.RequireItemAmount = 5

Config.OxyBottleItem = 'oxy_bottle'
Config.OxyBottleQuantity = 1

Config.OxyPillItem = 'oxycontin'
Config.OxyPillQuantity = 15

Config.AvailableDoctorListLocation = vec3(343.1629, -1399.8206, 32.5092)

---------------------------------------------------------
-- EFFECTS
---------------------------------------------------------

Config.EnableEffects = {
    enable = true,
    health = {
        enable = true,
        amount = 200
    },
    armor = {
        enable = false,
        amount = 100
    }
}

---------------------------------------------------------
-- WEBHOOK
---------------------------------------------------------

Config.EnableWebhook = false
Config.WebhookLink = ''
Config.WebhookName = 'ServerName'
Config.WebhookAvatarIcon = ''
Config.WebhookFooterIcon = ''

---------------------------------------------------------
-- UI / TEXT
---------------------------------------------------------

Config.Notifications = {
    position = 'top',
    icon = 'capsules',
    pharmacyTitle = 'Pharmacy',
    pharmacyDescription = 'You cancelled filling the script',
    pharmacyItemNotFound = 'There is nothing here for you - try again later',
    startOxyRunPedName = 'Aaron',
    startOxyRunCancelDescription = 'Come back whenever you are ready',
    startOxyRunPart2CancelDescription = 'Quit messin\' with me man, I don\'t have time for this..',
    startOxyRunDidntHaveItemDescription = 'I got nothing for you man, leave me alone.',
    startOxyRunAlreadyStarted = 'I just hooked you up bro - use what you got and then we\'ll talk again.',
    oxyBottleTitle = 'Oxy Bottle',
    oxyBottleDescription = 'You changed your mind and kept the bottle closed',
    oxycontinTitle = 'Oxycontin',
    oxycontinDescription = 'You changed your mind and didn\'t take it'
}

Config.Target = {
    startOxyRunLabel = 'Talk',
    startOxyRunIcon = 'fas fa-comment',
    availableDoctors = 'View available Doctors',
    availableDoctorsIcon = 'fas fa-user-doctor',
    fillScriptLabel = 'Fill script',
    fillScriptIcon = 'fas fa-capsules'
}

Config.ContextMenu = {
    availableDoctorsMenuTitle = 'Today\'s Doctors',
    availableDoctorsIcon = 'user-doctor'
}

Config.ProgressCircle = {
    position = 'middle',
    checkingScriptLabel = 'Checking script..',
    checkingScriptDuration = 15000,
    openOxyBottleLabel = 'Opening bottle..',
    openOxyBottleDuration = 4000,
    poppingOxyLabel = 'Popping oxy..',
    poppingOxyDuration = 2000
}

Config.AlertDialog = {
    startOxyRunHeader = 'Aaron',
    startOxyRunContent = 'Whats up man, you need one of them \'scripts? I\'ll hook you up but be careful with these. If you get caught, it wasn\'t from me..',
    startOxyRunPart2Header = 'Aaron',
    startOxyRunPart2Content = 'Alright man, let\'s do it. I need some cash though.. this stuff doesn\'t come easy. How\'s $',
    fakeScriptHeader = 'Doctor',
    fakeScriptContent = 'This is fraudulent! I will not fill this for you.'
}

Config.InputDialog = {
    header = 'Fill Prescription Information',
    nameLabel = 'Name',
    addressLabel = 'Address',
    firstCheckboxLabel = 'Nonacute Pain',
    secondCheckboxLabel = 'Acute Pain Exception',
    dobLabel = 'Date of Birth',
    doctorLabel = 'Doctor Signature'
}
