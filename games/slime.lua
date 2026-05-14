-- ==================== SLIME RNG - CATRAZ HUB ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 1.0

if _G.Slime_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Slime RNG",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.Slime_Loaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES & SERVICES
--==================================================
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Config
local Config = {
    AutoRoll = false,
    AutoCollect = false,
    FastRoll = false,
    WalkSpeed = 16,
    JumpPower = 50
}

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Slime RNG 🟢",
    Subtext = "Catraz Hub v1.0",
    Version = "v1.0",
    VersionIcon = "sparkles",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Slime",
    IntroEnabled = true,
    IntroText = "Loading Slime RNG...",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    -- Custom Theme
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Slime RNG",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

Notify("Script loaded successfully!")

--==================================================
-- TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main Farm",
    Icon = "crosshair",
    Glass = true,
    Outline = true
})

local PlayerTab = Window:MakeTab({
    Name = "Movement",
    Icon = "footprints",
    Glass = true,
    Outline = true
})

--==================================================
-- MAIN LOGIC
--==================================================

-- Auto Roll
local function doAutoRoll()
    task.spawn(function()
        while Config.AutoRoll do
            pcall(function()
                -- Replace with actual remote event if known, this is a generic placeholder
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("Roll") then
                    remotes.Roll:InvokeServer()
                end
            end)
            task.wait(Config.FastRoll and 0.1 or 1)
        end
    end)
end

-- Auto Collect
local function doAutoCollect()
    task.spawn(function()
        while Config.AutoCollect do
            pcall(function()
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Player.Character.HumanoidRootPart
                    -- Assuming coins/drops are in workspace.Drops
                    local drops = Workspace:FindFirstChild("Drops")
                    if drops then
                        for _, drop in pairs(drops:GetChildren()) do
                            if drop:IsA("BasePart") then
                                drop.CFrame = hrp.CFrame
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

--==================================================
-- UI COMPONENTS: MAIN
--==================================================

MainTab:AddSection({ Name = "⚙️ Farming Options" })

MainTab:AddToggle({
    Name = "Auto Roll",
    Default = false,
    Save = true,
    Flag = "AutoRoll_Flag",
    Callback = function(Value)
        Config.AutoRoll = Value
        if Value then
            doAutoRoll()
        end
    end
})

MainTab:AddToggle({
    Name = "Fast Roll",
    Default = false,
    Save = true,
    Flag = "FastRoll_Flag",
    Callback = function(Value)
        Config.FastRoll = Value
    end
})

MainTab:AddToggle({
    Name = "Auto Collect Drops",
    Default = false,
    Save = true,
    Flag = "AutoCollect_Flag",
    Callback = function(Value)
        Config.AutoCollect = Value
        if Value then
            doAutoCollect()
        end
    end
})

MainTab:AddButton({
    Name = "Redeem All Codes",
    Callback = function()
        -- Add known codes here if available
        local codes = {"UPDATE", "RELEASE"} 
        for _, code in ipairs(codes) do
            pcall(function()
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("RedeemCode") then
                    remotes.RedeemCode:InvokeServer(code)
                end
            end)
        end
        Notify("Attempted to redeem all codes!")
    end
})

--==================================================
-- UI COMPONENTS: PLAYER
--==================================================

PlayerTab:AddSection({ Name = "🏃 Movement" })

PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        Config.JumpPower = Value
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = Value
        end
    end
})

-- Keep movement updated
RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        if Config.WalkSpeed > 16 then
            Player.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        end
        if Config.JumpPower > 50 then
            Player.Character.Humanoid.JumpPower = Config.JumpPower
        end
    end
end)

-- Initialize Library
OrionLib:Init()
