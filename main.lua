--[[
    ADAPTIVE LATENCY SPEED ENGINE
    - Sine-Wave Velocity: Fluctuates speed naturally to bypass server checks.
    - Raycast Ground-Lock: Prevents mid-air speed flags (No-Fly).
    - Attribute Preservation: Keeps Stamina/Energy functions locked.
    - Smart-GUI: Responsive and non-intrusive.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // SETTINGS //
local SpeedConfig = {
    Enabled = false,
    Power = 8,           -- Base Speed Boost
    Frequency = 0.5,     -- How fast the "jitter" cycles
    Amplitude = 0.15,    -- 15% variation in speed
    MaxSafeLimit = 35
}

-- // SMART BYPASS ENGINE //
local tickCounter = 0
local function SmartMove(dt)
    if not SpeedConfig.Enabled then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if root and hum and hum.MoveDirection.Magnitude > 0 then
        -- 1. GROUND CHECK (Bypasses Fly-Detection)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        local groundCheck = workspace:Raycast(root.Position, Vector3.new(0, -7, 0), rayParams)
        
        if groundCheck then
            -- 2. SINE-WAVE CALCULATION (Mimics Network Jitter)
            tickCounter = tickCounter + dt
            local wave = 1 + (math.sin(tickCounter * (1/SpeedConfig.Frequency)) * SpeedConfig.Amplitude)
            local finalSpeed = (SpeedConfig.Power * wave) / 10
            
            -- 3. INTERPOLATED MOVEMENT
            -- We use MoveDirection * finalSpeed to nudge the CFrame
            local moveVector = hum.MoveDirection * finalSpeed
            root.CFrame = root.CFrame + moveVector
        end
    end
end

-- // STAMINA LOCK (Fixed - No Shortage) //
local function LockAttributes()
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            char:SetAttribute("Stamina", 100)
            char:SetAttribute("Energy", 100)
            char:SetAttribute("CanDash", true)
        end)
    end
end

-- // INTERFACE CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("AdaptiveSpeed_UI") then
        CoreGui.AdaptiveSpeed_UI:Destroy()
    end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AdaptiveSpeed_UI"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 190, 0, 140)
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

    local Glow = Instance.new("Frame", Main)
    Glow.Size = UDim2.new(1, 4, 1, 4)
    Glow.Position = UDim2.new(0, -2, 0, -2)
    Glow.ZIndex = 0
    Glow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "SMART BYPASS"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.Size = UDim2.new(0.8, 0, 0, 30)
    Input.Position = UDim2.new(0.1, 0, 0.35, 0)
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Input.Text = tostring(SpeedConfig.Power)
    Input.TextColor3 = Color3.new(0, 0.8, 1)
    Input.Font = Enum.Font.Code
    Instance.new("UICorner", Input)

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 35)
    Toggle.Position = UDim2.new(0.1, 0, 0.65, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.Text = "STELTH: OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 60, 60)
    Toggle.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Toggle)

    -- Logic
    Input.FocusLost:Connect(function()
        local n = tonumber(Input.Text)
        if n then
            SpeedConfig.Power = math.clamp(n, 1, SpeedConfig.MaxSafeLimit)
            Input.Text = tostring(SpeedConfig.Power)
        end
    end)

    Toggle.MouseButton1Click:Connect(function()
        SpeedConfig.Enabled = not SpeedConfig.Enabled
        Toggle.Text = SpeedConfig.Enabled and "STELTH: ON" or "STELTH: OFF"
        Toggle.TextColor3 = SpeedConfig.Enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
        Glow.BackgroundColor3 = SpeedConfig.Enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(0, 150, 255)
    end)

    -- Draggable Logic
    local d, ds, sp
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

-- // RUNTIME LOOPS //
RunService.Heartbeat:Connect(function(dt)
    SmartMove(dt)
    LockAttributes()
end)

BuildUI()
print("[BYPASS] Adaptive Sine-Wave Speed Engine Loaded.")
