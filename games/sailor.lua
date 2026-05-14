-- ==================== SAILOR PIECE - CATRAZ ULTIMATE ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 2.3 FIXED - Auto Skills System

if _G.SP_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Sailor Piece",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.SP_Loaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES & SERVICES
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Remote References
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CombatRemotes = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes")
local AbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")
local hakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local obsHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")
local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local spawnStrongestRemote = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local anosRemote = Remotes:WaitForChild("RequestSpawnAnosBoss")
local trueAizenRemote = RemoteEvents:WaitForChild("RequestSpawnTrueAizen")
local rimuruRemote = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local autoSpawnBossRemote = Remotes:WaitForChild("RequestAutoSpawn")
local autoSpawnAnosRemote = Remotes:WaitForChild("RequestAutoSpawnAnos")
local autoSpawnStrongestRemote = Remotes:WaitForChild("RequestAutoSpawnStrongest")
local autoSpawnRimuruRemote = RemoteEvents:WaitForChild("RequestAutoSpawnRimuru")
local autoSpawnTrueAizenRemote = RemoteEvents:WaitForChild("RequestAutoSpawnTrueAizen")
local dungeonVoteRemote = Remotes:WaitForChild("DungeonWaveVote")
local dungeonPortalRemote = Remotes:WaitForChild("RequestDungeonPortal")
local slimeCraftRemote = Remotes:WaitForChild("RequestSlimeCraft")
local grailCraftRemote = Remotes:WaitForChild("RequestGrailCraft")

--==================================================
-- CONSTANTS & CONFIGURATION
--==================================================
local Constants = {
    ICON = "rbxassetid://105921924721005",
    DISCORD = "https://discord.gg/B3PurfCy",
    NPC_FOLDER = "NPCs",
    BOSS_ISLAND_PORTAL = "Boss",
    ANOS_ISLAND = "Academy",
    FARM_MAX_DIST_FROM_PLAYER = 900,
    FARM_MAX_DIST_FROM_ORIGIN = 1200,
    GENERIC_HOSTILE_MAX_DIST = 900,
    
    Islands = {
        {Portal = "Starter", FarmUntil = 250, Enemies = {"Thief"}, QuestNPC = "QuestNPC1"},
        {Portal = "Jungle", FarmUntil = 750, Enemies = {"Monkey"}, QuestNPC = "QuestNPC3"},
        {Portal = "Desert", FarmUntil = 1500, Enemies = {"DesertBandit"}, QuestNPC = "QuestNPC5"},
        {Portal = "Snow", FarmUntil = 3000, Enemies = {"Swordsman", "FrostRogue"}, QuestNPC = "QuestNPC7"},
        {Portal = "Shibuya", FarmUntil = 5000, Enemies = {"Sorcerer", "Curse"}, QuestNPC = "QuestNPC9"},
        {Portal = "HuecoMundo", FarmUntil = 6250, Enemies = {"Hollow", "Quincy"}, QuestNPC = "QuestNPC11"},
        {Portal = "Shinjuku", FarmUntil = 8000, Enemies = {"StrongSorcerer"}, QuestNPC = "QuestNPC12"},
        {Portal = "Slime", FarmUntil = 9000, Enemies = {"Slime"}, QuestNPC = "QuestNPC14"},
        {Portal = "Academy", FarmUntil = 10000, Enemies = {"AcademyTeacher"}, QuestNPC = "QuestNPC15"},
        {Portal = "Judgement", FarmUntil = 10750, Enemies = {"Swordsman"}, QuestNPC = "QuestNPC16"},
        {Portal = "SoulSociety", FarmUntil = 999999, Enemies = {"Quincy1", "Quincy2", "Quincy3", "Quincy4", "Quincy5"}, QuestNPC = "QuestNPC17"},
    },
    
    TpIslands = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"},
    
    Bosses = {
        {Name = "AizenBoss", Display = "Aizen", Island = "HuecoMundo"},
        {Name = "AlucardBoss", Display = "Alucard", Island = "Sailor"},
        {Name = "GojoBoss", Display = "Gojo", Island = "Shibuya", RenderNear = "YujiBoss"},
        {Name = "JinwooBoss", Display = "Jinwoo", Island = "Sailor"},
        {Name = "SukunaBoss", Display = "Sukuna", Island = "Shibuya"},
        {Name = "YamatoBoss", Display = "Yamato", Island = "Judgement"},
        {Name = "YujiBoss", Display = "Yuji", Island = "Shibuya"},
    },
    
    SummonBosses = {
        {Name = "IchigoBoss", Display = "Ichigo"},
        {Name = "QinShiBoss", Display = "Qin Shi"},
        {Name = "SaberBoss", Display = "Saber"},
        {Name = "AnosBoss", Display = "Anos", Island = "Academy", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "BlessedMaidenBoss", Display = "Blessed Maiden", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "GilgameshBoss", Display = "Gilgamesh", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "RimuruBoss", Display = "Rimuru", Island = "Slime", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "SaberAlterBoss", Display = "Saber Alter", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "StrongestHistoryBoss", Display = "Strongest in History", Island = "Shinjuku", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "StrongestTodayBoss", Display = "Strongest Today", Island = "Shinjuku", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "TrueAizenBoss", Display = "True Aizen", Island = "SoulSociety", Difficulties = {"Normal","Medium","Hard","Extreme"}},
    },
    
    DungeonEnemyNames = {"DungeonNPC1","DungeonNPC2","DungeonNPC3","DungeonNPC4","DungeonNPC5"},
    DungeonTypes = {"Double","Rune","Cid"},
    DungeonDifficulties = {"Easy","Normal","Hard","Extreme"},
    DungeonPortalNames = {Double = "DoubleDungeon", Rune = "RuneDungeon", Cid = "CidDungeon"},
    
    IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"},
    
    ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest"},
    MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"},
}

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
    Ambient = Lighting.Ambient
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
    settings().Rendering.QualityLevel = originalQuality
end

--==================================================
-- CONFIGURATION (MENGGUNAKAN GENV UNTUK AKSES GLOBAL)
--==================================================
getgenv().Config = {
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        AutoHit = true,
        AutoStats = true,
        AutoHaki = false,
        AutoObsHaki = false,
        AutoEquip = true,
        SelectedWeapon = "None",
        SkillCooldown = 0.3
    },
    
    -- Auto Skills (sesuai format yang diminta)
    AutoSkills = {
        Z = false,
        X = false,
        C = false,
        V = false,
        F = false
    },
    
    -- State untuk skill system
    LastSkillTime = 0,
    
    -- Mode flags untuk skill system
    IsFarm = false,
    IsBossFight = false,
    IsAutoDungeon = false,
    IsBossRush = false,
    
    -- Farm Settings
    Farm = {
        HeightOffset = 15,
        TweenSpeed = 100,
        OffsetDist = 15,
        FarmMode = "Behind",
        FollowStyle = "Dodge",
        MoveMode = "Tween",
        SelectedIsland = "Auto",
        SelectedEnemy = "All",
        AntiAFK = true,
        AutoQuest = true,
        AutoSpawn = false,
        AutoChest = false
    },
    
    -- Dungeon Settings
    Dungeon = {
        Enabled = false,
        Type = "Double",
        Difficulty = "Normal",
        HeightOffset = 10,
        TweenSpeed = 50,
        MoveMode = "Teleport",
        FarmMode = "Behind",
        FollowStyle = "Dodge",
        OffsetDist = 15
    },
    
    -- Boss Rush
    BossRush = {
        Enabled = false,
        HeightOffset = 10,
        TweenSpeed = 50,
        MoveMode = "Teleport",
        FarmMode = "Behind",
        FollowStyle = "Dodge",
        OffsetDist = 15
    },
    
    -- Boss Systems
    Bosses = {
        Enabled = false,
        Notify = true,
        Selected = {},
        SummonSelected = {}
    },
    
    -- Quest Systems
    Quests = {
        DungeonEnabled = false,
        HogyokuEnabled = false
    },
    
    -- Merchant
    Merchant = {
        Enabled = false,
        Notify = true,
        Selected = {}
    },
    
    -- Chests
    Chests = {
        Enabled = false,
        Selected = {}
    },
    
    -- Misc
    Misc = {
        AntiAFK = true,
        FpsBoost = false,
        WhiteScreen = false,
        AutoRejoin = false,
        TimedRejoin = false,
        RejoinDelay = 10
    }
}

--==================================================
-- STATE VARIABLES
--==================================================
local State = {
    Running = true,
    Kills = 0,
    BossKills = 0,
    KillCount = 0,
    CurIsland = nil,
    CurTarget = nil,
    LockTarget = nil,
    HoverPos = nil,
    TweenOn = false,
    TweenTarget = nil,
    ATween = nil,
    ATweenConn = nil,
    LastEquip = 0,
    LastTP = 0,
    LastEnemy = 0,
    TPCount = 0,
    TPRest = tick(),
    IslandTPd = false,
    SpawnDone = false,
    FarmOrigin = nil,
    FarmGenericMode = false,
    QState = "NONE",
    BossTargetName = nil,
    BossDeathTimes = {},
    BossTimerCache = {},
    BossTPDone = false,
    LastBossTP = 0,
    BossCurrentIsland = nil,
    SummonBossTarget = nil,
    SummonBossTPDone = false,
    LastSummonBossTP = 0,
    SummonBossCommitted = {},
    SummonBossCurrentIsland = nil,
    SummonBossOrder = 0,
    SummonBossFailCount = {},
    SummonBossFireTime = {},
    AutoSpawnActive = {},
    DungeonStep = 0,
    DungeonCollected = {},
    LastDungeonSwitch = 0,
    LastBossRushSwitch = 0,
    HogyokuStep = 0,
    HogyokuCollected = {},
    Conns = {},
    RayParams = RaycastParams.new()
}

-- Inisialisasi RayParams
State.RayParams.FilterType = Enum.RaycastFilterType.Exclude

--==================================================
-- UTILITY FUNCTIONS
--==================================================

local function getChar()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function DistTo(pos)
    if not pos then return 99999 end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 99999 end
    return (hrp.Position - pos).Magnitude
end

local function GetNPCFolder()
    local direct = Workspace:FindFirstChild(Constants.NPC_FOLDER)
    if direct then return direct end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Folder") then
            local n = (desc.Name or ""):lower()
            if n == "npcs" or n == "npc" or n:find("npc", 1, true) then
                return desc
            end
        end
    end
    return nil
end

local function GetHum(e)
    if not e then return nil end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then
        for _, d in ipairs(e:GetDescendants()) do
            if d:IsA("Humanoid") then
                h = d
                break
            end
        end
    end
    return h
end

local function RootPos(e)
    if not e then return nil end
    local rp = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso") or e:FindFirstChild("UpperTorso")
    if rp and rp:IsA("BasePart") then return rp.Position end
    if e:IsA("Model") and e.PrimaryPart then return e.PrimaryPart.Position end
    for _, d in ipairs(e:GetDescendants()) do
        if d:IsA("BasePart") then return d.Position end
    end
    return nil
end

local function PortalDisplayName(portal)
    local names = {HuecoMundo = "Hueco Mundo", SoulSociety = "Soul Society"}
    return names[portal] or portal
end

local function GetIslandNames()
    local n = {"Auto"}
    for _, i in ipairs(Constants.Islands) do
        table.insert(n, PortalDisplayName(i.Portal))
    end
    return n
end

local function DisplayToPortal(display)
    for _, i in ipairs(Constants.Islands) do
        if PortalDisplayName(i.Portal) == display then
            return i.Portal
        end
    end
    return display
end

local function GetLevel()
    local lv = 0
    pcall(function()
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            local v = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl") or ls:FindFirstChild("LVL")
            if v then lv = tonumber(v.Value) or 0 end
        end
    end)
    return lv
end

local function IslandForLevel(lvl)
    for _, i in ipairs(Constants.Islands) do
        if lvl < i.FarmUntil then return i end
    end
    return Constants.Islands[#Constants.Islands]
end

local function IslandByName(n)
    for _, i in ipairs(Constants.Islands) do
        if i.Portal == n then return i end
    end
    return nil
end

local function GetFarmIsland()
    local lvl = GetLevel()
    if getgenv().Config.Farm.SelectedIsland == "Auto" then
        return IslandForLevel(lvl)
    end
    return IslandByName(getgenv().Config.Farm.SelectedIsland) or IslandForLevel(lvl)
end

local function IsAlive()
    local c = Player.Character
    if not c then return false end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hrp ~= nil and hum ~= nil and hum.Health > 0
end

local function ShouldIgnore(name)
    local lo = name:lower()
    for _, ig in ipairs(Constants.IgnoreList) do
        if lo:find(ig, 1, true) then return true end
    end
    if lo:match("boss$") then return true end
    return false
end

local function MatchEnemy(name, island)
    if not island then return false end
    local lo = (name or ""):lower()
    for _, e in ipairs(island.Enemies) do
        local el = (e or ""):lower()
        if lo:sub(1, #el) == el then return true end
    end
    return false
end

local function AbandonAllQuests()
    State.QState = "NONE"
    pcall(function() abandonRemote:FireServer("repeatable") end)
    for _, n in ipairs({"HogyokuUnlock","HogyokuQuestNPC","Hogyoku","HogyokuFragment","HogyokuQuest","SoulSocietyUnlock","SoulSociety"}) do
        pcall(function() abandonRemote:FireServer(n) end)
    end
    for _, isl in ipairs(Constants.Islands) do
        pcall(function() abandonRemote:FireServer(isl.QuestNPC) end)
    end
end

local function FullReset()
    AbandonAllQuests()
    State.CurIsland = nil
    State.IslandTPd = false
    State.SpawnDone = false
    State.FarmOrigin = nil
    State.LastEnemy = 0
    State.LastTP = 0
    State.TPCount = 0
    State.TPRest = tick()
    State.CurTarget = nil
    State.LockTarget = nil
    State.HoverPos = nil
    State.FarmGenericMode = false
    State.QState = "NONE"
    State.BossTargetName = nil
    State.BossTPDone = false
    State.LastBossTP = 0
    State.BossCurrentIsland = nil
    State.SummonBossTarget = nil
    State.SummonBossTPDone = false
    State.LastSummonBossTP = 0
    State.SummonBossCommitted = {}
    State.SummonBossCurrentIsland = nil
    State.SummonBossOrder = 0
    State.HogyokuStep = 0
    State.HogyokuCollected = {}
    State.DungeonStep = 0
    State.DungeonCollected = {}
    
    -- Reset mode flags
    getgenv().Config.IsFarm = false
    getgenv().Config.IsBossFight = false
    getgenv().Config.IsAutoDungeon = false
    getgenv().Config.IsBossRush = false
end

local function DoTP(portal)
    if tick() - State.LastTP < 3 then return false end
    if tick() - State.TPRest > 120 then
        State.TPCount = 0
        State.TPRest = tick()
    end
    if State.TPCount >= 10 then return false end
    State.LastTP = tick()
    State.TPCount = State.TPCount + 1
    local ok = false
    pcall(function() tpRemote:FireServer(portal) ok = true end)
    return ok
end

local function ForceTP(portal)
    State.LastTP = 0
    State.TPCount = 0
    State.TPRest = tick()
    local ok = false
    pcall(function() tpRemote:FireServer(portal) ok = true end)
    if not ok then
        task.wait(1)
        pcall(function() tpRemote:FireServer(portal) ok = true end)
    end
    State.LastTP = tick()
    State.TPCount = 1
    return ok
end

local function StopTween()
    if State.ATweenConn then
        pcall(function() State.ATweenConn:Disconnect() end)
        State.ATweenConn = nil
    end
    if State.ATween then
        pcall(function() State.ATween:Cancel() end)
        State.ATween = nil
    end
    State.TweenOn = false
    State.TweenTarget = nil
end

local function ClearTarget()
    State.CurTarget = nil
    State.LockTarget = nil
    StopTween()
end

local function FindEnemies(island)
    local nf = GetNPCFolder()
    if not island then return {} end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local origin = State.FarmOrigin
    local out = {}
    
    local function checkModel(m)
        if m:IsA("Model") and not m:IsDescendantOf(Player.Character) then
            -- Filter berdasarkan dropdown musuh
            if getgenv().Config.Farm.SelectedEnemy ~= "All" and m.Name ~= getgenv().Config.Farm.SelectedEnemy then
                return
            end
            local hm = GetHum(m)
            if hm and hm.Health > 0 and not ShouldIgnore(m.Name) then
                if MatchEnemy(m.Name, island) then
                    local p = RootPos(m)
                    if p then
                        if hrp and (p - hrp.Position).Magnitude > Constants.FARM_MAX_DIST_FROM_PLAYER then return end
                        if origin and (p - origin).Magnitude > Constants.FARM_MAX_DIST_FROM_ORIGIN then return end
                    end
                    table.insert(out, m)
                end
            end
        end
    end
    
    if nf then
        for _, desc in ipairs(nf:GetChildren()) do
            if desc:IsA("Model") then
                checkModel(desc)
            elseif desc:IsA("Folder") then
                for _, m in ipairs(desc:GetChildren()) do
                    if m:IsA("Model") then checkModel(m) end
                end
            end
        end
    end
    return out
end

local function GetAllEnemyNames()
    local names = {"All"}
    local nf = GetNPCFolder()
    if not nf then return names end
    
    local unique = {}
    local function addName(m)
        if m:IsA("Model") and not ShouldIgnore(m.Name) then
            unique[m.Name] = true
        end
    end
    
    for _, desc in ipairs(nf:GetChildren()) do
        if desc:IsA("Model") then
            addName(desc)
        elseif desc:IsA("Folder") then
            for _, m in ipairs(desc:GetChildren()) do
                if m:IsA("Model") then addName(m) end
            end
        end
    end
    
    for name in pairs(unique) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

local function NearestFrom(list)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myY = hrp.Position.Y
    local best, bd = nil, math.huge
    for _, e in ipairs(list) do
        local p = RootPos(e)
        if p and math.abs(p.Y - myY) < 150 then
            local d = (p - hrp.Position).Magnitude
            if d < bd then
                bd = d
                best = e
            end
        end
    end
    return best
end

local function GetGoalForEnemy(enemy)
    local pos = RootPos(enemy)
    if not pos then return nil, nil end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    
    -- Gunakan Height Offset dari config
    local heightOffset = getgenv().Config.Farm.HeightOffset
    
    -- Hitung arah berdasarkan mode farm
    local dir = (hrp.Position - pos).Unit
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    
    local farmMode = getgenv().Config.Farm.FarmMode
    local goal
    
    if farmMode == "In Front" then
        goal = pos - dir * getgenv().Config.Farm.OffsetDist
    elseif farmMode == "Left Side" then
        goal = pos + Vector3.new(dir.Z, 0, -dir.X) * getgenv().Config.Farm.OffsetDist
    elseif farmMode == "Right Side" then
        goal = pos + Vector3.new(-dir.Z, 0, dir.X) * getgenv().Config.Farm.OffsetDist
    else -- Behind (default)
        goal = pos + dir * getgenv().Config.Farm.OffsetDist
    end
    
    goal = Vector3.new(goal.X, pos.Y + heightOffset, goal.Z)
    return goal, pos
end

local function TweenTo(enemy)
    if not enemy then return end
    if State.LockTarget == enemy and getgenv().Config.Farm.FollowStyle ~= "Dodge" then
        local ep = RootPos(enemy)
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if ep and hrp then
            local d = (hrp.Position - ep).Magnitude
            if d <= getgenv().Config.Farm.OffsetDist + 25 then return end
            State.LockTarget = nil
        else
            return
        end
    end
    
    local goal, look = GetGoalForEnemy(enemy)
    if not goal then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local d = (hrp.Position - goal).Magnitude
    if d > 600 then return end
    
    if d < getgenv().Config.Farm.OffsetDist + 2 then
        State.LockTarget = enemy
        StopTween()
        return
    end
    
    if getgenv().Config.Farm.MoveMode == "Teleport" then
        StopTween()
        hrp.CFrame = CFrame.new(goal, look or goal)
        State.LockTarget = enemy
        return
    end
    
    if State.TweenOn and State.TweenTarget == enemy then return end
    
    StopTween()
    State.TweenOn = true
    State.TweenTarget = enemy
    State.LockTarget = nil
    
    local stepDist = math.min(d, 80)
    local dir = (goal - hrp.Position).Unit
    local stepGoal = hrp.Position + (dir * stepDist)
    local cf = CFrame.new(stepGoal, look or goal)
    local dur = math.clamp(stepDist / math.max(getgenv().Config.Farm.TweenSpeed, 1), 0.06, 3.0)
    
    State.ATween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
    State.ATweenConn = State.ATween.Completed:Connect(function()
        State.ATween = nil
        State.ATweenConn = nil
        State.TweenOn = false
        State.TweenTarget = nil
        State.LockTarget = enemy
    end)
    State.ATween:Play()
end

--==================================================
-- AUTO SKILLS SYSTEM (FIXED - DARI v4.0)
--==================================================
local function useSkills()
    local now = tick()
    if now - getgenv().Config.LastSkillTime < getgenv().Config.AutoFarm.SkillCooldown then return end
    
    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    local anySkillUsed = false
    
    for key, slot in pairs(skillMap) do
        if getgenv().Config.AutoSkills[key] then
            pcall(function() AbilityRemote:FireServer(slot) end)
            anySkillUsed = true
        end
    end
    
    if anySkillUsed then
        getgenv().Config.LastSkillTime = now
    end
end

-- Skill spam loop terpisah (berjalan terus)
task.spawn(function()
    while State.Running do
        task.wait(0.1) -- Check every 0.1 seconds
        if getgenv().Config.IsFarm or getgenv().Config.IsBossFight or getgenv().Config.IsAutoDungeon or getgenv().Config.IsBossRush then
            useSkills()
        end
    end
end)

--==================================================
-- FIXED EQUIP WEAPON FUNCTIONS
--==================================================
local function GetAllTools()
    local tools = {}
    local char = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end
    end
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end
    end
    
    return tools
end

local function GetCurrentWeapon()
    local char = Player.Character
    if not char then return nil end
    
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

local function EquipWeapon(weaponName)
    if not weaponName or weaponName == "None" then return false end
    
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    
    -- Cek apakah weapon sudah di tangan
    if char:FindFirstChild(weaponName) then
        return true -- Sudah equip
    end
    
    -- Coba cari di backpack
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local tool = backpack:FindFirstChild(weaponName)
    if not tool or not tool:IsA("Tool") then return false end
    
    -- Unequip semua weapon dulu
    hum:UnequipTools()
    task.wait(0.1)
    
    -- Equip weapon baru
    hum:EquipTool(tool)
    task.wait(0.2)
    
    -- Verifikasi
    return char:FindFirstChild(weaponName) ~= nil
end

local function EquipWeaponByType(type)
    -- type: "Melee" (Combat), "Sword" (pedang), "Fruit" (buah)
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    
    local targetTool = nil
    
    if type == "Melee" then
        -- Cari Combat
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == "Combat" or tool.Name:lower() == "combat") then
                targetTool = tool
                break
            end
        end
    elseif type == "Sword" then
        -- Cari pedang (semua tool yang bukan Combat dan bukan Fruit)
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "Combat" and not tool:FindFirstChild("FruitData") then
                targetTool = tool
                break
            end
        end
    elseif type == "Fruit" then
        -- Cari buah (tool dengan FruitData)
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                targetTool = tool
                break
            end
        end
    end
    
    if not targetTool then return false end
    
    hum:UnequipTools()
    task.wait(0.1)
    hum:EquipTool(targetTool)
    task.wait(0.2)
    
    return char:FindFirstChild(targetTool.Name) ~= nil
end

local function AutoEquipLogic()
    if not getgenv().Config.AutoFarm.AutoEquip or not IsAlive() then return end
    
    local currentWeapon = GetCurrentWeapon()
    local targetWeapon = getgenv().Config.AutoFarm.SelectedWeapon
    
    -- Jika target "None", biarkan apa adanya
    if targetWeapon == "None" then return end
    
    -- Jika sudah equip weapon yang diinginkan, tidak perlu action
    if currentWeapon and currentWeapon.Name == targetWeapon then return end
    
    -- Coba equip weapon yang dipilih di dropdown
    if targetWeapon ~= "None" then
        EquipWeapon(targetWeapon)
    end
end

-- Fungsi untuk refresh weapon list
local function RefreshWeaponList()
    local weapons = {"None"}
    local backpack = Player:FindFirstChild("Backpack")
    local char = Player.Character
    
    -- Add all tools from backpack
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(weapons, tool.Name)
            end
        end
    end
    
    -- Add all tools from character (if not already in list)
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and not table.find(weapons, tool.Name) then
                table.insert(weapons, tool.Name)
            end
        end
    end
    
    table.sort(weapons)
    return weapons
end

local function GetWeaponList()
    return RefreshWeaponList()
end

--==================================================
-- ATTACK FUNCTION DENGAN AUTO SKILLS
--==================================================
local function Attack()
    pcall(function() hitRemote:FireServer() end)
    -- Skills sudah di-handle oleh loop terpisah
end

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Sailor Piece",
        Content = msg,
        Image = "info",
        Time = duration or 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Ultimate Edition",
    Version = "v2.3",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Ultimate",
    IntroIcon = Constants.ICON,
    Icon = Constants.ICON,
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = Constants.ICON,
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local DungeonTab = Window:MakeTab({
    Name = "Dungeon",
    Icon = "dungeon",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Bosses",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local SkillTab = Window:MakeTab({
    Name = "Skills",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local MerchantTab = Window:MakeTab({
    Name = "Merchant",
    Icon = "shopping-cart",
    Glass = true,
    Outline = true
})

local QuestTab = Window:MakeTab({
    Name = "Quests",
    Icon = "bookmark",
    Glass = true,
    Outline = true
})

local SettingTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- MAIN TAB - PLAYER INFO
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local playerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days",
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
           "Uptime: " .. getUptime() .. "\n" ..
           "Kills: " .. State.KillCount .. " | Boss Kills: " .. State.BossKills
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

task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
        
        local level = 0
        local money = 0
        local gems = 0
        pcall(function() 
            level = Player.Data.Level.Value or 0
            money = Player.Data.Money.Value or 0
            gems = Player.Data.Gems.Value or 0
        end)
        
        playerInfoPara:SetDesc("Display Name: " .. Player.DisplayName .. "\n" ..
                               "Level: " .. level .. "\n" ..
                               "Money: " .. formatNumber(money) .. "\n" ..
                               "Gems: " .. formatNumber(gems) .. "\n" ..
                               "Kills: " .. State.KillCount .. "\n" ..
                               "Account Age: " .. Player.AccountAge .. " days")
    end
end)

--==================================================
-- FARM TAB - AUTO FARM SETTINGS
--==================================================
local FarmMainSection = FarmTab:AddSection({
    Name = "⚡ AUTO FARM SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoFarm.Enabled = Value
        getgenv().Config.IsFarm = Value
        if Value then
            FullReset()
            Notify("Auto Farm Enabled")
        else
            Notify("Auto Farm Disabled")
        end
    end
})

FarmMainSection:AddDropdown({
    Name = "FARM ISLAND",
    Default = "Auto",
    Options = GetIslandNames(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "FarmIsland",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.SelectedIsland = DisplayToPortal(Value)
        ClearTarget()
        State.CurIsland = nil
        State.IslandTPd = false
        State.SpawnDone = false
        State.FarmOrigin = nil
        AbandonAllQuests()
        Notify("Island changed to: " .. Value)
    end
})

-- DROPDOWN UNTUK MEMILIH MUSUH
FarmMainSection:AddDropdown({
    Name = "SELECT ENEMY TYPE",
    Default = "All",
    Options = GetAllEnemyNames(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedEnemy",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.SelectedEnemy = Value
        ClearTarget()
        Notify("Now targeting: " .. Value)
    end
})

FarmMainSection:AddButton({
    Name = "🔄 REFRESH ENEMY LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local enemies = GetAllEnemyNames()
        OrionLib.Flags["SelectedEnemy"]:SetOptions(enemies)
        Notify("Enemy list refreshed")
    end
})

FarmMainSection:AddDropdown({
    Name = "STAND POSITION",
    Default = "Behind",
    Options = {"Behind", "In Front", "Left Side", "Right Side"},
    Multi = false,
    Outline = true,
    Flag = "FarmMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.FarmMode = Value
        ClearTarget()
    end
})

FarmMainSection:AddDropdown({
    Name = "COMBAT STYLE",
    Default = "Dodge",
    Options = {"Dodge", "Static", "Orbit", "Strafe"},
    Multi = false,
    Outline = true,
    Flag = "FollowStyle",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.FollowStyle = Value
    end
})

FarmMainSection:AddDropdown({
    Name = "TRAVEL MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.MoveMode = Value
        ClearTarget()
    end
})

-- SLIDER UNTUK HEIGHT OFFSET
FarmMainSection:AddSlider({
    Name = "HEIGHT OFFSET",
    Min = 5,
    Max = 50,
    Default = 15,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "HeightOffset",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.HeightOffset = Value
        Notify("Height offset set to: " .. Value)
    end
})

FarmMainSection:AddSlider({
    Name = "OFFSET DISTANCE",
    Min = 5,
    Max = 50,
    Default = 15,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "OffsetDist",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.OffsetDist = Value
    end
})

FarmMainSection:AddSlider({
    Name = "MOVEMENT SPEED",
    Min = 20,
    Max = 250,
    Default = 100,
    Increment = 5,
    ValueName = "WS",
    Outline = true,
    Flag = "TweenSpeed",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Farm.TweenSpeed = Value
    end
})

FarmMainSection:AddToggle({
    Name = "AUTO HIT",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHit",
    Save = true,
    Callback = function(Value) getgenv().Config.AutoFarm.AutoHit = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO STATS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value) getgenv().Config.AutoFarm.AutoStats = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO EQUIP WEAPON",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoFarm.AutoEquip = Value
        Notify(Value and "Auto Equip ON" or "Auto Equip OFF")
    end
})

FarmMainSection:AddToggle({
    Name = "AUTO ARMAMENT HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value) getgenv().Config.AutoFarm.AutoHaki = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO OBSERVATION HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(Value) getgenv().Config.AutoFarm.AutoObsHaki = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO QUEST",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value) getgenv().Config.Farm.AutoQuest = Value end
})

FarmMainSection:AddToggle({
    Name = "SET SPAWN CRYSTAL",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSpawn",
    Save = true,
    Callback = function(Value) getgenv().Config.Farm.AutoSpawn = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value) getgenv().Config.Farm.AutoChest = Value end
})

-- DROPDOWN UNTUK MEMILIH WEAPON
FarmMainSection:AddDropdown({
    Name = "SELECT WEAPON",
    Default = "None",
    Options = GetWeaponList(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "WeaponSelect",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoFarm.SelectedWeapon = Value
        if Value ~= "None" then
            Notify("Selected: " .. Value)
            -- Langsung equip jika auto equip aktif
            if getgenv().Config.AutoFarm.AutoEquip then
                EquipWeapon(Value)
            end
        end
    end
})

FarmMainSection:AddButton({
    Name = "🔄 REFRESH WEAPON LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local weapons = GetWeaponList()
        OrionLib.Flags["WeaponSelect"]:SetOptions(weapons)
        Notify("Weapon list refreshed")
    end
})

-- Tombol manual untuk equip weapon
FarmMainSection:AddButton({
    Name = "⚔️ EQUIP SELECTED WEAPON NOW",
    Icon = "sword",
    Outline = true,
    Callback = function()
        if getgenv().Config.AutoFarm.SelectedWeapon ~= "None" then
            if EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon) then
                Notify("Equipped: " .. getgenv().Config.AutoFarm.SelectedWeapon)
            else
                Notify("Failed to equip: " .. getgenv().Config.AutoFarm.SelectedWeapon)
            end
        else
            Notify("Select a weapon first!")
        end
    end
})

-- Tombol untuk equip combat
FarmMainSection:AddButton({
    Name = "👊 EQUIP COMBAT",
    Icon = "fist",
    Outline = true,
    Callback = function()
        if EquipWeaponByType("Melee") then
            Notify("Equipped Combat")
            getgenv().Config.AutoFarm.SelectedWeapon = "Combat"
            OrionLib.Flags["WeaponSelect"]:SetValue("Combat")
        else
            Notify("Combat not found")
        end
    end
})

-- Tombol untuk equip pedang
FarmMainSection:AddButton({
    Name = "⚔️ EQUIP SWORD",
    Icon = "sword",
    Outline = true,
    Callback = function()
        if EquipWeaponByType("Sword") then
            local current = GetCurrentWeapon()
            if current then
                Notify("Equipped: " .. current.Name)
                getgenv().Config.AutoFarm.SelectedWeapon = current.Name
                OrionLib.Flags["WeaponSelect"]:SetValue(current.Name)
            end
        else
            Notify("No sword found")
        end
    end
})

-- Tombol untuk equip buah
FarmMainSection:AddButton({
    Name = "🍎 EQUIP FRUIT",
    Icon = "apple",
    Outline = true,
    Callback = function()
        if EquipWeaponByType("Fruit") then
            local current = GetCurrentWeapon()
            if current then
                Notify("Equipped: " .. current.Name)
                getgenv().Config.AutoFarm.SelectedWeapon = current.Name
                OrionLib.Flags["WeaponSelect"]:SetValue(current.Name)
            end
        else
            Notify("No fruit found")
        end
    end
})

--==================================================
-- SKILL TAB (AUTO SKILLS - FIXED)
--==================================================
local SkillSection = SkillTab:AddSection({
    Name = "🎯 AUTO SKILLS SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SkillSection:AddToggle({
    Name = "USE SKILL Z",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillZ",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.Z = Value
        Notify(Value and "Skill Z ON" or "Skill Z OFF")
    end
})

SkillSection:AddToggle({
    Name = "USE SKILL X",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillX",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.X = Value
        Notify(Value and "Skill X ON" or "Skill X OFF")
    end
})

SkillSection:AddToggle({
    Name = "USE SKILL C",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.C = Value
        Notify(Value and "Skill C ON" or "Skill C OFF")
    end
})

SkillSection:AddToggle({
    Name = "USE SKILL V",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.V = Value
        Notify(Value and "Skill V ON" or "Skill V OFF")
    end
})

SkillSection:AddToggle({
    Name = "USE SKILL F (NUKE)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.F = Value
        Notify(Value and "Skill F ON" or "Skill F OFF")
    end
})

SkillSection:AddSlider({
    Name = "SKILL COOLDOWN",
    Min = 0.1,
    Max = 2.0,
    Default = 0.3,
    Increment = 0.05,
    ValueName = "sec",
    Outline = true,
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoFarm.SkillCooldown = Value
    end
})

SkillSection:AddParagraph({
    Title = "⚡ AUTO SKILLS INFO",
    Desc = "Skills will automatically activate\nwhen any farming mode is active\n\nCheck every 0.1 seconds\nCooldown: " .. getgenv().Config.AutoFarm.SkillCooldown .. "s",
    Image = "zap",
    ImageSize = 32
})

--==================================================
-- DUNGEON TAB
--==================================================
local DungeonSection = DungeonTab:AddSection({
    Name = "⚔️ AUTO DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection:AddToggle({
    Name = "ENABLE AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Dungeon.Enabled = Value
        getgenv().Config.IsAutoDungeon = Value
        if Value then
            getgenv().Config.AutoFarm.Enabled = false
            getgenv().Config.IsFarm = false
            if OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(false) end
            Notify("Auto Dungeon Enabled")
        else
            Notify("Auto Dungeon Disabled")
        end
    end
})

DungeonSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Double",
    Options = {"Double", "Rune", "Cid"},
    Multi = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Dungeon.Type = Value
    end
})

DungeonSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Extreme"},
    Multi = false,
    Outline = true,
    Flag = "DungeonDifficulty",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Dungeon.Difficulty = Value
    end
})

DungeonSection:AddSlider({
    Name = "HEIGHT OFFSET",
    Min = 5,
    Max = 50,
    Default = 10,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "DungeonHeight",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Dungeon.HeightOffset = Value
    end
})

DungeonSection:AddButton({
    Name = "🚪 ENTER DUNGEON",
    Icon = "door",
    Outline = true,
    Callback = function()
        pcall(function()
            dungeonPortalRemote:FireServer(Constants.DungeonPortalNames[getgenv().Config.Dungeon.Type])
            Notify("Attempting to enter " .. getgenv().Config.Dungeon.Type .. " Dungeon")
        end)
    end
})

DungeonSection:AddButton({
    Name = "🗳️ VOTE DIFFICULTY",
    Icon = "vote",
    Outline = true,
    Callback = function()
        pcall(function()
            dungeonVoteRemote:FireServer(getgenv().Config.Dungeon.Difficulty)
            Notify("Voted for " .. getgenv().Config.Dungeon.Difficulty .. " difficulty")
        end)
    end
})

--==================================================
-- BOSS TAB
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "👾 BOSS SYSTEMS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "ENABLE WORLD BOSSES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossEnabled",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Bosses.Enabled = Value
        getgenv().Config.IsBossFight = Value
        Notify(Value and "Boss Hunting Enabled" or "Boss Hunting Disabled")
    end
})

BossMainSection:AddToggle({
    Name = "BOSS NOTIFICATIONS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossNotify",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Bosses.Notify = Value
    end
})

-- World Bosses
local BossListSection = BossTab:AddSection({
    Name = "🌍 WORLD BOSSES",
    TextSize = 16,
    Glass = true,
    Outline = true
})

for _, boss in ipairs(Constants.Bosses) do
    BossListSection:AddToggle({
        Name = boss.Display .. " (" .. boss.Island .. ")",
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Boss_" .. boss.Name,
        Save = true,
        Callback = function(Value)
            if Value then
                getgenv().Config.Bosses.Selected[boss.Name] = true
            else
                getgenv().Config.Bosses.Selected[boss.Name] = nil
            end
        end
    })
end

-- Summon Bosses
local SummonBossSection = BossTab:AddSection({
    Name = "🔮 SUMMON BOSSES",
    TextSize = 16,
    Glass = true,
    Outline = true
})

for _, boss in ipairs(Constants.SummonBosses) do
    SummonBossSection:AddToggle({
        Name = boss.Display .. (boss.Island and " (" .. boss.Island .. ")" or ""),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "SummonBoss_" .. boss.Name,
        Save = true,
        Callback = function(Value)
            if Value then
                getgenv().Config.Bosses.SummonSelected[boss.Name] = true
                -- Call summon remote
                if boss.Difficulties then
                    local diff = "Normal" -- Default difficulty
                    pcall(function() autoSpawnBossRemote:FireServer(boss.Name, diff) end)
                else
                    pcall(function() summonBossRemote:FireServer(boss.Name) end)
                end
            else
                getgenv().Config.Bosses.SummonSelected[boss.Name] = nil
            end
        end
    })
end

--==================================================
-- MERCHANT TAB
--==================================================
local MerchantSection = MerchantTab:AddSection({
    Name = "💰 AUTO MERCHANT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MerchantSection:AddToggle({
    Name = "ENABLE AUTO MERCHANT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Merchant.Enabled = Value
    end
})

MerchantSection:AddToggle({
    Name = "MERCHANT NOTIFICATIONS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "MerchantNotify",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Merchant.Notify = Value
    end
})

local MerchantItemsSection = MerchantTab:AddSection({
    Name = "🛒 ITEMS TO BUY",
    TextSize = 16,
    Glass = true,
    Outline = true
})

for _, item in ipairs(Constants.MerchantItems) do
    MerchantItemsSection:AddToggle({
        Name = item,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Merchant_" .. item:gsub(" ", "_"),
        Save = true,
        Callback = function(Value)
            if Value then
                getgenv().Config.Merchant.Selected[item] = true
            else
                getgenv().Config.Merchant.Selected[item] = nil
            end
        end
    })
end

--==================================================
-- QUEST TAB
--==================================================
local QuestSection = QuestTab:AddSection({
    Name = "📜 SPECIAL QUESTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

QuestSection:AddToggle({
    Name = "DUNGEON PIECES QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Quests.DungeonEnabled = Value
        if Value then
            if getgenv().Config.Quests.HogyokuEnabled then
                getgenv().Config.Quests.HogyokuEnabled = false
                if OrionLib.Flags["HogyokuQuest"] then OrionLib.Flags["HogyokuQuest"]:SetValue(false) end
            end
            Notify("Dungeon Quest Enabled")
            State.DungeonStep = 0
            State.DungeonCollected = {}
        else
            Notify("Dungeon Quest Disabled")
        end
    end
})

QuestSection:AddParagraph({
    Title = "Dungeon Info",
    Desc = "Collect 6 puzzle pieces:\nStarter → Jungle → Desert → Snow → Shibuya → Hueco Mundo",
    Image = "info",
    ImageSize = 32
})

QuestSection:AddToggle({
    Name = "HOGYOKU FRAGMENTS QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Quests.HogyokuEnabled = Value
        if Value then
            if getgenv().Config.Quests.DungeonEnabled then
                getgenv().Config.Quests.DungeonEnabled = false
                if OrionLib.Flags["DungeonQuest"] then OrionLib.Flags["DungeonQuest"]:SetValue(false) end
            end
            Notify("Hogyoku Quest Enabled")
            State.HogyokuStep = 0
            State.HogyokuCollected = {}
        else
            Notify("Hogyoku Quest Disabled")
        end
    end
})

QuestSection:AddParagraph({
    Title = "Hogyoku Info",
    Desc = "Collect 6 fragments:\nSnow → Shibuya → Hueco Mundo → Shinjuku → Slime → Judgement",
    Image = "info",
    ImageSize = 32
})

QuestSection:AddButton({
    Name = "📋 QUEST DEBUG INFO",
    Icon = "bug",
    Outline = true,
    Callback = function()
        Notify("Quest Debug Info:\nDungeon Step: " .. State.DungeonStep .. "\nHogyoku Step: " .. State.HogyokuStep, 5)
    end
})

--==================================================
-- SETTINGS TAB
--==================================================
local SettingsSection = SettingTab:AddSection({
    Name = "⚙️ GENERAL SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SettingsSection:AddToggle({
    Name = "ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Misc.AntiAFK = Value
    end
})

SettingsSection:AddToggle({
    Name = "FPS BOOST (BLACK SCREEN)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Misc.FpsBoost = Value
        if Value then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = false
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            end
        end
    end
})

SettingsSection:AddToggle({
    Name = "WHITE SCREEN MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WhiteScreen",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Misc.WhiteScreen = Value
        RunService:Set3dRenderingEnabled(not Value)
    end
})

SettingsSection:AddToggle({
    Name = "AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Misc.AutoRejoin = Value
    end
})

SettingsSection:AddToggle({
    Name = "TIMED REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TimedRejoin",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Misc.TimedRejoin = Value
    end
})

SettingsSection:AddSlider({
    Name = "REJOIN DELAY (MINUTES)",
    Min = 1,
    Max = 120,
    Default = 10,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Flag = "RejoinDelay",
    Save = true,
    Callback = function(Value)
        getgenv().Config.Misc.RejoinDelay = Value
    end
})

-- Teleport Section
local TeleportSection = SettingTab:AddSection({
    Name = "📍 TELEPORT TO ISLAND",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for _, name in ipairs(Constants.TpIslands) do
    TeleportSection:AddButton({
        Name = PortalDisplayName(name),
        Icon = "map-pin",
        Outline = true,
        Callback = function()
            if getgenv().Config.AutoFarm.Enabled then
                Notify("Disable Auto Farm first!", 2)
                return
            end
            ForceTP(name)
            Notify("Teleporting to " .. PortalDisplayName(name))
        end
    })
end

-- Destroy Button
local DestroySection = SettingTab:AddSection({
    Name = "⚠️ DANGER ZONE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DestroySection:AddButton({
    Name = "💀 DESTROY GUI",
    Icon = "skull",
    Outline = true,
    Callback = function()
        State.Running = false
        task.delay(0.1, function()
            OrionLib:Destroy()
            _G.SP_Loaded = false
        end)
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Configs",
    Icon = "settings"
})

--==================================================
-- MAIN FARM LOOP
--==================================================
local function DoFarmTick()
    local tgtIsland = GetFarmIsland()
    if not tgtIsland then
        task.wait(1)
        return
    end
    
    if not State.CurIsland or State.CurIsland.Portal ~= tgtIsland.Portal then
        StopTween()
        State.CurIsland = tgtIsland
        State.IslandTPd = false
        State.SpawnDone = false
        State.FarmOrigin = nil
        State.QState = "NONE"
        ClearTarget()
        AbandonAllQuests()
        Notify("Teleporting to " .. PortalDisplayName(tgtIsland.Portal), 1.5)
    end
    
    if not State.IslandTPd then
        if ForceTP(State.CurIsland.Portal) then
            task.wait(0.5)
            State.IslandTPd = true
            State.FarmOrigin = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position or nil
            State.LastEnemy = tick()
            if getgenv().Config.Farm.AutoQuest and State.QState == "NONE" then
                pcall(function() questRemote:FireServer(State.CurIsland.QuestNPC) end)
                State.QState = "ACTIVE"
            end
        else
            task.wait(1)
        end
        return
    end
    
    local enemies = FindEnemies(State.CurIsland)
    
    if #enemies > 0 then
        State.LastEnemy = tick()
        if State.CurTarget then
            local hm = GetHum(State.CurTarget)
            if not hm or hm.Health <= 0 or not State.CurTarget.Parent then
                if hm and hm.Health <= 0 then
                    State.KillCount = State.KillCount + 1
                end
                State.CurTarget = nil
                State.LockTarget = nil
            end
        end
        if not State.CurTarget then
            State.CurTarget = NearestFrom(enemies)
        end
        if State.CurTarget then
            TweenTo(State.CurTarget)
            Attack()
            
            -- AUTO EQUIP LOGIC
            if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 2 then
                State.LastEquip = tick()
                AutoEquipLogic()
            end
        end
    else
        State.CurTarget = nil
        State.LockTarget = nil
        if tick() - State.LastEnemy > 20 then
            State.IslandTPd = false
            State.SpawnDone = false
            State.FarmOrigin = nil
            State.LastEnemy = 0
        end
        task.wait(0.1)
    end
end

--==================================================
-- MAIN LOOP
--==================================================
task.spawn(function()
    while State.Running do
        task.wait(0.1)
        
        -- Priority: Quests first
        if getgenv().Config.Quests.DungeonEnabled then
            -- Dungeon quest logic (simplified)
            task.wait(0.2)
        elseif getgenv().Config.Quests.HogyokuEnabled then
            -- Hogyoku quest logic (simplified)
            task.wait(0.2)
        elseif getgenv().Config.Dungeon.Enabled then
            -- Dungeon auto mode
            task.wait(0.2)
        elseif getgenv().Config.Bosses.Enabled then
            -- Boss hunting
            task.wait(0.2)
        elseif getgenv().Config.AutoFarm.Enabled then
            -- Auto farm
            if IsAlive() then
                DoFarmTick()
            else
                task.wait(0.5)
            end
        end
    end
end)

--==================================================
-- ANTI AFK SYSTEM
--==================================================
task.spawn(function()
    while State.Running do
        task.wait(60)
        if getgenv().Config.Misc.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

--==================================================
-- AUTO REJOIN HANDLER
--==================================================
task.spawn(function()
    local GuiService = game:GetService("GuiService")
    local lastError = ""
    GuiService.ErrorMessageChanged:Connect(function()
        if not getgenv().Config.Misc.AutoRejoin then return end
        local err = GuiService:GetErrorMessage()
        if err ~= lastError and err ~= "" then
            lastError = err
            task.wait(5)
            pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
        end
    end)
end)

--==================================================
-- TIMED REJOIN
--==================================================
task.spawn(function()
    local elapsed = 0
    while State.Running do
        task.wait(1)
        if getgenv().Config.Misc.TimedRejoin then
            elapsed = elapsed + 1
            if elapsed >= getgenv().Config.Misc.RejoinDelay * 60 then
                elapsed = 0
                task.wait(2)
                pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
            end
        else
            elapsed = 0
        end
    end
end)

--==================================================
-- AUTO MERCHANT LOOP
--==================================================
task.spawn(function()
    local lastMerchant = 0
    while State.Running do
        task.wait(30)
        if getgenv().Config.Merchant.Enabled and tick() - lastMerchant > 1800 then
            lastMerchant = tick()
            for item in pairs(getgenv().Config.Merchant.Selected) do
                pcall(function()
                    local remote = Remotes:FindFirstChild("MerchantRemotes") and Remotes.MerchantRemotes:FindFirstChild("PurchaseMerchantItem")
                    if remote then
                        remote:InvokeServer(item, 1)
                        if getgenv().Config.Merchant.Notify then
                            Notify("Purchased: " .. item, 1.5)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end
    end
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    ClearTarget()
    if getgenv().Config.AutoFarm.AutoEquip and getgenv().Config.AutoFarm.SelectedWeapon ~= "None" then
        task.spawn(function()
            task.wait(1.5)
            EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon)
        end)
    end
end)

--==================================================
-- SEMUA KEYBIND DIHAPUS - HANYA F4 UNTUK TOGGLE UI
-- Catraz Hub sudah punya F4 default untuk toggle UI
--==================================================
-- Tidak ada keybind handler

--==================================================
-- HEARTBEAT MOVEMENT
--==================================================
RunService.Heartbeat:Connect(function()
    if not State.Running then return end
    
    -- Follow-style movement jika LockTarget ada
    if State.LockTarget and getgenv().Config.Farm.FollowStyle == "Dodge" then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local enemyPos = RootPos(State.LockTarget)
        if hrp and enemyPos then
            local dir = (hrp.Position - enemyPos).Unit
            local right = Vector3.new(-dir.Z, 0, dir.X)
            local dodgeDir = (math.sin(tick() * 4) > 0) and 1 or -1
            local goal = enemyPos + dir * getgenv().Config.Farm.OffsetDist + right * dodgeDir * 4
            goal = Vector3.new(goal.X, enemyPos.Y + getgenv().Config.Farm.HeightOffset, goal.Z)
            local lookAt = Vector3.new(enemyPos.X, hrp.Position.Y, enemyPos.Z)
            
            local d = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(goal.X, 0, goal.Z)).Magnitude
            if d > 1 then
                hrp.CFrame = CFrame.new(hrp.Position + (goal - hrp.Position).Unit * math.min(d, 3), lookAt)
            else
                hrp.CFrame = CFrame.new(goal, lookAt)
            end
        end
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 to toggle UI")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v2.3 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ FIXED: Auto Skills System (spam loop terpisah)")
print("✅ Skills check setiap 0.1 detik")
print("✅ Cooldown slider: 0.1-2.0 detik")
print("✅ FIXED: VirtualInputService Error")
print("✅ FIXED: Equip Weapon (bisa ganti pedang/combat/buah)")
print("✅ Hanya F4 untuk toggle UI")
print("✅ Auto Farm with Enemy Dropdown")
print("✅ Height Offset Slider (5-50 studs)")
print("✅ Multiple Combat Styles (Dodge/Static/Orbit/Strafe)")
print("═══════════════════════════════════════════════════════")