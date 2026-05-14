-- ==================== VIOLENCE DISTRICT - PREMIUM CATRAZ v1.2 ===================

if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.VD_Loaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--==================================================
-- SAVE ORIGINAL SETTINGS (SEBELUM APAPUN)
--==================================================
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

local originalCamera = {
    FieldOfView = Camera.FieldOfView
}

local originalQuality = settings().Rendering.QualityLevel

--==================================================
-- RESTORE ORIGINAL SETTINGS (PASTIKAN TIDAK BERUBAH)
--==================================================
local function restoreOriginalSettings()
    -- Restore Lighting
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
    Lighting.ColorShift_Top = originalLighting.ColorShift_Top
    
    -- Restore Camera
    Camera.FieldOfView = originalCamera.FieldOfView
    
    -- Restore Quality
    settings().Rendering.QualityLevel = originalQuality
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Material == Enum.Material.ForceField then
            v.Material = Enum.Material.Plastic
        end
    end
end
restoreOriginalSettings()

--==================================================
-- COLORS
--==================================================
local TeamColor = Color3.fromRGB(0, 255, 0)
local EnemyColor = Color3.fromRGB(255, 0, 0)

--==================================================
-- CONFIG
--==================================================
local Config = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Tracers = false,
        TeamCheck = false,
        MaxDistance = 2000,
        ShowTeammates = false
    },
    Highlight = {
        Enabled = false,
        TeamCheck = false,
        ShowTeam = false
    },
    Generator = {
        ESPEnabled = false,
        AntiFailEnabled = false
    },
    Healing = {
        AntiFailEnabled = false
    },
    UI = {
        HideSkillCheck = false
    },
    Visual = {
        FullbrightEnabled = false,
        NoFogEnabled = false,
        WallhackEnabled = false,
        SuperZoomEnabled = false,
        AntiAliasingEnabled = false,
        PerformanceMode = false
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 16,
        JumpEnabled = false,
        JumpValue = 50,
        InfiniteJump = false,
        Noclip = false
    },
    Teleport = {
        SavedPosition = nil
    },
    Misc = {
        AntiAFK = false
    }
}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Violence District",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "PREMIUM Edition v1.2",
    Version = "v1.2",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Violence",
    IntroEnabled = true,
    IntroText = "Violence District CatrazHub",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    -- Floating Toggle 
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully! Graphics are normal.")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local ESPTab = Window:MakeTab({
    Name = "Player ESP",
    Icon = "eye",
    Glass = true,
    Outline = true
})

local HighlightTab = Window:MakeTab({
    Name = "Highlight",
    Icon = "sparkles",
    Glass = true,
    Outline = true
})

local GeneratorTab = Window:MakeTab({
    Name = "Generator",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local HealingTab = Window:MakeTab({
    Name = "Healing",
    Icon = "heart",
    Glass = true,
    Outline = true
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "sun",
    Glass = true,
    Outline = true
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "footprints",
    Glass = true,
    Outline = true
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
    Glass = true,
    Outline = true
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function GetActiveFeatures()
    local active = {}
    
    if Config.ESP.Enabled then table.insert(active, "ESP") end
    if Config.Highlight.Enabled then table.insert(active, "Highlight") end
    if Config.Generator.ESPEnabled then table.insert(active, "GenESP") end
    if Config.Generator.AntiFailEnabled then table.insert(active, "Anti-Gen") end
    if Config.Healing.AntiFailEnabled then table.insert(active, "Anti-Heal") end
    if Config.UI.HideSkillCheck then table.insert(active, "HideSC") end
    if Config.Visual.FullbrightEnabled then table.insert(active, "Fullbright") end
    if Config.Visual.NoFogEnabled then table.insert(active, "NoFog") end
    if Config.Visual.WallhackEnabled then table.insert(active, "Wallhack") end
    if Config.Visual.SuperZoomEnabled then table.insert(active, "SuperZoom") end
    if Config.Visual.AntiAliasingEnabled then table.insert(active, "AntiAlias") end
    if Config.Visual.PerformanceMode then table.insert(active, "Performance") end
    if Config.Movement.SpeedEnabled then table.insert(active, "Speed") end
    if Config.Movement.JumpEnabled then table.insert(active, "Jump") end
    if Config.Movement.InfiniteJump then table.insert(active, "InfJump") end
    if Config.Movement.Noclip then table.insert(active, "Noclip") end
    if Config.Misc.AntiAFK then table.insert(active, "AntiAFK") end
    
    return active
end

--==================================================
-- TEAM CHECK FUNCTION
--==================================================
local function isTeammate(player)
    if not Player.Team then return false end
    if not player.Team then return false end
    return player.Team == Player.Team
end

local function getPlayerColor(player)
    if Config.ESP.TeamCheck and isTeammate(player) then
        return TeamColor
    else
        return EnemyColor
    end
end

--==================================================
-- PLAYER ESP SYSTEM 
--==================================================
local ESPObjects = {}

local function createPlayerESP(player)
    if player == Player then return end
    if ESPObjects[player] then return end
    
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = ESPObjects[player]
    
    -- Box settings
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    -- NAME - SIZE 22 DAN TEBAL (FONT 3 = GothamBold)
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255) 
    esp.Name.Size = 22 
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 3 
    
    -- Distance settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(255, 255, 0)
    esp.Distance.Size = 16 
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 3
    
    -- Health bar settings
    esp.HealthBarBG.Visible = false
    esp.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)
    esp.HealthBarBG.Thickness = 1
    esp.HealthBarBG.Transparency = 0.8
    esp.HealthBarBG.Filled = true
    
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Filled = true
    
    -- Tracer settings
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 1
end

local function removePlayerESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function updatePlayerESP()
    if not Config.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do obj.Visible = false end
        end
        return
    end
    
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Parent or not player.Character then
            removePlayerESP(player)
            continue
        end
        
        if Config.ESP.TeamCheck and isTeammate(player) and not Config.ESP.ShowTeammates then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")
        
        if not hrp or not hum or not head then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        
        if distance > Config.ESP.MaxDistance then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPos = Camera:WorldToViewportPoint(hrp.Position)
        
        if not onScreen then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local boxSize = Vector2.new(2000 / distance, 2500 / distance)
        local playerColor = getPlayerColor(player)
        
        if Config.ESP.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        if Config.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 55) 
            esp.Name.Color = Color3.fromRGB(255, 255, 255)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Config.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 30)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if Config.ESP.Health and hum then
            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barWidth = 4
            local barHeight = boxSize.Y
            
            esp.HealthBarBG.Size = Vector2.new(barWidth, barHeight)
            esp.HealthBarBG.Position = Vector2.new(rootPos.X - boxSize.X / 2 - 7, rootPos.Y - boxSize.Y / 2)
            esp.HealthBarBG.Visible = true
            
            local healthColor = Color3.fromRGB(
                math.floor(255 * (1 - healthPercent)),
                math.floor(255 * healthPercent),
                0
            )
            esp.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            esp.HealthBar.Position = Vector2.new(
                rootPos.X - boxSize.X / 2 - 7,
                rootPos.Y - boxSize.Y / 2 + barHeight * (1 - healthPercent)
            )
            esp.HealthBar.Color = healthColor
            esp.HealthBar.Visible = true
        else
            esp.HealthBarBG.Visible = false
            esp.HealthBar.Visible = false
        end
        
        if Config.ESP.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.From = screenCenter
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            esp.Tracer.Color = playerColor
            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end
    end
end

local function setupPlayerESP(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        task.wait(0.5)
        if Config.ESP.Enabled then
            createPlayerESP(player)
        end
    end)
    
    if player.Character then
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            if Config.ESP.Enabled then
                createPlayerESP(player)
            end
        end)
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Player then
        setupPlayerESP(player)
    end
end

Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

--==================================================
-- GENERATOR ESP & TELEPORT
--==================================================
local GeneratorESP = {}
local GeneratorList = {} -- Untuk menyimpan daftar generator

-- Fungsi untuk mendapatkan semua generator di map (IMPROVED)
local function scanGenerators()
    local generators = {}
    local foundCount = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Cari generator dengan berbagai kemungkinan nama
        if obj:IsA("Model") and (obj.Name == "Generator" or obj.Name:find("Generator") or obj.Name:find("generator")) then
            foundCount = foundCount + 1
            local name = "Generator " .. foundCount
            
            -- Cari PrimaryPart atau bagian utama generator
            local primaryPart = obj.PrimaryPart
            if not primaryPart then
                -- Coba cari part yang bisa jadi posisi
                for _, part in pairs(obj:GetChildren()) do
                    if part:IsA("BasePart") then
                        primaryPart = part
                        break
                    end
                end
            end
            
            -- Dapatkan progress
            local progress = 0
            local success, result = pcall(function()
                return obj:GetAttribute("RepairProgress") or 0
            end)
            if success then
                progress = result
            end
            
            -- Simpan data generator (tanpa jarak)
            table.insert(generators, {
                Model = obj,
                Name = name,
                Progress = progress,
                Position = primaryPart and primaryPart.Position or nil,
                PrimaryPart = primaryPart
            })
        end
    end
    
    return generators
end

-- Fungsi untuk mendapatkan list nama generator untuk dropdown (TANPA JARAK)
local function getGeneratorNames()
    local names = {}
    local gens = scanGenerators()
    
    if #gens == 0 then
        table.insert(names, "❌ No generators found")
    else
        for i, gen in ipairs(gens) do
            local status = gen.Progress >= 100 and "✅" or "🔄"
            local progressText = string.format("%.0f", gen.Progress) .. "%"
            -- TANPA JARAK - hanya tampilkan nama dan progress
            local name = string.format("%s %s (%s)", status, gen.Name, progressText)
            table.insert(names, name)
        end
    end
    return names
end

-- Fungsi untuk teleport ke generator terpilih
local function teleportToGenerator(selectedName)
    -- Cek karakter
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Anda tidak memiliki karakter!")
        return false
    end
    
    local gens = scanGenerators()
    local hrp = Player.Character.HumanoidRootPart
    
    -- Cari generator yang dipilih berdasarkan index
    for i, gen in ipairs(gens) do
        local status = gen.Progress >= 100 and "✅" or "🔄"
        local progressText = string.format("%.0f", gen.Progress) .. "%"
        -- Sesuaikan format dengan yang di dropdown
        local checkName = string.format("%s %s (%s)", status, gen.Name, progressText)
        
        if checkName == selectedName then
            -- Cek apakah generator memiliki posisi
            if gen.Position then
                -- PASTIKAN POSISI VALID (cek NaN atau infinite)
                if gen.Position.X ~= gen.Position.X or math.abs(gen.Position.X) > 1e6 then
                    Notify("❌ Posisi generator tidak valid")
                    return false
                end
                
                -- TELEPORT - PAKAI METODE LANGSUNG
                local targetPos = Vector3.new(gen.Position.X, gen.Position.Y + 3, gen.Position.Z)
                
                -- Method 1: CFrame (PALING AMAN)
                local success1, err1 = pcall(function()
                    hrp.CFrame = CFrame.new(targetPos)
                    -- Tunggu sebentar untuk memastikan teleport selesai
                    task.wait(0.1)
                end)
                
                if success1 then
                    Notify("✅ Teleported ke " .. gen.Name .. " (" .. progressText .. ")")
                    return true
                else
                    -- Method 2: Coba dengan MoveTo sebagai alternatif
                    local success2 = pcall(function()
                        hrp:MoveTo(targetPos)
                    end)
                    
                    if success2 then
                        Notify("✅ Teleported ke " .. gen.Name .. " (MoveTo)")
                        return true
                    else
                        Notify("❌ Gagal teleport: " .. tostring(err1))
                        return false
                    end
                end
            else
                Notify("❌ Generator tidak memiliki posisi yang valid")
                return false
            end
        end
    end
    
    Notify("❌ Generator tidak ditemukan")
    return false
end

-- Fungsi untuk teleport paksa ke generator terdekat (ALTERNATIF)
local function teleportToNearestGenerator()
    local gens = scanGenerators()
    if #gens == 0 then
        Notify("❌ Tidak ada generator di map")
        return false
    end
    
    -- Hitung jarak untuk mencari yang terdekat (internal saja, tidak ditampilkan)
    local nearest = nil
    local shortestDist = math.huge
    
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = Player.Character.HumanoidRootPart.Position
        
        for _, gen in ipairs(gens) do
            if gen.Position then
                local dist = (myPos - gen.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = gen
                end
            end
        end
    else
        -- Jika tidak bisa hitung jarak, ambil generator pertama
        nearest = gens[1]
    end
    
    if nearest and nearest.Position then
        local hrp = Player.Character.HumanoidRootPart
        local targetPos = Vector3.new(nearest.Position.X, nearest.Position.Y + 3, nearest.Position.Z)
        
        -- PASTIKAN POSISI VALID
        if targetPos.X ~= targetPos.X or math.abs(targetPos.X) > 1e6 then
            Notify("❌ Posisi generator tidak valid")
            return false
        end
        
        local success = pcall(function()
            hrp.CFrame = CFrame.new(targetPos)
        end)
        
        if success then
            local progressText = string.format("%.0f", nearest.Progress) .. "%"
            Notify("✅ Teleported ke generator terdekat (" .. progressText .. ")")
            return true
        else
            Notify("❌ Gagal teleport ke generator terdekat")
            return false
        end
    end
    
    Notify("❌ Tidak ada generator dengan posisi valid")
    return false
end

-- Fungsi untuk membuat ESP Generator 
local function createGeneratorESP(gen)
    if not gen:IsA("Model") or gen:FindFirstChild("GenESP") then return end
    
    local folder = Instance.new("Folder", gen)
    folder.Name = "GenESP"
    
    local highlight = Instance.new("Highlight", folder)
    highlight.Adornee = gen
    highlight.FillColor = Color3.new(0, 1, 1)
    highlight.DepthMode = "AlwaysOnTop"
    
    -- Cari part untuk billboard
    local adornee = gen:FindFirstChild("HitBox") or gen.PrimaryPart
    if not adornee then
        for _, part in pairs(gen:GetChildren()) do
            if part:IsA("BasePart") then
                adornee = part
                break
            end
        end
    end
    
    if adornee then
        local billboard = Instance.new("BillboardGui", folder)
        billboard.Size = UDim2.new(0, 80, 0, 40)
        billboard.AlwaysOnTop = true
        billboard.Adornee = adornee
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14
        
        task.spawn(function()
            while gen.Parent and folder.Parent do
                local progress = 0
                local success, result = pcall(function()
                    return gen:GetAttribute("RepairProgress") or 0
                end)
                if success then
                    progress = result
                end
                
                textLabel.Text = math.floor(progress) .. "%"
                highlight.Enabled = Config.Generator.ESPEnabled
                billboard.Enabled = Config.Generator.ESPEnabled
                
                if progress >= 100 then
                    highlight.FillColor = Color3.new(0, 1, 0)
                else
                    highlight.FillColor = Color3.new(0, 1, 1)
                end
                
                task.wait(1)
            end
        end)
    end
    
    GeneratorESP[gen] = folder
end

-- Generator scanner thread (hanya berjalan jika diaktifkan)
task.spawn(function()
    while true do
        if Config.Generator.ESPEnabled then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name == "Generator" or obj.Name:find("Generator")) then
                    createGeneratorESP(obj)
                end
            end
        end
        task.wait(3)
    end
end)

-- ANTI-FAIL SYSTEM DINONAKTIFKAN MENGHINDARI ERROR
print("⚠️ Anti-Fail System dinonaktifkan untuk menghindari error")

--==================================================
-- HIGHLIGHT SYSTEM
--==================================================
local Highlights = {}

local function createHighlight(player)
    if player == Player then return end
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    if Config.Highlight.TeamCheck then
        if isTeammate(player) then
            highlight.FillColor = TeamColor
            highlight.OutlineColor = TeamColor
        else
            highlight.FillColor = EnemyColor
            highlight.OutlineColor = EnemyColor
        end
    else
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
    
    Highlights[player] = highlight
end

local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function updateHighlights()
    for player, highlight in pairs(Highlights) do
        if not player or not player.Parent or not player.Character then
            removeHighlight(player)
            continue
        end
        
        if Config.Highlight.TeamCheck and isTeammate(player) and not Config.Highlight.ShowTeam then
            highlight.Enabled = false
            continue
        else
            highlight.Enabled = true
        end
        
        if Config.Highlight.TeamCheck then
            if isTeammate(player) then
                highlight.FillColor = TeamColor
                highlight.OutlineColor = TeamColor
            else
                highlight.FillColor = EnemyColor
                highlight.OutlineColor = EnemyColor
            end
        else
            highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end
end

--==================================================
-- WALLHACK FUNCTION 
--==================================================
local WallhackConnection = nil

local function updateWallhack()
    if WallhackConnection then
        WallhackConnection:Disconnect()
        WallhackConnection = nil
    end
    
    if Config.Visual.WallhackEnabled then
        WallhackConnection = RunService.RenderStepped:Connect(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
                    -- Hanya ubah part yang opacity-nya rendah, jangan semua
                    if v.Transparency < 0.3 then
                        v.Material = Enum.Material.ForceField
                        v.Transparency = 0.3
                    end
                end
            end
        end)
    else
        -- Restore normal materials hanya untuk part yang diubah
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) and v.Material == Enum.Material.ForceField then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

--==================================================
-- VISUAL FEATURES 
--==================================================

-- No Fog
local function updateNoFog()
    if Config.Visual.NoFogEnabled then
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

-- Super Zoom
local function updateSuperZoom()
    if Config.Visual.SuperZoomEnabled then
        Camera.FieldOfView = 120
    else
        Camera.FieldOfView = originalCamera.FieldOfView
    end
end

-- Fullbright
local function updateFullbright()
    if Config.Visual.FullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end

-- Anti-Aliasing
local function updateGraphicsQuality()
    if Config.Visual.AntiAliasingEnabled then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
    else
        settings().Rendering.QualityLevel = originalQuality
    end
end

-- Performance Mode
local function updatePerformanceMode()
    if Config.Visual.PerformanceMode then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
    else
        settings().Rendering.QualityLevel = originalQuality
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

-- Reset Visual Settings
local function resetVisualSettings()
    Config.Visual.FullbrightEnabled = false
    Config.Visual.NoFogEnabled = false
    Config.Visual.WallhackEnabled = false
    Config.Visual.SuperZoomEnabled = false
    Config.Visual.AntiAliasingEnabled = false
    Config.Visual.PerformanceMode = false
    
    -- Restore all settings
    restoreOriginalSettings()
    updateWallhack()
    
    Notify("All visual settings reset to normal")
end

--==================================================
-- MOVEMENT SYSTEM
--==================================================
local noclipConnection = nil
local infiniteJumpConnection = nil

local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if Config.Movement.SpeedEnabled then
        hum.WalkSpeed = Config.Movement.SpeedValue
    else
        hum.WalkSpeed = 16
    end
    
    if Config.Movement.JumpEnabled then
        hum.JumpPower = Config.Movement.JumpValue
    else
        hum.JumpPower = 50
    end
end

-- Infinite Jump
infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfiniteJump then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Noclip
local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Movement.Noclip then return end
        
        local char = Player.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    task.wait(0.1)
    
    local char = Player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

--==================================================
-- ANTI AFK SYSTEM
--==================================================
local antiAFKConnection = nil

local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    if Config.Misc.AntiAFK then
        antiAFKConnection = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

--==================================================
-- TELEPORT FUNCTIONS (PLAYER)
--==================================================
local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

local function teleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        Notify("Teleported to " .. playerName)
        return true
    end
    Notify("Player not found or invalid")
    return false
end

--==================================================
-- HIDE SKILL CHECK UI
--==================================================
RunService.RenderStepped:Connect(function()
    if Config.UI.HideSkillCheck then
        local PlayerGui = Player:FindFirstChild("PlayerGui")
        if PlayerGui then
            local targetUI = PlayerGui:FindFirstChild("SkillCheckPromptGui")
            local targetUICon = PlayerGui:FindFirstChild("SkillCheckPromptGui-con")
            
            if targetUI and targetUI.Enabled then
                targetUI.Enabled = false
            end
            
            if targetUICon and targetUICon.Enabled then
                targetUICon.Enabled = false
            end
        end
    end
end)

--==================================================
-- UPDATE LOOP 
--==================================================
RunService.Heartbeat:Connect(function()
    updateMovement()
    updatePlayerESP()
    
    -- Visual features hanya berjalan jika diaktifkan
    if Config.Visual.NoFogEnabled then
        updateNoFog()
    end
    
    if Config.Visual.FullbrightEnabled then
        updateFullbright()
    end
    
    if Config.Visual.SuperZoomEnabled then
        updateSuperZoom()
    end
    
    if Config.Visual.WallhackEnabled then
        updateWallhack()
    end
    
    if Config.Visual.AntiAliasingEnabled then
        updateGraphicsQuality()
    end
    
    if Config.Visual.PerformanceMode then
        updatePerformanceMode()
    end
    
    if Config.Highlight.Enabled then
        updateHighlights()
    end
end)

--==================================================
-- MAIN TAB - PLAYER INFO 
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Player info 
PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days\n" ..
           "Team: " .. (Player.Team and Player.Team.Name or "No Team"),
    Image = "user",
    ImageSize = 48
})

local ServerInfoSection = MainTab:AddSection({
    Name = "🌐 SERVER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local startTime = tick()
local function getUptime()
    local uptime = tick() - startTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function UpdateServerInfo()
    local players = Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    
    return "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
           "Ping: " .. ping .. "ms\n" ..
           "Uptime: " .. getUptime()
end

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = UpdateServerInfo(),
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
            Callback = function()
                ServerInfoPara:SetDesc(UpdateServerInfo())
            end
        }
    }
})

-- Auto refresh server info
task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
    end
end)

local ActiveFeaturesSection = MainTab:AddSection({
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ActiveFeaturesPara = ActiveFeaturesSection:AddParagraph({
    Title = "Currently Active",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

-- Update active features setiap detik
task.spawn(function()
    while true do
        local active = GetActiveFeatures()
        if #active > 0 then
            ActiveFeaturesPara:SetDesc(table.concat(active, " • "))
        else
            ActiveFeaturesPara:SetDesc("No active features")
        end
        task.wait(1)
    end
end)

--==================================================
-- ESP TAB
--==================================================
local ESPSection = ESPTab:AddSection({
    Name = "🎯 PLAYER ESP SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ESPSection:AddToggle({
    Name = "ENABLE ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPEnable",
    Save = true,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createPlayerESP(player)
                end
            end
            Notify("Player ESP Enabled")
        else
            for player, _ in pairs(ESPObjects) do
                removePlayerESP(player)
            end
        end
    end
})

ESPSection:AddToggle({
    Name = "SHOW BOXES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPBoxes",
    Save = true,
    Callback = function(Value) Config.ESP.Boxes = Value end
})

ESPSection:AddToggle({
    Name = "SHOW NAMES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPNames",
    Save = true,
    Callback = function(Value) Config.ESP.Names = Value end
})

ESPSection:AddToggle({
    Name = "SHOW DISTANCE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPDistance",
    Save = true,
    Callback = function(Value) Config.ESP.Distance = Value end
})

ESPSection:AddToggle({
    Name = "SHOW HEALTH BAR",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPHealth",
    Save = true,
    Callback = function(Value) Config.ESP.Health = Value end
})

ESPSection:AddToggle({
    Name = "SHOW TRACERS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTracers",
    Save = true,
    Callback = function(Value) Config.ESP.Tracers = Value end
})

ESPSection:AddToggle({
    Name = "TEAM CHECK (HIDE TEAMMATES)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTeamCheck",
    Save = true,
    Callback = function(Value) Config.ESP.TeamCheck = Value end
})

ESPSection:AddToggle({
    Name = "SHOW TEAMMATES (OVERRIDE)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPShowTeam",
    Save = true,
    Callback = function(Value) Config.ESP.ShowTeammates = Value end
})

ESPSection:AddSlider({
    Name = "MAX ESP DISTANCE",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    ValueName = "meters",
    Outline = true,
    Callback = function(Value) Config.ESP.MaxDistance = Value end
})

ESPSection:AddParagraph({
    Title = "COLOR GUIDE",
    Desc = "🟢 GREEN = Teammate\n🔴 RED = Enemy\n⚪ WHITE = Normal Players",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightSection = HighlightTab:AddSection({
    Name = "✨ CHARACTER HIGHLIGHT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HighlightSection:AddToggle({
    Name = "ENABLE HIGHLIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightEnable",
    Save = true,
    Callback = function(Value)
        Config.Highlight.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createHighlight(player)
                end
            end
            Notify("Highlight Enabled")
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
        end
    end
})

HighlightSection:AddToggle({
    Name = "AUTO TEAM COLORS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightTeam",
    Save = true,
    Callback = function(Value) Config.Highlight.TeamCheck = Value end
})

HighlightSection:AddToggle({
    Name = "SHOW TEAM HIGHLIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightShowTeam",
    Save = true,
    Callback = function(Value) Config.Highlight.ShowTeam = Value end
})

--==================================================
-- GENERATOR TAB (DENGAN TELEPORT GENERATOR - FIXED)
--==================================================
local GenSection = GeneratorTab:AddSection({
    Name = "⚡ GENERATOR FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GenSection:AddToggle({
    Name = "ENABLE GENERATOR ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenESP",
    Save = true,
    Callback = function(Value)
        Config.Generator.ESPEnabled = Value
        if not Value then
            for gen, folder in pairs(GeneratorESP) do
                if folder then folder:Destroy() end
            end
            GeneratorESP = {}
        end
        Notify(Value and "Generator ESP Enabled" or "Generator ESP Disabled")
    end
})

GenSection:AddToggle({
    Name = "ENABLE ANTI-FAIL GENERATOR",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Generator.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Generator Enabled" or "Anti-Fail Generator Disabled")
    end
})

GenSection:AddParagraph({
    Title = "GENERATOR INFO",
    Desc = "🔵 Cyan = In Progress\n🟢 Green = Complete (100%)\n✅ Hold left click to repair",
    Image = "info",
    ImageSize = 30
})

--==================================================
-- TELEPORT GENERATOR SECTION
--==================================================
local TeleportGenSection = GeneratorTab:AddSection({
    Name = "📍 TELEPORT TO GENERATOR",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local SelectedGenerator = ""
local GeneratorDropdown = nil

-- Dropdown untuk generator list
GeneratorDropdown = TeleportGenSection:AddDropdown({
    Name = "PILIH GENERATOR",
    Default = "🔍 Scanning generators...",
    Options = {"🔍 Scanning..."},
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        SelectedGenerator = Value
        if Value and Value ~= "" and Value ~= "❌ No generators found" and Value ~= "🔍 Scanning..." then
            print("✅ Generator dipilih: " .. Value)
        end
    end
})

-- Tombol Teleport ke Generator
TeleportGenSection:AddButton({
    Name = "🚀 TELEPORT KE GENERATOR TERPILIH",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        if SelectedGenerator and SelectedGenerator ~= "" and SelectedGenerator ~= "❌ No generators found" and SelectedGenerator ~= "🔍 Scanning..." then
            teleportToGenerator(SelectedGenerator)
        else
            Notify("❌ Pilih generator terlebih dahulu!")
        end
    end
})

-- Tombol Teleport ke Generator Terdekat (ALTERNATIF)
TeleportGenSection:AddButton({
    Name = "🎯 TELEPORT KE GENERATOR TERDEKAT", 
    Icon = "target",
    Outline = true,
    Callback = function()
        teleportToNearestGenerator()
    end
})

-- Tombol Refresh Generator List
TeleportGenSection:AddButton({
    Name = "🔄 REFRESH DAFTAR GENERATOR",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local options = getGeneratorNames()
        if GeneratorDropdown then
            GeneratorDropdown:Refresh(options, true)
        end
        if #options > 0 and options[1] ~= "❌ No generators found" then
            Notify("✅ Ditemukan " .. #options .. " generator di map")
        elseif options[1] == "❌ No generators found" then
            Notify("❌ Tidak ada generator di map ini")
        end
    end
})

TeleportGenSection:AddParagraph({
    Title = "TP GENERATOR WAJIB MENYALAKAN NO-CLIP",
    Image = "info",
    ImageSize = 30
})

-- Auto-refresh pertama kali
task.spawn(function()
    task.wait(2) -- Tunggu 2 detik agar UI siap
    local options = getGeneratorNames()
    if GeneratorDropdown then
        GeneratorDropdown:Refresh(options, true)
    end
    if #options > 0 and options[1] ~= "❌ No generators found" then
        print("✅ Generator scanner: Ditemukan " .. #options .. " generator")
    else
        print("⚠️ Generator scanner: Tidak ada generator ditemukan")
    end
end)

--==================================================
-- HEALING TAB
--==================================================
local HealSection = HealingTab:AddSection({
    Name = "❤️ HEALING FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HealSection:AddToggle({
    Name = "ENABLE ANTI-FAIL HEALING",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HealAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Healing.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Healing Enabled" or "Anti-Fail Healing Disabled")
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualMainSection = VisualTab:AddSection({
    Name = "☀️ VISUAL ENHANCEMENTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

VisualMainSection:AddToggle({
    Name = "WALLHACK (SEE THROUGH WALLS)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.WallhackEnabled = Value
        updateWallhack()
        Notify(Value and "Wallhack Enabled" or "Wallhack Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "FULLBRIGHT (BRIGHT MAP)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.FullbrightEnabled = Value
        updateFullbright()
        Notify(Value and "Fullbright Enabled" or "Fullbright Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "NO FOG (CLEAR VIEW)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Config.Visual.NoFogEnabled = Value
        updateNoFog()
        Notify(Value and "No Fog Enabled" or "No Fog Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "SUPER ZOOM OUT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SuperZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.SuperZoomEnabled = Value
        updateSuperZoom()
        Notify(Value and "Super Zoom Enabled" or "Super Zoom Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "ANTI-ALIASING (HIGH QUALITY)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAlias",
    Save = true,
    Callback = function(Value)
        Config.Visual.AntiAliasingEnabled = Value
        updateGraphicsQuality()
        Notify(Value and "Anti-Aliasing Enabled" or "Anti-Aliasing Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "PERFORMANCE MODE (LOW QUALITY)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Performance",
    Save = true,
    Callback = function(Value)
        Config.Visual.PerformanceMode = Value
        updatePerformanceMode()
        Notify(Value and "Performance Mode Enabled" or "Performance Mode Disabled")
    end
})

VisualMainSection:AddButton({
    Name = "🔄 RESET ALL VISUAL SETTINGS",
    Icon = "refresh-cw",
    Outline = true,
    Callback = resetVisualSettings
})

VisualTab:AddSection({
    Name = "🎮 UI SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

VisualTab:AddToggle({
    Name = "HIDE SKILL CHECK UI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HideSkillCheck",
    Save = true,
    Callback = function(Value)
        Config.UI.HideSkillCheck = Value
        Notify(Value and "Skill Check UI Hidden" or "Skill Check UI Visible")
    end
})

--==================================================
-- MOVEMENT TAB
--==================================================
local SpeedSection = MovementTab:AddSection({
    Name = "⚡ SPEED HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SpeedSection:AddToggle({
    Name = "ENABLE SPEED BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SpeedEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.SpeedEnabled = Value
        if not Value then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end
})

SpeedSection:AddSlider({
    Name = "SPEED VALUE (16-200)",
    Min = 16,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Callback = function(Value)
        Config.Movement.SpeedValue = Value
        if Config.Movement.SpeedEnabled then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = Value end
            end
        end
    end
})

local JumpSection = MovementTab:AddSection({
    Name = "🦘 JUMP HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

JumpSection:AddToggle({
    Name = "ENABLE JUMP BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "JumpEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.JumpEnabled = Value
        if not Value then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 50 end
            end
        end
    end
})

JumpSection:AddSlider({
    Name = "JUMP POWER (50-300)",
    Min = 50,
    Max = 300,
    Default = 100,
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Callback = function(Value)
        Config.Movement.JumpValue = Value
        if Config.Movement.JumpEnabled then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = Value end
            end
        end
    end
})

local ExtraSection = MovementTab:AddSection({
    Name = "🚀 EXTRA MOVEMENT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ExtraSection:AddToggle({
    Name = "INFINITE JUMP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        Config.Movement.InfiniteJump = Value
        Notify(Value and "Infinite Jump Enabled" or "Infinite Jump Disabled")
    end
})

ExtraSection:AddToggle({
    Name = "NOCLIP (WALK THROUGH WALLS)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        
        if Value then
            enableNoclip()
            Notify("Noclip Enabled - You can walk through walls!")
        else
            disableNoclip()
            Notify("Noclip Disabled - Collision restored")
        end
    end
})

--==================================================
-- TELEPORT TAB (PLAYER)
--==================================================
local TeleportMainSection = TeleportTab:AddSection({
    Name = "📍 TELEPORT TO PLAYER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local SelectedPlayer = ""

-- Dropdown untuk player list
TeleportMainSection:AddDropdown({
    Name = "SELECT PLAYER",
    Default = "Select a player",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

TeleportMainSection:AddButton({
    Name = "🚀 TELEPORT TO SELECTED PLAYER",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "" and SelectedPlayer ~= "Select a player" then
            teleportToPlayer(SelectedPlayer)
        else
            Notify("Please select a player first!")
        end
    end
})

TeleportMainSection:AddButton({
    Name = "🔄 REFRESH PLAYER LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Notify("Player list refreshed")
    end
})

local WaypointSection = TeleportTab:AddSection({
    Name = "📍 WAYPOINTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

WaypointSection:AddButton({
    Name = "💾 SAVE CURRENT POSITION",
    Icon = "save",
    Outline = true,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Config.Teleport.SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!")
        end
    end
})

WaypointSection:AddButton({
    Name = "📂 LOAD SAVED POSITION",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if Config.Teleport.SavedPosition then
            Player.Character.HumanoidRootPart.CFrame = Config.Teleport.SavedPosition
            Notify("Teleported to saved position")
        else
            Notify("No saved position found!")
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscMainSection = MiscTab:AddSection({
    Name = "⚙️ UTILITY FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "ANTI AFK (PREVENT IDLE KICK)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        setupAntiAFK()
        Notify(Value and "Anti AFK Enabled" or "Anti AFK Disabled")
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
    -- Re-apply noclip if enabled
    if Config.Movement.Noclip then
        enableNoclip()
    end
    
    -- Reset speed/jump if enabled
    if Config.Movement.SpeedEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.Movement.SpeedValue end
    end
    
    if Config.Movement.JumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Config.Movement.JumpValue end
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
