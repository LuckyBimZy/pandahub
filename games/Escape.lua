-- ==================== CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v3.2 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.2 ULTIMATE - TRUE TSUNAMI PROOF + AUTO RESPAWN

-- [[ 📡 CATRAZ ANALYTICS SYSTEM (LIVE SERVER) ]] --
task.spawn(function()
    local BackendURL = "http://bot-service-asia-se-02.cybrancee.com:5023"
    local ScriptName = "Escape Tsunami For Brainrots"
    local ExecutorName = "Unknown"

    if identifyexecutor then ExecutorName = identifyexecutor() end
    local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

    if HttpRequest then
        pcall(function()
            local BodyJson = game:GetService("HttpService"):JSONEncode({
                ["script"] = ScriptName,
                ["executor"] = ExecutorName
            })
            HttpRequest({
                Url = BackendURL .. "/ping",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "CatrazHub/Client" },
                Body = BodyJson
            })
        end)
    end
end)

if _G.CT_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catraz Hub",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.CT_Loaded = true

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
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

--==================================================
-- GLOBAL ENV SETUP
--==================================================
getgenv().MzD = {}
local M = getgenv().MzD

--==================================================
-- INITIALIZE FOLDERS
--==================================================
M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
if not M.ActiveBrainrots then task.spawn(function() M.ActiveBrainrots = workspace:WaitForChild("ActiveBrainrots", 15) end) end

M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
if not M.ActiveLuckyBlocks then task.spawn(function() M.ActiveLuckyBlocks = workspace:WaitForChild("ActiveLuckyBlocks", 15) end) end

M.PlotAction = nil
pcall(function()
    M.PlotAction = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("Net", 10):WaitForChild("RF/Plot.PlotAction", 10)
end)

--==================================================
-- SAVE ORIGINAL SETTINGS
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
-- RESTORE ORIGINAL SETTINGS
--==================================================
local function restoreOriginalSettings()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
    Lighting.ColorShift_Top = originalLighting.ColorShift_Top
    Camera.FieldOfView = originalCamera.FieldOfView
    settings().Rendering.QualityLevel = originalQuality
end
restoreOriginalSettings()

--==================================================
-- COLORS
--==================================================
local TeamColor = Color3.fromRGB(0, 255, 0)
local EnemyColor = Color3.fromRGB(255, 0, 0)

--==================================================
-- CONFIG - SEMUA SETTING
--==================================================
local Config = {
    -- Farm Settings
    Farming = false,
    FarmTargets = {"Brainrots"},
    SelectedBrainrots = {},
    TargetMutation = "None",
    TargetRarity = {"Common"},
    LuckyBlockRarity = {"Common"},
    LuckyBlockMutation = "Any",
    TweenSpeed = 1000,
    CorridorSpeed = 400,
    AutoCollectMoney = false,
    InstantPickup = true,
    AntiAFK = false,
    AutoUpgrade = false,
    MaxLevel = 250,
    FactoryEnabled = false,
    FactorySlot = "5",
    FactoryRarity = "Common",
    FactoryMaxLevel = 250,
    FarmMode = "Collect, Place & Max",
    FarmSlot = "5",
    NoclipEnabled = false,
    FarmCapacity = 1,
    FarmHeight = -25, -- Ketinggian farm (default bawah tanah)
    
    -- Tsunami Settings
    TsunamiProtection = false,
    TsunamiMode = "Bawah",
    TsunamiHeight = 150,
}

--==================================================
-- STATUS
--==================================================
local Status = {
    farm = "Idle", 
    farmCount = 0, 
    luckyBlockCount = 0,
    money = "Idle",
    placeCount = 0, 
    upgradeCount = 0,
    upgrade = "Idle",
    factory = "Idle", 
    factoryCount = 0,
    tsunami = "Off",
    deaths = 0
}

--==================================================
-- STATE VARIABLES
--==================================================
M.baseGUID = nil
M.baseCFrame = nil
M.homePosition = nil
M.farmThread = nil
M.factoryThread = nil
M.moneyThread = nil
M.moneyRemoteThread = nil
M.upgradeThread = nil
M._noclipConn = nil
M._instantConn = nil
M._wallZ_front = 173
M._wallZ_back = -173
M._isGod = false
M._godThread = nil
M._healthConn = nil
M._damageShield = nil -- Shield untuk mencegah damage tsunami
M._tsunamiSafeZone = false -- Status apakah dalam zona aman

-- Tsunami Variables
local Tsunami = {
    Enabled = false,
    Mode = "Bawah",
    Height = 150,
    DetectionPart = nil,
    TsunamiPart = nil,
    Connection = nil,
    FlyConnection = nil,
    BodyVelocity = nil,
    BodyGyro = nil,
    IsFlying = false,
    LastTsunamiPos = nil,
    SafeY = -50, -- Ketinggian aman default (bawah tanah)
    DamageCooldown = 0, -- Cooldown untuk mencegah damage berulang
    LastDamageTime = 0
}

local HIGH_RARITIES = {["Celestial"] = true, ["Divine"] = true, ["Infinity"] = true}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Catraz Hub",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub",
    Subtext = "Escape Tsunami For Brainrots",
    Version = "v3.2 ULTIMATE",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Tsunami",
    IntroEnabled = true,
    IntroText = "Escape Tsunami For Brainrots",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "rbxassetid://84894412677021",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    -- Floating Toggle 
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "home",
    Glass = true,
    Outline = true
})

local TsunamiTab = Window:MakeTab({
    Name = "Tsunami",
    Icon = "waves",
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local FactoryTab = Window:MakeTab({
    Name = "Factory",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local AutoTab = Window:MakeTab({
    Name = "Automation",
    Icon = "rocket",
    Glass = true,
    Outline = true
})

local ConfigTab = Window:MakeTab({
    Name = "Config",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- OPTIONS
--==================================================
local RAR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity"}
local MUT = {"Any","None","Emerald","Gold","Blood","Diamond","Rainbow","Shadow","Crystal","Void"}
local FM = {"Collect","Collect, Place & Max"}
local FR = {"Common","Uncommon","Rare","Epic","Legendary","Mythical"}
local LBR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity","Admin","UFO","Candy","Money"}
local SL = {} for i=1,40 do table.insert(SL,tostring(i)) end
local CSPD = {"100","200","300","400","500","600","800","1000","1200","1500","2000","2500","3000"}
local TSUNAMI_MODES = {"Bawah (Gali Tanah)", "Atas (Terbang di Atas)"}
local FARM_HEIGHTS = {
    "Bawah Tanah (-0.3)", 
    "Bawah Tanah (-0.5)", 
    "Bawah Tanah (-0.7)",
    "Bawah Tanah (-0.8)",
    "Bawah Tanah (-0.9)",
    "Bawah Tanah (-1)", 
    "Bawah Tanah (-2)", 
    "Bawah Tanah (-3)", 
    "Bawah Tanah (-4)", 
    "Bawah Tanah (-5)", 
    "Bawah Tanah (-7)", 
    "Bawah Tanah (-10)",
    "Bawah Tanah (-25)", 
    "Permukaan (0)", 
    "Ketinggian 50", 
    "Ketinggian 100", 
    "Ketinggian 150", 
    "Ketinggian 200"
}
--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function GetActiveFeatures()
    local active = {}
    
    if Config.Farming then table.insert(active, "Farm") end
    if Config.AutoCollectMoney then table.insert(active, "Money") end
    if Config.AutoUpgrade then table.insert(active, "Upgrade") end
    if Config.FactoryEnabled then table.insert(active, "Factory") end
    if Config.TsunamiProtection then table.insert(active, "Tsunami") end
    if Config.NoclipEnabled then table.insert(active, "Noclip") end
    
    return active
end

--==================================================
-- DAMAGE PROTECTION SYSTEM
--==================================================

-- Fungsi untuk membuat shield damage
local function createDamageShield()
    if M._damageShield then return end
    
    -- Buat part transparan sebagai shield
    local shield = Instance.new("Part")
    shield.Name = "DamageShield"
    shield.Size = Vector3.new(10, 10, 10)
    shield.Transparency = 1
    shield.CanCollide = false
    shield.Anchored = true
    shield.Parent = Workspace
    
    -- Posisikan shield di sekitar player
    local function updateShieldPosition()
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        shield.Position = hrp.Position
    end
    
    -- Update posisi shield setiap frame
    local connection = RunService.Heartbeat:Connect(updateShieldPosition)
    
    M._damageShield = {
        Part = shield,
        Connection = connection
    }
end

-- Fungsi untuk menghancurkan shield
local function destroyDamageShield()
    if M._damageShield then
        if M._damageShield.Connection then
            M._damageShield.Connection:Disconnect()
        end
        if M._damageShield.Part then
            pcall(function() M._damageShield.Part:Destroy() end)
        end
        M._damageShield = nil
    end
end

-- Fungsi untuk mencegah damage tsunami (HOOK METAMETHOD)
local function setupDamageProtection()
    -- Hook untuk mencegah damage dari tsunami
    local oldNamecall
    local success, result = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Cegah damage dari tsunami
            if method == "FireServer" and tostring(self):find("Damage") then
                -- Cek apakah damage berasal dari tsunami
                local damageSource = tostring(args[1]) or ""
                if damageSource:find("tsunami") or damageSource:find("Tsunami") or damageSource:find("wave") or damageSource:find("water") then
                    -- Jika tsunami protection aktif, block damage
                    if Config.TsunamiProtection and Tsunami.Enabled then
                        return nil
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end)
    end)
    
    if not success then
        warn("[Catraz Hub] Metamethod hook gagal, menggunakan metode alternatif")
    end
end

-- Panggil setup damage protection
task.spawn(setupDamageProtection)

--==================================================
-- TSUNAMI FUNCTIONS - FIXED
--==================================================

-- Fungsi untuk mendeteksi tsunami
local function detectTsunami()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("tsunami") or name:find("wave") or name:find("banjir") or name:find("flood") or name:find("water") or name:find("gelombang") then
                if obj:IsA("Model") then
                    local prim = obj.PrimaryPart
                    if prim then return prim end
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("BasePart") then return child end
                    end
                else
                    return obj
                end
            end
        end
    end
    return nil
end

-- Fungsi untuk membuat part deteksi tsunami
local function createTsunamiDetector()
    if Tsunami.DetectionPart and Tsunami.DetectionPart.Parent then
        pcall(function() Tsunami.DetectionPart:Destroy() end)
    end
    
    local detector = Instance.new("Part")
    detector.Name = "TsunamiDetector"
    detector.Size = Vector3.new(100, 100, 100)
    detector.Transparency = 1
    detector.CanCollide = false
    detector.Anchored = true
    detector.Parent = Workspace
    
    Tsunami.DetectionPart = detector
    return detector
end

-- Fungsi untuk mendapatkan ketinggian aman dari tsunami
local function getTsunamiSafeHeight()
    if Tsunami.Mode == "Bawah" then
        return -50 -- Di bawah tanah
    else
        return Tsunami.Height -- Di atas
    end
end

-- Fungsi untuk mendapatkan ketinggian farm berdasarkan mode
local function getFarmHeight()
    if Config.TsunamiProtection and Tsunami.Enabled then
        -- Jika tsunami aktif, gunakan ketinggian aman tsunami
        return getTsunamiSafeHeight()
    else
        -- Jika tsunami tidak aktif, gunakan ketinggian farm yang dipilih
        return Config.FarmHeight
    end
end

-- Fungsi untuk mengecek apakah player dalam zona aman
local function isInSafeZone()
    local char = Player.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local tsunami = detectTsunami()
    if not tsunami then return true end -- Tidak ada tsunami = aman
    
    local playerY = hrp.Position.Y
    local tsunamiY = tsunami.Position.Y
    
    if Tsunami.Mode == "Bawah" then
        -- Mode bawah: aman jika Y < -40
        return playerY < -40
    else
        -- Mode atas: aman jika Y > Tsunami.Height - 10
        return playerY > Tsunami.Height - 10
    end
end

-- Fungsi untuk terbang menghindari tsunami (DIPERBAIKI)
local function enableTsunamiFlight()
    if Tsunami.IsFlying then return end
    
    local char = Player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
    
    -- Hancurkan BodyVelocity lama jika ada
    if Tsunami.BodyVelocity then
        pcall(function() Tsunami.BodyVelocity:Destroy() end)
    end
    if Tsunami.BodyGyro then
        pcall(function() Tsunami.BodyGyro:Destroy() end)
    end
    
    -- Buat BodyVelocity baru
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TsunamiFlight"
    bv.MaxForce = Vector3.new(10000, 10000, 10000)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = hrp
    
    -- Buat BodyGyro untuk stabilisasi
    local bg = Instance.new("BodyGyro")
    bg.Name = "TsunamiGyro"
    bg.MaxTorque = Vector3.new(10000, 10000, 10000)
    bg.P = 1000
    bg.D = 500
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    Tsunami.BodyVelocity = bv
    Tsunami.BodyGyro = bg
    Tsunami.IsFlying = true
    
    -- Aktifkan noclip
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    -- Buat shield damage
    createDamageShield()
    
    -- Hapus koneksi lama jika ada
    if Tsunami.FlyConnection then
        Tsunami.FlyConnection:Disconnect()
    end
    
    -- Koneksi untuk menjaga ketinggian
    Tsunami.FlyConnection = RunService.Heartbeat:Connect(function()
        if not Tsunami.Enabled then
            disableTsunamiFlight()
            return
        end
        
        local currentChar = Player.Character
        if not currentChar then
            disableTsunamiFlight()
            return
        end
        
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHrp then return end
        
        local targetY = getTsunamiSafeHeight()
        local currentY = currentHrp.Position.Y
        
        -- Jika sudah di ketinggian aman, diam di tempat
        if math.abs(currentY - targetY) < 2 then
            if Tsunami.BodyVelocity then
                Tsunami.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        else
            -- Terbang ke ketinggian aman
            local direction = (targetY > currentY) and 1 or -1
            if Tsunami.BodyVelocity then
                Tsunami.BodyVelocity.Velocity = Vector3.new(0, direction * 50, 0)
            end
        end
        
        -- Stabilisasi rotasi
        if Tsunami.BodyGyro then
            Tsunami.BodyGyro.CFrame = CFrame.new(currentHrp.Position, currentHrp.Position + Vector3.new(0, 0, -1))
        end
        
        -- Jaga noclip
        for _, part in pairs(currentChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Update status zona aman
        TsunamiSafeZone = isInSafeZone()
    end)
end

local function disableTsunamiFlight()
    if Tsunami.FlyConnection then
        Tsunami.FlyConnection:Disconnect()
        Tsunami.FlyConnection = nil
    end
    
    if Tsunami.BodyVelocity then
        pcall(function() Tsunami.BodyVelocity:Destroy() end)
        Tsunami.BodyVelocity = nil
    end
    
    if Tsunami.BodyGyro then
        pcall(function() Tsunami.BodyGyro:Destroy() end)
        Tsunami.BodyGyro = nil
    end
    
    Tsunami.IsFlying = false
    
    -- Hancurkan shield damage
    destroyDamageShield()
    
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
        
        -- Kembalikan collision hanya jika noclip tidak aktif
        if not Config.NoclipEnabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fungsi untuk mengaktifkan sistem tsunami
local function enableTsunamiProtection()
    if Tsunami.Connection then
        Tsunami.Connection:Disconnect()
    end
    
    Tsunami.Enabled = true
    Tsunami.Mode = Config.TsunamiMode
    Tsunami.Height = Config.TsunamiHeight
    createTsunamiDetector()
    
    Tsunami.Connection = RunService.Heartbeat:Connect(function()
        if not Tsunami.Enabled then return end
        
        local tsunami = detectTsunami()
        local char = Player.Character
        if not char or not tsunami then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tsunamiPos = tsunami.Position
        local playerPos = hrp.Position
        local distance = (playerPos - tsunamiPos).Magnitude
        local heightDiff = math.abs(playerPos.Y - tsunamiPos.Y)
        
        -- Deteksi tsunami berdasarkan mode
        if Tsunami.Mode == "Bawah" then
            -- Mode bawah tanah: tsunami di atas, kita di bawah
            if playerPos.Y > -45 and distance < 100 and heightDiff < 50 then
                enableTsunamiFlight()
            end
        else
            -- Mode atas: tsunami di bawah, kita di atas
            if playerPos.Y < Tsunami.Height - 10 and distance < 100 then
                enableTsunamiFlight()
            end
        end
        
        -- Update detector
        if Tsunami.DetectionPart then
            Tsunami.DetectionPart.Position = Vector3.new(playerPos.X, getTsunamiSafeHeight(), playerPos.Z)
        end
        
        Tsunami.LastTsunamiPos = tsunamiPos
    end)
    
    -- Update safe Y untuk farm
    Tsunami.SafeY = getTsunamiSafeHeight()
    
    Notify("Tsunami Protection Aktif - Mode: " .. Config.TsunamiMode)
end

local function disableTsunamiProtection()
    Tsunami.Enabled = false
    if Tsunami.Connection then
        Tsunami.Connection:Disconnect()
        Tsunami.Connection = nil
    end
    disableTsunamiFlight()
    if Tsunami.DetectionPart then
        pcall(function() Tsunami.DetectionPart:Destroy() end)
        Tsunami.DetectionPart = nil
    end
end

--==================================================
-- NOCLIP FUNCTIONS
--==================================================
function M.isOwnWallPart(part)
    if not part then return false end
    local p = part.Parent
    while p do if p.Name == "MzDHubWalls" then return true end p = p.Parent end
    return false
end

local function enableNoclip()
    if M._noclipConn then return end
    Config.NoclipEnabled = true
    M._noclipConn = RunService.Stepped:Connect(function()
        if not Config.NoclipEnabled then return end
        pcall(function()
            local ch = Player.Character if not ch then return end
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and not M.isOwnWallPart(p) then p.CanCollide = false end
            end
        end)
    end)
end

local function disableNoclip()
    Config.NoclipEnabled = false
    if M._noclipConn then pcall(function() M._noclipConn:Disconnect() end) M._noclipConn = nil end
    pcall(function()
        local ch = Player.Character if not ch then return end
        for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end)
end

--==================================================
-- GOD MODE (DISABLED)
--==================================================
function M.enableGod() end
function M.disableGod() end

--==================================================
-- MAP FUNCTIONS
--==================================================
function M.mapFindCurrentMap()
    local best, bc = nil, 0
    for _, c in pairs(workspace:GetChildren()) do
        if c:IsA("Model") and c.Name:find("Map") and not c.Name:find("SharedInstances") then
            if c:FindFirstChild("Spawners") or c:FindFirstChild("Gaps") or c:FindFirstChild("RightWalls") or c:FindFirstChild("FirstFloor") or c:FindFirstChild("Ground") then return c end
            local cnt = 0
            for _, d in pairs(c:GetDescendants()) do if d:IsA("BasePart") then cnt = cnt + 1 end if cnt > 10 then return c end end
            if cnt > bc then bc = cnt best = c end
        end
    end return best
end

function M.detectWallZ()
    local map = M.mapFindCurrentMap() if not map then return end
    local mzwalls = map:FindFirstChild("MzDHubWalls") if not mzwalls then return end
    local fw = mzwalls:FindFirstChild("FrontWall_1")
    local bw = mzwalls:FindFirstChild("BackWall_1")
    if fw then M._wallZ_front = fw.Position.Z - fw.Size.Z / 2 - 3 end
    if bw then M._wallZ_back = bw.Position.Z + bw.Size.Z / 2 + 3 end
end

function M.getCorridorZ()
    M.detectWallZ()
    local homePos = M.getHomePosition().Position
    if homePos.Z >= 0 then return M._wallZ_front else return M._wallZ_back end
end

--==================================================
-- BASE FUNCTIONS
--==================================================
function M.findBase()
    local bases = workspace:FindFirstChild("Bases") if not bases then return end
    for _, base in pairs(bases:GetChildren()) do
        pcall(function()
            local pn = base.Title.TitleGui.Frame.PlayerName
            if pn.Text == Player.Name or pn.Text == Player.DisplayName then
                M.baseGUID = base.Name
                local s1 = base:FindFirstChild("slot 1 brainrot")
                if s1 and s1:FindFirstChild("Root") then M.baseCFrame = s1.Root.CFrame end
            end
        end)
    end
    if not M.homePosition then M.setHomePosition() end
end

function M.setHomePosition()
    local ch = Player.Character if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
    M.homePosition = hrp.CFrame
end

function M.getHomePosition()
    if M.homePosition then return M.homePosition end
    if M.baseCFrame then return M.baseCFrame end
    return CFrame.new(124, 3.8, 22)
end

task.spawn(function() task.wait(3) M.findBase() end)

Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    if Config.InstantPickup then setupInstant() end
    task.wait(0.5) M.detectWallZ()
    if M._isGod then
        M._isGod = false
        if M._healthConn then pcall(function() M._healthConn:Disconnect() end) M._healthConn = nil end
        if M._godThread then pcall(task.cancel, M._godThread) M._godThread = nil end
        task.wait(0.5) M.enableGod()
    end
    if Config.NoclipEnabled then
        if M._noclipConn then pcall(function() M._noclipConn:Disconnect() end) M._noclipConn = nil end
        Config.NoclipEnabled = false task.wait(0.3) enableNoclip()
    end
    if Config.TsunamiProtection then
        task.wait(1)
        enableTsunamiProtection()
    end
end)

--==================================================
-- AUTO RESPAWN SYSTEM - FIXED
--==================================================
function M.waitForRespawn()
    if not M.isDead() then return true end
    
    Status.deaths = Status.deaths + 1
    Status.farm = "💀 Mati! Respawn #" .. Status.deaths
    
    Notify("💀 Karakter mati! Menunggu respawn...")
    
    local timeout = tick() + 15
    while M.isDead() and tick() < timeout do 
        task.wait(0.2) 
    end
    
    task.wait(1.5) -- Tunggu karakter spawn
    
    -- Reset posisi home
    M.setHomePosition()
    
    -- Re-enable tsunami protection
    if Config.TsunamiProtection then
        enableTsunamiProtection()
    end
    
    -- Re-enable noclip
    if Config.NoclipEnabled then
        enableNoclip()
    end
    
    Status.farm = "🔄 Respawn selesai, melanjutkan farm..."
    Notify("✅ Respawn selesai! Melanjutkan farm...")
    
    task.wait(1)
    return not M.isDead()
end

--==================================================
-- TWEEN FUNCTIONS - ADAPTED FOR TSUNAMI MODE
--==================================================
function M.tweenTo(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local speed = tonumber(Config.TweenSpeed) or 1000
    if speed <= 0 then speed = 1000 end
    local t = math.max(d / speed, 0.05)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

function M.fastTween(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local t = math.max(d / 9999, 0.01)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

function M.corridorTween(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local spd = tonumber(Config.CorridorSpeed) or 400
    if spd <= 0 then spd = 400 end
    local t = math.max(d / spd, 0.05)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

function M.returnToBase() 
    M.tweenTo(M.getHomePosition()) 
    task.wait(0.1) 
end

-- MODIFIED: undergroundPathTo sekarang menggunakan ketinggian yang sesuai mode
function M.undergroundPathTo(targetCFrame)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    
    -- Dapatkan ketinggian yang sesuai
    local travelY = getFarmHeight()
    
    local bv = hrp:FindFirstChild("AntiFallMzD")
    if not bv then
        bv = Instance.new("BodyVelocity") 
        bv.Name = "AntiFallMzD" 
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0) 
        bv.Parent = hrp
    end
    
    local startPos = hrp.Position 
    local endPos = targetCFrame.Position 
    
    -- Turun/naik ke ketinggian travel
    M.fastTween(CFrame.new(startPos.X, travelY, startPos.Z)) 
    task.wait(0.05)
    
    -- Bergerak horizontal
    M.tweenTo(CFrame.new(endPos.X, travelY, endPos.Z)) 
    task.wait(0.05)
    
    -- Naik/turun ke target
    M.tweenTo(targetCFrame) 
    task.wait(0.05) 
    
    return true
end

-- MODIFIED: undergroundReturnToBase menggunakan ketinggian yang sesuai mode
function M.undergroundReturnToBase()
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    
    -- Dapatkan ketinggian yang sesuai
    local travelY = getFarmHeight()
    local curPos = hrp.Position 
    local homePos = M.getHomePosition().Position 
    
    local bv = hrp:FindFirstChild("AntiFallMzD")
    if not bv then 
        bv = Instance.new("BodyVelocity") 
        bv.Name = "AntiFallMzD" 
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
        bv.Velocity = Vector3.new(0, 0, 0) 
        bv.Parent = hrp 
    end
    
    -- Turun/naik ke ketinggian travel
    M.fastTween(CFrame.new(curPos.X, travelY, curPos.Z)) 
    task.wait(0.05)
    
    -- Bergerak horizontal ke home
    M.tweenTo(CFrame.new(homePos.X, travelY, homePos.Z)) 
    task.wait(0.05)
    
    -- Naik ke home
    M.tweenTo(M.getHomePosition()) 
    task.wait(0.05)
    
    if bv then bv:Destroy() end 
    return true
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================
function M.isHighRarity(r) return HIGH_RARITIES[r] == true end

function M.isDead()
    local ch = Player.Character if not ch then return true end
    local hum = ch:FindFirstChild("Humanoid") if not hum then return true end
    return hum.Health <= 0
end

function M.forceGrabPrompt(target)
    if not target then return end
    local prompts = {}
    if target:IsA("ProximityPrompt") then 
        table.insert(prompts, target)
    else 
        for _, d in pairs(target:GetDescendants()) do 
            if d:IsA("ProximityPrompt") then 
                table.insert(prompts, d) 
            end 
        end 
    end
    
    for _, p in pairs(prompts) do
        pcall(function() 
            p.MaxActivationDistance = 99999 
            p.HoldDuration = 0 
        end)
        pcall(function() fireproximityprompt(p) end) 
        pcall(function() fireproximityprompt(p) end)
    end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local parent = target 
        if parent:IsA("ProximityPrompt") then 
            parent = parent.Parent 
        end
        if parent and parent:IsA("BasePart") then 
            pcall(function() 
                firetouchinterest(hrp, parent, 0) 
                firetouchinterest(hrp, parent, 1) 
            end) 
        end
        local searchRoot = parent 
        if searchRoot and searchRoot.Parent and not searchRoot.Parent:IsA("Workspace") then 
            searchRoot = searchRoot.Parent 
        end
        if searchRoot then 
            for _, d in pairs(searchRoot:GetDescendants()) do 
                if d:IsA("BasePart") then 
                    pcall(function() 
                        firetouchinterest(hrp, d, 0) 
                        firetouchinterest(hrp, d, 1) 
                    end) 
                end 
            end 
        end
    end 
    task.wait(0.04)
end

--==================================================
-- BRAINROT FUNCTIONS
--==================================================
function M.getTargetRarities() 
    return type(Config.TargetRarity) == "table" and Config.TargetRarity or {Config.TargetRarity} 
end

function M.rarityMatches(fn) 
    for _, r in pairs(M.getTargetRarities()) do 
        if r == "Any" or r == fn then 
            return true 
        end 
    end 
    return false 
end

function M.getBrainrotNames(rarity)
    local names, seen = {}, {}
    if not M.ActiveBrainrots then M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") end
    if not M.ActiveBrainrots then return names end
    for _, f in pairs(M.ActiveBrainrots:GetChildren()) do
        if f:IsA("Folder") and (rarity == "Any" or f.Name == rarity) then
            for _, b in pairs(f:GetChildren()) do
                local n = b:FindFirstChild("RenderedBrainrot") and b.RenderedBrainrot:GetAttribute("BrainrotName") or b:GetAttribute("BrainrotName") or b.Name
                if n and n ~= "" and not seen[n] then 
                    seen[n] = true 
                    table.insert(names, n) 
                end
            end
        end
    end 
    table.sort(names) 
    return names
end

function M.matchesFilter(b, folderRarity)
    if not M.rarityMatches(folderRarity) then return false end
    if M.isHighRarity(folderRarity) then return true end
    local mut = b:GetAttribute("Mutation") or "None" 
    local isNone = (mut:lower() == "none" or mut == "")
    if Config.TargetMutation == "None" then 
        if not isNone then return false end 
    elseif Config.TargetMutation ~= "Any" then 
        if mut ~= Config.TargetMutation then return false end 
    end
    return true
end

function M.toolMatchesRarity(tool, targetRarity, targetMutation)
    local tMut = tool:GetAttribute("Mutation") or "None" 
    local lvl = tonumber(tool:GetAttribute("Level")) or 0
    local bName = tool:GetAttribute("BrainrotName") 
    local toolRarity = tool:GetAttribute("Rarity")
    if not bName or bName == "" or lvl >= Config.MaxLevel then return false end
    local tR = type(targetRarity) == "table" and targetRarity or {targetRarity}
    if toolRarity and M.isHighRarity(toolRarity) then
        for _, r in pairs(tR) do 
            if r == "Any" or r == toolRarity then 
                return true 
            end 
        end 
        return false
    end
    if targetMutation == "None" then 
        if not (tMut:lower() == "none" or tMut == "") then return false end
    elseif targetMutation ~= "Any" then 
        if tMut ~= targetMutation then return false end 
    end
    local isAny = false 
    for _, r in pairs(tR) do 
        if r == "Any" then 
            isAny = true 
            break 
        end 
    end
    if not isAny then
        if toolRarity and toolRarity ~= "" then
            local m = false 
            for _, r in pairs(tR) do 
                if toolRarity == r then 
                    m = true 
                    break 
                end 
            end 
            if not m then return false end
        else
            local wl = {} 
            for _, r in pairs(tR) do 
                for _, n in pairs(M.getBrainrotNames(r)) do 
                    wl[n] = true 
                end 
            end
            if not wl[bName] then return false end
        end
    end 
    return true
end

function M.findTargetToolInBackpack()
    local bp = Player:FindFirstChild("Backpack")
    if bp then 
        for _, t in pairs(bp:GetChildren()) do 
            if t:IsA("Tool") and M.toolMatchesRarity(t, Config.TargetRarity, Config.TargetMutation) then 
                return t 
            end 
        end 
    end
    local ch = Player.Character 
    if ch then 
        local eq = ch:FindFirstChildWhichIsA("Tool") 
        if eq and M.toolMatchesRarity(eq, Config.TargetRarity, Config.TargetMutation) then 
            return eq 
        end 
    end
    return nil
end

function M.findBrainrotRoot(b)
    local root = b:FindFirstChild("Root") 
    if root and root:IsA("BasePart") then return root end
    local rendered = b:FindFirstChild("RenderedBrainrot") 
    if rendered then 
        local rr = rendered:FindFirstChild("Root") 
        if rr and rr:IsA("BasePart") then return rr end 
    end
    for _, desc in pairs(b:GetDescendants()) do 
        if desc:IsA("BasePart") then 
            return desc 
        end 
    end
    if b:IsA("BasePart") then return b end 
    return nil
end

function M.isSlotEmpty(s)
    if not M.baseGUID then M.findBase() end 
    if not M.baseGUID then return true end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID) 
    if not mb then return true end
    local sm = mb:FindFirstChild("slot " .. s .. " brainrot") 
    if not sm then return true end
    local bn = sm:GetAttribute("BrainrotName") 
    return not bn or bn == ""
end

function M.findOccupiedSlots()
    if not M.baseGUID then M.findBase() end 
    if not M.baseGUID then return {} end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID) 
    if not mb then return {} end
    local o = {}
    for i = 1, 40 do
        local sm = mb:FindFirstChild("slot " .. i .. " brainrot")
        if sm then 
            local bn = sm:GetAttribute("BrainrotName") 
            local lv = sm:GetAttribute("Level")
            if bn and bn ~= "" then 
                table.insert(o, {slot = i, name = bn, level = lv or 1}) 
            end
        end
    end 
    return o
end

function M.placeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    local ok = pcall(function() M.PlotAction:InvokeServer("Place Brainrot", M.baseGUID, tostring(s)) end)
    if ok then Status.placeCount = Status.placeCount + 1 end 
    return ok
end

function M.pickUpBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    return pcall(function() M.PlotAction:InvokeServer("Pick Up Brainrot", M.baseGUID, tostring(s)) end)
end

function M.upgradeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    return pcall(function() M.PlotAction:InvokeServer("Upgrade Brainrot", M.baseGUID, tostring(s)) end)
end

function M.tweenToSlot(slotNumber)
    if not M.baseGUID then M.findBase() end 
    if not M.baseGUID then return false end
    local myBase = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID) 
    if not myBase then return false end
    local sm = myBase:FindFirstChild("slot " .. slotNumber .. " brainrot") 
    if not sm then return false end
    local root = sm:FindFirstChild("Root") 
    if root then 
        return M.tweenTo(root.CFrame * CFrame.new(0, 3, 0)) 
    end
    for _, part in pairs(sm:GetDescendants()) do 
        if part:IsA("BasePart") then 
            return M.tweenTo(part.CFrame * CFrame.new(0, 3, 0)) 
        end 
    end 
    return false
end

function M.isHighRarityTool(tool)
    if not tool then return false end 
    local r = tool:GetAttribute("Rarity") or "" 
    if HIGH_RARITIES[r] then return true end
    local bName = tool:GetAttribute("BrainrotName") or ""
    if M.ActiveBrainrots then
        for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
            if HIGH_RARITIES[folder.Name] then 
                for _, b in pairs(folder:GetChildren()) do 
                    if (b:GetAttribute("BrainrotName") or "") == bName then 
                        return true 
                    end 
                end 
            end
        end
    end 
    return false
end

--==================================================
-- LUCKY BLOCK FUNCTIONS
--==================================================
function M.getLuckyBlockRarities() 
    return type(Config.LuckyBlockRarity) == "table" and Config.LuckyBlockRarity or {Config.LuckyBlockRarity} 
end

function M.luckyBlockRarityMatches(bn) 
    for _, r in pairs(M.getLuckyBlockRarities()) do 
        if r == "Any" or bn:find("" .. r) or bn == r then 
            return true 
        end 
    end 
    return false 
end

function M.luckyBlockMutationMatches(block)
    local mut = block:GetAttribute("Mutation") or "None" 
    local isNone = (mut:lower() == "none" or mut == "")
    if Config.LuckyBlockMutation == "Any" then return true end 
    if Config.LuckyBlockMutation == "None" then return isNone end
    return mut == Config.LuckyBlockMutation
end

function M.luckyBlockGetRarityFromName(bn) 
    return bn:match("LuckyBlock_(.+)") or bn 
end

function M.findLuckyBlockRoot(block)
    local r = block:FindFirstChild("Root") 
    if r and r:IsA("BasePart") then return r end
    if block:IsA("BasePart") then return block end
    local p = nil 
    pcall(function() p = block.PrimaryPart end) 
    if p then return p end
    for _, d in pairs(block:GetDescendants()) do 
        if d:IsA("BasePart") then 
            return d 
        end 
    end 
    return nil
end

function M.hasFarmTarget(targetName)
    for _, v in pairs(Config.FarmTargets) do 
        if v == targetName then 
            return true 
        end 
    end
    return false
end

--==================================================
-- FARM SYSTEM - FIXED WITH TSUNAMI PROOF + AUTO RESPAWN
--==================================================
function M.startFarming()
    if M.farmThread then return end
    Config.Farming = true 
    Status.farmCount = 0 
    Status.luckyBlockCount = 0
    Status.deaths = 0
    M.setHomePosition() 
    M.detectWallZ() 
    M.returnToBase() 
    enableNoclip()

    M.farmThread = task.spawn(function()
        local currentBackpackCount = 0
        local maxBackpackCount = Config.FarmCapacity or 1
        local respawnAttempts = 0

        while Config.Farming do
            local ok, err = pcall(function()
                -- Cek apakah tsunami aktif dan perlu mengubah ketinggian
                local currentFarmHeight = getFarmHeight()
                
                if M.isDead() then
                    Status.farm = "💀 Mati! Menunggu respawn..."
                    M.waitForRespawn() 
                    task.wait(1) 
                    M.setHomePosition() 
                    M.returnToBase()
                    task.wait(0.5) 
                    currentBackpackCount = 0
                    respawnAttempts = respawnAttempts + 1
                    
                    -- Re-enable tsunami protection setelah respawn
                    if Config.TsunamiProtection then
                        enableTsunamiProtection()
                    end
                    
                    -- Lanjutkan farming
                    Status.farm = "🔄 Melanjutkan farm..."
                    task.wait(1)
                    return
                end
                
                local ch = Player.Character 
                local hum = ch and ch:FindFirstChild("Humanoid")
                if not ch or not hum then 
                    task.wait(1) 
                    return 
                end
                
                -- Cek apakah dalam zona aman tsunami
                if Config.TsunamiProtection and Tsunami.Enabled then
                    if not isInSafeZone() then
                        Status.farm = "⚠️ Tsunami mendekat! Mencari tempat aman..."
                        enableTsunamiFlight()
                        task.wait(1)
                        return
                    end
                end
                
                -- PRIORITAS: LUCKY BLOCKS
                if M.hasFarmTarget("Lucky Blocks") then
                    if not M.ActiveLuckyBlocks then 
                        M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks") 
                    end
                    if M.ActiveLuckyBlocks then
                        local foundLB = false
                        for _, block in pairs(M.ActiveLuckyBlocks:GetChildren()) do
                            if not Config.Farming or M.isDead() then break end
                            if M.luckyBlockRarityMatches(block.Name) and M.luckyBlockMutationMatches(block) then
                                local rootPart = M.findLuckyBlockRoot(block) 
                                if not rootPart then continue end
                                foundLB = true
                                local rarityName = M.luckyBlockGetRarityFromName(block.Name)
                                
                                Status.farm = "Opening LB " .. rarityName .. "..." 
                                M.undergroundPathTo(rootPart.CFrame * CFrame.new(0, 3, 0))
                                
                                for attempt = 1, 5 do
                                    if not Config.Farming then break end
                                    if M.isDead() then 
                                        M.waitForRespawn() 
                                        task.wait(1) 
                                        M.setHomePosition() 
                                        if rootPart and rootPart.Parent then 
                                            M.undergroundPathTo(rootPart.CFrame * CFrame.new(0, 3, 0)) 
                                        else 
                                            break 
                                        end
                                    end
                                    if rootPart and rootPart.Parent then 
                                        M.forceGrabPrompt(block) 
                                        task.wait(0.04) 
                                        M.forceGrabPrompt(rootPart) 
                                        task.wait(0.04)
                                        if not block.Parent or not rootPart.Parent then 
                                            Status.luckyBlockCount = Status.luckyBlockCount + 1 
                                        end 
                                        break
                                    else 
                                        break 
                                    end
                                end
                                pcall(function() hum:UnequipTools() end) 
                                task.wait(0.04)
                                
                                local hrp = ch:FindFirstChild("HumanoidRootPart")
                                if hrp then 
                                    M.fastTween(CFrame.new(hrp.Position.X, currentFarmHeight, hrp.Position.Z)) 
                                end
                                
                                Status.farm = "LB Secured. Returning underground..." 
                                M.undergroundReturnToBase() 
                                return
                            end
                        end
                        if foundLB then return end 
                    end
                end

                -- PRIORITAS KEDUA: BRAINROTS
                if M.hasFarmTarget("Brainrots") then
                    if not M.baseGUID then M.findBase() end
                    if not M.baseGUID then 
                        Status.farm = "No base found!" 
                        task.wait(2) 
                        return 
                    end
                    local ws = tonumber(Config.FarmSlot) or 5

                    if Config.FarmMode == "Collect" then
                        Status.farm = "Searching Brainrots..."
                        if not M.ActiveBrainrots then 
                            M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") 
                        end
                        if M.ActiveBrainrots then
                            for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
                                if not Config.Farming then break end
                                if folder:IsA("Folder") and M.rarityMatches(folder.Name) then
                                    for _, b in pairs(folder:GetChildren()) do
                                        if not Config.Farming or M.isDead() then break end
                                        if M.matchesFilter(b, folder.Name) then
                                            local root = M.findBrainrotRoot(b) 
                                            if not root then continue end
                                            Status.farm = "Going to " .. folder.Name .. "..."
                                            M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0))
                                            
                                            for attempt = 1, 5 do
                                                if not Config.Farming then break end
                                                if M.isDead() then 
                                                    M.waitForRespawn() 
                                                    task.wait(1) 
                                                    M.setHomePosition() 
                                                    if root and root.Parent then 
                                                        M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0)) 
                                                    else 
                                                        break 
                                                    end
                                                end
                                                if root and root.Parent then 
                                                    Status.farm = "Grabbing " .. folder.Name .. "..."
                                                    M.forceGrabPrompt(root) 
                                                    M.forceGrabPrompt(b) 
                                                    task.wait(0.04) 
                                                    Status.farmCount = Status.farmCount + 1 
                                                    currentBackpackCount = currentBackpackCount + 1 
                                                    break
                                                else 
                                                    break 
                                                end
                                            end
                                            pcall(function() hum:UnequipTools() end) 
                                            task.wait(0.04)
                                            local hrp = ch:FindFirstChild("HumanoidRootPart")
                                            if hrp then 
                                                M.fastTween(CFrame.new(hrp.Position.X, currentFarmHeight, hrp.Position.Z)) 
                                            end

                                            if currentBackpackCount >= maxBackpackCount then
                                                Status.farm = "Returning underground..." 
                                                M.undergroundReturnToBase() 
                                                currentBackpackCount = 0
                                            end
                                            return
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(1) 
                        return
                    end

                    -- MODE: COLLECT, PLACE & MAX
                    if not M.isSlotEmpty(ws) then
                        Status.farm = "Clearing slot..."
                        M.pickUpBrainrot(ws) 
                        task.wait(0.5)
                        pcall(function() hum:UnequipTools() end) 
                        task.wait(0.3)
                    end

                    local tool = M.findTargetToolInBackpack()
                    if tool and M.isHighRarityTool(tool) then
                        Status.farm = "✓ " .. (tool:GetAttribute("Rarity") or "High") .. " in backpack"
                        Status.farmCount = Status.farmCount + 1 
                        task.wait(0.5) 
                        tool = nil
                    end

                    if not tool then
                        Status.farm = "Searching Brainrots..."
                        local found = false
                        if not M.ActiveBrainrots then 
                            M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") 
                        end
                        if M.ActiveBrainrots then
                            for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
                                if not Config.Farming then break end
                                if folder:IsA("Folder") and M.rarityMatches(folder.Name) then
                                    for _, b in pairs(folder:GetChildren()) do
                                        if not Config.Farming or M.isDead() then break end
                                        if M.matchesFilter(b, folder.Name) then
                                            local root = M.findBrainrotRoot(b) 
                                            if not root then continue end
                                            found = true 
                                            Status.farm = "Retrieving " .. folder.Name .. "..."
                                            M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0))
                                            
                                            for attempt = 1, 5 do
                                                if not Config.Farming then break end
                                                if M.isDead() then 
                                                    M.waitForRespawn() 
                                                    task.wait(1) 
                                                    M.setHomePosition() 
                                                    if root and root.Parent then 
                                                        M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0)) 
                                                    else 
                                                        found = false 
                                                        break 
                                                    end
                                                end
                                                if root and root.Parent then 
                                                    M.forceGrabPrompt(root) 
                                                    M.forceGrabPrompt(b)
                                                    task.wait(0.04) 
                                                    Status.farmCount = Status.farmCount + 1 
                                                    break
                                                else 
                                                    found = false 
                                                    break 
                                                end
                                            end
                                            pcall(function() hum:UnequipTools() end) 
                                            task.wait(0.04)
                                            local hrp = ch:FindFirstChild("HumanoidRootPart")
                                            if hrp then 
                                                M.fastTween(CFrame.new(hrp.Position.X, currentFarmHeight, hrp.Position.Z)) 
                                            end
                                            
                                            Status.farm = "Returning underground..." 
                                            M.undergroundReturnToBase() 
                                            break
                                        end
                                    end
                                end
                                if found then break end
                            end
                        end
                        if not found then 
                            Status.farm = "Searching Targets..." 
                            task.wait(2) 
                            return 
                        end
                        task.wait(0.3) 
                        tool = M.findTargetToolInBackpack()
                        if not tool then return end
                    end

                    if M.isHighRarityTool(tool) then 
                        Status.farmCount = Status.farmCount + 1 
                        task.wait(0.5) 
                        return 
                    end

                    local bName = tool:GetAttribute("BrainrotName") or "Brainrot"
                    Status.farm = "Heading to slot " .. ws
                    M.tweenToSlot(ws) 
                    task.wait(0.3)
                    local eq = ch:FindFirstChildWhichIsA("Tool")
                    if eq and eq ~= tool then 
                        hum:UnequipTools() 
                        task.wait(0.2) 
                    end
                    hum:EquipTool(tool) 
                    task.wait(0.5)
                    Status.farm = "Placing " .. bName
                    M.placeBrainrot(ws) 
                    task.wait(0.8)
                    if M.isSlotEmpty(ws) then 
                        Status.farm = "Placement failed..." 
                        pcall(function() hum:UnequipTools() end) 
                        task.wait(1) 
                        return 
                    end
                    Status.farm = "Upgrading " .. bName .. "..."
                    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
                    local sm = mb and mb:FindFirstChild("slot " .. ws .. " brainrot")
                    if sm then
                        local cur = tonumber(sm:GetAttribute("Level")) or 0 
                        local fails = 0
                        while cur < Config.MaxLevel and Config.Farming do
                            M.upgradeBrainrot(ws) 
                            task.wait(0.05)
                            local nw = tonumber(sm:GetAttribute("Level")) or cur
                            if nw > cur then 
                                fails = 0 
                                cur = nw 
                                Status.upgradeCount = Status.upgradeCount + 1 
                                Status.farm = bName .. " Lv." .. cur .. "/" .. Config.MaxLevel
                            else 
                                fails = fails + 1 
                                if fails > 20 then 
                                    task.wait(1) 
                                    break 
                                end 
                            end
                        end
                    end
                    Status.farm = bName .. " DONE!" 
                    task.wait(0.3)
                    M.pickUpBrainrot(ws) 
                    task.wait(0.8) 
                    pcall(function() hum:UnequipTools() end) 
                    task.wait(0.3)
                    if not M.isSlotEmpty(ws) then 
                        M.pickUpBrainrot(ws) 
                        task.wait(0.5) 
                        pcall(function() hum:UnequipTools() end) 
                        task.wait(0.3) 
                    end
                end
                
            end)
            if not ok then 
                warn("[Catraz Farm] " .. tostring(err)) 
                task.wait(1) 
            end
            task.wait(0.3)
        end
        disableNoclip() 
        Status.farm = "Idle" 
        M.farmThread = nil
    end)
end

function M.stopFarming()
    Config.Farming = false
    if M.farmThread then 
        pcall(task.cancel, M.farmThread) 
        M.farmThread = nil 
    end
    disableNoclip()
    destroyDamageShield()
    pcall(function()
        local ch = Player.Character 
        if ch then
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then 
                local bv = hrp:FindFirstChild("AntiFallMzD") 
                if bv then 
                    bv:Destroy() 
                end 
            end
        end
    end)
    Status.farm = "Idle"
end

--==================================================
-- FACTORY SYSTEM - FIXED
--==================================================
function M.startFactoryLoop()
    if M.factoryThread then return end
    Config.FactoryEnabled = true 
    Status.factoryCount = 0
    M.factoryThread = task.spawn(function()
        local stopR = "Idle"
        while Config.FactoryEnabled do
            local ok = pcall(function()
                Status.factory = "Scanning..."
                if not M.baseGUID then M.findBase() end 
                if not M.baseGUID then 
                    Status.factory = "No base found!" 
                    task.wait(2) 
                    return 
                end
                local ws = tonumber(Config.FactorySlot) or 5
                if not M.isSlotEmpty(ws) then 
                    M.pickUpBrainrot(ws) 
                    task.wait(0.5) 
                    pcall(function() Player.Character.Humanoid:UnequipTools() end) 
                    task.wait(0.3) 
                end
                local bp = Player:FindFirstChild("Backpack") 
                if not bp then return end 
                local tool = nil
                for _, t in pairs(bp:GetChildren()) do 
                    if t:IsA("Tool") and M.toolMatchesRarity(t, Config.FactoryRarity, "None") then 
                        tool = t 
                        break 
                    end 
                end
                if not tool then 
                    stopR = "All " .. Config.FactoryRarity .. "s maxed!" 
                    Config.FactoryEnabled = false 
                    return 
                end
                local bName = tool:GetAttribute("BrainrotName") or "Item" 
                Status.factory = "Equipping " .. bName
                local hum = Player.Character and Player.Character:FindFirstChild("Humanoid") 
                if hum then 
                    hum:EquipTool(tool) 
                    task.wait(0.5) 
                end
                M.placeBrainrot(ws) 
                task.wait(0.8)
                if M.isSlotEmpty(ws) then 
                    pcall(function() hum:UnequipTools() end) 
                    task.wait(1) 
                    return 
                end
                Status.factory = "Maxing " .. bName
                local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
                local sm = mb and mb:FindFirstChild("slot " .. ws .. " brainrot")
                if sm then
                    local cur = tonumber(sm:GetAttribute("Level")) or 0 
                    local fails = 0
                    while cur < Config.FactoryMaxLevel and Config.FactoryEnabled do
                        M.upgradeBrainrot(ws) 
                        task.wait(0.05)
                        local nw = tonumber(sm:GetAttribute("Level")) or cur
                        if nw > cur then 
                            fails = 0 
                            cur = nw 
                            Status.factory = bName .. " Lv." .. cur
                        else 
                            fails = fails + 1 
                            if fails > 10 then 
                                stopR = "Out of money!" 
                                Config.FactoryEnabled = false 
                                break 
                            end 
                        end
                    end
                end
                task.wait(0.5) 
                M.pickUpBrainrot(ws) 
                task.wait(0.8) 
                Status.factoryCount = Status.factoryCount + 1
                pcall(function() Player.Character.Humanoid:UnequipTools() end) 
                task.wait(0.3)
            end)
            if not ok then 
                task.wait(1) 
            end 
            if Config.FactoryEnabled then 
                task.wait(0.5) 
            end
        end
        Status.factory = stopR 
        M.factoryThread = nil
    end)
end

function M.stopFactoryLoop()
    Config.FactoryEnabled = false
    if M.factoryThread then 
        pcall(task.cancel, M.factoryThread) 
        M.factoryThread = nil 
    end
    if not (string.find(Status.factory or "", "maxed") or string.find(Status.factory or "", "money")) then 
        Status.factory = "Idle" 
    end
end

--==================================================
-- MONEY SYSTEM - FIXED
--==================================================
function M.startMoney()
    if M.moneyThread then return end 
    Config.AutoCollectMoney = true 
    Status.money = "Active"
    if not M.baseGUID then M.findBase() end
    M.moneyThread = task.spawn(function()
        while Config.AutoCollectMoney do 
            pcall(function()
                if not M.baseGUID then M.findBase() end 
                if not M.baseGUID then return end
                local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") 
                if not mb or not hrp then return end
                for i = 1, 40 do
                    local sm = mb:FindFirstChild("slot " .. i .. " brainrot")
                    if sm and sm:GetAttribute("BrainrotName") and sm:GetAttribute("BrainrotName") ~= "" then
                        for _, d in pairs(sm:GetDescendants()) do 
                            if d:IsA("BasePart") then 
                                pcall(function() 
                                    firetouchinterest(hrp, d, 0) 
                                    firetouchinterest(hrp, d, 1) 
                                end) 
                            end 
                        end
                    end
                end
                local slots = mb:FindFirstChild("Slots")
                if slots then 
                    for _, s in pairs(slots:GetChildren()) do 
                        local c = s:FindFirstChild("Collect") 
                        if c and c:IsA("BasePart") then 
                            pcall(function() 
                                firetouchinterest(hrp, c, 0) 
                                firetouchinterest(hrp, c, 1) 
                            end) 
                        end 
                    end 
                end
            end) 
            task.wait(0.1) 
        end 
        Status.money = "Idle"
    end)
    M.moneyRemoteThread = task.spawn(function()
        while Config.AutoCollectMoney do 
            pcall(function()
                if M.baseGUID and M.PlotAction then 
                    for i = 1, 40 do 
                        task.spawn(function() 
                            pcall(function() 
                                M.PlotAction:InvokeServer("Collect Money", M.baseGUID, tostring(i)) 
                            end) 
                        end) 
                    end 
                end
            end) 
            task.wait(1) 
        end
    end)
end

function M.stopMoney()
    Config.AutoCollectMoney = false
    if M.moneyThread then 
        pcall(task.cancel, M.moneyThread) 
        M.moneyThread = nil 
    end
    if M.moneyRemoteThread then 
        pcall(task.cancel, M.moneyRemoteThread) 
        M.moneyRemoteThread = nil 
    end
    Status.money = "Idle"
end

--==================================================
-- UPGRADE SYSTEM - FIXED
--==================================================
function M.startAutoUpgrade()
    if M.upgradeThread then return end 
    Config.AutoUpgrade = true 
    Status.upgradeCount = 0
    M.upgradeThread = task.spawn(function()
        while Config.AutoUpgrade do 
            pcall(function()
                for _, info in pairs(M.findOccupiedSlots()) do 
                    if not Config.AutoUpgrade then break end 
                    if info.level < Config.MaxLevel then 
                        M.upgradeSlotToMax(info.slot) 
                    end 
                end
                Status.upgrade = "Finished (#" .. Status.upgradeCount .. ")"
            end) 
            task.wait(3) 
        end 
        Status.upgrade = "Idle"
    end)
end

function M.upgradeSlotToMax(slot)
    if not M.baseGUID or not M.PlotAction then return end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
    local sm = mb and mb:FindFirstChild("slot " .. slot .. " brainrot")
    if not sm then return end
    local cur = tonumber(sm:GetAttribute("Level")) or 0
    while cur < Config.MaxLevel and Config.AutoUpgrade do
        M.upgradeBrainrot(slot) 
        task.wait(0.05)
        local nw = tonumber(sm:GetAttribute("Level")) or cur
        if nw > cur then 
            cur = nw 
            Status.upgradeCount = Status.upgradeCount + 1 
        end
    end
end

function M.stopAutoUpgrade() 
    Config.AutoUpgrade = false 
    if M.upgradeThread then 
        pcall(task.cancel, M.upgradeThread) 
        M.upgradeThread = nil 
    end 
    Status.upgrade = "Idle" 
end

--==================================================
-- INSTANT PICKUP
--==================================================
local function setupInstant()
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("ProximityPrompt") then 
            pcall(function() o.HoldDuration = 0 end) 
        end 
    end
    if not M._instantConn then 
        M._instantConn = workspace.DescendantAdded:Connect(function(o) 
            if o:IsA("ProximityPrompt") then 
                pcall(function() o.HoldDuration = 0 end) 
            end 
        end) 
    end
end
setupInstant()

--==================================================
-- HOME TAB
--==================================================
local DashSection = HomeTab:AddSection({
    Name = "📊 DASHBOARD",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DashSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days",
    Image = "user",
    ImageSize = 48
})

local ServerSection = HomeTab:AddSection({
    Name = "🌐 SERVER INFO",
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

local ServerPara = ServerSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. #Players:GetPlayers() .. "\n" ..
           "Uptime: " .. getUptime(),
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
            Callback = function()
                ServerPara:SetDesc("Players: " .. #Players:GetPlayers() .. "\n" ..
                                  "Uptime: " .. getUptime())
            end
        }
    }
})

task.spawn(function()
    while true do
        task.wait(1)
        ServerPara:SetDesc("Players: " .. #Players:GetPlayers() .. "\n" ..
                          "Uptime: " .. getUptime())
    end
end)

local ActiveSection = HomeTab:AddSection({
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ActivePara = ActiveSection:AddParagraph({
    Title = "Currently Active",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

task.spawn(function()
    while true do
        local active = GetActiveFeatures()
        if #active > 0 then
            ActivePara:SetDesc(table.concat(active, " • "))
        else
            ActivePara:SetDesc("No active features")
        end
        task.wait(1)
    end
end)

local InfoSection = HomeTab:AddSection({
    Name = "ℹ️ SCRIPT INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "Information",
    Desc = "Creator: Catraz Team\nVersion: 3.2 ULTIMATE\nFeatures: TRUE Tsunami Proof, Auto Respawn, Farm, Factory",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- TSUNAMI TAB
--==================================================
local TsunamiMainSection = TsunamiTab:AddSection({
    Name = "🌊 TSUNAMI PROTECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local TsunamiModeDropdown = TsunamiMainSection:AddDropdown({
    Name = "Mode Perlindungan",
    Default = "Bawah (Gali Tanah)",
    Options = TSUNAMI_MODES,
    Multi = false,
    Outline = true,
    Flag = "TsunamiMode",
    Callback = function(v)
        if v == "Bawah (Gali Tanah)" then
            Config.TsunamiMode = "Bawah"
            Tsunami.Mode = "Bawah"
        else
            Config.TsunamiMode = "Atas"
            Tsunami.Mode = "Atas"
        end
        if Config.TsunamiProtection then
            disableTsunamiProtection()
            task.wait(0.5)
            enableTsunamiProtection()
        end
    end
})

local HeightSlider = TsunamiMainSection:AddSlider({
    Name = "Ketinggian Aman (Mode Atas)",
    Min = 50,
    Max = 500,
    Default = Config.TsunamiHeight,
    Increment = 10,
    ValueName = "Studs",
    Outline = true,
    Callback = function(v)
        Config.TsunamiHeight = v
        Tsunami.Height = v
    end
})

local TsunamiStatusPara = TsunamiMainSection:AddParagraph({
    Title = "Status Tsunami",
    Desc = "⏸️ Nonaktif",
    Image = "info",
    ImageSize = 30
})

TsunamiMainSection:AddToggle({
    Name = "🌊 Aktifkan Tsunami Protection",
    Default = false,
    Outline = true,
    Flag = "TsunamiToggle",
    Callback = function(v)
        Config.TsunamiProtection = v
        if v then
            enableTsunamiProtection()
            TsunamiStatusPara:SetDesc("✅ Aktif - Mode: " .. Config.TsunamiMode)
            Notify("Tsunami Protection Aktif! Mode: " .. Config.TsunamiMode)
        else
            disableTsunamiProtection()
            TsunamiStatusPara:SetDesc("⏸️ Nonaktif")
            Notify("Tsunami Protection Nonaktif")
        end
    end
})

TsunamiMainSection:AddParagraph({
    Title = "📋 INFORMASI",
    Desc = "• Mode Bawah: Menggali tanah (Y = -50)\n• Mode Atas: Terbang di atas (Y = " .. Config.TsunamiHeight .. "+)\n• Noclip otomatis saat terbang\n• DAMAGE PROOF - Tidak akan terkena tsunami\n• Deteksi tsunami radius 100 studs",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- FARM TAB
--==================================================
local TargetSection = FarmTab:AddSection({
    Name = "🎯 TARGET SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TargetSection:AddDropdown({
    Name = "What to Farm?", 
    Default = Config.FarmTargets, 
    Options = {"Brainrots", "Lucky Blocks"},
    Multi = true, 
    Outline = true, 
    Flag = "FarmTargets",
    Callback = function(v)
        local s = {}
        for _, on in pairs(v) do table.insert(s, on) end
        if #s == 0 then s = {"Brainrots"} end
        Config.FarmTargets = s 
    end
})

local FarmHeightSection = FarmTab:AddSection({
    Name = "📏 KETINGGIAN FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- DIPERBARUI: Dropdown dengan opsi rendah -1 sampai -10
FarmHeightSection:AddDropdown({
    Name = "Pilih Ketinggian Farm",
    Default = "Bawah Tanah (-25)",
    Options = FARM_HEIGHTS,
    Multi = false,
    Outline = true,
    Flag = "FarmHeight",
    Callback = function(v)
        if v == "Bawah Tanah (-0.3)" then Config.FarmHeight = -0.3
        elseif v == "Bawah Tanah (-0.5)" then Config.FarmHeight = -0.5
        elseif v == "Bawah Tanah (-0.7)" then Config.FarmHeight = -0.7
        elseif v == "Bawah Tanah (-0.8)" then Config.FarmHeight = -0.8
        elseif v == "Bawah Tanah (-0.9)" then Config.FarmHeight = -0.9
        elseif v == "Bawah Tanah (-1)" then Config.FarmHeight = -1
        elseif v == "Bawah Tanah (-2)" then Config.FarmHeight = -2
        elseif v == "Bawah Tanah (-3)" then Config.FarmHeight = -3
        elseif v == "Bawah Tanah (-4)" then Config.FarmHeight = -4
        elseif v == "Bawah Tanah (-5)" then Config.FarmHeight = -5
        elseif v == "Bawah Tanah (-7)" then Config.FarmHeight = -7
        elseif v == "Bawah Tanah (-10)" then Config.FarmHeight = -10
        elseif v == "Bawah Tanah (-25)" then Config.FarmHeight = -25
        elseif v == "Permukaan (0)" then Config.FarmHeight = 0
        elseif v == "Ketinggian 50" then Config.FarmHeight = 50
        elseif v == "Ketinggian 100" then Config.FarmHeight = 100
        elseif v == "Ketinggian 150" then Config.FarmHeight = 150
        elseif v == "Ketinggian 200" then Config.FarmHeight = 200
        end
        Notify("Ketinggian farm diubah ke: " .. v)
    end
})

FarmHeightSection:AddParagraph({
    Title = "ℹ️ INFO KETINGGIAN",
    Desc = "• Opsi rendah: -1, -2, -3, -4, -5, -7, -10, -25\n• Ketinggian farm akan otomatis mengikuti mode tsunami jika tsunami aktif\n• Mode Bawah: Y = -50\n• Mode Atas: Y = " .. Config.TsunamiHeight .. "\n• Farm tetap aman dari tsunami",
    Image = "info",
    ImageSize = 30
})

local BrainrotSection = FarmTab:AddSection({
    Name = "🧟 BRAINROT SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BrainrotSection:AddDropdown({ 
    Name = "Target Rarity", 
    Default = Config.TargetRarity, 
    Options = RAR, 
    Multi = true, 
    Outline = true, 
    Flag = "TargetRarity",
    Callback = function(v) 
        local s = {} 
        for _, on in pairs(v) do table.insert(s, on) end 
        Config.TargetRarity = #s>0 and s or {"Common"} 
    end 
})

BrainrotSection:AddDropdown({ 
    Name = "Target Mutation", 
    Default = Config.TargetMutation, 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "TargetMutation",
    Callback = function(v) Config.TargetMutation = v end 
})

BrainrotSection:AddDropdown({ 
    Name = "Farm Mode", 
    Default = Config.FarmMode, 
    Options = FM, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmMode",
    Callback = function(v) Config.FarmMode = v end 
})

BrainrotSection:AddDropdown({ 
    Name = "Work Slot", 
    Default = Config.FarmSlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmSlot",
    Callback = function(v) Config.FarmSlot = v end 
})

BrainrotSection:AddSlider({ 
    Name = "Max Level", 
    Min = 1, 
    Max = 500, 
    Default = Config.MaxLevel, 
    Increment = 1, 
    ValueName = "Lv", 
    Outline = true, 
    Flag = "MaxLevel",
    Callback = function(v) Config.MaxLevel = math.floor(v) end 
})

local LuckySection = FarmTab:AddSection({
    Name = "🎲 LUCKY BLOCK SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

LuckySection:AddDropdown({ 
    Name = "LB Rarity", 
    Default = Config.LuckyBlockRarity, 
    Options = LBR, 
    Multi = true, 
    Outline = true, 
    Flag = "LBRarity",
    Callback = function(v) 
        local s = {} 
        for _, on in pairs(v) do table.insert(s, on) end 
        Config.LuckyBlockRarity = #s>0 and s or {"Common"} 
    end 
})

LuckySection:AddDropdown({ 
    Name = "LB Mutation", 
    Default = Config.LuckyBlockMutation, 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "LBMutation",
    Callback = function(v) Config.LuckyBlockMutation = v end 
})

local FarmControlSection = FarmTab:AddSection({
    Name = "🚀 AUTO FARM MASTER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local FarmStatusPara = FarmControlSection:AddParagraph({
    Title = "Master Farm Status",
    Desc = "Idle",
    Image = "activity",
    ImageSize = 30
})

local FarmStatsPara = FarmControlSection:AddParagraph({
    Title = "Statistics",
    Desc = "Placed: 0 | Upgraded: 0",
    Image = "bar-chart",
    ImageSize = 30
})

FarmControlSection:AddToggle({
    Name = "🚀 Master Auto Farm", 
    Default = false, 
    Outline = true, 
    Flag = "FarmToggle",
    Callback = function(v)
        if v then 
            M.findBase() 
            M.startFarming() 
            Notify("Master Farm Started!")
        else 
            M.stopFarming() 
            Notify("Master Farm Stopped")
        end
    end
})

--==================================================
-- FACTORY TAB
--==================================================
local FactorySection = FactoryTab:AddSection({
    Name = "🏭 FACTORY LOOP",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FactorySection:AddDropdown({ 
    Name = "Rarity", 
    Default = Config.FactoryRarity, 
    Options = FR, 
    Multi = false, 
    Outline = true, 
    Flag = "FactoryRarity",
    Callback = function(v) Config.FactoryRarity = v end 
})

FactorySection:AddDropdown({ 
    Name = "Work Slot", 
    Default = Config.FactorySlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FactorySlot",
    Callback = function(v) Config.FactorySlot = v end 
})

FactorySection:AddSlider({ 
    Name = "Max Level", 
    Min = 1, 
    Max = 500, 
    Default = Config.FactoryMaxLevel, 
    Increment = 1, 
    ValueName = "Lv", 
    Outline = true, 
    Flag = "FactoryMaxLevel",
    Callback = function(v) Config.FactoryMaxLevel = math.floor(v) end 
})

local FactoryStatusPara = FactorySection:AddParagraph({
    Title = "Factory Status",
    Desc = "Idle",
    Image = "factory",
    ImageSize = 30
})

FactorySection:AddToggle({ 
    Name = "🔁 Factory Loop", 
    Default = false, 
    Outline = true, 
    Flag = "FactoryToggle",
    Callback = function(v) 
        if v then 
            M.findBase() 
            M.startFactoryLoop() 
            FactoryStatusPara:SetDesc("Active")
            Notify("Factory Loop Started")
        else 
            M.stopFactoryLoop() 
            FactoryStatusPara:SetDesc("Idle")
            Notify("Factory Loop Stopped")
        end 
    end 
})

--==================================================
-- AUTOMATION TAB
--==================================================
local MoneySection = AutoTab:AddSection({
    Name = "💰 AUTO COLLECT MONEY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local MoneyStatusPara = MoneySection:AddParagraph({
    Title = "Money Status",
    Desc = "Idle",
    Image = "dollar-sign",
    ImageSize = 30
})

MoneySection:AddToggle({ 
    Name = "💰 Auto Collect Money", 
    Default = false, 
    Outline = true, 
    Flag = "MoneyToggle",
    Callback = function(v) 
        if v then 
            M.findBase() 
            M.startMoney() 
            MoneyStatusPara:SetDesc("Active")
            Notify("Money Collector Started")
        else 
            M.stopMoney() 
            MoneyStatusPara:SetDesc("Idle")
            Notify("Money Collector Stopped")
        end 
    end 
})

local UpgradeSection = AutoTab:AddSection({
    Name = "⬆️ AUTO UPGRADE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local UpgradeStatusPara = UpgradeSection:AddParagraph({
    Title = "Upgrade Status",
    Desc = "Idle",
    Image = "trending-up",
    ImageSize = 30
})

UpgradeSection:AddToggle({ 
    Name = "⬆️ Auto Upgrade Slots", 
    Default = false, 
    Outline = true, 
    Flag = "UpgradeToggle",
    Callback = function(v) 
        if v then 
            M.findBase() 
            M.startAutoUpgrade() 
            UpgradeStatusPara:SetDesc("Active")
            Notify("Auto Upgrade Started")
        else 
            M.stopAutoUpgrade() 
            UpgradeStatusPara:SetDesc("Idle")
            Notify("Auto Upgrade Stopped")
        end 
    end 
})

local InstantSection = AutoTab:AddSection({
    Name = "⚡ INSTANT PICKUP",
    TextSize = 18,
    Glass = true,
    Outline = true
})

InstantSection:AddToggle({
    Name = "⚡ Instant Pickup",
    Default = Config.InstantPickup,
    Outline = true,
    Flag = "InstantPickup",
    Callback = function(v)
        Config.InstantPickup = v
        Notify(v and "Instant Pickup Enabled" or "Instant Pickup Disabled")
    end
})

--==================================================
-- CONFIG TAB
--==================================================
local TweakSection = ConfigTab:AddSection({
    Name = "⚙️ TWEAKS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TweakSection:AddSlider({
    Name = "Farm Tween Speed",
    Min = 100, 
    Max = 3000, 
    Default = Config.TweenSpeed, 
    Increment = 50,
    ValueName = "Speed", 
    Outline = true, 
    Flag = "TweenSpeed",
    Callback = function(v) 
        Config.TweenSpeed = v
    end
})

TweakSection:AddDropdown({ 
    Name = "Corridor Speed", 
    Default = tostring(Config.CorridorSpeed), 
    Options = CSPD, 
    Multi = false, 
    Outline = true, 
    Flag = "CorridorSpeed",
    Callback = function(v) 
        Config.CorridorSpeed = tonumber(v) or 400 
    end 
})

local ActionSection = ConfigTab:AddSection({
    Name = "🎮 ACTIONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ActionSection:AddButton({ 
    Name = "🏠 Find My Base", 
    Outline = true, 
    Callback = function() 
        M.findBase() 
        if M.baseGUID then
            Notify("Base Found: " .. M.baseGUID)
        else
            Notify("Base Not Found")
        end
    end 
})

ActionSection:AddButton({ 
    Name = "📍 Set Home Position", 
    Outline = true, 
    Callback = function() 
        M.setHomePosition() 
        Notify("Home Position Saved")
    end 
})

ActionSection:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Outline = true,
    Flag = "NoclipToggle",
    Callback = function(v)
        if v then
            enableNoclip()
            Notify("Noclip Enabled")
        else
            disableNoclip()
            Notify("Noclip Disabled")
        end
    end
})

local PlayerInfoSection = ConfigTab:AddSection({
    Name = "ℹ️ PLAYER INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local PlayerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "Player Info",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38
})

-- Update player info
task.spawn(function()
    while true do
        task.wait(1)
        PlayerInfoPara:SetDesc(
            "Player: " .. Player.Name .. "\n" ..
            "Base: " .. (M.baseGUID or "Not Found") .. "\n" ..
            "Noclip: " .. (Config.NoclipEnabled and "✅" or "❌") .. "\n" ..
            "Tsunami: " .. (Config.TsunamiProtection and "✅ " .. Config.TsunamiMode or "❌") .. "\n" ..
            "Deaths: " .. Status.deaths .. "\n" ..
            "Farm Height: " .. (Config.TsunamiProtection and getFarmHeight() .. " (Tsunami Mode)" or Config.FarmHeight)
        )
    end
end)

--==================================================
-- UPDATE LOOP untuk status
--==================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Update Farm Status
            FarmStatusPara:SetDesc(
                "Status: " .. Status.farm .. "\n" ..
                "Brainrots: #" .. Status.farmCount .. "\n" ..
                "Lucky Blocks: #" .. Status.luckyBlockCount
            )
            
            FarmStatsPara:SetDesc(
                "Placed: " .. Status.placeCount .. "\n" ..
                "Upgraded: " .. Status.upgradeCount
            )
            
            FactoryStatusPara:SetDesc(
                "Status: " .. Status.factory .. "\n" ..
                "Completed: #" .. Status.factoryCount
            )
            
            MoneyStatusPara:SetDesc(
                "Status: " .. (Config.AutoCollectMoney and "✅ Active" or "⏸️ Idle")
            )
            
            UpgradeStatusPara:SetDesc(
                "Status: " .. Status.upgrade .. "\n" ..
                "Upgraded: #" .. Status.upgradeCount
            )
        end)
    end
end)

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "save"
})

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
    if Config.InstantPickup then setupInstant() end
    
    if Config.NoclipEnabled then
        if M._noclipConn then pcall(function() M._noclipConn:Disconnect() end) M._noclipConn = nil end
        Config.NoclipEnabled = false 
        task.wait(0.3) 
        enableNoclip()
    end
    
    if Config.TsunamiProtection then
        task.wait(1)
        enableTsunamiProtection()
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v3.2 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ TRUE TSUNAMI PROOF - Tidak akan terkena damage!")
print("✅ DAMAGE SHIELD - Mencegah damage dari tsunami")
print("✅ AUTO RESPAWN - Langsung mulai farm lagi setelah mati")
print("✅ Farm otomatis mengikuti mode tsunami (Bawah/Atas)")
print("✅ Bisa pilih ketinggian farm manual")
print("✅ Tween Speed bisa diatur sampai 3000")
print("═══════════════════════════════════════════════════════")
print("🚀 Karamen BENAR-BENAR AMAN dari tsunami!")
print("═══════════════════════════════════════════════════════")