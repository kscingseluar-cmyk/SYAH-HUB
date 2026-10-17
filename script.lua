--[[
    UNIVERSAL SCRIPT HUB (FULL ENGLISH VERSION)
    Optimized for Mobile Executors (Delta, Arceus, Hydrogen, etc.)
--]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "SYAH HUB - Universal Custom", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "SyahHubConfig",
    IntroText = "Loading Custom Hub..."
})

-- Services & Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- States
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local AimbotEnabled = false
local AimbotFOV = 150
local FOVCircleVisible = false
local ESPEnabled = false

-- Fly Variables
local Flying = false
local FlySpeed = 50
local BodyVelocity, BodyGyro

-- Teleport Variables
local SavedCFrame = nil
local SelectedPlayerName = ""

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local MainTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TeleportTab = Window:MakeTab({ Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local VisualsTab = Window:MakeTab({ Name = "ESP / Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local CombatTab = Window:MakeTab({ Name = "Combat / Aim", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local MiscTab = Window:MakeTab({ Name = "Misc / Utility", Icon = "rbxassetid://4483345998", PremiumOnly = false })

----------------------------------------------------------------
-- PLAYER TAB (TEXTBOX INPUTS)
----------------------------------------------------------------
MainTab:AddSection({ Name = "Movement Custom Values" })

MainTab:AddTextbox({
    Name = "WalkSpeed (Type Number)",
    Default = "16",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = num
        end
    end
})

MainTab:AddTextbox({
    Name = "JumpPower (Type Number)",
    Default = "50",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = num
        end
    end
})

MainTab:AddSection({ Name = "Fly System" })

MainTab:AddTextbox({
    Name = "Fly Speed (Type Number)",
    Default = "50",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            FlySpeed = num
        end
    end
})

MainTab:AddToggle({
    Name = "Enable Fly",
    Default = false,
    Callback = function(Value)
        Flying = Value
        if Flying then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                
                BodyGyro = Instance.new("BodyGyro")
                BodyGyro.P = 9e4
                BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                BodyGyro.cframe = hrp.CFrame
                BodyGyro.Parent = hrp

                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.velocity = Vector3.new(0, 0, 0)
                BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
                BodyVelocity.Parent = hrp

                char.Humanoid.PlatformStand = true
            end
        else
            local char = LocalPlayer.Character
            if char then
                if BodyGyro then BodyGyro:Destroy() end
                if BodyVelocity then BodyVelocity:Destroy() end
                if char:FindFirstChild("Humanoid") then
                    char.Humanoid.PlatformStand = false
                end
            end
        end
    end
})

-- Fly Loop Logic
RunService.RenderStepped:Connect(function()
    if Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        BodyGyro.cframe = Camera.CFrame
        
        local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
        if moveDir.Magnitude > 0 then
            BodyVelocity.velocity = Camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z)) * FlySpeed
        else
            BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
        end
    end
end)

MainTab:AddSection({ Name = "Toggles" })

MainTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end    
})

MainTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end    
})

-- Noclip Loop
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
TeleportTab:AddSection({ Name = "Set & TP Position" })

TeleportTab:AddButton({
    Name = "Set Position (Save Pos)",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Position saved successfully!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

TeleportTab:AddButton({
    Name = "TP to Saved Position",
    Callback = function()
        if SavedCFrame then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = SavedCFrame
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported successfully!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please click 'Set Position' first!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

TeleportTab:AddSection({ Name = "Teleport to Player" })

local PlayerDropdown = TeleportTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = {},
    Callback = function(Value)
        SelectedPlayerName = Value
    end    
})

local function UpdatePlayerDropdown()
    local playerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end
    PlayerDropdown:Refresh(playerList, true)
end

UpdatePlayerDropdown()
Players.PlayerAdded:Connect(UpdatePlayerDropdown)
Players.PlayerRemoving:Connect(UpdatePlayerDropdown)

TeleportTab:AddButton({
    Name = "TP to Selected Player",
    Callback = function()
        if SelectedPlayerName ~= "" then
            local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Player not found or is dead!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    end    
})

----------------------------------------------------------------
-- VISUALS TAB (ESP)
----------------------------------------------------------------
VisualsTab:AddToggle({
    Name = "Enable Player Highlight (ESP)",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("SYAH_ESP") then
                    player.Character.SYAH_ESP:Destroy()
                end
            end
        end
    end    
})

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not player.Character:FindFirstChild("SYAH_ESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "SYAH_ESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- COMBAT TAB (FOV TEXTBOX)
----------------------------------------------------------------
CombatTab:AddToggle({
    Name = "Camera Aimbot",
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end    
})

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

CombatTab:AddToggle({
    Name = "Show FOV Circle",
    Default = false,
    Callback = function(Value)
        FOVCircleVisible = Value
        FOVCircle.Visible = Value
    end    
})

CombatTab:AddTextbox({
    Name = "FOV Radius (Type Number)",
    Default = "150",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            AimbotFOV = num
            FOVCircle.Radius = num
        end
    end
})

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = AimbotFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos

    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

----------------------------------------------------------------
-- MISC TAB
----------------------------------------------------------------
MiscTab:AddButton({
    Name = "Anti-AFK",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        OrionLib:MakeNotification({
            Name = "Anti-AFK",
            Content = "Anti-AFK Activated!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

MiscTab:AddButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end    
})

-- Initialize UI
OrionLib:Init()
