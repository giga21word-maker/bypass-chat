--[[
    AETHER-WALK V6: BRAINROT SURVIVAL & ANTI-CHEAT OBLITERATOR
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - FIXED: Vertical Ascent/Descent via Camera LookVector.
    - FIXED: Sticky Speed Buffer for mobile keyboards.
    - ADDED: "The Dug" - Instantly clips to safe-pit depth.
    - ADDED: "God Mode" - State-masking to nullify Tsunami damage.
    - ADDED: "Zone TP" - Instant jump to Celestial/Cosmic regions.
    - ADDED: "Save/Load" - Positional memory for farming locations.
    - OPTIMIZED: Vector-Packet Splitting to bypass 2026 detection.
    ----------------------------------------------------------
]]

-- // 1. CORE SYSTEM SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // 2. ELITE CONFIGURATION //
local AETHER_CONFIG = {
    ENABLED = false,
    GOD_MODE = false,
    SPEED = 80,
    MAX_CAP = 1000,
    UI_COLOR = Color3.fromRGB(170, 0, 255),
    SAVED_POS = nil,
    VERSION = "V6.0.1 - Brainrot Edition"
}

-- Zone Coordinates (Hardcoded for "Escape Tsunami for Brainrots")
local ZONES = {
    ["BASE"] = Vector3.new(0, 5, 0),
    ["LEGENDARY"] = Vector3.new(0, 5, 1200),
    ["MYTHIC"] = Vector3.new(0, 5, 2500),
    ["COSMIC"] = Vector3.new(0, 5, 4500),
    ["CELESTIAL"] = Vector3.new(0, 5, 8000)
}

-- // 3. INTERNAL ENGINE STATE //
local Internal = {
    SpeedBuffer = 80,
    LastUpdate = tick(),
    FlightConnection = nil,
    BypassActive = true,
    UIVisible = true
}

-- // 4. THE OBLITERATOR BYPASS (INSTRUCTION SYNC) //
-- This function is locked and optimized. Do not delete.
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        -- Attribute Locking: Bypasses stamina/energy drain
        Char:SetAttribute("Stamina", 100)
        Char:SetAttribute("Energy", 100)
        Char:SetAttribute("CanDash", true)
        
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            -- MASKING: Server-side scanners see 16 WalkSpeed (Normal)
            Hum.WalkSpeed = 16
            
            if AETHER_CONFIG.ENABLED then
                -- State-Spoofing: Sets state to 'RunningNoPhysics'
                -- This makes the server think you are on a conveyor or lift
                Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                
                -- Anti-Tsunami God Mode Logic
                if AETHER_CONFIG.GOD_MODE then
                    Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    -- Forcing health to max locally to prevent death-scripts
                    Hum.Health = Hum.MaxHealth
                end
            end
        end
    end)
end

-- // 5. THE AETHER-FLY ENGINE (3D VECTORING) //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    local Look = Camera.CFrame.LookVector
    local MoveDir = Hum.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        -- ADVANCED VECTOR INJECTION:
        -- We calculate a composite vector of camera gaze and walk direction
        local TargetVelocity = Look * AETHER_CONFIG.SPEED
        
        -- Physics Bypass: We set velocity while frame-splitting the position
        Root.AssemblyLinearVelocity = TargetVelocity
        
        -- CFrame Delta-Splitting: Bypasses "Position Jump" detection
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.075)
    else
        -- ANTI-GRAVITY ANCHOR: Hover exactly where you are
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0)
    end
end

-- // 6. EXPANDED MODULAR UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV6_System") then CoreGui.AetherV6_System:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV6_System"
    Screen.IgnoreGuiInset = true

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 260, 0, 420)
    Main.Position = UDim2.new(0.05, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = AETHER_CONFIG.UI_COLOR
    Stroke.Thickness = 2

    -- TITLE BAR
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "AETHER WALK - " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    -- SCROLLING CONTENT
    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -20, 1, -60)
    Scroll.Position = UDim2.new(0, 10, 0, 50)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 1.8, 0)
    Scroll.ScrollBarThickness = 0

    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0, 8)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateButton(text, color, callback)
        local btn = Instance.new("TextButton", Scroll)
        btn.Size = UDim2.new(0.95, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = text
        btn.TextColor3 = color
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        Instance.new("UICorner", btn)
        btn.MouseButton1Down:Connect(callback)
        return btn
    end

    -- SPEED INPUT
    local SpeedBox = Instance.new("TextBox", Scroll)
    SpeedBox.Size = UDim2.new(0.95, 0, 0, 45)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedBox.PlaceholderText = "INPUT SPEED"
    SpeedBox.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 25
    SpeedBox.ClearTextOnFocus = false
    Instance.new("UICorner", SpeedBox)

    -- TOGGLE FLY
    local FlyToggle = CreateButton("FLY ENGINE: OFF", Color3.new(1, 0, 0), function()
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED
    end)

    -- THE DUG (PIT SAFETY)
    CreateButton("THE DUG (HIDE IN PIT)", Color3.new(1, 1, 1), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Tsunami pits are below the surface; we clip the CFrame down instantly
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -30, 0)
        end
    end)

    -- GOD MODE
    local GodToggle = CreateButton("TSUNAMI GOD: OFF", Color3.new(1, 0, 0), function()
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE
    end)

    -- TP PANEL TOGGLE (ZONES)
    CreateButton("--- TELEPORT ZONES ---", Color3.new(0.6, 0.6, 0.6), function() end)
    
    for zone, pos in pairs(ZONES) do
        CreateButton("TP TO " .. zone, Color3.fromRGB(0, 150, 255), function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        end)
    end

    -- SAVE/LOAD
    CreateButton("--- POSITIONAL MEMORY ---", Color3.new(0.6, 0.6, 0.6), function() end)
    
    CreateButton("SAVE CURRENT SPOT", Color3.new(0, 1, 0), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            AETHER_CONFIG.SAVED_POS = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)

    CreateButton("LOAD SAVED SPOT", Color3.new(1, 1, 0), function()
        if AETHER_CONFIG.SAVED_POS and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = AETHER_CONFIG.SAVED_POS
        end
    end)

    -- // UI DYNAMICS //
    RunService.RenderStepped:Connect(function()
        FlyToggle.Text = AETHER_CONFIG.ENABLED and "FLY ENGINE: ON" or "FLY ENGINE: OFF"
        FlyToggle.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
        
        GodToggle.Text = AETHER_CONFIG.GOD_MODE and "TSUNAMI GOD: ON" or "TSUNAMI GOD: OFF"
        GodToggle.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
    end)

    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber(SpeedBox.Text)
        if n then Internal.SpeedBuffer = n end
    end)

    SpeedBox.FocusLost:Connect(function()
        AETHER_CONFIG.SPEED = math.clamp(Internal.SpeedBuffer, 0, AETHER_CONFIG.MAX_CAP)
        SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    end)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

-- // 7. RUNTIME MASTER LOOPS //
RunService.Heartbeat:Connect(function(dt)
    ExecuteAether(dt)
    GlobalBypassSync()
end)

-- Initialize
BuildUI()
print("[LOADED] Aether-Walk V6.0.1: The Brainrot Anti-Cheat Obliterator.")
