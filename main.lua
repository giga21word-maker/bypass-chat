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
    AETHER-WALK V17: AUTHORITY EDITION
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-17]
    - FIXED: GUI Snap-back. New Delta-Anchor dragging system.
    - FIXED: Auto-Off Bug. Implemented State-Locking toggles.
    - FIXED: Phantom Slowing. Frame-synced Kinematic CFrame Drive.
    - NEW: Vector-Jitter Stutter TP. Randomized pathing for AC Bypass.
    - UI: Modernized "Dashboard" with high-contrast sections.
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
    VERSION = "V17.0.0 - Authority Elite",
    SAFE_BASE = Vector3.new(66, 3, 7),
    ACTIVE = true
}

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
    UI_Debounce = false,
    Connections = {},
    LastGhostPos = nil
}

-- // 4. ENHANCED BYPASS ENGINE (STUTTER TP) //
local function SmartTeleport(targetCFrame)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsTeleporting or not AETHER_CONFIG.ACTIVE then return end
    
    Internal.IsTeleporting = true
    local startPos = Root.Position
    local endPos = targetCFrame.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 30 then
        -- V17: Advanced Vector-Jitter Stutter
        local steps = math.clamp(math.floor(dist/15), 8, 30)
        for i = 1, steps do
            if not AETHER_CONFIG.ACTIVE then break end
            
            local alpha = i/steps
            local nextPoint = startPos:Lerp(endPos, alpha)
            
            -- Inject Micro-Stutter (Randomized Jitter)
            local jitter = Vector3.new(
                math.random(-25, 25)/100, 
                math.random(-5, 5)/100, 
                math.random(-25, 25)/100
            )
            
            Root.CFrame = CFrame.new(nextPoint + jitter)
            
            -- Variable Wait Timing (Mimics Packet Loss/Human Lag)
            if i % 4 == 0 then
                task.wait(0.01 + (math.random(1, 10)/500))
            else
                RunService.Heartbeat:Wait()
            end
        end
    end
    
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 5. AUTHORITY GHOST ENGINE (FIXED SLOWING) //
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
        
        -- V17 Kinematic Drive: Frame-Synced Movement
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            -- Use Camera-Relative Authority
            local look = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            local targetVel = (MoveDir * AETHER_CONFIG.SPEED)
            
            -- Fixed Slowing: Use pure CFrame translation, bypass physics friction entirely
            local nextPos = GhostRoot.Position + (targetVel * dt)
            local targetRot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
            
            GhostRoot.CFrame = targetRot + (targetVel * dt)
        end
        
        -- Authority: Ensure ghost doesn't fall through map or lag behind
        GhostRoot.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // 6. GLOBAL BYPASS SYNC //
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
                    Internal.GhostModel.Name = "Aether_Ghost_V17"
                    Internal.GhostModel.Parent = Workspace
                    for _, p in pairs(Internal.GhostModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 0.5
                            p.Color = AETHER_CONFIG.UI_COLOR
                            p.CanCollide = false
                            p.Anchored = true -- Kinematic Authority
                        elseif p:IsA("Humanoid") then
                            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                    end
                    Internal.GhostModel:SetPrimaryPartCFrame(Root.CFrame)
                end

                -- Keep real body in a safe pocket
                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 2) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 10, 0))
                end
                Root.Anchored = true
            else
                if Internal.GhostModel then
                    local returnPos = Internal.GhostModel.PrimaryPart.CFrame
                    CleanupGhost()
                    Root.Anchored = false
                    SmartTeleport(returnPos)
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
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.08)
    else
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0)
    end
end

-- // 8. V17 UI AUTHORITY (DRAG FIXED) //
local function MakeDraggable(obj)
    local dragStart, startPos
    local dragging = false

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            -- Authority Fix: Use Pixel-Offset conversion to prevent snap-back
            obj.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function BuildUI()
    if CoreGui:FindFirstChild("AetherV17") then CoreGui.AetherV17:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV17"

    -- Toggle Button
    local Toggle = Instance.new("TextButton", Screen)
    Toggle.Size = UDim2.new(0, 45, 0, 45)
    Toggle.Position = UDim2.new(0.02, 0, 0.8, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Toggle.Text = "A"
    Toggle.TextColor3 = AETHER_CONFIG.UI_COLOR
    Toggle.Font = Enum.Font.FredokaOne
    Toggle.TextSize = 22
    Toggle.Visible = false
    Instance.new("UICorner", Toggle)
    local TS = Instance.new("UIStroke", Toggle)
    TS.Color = AETHER_CONFIG.UI_COLOR
    TS.Thickness = 2
    MakeDraggable(Toggle)

    -- Main Dashboard
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 620, 0, 240)
    Main.Position = UDim2.new(0.5, -310, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    local MS = Instance.new("UIStroke", Main)
    MS.Color = AETHER_CONFIG.UI_COLOR
    MS.Thickness = 1.5
    MakeDraggable(Main)

    -- Top Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "AETHER WALK AUTHORITY // " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    local function ControlBtn(txt, color, xPos, call)
        local b = Instance.new("TextButton", Header)
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = UDim2.new(1, xPos, 0, 2.5)
        b.BackgroundTransparency = 1
        b.Text = txt
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBlack
        b.MouseButton1Down:Connect(call)
    end

    ControlBtn("X", Color3.fromRGB(255, 100, 100), -35, function()
        AETHER_CONFIG.ACTIVE = false
        CleanupGhost()
        Screen:Destroy()
    end)

    ControlBtn("-", Color3.new(1,1,1), -70, function()
        Main.Visible = false
        Toggle.Visible = true
    end)

    Toggle.MouseButton1Down:Connect(function()
        Main.Visible = true
        Toggle.Visible = false
    end)

    -- Container
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -20, 1, -50)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Content)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 10)

    local function CreateSection(name, width)
        local Sec = Instance.new("Frame", Content)
        Sec.Size = UDim2.new(0, width, 1, 0)
        Sec.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Instance.new("UICorner", Sec)
        Instance.new("UIStroke", Sec).Color = Color3.fromRGB(30, 30, 30)
        
        local T = Instance.new("TextLabel", Sec)
        T.Size = UDim2.new(1, 0, 0, 25)
        T.Text = name:upper()
        T.TextColor3 = AETHER_CONFIG.UI_COLOR
        T.Font = Enum.Font.GothamBold
        T.TextSize = 10
        T.BackgroundTransparency = 1
        
        local Holder = Instance.new("Frame", Sec)
        Holder.Size = UDim2.new(1, -10, 1, -35)
        Holder.Position = UDim2.new(0, 5, 0, 30)
        Holder.BackgroundTransparency = 1
        local L = Instance.new("UIListLayout", Holder)
        L.Padding = UDim.new(0, 5)
        
        return Holder
    end

    local function EliteBtn(txt, parent, call)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 32)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        b.Text = txt
        b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 11
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(function()
            if Internal.UI_Debounce then return end
            Internal.UI_Debounce = true
            call(b)
            task.wait(0.2)
            Internal.UI_Debounce = false
        end)
        return b
    end

    -- Sections
    local SecCore = CreateSection("Engines", 130)
    local FlyBtn = EliteBtn("FLY: DISABLED", SecCore, function(b)
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED
    end)

    local GodBtn = EliteBtn("PHANTOM: DISABLED", SecCore, function(b)
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE
    end)

    local SecTools = CreateSection("Authority", 150)
    local SpeedIn = Instance.new("TextBox", SecTools)
    SpeedIn.Size = UDim2.new(1, 0, 0, 32)
    SpeedIn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SpeedIn.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    SpeedIn.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedIn.Font = Enum.Font.Code
    SpeedIn.TextSize = 11
    Instance.new("UICorner", SpeedIn)
    SpeedIn.FocusLost:Connect(function()
        local val = tonumber(SpeedIn.Text:match("%d+"))
        AETHER_CONFIG.SPEED = val or 80
        SpeedIn.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    end)

    EliteBtn("FORCE DUG", SecTools, function() LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0) end)
    EliteBtn("COPY COORDS", SecTools, function()
        local p = (Internal.GhostModel and Internal.GhostModel.PrimaryPart) or LocalPlayer.Character.HumanoidRootPart
        local vec = p.Position
        setclipboard("Vector3.new(" .. math.floor(vec.X) .. ", " .. math.floor(vec.Y) .. ", " .. math.floor(vec.Z) .. ")")
    end)

    local SecWarp = CreateSection("Warp Grid", 290)
    local WarpGrid = Instance.new("UIGridLayout", SecWarp)
    WarpGrid.CellSize = UDim2.new(0, 90, 0, 32)
    WarpGrid.CellPadding = UDim2.new(0, 5, 0, 5)

    for zone, pos in pairs(ZONES) do
        EliteBtn(zone, SecWarp, function() SmartTeleport(CFrame.new(pos)) end)
    end

    -- Master Updater
    RunService.RenderStepped:Connect(function()
        if not AETHER_CONFIG.ACTIVE then return end
        
        FlyBtn.Text = AETHER_CONFIG.ENABLED and "FLY: ACTIVE" or "FLY: DISABLED"
        FlyBtn.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0,1,0.5) or Color3.new(1,0.2,0.2)
        
        GodBtn.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM: ACTIVE" or "PHANTOM: DISABLED"
        GodBtn.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0,1,0.5) or Color3.new(1,0.2,0.2)
    end)
end

-- // RUNTIME AUTHORITY //
table.insert(Internal.Connections, RunService.Heartbeat:Connect(function(dt)
    if AETHER_CONFIG.ACTIVE then
        ExecuteAether(dt)
        GlobalBypassSync()
        HandleGhostLogic(dt)
    end
end))

BuildUI()
print("[AETHER V17] Authority Elite Online.")
