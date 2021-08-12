if AZP == nil then AZP = {} end
if AZP.BagsAndBank == nil then AZP.BagsAndBank = {} end
if AZP.BagsAndBank.event == nil then AZP.BagsAndBank.event = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BagsAndBank"] = 4

local usedContainerItem = false
local AZPUISelfFrame, EventFrame = nil, nil

function AZP.BagsAndBank:OnLoad()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("LOOT_CLOSED")
    EventFrame:RegisterEvent("CHAT_MSG_LOOT")
    EventFrame:RegisterEvent("LOOT_OPENED")
    EventFrame:RegisterEvent("LOOT_READY")
    EventFrame:SetScript("OnEvent", function(...) AZP.BagsAndBank:OnEvent(...) end)

    AZPUISelfFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    AZPUISelfFrame:SetSize(150, 60)
    AZPUISelfFrame:SetPoint("CENTER", 0, 0)
    AZPUISelfFrame:SetScript("OnDragStart", AZPUISelfFrame.StartMoving)
    AZPUISelfFrame:SetScript("OnDragStop", function()
        AZPUISelfFrame:StopMovingOrSizing()
        --AZP.BagsAndBank:SaveMainFrameLocation()
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

    AZPUISelfFrame.counter = AZPUISelfFrame:CreateFontString("AZPUISelfFrame", "ARTWORK", "GameFontNormalLarge")
    AZPUISelfFrame.counter:SetSize(125, 25)
    AZPUISelfFrame.counter:SetPoint("TOPLEFT", AZPUISelfFrame, "TOPLEFT", 5, -5)
    AZPUISelfFrame.counter:SetText("WordsHere")

    AZPUISelfFrame.openButton = CreateFrame("Button", nil, AZPUISelfFrame, "UIPanelButtonTemplate")
    AZPUISelfFrame.openButton:SetPoint("BOTTOM", AZPUISelfFrame, "BOTTOM", 0, 7)
    AZPUISelfFrame.openButton:SetSize(125, 25)
    AZPUISelfFrame.openButton:SetText("Open Next Container!")
    AZPUISelfFrame.openButton:SetScript("OnClick", function() AZP.BagsAndBank:SelectNextItem() end)

    AZPUISelfFrame.closeButton = CreateFrame("Button", nil, AZPUISelfFrame, "UIPanelCloseButton")
    AZPUISelfFrame.closeButton:SetSize(20, 21)
    AZPUISelfFrame.closeButton:SetPoint("TOPRIGHT", AZPUISelfFrame, "TOPRIGHT", 2, 2)
    AZPUISelfFrame.closeButton:SetScript("OnClick", function() AZP.BagsAndBank:ShowHideFrame() end )
end

function AZP.BagsAndBank:SelectNextItem()
    for i = 0, 4 do
        for j = 0, 40 do
            local itemID = GetContainerItemID(i, j)
            if itemID ~= nil then
                if AZP.BagsAndBank.itemIDs[itemID] ~= nil then
                    UseContainerItem(i, j)
                    usedContainerItem = true
                    return true
                end
            end
        end
    end
end

function AZP.BagsAndBank.event:VariablesLoaded()
    AZP.BagsAndBank:GetUseItemCount()
end

function AZP.BagsAndBank:GetUseItemCount()
    local useItemCounter = 0
    for i = 0, 4 do
        for j = 0, 40 do
            local itemID = GetContainerItemID(i, j)
            if itemID ~= nil then
                if AZP.BagsAndBank.itemIDs[itemID] ~= nil then
                    useItemCounter = useItemCounter + 1
                end
            end
        end
    end
    AZPUISelfFrame.counter:SetText("Containers Found: " .. useItemCounter)
end

function AZP.BagsAndBank.event:ChatMsgLoot(...)
    local itemTable = AZP.BagsAndBank.itemIDs
    local _, inputText, inputPlayer = ...
    local playerName, playerServer = UnitFullName("Player")
    if inputPlayer == (playerName) or inputPlayer == (playerName .. "-" .. playerServer) then
        local itemID = select(3, strsplit(":", inputText))
        if itemTable[itemID] ~= nil or usedContainerItem then
            C_Timer.After(3, function() AZP.BagsAndBank:GetUseItemCount() end)
            usedContainerItem = false
        end
    end
end

function AZP.BagsAndBank:OnEvent(_, ...)
    local event = ...
    if event == "VARIABLES_LOADED" then
        AZP.BagsAndBank.event:VariablesLoaded()
    elseif event == "CHAT_MSG_LOOT" then
        AZP.BagsAndBank.event:ChatMsgLoot(...)
    end
end

function AZP.BagsAndBank:ShowHideFrame()
    if AZPUISelfFrame:IsShown() then
        AZPUISelfFrame:Hide()
    elseif not AZPUISelfFrame:IsShown() then
        AZPUISelfFrame:Show()
    end
end

AZP.BagsAndBank:OnLoad()

AZP.SlashCommands["BagsAndBank"] = function ()
    AZP.BagsAndBank:ShowHideFrame()
end