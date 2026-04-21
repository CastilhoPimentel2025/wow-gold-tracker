local sessionStart = 0
local totalEarned = 0
local totalSpent = 0
local lastGold = 0
local historyVisible = false

-- Janela principal
local window = CreateFrame("Frame", "GoldTrackerWindow", UIParent, "BackdropTemplate")
window:SetSize(220, 120)
window:SetPoint("CENTER")
window:SetMovable(true)
window:EnableMouse(true)
window:SetClampedToScreen(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", function(self) self:StartMoving() end)
window:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, _, _, x, y = self:GetPoint()

    GoldTrackerDB.windowPosition = {
        point = point,
        x = x,
        y = y
    }
end)
window:SetFrameStrata("MEDIUM")
-- Restaurar posição salva
if GoldTrackerDB and GoldTrackerDB.windowPosition then
    local pos = GoldTrackerDB.windowPosition

    window:ClearAllPoints()
    window:SetPoint(
        pos.point,
        UIParent,
        pos.point,
        pos.x,
        pos.y
    )
end
-- Botão fechar padrão do WoW
local closeBtn = CreateFrame(
    "Button",
    nil,
    window,
    "UIPanelCloseButton"
)

closeBtn:SetPoint("TOPRIGHT", 0, 0)

-- Fundo estilo WoW
window:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})

-- Transparência leve
window:SetBackdropColor(0, 0, 0, 0.8)

-- Título
local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", 0, -8)
title:SetFontObject("GameFontHighlight")
title:SetText("|TInterface\\MoneyFrame\\UI-GoldIcon:16:16|t |cffffd700GoldTracker|r")
title:SetShadowOffset(1, -1)

-- Botão de histórico
local histBtn = CreateFrame("Button", nil, window)
histBtn:SetSize(16, 16)
histBtn:SetPoint("TOPRIGHT", -6, -6)
local histBtnText = histBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
histBtnText:SetAllPoints()
histBtnText:SetText("|cffffd700≡|r")

-- Linhas principais
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

-- Linhas do histórico (5 sessões x 2 linhas cada)
local histLines = {}
for i = 1, 5 do
    local header = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 10, -120 - ((i - 1) * 36))
    header:SetWidth(200)
    header:SetJustifyH("LEFT")

    local detail = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail:SetPoint("TOPLEFT", 10, -132 - ((i - 1) * 36))
    detail:SetWidth(200)
    detail:SetJustifyH("LEFT")

    histLines[i] = { header = header, detail = detail }
    header:Hide()
    detail:Hide()
end

-- Atualiza histórico na janela
local function updateHistory()
    local history = GoldTrackerHistory.getHistory()
    for i = 1, 5 do
        if history[i] then
            local s = history[i]
            local mins = math.floor(s.duration / 60)
            histLines[i].header:SetText(
                "|cffaaaaaa[" .. s.date .. "] " .. mins .. " min|r")
            histLines[i].detail:SetText(
                "|cff00ff00+" .. GetCoinTextureString(s.earned) ..
                "|r  |cffff0000-" .. GetCoinTextureString(s.spent) .. "|r")
            histLines[i].header:Show()
            histLines[i].detail:Show()
        else
            histLines[i].header:Hide()
            histLines[i].detail:Hide()
        end
    end
end

-- Atualiza a janela principal
local function updateDisplay()
    local currentGold = GetMoney()

    lineAtual:SetText("Atual:  " .. GetCoinTextureString(currentGold))
    lineGanho:SetText("|cff00ff00Ganho: |r" ..GetCoinTextureString(totalEarned))
    lineGasto:SetText("|cffff0000Spent: |r" ..GetCoinTextureString(totalSpent))

end
-- Toggle histórico
histBtn:SetScript("OnClick", function()
    historyVisible = not historyVisible
    if historyVisible then
        window:SetSize(220, 310)
        histBtnText:SetText("|cffaaaaaa▲|r")
        updateHistory()
    else
        window:SetSize(220, 100)
        histBtnText:SetText("|cffaaaaaa▼|r")
        for i = 1, 5 do
            histLines[i].header:Hide()
            histLines[i].detail:Hide()
        end
    end
end)

-- Inicializa o banco de dados
local function initDB()
    if not GoldTrackerDB then
        GoldTrackerDB = {
            totalEarned = 0,
            totalSpent  = 0,
            history     = {},
        }
    end
    totalEarned = GoldTrackerDB.totalEarned
    totalSpent  = GoldTrackerDB.totalSpent
end

-- Salva sessão atual
local function saveSession()
    local duration = time() - sessionStart
    GoldTrackerHistory.saveSession(totalEarned, totalSpent, duration)
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
        saveSession()
        updateDisplay()

    elseif event == "PLAYER_LOGOUT" then
        saveSession()
    end
end)

-- Comandos
SLASH_GOLDTRACKER1 = "/gold"
SlashCmdList["GOLDTRACKER"] = function(msg)
    if msg == "reset" then
        GoldTrackerDB.totalEarned = 0
        GoldTrackerDB.totalSpent  = 0
        GoldTrackerDB.history     = {}
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