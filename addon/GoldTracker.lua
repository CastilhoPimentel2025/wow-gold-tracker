local sessionStart = 0
local totalEarned = 0
local totalSpent = 0
local lastGold = 0

-- Janela principal
local window = CreateFrame("Frame", "GoldTrackerWindow", UIParent)
window:SetSize(220, 120)
window:SetPoint("CENTER")
window:SetMovable(true)
window:EnableMouse(true)
window:SetClampedToScreen(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", function(self) self:StartMoving() end)
window:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
window:SetFrameStrata("MEDIUM")

-- Fundo
local bg = window:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.15, 0.15, 0.15, 0.9)

-- Borda cinza
local border = window:CreateTexture(nil, "BORDER")
border:SetAllPoints()
border:SetColorTexture(0.4, 0.4, 0.4, 1)

local inner = window:CreateTexture(nil, "BACKGROUND")
inner:SetPoint("TOPLEFT", 1, -1)
inner:SetPoint("BOTTOMRIGHT", -1, 1)
inner:SetColorTexture(0.15, 0.15, 0.15, 0.95)

-- Título
local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", 0, -8)
title:SetText("|cffffd700GoldTracker|r")

-- Linhas de texto
local function createLine(offsetY)
    local line = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
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
    local elapsed     = math.max(time() - sessionStart, 1)
    local perHour     = math.floor(totalEarned / elapsed * 3600)

    lineAtual:SetText("Atual:  " .. GetCoinTextureString(currentGold))
    lineGanho:SetText("|cff00ff00Ganho:  " .. GetCoinTextureString(totalEarned) .. "|r")
    lineGasto:SetText("|cffff0000Gasto:  " .. GetCoinTextureString(totalSpent) .. "|r")

    if perHour >= 0 then
        linePHora:SetText("|cffffff00Por hora: " .. GetCoinTextureString(perHour) .. "|r")
    else
        linePHora:SetText("|cffffff00Por hora: -" .. GetCoinTextureString(math.abs(perHour)) .. "|r")
    end
end

-- Inicializa o banco de dados
local function initDB()
    if not GoldTrackerDB then
        GoldTrackerDB = {
            totalEarned = 0,
            totalSpent  = 0,
        }
    end

    -- Carrega os dados salvos
    totalEarned = GoldTrackerDB.totalEarned
    totalSpent  = GoldTrackerDB.totalSpent
end

-- Salva no banco de dados
local function saveDB()
    GoldTrackerDB.totalEarned = totalEarned
    GoldTrackerDB.totalSpent  = totalSpent
end

-- Eventos
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        initDB()
        lastGold     = GetMoney()
        sessionStart = time()
        updateDisplay()

    elseif event == "PLAYER_ENTERING_WORLD" then
        window:Show()

    elseif event == "PLAYER_MONEY" then
        local currentGold = GetMoney()
        local diff = currentGold - lastGold

        if diff > 0 then
            totalEarned = totalEarned + diff
        else
            totalSpent = totalSpent + math.abs(diff)
        end

        lastGold = currentGold
        saveDB()
        updateDisplay()

    elseif event == "PLAYER_LOGOUT" then
        saveDB()
    end
end)

-- Comando para mostrar/esconder
SLASH_GOLDTRACKER1 = "/gold"
SlashCmdList["GOLDTRACKER"] = function(msg)
    if msg == "reset" then
        GoldTrackerDB.totalEarned = 0
        GoldTrackerDB.totalSpent  = 0
        totalEarned = 0
        totalSpent  = 0
        print("|cffffd700[GoldTracker]|r Dados resetados!")
        updateDisplay()
    elseif window:IsShown() then
        window:Hide()
    else
        window:Show()
    end
end