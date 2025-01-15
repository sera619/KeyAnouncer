--[[
    WoW Addon "KeyAnouncer"
    Send your mythic+ keystone automaticly in guild or party chat.
    
    
    TODOs: 
    - partymember keys in sepperate window

]]

local addonName, addonTable = ...
local KeyAnouncer = CreateFrame("Frame")
KeyAnouncerDB = KeyAnouncerDB or {}
-- load libs
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local informationText = "Automatic link your keystone in guild or party chat if '!keys' is typped in chat."
local addonVersion = "1.2.4"
local postCooldown = 8
local lastPostTime = 0
local windowHeight = 250
local windowWidth = 250
local keystone = nil

-- function to get actual time 
local function GetTimeNow()
    return time()
end

-- settings
local defaultSettings = {
    isEnabled = true,
    showOnLogin = true,
    isGuildChatEnabled = true,
    isPartyChatEnabled = true,
    MinimapIcon = {hide = false }
}

local function SaveSettings()
    for key in pairs(defaultSettings) do
        KeyAnouncerDB[key] = KeyAnouncerDB[key]
    end
end

local function LoadSettings()
    for key, value in pairs(defaultSettings) do
        if KeyAnouncerDB[key] == nil then
            KeyAnouncerDB[key] = value
        end
    end
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
checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
checkbox.text:SetText("Post Keystone Automatic")
checkbox:SetPoint("CENTER", frame, "CENTER", -(checkbox:GetWidth()*2 + 12), 15)
checkbox:SetScript("OnClick", function(self)
    KeyAnouncerDB.isEnabled = self:GetChecked()  -- Save the updated setting
    -- print("Checkbox clicked, isEnabled set to: " .. tostring(isEnabled))
end)

-- Checkbox: Show on Login
local loginCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
loginCheckbox:SetPoint("CENTER", checkbox, "BOTTOM", 0, -10)
loginCheckbox.text = loginCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
loginCheckbox.text:SetPoint("LEFT", loginCheckbox, "RIGHT", 2, 0)
loginCheckbox.text:SetText("Show Settings on Login")
loginCheckbox:SetScript("OnClick", function(self)
    KeyAnouncerDB.showOnLogin = self:GetChecked()
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Checkbox: enable party chat
local partyChatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
partyChatCheckbox:SetPoint("CENTER", loginCheckbox, "BOTTOM", 0, -10) 
partyChatCheckbox.text = partyChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
partyChatCheckbox.text:SetPoint("LEFT", partyChatCheckbox, "RIGHT", 2, 0)
partyChatCheckbox.text:SetText("Include Partychat")
partyChatCheckbox:SetScript("OnClick", function(self)
    KeyAnouncerDB.isPartyChatEnabled = self:GetChecked()
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Checkbox: enable guild chat
local guildChatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
guildChatCheckbox:SetPoint("CENTER", partyChatCheckbox, "BOTTOM", 0, -10) 
guildChatCheckbox.text = guildChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
guildChatCheckbox.text:SetPoint("LEFT", guildChatCheckbox, "RIGHT", 2, 0)
guildChatCheckbox.text:SetText("Include Guildchat")
guildChatCheckbox:SetScript("OnClick", function(self)
    KeyAnouncerDB.isGuidChatEnabled = self:GetChecked()
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
    if event == "ADDON_LOADED" then
    -- or event == "PLAYER_ENTERING_WORLD"
        local addonName = ...
        if addonName == addonName then
            -- load savedvariables on addon load
            LoadSettings()
            checkbox:SetChecked(KeyAnouncerDB.isEnabled)  -- Lade Einstellung
            loginCheckbox:SetChecked(KeyAnouncerDB.showOnLogin)  -- Lade Einstellung
            partyChatCheckbox:SetChecked(KeyAnouncerDB.isPartyChatEnabled)
            guildChatCheckbox:SetChecked(KeyAnouncerDB.isGuidChatEnabled)
            if KeyAnouncerDB.MinimapIcon.hide then
                LDBIcon:Hide("KeyAnouncer")
            else
                LDBIcon:Show("KeyAnouncer")
            end
            if KeyAnouncerDB.showOnLogin == true then
                frame:Show()
            else
                frame:Hide()
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        -- save settings
        SaveSettings()
    elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_GUILD" then
        -- post keystone 
        local message, sender = ...
        if not KeyAnouncerDB.isEnabled then
            return
        end
        if message == "!keys" then
            local now = GetTimeNow()
            if now - lastPostTime < postCooldown then
                -- local remaining = postCooldown - (now - lastPostTime)
                return
            end
            keystone = GetMythicKeystone()
            if keystone ~= "" then
                if event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
                    if not KeyAnouncerDB.isPartyChatEnabled then
                        return
                    end
                    SendChatMessage(keystone.hyperlink, "PARTY")
                elseif event == "CHAT_MSG_GUILD" then
                    if not KeyAnouncerDB.isGuidChatEnabled then
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
