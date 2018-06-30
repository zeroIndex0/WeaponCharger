
WeaponCharger = WeaponCharger or {}

WeaponCharger.name = "WeaponCharger"
WeaponCharger.version = 0.1

local function WeaponChargerGetSoulGemIndex()
    for index = 0, GetBagSize(BAG_BACKPACK) do
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, index) then
			return index
		end
	end
	return nil
end

local function WeaponChargerChargeWeapons()
    local weapons = {
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF
    }
    local minimumWeaponCharge = 4
    for _, weapon in ipairs(weapons) do
        local charge, maxCharge = GetChargeInfoForItem(BAG_WORN, weapon)
        if charge <= minimumWeaponCharge and maxCharge ~= 0 then
            local soulGemIndex = WeaponChargerGetSoulGemIndex()
            if soulGemIndex == nil then d("You Do Not Have Enough Soul Gems") return end
            ChargeItemWithSoulGem(BAG_WORN, weapon, BAG_BACKPACK, soulGemIndex)
            --output the message to all tabs
            if CHAT_SYSTEM then
                if CHAT_SYSTEM.primaryContainer then
                    CHAT_SYSTEM.primaryContainer:OnChatEvent(nil, "Charged: " .. GetItemLink(BAG_WORN, weapon, LINK_STYLE_BRACKETS),  CHAT_CATEGORY_SYSTEM)
                end
            end
        end
    end
end

local function WeaponChargerInventoryUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if bagId ~= BAG_WORN then return end
    if inventoryUpdateReason == 3 then
        WeaponChargerChargeWeapons()
    end
end

local function Initialize(event, addOnName)
    -- the addOnName and the WeaponCharger.name have to match otherwise we need to stop
   if(addOnName ~= WeaponCharger.name) then return end

    --after the addon is loaded we dont need this anymore
    EVENT_MANAGER:UnregisterForEvent(WeaponCharger.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(WeaponCharger.name, EVENT_ADD_ON_LOADED, Initialize)
EVENT_MANAGER:RegisterForEvent(WeaponCharger.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WeaponChargerInventoryUpdate)