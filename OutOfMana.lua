local ConfigFrame = CreateFrame("Frame")

ConfigFrame:RegisterEvent("ADDON_LOADED")
ConfigFrame:RegisterEvent("UNIT_POWER_UPDATE")
ConfigFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
ConfigFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function InitDefaults()
    if WarningsEnabledOOM == nil then
        WarningsEnabledOOM = true
        LevelOfManaToWarnOOM = 10
        LevelOfManaIsOkOOM = 85
        IsWarningWasActivatedOOM = false
    end
end

local function ShouldWarn()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end

    return instanceType == "party" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena"
end

local function Warn(message, emote)
    SendChatMessage(message, "SAY")
    if emote then
        DoEmote(emote, "none")
    end
end

local function HandleManaChange()
    if not WarningsEnabledOOM or not ShouldWarn() then return end

    local powerType = select(2, UnitPowerType("player"))
    if powerType ~= "MANA" then return end

    local maxMana = UnitPowerMax("player", 0)
    if maxMana == 0 then return end

    local currentMana = UnitPower("player", 0)
    local percent = (currentMana / maxMana) * 100

    if not IsWarningWasActivatedOOM and percent <= LevelOfManaToWarnOOM then
        Warn("My mana is low!", "oom")
        IsWarningWasActivatedOOM = true
    elseif IsWarningWasActivatedOOM and percent >= LevelOfManaIsOkOOM then
        Warn("My mana is ok now", "ready")
        IsWarningWasActivatedOOM = false
    end
end

ConfigFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "OutOfMana" then
        InitDefaults()
    elseif event == "UNIT_POWER_UPDATE" and arg1 == "player" then
        HandleManaChange()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        IsWarningWasActivatedOOM = false
    end
end)

SLASH_OUTOFMANA1 = "/om"
function SlashCmdList.OUTOFMANA(msg)
    if WarningsEnabledOOM then
        print("|cFFFF0000[OOM]|r Warnings disabled.")
        WarningsEnabledOOM = false
    else
        print("|cFF00FF00[OOM]|r Warnings enabled.")
        WarningsEnabledOOM = true
    end
end
