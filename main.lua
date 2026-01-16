--[[
    AETHER-WALK V4: VELOCITY-INJECTION BYPASS
    --------------------------------------------------
    [FIXES]
    - Vertical Flight: Uses Force-Vectoring to overcome gravity.
    - Speed Bypass: Frame-splits high velocity to avoid ban-flags.
    - State Lock: Forces 'Running' but prevents floor-clipping.
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
    SPEED = 80, -- High speed (Bypassed)
    UI_COLOR = Color3.fromRGB(0, 255, 180),
    MAX_CAP = 300
}

-- // 3. ENGINE STATE //
local Internal = {
    Clock = 0,
    LastSpeed = 80,
    FlightForce = nil
}

-- // 4. ATTRIBUTE & SPEED BYPASS (INSTRUCTION SYNC) //
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        -- Locking Attributes (Stamina/Energy)
        Char:SetAttribute("Stamina", 100)
        Char:SetAttribute("Energy", 100)
        
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            -- THE BYPASS: We lock WalkSpeed to 16 so server-scans pass.
            -- Our engine handles the REAL speed via CFrame/Velocity injection.
            Hum.WalkSpeed = 16
            
            if AETHER_CONFIG.ENABLED then
                Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end
    end)
end

-- // 5. THE AETHER-FLY ENGINE //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    -- CALCULATE DIRECTIONAL VECTOR
    local Look = Camera.CFrame.LookVector
    local MoveDir = Hum.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        -- SPEED BYPASS LOGIC:
        -- Instead of teleporting, we apply a consistent velocity vector
        -- that mimics high-latency movement to bypass anti-cheat checks.
        local TargetVelocity = Look * AETHER_CONFIG.SPEED
        
        -- Apply the force directly to the RootPart's physics assembly
        Root.AssemblyLinearVelocity = TargetVelocity
        
        -- Frame-Splitting: Micro-CFrame adjustment to ensure verticality works
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.1)
    else
        -- HOVER: Counteract Gravity perfectly
        -- Vector3.new(0, 1.1, 0) is the "Magic Number" to float in most engines
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
    end
end

-- // 6. RECONSTRUCTED MOBILE UI (STICKY INPUT) //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV4") then CoreGui.AetherV4:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV4"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 160)
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = AETHER_CONFIG.UI_COLOR

    -- LARGE SPEED BOX
    local SpeedInput = Instance.new("TextBox", Main)
    SpeedInput.Size = UDim2.new(0.8, 0, 0, 50)
    SpeedInput.Position = UDim2.new(0.1, 0, 0.1, 0)
    SpeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SpeedInput.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedInput.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedInput.Font = Enum.Font.Code
    SpeedInput.TextSize = 30
    SpeedInput.ClearTextOnFocus = false
    Instance.new("UICorner", SpeedInput)

    -- TOGGLE BUTTON
    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 60)
    Toggle.Position = UDim2.new(0.1, 0, 0.5, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Toggle.Text = "FLY: OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 60, 60)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 20
    Instance.new("UICorner", Toggle)

    -- LOGIC
    SpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber(SpeedInput.Text)
        if n then Internal.LastSpeed = n end
    end)

    SpeedInput.FocusLost:Connect(function()
        AETHER_CONFIG.SPEED = math.clamp(Internal.LastSpeed, 0, AETHER_CONFIG.MAX_CAP)
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
    
    -- Drag Handler
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
print("[LOADED] Aether-Walk V4: Vertical Speed Bypass Active.")
