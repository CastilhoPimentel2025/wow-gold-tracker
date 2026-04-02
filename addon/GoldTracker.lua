local startGold = 0
local sessionStart = time()

-- Janela principal
local window = CreateFrame("Frame", "GoldTrackerWindow", UIParent, "BackdropTemplate")
window:SetSize(220, 120)
window:SetPoint("CENTER")
window:SetMovable(true)
window:EnableMouse(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", window.StartMoving)
window:SetScript("OnDragStop", window.StopMovingOrSizing)
window:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})
window:SetBackdropColor(0, 0, 0, 0.8)
window:SetBackdropBorderColor(1, 0.8, 0, 1)

-- Título
local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", 0, -8)
title:SetText("|cffffd700GoldTracker|r")

-- Linhas de texto
local function createLine(_, offsetY)
    local line = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line:SetPoint("TOPLEFT", 10, offsetY)
    line:SetWidth(200)
    line:SetJustifyH("LEFT")
    return line
end

local lineAtual = createLine(window, -24)
local lineGanho = createLine(window, -40)
local lineGasto = createLine(window, -56)
local linePHora = createLine(window, -72)

-- Atualiza a janela
local function updateDisplay()
    local currentGold = GetMoney()
    local earned      = currentGold - startGold
    local elapsed     = math.max(time() - sessionStart, 1)
    local perHour     = math.floor(earned / elapsed * 3600)

    lineAtual:SetText("Atual:  " .. GetCoinTextureString(currentGold))

    if earned >= 0 then
        lineGanho:SetText("|cff00ff00Ganho:  " .. GetCoinTextureString(earned) .. "|r")
        lineGasto:SetText("|cffff0000Gasto:  " .. GetCoinTextureString(0) .. "|r")
    else
        lineGanho:SetText("|cff00ff00Ganho:  " .. GetCoinTextureString(0) .. "|r")
        lineGasto:SetText("|cffff0000Gasto:  " .. GetCoinTextureString(math.abs(earned)) .. "|r")
    end

    if perHour >= 0 then
        linePHora:SetText("|cffffff00/hora: " .. GetCoinTextureString(perHour) .. "|r")
    else
        linePHora:SetText("|cffffff00/hora: -" .. GetCoinTextureString(math.abs(perHour)) .. "|r")
    end
end

-- Eventos
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        if startGold == 0 then
            startGold    = GetMoney()
            sessionStart = time()
            updateDisplay()
        end
    elseif event == "PLAYER_MONEY" then
        updateDisplay()
    end
end)

-- Comando para mostrar/esconder
SLASH_GOLDTRACKER1 = "/gold"
SlashCmdList["GOLDTRACKER"] = function()
    if window:IsShown() then
        window:Hide()
    else
        window:Show()
    end
end