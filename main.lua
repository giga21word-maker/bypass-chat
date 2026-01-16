--[[
    AETHER-WALK V5: VELOCITY-INJECTION + CUSTOM SPEED BYPASS
    --------------------------------------------------
    [FIXES]
    - Vertical Flight: Uses Force-Vectoring to overcome gravity via Camera Look.
    - Speed Bypass: Frame-splits high velocity and masks WalkSpeed at 16.
    - State Lock: Forces 'RunningNoPhysics' to bypass flight detection.
    - Custom Input: Added sticky-buffer text box for speed control.
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // 2. ELITE CONFIG //
local AETHER_CONFIG = {
    ENABLED = false,
    SPEED = 80, 
    UI_COLOR = Color3.fromRGB(0, 255, 180),
    MAX_CAP = 500 -- Increased cap for speed testing
}

-- // 3. ENGINE STATE //
local Internal = {
    Clock = 0,
    SpeedBuffer = 80, -- Sticky Buffer for mobile keyboards
    FlightForce = nil
}

-- // 4. ATTRIBUTE & SPEED BYPASS (INSTRUCTION SYNC) //
-- Functions are locked, fixed, and optimized. Never deleted.
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        -- Locking Attributes (Stamina/Energy/Blind-Shot Checks)
        Char:SetAttribute("Stamina", 100)
        Char:SetAttribute("Energy", 100)
        Char:SetAttribute("CanDash", true)
        
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            -- BYPASS: Server sees 16 (Normal), Engine provides CUSTOM_SPEED
            Hum.WalkSpeed = 16
            
            if AETHER_CONFIG.ENABLED then
                -- Spoofs state to ignore standard floor-physics checks
                Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end
    end)
end

-- // 5. THE AETHER-FLY ENGINE (3D AXIS) //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    -- CALCULATE DIRECTIONAL VECTOR (Look up to go up, look down to go down)
    local Look = Camera.CFrame.LookVector
    local MoveDir = Hum.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        -- SPEED BYPASS LOGIC:
        -- Applying TargetVelocity to the physics assembly while frame-splitting the CFrame.
        local TargetVelocity = Look * AETHER_CONFIG.SPEED
        
        Root.AssemblyLinearVelocity = TargetVelocity
        
        -- Micro-CFrame adjustment ensures you move through 3D space even if gravity resists
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.08)
    else
        -- HOVER: Counteract Gravity perfectly (Weightless walk)
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
    end
end

-- // 6. RECONSTRUCTED MOBILE UI (STICKY INPUT) //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV5_Console") then CoreGui.AetherV5_Console:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV5_Console"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 180) -- Slightly taller for the new input
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = AETHER_CONFIG.UI_COLOR
    Stroke.Thickness = 2

    -- TITLE
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "AETHER WALK V5"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 16
    Title.BackgroundTransparency = 1

    -- LARGE SPEED BOX (CUSTOM UPDATE)
    local SpeedInput = Instance.new("TextBox", Main)
    SpeedInput.Size = UDim2.new(0.8, 0, 0, 50)
    SpeedInput.Position = UDim2.new(0.1, 0, 0.25, 0)
    SpeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SpeedInput.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedInput.PlaceholderText = "SPEED"
    SpeedInput.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedInput.Font = Enum.Font.Code
    SpeedInput.TextSize = 30
    SpeedInput.ClearTextOnFocus = false
    Instance.new("UICorner", SpeedInput)

    -- TOGGLE BUTTON
    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 50)
    Toggle.Position = UDim2.new(0.1, 0, 0.65, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Toggle.Text = "FLY: OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 60, 60)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 18
    Instance.new("UICorner", Toggle)

    -- // UI INTERACTION LOGIC //
    
    -- Sticky Buffer ensures that typing on mobile doesn't reset the speed
    SpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber(SpeedInput.Text)
        if n then Internal.SpeedBuffer = n end
    end)

    SpeedInput.FocusLost:Connect(function()
        AETHER_CONFIG.SPEED = math.clamp(Internal.SpeedBuffer, 0, AETHER_CONFIG.MAX_CAP)
        SpeedInput.Text = tostring(AETHER_CONFIG.SPEED)
    end)

    Toggle.MouseButton1Down:Connect(function()
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED
        Toggle.Text = AETHER_CONFIG.ENABLED and "FLY: ON" or "FLY: OFF"
        Toggle.TextColor3 = AETHER_CONFIG.ENABLED and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 60, 60)
        
        if not AETHER_CONFIG.ENABLED then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
        end
    end)
    
    -- Standard Drag Handler
    local d, dS, sP
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; dS = i.Position; sP = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dS
            Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

-- // 7. RUNTIME //
RunService.Heartbeat:Connect(function(dt)
    ExecuteAether(dt)
    GlobalBypassSync()
end)

BuildUI()
print("[SUCCESS] Aether-Walk V5: Custom Speed & 3D Axis Active.")
