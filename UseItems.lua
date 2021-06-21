if AZP == nil then AZP = {} end
if AZP.UseItems == nil then AZP.UseItems = {} end
if AZP.UseItems.event == nil then AZP.UseItems.event = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["UseItems"] = 5

local usedContainerItem = false
local AZPUISelfFrame, EventFrame = nil, nil

function AZP.UseItems:OnLoad()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("LOOT_CLOSED")
    EventFrame:RegisterEvent("CHAT_MSG_LOOT")
    EventFrame:RegisterEvent("LOOT_OPENED")
    EventFrame:RegisterEvent("LOOT_READY")
    EventFrame:SetScript("OnEvent", function(...) AZP.UseItems:OnEvent(...) end)

    AZPUISelfFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    AZPUISelfFrame:SetSize(150, 75)
    AZPUISelfFrame:SetPoint("CENTER", 0, 0)
    AZPUISelfFrame:SetScript("OnDragStart", AZPUISelfFrame.StartMoving)
    AZPUISelfFrame:SetScript("OnDragStop", function()
        AZPUISelfFrame:StopMovingOrSizing()
        --AZP.UseItems:SaveMainFrameLocation()
    end)
    AZPUISelfFrame:RegisterForDrag("LeftButton")
    AZPUISelfFrame:EnableMouse(true)
    AZPUISelfFrame:SetMovable(true)
    AZPUISelfFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    AZPUISelfFrame:SetBackdropColor(0.5, 0.5, 0.5, 0.75)

    AZPUISelfFrame:Show()

    AZPUISelfFrame.closeButton = CreateFrame("Button", nil, AZPUISelfFrame, "UIPanelCloseButton")
    AZPUISelfFrame.closeButton:SetSize(20, 21)
    AZPUISelfFrame.closeButton:SetPoint("TOPRIGHT", AZPUISelfFrame, "TOPRIGHT", 2, 2)
    AZPUISelfFrame.closeButton:SetScript("OnClick", function() AZP.UseItems:ShowHideFrame() end )

    AZPUISelfFrame.openButton = CreateFrame("Button", nil, AZPUISelfFrame, "UIPanelButtonTemplate")
    AZPUISelfFrame.openButton:SetPoint("TOPLEFT", AZPUISelfFrame, "TOPLEFT", 5, -5)
    AZPUISelfFrame.openButton:SetSize(100, 25)
    AZPUISelfFrame.openButton:SetText("Open Container!")
    AZPUISelfFrame.openButton:SetScript("OnClick", function() AZP.UseItems:SelectNextItem() end)

    AZPUISelfFrame.counter = AZPUISelfFrame:CreateFontString("AZPUISelfFrame", "ARTWORK", "GameFontNormalLarge")
    AZPUISelfFrame.counter:SetSize(150, 50)
    AZPUISelfFrame.counter:SetPoint("BOTTOMLEFT", AZPUISelfFrame, "BOTTOMLEFT", 5, -5)
    AZPUISelfFrame.counter:SetText("WordsHere")
end

function AZP.UseItems:SelectNextItem()
    for i = 0, 4 do
        for j = 0, 40 do
            local itemID = GetContainerItemID(i, j)
            if itemID ~= nil then
                if AZP.UseItems.itemIDs[itemID] ~= nil then
                    print(itemID, AZP.UseItems.itemIDs[itemID][1])
                    UseContainerItem(i, j)
                    usedContainerItem = true
                    return true
                end
            end
        end
    end
end

function AZP.UseItems.event:VariablesLoaded()
    AZP.UseItems:GetUseItemCount()
end

function AZP.UseItems:GetUseItemCount()
    local useItemCounter = 0
    print("useItemCounter inFunction:", useItemCounter)
    for i = 0, 4 do
        for j = 0, 40 do
            local itemID = GetContainerItemID(i, j)
            if itemID ~= nil then
                if AZP.UseItems.itemIDs[itemID] ~= nil then
                    useItemCounter = useItemCounter + 1
                end
            end
        end
    end
    print("useItemCounter endFunction:", useItemCounter)
    AZPUISelfFrame.counter:SetText("Containers Found: " .. useItemCounter)
end

function AZP.UseItems.event:ChatMsgLoot(...)
    local itemTable = AZP.UseItems.itemIDs
    local _, inputText, inputPlayer = ...
    local playerName, playerServer = UnitFullName("Player")
    if inputPlayer == (playerName) or inputPlayer == (playerName .. "-" .. playerServer) then
        local itemID = select(3, strsplit(":", inputText))
        print(inputPlayer, itemID, inputText)
        if itemTable[itemID] ~= nil or usedContainerItem then
            C_Timer.After(3, function() AZP.UseItems:GetUseItemCount() end)
            usedContainerItem = false
        end
    end
end

function AZP.UseItems:OnEvent(_, ...)
    local event = ...
    if event == "VARIABLES_LOADED" then
        AZP.UseItems.event:VariablesLoaded()
    elseif event == "CHAT_MSG_LOOT" then
        print("CHAT_MSG_LOOT Event!")
        AZP.UseItems.event:ChatMsgLoot(...)
    end
end

function AZP.UseItems:ShowHideFrame()
    if AZPUISelfFrame:IsShown() then
        AZPUISelfFrame:Hide()
    elseif not AZPUISelfFrame:IsShown() then
        AZPUISelfFrame:Show()
    end
end

AZP.UseItems:OnLoad()

AZP.SlashCommands["useItems"] = function ()
    AZP.UseItems:ShowHideFrame()
end