-- WoW Addon "KeyAnouncer"

-- TODO: 
-- - show partymember keys in sepperate window

local addonName, addonTable = ...
local KeyAnouncer = CreateFrame("Frame")
KeyAnouncerDB = KeyAnouncerDB or {}
-- load libs
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local informationText = "Automatic link your keystone in guild or party chat if '!keys' is typped in chat."
local isEnabled = true
local isPartyChatEnabled = true
local isGuidChatEnabled = true
local showOnLogin = false
local addonVersion = "1.2.0"
local postCooldown = 8

local lastPostTime = 0
local canPostKey = true

local windowHeight = 250
local windowWidth = 250
local minimapButtonPosition = 0
local keystone = nil

-- function to get actual time 
local function GetTimeNow()
    return time()
end

-- function to find and return players keystone
local function GetMythicKeystone()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item then
                if item and (item.itemName:find("Mythic Keystone") or item.itemName:find("Schlüsselstein")) then
                    -- print(item.hyperlink)
                    return item
                end
            end
        end
    end
    print("You have no mythic+ keystone!")
    return ""
end

-- Create Addon Window
local frame = CreateFrame("Frame", "KeyAnouncerFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(windowWidth, windowHeight)
frame:SetPoint("CENTER")
frame:Hide()

-- create DataBroker object
local dataObject = LDB:NewDataObject("KeyAnouncer",{
    type = "launcher",
    text = "KeyAnouncer",
    icon = "Interface/AddOns/KeyAnouncer/Icons/KeyAnouncerIcon.tga",
    OnClick = function (_, button)
        if button == "LeftButton" then
            if frame:IsShown() then
                frame:Hide()
            else
                frame:Show()
            end
        end
    end,
    OnTooltipShow = function (tooltip)
        tooltip:AddLine("KeyAnouncer", 1, 1, 1)
        tooltip:AddLine("Left-click to show/hide the addon window.", nil, nil, nil, true)
    end
})

-- Register minimapicon
LDBIcon:Register("KeyAnouncer", dataObject, KeyAnouncerDB.MinimapIcon)

-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMed2")
title:SetPoint("TOP", frame, "TOP", 0, -5)
title:SetText("KeyAnouncer")
title:SetTextColor(255, 0, 0, 1)

-- Informationtext
local infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoText:SetPoint("TOP", title, "TOP", 0, -30)
infoText:SetWidth(windowWidth-20)
infoText:SetWordWrap(true)
infoText:SetTextColor(255,255,255,1)
infoText:SetText(informationText)

-- Checkbox: Enable Addon
local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 2, 0) -- Reduzierter Abstand
checkbox.text:SetText("Post Keystone Automatic")
checkbox:SetChecked(KeyAnouncerDB.isEnabled)  -- Use the saved setting from KeyAnouncerDB
checkbox:SetPoint("CENTER", frame, "CENTER", -(checkbox:GetWidth()*2 + 12), 15)
checkbox:SetScript("OnClick", function(self)
    isEnabled = self:GetChecked()
    KeyAnouncerDB.isEnabled = isEnabled  -- Save the updated setting
    -- print("Checkbox clicked, isEnabled set to: " .. tostring(isEnabled))
end)

-- Checkbox: Show on Login
local loginCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
loginCheckbox:SetPoint("CENTER", checkbox, "BOTTOM", 0, -10) -- Platzierung direkt unter der ersten Checkbox
loginCheckbox.text = loginCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
loginCheckbox.text:SetPoint("LEFT", loginCheckbox, "RIGHT", 2, 0) -- Reduzierter Abstand
loginCheckbox.text:SetText("Show Settings on Login")
loginCheckbox:SetChecked(KeyAnouncerDB.showOnLogin)  -- Use the saved setting from KeyAnouncerDB
loginCheckbox:SetScript("OnClick", function(self)
    showOnLogin = self:GetChecked()
    KeyAnouncerDB.showOnLogin = showOnLogin  -- Save the updated setting
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Checkbox: enable party chat
local partyChatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
partyChatCheckbox:SetPoint("CENTER", loginCheckbox, "BOTTOM", 0, -10) 
partyChatCheckbox.text = partyChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
partyChatCheckbox.text:SetPoint("LEFT", partyChatCheckbox, "RIGHT", 2, 0) -- Reduzierter Abstand
partyChatCheckbox.text:SetText("Include Partychat")
partyChatCheckbox:SetChecked(KeyAnouncerDB.isPartyChatEnabled)  -- Use the saved setting from KeyAnouncerDB
partyChatCheckbox:SetScript("OnClick", function(self)
    isPartyChatEnabled = self:GetChecked()
    KeyAnouncerDB.isPartyChatEnabled = isPartyChatEnabled  -- Save the updated setting
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Checkbox: enable guild chat
local guildChatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
guildChatCheckbox:SetPoint("CENTER", partyChatCheckbox, "BOTTOM", 0, -10) 
guildChatCheckbox.text = guildChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
guildChatCheckbox.text:SetPoint("LEFT", guildChatCheckbox, "RIGHT", 2, 0) -- Reduzierter Abstand
guildChatCheckbox.text:SetText("Include Guildchat")
guildChatCheckbox:SetChecked(KeyAnouncerDB.isGuidChatEnabled)  -- Use the saved setting from KeyAnouncerDB
guildChatCheckbox:SetScript("OnClick", function(self)
    isGuidChatEnabled = self:GetChecked()
    KeyAnouncerDB.isPartyChatEnabled = isGuidChatEnabled  -- Save the updated setting
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Version Text
local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
versionText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
versionText:SetTextScale(0.8)
versionText:SetText('v' .. addonVersion .. " © S3R43o3 2025")

-- Register events
KeyAnouncer:RegisterEvent("CHAT_MSG_PARTY")
KeyAnouncer:RegisterEvent("CHAT_MSG_PARTY_LEADER")
KeyAnouncer:RegisterEvent("CHAT_MSG_GUILD")
KeyAnouncer:RegisterEvent("ADDON_LOADED")
KeyAnouncer:RegisterEvent("PLAYER_LOGOUT")
KeyAnouncer:RegisterEvent("PLAYER_ENTERING_WORLD")
KeyAnouncer:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" or event == "PLAYER_ENTERING_WORLD" then
        local addonName = ...
        if addonName == addonName then
            KeyAnouncerDB.MinimapIcon = KeyAnouncerDB.MinimapIcon or {hide = false}

            if KeyAnouncerDB.MinimapIcon.hide then
                LDBIcon:Hide("KeyAnouncer")
            else
                LDBIcon:Show("KeyAnouncer")
            end
            -- Lade Einstellungen, wenn das Addon geladen wurde
            isEnabled = KeyAnouncerDB.isEnabled ~= nil and KeyAnouncerDB.isEnabled or true
            showOnLogin = KeyAnouncerDB.showOnLogin ~= nil and KeyAnouncerDB.showOnLogin or true
            isPartyChatEnabled = KeyAnouncerDB.isPartyChatEnabled ~= nil and KeyAnouncerDB.isPartyChatEnabled or true
            isGuidChatEnabled = KeyAnouncerDB.isGuidChatEnabled ~= nil and KeyAnouncerDB.isGuidChatEnabled or true
            minimapButtonPosition = KeyAnouncerDB.minimapButtonPosition or 0
            checkbox:SetChecked(KeyAnouncerDB.isEnabled)  -- Lade Einstellung
            loginCheckbox:SetChecked(KeyAnouncerDB.showOnLogin)  -- Lade Einstellung
            partyChatCheckbox:SetChecked(KeyAnouncerDB.isPartyChatEnabled)
            guildChatCheckbox:SetChecked(KeyAnouncerDB.isGuidChatEnabled)
            -- UpdateMinimapButtonPosition()
            if KeyAnouncerDB.showOnLogin == true then
                frame:Show()
            else
                frame:Hide()
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        -- Speichern der Einstellungen
        KeyAnouncerDB.isEnabled = isEnabled
        KeyAnouncerDB.showOnLogin = showOnLogin
        KeyAnouncerDB.isPartyChatEnabled = isPartyChatEnabled
        KeyAnouncerDB.minimapButtonPosition = minimapButtonPosition
        KeyAnouncerDB.isGuidChatEnabled = isGuidChatEnabled
    elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_GUILD" then
        -- Chat-Nachricht verarbeiten
        local message, sender = ...
        if not isEnabled then
            return
        end
        if message == "!keys" then
            local now = GetTimeNow()
            if now - lastPostTime < postCooldown then
                local remaining = postCooldown - (now - lastPostTime)
                return
            end
            keystone = GetMythicKeystone()
            if keystone ~= "" then
                if event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
                    if not isPartyChatEnabled then
                        return
                    end
                    SendChatMessage(keystone.hyperlink, "PARTY")
                elseif event == "CHAT_MSG_GUILD" then
                    if not isGuidChatEnabled then
                        return
                    end
                    SendChatMessage(keystone.hyperlink, "GUILD")
                end
                lastPostTime = now
            else
                -- print("No keystone found!")
                return
            end
        end
    end
end)
