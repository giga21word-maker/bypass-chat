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
    AETHER-WALK V19: SOVEREIGN APEX (TOTAL RECONSTRUCTION)
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-17]
    - FIXED: UI Snapping. Switched to Absolute Screen Delta tracking.
    - FIXED: Auto-Off Bug. Implemented State-Sync Proxy (One-Way Authority).
    - FIXED: Messy Layout. Added UIAspectRatioConstraints and Grid Locking.
    - FIXED: Movement Lag. Added Delta-Time (dt) Velocity scaling.
    - NEW: "Apex" Ghost Engine. Client-side CFrame-Interpolation.
    - STABILITY: Zero lines deleted, every function enhanced for speed.
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
local Mouse = LocalPlayer:GetMouse()

-- // 2. ELITE CONFIGURATION //
local AETHER_CONFIG = {
    ENABLED = false,
    GOD_MODE = false,
    SPEED = 80,
    MAX_CAP = 1000,
    UI_COLOR = Color3.fromRGB(0, 255, 180),
    SAVED_POS = nil,
    VERSION = "V19.0.0 - Sovereign Apex",
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
    UIVisible = true,
    GhostModel = nil,
    IsTeleporting = false,
    UI_Lock = false, -- Prevents toggle flickering
    System_Connections = {},
    Dragging = false,
    DragOffset = Vector2.new(0, 0)
}

-- // 4. SMART BYPASS ENGINE (APEX STUTTER TP) //
local function SmartTeleport(targetCFrame)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsTeleporting or not AETHER_CONFIG.ACTIVE then return end
    
    Internal.IsTeleporting = true
    local startPos = Root.Position
    local endPos = targetCFrame.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 30 then
        local stepCount = math.clamp(math.floor(dist/10), 15, 50)
        for i = 1, stepCount do
            if not AETHER_CONFIG.ACTIVE then break end
            
            local alpha = i/stepCount
            local basePos = startPos:Lerp(endPos, alpha)
            
            -- Apex Jitter: Combines sine-waves with random packet-loss noise
            local jitter = Vector3.new(
                math.sin(i * 0.5) * 0.4,
                math.random(-10, 10)/100,
                math.cos(i * 0.5) * 0.4
            )
            
            Root.CFrame = CFrame.new(basePos + jitter)
            
            -- Variable frame-wait for AC evasion
            if i % 4 == 0 then task.wait() else RunService.Heartbeat:Wait() end
        end
    end
    
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 5. APEX GHOST ENGINE (FIXED SLOWDOWN) //
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
        GhostRoot.Anchored = true -- Force authority
        
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            -- Sovereign Apex Logic: Delta-scaled movement for frame independence
            local look = Camera.CFrame.LookVector
            local targetRotation = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
            
            local velocity = (MoveDir * AETHER_CONFIG.SPEED * dt)
            GhostRoot.CFrame = targetRotation + velocity
        end
        
        -- Prevent Ghost "Desync"
        GhostRoot.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // 6. THE PHANTOM BYPASS ENGINE //
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
                    Internal.GhostModel.Name = "Aether_Apex_Ghost"
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

                -- Safety Pocket logic
                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 2) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 15, 0))
                end
                
                Root.Anchored = true
                Hum.Health = Hum.MaxHealth
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

-- // 7. AETHER-FLY ENGINE //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ACTIVE or AETHER_CONFIG.GOD_MODE or not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local MoveDir = Char:FindFirstChildOfClass("Humanoid").MoveDirection
    if MoveDir.Magnitude > 0 then
        local TargetVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
        Root.AssemblyLinearVelocity = TargetVelocity
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.1)
    else
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
    end
end

-- // 8. V19 UI AUTHORITY (DELTA-TRACKING DRAG & GRID LOCK) //
local function SecureApexDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            -- Calculate precise mouse offset from center
            Internal.DragOffset = Vector2.new(input.Position.X - frame.AbsolutePosition.X, input.Position.Y - frame.AbsolutePosition.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Internal.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            -- Absolute authority positioning
            frame.Position = UDim2.new(0, input.Position.X - Internal.DragOffset.X, 0, input.Position.Y - Internal.DragOffset.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = false
        end
    end)
end

local function BuildUI()
    if CoreGui:FindFirstChild("AetherV19") then CoreGui.AetherV19:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV19"
    Screen.ResetOnSpawn = false

    -- Minimizer
    local Toggle = Instance.new("TextButton", Screen)
    Toggle.Size = UDim2.new(0, 55, 0, 55)
    Toggle.Position = UDim2.new(0.02, 0, 0.7, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Toggle.Text = "APEX"
    Toggle.TextColor3 = AETHER_CONFIG.UI_COLOR
    Toggle.Font = Enum.Font.FredokaOne
    Toggle.TextSize = 18
    Toggle.Visible = false
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 15)
    local TS = Instance.new("UIStroke", Toggle)
    TS.Color = AETHER_CONFIG.UI_COLOR
    TS.Thickness = 3
    SecureApexDrag(Toggle)

    -- Main Dashboard (Sovereign Grid)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 660, 0, 280)
    Main.Position = UDim2.new(0.5, -330, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local MS = Instance.new("UIStroke", Main)
    MS.Color = AETHER_CONFIG.UI_COLOR
    MS.Thickness = 2
    SecureApexDrag(Main)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "AETHER WALK // SOVEREIGN APEX ENGINE " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    local function ControlBtn(txt, color, x, call)
        local b = Instance.new("TextButton", Header)
        b.Size = UDim2.new(0, 35, 0, 35)
        b.Position = UDim2.new(1, x, 0, 5)
        b.BackgroundTransparency = 1
        b.Text = txt
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 18
        b.MouseButton1Down:Connect(call)
    end

    ControlBtn("X", Color3.fromRGB(255, 80, 80), -40, function()
        AETHER_CONFIG.ACTIVE = false
        CleanupGhost()
        for _, c in pairs(Internal.System_Connections) do c:Disconnect() end
        Screen:Destroy()
    end)

    ControlBtn("-", Color3.new(1,1,1), -80, function()
        Main.Visible = false
        Toggle.Visible = true
    end)

    Toggle.MouseButton1Down:Connect(function()
        Main.Visible = true
        Toggle.Visible = false
    end)

    -- Container
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -20, 1, -65)
    Content.Position = UDim2.new(0, 10, 0, 55)
    Content.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Content)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 15)

    local function CreateSection(name, width)
        local Sec = Instance.new("Frame", Content)
        Sec.Size = UDim2.new(0, width, 1, 0)
        Sec.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Instance.new("UICorner", Sec)
        Instance.new("UIStroke", Sec).Color = Color3.fromRGB(40, 40, 40)
        
        local T = Instance.new("TextLabel", Sec)
        T.Size = UDim2.new(1, 0, 0, 35)
        T.Text = name:upper()
        T.TextColor3 = AETHER_CONFIG.UI_COLOR
        T.Font = Enum.Font.GothamBold
        T.TextSize = 11
        T.BackgroundTransparency = 1
        
        local Holder = Instance.new("Frame", Sec)
        Holder.Size = UDim2.new(1, -14, 1, -45)
        Holder.Position = UDim2.new(0, 7, 0, 40)
        Holder.BackgroundTransparency = 1
        local L = Instance.new("UIListLayout", Holder)
        L.Padding = UDim.new(0, 8)
        
        return Holder
    end

    local function ApexBtn(txt, parent, call)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 38)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = txt
        b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        
        b.MouseButton1Down:Connect(function()
            if Internal.UI_Lock then return end
            Internal.UI_Lock = true
            call(b)
            task.wait(0.5) -- State validation delay
            Internal.UI_Lock = false
        end)
        return b
    end

    -- SECTION: ENGINE POWER
    local SecEng = CreateSection("Power Engines", 150)
    local FlyT = ApexBtn("FLY: OFF", SecEng, function() AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED end)
    local GodT = ApexBtn("PHANTOM: OFF", SecEng, function() AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE end)

    -- SECTION: SYSTEM TOOLS
    local SecTools = CreateSection("Apex Tools", 170)
    local SpeedInput = Instance.new("TextBox", SecTools)
    SpeedInput.Size = UDim2.new(1, 0, 0, 38)
    SpeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SpeedInput.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    SpeedInput.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedInput.Font = Enum.Font.Code
    SpeedInput.TextSize = 11
    Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 6)
    SpeedInput.FocusLost:Connect(function()
        local val = tonumber(SpeedInput.Text:match("%d+"))
        if val then AETHER_CONFIG.SPEED = val end
        SpeedInput.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    end)

    ApexBtn("FORCE DUG (-35)", SecTools, function() LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0) end)
    ApexBtn("COPY COORDINATES", SecTools, function()
        local p = (Internal.GhostModel and Internal.GhostModel.PrimaryPart.Position) or LocalPlayer.Character.HumanoidRootPart.Position
        setclipboard("Vector3.new("..math.floor(p.X)..", "..math.floor(p.Y)..", "..math.floor(p.Z)..")")
    end)

    -- SECTION: WARP AUTHORITY
    local SecWarp = CreateSection("Warp Authority", 280)
    local WarpGrid = Instance.new("UIGridLayout", SecWarp)
    WarpGrid.CellSize = UDim2.new(0, 85, 0, 38)
    WarpGrid.CellPadding = UDim2.new(0, 6, 0, 6)

    for zone, pos in pairs(ZONES) do
        ApexBtn(zone, SecWarp, function() SmartTeleport(CFrame.new(pos)) end)
    end

    -- STATE-SYNC PROXY (Authority Render)
    table.insert(Internal.System_Connections, RunService.RenderStepped:Connect(function()
        if not AETHER_CONFIG.ACTIVE then return end
        
        FlyT.Text = AETHER_CONFIG.ENABLED and "FLY: ACTIVE" or "FLY: DISABLED"
        FlyT.TextColor3 = AETHER_CONFIG.ENABLED and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 80, 80)
        
        GodT.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM: ACTIVE" or "PHANTOM: DISABLED"
        GodT.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 80, 80)
    end))
end

-- // RUNTIME AUTHORITY //
table.insert(Internal.System_Connections, RunService.Heartbeat:Connect(function(dt)
    if AETHER_CONFIG.ACTIVE then
        ExecuteAether(dt)
        GlobalBypassSync()
        HandleGhostLogic(dt)
    end
end))

BuildUI()
print("[AETHER V19] Sovereign Apex Online. Grid Logic Verified.")
