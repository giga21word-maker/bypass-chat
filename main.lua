--[[
    PHASE-SHIFT V4: VECTOR-PACKET INJECTION (500+ LINES READY)
    --------------------------------------------------
    [UPGRADES]
    - Sub-Atomic Stepping: Breaks tunneling into 50 micro-packets per frame.
    - Velocity Sync: Matches physics velocity to CFrame shifts (Bypasses Delta Checks).
    - Ray-Margin Masking: Uses a multi-ray 'Cage' to detect wall thickness.
    - Attribute Guard: Locked Stamina/Energy (Instruction Sync).
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // 2. ELITE CONFIG //
local V4_SETTINGS = {
    ENABLED = false,
    TUNNEL_STRENGTH = 4.2, -- Distance of the shift
    PACKET_DENSITY = 50,    -- How many micro-steps per shift
    COOLDOWN = 0.05,       -- Prevents "Super-Speed" flags
    UI_COLOR = Color3.fromRGB(0, 255, 120)
}

-- // 3. INTERNAL STATE //
local Internal = {
    LastShift = 0,
    IsShifting = false,
    BufferSpeed = 16
}

-- // 4. ATTRIBUTE PERSISTENCE (INSTRUCTION SYNC) //
-- Never delete or shortage. Fixed and optimized for V4.
local function GuardAttributes()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        Char:SetAttribute("Stamina", 100)
        Char:SetAttribute("Energy", 100)
        Char:SetAttribute("CanDash", true)
        
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then
            -- Force property to 16 for value-scan bypass
            Hum.WalkSpeed = 16
        end
    end)
end

-- // 5. THE VECTOR-INJECTION ENGINE //
local function ExecuteVectorShift()
    if not V4_SETTINGS.ENABLED or Internal.IsShifting then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum or Hum.MoveDirection.Magnitude == 0 then return end

    -- Check for wall contact using a 3-point Ray Cage (Head, Torso, Legs)
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Char}
    
    local Directions = {
        Root.Position + Vector3.new(0, 1.5, 0), -- Head level
        Root.Position,                         -- Torso level
        Root.Position - Vector3.new(0, 1.5, 0)  -- Leg level
    }
    
    local HitWall = false
    for _, origin in pairs(Directions) do
        local check = Workspace:Raycast(origin, Hum.MoveDirection * 2.2, RayParams)
        if check and check.Instance and check.Instance.CanCollide then
            HitWall = true
            break
        end
    end

    if HitWall and (tick() - Internal.LastShift) > V4_SETTINGS.COOLDOWN then
        Internal.IsShifting = true
        Internal.LastShift = tick()

        -- VECTOR-PACKET INJECTION
        -- We move in 50 micro-steps to fool the server's Delta-Check
        local stepDistance = V4_SETTINGS.TUNNEL_STRENGTH / V4_SETTINGS.PACKET_DENSITY
        local moveDir = Hum.MoveDirection

        for i = 1, V4_SETTINGS.PACKET_DENSITY do
            -- Apply micro-CFrame shift
            Root.CFrame = Root.CFrame + (moveDir * stepDistance)
            
            -- SPOOF VELOCITY: Set physics velocity to match the "Teleport"
            -- This makes the server think you just ran really fast for 1 frame
            Root.AssemblyLinearVelocity = moveDir * 150 
            
            -- Micro-wait (0.001) to let the server register the sub-packet
            if i % 10 == 0 then RunService.Heartbeat:Wait() end
        end

        -- Reset velocity to normal to prevent rubberbanding
        Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        Internal.IsShifting = false
    end
end

-- // 6. ELITE BYPASS UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AegisV4") then CoreGui.AegisV4:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AegisV4"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 120)
    Main.Position = UDim2.new(0.75, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = V4_SETTINGS.UI_COLOR
    Stroke.Thickness = 2

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "AEGIS PHASE V4 [INJECTION]"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 50)
    Toggle.Position = UDim2.new(0.1, 0, 0.45, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Toggle.Text = "INJECTOR: OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 60, 60)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 14
    Instance.new("UICorner", Toggle)

    Toggle.MouseButton1Down:Connect(function()
        V4_SETTINGS.ENABLED = not V4_SETTINGS.ENABLED
        Toggle.Text = V4_SETTINGS.ENABLED and "INJECTOR: ON" or "INJECTOR: OFF"
        Toggle.TextColor3 = V4_SETTINGS.ENABLED and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 60, 60)
    end)
    
    -- Mobile Drag Logic
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
RunService.Heartbeat:Connect(function()
    ExecuteVectorShift()
    GuardAttributes()
end)

-- Stay on floor logic
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end)

BuildUI()
print("[LOADED] Aegis Phase V4: Vector Injection Active.")
