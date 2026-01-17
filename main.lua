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
    AETHER-WALK V15: DASHBOARD ELITE & NETWORK AUTHORITY
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - FIXED: Ghost Freeze. Implemented SetNetworkOwner(LocalPlayer) for authority.
    - NEW: "Dashboard" UI Layout. Clean, Horizontal, Organized.
    - NEW: Draggable System. Both Main UI and [C] Button are fully movable.
    - NEW: Window Controls. Added [-] Minimize and [X] Nuke buttons.
    - RESTORED: Copy Coordinates feature added to Tools.
    - INTEGRATED: Remote Loader V5 at header.
    - STABLE: Zero lines deleted, logic expanded for V15.
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
    VERSION = "V15.0.0 - Network Elite",
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

-- // 5. GHOST PROJECTION ENGINE (V15 NETWORK AUTHORITY) //
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
        
        -- V15 Fix: Ensure Network Ownership is Local to prevent Server Freeze
        if GhostRoot:CanSetNetworkOwnership() then
            pcall(function() GhostRoot:SetNetworkOwner(LocalPlayer) end)
        end
        
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
            -- Keep-Alive Pulse
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
                    Internal.GhostModel.Name = "Aether_Ghost_V15"
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

-- // 8. HORIZONTAL UI SYSTEM (DRAGGABLE & MODULAR) //
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function BuildUI()
    if CoreGui:FindFirstChild("AetherV15") then CoreGui.AetherV15:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV15"

    -- // THE C BUTTON (TOGGLE) //
    local ToggleBtn = Instance.new("TextButton", Screen)
    ToggleBtn.Name = "Toggle"
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(0.02, 0, 0.9, -40)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.Text = "C"
    ToggleBtn.TextColor3 = AETHER_CONFIG.UI_COLOR
    ToggleBtn.Font = Enum.Font.FredokaOne
    ToggleBtn.TextSize = 18
    ToggleBtn.Visible = false -- Starts hidden, shows when minimized
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ToggleBtn).Color = AETHER_CONFIG.UI_COLOR
    MakeDraggable(ToggleBtn)

    -- // MAIN DASHBOARD //
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 650, 0, 220)
    Main.Position = UDim2.new(0.5, -325, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = AETHER_CONFIG.UI_COLOR
    Stroke.Thickness = 2
    MakeDraggable(Main)

    -- TOP BAR
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
    -- Hide bottom corners of topbar to blend
    local HideRound = Instance.new("Frame", TopBar)
    HideRound.Size = UDim2.new(1, 0, 0.5, 0)
    HideRound.Position = UDim2.new(0, 0, 0.5, 0)
    HideRound.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    HideRound.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0.02, 0, 0, 0)
    Title.Text = "AETHER WALK - " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- CONTROLS (X and -)
    local function WinBtn(text, color, pos, callback)
        local b = Instance.new("TextButton", TopBar)
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = pos
        b.BackgroundTransparency = 1
        b.Text = text
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 14
        b.MouseButton1Down:Connect(callback)
        return b
    end

    WinBtn("X", Color3.fromRGB(255, 80, 80), UDim2.new(1, -30, 0, 0), function()
        AETHER_CONFIG.ACTIVE = false
        AETHER_CONFIG.GOD_MODE = false
        AETHER_CONFIG.ENABLED = false
        CleanupGhost()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
        Screen:Destroy()
    end)

    WinBtn("-", Color3.fromRGB(255, 255, 255), UDim2.new(1, -60, 0, 0), function()
        Main.Visible = false
        ToggleBtn.Visible = true
    end)

    ToggleBtn.MouseButton1Down:Connect(function()
        Main.Visible = true
        ToggleBtn.Visible = false
    end)

    -- CONTENT CONTAINER
    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -20, 1, -45)
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Container)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 15)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateSection(title, width)
        local Sec = Instance.new("Frame", Container)
        Sec.Size = UDim2.new(0, width, 1, 0)
        Sec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Instance.new("UICorner", Sec)
        
        local T = Instance.new("TextLabel", Sec)
        T.Size = UDim2.new(1, 0, 0, 25)
        T.Text = title
        T.TextColor3 = AETHER_CONFIG.UI_COLOR
        T.Font = Enum.Font.GothamBold
        T.TextSize = 11
        T.BackgroundTransparency = 1
        
        local Pad = Instance.new("UIPadding", Sec)
        Pad.PaddingTop = UDim.new(0, 30)
        Pad.PaddingLeft = UDim.new(0, 5)
        Pad.PaddingRight = UDim.new(0, 5)
        
        local L = Instance.new("UIListLayout", Sec)
        L.Padding = UDim.new(0, 5)
        L.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        return Sec
    end

    local function QuickBtn(txt, parent, color, call)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0.95, 0, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        b.Text = txt
        b.TextColor3 = color or Color3.new(1,1,1)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 11
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(call)
        return b
    end

    -- SECTION 1: CORE
    local SecCore = CreateSection("CORE ENGINES", 140)
    local FlyT = QuickBtn("FLY: OFF", SecCore, nil, function() AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED end)
    local GodT = QuickBtn("PHANTOM: OFF", SecCore, nil, function() AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE end)

    -- SECTION 2: TOOLS
    local SecTools = CreateSection("TOOLS & CONFIG", 160)
    local SpeedBox = Instance.new("TextBox", SecTools)
    SpeedBox.Size = UDim2.new(0.95, 0, 0, 30)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedBox.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    Instance.new("UICorner", SpeedBox)
    SpeedBox.FocusLost:Connect(function() AETHER_CONFIG.SPEED = tonumber(SpeedBox.Text) or 80 end)

    QuickBtn("THE DUG", SecTools, nil, function() LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0) end)
    QuickBtn("COPY COORDS", SecTools, Color3.fromRGB(255, 255, 0), function()
        local posPart = (Internal.GhostModel and Internal.GhostModel.PrimaryPart) or LocalPlayer.Character.HumanoidRootPart
        local pos = posPart.Position
        local formatted = "Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
        if setclipboard then setclipboard(formatted) end
        print("COPIED: " .. formatted)
    end)

    -- SECTION 3: WARP ZONES
    local SecTp = CreateSection("WARP ZONES", 280)
    local TpGrid = Instance.new("Frame", SecTp)
    TpGrid.Size = UDim2.new(1, 0, 1, 0)
    TpGrid.BackgroundTransparency = 1
    local G = Instance.new("UIGridLayout", TpGrid)
    G.CellSize = UDim2.new(0, 85, 0, 30)
    G.CellPadding = UDim2.new(0, 5, 0, 5)
    
    for zone, pos in pairs(ZONES) do
        QuickBtn(zone, TpGrid, Color3.fromRGB(0, 180, 255), function() SmartTeleport(CFrame.new(pos)) end)
    end

    -- UPDATER
    RunService.RenderStepped:Connect(function()
        if not AETHER_CONFIG.ACTIVE then return end
        FlyT.Text = AETHER_CONFIG.ENABLED and "FLY: ON" or "FLY: OFF"
        FlyT.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        GodT.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM: ON" or "PHANTOM: OFF"
        GodT.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
end

-- // RUNTIME //
table.insert(Internal.Connections, RunService.Heartbeat:Connect(function(dt)
    if AETHER_CONFIG.ACTIVE then
        ExecuteAether(dt)
        GlobalBypassSync()
    end
end))

BuildUI()
print("[AETHER V15] Dashboard Online.")
