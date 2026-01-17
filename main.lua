-- // GHOST-SYNC: REMOTE LOADER V5 //
-- Optimized for: Stratus-Walk V2 / Phase-Shift Integration
-- URL: https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua

local RemoteURL = "https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua"

local function LoadProject()
    local success, response = pcall(function()
        return game:HttpGet(RemoteURL)
    end)

    if success and response then
        print("[PROJECT] Fetch Successful. Executing Payload...")
        local exec_success, exec_err = pcall(function()
            loadstring(response)()
        end)
        if not exec_success then warn("[EXECUTION ERROR]: " .. tostring(exec_err)) end
    else
        warn("[FETCH ERROR]: Could not reach GitHub. Fallback initiated.")
        pcall(function() loadstring(game:HttpGetAsync(RemoteURL))() end)
    end
end
task.spawn(LoadProject)


--[[
    AETHER-WALK V16: KINEMATIC GHOST & STUTTER BYPASS
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - CRITICAL FIX: Ghost Freeze. Switched from Physics (BodyVelocity) to Kinematic (CFrame).
    - CRITICAL FIX: UI Snapping. Rewrote Draggable logic to use Offset Deltas.
    - NEW: "Stutter" TP. Adds randomized noise to TP to bypass anti-cheat.
    - FIXED: Auto-Off buttons. Added Debounce locking.
    - REORGANIZED: Buttons are strictly contained in frames.
    - STABLE: Zero lines deleted, logic overhauled for V16.
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
    VERSION = "V16.0.0 - Kinematic Elite",
    SAFE_BASE = Vector3.new(66, 3, 7),
    ACTIVE = true
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
    Debounce = false,
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
        -- V16: Added Random Noise (Stutter) to confuse Anti-Cheat
        local stepCount = math.clamp(math.floor(dist/20), 5, 25)
        for i = 1, stepCount do
            if not AETHER_CONFIG.ACTIVE then break end
            
            local alpha = i/stepCount
            local cleanLerp = startPos:Lerp(endPos, alpha)
            -- The Stutter: Add tiny random offsets
            local noise = Vector3.new(math.random(-10,10)/100, math.random(-10,10)/100, math.random(-10,10)/100)
            
            Root.CFrame = CFrame.new(cleanLerp + noise)
            
            -- Randomized Wait (Micro-Sleep)
            if i % 3 == 0 then RunService.Heartbeat:Wait() else RunService.Stepped:Wait() end
        end
    end
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 5. GHOST PROJECTION ENGINE (V16 KINEMATIC DRIVE) //
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
    local RealHum = RealChar and RealChar:FindFirstChildOfClass("Humanoid")
    
    if GhostRoot and GhostHum and RealHum then
        Camera.CameraSubject = GhostHum
        
        -- V16 KINEMATIC UPDATE:
        -- We no longer use BodyVelocity (Physics). We use CFrame (Math).
        -- This prevents the "Freeze" when the server stops calculating physics.
        
        local MoveDir = RealHum.MoveDirection
        local LookVec = Camera.CFrame.LookVector
        local RightVec = Camera.CFrame.RightVector
        
        -- Calculate relative movement based on Camera
        -- W/S moves along LookVector, A/D moves along RightVector
        -- We approximate this by just projecting the MoveDir onto the Camera's basis
        
        if MoveDir.Magnitude > 0 then
            -- Pure Math Movement
            local TargetPos = GhostRoot.Position + (MoveDir * AETHER_CONFIG.SPEED * dt)
            
            -- Rotate Ghost to face camera look direction for smoother feel
            local NewRotation = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(LookVec.X, 0, LookVec.Z))
            
            GhostRoot.CFrame = NewRotation + (MoveDir * AETHER_CONFIG.SPEED * dt)
        else
            -- V16 Idle: No physics sleep, just stay put
        end
        
        -- Force No-Clip
        GhostRoot.AssemblyLinearVelocity = Vector3.zero
        GhostRoot.AssemblyAngularVelocity = Vector3.zero
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
            Hum.WalkSpeed = 16 -- Keep real body normal
            
            if AETHER_CONFIG.GOD_MODE then
                if not Internal.GhostModel then
                    Char.Archivable = true
                    Internal.GhostModel = Char:Clone()
                    Internal.GhostModel.Name = "Aether_Ghost_V16"
                    Internal.GhostModel.Parent = Workspace
                    for _, p in pairs(Internal.GhostModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 0.5
                            p.Color = AETHER_CONFIG.UI_COLOR
                            p.CanCollide = false
                            p.CanTouch = false
                            p.Anchored = true -- KINEMATIC REQUIRES ANCHORED GHOST
                        elseif p:IsA("Humanoid") then
                            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                    end
                    Internal.GhostModel:SetPrimaryPartCFrame(Root.CFrame)
                end

                -- Anchor Real Body Safely
                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 5) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 5, 0))
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

-- // 8. V16 UI SYSTEM (OFFSET DRAGGABLE FIXED) //
local function EnableDrag(frame)
    local dragToggle = nil
    local dragSpeed = 0
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

local function BuildUI()
    if CoreGui:FindFirstChild("AetherV16") then CoreGui.AetherV16:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV16"

    -- // THE C BUTTON (TOGGLE) //
    local ToggleBtn = Instance.new("TextButton", Screen)
    ToggleBtn.Name = "Toggle"
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(0.02, 0, 0.85, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.Text = "C"
    ToggleBtn.TextColor3 = AETHER_CONFIG.UI_COLOR
    ToggleBtn.Font = Enum.Font.FredokaOne
    ToggleBtn.TextSize = 18
    ToggleBtn.Visible = false 
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ToggleBtn).Color = AETHER_CONFIG.UI_COLOR
    EnableDrag(ToggleBtn)

    -- // MAIN DASHBOARD //
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 600, 0, 200)
    Main.Position = UDim2.new(0.5, -300, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = AETHER_CONFIG.UI_COLOR
    Stroke.Thickness = 2
    EnableDrag(Main)

    -- TOP BAR
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0.02, 0, 0, 0)
    Title.Text = "AETHER WALK - " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- CONTROLS
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
        Sec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Instance.new("UICorner", Sec)
        
        local T = Instance.new("TextLabel", Sec)
        T.Size = UDim2.new(1, 0, 0, 25)
        T.Text = title
        T.TextColor3 = AETHER_CONFIG.UI_COLOR
        T.Font = Enum.Font.GothamBold
        T.TextSize = 10
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
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        b.Text = txt
        b.TextColor3 = color or Color3.new(1,1,1)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 10
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(function()
            -- Debounce to prevent auto-off bugs
            if Internal.Debounce then return end
            Internal.Debounce = true
            call()
            wait(0.2)
            Internal.Debounce = false
        end)
        return b
    end

    -- SECTION 1
    local SecCore = CreateSection("ENGINES", 120)
    local FlyT = QuickBtn("FLY: OFF", SecCore, nil, function() AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED end)
    local GodT = QuickBtn("PHANTOM: OFF", SecCore, nil, function() AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE end)

    -- SECTION 2
    local SecTools = CreateSection("TOOLS", 140)
    local SpeedBox = Instance.new("TextBox", SecTools)
    SpeedBox.Size = UDim2.new(1, 0, 0, 28)
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
    end)

    -- SECTION 3
    local SecTp = CreateSection("ZONES", 260)
    local TpGrid = Instance.new("UIGridLayout", SecTp)
    TpGrid.CellSize = UDim2.new(0, 80, 0, 28)
    TpGrid.CellPadding = UDim2.new(0, 5, 0, 5)
    
    for zone, pos in pairs(ZONES) do
        QuickBtn(zone, SecTp, Color3.fromRGB(0, 180, 255), function() SmartTeleport(CFrame.new(pos)) end)
    end

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
print("[AETHER V16] Kinematic Elite Online.")
