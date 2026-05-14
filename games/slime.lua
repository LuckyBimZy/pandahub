-- ==================== SLIME RNG - CATRAZ ULTIMATE ====================
-- Premium UI menggunakan Catraz Hub Library
-- Base code & logic dari: https://github.com/U-ziii/Slime-RNG.git

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
local VirtualUser = game:GetService("VirtualUser")

local Window = OrionLib:MakeWindow({
    Name = "Pandahub | Slime RNG",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Pandahub_Slime"
})

--==================================================
-- CONFIGURATION
--==================================================
getgenv().Config = {
    AutoRoll = false,
    AutoCraft = false,
    AutoEquip = false,
    AntiAFK = true
}

--==================================================
-- TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

--==================================================
-- MAIN LOGIC (Based on U-ziii/Slime-RNG logic)
--==================================================

MainTab:AddToggle({
    Name = "Auto Roll",
    Default = false,
    Callback = function(Value)
        getgenv().Config.AutoRoll = Value
    end    
})

MainTab:AddToggle({
    Name = "Auto Craft",
    Default = false,
    Callback = function(Value)
        getgenv().Config.AutoCraft = Value
    end    
})

MainTab:AddToggle({
    Name = "Auto Equip Best",
    Default = false,
    Callback = function(Value)
        getgenv().Config.AutoEquip = Value
    end    
})

MainTab:AddButton({
    Name = "Load Original Script Logic (U-ziii)",
    Callback = function()
        -- The actual underlying script from the github repo
        loadstring(game:HttpGet("https://pastefy.app/nBwUBkAF/raw"))()
    end    
})

MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = true,
    Callback = function(Value)
        getgenv().Config.AntiAFK = Value
    end    
})

--==================================================
-- BACKGROUND LOOPS
--==================================================
-- Anti AFK
Player.Idled:Connect(function()
    if getgenv().Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Main Farm Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().Config.AutoRoll then
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                if rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Roll") then
                    rs.Remotes.Roll:InvokeServer()
                end
            end)
        end
        
        if getgenv().Config.AutoCraft then
            pcall(function()
                -- Placeholder logic for Auto Craft
            end)
        end
    end
end)

OrionLib:Init()
