--[[
    AETHER-WALK V8: OBLITERATOR + PHANTOM-TP + CLIPBOARD SYNC
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - UPDATED: God Mode now uses Phantom-TP (Body to sky, POV stays at spot).
    - ADDED: Clipboard Sync - "Copy Position" now saves directly to device.
    - FIXED: All previous logic preserved and optimized for zero-deletion.
    ----------------------------------------------------------
]]

-- // 1. CORE SYSTEM SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // 2. ELITE CONFIGURATION //
local AETHER_CONFIG = {
    ENABLED = false,
    GOD_MODE = false,
    SPEED = 80,
    MAX_CAP = 1000,
    UI_COLOR = Color3.fromRGB(0, 255, 180),
    SAVED_POS = nil,
    VERSION = "V8.0.0 - Phantom Logic",
    PHANTOM_ZONE = Vector3.new(9999, 800, 9999), -- Distant safety height
    GHOST_POS = nil
}

-- Current Zones
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
    UIVisible = true,
    SafetyPart = nil
}

-- // 4. THE PHANTOM BYPASS (GOD MODE + ANTI-CHEAT) //
-- Optimized: Now handles physical body separation (Phantom-TP)
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            Hum.WalkSpeed = 16
            Char:SetAttribute("Stamina", 100)
            Char:SetAttribute("Energy", 100)
            
            if AETHER_CONFIG.ENABLED and not AETHER_CONFIG.GOD_MODE then
                Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end

            -- NEW PHANTOM LOGIC: Moves body to safety but locks POV
            if AETHER_CONFIG.GOD_MODE then
                -- Build Safety Platform in sky if not exists
                if not Internal.SafetyPart then
                    Internal.SafetyPart = Instance.new("Part", Workspace)
                    Internal.SafetyPart.Size = Vector3.new(50, 1, 50)
                    Internal.SafetyPart.Position = AETHER_CONFIG.PHANTOM_ZONE
                    Internal.SafetyPart.Anchored = true
                    Internal.SafetyPart.Transparency = 1
                    Internal.SafetyPart.Name = "Aether_Safety"
                end

                -- Record where we were before TPing
                if not AETHER_CONFIG.GHOST_POS then
                    AETHER_CONFIG.GHOST_POS = Root.CFrame
                end

                -- Move physical body to sky platform
                Root.CFrame = Internal.SafetyPart.CFrame + Vector3.new(0, 3, 0)
                Root.AssemblyLinearVelocity = Vector3.new(0,0,0)

                -- Lock Camera to the Ghost Location so you can still play
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = AETHER_CONFIG.GHOST_POS * CFrame.new(0, 1.5, 0)

                -- Disable touches to prevent kill scripts reaching the ghost
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanTouch = false end
                end
                Hum.MaxHealth = 999999
                Hum.Health = 999999
            else
                -- Toggle Off: Snap back to ghost and restore camera
                if AETHER_CONFIG.GHOST_POS then
                    Root.CFrame = AETHER_CONFIG.GHOST_POS
                    AETHER_CONFIG.GHOST_POS = nil
                    Camera.CameraType = Enum.CameraType.Custom
                    for _, part in pairs(Char:GetChildren()) do
                        if part:IsA("BasePart") then part.CanTouch = true end
                    end
                end
            end
        end
    end)
end

-- // 5. THE AETHER-FLY ENGINE //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ENABLED or AETHER_CONFIG.GOD_MODE then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    local Look = Camera.CFrame.LookVector
    local MoveDir = Hum.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        local TargetVelocity = Look * AETHER_CONFIG.SPEED
        Root.AssemblyLinearVelocity = TargetVelocity
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.08)
    else
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0)
    end
end

-- // 6. MODULAR UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV8_System") then CoreGui.AetherV8_System:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV8_System"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 260, 0, 440)
    Main.Position = UDim2.new(0.05, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = AETHER_CONFIG.UI_COLOR

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "AETHER WALK - " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -20, 1, -60)
    Scroll.Position = UDim2.new(0, 10, 0, 50)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 2.2, 0)
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
        btn.TextSize = 11
        Instance.new("UICorner", btn)
        btn.MouseButton1Down:Connect(callback)
        return btn
    end

    -- SPEED INPUT
    local SpeedBox = Instance.new("TextBox", Scroll)
    SpeedBox.Size = UDim2.new(0.95, 0, 0, 45)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedBox.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 25
    SpeedBox.ClearTextOnFocus = false
    Instance.new("UICorner", SpeedBox)

    local FlyToggle = CreateButton("FLY ENGINE: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED
    end)

    local GodToggle = CreateButton("PHANTOM GOD: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE
    end)

    CreateButton("THE DUG (CLIP TO PIT)", Color3.new(1, 1, 1), function()
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0)
    end)

    -- CLIPBOARD LOGIC
    CreateButton("COPY POSITION TO CLIPBOARD", Color3.fromRGB(255, 255, 0), function()
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        if AETHER_CONFIG.GHOST_POS then pos = AETHER_CONFIG.GHOST_POS.Position end -- Copy ghost pos if in God Mode
        local formatted = "Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
        if setclipboard then
            setclipboard(formatted)
            print("Copied to Clipboard: " .. formatted)
        else
            print("COORDS (No setclipboard): " .. formatted)
        end
    end)

    CreateButton("SAVE SPOT", Color3.new(0, 1, 0), function()
        AETHER_CONFIG.SAVED_POS = AETHER_CONFIG.GHOST_POS or LocalPlayer.Character.HumanoidRootPart.CFrame
    end)

    CreateButton("LOAD SPOT", Color3.new(1, 1, 0), function()
        if AETHER_CONFIG.SAVED_POS then LocalPlayer.Character.HumanoidRootPart.CFrame = AETHER_CONFIG.SAVED_POS end
    end)

    -- ZONE TPs
    CreateButton("--- ZONE TELEPORTS ---", Color3.new(0.6, 0.6, 0.6), function() end)
    for zone, pos in pairs(ZONES) do
        CreateButton("TP TO " .. zone, Color3.fromRGB(0, 180, 255), function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end)
    end

    -- UI UPDATES
    RunService.RenderStepped:Connect(function()
        FlyToggle.Text = AETHER_CONFIG.ENABLED and "FLY ENGINE: ON" or "FLY ENGINE: OFF"
        FlyToggle.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
        GodToggle.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM GOD: ON" or "PHANTOM GOD: OFF"
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

    -- Dragging
    local d, dS, sP
    Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; dS = i.Position; sP = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dS; Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

-- // RUNTIME //
RunService.Heartbeat:Connect(function(dt)
    ExecuteAether(dt)
    GlobalBypassSync()
end)

BuildUI()
print("[SUCCESS] Aether-Walk V8 Loaded. Phantom-TP and Clipboard Sync Active.")
