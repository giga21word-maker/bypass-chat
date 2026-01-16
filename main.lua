--[[
    BLIND SHOT: FULL VISION ENGINE (v7.0)
    Target: MisfitsBStoo version
    
    [FEATURES]
    - Avatar Unhider: Forces full rendering of clothes, accessories, and skins.
    - Weapon Visualizer: Shows exactly what gun they are holding and where it's pointing.
    - User Tags: Creates custom BillboardGuis so you can see who is who.
    - Laser Persistence: Forces the red trajectory beams to be visible at all times.
    - Eternal Energy: Bypasses dash/stamina limits.
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. SETTINGS //
local Config = {
    Enabled = true,
    ShowAvatars = true,
    ShowNames = true,
    ShowLasers = true,
    InfEnergy = true,
    RevealTransparency = 0 -- 0 is fully visible, 0.5 is ghost-like
}

-- // 3. NAME TAG SYSTEM //
-- Creates a clean, floating name above every hidden player
local function CreateNameTag(char, name)
    if char:FindFirstChild("EternalTag") then return end
    
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local bgui = Instance.new("BillboardGui")
    bgui.Name = "EternalTag"
    bgui.Adornee = head
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    bgui.Parent = char

    local text = Instance.new("TextLabel", bgui)
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Text = name
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextStrokeTransparency = 0
    text.TextSize = 14
end

-- // 4. FULL REVEAL ENGINE //
-- This is the core logic that unhides the actual models
local function UnhideEverything()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            
            -- 1. Unhide the Avatar and the Gun (Tool)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    -- This is the "magic" property that Roblox uses to hide players locally
                    part.LocalTransparencyModifier = Config.RevealTransparency
                    part.Transparency = Config.RevealTransparency
                end
                
                -- 2. Unhide the Gun's Laser/Trajectory
                -- In Blind Shot, the red line is usually a Beam or a long thin Part
                if Config.ShowLasers then
                    if part.Name:lower():find("laser") or part.Name:lower():find("beam") or part.Name:lower():find("trajectory") then
                        part.Transparency = 0
                        if part:IsA("Beam") then
                            part.Enabled = true
                        end
                    end
                end
            end

            -- 3. Apply Name Tags
            if Config.ShowNames then
                CreateNameTag(char, player.DisplayName)
            end
        end
    end
end

-- // 5. ENERGY & STAMINA SYSTEM //
local function LockStamina()
    local char = LocalPlayer.Character
    if not char or not Config.InfEnergy then return end

    -- Blind Shot uses Attributes on the Character model
    char:SetAttribute("Energy", 100)
    char:SetAttribute("Stamina", 100)
    char:SetAttribute("CanDash", true)
    
    -- Ensure Dash cooldown doesn't trigger
    local dashVal = char:FindFirstChild("DashCooldown") or char:FindFirstChild("Cooldown")
    if dashVal and dashVal:IsA("ValueBase") then
        dashVal.Value = 0
    end
end

-- // 6. BYPASSING THE BLINDFOLD UI //
local function ClearScreen()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        -- Find the specific frames that turn the screen black
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("Frame") or v:IsA("ImageLabel") then
                if v.Name == "Blindfold" or v.Name == "Overlay" or v.Name == "Blackout" then
                    v.Visible = false
                end
            end
        end
    end
end

-- // 7. RUNTIME LOOP //
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        UnhideEverything()
        ClearScreen()
        LockStamina()
    end
end)

-- // 8. USER INTERFACE //
local function BuildUI()
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "FullVision_v7"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 240, 0, 200)
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "FULL VISION ENGINE"
    Title.TextColor3 = Color3.fromRGB(0, 255, 150)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1

    local function Toggle(text, key, y)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0.9, 0, 0, 35)
        b.Position = UDim2.new(0.05, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = text .. ": ON"
        b.TextColor3 = Color3.fromRGB(0, 255, 150)
        b.Font = Enum.Font.Gotham
        Instance.new("UICorner", b)

        b.MouseButton1Click:Connect(function()
            Config[key] = not Config[key]
            b.Text = text .. (Config[key] and ": ON" or ": OFF")
            b.TextColor3 = Config[key] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
        end)
    end

    Toggle("Unhide Avatars", "ShowAvatars", 45)
    Toggle("Show Usernames", "ShowNames", 85)
    Toggle("Force Laser Visibility", "ShowLasers", 125)
    Toggle("Infinite Dash", "InfEnergy", 165)

    -- Draggable
    local d, ds, sp
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; sp = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

BuildUI()
print("[VISION] Blind Shot Master Engine Loaded.")
