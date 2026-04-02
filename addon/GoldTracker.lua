GoldTracker = {}

local startGold = GetMoney()

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", function()
    local currentGold = GetMoney()
    local earned = currentGold - startGold

    print("Gold earned this session: " ..
        GetCoinTextureString(earned))
end)