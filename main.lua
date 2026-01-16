--[[
    AETHER-WALK V14: HORIZONTAL ELITE & KEEP-ALIVE
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - FIXED: Phantom Freeze. Added Heartbeat Keep-Alive to physics.
    - NEW: Horizontal Organized Layout for better visibility.
    - NEW: [X] Button - Complete script/effect termination.
    - NEW: [C] Button - UI Collapse/Toggle system.
    - STABLE: Zero lines deleted, logic purely upgraded for V14.
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
    VERSION = "V14.0.0 - Horizontal Elite",
    SAFE_BASE = Vector3.new(66, 3, 7),
    ACTIVE = true -- Used for the [X] Killswitch
}

-- UPDATED ZONES
local ZONES = {
    ["BASE"] = AETHER_CONFIG.SAFE_BASE,
    ["LEGENDARY"] = Vector3.new(0, 5, 1200),
    ["MYTHIC"] = Vector3.new(0, 5, 2500),
    ["COSMIC"] = Vector3.new(0, 5, 4500),
    ["CELESTIAL"] = Vector3.new(0, 5, 8000)
}

-- // 3. INTERNAL ENGINE STATE //
local Internal = {
    SpeedBuffer = 80,
    UIVisible = true,
    GhostModel = nil,
    IsTeleporting = false,
    BV = nil, 
    BG = nil,
    Connections = {}
}

-- // 4. SMART BYPASS ENGINE (HYPER-STUTTER TP) //
local function SmartTeleport(targetCFrame)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsTeleporting or not AETHER_CONFIG.ACTIVE then return end
    
    Internal.IsTeleporting = true
    local startPos = Root.Position
    local endPos = targetCFrame.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 30 then
        local stepCount = math.clamp(math.floor(dist/15), 5, 20)
        for i = 1, stepCount do
            if not AETHER_CONFIG.ACTIVE then break end
            Root.CFrame = CFrame.new(startPos:Lerp(endPos, i/stepCount))
            RunService.Stepped:Wait() 
        end
    end
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 5. GHOST PROJECTION ENGINE (V14 KEEP-ALIVE) //
local function CleanupGhost()
    if Internal.GhostModel then Internal.GhostModel:Destroy() end
    Internal.GhostModel = nil
    if Internal.BV then Internal.BV:Destroy() end
    if Internal.BG then Internal.BG:Destroy() end
    Internal.BV = nil
    Internal.BG = nil
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function HandleGhostLogic(dt)
    if not AETHER_CONFIG.GOD_MODE or not Internal.GhostModel or not AETHER_CONFIG.ACTIVE then return end
    
    local GhostRoot = Internal.GhostModel:FindFirstChild("HumanoidRootPart")
    local GhostHum = Internal.GhostModel:FindFirstChildOfClass("Humanoid")
    local RealChar = LocalPlayer.Character
    
    if GhostRoot and GhostHum then
        Camera.CameraSubject = GhostHum
        
        if not Internal.BV then
            Internal.BV = Instance.new("BodyVelocity", GhostRoot)
            Internal.BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            Internal.BG = Instance.new("BodyGyro", GhostRoot)
            Internal.BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            local TargetVel = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            Internal.BV.Velocity = TargetVel
            Internal.BG.CFrame = Camera.CFrame
        else
            -- V14 KEEP-ALIVE: Prevents physics sleep/freezing
            Internal.BV.Velocity = Vector3.new(0, math.sin(tick()*5)*0.1, 0)
        end
    end
end

-- // 6. THE PHANTOM BYPASS //
local function GlobalBypassSync()
    if not AETHER_CONFIG.ACTIVE then return end
    local Char = LocalPlayer.Character
    if not Char or Internal.IsTeleporting then return end
    
    pcall(function()
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            Hum.WalkSpeed = 16
            
            if AETHER_CONFIG.GOD_MODE then
                if not Internal.GhostModel then
                    Char.Archivable = true
                    Internal.GhostModel = Char:Clone()
                    Internal.GhostModel.Name = "Aether_Ghost_V14"
                    Internal.GhostModel.Parent = Workspace
                    for _, p in pairs(Internal.GhostModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 0.5
                            p.Color = AETHER_CONFIG.UI_COLOR
                            p.CanCollide = false
                            p.CanTouch = false
                        elseif p:IsA("Humanoid") then
                            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                    end
                    Internal.GhostModel:SetPrimaryPartCFrame(Root.CFrame)
                end

                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 5) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 2, 0))
                end
                
                Root.Anchored = true
                Hum.MaxHealth = 999999
                Hum.Health = 999999
            else
                if Internal.GhostModel then
                    Root.Anchored = false
                    local targetReturn = Internal.GhostModel.PrimaryPart.CFrame
                    CleanupGhost()
                    SmartTeleport(targetReturn)
                end
            end
        end
    end)
end

-- // 7. THE AETHER-FLY ENGINE //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ACTIVE then return end
    if AETHER_CONFIG.GOD_MODE then HandleGhostLogic(dt) return end
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

-- // 8. HORIZONTAL UI SYSTEM //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV14") then CoreGui.AetherV14:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV14"

    -- Collapse Button (C)
    local Collapse = Instance.new("TextButton", Screen)
    Collapse.Size = UDim2.new(0, 30, 0, 30)
    Collapse.Position = UDim2.new(0.05, 0, 0.15, 0)
    Collapse.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Collapse.Text = "C"
    Collapse.TextColor3 = AETHER_CONFIG.UI_COLOR
    Collapse.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Collapse)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 600, 0, 180)
    Main.Position = UDim2.new(0.5, -300, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = AETHER_CONFIG.UI_COLOR
    Stroke.Thickness = 2

    -- Kill Button (X)
    local Kill = Instance.new("TextButton", Main)
    Kill.Size = UDim2.new(0, 25, 0, 25)
    Kill.Position = UDim2.new(1, -30, 0, 5)
    Kill.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Kill.Text = "X"
    Kill.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Kill)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "AETHER WALK ELITE - " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.FredokaOne
    Title.BackgroundTransparency = 1

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -20, 1, -40)
    Container.Position = UDim2.new(0, 10, 0, 35)
    Container.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Container)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateSection(title, width)
        local Sec = Instance.new("Frame", Container)
        Sec.Size = UDim2.new(0, width, 1, 0)
        Sec.BackgroundTransparency = 1
        local L = Instance.new("UIListLayout", Sec)
        L.Padding = UDim.new(0, 5)
        local T = Instance.new("TextLabel", Sec)
        T.Size = UDim2.new(1, 0, 0, 20)
        T.Text = title
        T.TextColor3 = Color3.new(0.6, 0.6, 0.6)
        T.Font = Enum.Font.GothamBold
        T.TextSize = 10
        T.BackgroundTransparency = 1
        return Sec
    end

    -- SECTION 1: ENGINES
    local SecEng = CreateSection("SYSTEM ENGINES", 140)
    local function QuickBtn(txt, parent, call)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = txt
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(call)
        return b
    end

    local FlyT = QuickBtn("FLY: OFF", SecEng, function() AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED end)
    local GodT = QuickBtn("PHANTOM: OFF", SecEng, function() AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE end)

    -- SECTION 2: SETTINGS
    local SecSet = CreateSection("CONFIGURATION", 140)
    local SpeedBox = Instance.new("TextBox", SecSet)
    SpeedBox.Size = UDim2.new(1, 0, 0, 35)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedBox.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    Instance.new("UICorner", SpeedBox)
    QuickBtn("THE DUG", SecSet, function() LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0) end)

    -- SECTION 3: TELEPORTS
    local SecTp = CreateSection("FAST ZONES", 280)
    local TpGrid = Instance.new("UIGridLayout", SecTp)
    TpGrid.CellSize = UDim2.new(0, 85, 0, 30)
    for zone, pos in pairs(ZONES) do
        QuickBtn(zone, SecTp, function() SmartTeleport(CFrame.new(pos)) end)
    end

    -- UI LOGIC
    Collapse.MouseButton1Down:Connect(function() Main.Visible = not Main.Visible end)
    Kill.MouseButton1Down:Connect(function()
        AETHER_CONFIG.ACTIVE = false
        AETHER_CONFIG.GOD_MODE = false
        AETHER_CONFIG.ENABLED = false
        CleanupGhost()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
        Screen:Destroy()
    end)

    RunService.RenderStepped:Connect(function()
        if not AETHER_CONFIG.ACTIVE then return end
        FlyT.Text = AETHER_CONFIG.ENABLED and "FLY: ON" or "FLY: OFF"
        FlyT.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        GodT.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM: ON" or "PHANTOM: OFF"
        GodT.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)

    SpeedBox.FocusLost:Connect(function() AETHER_CONFIG.SPEED = tonumber(SpeedBox.Text) or 80 end)

    -- Dragging
    local d, dS, sP
    Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; dS = i.Position; sP = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dS; Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

-- // RUNTIME //
table.insert(Internal.Connections, RunService.Heartbeat:Connect(function(dt)
    if AETHER_CONFIG.ACTIVE then
        ExecuteAether(dt)
        GlobalBypassSync()
    end
end))

BuildUI()
print("[AETHER V14] Horizontal Elite Online.")
