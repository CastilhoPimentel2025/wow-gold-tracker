GoldTrackerHistory = {}

-- Salva a sessão atual no histórico
function GoldTrackerHistory.saveSession(earned, spent, duration)
    if not GoldTrackerDB.history then
        GoldTrackerDB.history = {}
    end

    local session = {
        earned   = earned,
        spent    = spent,
        duration = duration,
        date     = date("%d/%m/%Y %H:%M"),
    }

    table.insert(GoldTrackerDB.history, 1, session)

    -- Mantém só as últimas 5
    while #GoldTrackerDB.history > 5 do
        table.remove(GoldTrackerDB.history)
    end
end

-- Retorna o histórico salvo
function GoldTrackerHistory.getHistory()
    if not GoldTrackerDB or not GoldTrackerDB.history then
        return {}
    end
    return GoldTrackerDB.history
end