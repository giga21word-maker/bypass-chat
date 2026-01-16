--[[
    AETHER-WALK V9: CLONED-GHOST PROJECTION ENGINE
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - NEW: Cloned-Ghost Avatar. You control a ghost while real body is in sky.
    - UPDATED: Camera and Inputs now bind to the Ghost Clone.
    - FIXED: Copy Position now pulls from the Ghost's location for precision.
    - STABLE: Zero lines deleted, only upgraded logic.
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
    VERSION = "V9.0.0 - Ghost Projection",
    PHANTOM_ZONE = Vector3.new(9999, 800, 9999)
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
    SafetyPart = nil,
    GhostModel = nil,
    GhostConnection = nil
}

-- // 4. GHOST PROJECTION ENGINE //
local function CleanupGhost()
    if Internal.GhostModel then Internal.GhostModel:Destroy() end
    if Internal.GhostConnection then Internal.GhostConnection:Disconnect() end
    Internal.GhostModel = nil
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function HandleGhostLogic(dt)
    if not AETHER_CONFIG.GOD_MODE or not Internal.GhostModel then return end
    
    local GhostRoot = Internal.GhostModel:FindFirstChild("HumanoidRootPart")
    local GhostHum = Internal.GhostModel:FindFirstChildOfClass("Humanoid")
    local RealChar = LocalPlayer.Character
    
    if GhostRoot and GhostHum then
        -- Mirroring Movement Inputs to Ghost
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            local TargetVel = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            GhostRoot.AssemblyLinearVelocity = TargetVel
            GhostRoot.CFrame = GhostRoot.CFrame + (TargetVel * dt * 0.08)
        else
            GhostRoot.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0)
        end
    end
end

-- // 5. THE PHANTOM BYPASS (UPDATED V9) //
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            Hum.WalkSpeed = 16
            
            if AETHER_CONFIG.GOD_MODE then
                -- INITIALIZE GHOST CLONE
                if not Internal.GhostModel then
                    Char.Archivable = true
                    Internal.GhostModel = Char:Clone()
                    Internal.GhostModel.Name = "Aether_Ghost"
                    Internal.GhostModel.Parent = Workspace
                    
                    -- Make Ghost Transparent/Blue to look like a ghost
                    for _, p in pairs(Internal.GhostModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 0.5
                            p.Color = Color3.fromRGB(0, 255, 255)
                            p.CanCollide = false
                        elseif p:IsA("Humanoid") then
                            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                    end
                    
                    Internal.GhostModel:SetPrimaryPartCFrame(Root.CFrame)
                    Camera.CameraSubject = Internal.GhostModel:FindFirstChildOfClass("Humanoid")
                end

                -- Build Safety Platform
                if not Internal.SafetyPart then
                    Internal.SafetyPart = Instance.new("Part", Workspace)
                    Internal.SafetyPart.Size = Vector3.new(50, 1, 50)
                    Internal.SafetyPart.Position = AETHER_CONFIG.PHANTOM_ZONE
                    Internal.SafetyPart.Anchored = true
                    Internal.SafetyPart.Transparency = 1
                end

                -- Move Real Body to Safety
                Root.CFrame = Internal.SafetyPart.CFrame + Vector3.new(0, 3, 0)
                Hum.MaxHealth = 999999
                Hum.Health = 999999
            else
                -- SNAP BACK TO GHOST POSITION ON TOGGLE OFF
                if Internal.GhostModel then
                    Root.CFrame = Internal.GhostModel.PrimaryPart.CFrame
                    CleanupGhost()
                end
            end
        end
    end)
end

-- // 6. THE AETHER-FLY ENGINE //
local function ExecuteAether(dt)
    if AETHER_CONFIG.GOD_MODE then 
        HandleGhostLogic(dt) -- Run ghost control instead of real control
        return 
    end
    if not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local MoveDir = Char:FindFirstChildOfClass("Humanoid").MoveDirection
    if MoveDir.Magnitude > 0 then
        local TargetVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
        Root.AssemblyLinearVelocity = TargetVelocity
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.08)
    else
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0)
    end
end

-- // 7. MODULAR UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV9_System") then CoreGui.AetherV9_System:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV9_System"

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

    local GodToggle = CreateButton("GHOST PROJECTION: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE
    end)

    CreateButton("THE DUG (CLIP TO PIT)", Color3.new(1, 1, 1), function()
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0)
    end)

    -- CLIPBOARD LOGIC
    CreateButton("COPY POSITION TO CLIPBOARD", Color3.fromRGB(255, 255, 0), function()
        -- Pull position from Ghost if active, else real body
        local posPart = (Internal.GhostModel and Internal.GhostModel.PrimaryPart) or LocalPlayer.Character.HumanoidRootPart
        local pos = posPart.Position
        local formatted = "Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
        if setclipboard then setclipboard(formatted) end
        print("Copied: " .. formatted)
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
        GodToggle.Text = AETHER_CONFIG.GOD_MODE and "GHOST PROJECTION: ON" or "GHOST PROJECTION: OFF"
        GodToggle.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
    end)

    SpeedBox.FocusLost:Connect(function()
        AETHER_CONFIG.SPEED = tonumber(SpeedBox.Text) or 80
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
print("[AETHER V9] Ghost Projection Engine Online.")
