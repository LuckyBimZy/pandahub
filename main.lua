-- ==================== LOADER.LUA ====================
-- Loader sederhana berdasarkan PlaceId
-- Simpan di root folder

local placeId = game.PlaceId
local githubRaw = "https://raw.githubusercontent.com/LuckyBimZy/Machadepanmu/main/games/"

-- Daftar game yang didukung
local supportedGames = {
    [93978595733734] = { -- Ganti dengan ID game Violence District yang sebenarnya
        name = "Violence District",
        file = "violence.lua"
    },
    [131623223084840] = { -- Ganti dengan ID game brainrot
        name = "Escape Tsunami For Brainrots",
        file = "Escape.lua"
    },
    [77747658251236] = { -- Ganti dengan ID sailor piece
        name = "Sailor Piece",
        file = "sailor.lua"
    },
    [75992362647444] = { -- Ganti dengan ID game tapsimu
        name = "Tap simulator",
        file = "tapsim.lua"
    },
    [1234567890] = { -- Ganti dengan ID game Slime RNG yang sebenarnya
        name = "Slime RNG",
        file = "slime.lua"
    }
}

-- Cek apakah game didukung
local gameData = supportedGames[placeId]

if gameData then
    print("========================================")
    print("Loader: Detected " .. gameData.name)
    print("Loading script: " .. gameData.file)
    print("========================================")
    
    -- Load script dari GitHub
    local success, err = pcall(function()
        loadstring(game:HttpGet(githubRaw .. gameData.file))()
    end)
    
    if success then
        print("✅ Script loaded successfully!")
    else
        warn("❌ Failed to load script: " .. tostring(err))
    end
else
    warn("========================================")
    warn("Game not supported!")
    warn("Place ID: " .. placeId)
    warn("Supported games:")
    for id, data in pairs(supportedGames) do
        warn("  - " .. data.name .. " (ID: " .. id .. ")")
    end
    warn("========================================")
end