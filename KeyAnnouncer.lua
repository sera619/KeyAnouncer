--[[
    WoW Addon "KeyAnnouncer"
    Send your mythic+ keystone automaticly in guild or party chat.
    
    
    TODOs: 
    - partymember keys in sepperate window

]]

local addonName = "KeyAnnouncer"
local KeyAnnouncer = CreateFrame("Frame")
KeyAnnouncerDB = KeyAnnouncerDB or {}
-- load libs
local LDBIcon = LibStub:GetLibrary("LibDBIcon-1.0", true)
local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)

local informationText = "Automatically link your M+ keystone in the group/guild chat when “!keys” is written in the chat."
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version")
local postCooldown = 8
local lastPostTime = 0
local windowHeight = 275
local windowWidth = 250
local acceptedKeystoneID = 180653
local groupKeystones = {}
local keystone = nil

-- settings
local defaultSettings = {
    isEnabled = true,
    showOnLogin = true,
    isGuildChatEnabled = true,
    isPartyChatEnabled = true,
    MinimapIcon = {hide = false, minimapPos = 120 },
    framePosition = nil,
    groupKeystonesFramePosition = nil,
}

-- function to get actual time 
local function GetTimeNow()
    return time()
end

local function SaveSettings()
    for key in pairs(defaultSettings) do
        KeyAnnouncerDB[key] = KeyAnnouncerDB[key]
    end
end

local function LoadSettings()
    for key, value in pairs(defaultSettings) do
        if KeyAnnouncerDB[key] == nil then
            KeyAnnouncerDB[key] = value
        end
    end
end

local function SaveFramePosition(frame, positionKey)
    local point, _, relativePoint, xOffset, yOffset = frame:GetPoint()
    KeyAnnouncerDB[positionKey] = {point = point, relativePoint =  relativePoint, xOffset = xOffset, yOffset = yOffset}
end

local function LoadFramePosition(frame, positionKey, defaultPoint)
    local position = KeyAnnouncerDB[positionKey]
    if position then
        frame:SetPoint(position.point, UIParent, position.relativePoint, position.xOffset, position.yOffset)
    else
        frame:SetPoint(unpack(defaultPoint))
    end
end

-- function to find and return players keystone
local function GetMythicKeystone()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item then
                if item.itemID == acceptedKeystoneID then
                    -- print(item.hyperlink)
                    return item
                end
            end
        end
    end
    print("You have no mythic+ keystone!")
    return ""
end

-- function to send key via addon
local function AnnounceMyKey()
    local key = GetMythicKeystone()
    if key ~= "" then
        C_ChatInfo.SendAddonMessage("KeyAnnouncer", key.hyperlink, "PARTY")
    end
end

-- Create Addon Window
local frame = CreateFrame("Frame", "KeyAnnouncerFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(windowWidth, windowHeight)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveFramePosition(self, "framePosition")
end)
frame:Hide()

-- groupKeystones window
local groupKeystonesFrame = CreateFrame("Frame", "KeyAnnouncerPartyFrame", UIParent, "BasicFrameTemplateWithInset")
groupKeystonesFrame:SetSize(450, 200)
groupKeystonesFrame:SetPoint("TOP", 0, -10)
groupKeystonesFrame:SetMovable(true)
groupKeystonesFrame:EnableMouse(true)
groupKeystonesFrame:RegisterForDrag("LeftButton")
groupKeystonesFrame:SetScript("OnDragStart", groupKeystonesFrame.StartMoving)
groupKeystonesFrame:SetScript("OnDragStop", function (self)
    self:StopMovingOrSizing()
    SaveFramePosition(self, "groupKeystonesFramePosition")
end)
groupKeystonesFrame:Hide()

local groupKeystonesTitle = groupKeystonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMed2")
groupKeystonesTitle:SetPoint("TOP", groupKeystonesFrame, "TOP", 0, -5)
groupKeystonesTitle:SetText("KeyAnnouncer - Groupkeys")
groupKeystonesTitle:SetTextColor(255, 0, 0, 1)

-- scroll frame for party window
local partyScrollFrame = CreateFrame("ScrollFrame", nil, groupKeystonesFrame, "UIPanelScrollFrameTemplate")
partyScrollFrame:SetPoint("TOPLEFT", 0, -30)
partyScrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

local partyFrameContent = CreateFrame("Frame", nil, partyScrollFrame)
partyFrameContent:SetSize(450, 400)
partyScrollFrame:SetScrollChild(partyFrameContent)

-- key text
local keyText = partyFrameContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
keyText:SetWidth(450)
keyText:SetPoint("TOPLEFT", 0, 0)
keyText:SetWordWrap(true)
keyText:SetText("No keys available yet.")

local function UpdateGroupFrame()
    local displayText = ""

    for player, key in pairs(groupKeystones) do
        if key then
            displayText = displayText .. player .. ": " .. key .. "\n"
        else
            displayText = displayText .. player .. ": No Keystone\n"
        end
    end
    keyText:SetText(displayText ~= "" and displayText or "No keys available yet.\nFeature is in beta.")
end

local function UpdateOwnKeystone()
    local name = UnitName('player')
    local realm = GetRealmName()
    local fullName = name .. "-" .. realm
    local key = GetMythicKeystone()
    if key ~= "" then
        groupKeystones[fullName] = key.hyperlink
    else
        groupKeystones[fullName] = "No Keystone"
    end
end

local function UpdateGroupMembers()
    table.wipe(groupKeystones)
    local numGroupMembers = GetNumGroupMembers()
    if numGroupMembers < 1 then
        UpdateOwnKeystone()
    else
        for i = 1, numGroupMembers do
            local name, realm = UnitName("party"..i)
            if name then
                local fullName = realm and (name.. "-" ..realm) or name
                groupKeystones[fullName] = nil
            end
        end
    end
    UpdateGroupFrame()
end


-- create DataBroker object
local dataObject = LDB:NewDataObject("KeyAnnouncer",{
    type = "launcher",
    text = "KeyAnnouncer",
    icon = "Interface/AddOns/KeyAnnouncer/Icons/KeyAnnouncerIcon.tga",
    OnClick = function (_, button)
        if button == "LeftButton" then
            if frame:IsShown() then
                frame:Hide()
            else
                frame:Show()
            end
        elseif button == "RightButton" then
            if groupKeystonesFrame:IsShown() then
                groupKeystonesFrame:Hide()
            else
                groupKeystonesFrame:Show()
            end
        end
    end,
    OnTooltipShow = function (tooltip)
        tooltip:AddLine("KeyAnnouncer", 1, 1, 1)
        tooltip:AddLine(" ", nil, nil, nil, true)
        tooltip:AddLine("Left-click to show/hide the addon window.", nil, nil, nil, true)
        tooltip:AddLine("Right-click to show/hide groupkeystones window.", nil, nil, nil, true)
    end
})
LDBIcon:Register("KeyAnnouncer", dataObject, KeyAnnouncerDB.MinimapIcon)




-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMed2")
title:SetPoint("TOP", frame, "TOP", 0, -5)
title:SetText("KeyAnnouncer")
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
checkbox:SetPoint("CENTER", infoText, "CENTER", -(checkbox:GetWidth()*2 + 12), -40)
checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
checkbox.text:SetText("Post Keystone Automatic")
checkbox:SetScript("OnClick", function(self)
    KeyAnnouncerDB.isEnabled = self:GetChecked()  -- Save the updated setting
    -- print("Checkbox clicked, isEnabled set to: " .. tostring(isEnabled))
end)

-- Checkbox: Show on Login
local loginCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
loginCheckbox:SetPoint("CENTER", checkbox, "BOTTOM", 0, -10)
loginCheckbox.text = loginCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
loginCheckbox.text:SetPoint("LEFT", loginCheckbox, "RIGHT", 2, 0)
loginCheckbox.text:SetText("Show Settings on Login")
loginCheckbox:SetScript("OnClick", function(self)
    KeyAnnouncerDB.showOnLogin = self:GetChecked()
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Checkbox: enable party chat
local partyChatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
partyChatCheckbox:SetPoint("CENTER", loginCheckbox, "BOTTOM", 0, -10) 
partyChatCheckbox.text = partyChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
partyChatCheckbox.text:SetPoint("LEFT", partyChatCheckbox, "RIGHT", 2, 0)
partyChatCheckbox.text:SetText("Include Partychat")
partyChatCheckbox:SetScript("OnClick", function(self)
    KeyAnnouncerDB.isPartyChatEnabled = self:GetChecked()
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- Checkbox: enable guild chat
local guildChatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
guildChatCheckbox:SetPoint("CENTER", partyChatCheckbox, "BOTTOM", 0, -10) 
guildChatCheckbox.text = guildChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
guildChatCheckbox.text:SetPoint("LEFT", guildChatCheckbox, "RIGHT", 2, 0)
guildChatCheckbox.text:SetText("Include Guildchat")
guildChatCheckbox:SetScript("OnClick", function(self)
    KeyAnnouncerDB.isGuildChatEnabled = self:GetChecked()
    -- print("Login Checkbox clicked, showOnLogin set to: " .. tostring(showOnLogin))
end)

-- show/hide partyframe button
local partyFrameButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
partyFrameButton:SetPoint("CENTER", frame, "CENTER", 0, -100) 
partyFrameButton:SetText("Partykeystones")
partyFrameButton:SetScript("OnClick", function(self)
    if groupKeystonesFrame:IsShown() then
        groupKeystonesFrame:Hide()
    else
        groupKeystonesFrame:Show()
    end
end)

-- Version Text
local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
versionText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
versionText:SetTextScale(0.8)
versionText:SetText('v' .. addonVersion .. " © S3R43o3 2025")


-- Register events
KeyAnnouncer:RegisterEvent("CHAT_MSG_PARTY")
KeyAnnouncer:RegisterEvent("CHAT_MSG_PARTY_LEADER")
KeyAnnouncer:RegisterEvent("CHAT_MSG_GUILD")
KeyAnnouncer:RegisterEvent("ADDON_LOADED")
KeyAnnouncer:RegisterEvent("PLAYER_LOGOUT")
KeyAnnouncer:RegisterEvent("PLAYER_ENTERING_WORLD")
KeyAnnouncer:RegisterEvent("GROUP_ROSTER_UPDATE")
KeyAnnouncer:RegisterEvent("PLAYER_ENTERING_WORLD")
KeyAnnouncer:RegisterEvent("CHAT_MSG_ADDON")
C_ChatInfo.RegisterAddonMessagePrefix("KeyAnnouncer")
KeyAnnouncer:SetScript("OnEvent", function(self, event, prefix, message, channel, sender, ...)
    if event == "ADDON_LOADED" then
    -- or event == "PLAYER_ENTERING_WORLD"
        local addonName = ...
        if addonName == addonName then
            -- load savedvariables on addon load
            LoadSettings()
            -- Register minimapicon
            LoadFramePosition(frame, "framePosition", {"CENTER", 0, 0})
            LoadFramePosition(groupKeystonesFrame, "groupKeystonesFramePosition", {"TOP", 0, -10})
            checkbox:SetChecked(KeyAnnouncerDB.isEnabled)
            loginCheckbox:SetChecked(KeyAnnouncerDB.showOnLogin)
            partyChatCheckbox:SetChecked(KeyAnnouncerDB.isPartyChatEnabled)
            guildChatCheckbox:SetChecked(KeyAnnouncerDB.isGuildChatEnabled)
            if KeyAnnouncerDB.MinimapIcon.hide then
                LDBIcon:Hide("KeyAnnouncer")
            else
                LDBIcon:Show("KeyAnnouncer")
            end
            if KeyAnnouncerDB.showOnLogin == true then
                frame:Show()
            else
                frame:Hide()
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        -- save settings
        SaveSettings()

    elseif event == "CHAT_MSG_ADDON" and prefix == "KeyAnnouncer" then
        local playerName = Ambiguate(sender, "short")
        groupKeystones[playerName] = message
        UpdateGroupFrame()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        UpdateGroupMembers()
        AnnounceMyKey()
    elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_GUILD" then
        -- post keystone 
        local now = GetTimeNow()
        if not KeyAnnouncerDB.isEnabled then
            return
        end
        if message == "!keys" or prefix == "!keys" then
            keystone = GetMythicKeystone()
            if now - lastPostTime < postCooldown then
                -- local remaining = postCooldown - (now - lastPostTime)
                return
            end
            if keystone and keystone ~= "" then
                if event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
                    if not KeyAnnouncerDB.isPartyChatEnabled then
                        return
                    end
                    SendChatMessage(keystone.hyperlink, "PARTY")
                elseif event == "CHAT_MSG_GUILD" then
                    if not KeyAnnouncerDB.isGuildChatEnabled then
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
