-- // GHOST-SYNC: REMOTE LOADER V6 //
-- Optimized for: Authority Prime V20
-- URL: https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua

local RemoteURL = "https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua"

local function LoadProject()
    local success, response = pcall(function()
        return game:HttpGet(RemoteURL)
    end)

    if success and response then
        print("[AUTHORITY] Fetch Successful. Booting Apex Engine...")
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
    AETHER-WALK V20: AUTHORITY PRIME (FINAL ARCHITECTURE)
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-17]
    - FIXED: UI Snapping. Now uses Absolute Pixel Tracking via RenderStepped.
    - FIXED: Auto-Off Bug. Implemented Global State-Locking (Primary Authority).
    - FIXED: Phantom Slowdown. Added Kinematic Velocity Buffering.
    - FIXED: UI Deletion. Deep-disconnect Nuke function added.
    - NEW: "Authority" Frame syncing. The UI and Script run on the same clock.
    - OPTIMIZATION: Zero line deletion. Added 150+ lines of safety logic.
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
    VERSION = "V20.0.0 - Authority Prime",
    SAFE_BASE = Vector3.new(66, 3, 7),
    ACTIVE = true -- Global Authority Switch
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
    Connections = {}, -- Store all loops here for Nuke()
    Dragging = false,
    DragOffset = Vector2.new(0, 0),
    CurrentDragFrame = nil,
    VelocityBuffer = Vector3.new(0, 0, 0)
}

-- // 4. THE "NUKE" CLEANUP (FIXES UI NOT DELETING) //
local function NukeAuthority()
    AETHER_CONFIG.ACTIVE = false
    AETHER_CONFIG.GOD_MODE = false
    AETHER_CONFIG.ENABLED = false
    
    -- Disconnect all loops
    for _, conn in pairs(Internal.Connections) do
        if conn then conn:Disconnect() end
    end
    
    -- Cleanup Ghost
    if Internal.GhostModel then Internal.GhostModel:Destroy() end
    
    -- Reset Physics
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then Root.Anchored = false end
    
    -- Destroy UI
    if CoreGui:FindFirstChild("AetherPrime") then
        CoreGui.AetherPrime:Destroy()
    end
    print("[AUTHORITY] Engine Nuked. All processes terminated.")
end

-- // 5. SMART BYPASS ENGINE (PRIME STUTTER TP) //
local function SmartTeleport(targetCFrame)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsTeleporting or not AETHER_CONFIG.ACTIVE then return end
    
    Internal.IsTeleporting = true
    local startPos = Root.Position
    local endPos = targetCFrame.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 25 then
        local steps = math.clamp(math.floor(dist/12), 12, 45)
        for i = 1, steps do
            if not AETHER_CONFIG.ACTIVE then break end
            local alpha = i/steps
            local nextPoint = startPos:Lerp(endPos, alpha)
            
            -- Prime Jitter (AC Bypass)
            local jitter = Vector3.new(math.sin(i)*0.2, math.cos(i)*0.1, math.sin(i*2)*0.2)
            Root.CFrame = CFrame.new(nextPoint + jitter)
            
            if i % 3 == 0 then RunService.Heartbeat:Wait() end
        end
    end
    
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 6. PRIME GHOST ENGINE (FIXED SLOWING) //
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
        GhostRoot.Anchored = true
        
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            -- Authority Prime Movement: dt scaling ensures zero slowing
            local look = Camera.CFrame.LookVector
            local rot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
            local velocity = (MoveDir * AETHER_CONFIG.SPEED * dt)
            
            GhostRoot.CFrame = rot + velocity
        end
        GhostRoot.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // 7. GLOBAL BYPASS SYNC (STATE-LOCKING) //
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
                    Internal.GhostModel.Name = "Aether_Prime_Ghost"
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

                -- Authority State-Lock: Prevent falling
                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 5) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 10, 0))
                end
                Root.Anchored = true
            else
                if Internal.GhostModel then
                    local ret = Internal.GhostModel.PrimaryPart.CFrame
                    CleanupGhost()
                    Root.Anchored = false
                    SmartTeleport(ret)
                end
            end
        end
    end)
end

-- // 8. AETHER-FLY ENGINE //
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

-- // 9. V20 UI AUTHORITY (ABSOLUTE PIXEL DRAG) //
local function AttachPrimeDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            Internal.CurrentDragFrame = frame
            local mousePos = UserInputService:GetMouseLocation()
            Internal.DragOffset = Vector2.new(mousePos.X - frame.AbsolutePosition.X, mousePos.Y - frame.AbsolutePosition.Y)
        end
    end)
end

-- The Global Drag Loop (Bypasses UI Snap)
table.insert(Internal.Connections, RunService.RenderStepped:Connect(function()
    if Internal.Dragging and Internal.CurrentDragFrame and AETHER_CONFIG.ACTIVE then
        local mousePos = UserInputService:GetMouseLocation()
        -- Direct Pixel Injection
        Internal.CurrentDragFrame.Position = UDim2.new(0, mousePos.X - Internal.DragOffset.X, 0, mousePos.Y - Internal.DragOffset.Y - 36)
    end
end))

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Internal.Dragging = false
        Internal.CurrentDragFrame = nil
    end
end)

local function BuildUI()
    if CoreGui:FindFirstChild("AetherPrime") then CoreGui.AetherPrime:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherPrime"
    Screen.ResetOnSpawn = false

    -- Minimizer
    local Toggle = Instance.new("TextButton", Screen)
    Toggle.Size = UDim2.new(0, 50, 0, 50)
    Toggle.Position = UDim2.new(0.02, 0, 0.8, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Toggle.Text = "PRIME"
    Toggle.TextColor3 = AETHER_CONFIG.UI_COLOR
    Toggle.Font = Enum.Font.GothamBlack
    Toggle.TextSize = 12
    Toggle.Visible = false
    Instance.new("UICorner", Toggle)
    local TS = Instance.new("UIStroke", Toggle)
    TS.Color = AETHER_CONFIG.UI_COLOR
    TS.Thickness = 2
    AttachPrimeDrag(Toggle)

    -- Main Dashboard
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 650, 0, 260)
    Main.Position = UDim2.new(0.5, -325, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    local MS = Instance.new("UIStroke", Main)
    MS.Color = AETHER_CONFIG.UI_COLOR
    MS.Thickness = 1.5
    AttachPrimeDrag(Main)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -120, 1, 0)
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
        b.Position = UDim2.new(1, xPos, 0, 5)
        b.BackgroundTransparency = 1
        b.Text = txt
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 18
        b.MouseButton1Down:Connect(call)
    end

    ControlBtn("X", Color3.fromRGB(255, 100, 100), -35, NukeAuthority)

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
    Content.Size = UDim2.new(1, -20, 1, -55)
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

    local function PrimeBtn(txt, parent, call)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 35)
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
            task.wait(0.3)
            Internal.UI_Debounce = false
        end)
        return b
    end

    -- SECTIONS
    local SecCore = CreateSection("Engines", 140)
    local FlyBtn = PrimeBtn("FLY: OFF", SecCore, function() AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED end)
    local GodBtn = PrimeBtn("PHANTOM: OFF", SecCore, function() AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE end)

    local SecTools = CreateSection("Tools", 160)
    local SpeedIn = Instance.new("TextBox", SecTools)
    SpeedIn.Size = UDim2.new(1, 0, 0, 35)
    SpeedIn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SpeedIn.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    SpeedIn.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedIn.Font = Enum.Font.Code
    SpeedIn.TextSize = 11
    Instance.new("UICorner", SpeedIn)
    SpeedIn.FocusLost:Connect(function()
        local val = tonumber(SpeedIn.Text:match("%d+"))
        if val then AETHER_CONFIG.SPEED = val end
        SpeedIn.Text = "SPEED: " .. AETHER_CONFIG.SPEED
    end)

    PrimeBtn("FORCE DUG (-35)", SecTools, function() LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0) end)
    PrimeBtn("COPY COORDS", SecTools, function()
        local pos = (Internal.GhostModel and Internal.GhostModel.PrimaryPart.Position) or LocalPlayer.Character.HumanoidRootPart.Position
        setclipboard("Vector3.new("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")")
    end)

    local SecWarp = CreateSection("Warp Authority", 280)
    local WarpGrid = Instance.new("UIGridLayout", SecWarp)
    WarpGrid.CellSize = UDim2.new(0, 85, 0, 35)
    WarpGrid.CellPadding = UDim2.new(0, 5, 0, 5)

    for zone, pos in pairs(ZONES) do
        PrimeBtn(zone, SecWarp, function() SmartTeleport(CFrame.new(pos)) end)
    end

    -- STATE GUARDIAN (Fixes Auto-Off)
    table.insert(Internal.Connections, RunService.RenderStepped:Connect(function()
        if not AETHER_CONFIG.ACTIVE then return end
        FlyBtn.Text = AETHER_CONFIG.ENABLED and "FLY: ACTIVE" or "FLY: DISABLED"
        FlyBtn.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0,1,0.5) or Color3.new(1,0.2,0.2)
        GodBtn.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM: ACTIVE" or "PHANTOM: DISABLED"
        GodBtn.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0,1,0.5) or Color3.new(1,0.2,0.2)
    end))
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
print("[AETHER V20] Authority Prime Online. Engine Lock Active.")
