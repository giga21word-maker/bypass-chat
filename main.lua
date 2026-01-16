--[[
    ELITE DELTA-SYNC MOVEMENT ENGINE (v2026.01)
    --------------------------------------------------
    [DEVELOPER NOTES]
    - TARGET: High-Security Server-Side Bypass.
    - METHOD: CFrame Delta Stepping + Sine-Wave Jitter.
    - PERSISTENCE: Locked Stamina & Energy (Instruction Sync).
    - COMPATIBILITY: Full Mobile Touch & PC support.
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // 2. SYSTEM CONSTANTS //
local SETTINGS = {
    ENABLED = false,
    SPEED_POWER = 5,
    JITTER_STRENGTH = 0.15,
    SYNC_FREQ = 1/60,
    GROUND_SCAN_DIST = 7.5,
    MAX_SPEED_CAP = 85,
    THEME_COLOR = Color3.fromRGB(0, 255, 120),
    GUI_NAME = "DeltaSync_Elite_v2026"
}

-- // 3. INTERNAL STATE TRACKING //
local State = {
    IsMobile = UserInputService.TouchEnabled,
    LastUpdate = tick(),
    FrameCounter = 0,
    MoveActive = false,
    DragState = false,
    OriginalWalkSpeed = 16
}

-- // 4. ATTRIBUTE PERSISTENCE (INSTRUCTION SYNC) //
-- Ensuring Stamina/Energy functions are locked and never deleted.
local function ForceAttributePersistence()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    pcall(function()
        -- Locking essential gameplay attributes
        Character:SetAttribute("Stamina", 100)
        Character:SetAttribute("Energy", 100)
        Character:SetAttribute("CanDash", true)
        
        -- Override game-specific fatigue states
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.JumpPower = 50 -- Standard
            -- Prevent the game from forcing a 'Slower' state
            if Humanoid.WalkSpeed < 16 then
                Humanoid.WalkSpeed = 16
            end
        end
    end)
end

-- // 5. THE DELTA-SYNC ENGINE //
local function ApplyDeltaMovement(deltaTime)
    if not SETTINGS.ENABLED then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    -- Verify player is actively attempting to move (Joystick/WASD)
    if Hum.MoveDirection.Magnitude > 0 then
        -- GROUND VERIFICATION: Prevents 'Fly' detection flags
        local RayParams = RaycastParams.new()
        RayParams.FilterDescendantsInstances = {Character}
        RayParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local Result = Workspace:Raycast(Root.Position, Vector3.new(0, -SETTINGS.GROUND_SCAN_DIST, 0), RayParams)
        
        if Result then
            State.FrameCounter = State.FrameCounter + 1
            
            -- SINE-WAVE JITTER: Mimics network inconsistency (Ping spikes)
            -- This makes the speed non-linear, which bypasses pattern detection
            local SineWave = math.sin(tick() * 25) * SETTINGS.JITTER_STRENGTH
            local AdaptiveMultiplier = (SETTINGS.SPEED_POWER * (1 + SineWave))
            
            -- DELTA STEP CALCULATION
            -- Standard Roblox physics runs at 60Hz; we scale by deltaTime to stay synced
            local MoveOffset = Hum.MoveDirection * (AdaptiveMultiplier * deltaTime * 6.5)
            
            -- PIVOT INTERPOLATION: Smoother than setting .CFrame directly
            local TargetCFrame = Root.CFrame + MoveOffset
            Root.CFrame = Root.CFrame:Lerp(TargetCFrame, 0.9)
        end
    end
end

-- // 6. ELITE MOBILE-READY INTERFACE //
local function InitializeInterface()
    -- Cleanup pre-existing UI for clean re-execution
    if CoreGui:FindFirstChild(SETTINGS.GUI_NAME) then
        CoreGui:FindFirstChild(SETTINGS.GUI_NAME):Destroy()
    end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = SETTINGS.GUI_NAME
    Screen.Parent = CoreGui
    Screen.IgnoreGuiInset = true

    -- OPEN/CLOSE BUTTON (Mobile Optimized)
    local Trigger = Instance.new("TextButton")
    Trigger.Name = "OpenTrigger"
    Trigger.Size = UDim2.new(0, 55, 0, 55)
    Trigger.Position = UDim2.new(0.02, 0, 0.45, 0)
    Trigger.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Trigger.Text = "SPD"
    Trigger.TextColor3 = SETTINGS.THEME_COLOR
    Trigger.Font = Enum.Font.GothamBold
    Trigger.TextSize = 18
    Trigger.Parent = Screen
    
    Instance.new("UICorner", Trigger).CornerRadius = UDim.new(1, 0)
    local TriggerStroke = Instance.new("UIStroke", Trigger)
    TriggerStroke.Color = SETTINGS.THEME_COLOR
    TriggerStroke.Thickness = 2

    -- MAIN HUB PANEL
    local Main = Instance.new("Frame")
    Main.Name = "ControlPanel"
    Main.Size = UDim2.new(0, 210, 0, 240)
    Main.Position = UDim2.new(0.12, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Parent = Screen

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local HubStroke = Instance.new("UIStroke", Main)
    HubStroke.Color = SETTINGS.THEME_COLOR
    HubStroke.Thickness = 1.5

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.Text = "DELTA-SYNC ELITE"
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.Font = Enum.Font.FredokaOne
    Header.TextSize = 18
    Header.BackgroundTransparency = 1
    Header.Parent = Main

    -- SPEED INPUT FIELD
    local InputLabel = Instance.new("TextLabel")
    InputLabel.Size = UDim2.new(1, 0, 0, 30)
    InputLabel.Position = UDim2.new(0, 0, 0.2, 0)
    InputLabel.Text = "BYPASS INTENSITY"
    InputLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    InputLabel.Font = Enum.Font.Gotham
    InputLabel.TextSize = 10
    InputLabel.BackgroundTransparency = 1
    InputLabel.Parent = Main

    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(0.8, 0, 0, 40)
    SpeedBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SpeedBox.Text = tostring(SETTINGS.SPEED_POWER)
    SpeedBox.TextColor3 = SETTINGS.THEME_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 22
    SpeedBox.Parent = Main
    
    Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 8)

    -- BYPASS TOGGLE BUTTON
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0.8, 0, 0, 50)
    Toggle.Position = UDim2.new(0.1, 0, 0.65, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 70, 70)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 16
    Toggle.Parent = Main
    
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

    -- FOOTER STATUS
    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 30)
    Footer.Position = UDim2.new(0, 0, 0.86, 0)
    Footer.Text = "SECURE BYPASS ACTIVE"
    Footer.TextColor3 = Color3.fromRGB(60, 60, 60)
    Footer.Font = Enum.Font.GothamItalic
    Footer.TextSize = 9
    Footer.BackgroundTransparency = 1
    Footer.Parent = Main

    -- // 7. UI INTERACTION LOGIC //
    
    Trigger.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        Trigger.Text = Main.Visible and "X" or "SPD"
        Trigger.TextColor3 = Main.Visible and Color3.fromRGB(255, 50, 50) or SETTINGS.THEME_COLOR
    end)

    SpeedBox.FocusLost:Connect(function()
        local n = tonumber(SpeedBox.Text)
        if n then
            SETTINGS.SPEED_POWER = math.clamp(n, 0, SETTINGS.MAX_SPEED_CAP)
            SpeedBox.Text = tostring(SETTINGS.SPEED_POWER)
        else
            SpeedBox.Text = tostring(SETTINGS.SPEED_POWER)
        end
    end)

    Toggle.MouseButton1Click:Connect(function()
        SETTINGS.ENABLED = not SETTINGS.ENABLED
        Toggle.Text = SETTINGS.ENABLED and "ON" or "OFF"
        Toggle.TextColor3 = SETTINGS.ENABLED and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 70, 70)
        Toggle.BackgroundColor3 = SETTINGS.ENABLED and Color3.fromRGB(15, 45, 25) or Color3.fromRGB(35, 35, 35)
        Footer.Text = SETTINGS.ENABLED and "INJECTING POSITION PACKETS..." or "IDLE - WAITING"
    end)

    -- MANUAL DRAG HANDLER (FOR TOUCH COMPATIBILITY)
    local function HandleDrag()
        local Dragging = false
        local DragInput, DragStart, StartPos

        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPos = Main.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local Delta = input.Position - DragStart
                Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            end
        end)
    end
    
    HandleDrag()
end

-- // 8. MASTER RUNTIME LOOPS //

-- HEARTBEAT: Primary physics frame update
RunService.Heartbeat:Connect(function(dt)
    -- Layer 1: Movement Bypass Logic
    pcall(function()
        ApplyDeltaMovement(dt)
    end)
    
    -- Layer 2: Constant Attribute Guard (Stamina/Energy)
    ForceAttributePersistence()
end)

-- STEPPED: Secondary check for internal WalkSpeed property (Anti-Cheat Bypass)
RunService.Stepped:Connect(function()
    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        -- Force internal property to 16. Server scans see 'Normal' walkspeed.
        Humanoid.WalkSpeed = 16 
    end
end)

-- // 9. FINAL INITIALIZATION //
InitializeInterface()

print([[
--------------------------------------------------
   DELTA-SYNC ELITE LOADED
   - Lines: 315
   - Mode: Stealth Bypass
   - Status: Mobile Ready
--------------------------------------------------
]])
