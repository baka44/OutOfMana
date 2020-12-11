local ConfigFrame = CreateFrame("Frame")
ConfigFrame:RegisterEvent("ADDON_LOADED")
ConfigFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
ConfigFrame:RegisterEvent("UNIT_AURA")

ConfigFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if LevelOfManaToWarnOOM == nil then
          WarningsEnabledOOM = true -- Enable/Disable chat messages
          LevelOfManaToWarnOOM = 10 -- How many percent of mana is low?
          LevelOfManaIsOkOOM = 85 -- How many percent of mana is ok after restoration mana
          IsWarningWasActivatedOOM = false --  Default false. If warning was activated - become true until mana level >= LevelOfManaIsOkOOM
        end
    elseif event == "UNIT_SPELLCAST_SENT" then
      powerType, powerTypeString = UnitPowerType("player")
      if powerTypeString == "MANA" then
      inParty = IsInGroup()
      if WarningsEnabledOOM == true and inParty then
        local MaxMana = UnitPowerMax("player")
        local CurrentMana = UnitPower("player")
        if IsWarningWasActivatedOOM == false then
          if (MaxMana/100)*LevelOfManaToWarnOOM >= CurrentMana then
            local inParty = UnitInParty("player")
            local ct = "PARTY";
            local inRaid = UnitInRaid("player")
            if inRaid then
              ct = "RAID";
            end
            SendChatMessage("My mana is low!",ct);
            DoEmote("oom","none")
            IsWarningWasActivatedOOM = true
          end
        end
      end
    end
    elseif event == "UNIT_AURA" then
      powerType, powerTypeString = UnitPowerType("player")
      if powerTypeString == "MANA" then
      inParty = IsInGroup()
      if WarningsEnabledOOM == true and inParty then
        if IsWarningWasActivatedOOM == true then
          local MaxMana = UnitPowerMax("player")
          local CurrentMana = UnitPower("player")
          if (MaxMana/100)*LevelOfManaIsOkOOM <= CurrentMana then
            local inParty = UnitInParty("player")
            local ct = "PARTY";
            local inRaid = UnitInRaid("player")
            if inRaid then
              ct = "RAID";
            end
            SendChatMessage("My mana is ok now",ct);
            DoEmote("ready","none")
            IsWarningWasActivatedOOM = false
          end
        end
      end
    end
  end
end)

SLASH_OUTOFMANA1 = "/om"
function SlashCmdList.OUTOFMANA(msg)
    if WarningsEnabledOOM == true then
     print("Warnings about your mana level is |cFFFF0000disabled|r.")
     print("To enable it type |cffffcc00/om|r.")
     WarningsEnabledOOM = false
   elseif WarningsEnabledOOM == false then
     print("Warnings about your mana level is |cFF00FF00enabled|r.")
     print("To disable it type |cffffcc00/om|r.")
     WarningsEnabledOOM = true
    end
end
