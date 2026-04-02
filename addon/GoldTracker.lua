local GoldTracker = {}
local startGold = 0

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        startGold = GetMoney()

    elseif event == "PLAYER_MONEY" then
        local currentGold = GetMoney()
        local earned = currentGold - startGold

        if earned >= 0 then
            print("|cff00ff00[GoldTracker]|r Gold earned this session: "
                .. GetCoinTextureString(earned))
        else
            print("|cffff0000[GoldTracker]|r Gold spent this session: "
                .. GetCoinTextureString(math.abs(earned)))
        end
    end
end)