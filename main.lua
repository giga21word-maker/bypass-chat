--[[
    MOBILE-OPTIMIZED SMART SPEED (v2026)
    - Touch-Safe GUI: Designed for mobile screens.
    - CFrame Delta Movement: Bypasses WalkSpeed checks.
    - Ground-Lock: Ensures no flying/floating flags.
    - Attribute Lock: Persistent Stamina/Energy for Blind Shot.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // SETTINGS //
local SpeedConfig = {
    Enabled = false,
    Power = 5,
    MaxLimit = 40
}

-- // CORE ENGINE //
local function ApplyMobileSpeed()
    if not SpeedConfig.Enabled then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    -- Mobile Joystick Check (MoveDirection)
    if root and hum and hum.MoveDirection.Magnitude > 0 then
        -- Raycast to ensure we are on ground
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        local groundCheck = workspace:Raycast(root.Position, Vector3.new(0, -7, 0), rayParams)
        
        if groundCheck then
            -- Delta-move (Nudge character forward)
            local moveVector = hum.MoveDirection * (SpeedConfig.Power / 12)
            root.CFrame = root.CFrame + moveVector
        end
    end
end

-- // STAMINA LOCK //
local function PersistAttributes()
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            char:SetAttribute("Stamina", 100)
            char:SetAttribute("Energy", 100)
        end)
    end
end

-- // MOBILE GUI //
local function BuildMobileUI()
    -- Cleanup
    if CoreGui:FindFirstChild("MobileSpeed_UI") then CoreGui.MobileSpeed_UI:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "MobileSpeed_UI"

    -- Open/Close Button (For Mobile)
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    OpenBtn.Text = "SPD"
    OpenBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", OpenBtn)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 180, 0, 150)
    Main.Position = UDim2.new(0.1, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.Visible = false
    Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Text = "SPEED SET"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold

    local Input = Instance.new("TextBox", Main)
    Input.Size = UDim2.new(0.8, 0, 0, 35)
    Input.Position = UDim2.new(0.1, 0, 0.3, 0)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Input.Text = tostring(SpeedConfig.Power)
    Input.PlaceholderText = "Enter Speed..."
    Input.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Input)

    local ApplyBtn = Instance.new("TextButton", Main)
    ApplyBtn.Size = UDim2.new(0.8, 0, 0, 35)
    ApplyBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
    ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    ApplyBtn.Text = "OFF"
    ApplyBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", ApplyBtn)

    -- Mobile Functionality
    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    Input.FocusLost:Connect(function()
        local n = tonumber(Input.Text)
        if n then
            SpeedConfig.Power = math.clamp(n, 0, SpeedConfig.MaxLimit)
            Input.Text = tostring(SpeedConfig.Power)
        end
    end)

    ApplyBtn.MouseButton1Click:Connect(function()
        SpeedConfig.Enabled = not SpeedConfig.Enabled
        ApplyBtn.Text = SpeedConfig.Enabled and "ON" or "OFF"
        ApplyBtn.BackgroundColor3 = SpeedConfig.Enabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 0, 0)
    end)
    
    -- Make Main Draggable for Mobile
    local drag, dPos, sPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dPos = i.Position; sPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = i.Position - dPos
            Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() drag = false end)
end

-- // RUNTIME //
RunService.Heartbeat:Connect(function()
    ApplyMobileSpeed()
    PersistAttributes()
end)

BuildMobileUI()
print("Mobile Speed Bypass Ready. Tap 'SPD' to configure.")
