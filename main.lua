-- // GHOST-SYNC: MOBILE APEX V23 //
-- Optimized for: Mobile Touch / Safe-Hole Grid
-- URL: https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua

--[[
    AETHER V23: SOVEREIGN MOBILE APEX
    ----------------------------------------------------------
    - MOBILE: Added Touch-Friendly UI with Responsive Buttons.
    - GRID: Safe Hole Snapping (Interval: 84 | Height: -3).
    - FIXED: UI Snapping bug via Absolute Touch-Delta Tracking.
    - CORE: Fly, Phantom, Speed, and Safe-Hole Stutter.
    ----------------------------------------------------------
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // 1. CONFIGURATION AUTHORITY //
local AETHER_CONFIG = {
    ENABLED = false,
    PHANTOM = false,
    SPEED = 85,
    VERSION = "V23.0.0 - Mobile Apex",
    HOLE_X_OFFSET = 282,
    HOLE_INTERVAL = 84,
    SAFE_Y = -3,
    ACTIVE = true
}

local Internal = {
    Ghost = nil,
    IsWarpping = false,
    Connections = {},
    Dragging = false,
    DragOffset = Vector2.new(0, 0),
    CurrentFrame = nil
}

-- // 2. MATH CORE: SAFE HOLE LOGIC //
local function GetNearestSafeHole(pos)
    local relativeX = pos.X - AETHER_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relativeX / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL
    return Vector3.new(snapX + AETHER_CONFIG.HOLE_X_OFFSET, AETHER_CONFIG.SAFE_Y, pos.Z)
end

-- // 3. MOVEMENT: HOLE-HOP STUTTER //
local function SafeTeleport(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 20 then
        local steps = math.clamp(math.floor(dist/20), 4, 12)
        for i = 1, steps do
            local alpha = i/steps
            local hopPos = GetNearestSafeHole(startPos:Lerp(endPos, alpha))
            Root.CFrame = CFrame.new(hopPos)
            task.wait(0.05)
        end
    end
    Root.CFrame = targetCF
    Internal.IsWarpping = false
end

-- // 4. PHANTOM & FLY ENGINE //
local function CleanupGhost()
    if Internal.Ghost then Internal.Ghost:Destroy() end
    Internal.Ghost = nil
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then Root.Anchored = false end
end

local function ExecuteLogic(dt)
    if not AETHER_CONFIG.ACTIVE then return end
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Root or not Hum then return end

    if AETHER_CONFIG.PHANTOM and Internal.Ghost then
        Camera.CameraSubject = Internal.Ghost:FindFirstChildOfClass("Humanoid")
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        if GhostRoot then
            local MoveDir = Hum.MoveDirection
            if MoveDir.Magnitude > 0 then
                local look = Camera.CFrame.LookVector
                local rot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
                GhostRoot.CFrame = rot + (MoveDir * AETHER_CONFIG.SPEED * dt)
            end
        end
    elseif AETHER_CONFIG.ENABLED then
        local MoveDir = Hum.MoveDirection
        if MoveDir.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            Root.CFrame += (Camera.CFrame.LookVector * AETHER_CONFIG.SPEED * dt * 0.1)
        else
            Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
        end
    end
end

-- // 5. UI AUTHORITY: MOBILE DRAG & BUILD //
local function AttachMobileDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            Internal.CurrentFrame = frame
            local startPos = input.Position
            Internal.DragOffset = Vector2.new(startPos.X - frame.AbsolutePosition.X, startPos.Y - frame.AbsolutePosition.Y)
        end
    end)
end

-- Global Drag Loop (Bypass Snap)
table.insert(Internal.Connections, RunService.RenderStepped:Connect(function()
    if Internal.Dragging and Internal.CurrentFrame then
        local inputPos = UserInputService:GetMouseLocation()
        Internal.CurrentFrame.Position = UDim2.new(0, inputPos.X - Internal.DragOffset.X, 0, inputPos.Y - Internal.DragOffset.Y - 36)
    end
end))

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Internal.Dragging = false
        Internal.CurrentFrame = nil
    end
end)

local function BuildUI()
    if CoreGui:FindFirstChild("AetherMobile") then CoreGui.AetherMobile:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherMobile"

    -- Toggle Button (For Mobile)
    local MainToggle = Instance.new("TextButton", Screen)
    MainToggle.Size = UDim2.new(0, 60, 0, 60)
    MainToggle.Position = UDim2.new(0.05, 0, 0.15, 0)
    MainToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainToggle.Text = "AETHER"
    MainToggle.TextColor3 = Color3.fromRGB(0, 255, 180)
    MainToggle.Font = Enum.Font.GothamBlack
    MainToggle.TextSize = 10
    Instance.new("UICorner", MainToggle)
    AttachMobileDrag(MainToggle)

    -- Main Dashboard
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 400, 0, 240)
    Main.Position = UDim2.new(0.5, -200, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.Visible = false
    Instance.new("UICorner", Main)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(0, 255, 180)
    Stroke.Thickness = 2
    AttachMobileDrag(Main)

    MainToggle.MouseButton1Down:Connect(function() Main.Visible = not Main.Visible end)

    -- Title
    local T = Instance.new("TextLabel", Main)
    T.Size = UDim2.new(1, 0, 0, 35)
    T.Text = "SOVEREIGN MOBILE APEX " .. AETHER_CONFIG.VERSION
    T.TextColor3 = Color3.new(1,1,1)
    T.Font = Enum.Font.GothamBold
    T.TextSize = 12
    T.BackgroundTransparency = 1

    -- Grid Layout
    local Grid = Instance.new("ScrollingFrame", Main)
    Grid.Size = UDim2.new(1, -20, 1, -50)
    Grid.Position = UDim2.new(0, 10, 0, 40)
    Grid.BackgroundTransparency = 1
    Grid.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Grid.ScrollBarThickness = 2
    local UIList = Instance.new("UIListLayout", Grid)
    UIList.Padding = UDim.new(0, 8)

    local function CreateButton(txt, call)
        local b = Instance.new("TextButton", Grid)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        b.Text = txt
        b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(call)
        return b
    end

    -- Feature Buttons
    local FlyB = CreateButton("FLY: OFF", function(b) 
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED 
        b.Text = AETHER_CONFIG.ENABLED and "FLY: ON" or "FLY: OFF"
        b.TextColor3 = AETHER_CONFIG.ENABLED and Color3.fromRGB(0, 255, 180) or Color3.new(0.9,0.9,0.9)
    end)

    local PhantB = CreateButton("PHANTOM: OFF", function(b) 
        AETHER_CONFIG.PHANTOM = not AETHER_CONFIG.PHANTOM
        if AETHER_CONFIG.PHANTOM then
            local Char = LocalPlayer.Character
            Char.Archivable = true
            Internal.Ghost = Char:Clone()
            Internal.Ghost.Parent = Workspace
            for _, v in pairs(Internal.Ghost:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.5 v.CanCollide = false v.Anchored = true end
            end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            Root.CFrame = CFrame.new(GetNearestSafeHole(Root.Position))
            Root.Anchored = true
        else
            local target = Internal.Ghost.PrimaryPart.CFrame
            CleanupGhost()
            SafeTeleport(target)
        end
        b.Text = AETHER_CONFIG.PHANTOM and "PHANTOM: ON" or "PHANTOM: OFF"
        b.TextColor3 = AETHER_CONFIG.PHANTOM and Color3.fromRGB(0, 255, 180) or Color3.new(0.9,0.9,0.9)
    end)

    CreateButton("FORCE DUG SNAP (SAFE HOLE)", function()
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root then SafeTeleport(CFrame.new(GetNearestSafeHole(Root.Position))) end
    end)

    CreateButton("KILL SCRIPT / NUKE UI", function()
        AETHER_CONFIG.ACTIVE = false
        CleanupGhost()
        for _, c in pairs(Internal.Connections) do c:Disconnect() end
        Screen:Destroy()
    end)
end

-- // RUNTIME //
table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
print("[AETHER V23] Mobile Authority Online. Use the screen button to toggle.")
