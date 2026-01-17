-- // GHOST-SYNC: REMOTE LOADER V5 //
-- Optimized for: Stratus-Walk V2 / Phase-Shift Integration
-- URL: https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua

local RemoteURL = "https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua"

local function LoadProject()
    -- We use a pcall to ensure the game keeps going even if GitHub is down
    local success, response = pcall(function()
        -- HttpGet is used for high-priority synchronous fetching
        return game:HttpGet(RemoteURL)
    end)

    if success and response then
        print("[PROJECT] Fetch Successful. Executing Payload...")
        
        -- Executing the string within the global environment
        local exec_success, exec_err = pcall(function()
            loadstring(response)()
        end)

        if not exec_success then
            warn("[EXECUTION ERROR]: " .. tostring(exec_err))
        end
    else
        warn("[FETCH ERROR]: Could not reach GitHub. Check connection.")
        
        -- Fallback: Attempting secondary load via HttpGetAsync
        pcall(function()
            loadstring(game:HttpGetAsync(RemoteURL))()
        end)
    end
end

-- Automatically load the remote payload
task.spawn(LoadProject)


--[[
    AETHER-WALK V18: SOVEREIGN EDITION (ENGINE OVERHAUL)
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-17]
    - CRITICAL: Rewrote Dragging System using Absolute Offset to stop Snapping.
    - CRITICAL: Implemented State-Locking to prevent "Auto-Off" bug.
    - FIXED: Phantom Slowdown using Vector-Force Compensation.
    - NEW: "Sine-Wave Jitter" TP pathing for high-velocity AC bypass.
    - FIXED: Explicit Nuke() function for GUI deletion.
    - UI: Redesigned with 'Sovereign' Grid for zero mess.
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
    VERSION = "V18.0.0 - Sovereign Elite",
    SAFE_BASE = Vector3.new(66, 3, 7),
    ACTIVE = true -- Global Authority Switch
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
    UI_Connections = {},
    System_Connections = {},
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 4. SMART BYPASS ENGINE (SINE-WAVE STUTTER TP) //
local function SmartTeleport(targetCFrame)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsTeleporting or not AETHER_CONFIG.ACTIVE then return end
    
    Internal.IsTeleporting = true
    local startPos = Root.Position
    local endPos = targetCFrame.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 30 then
        local stepCount = math.clamp(math.floor(dist/12), 10, 40)
        for i = 1, stepCount do
            if not AETHER_CONFIG.ACTIVE then break end
            
            local alpha = i/stepCount
            local basePos = startPos:Lerp(endPos, alpha)
            
            -- V18 Sine-Wave Jitter: Creates a curved, non-linear path to bypass AC
            local sineOffset = Vector3.new(
                math.sin(alpha * math.pi) * 0.5,
                math.cos(alpha * math.pi) * 0.5,
                math.sin(alpha * 2) * 0.2
            )
            
            Root.CFrame = CFrame.new(basePos + sineOffset)
            
            -- Micro-stutter delay
            if i % 5 == 0 then RunService.Heartbeat:Wait() else RunService.Stepped:Wait() end
        end
    end
    
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 5. GHOST PROJECTION ENGINE (V18 SOVEREIGN AUTHORITY) //
local function CleanupGhost()
    if Internal.GhostModel then Internal.GhostModel:Destroy() end
    Internal.GhostModel = nil
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function HandleGhostLogic(dt)
    if not AETHER_CONFIG.GOD_MODE or not Internal.GhostModel or not AETHER_CONFIG.ACTIVE then return end
    
    local GhostRoot = Internal.GhostModel:FindFirstChild("HumanoidRootPart")
    local GhostHum = Internal.GhostModel:FindFirstChildOfClass("Humanoid")
    local RealChar = LocalPlayer.Character
    
    if GhostRoot and GhostHum and RealChar then
        Camera.CameraSubject = GhostHum
        
        -- Fixed: Authority Re-assertion
        if GhostRoot.Anchored == false then GhostRoot.Anchored = true end
        
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            -- V18 Vector-Force Compensation: Maintains speed regardless of frame drops
            local TargetVel = (MoveDir * AETHER_CONFIG.SPEED)
            local look = Camera.CFrame.LookVector
            local rot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
            
            GhostRoot.CFrame = rot + (TargetVel * dt)
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
            if AETHER_CONFIG.GOD_MODE then
                if not Internal.GhostModel then
                    Char.Archivable = true
                    Internal.GhostModel = Char:Clone()
                    Internal.GhostModel.Name = "Aether_Ghost_V18"
                    Internal.GhostModel.Parent = Workspace
                    for _, p in pairs(Internal.GhostModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 0.5
                            p.Color = AETHER_CONFIG.UI_COLOR
                            p.CanCollide = false
                            p.Anchored = true
                        elseif p:IsA("Humanoid") then
                            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                    end
                    Internal.GhostModel:SetPrimaryPartCFrame(Root.CFrame)
                end

                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 5) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 5, 0))
                end
                
                Root.Anchored = true
                Hum.MaxHealth = 999999
                Hum.Health = 999999
            else
                if Internal.GhostModel then
                    local targetReturn = Internal.GhostModel.PrimaryPart.CFrame
                    CleanupGhost()
                    Root.Anchored = false
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

-- // 8. V18 UI AUTHORITY (ABSOLUTE DRAG & STATE LOCK) //
local function SecureDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = frame.Position
            
            local moveConnection
            moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    if Internal.Dragging then
                        local delta = moveInput.Position - Internal.DragStart
                        -- V18 Absolute Anchor: Prevents snapping by calculating current frame offsets
                        frame.Position = UDim2.new(
                            Internal.StartPos.X.Scale, 
                            Internal.StartPos.X.Offset + delta.X, 
                            Internal.StartPos.Y.Scale, 
                            Internal.StartPos.Y.Offset + delta.Y
                        )
                    else
                        moveConnection:Disconnect()
                    end
                end
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = false
        end
    end)
end

local function BuildUI()
    if CoreGui:FindFirstChild("AetherV18") then CoreGui.AetherV18:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV18"

    -- Toggle Button (Minimized)
    local ToggleBtn = Instance.new("TextButton", Screen)
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0.02, 0, 0.75, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    ToggleBtn.Text = "A"
    ToggleBtn.TextColor3 = AETHER_CONFIG.UI_COLOR
    ToggleBtn.Font = Enum.Font.FredokaOne
    ToggleBtn.TextSize = 25
    ToggleBtn.Visible = false
    Instance.new("UICorner", ToggleBtn)
    local TS = Instance.new("UIStroke", ToggleBtn)
    TS.Color = AETHER_CONFIG.UI_COLOR
    TS.Thickness = 2
    SecureDrag(ToggleBtn)

    -- Main Dashboard
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 640, 0, 260)
    Main.Position = UDim2.new(0.5, -320, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = AETHER_CONFIG.UI_COLOR
    MainStroke.Thickness = 1.5
    SecureDrag(Main)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "AETHER WALK // SOVEREIGN ENGINE " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- Control Window Functions
    local function WinBtn(txt, color, xPos, callback)
        local b = Instance.new("TextButton", Header)
        b.Size = UDim2.new(0, 35, 0, 35)
        b.Position = UDim2.new(1, xPos, 0, 2.5)
        b.BackgroundTransparency = 1
        b.Text = txt
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 16
        b.MouseButton1Down:Connect(callback)
    end

    -- Explicit Nuke: Fixes the GUI not deleting bug
    WinBtn("X", Color3.fromRGB(255, 80, 80), -40, function()
        AETHER_CONFIG.ACTIVE = false
        AETHER_CONFIG.GOD_MODE = false
        AETHER_CONFIG.ENABLED = false
        CleanupGhost()
        for _, conn in pairs(Internal.System_Connections) do conn:Disconnect() end
        Screen:Destroy()
        print("[AETHER] Sovereign Engine Offline.")
    end)

    WinBtn("-", Color3.new(1, 1, 1), -80, function()
        Main.Visible = false
        ToggleBtn.Visible = true
    end)

    ToggleBtn.MouseButton1Down:Connect(function()
        Main.Visible = true
        ToggleBtn.Visible = false
    end)

    -- Layout Grid
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.new(0, 10, 0, 50)
    Content.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Content)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 12)

    local function CreateSection(name, width)
        local Sec = Instance.new("Frame", Content)
        Sec.Size = UDim2.new(0, width, 1, 0)
        Sec.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Instance.new("UICorner", Sec)
        Instance.new("UIStroke", Sec).Color = Color3.fromRGB(35, 35, 35)
        
        local T = Instance.new("TextLabel", Sec)
        T.Size = UDim2.new(1, 0, 0, 30)
        T.Text = name:upper()
        T.TextColor3 = AETHER_CONFIG.UI_COLOR
        T.Font = Enum.Font.GothamBold
        T.TextSize = 11
        T.BackgroundTransparency = 1
        
        local Container = Instance.new("Frame", Sec)
        Container.Size = UDim2.new(1, -10, 1, -40)
        Container.Position = UDim2.new(0, 5, 0, 35)
        Container.BackgroundTransparency = 1
        local L = Instance.new("UIListLayout", Container)
        L.Padding = UDim.new(0, 6)
        
        return Container
    end

    local function SovereignBtn(txt, parent, call)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = txt
        b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 11
        Instance.new("UICorner", b)
        
        b.MouseButton1Down:Connect(function()
            call(b)
        end)
        return b
    end

    -- SECTION: POWER
    local SecPower = CreateSection("Power", 140)
    local FlyToggle = SovereignBtn("FLY ENGINE", SecPower, function() 
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED 
    end)
    local GodToggle = SovereignBtn("PHANTOM MODE", SecPower, function() 
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE 
    end)

    -- SECTION: TOOLS
    local SecTools = CreateSection("Tools", 160)
    local SpeedInput = Instance.new("TextBox", SecTools)
    SpeedInput.Size = UDim2.new(1, 0, 0, 35)
    SpeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SpeedInput.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    SpeedInput.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedInput.Font = Enum.Font.Code
    SpeedInput.TextSize = 11
    Instance.new("UICorner", SpeedInput)
    SpeedInput.FocusLost:Connect(function()
        local n = tonumber(SpeedInput.Text:match("%d+"))
        if n then AETHER_CONFIG.SPEED = n end
        SpeedInput.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    end)

    SovereignBtn("FORCE DUG (-35)", SecTools, function() 
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0) 
    end)
    SovereignBtn("COPY POSITION", SecTools, function()
        local pos = (Internal.GhostModel and Internal.GhostModel.PrimaryPart.Position) or LocalPlayer.Character.HumanoidRootPart.Position
        setclipboard("Vector3.new("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")")
    end)

    -- SECTION: WARPS
    local SecWarps = CreateSection("Warp Authority", 270)
    local WarpGrid = Instance.new("UIGridLayout", SecWarps)
    WarpGrid.CellSize = UDim2.new(0, 80, 0, 35)
    WarpGrid.CellPadding = UDim2.new(0, 5, 0, 5)

    for zone, pos in pairs(ZONES) do
        SovereignBtn(zone, SecWarps, function() SmartTeleport(CFrame.new(pos)) end)
    end

    -- MASTER STATE VALIDATOR (Fixes Auto-Off Bug)
    table.insert(Internal.System_Connections, RunService.RenderStepped:Connect(function()
        if not AETHER_CONFIG.ACTIVE then return end
        
        -- Force UI to match actual internal state
        FlyToggle.Text = AETHER_CONFIG.ENABLED and "FLY: ON" or "FLY: OFF"
        FlyToggle.BackgroundColor3 = AETHER_CONFIG.ENABLED and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(40, 40, 40)
        
        GodToggle.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM: ON" or "PHANTOM: OFF"
        GodToggle.BackgroundColor3 = AETHER_CONFIG.GOD_MODE and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(40, 40, 40)
    end))
end

-- // RUNTIME AUTHORITY //
table.insert(Internal.System_Connections, RunService.Heartbeat:Connect(function(dt)
    if AETHER_CONFIG.ACTIVE then
        ExecuteAether(dt)
        GlobalBypassSync()
        if AETHER_CONFIG.GOD_MODE then HandleGhostLogic(dt) end
    end
end))

BuildUI()
print("[AETHER V18] Sovereign Authority Online. All bugs suppressed.")
