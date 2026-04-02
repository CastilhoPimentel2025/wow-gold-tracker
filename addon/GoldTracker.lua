local startGold = 0
local sessionStart = time()

-- Janela principal
local window = CreateFrame("Frame", "GoldTrackerWindow", UIParent)
window:SetSize(220, 120)
window:SetPoint("CENTER")
window:SetMovable(true)
window:EnableMouse(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", window.StartMoving)
window:SetScript("OnDragStop", window.StopMovingOrSizing)
window:SetFrameStrata("MEDIUM")

-- Fundo
local bg = window:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.8)

-- Borda dourada
local border = window:CreateTexture(nil, "BORDER")
border:SetAllPoints()
border:SetColorTexture(1, 0.8, 0, 0.6)

local inner = window:CreateTexture(nil, "BACKGROUND")
inner:SetPoint("TOPLEFT", 1, -1)
inner:SetPoint("BOTTOMRIGHT", -1, 1)
inner:SetColorTexture(0, 0, 0, 0.85)

-- Título
local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", 0, -8)
title:SetText("|cffffd700GoldTracker|r")

-- Linhas de texto
local function createLine(offsetY)
    local line = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line:SetPoint("TOPLEFT", 10, offsetY)
    line:SetWidth(200)
    line:SetJustifyH("LEFT")
    return line
end

local lineAtual = createLine(-24)
local lineGanho = createLine(-40)
local lineGasto = createLine(-56)
local linePHora = createLine(-72)

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

## Interface: 120001