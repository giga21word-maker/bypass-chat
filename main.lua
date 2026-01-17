-- // GHOST-SYNC: MOBILE APEX V23.1 //
-- Optimized for: Mobile Touch / Safe-Hole Grid Authority
-- Pattern: Interval 84 | Height -3

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
    VERSION = "V23.1.0 - Mobile Apex",
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
-- Logic: (CurrentX - 282) / 84 gives us the hole index. Rounding and multiplying back snaps it.
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
    
    -- Stutter transit: Hops through safe holes to prevent Tsunami hits during TP
    if dist > 25 then
        local steps = math.clamp(math.floor(dist/30), 4, 15)
        for i = 1, steps do
            if not AETHER_CONFIG.ACTIVE then break end
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
    if Root then 
        Root.Anchored = false 
        Root.AssemblyLinearVelocity = Vector3.zero
    end
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
                -- Velocity Buffer: Direct CFrame translation prevents the "slowing" bug
                GhostRoot.CFrame = rot + (MoveDir * AETHER_CONFIG.SPEED * dt)
            end
        end
        -- Lock real body in nearest safe hole while phantom is out
        Root.Anchored = true
    elseif AETHER_CONFIG.ENABLED then
        Root.Anchored = false
        local MoveDir = Hum.MoveDirection
        if MoveDir.Magnitude > 0 then
            local TargetVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            Root.AssemblyLinearVelocity = TargetVelocity
            Root.CFrame += (TargetVelocity * dt * 0.1)
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
            local mousePos = UserInputService:GetMouseLocation()
            Internal.DragOffset = Vector2.new(mousePos.X - frame.AbsolutePosition.X, mousePos.Y - frame.AbsolutePosition.Y)
        end
    end)
end

-- RenderStepped Drag Loop: Bypasses UI Snap by calculating Absolute Pixels
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
    Screen.ResetOnSpawn = false

    -- Toggle Button (Mobile Access Point)
    local MainToggle = Instance.new("TextButton", Screen)
    MainToggle.Size = UDim2.new(0, 65, 0, 65)
    MainToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
    MainToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainToggle.Text = "APEX"
    MainToggle.TextColor3 = Color3.fromRGB(0, 255, 180)
    MainToggle.Font = Enum.Font.GothamBlack
    MainToggle.TextSize = 12
    Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0, 12)
    local TStroke = Instance.new("UIStroke", MainToggle)
    TStroke.Color = Color3.fromRGB(0, 255, 180)
    TStroke.Thickness = 2
    AttachMobileDrag(MainToggle)

    -- Main Dashboard
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 380, 0, 250)
    Main.Position = UDim2.new(0.5, -190, 0.35, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.Visible = false
    Instance.new("UICorner", Main)
    local MStroke = Instance.new("UIStroke", Main)
    MStroke.Color = Color3.fromRGB(0, 255, 180)
    MStroke.Thickness = 1.5
    AttachMobileDrag(Main)

    MainToggle.MouseButton1Down:Connect(function() Main.Visible = not Main.Visible end)

    -- Header
    local HeaderText = Instance.new("TextLabel", Main)
    HeaderText.Size = UDim2.new(1, 0, 0, 40)
    HeaderText.Text = "SOVEREIGN MOBILE // " .. AETHER_CONFIG.VERSION
    HeaderText.TextColor3 = Color3.new(1,1,1)
    HeaderText.Font = Enum.Font.GothamBold
    HeaderText.TextSize = 13
    HeaderText.BackgroundTransparency = 1

    -- Container
    local Grid = Instance.new("ScrollingFrame", Main)
    Grid.Size = UDim2.new(1, -20, 1, -60)
    Grid.Position = UDim2.new(0, 10, 0, 50)
    Grid.BackgroundTransparency = 1
    Grid.BorderSizePixel = 0
    Grid.CanvasSize = UDim2.new(0, 0, 1.2, 0)
    Grid.ScrollBarThickness = 3
    local UIList = Instance.new("UIListLayout", Grid)
    UIList.Padding = UDim.new(0, 10)

    local function CreateButton(txt, call)
        local b = Instance.new("TextButton", Grid)
        b.Size = UDim2.new(1, 0, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.Text = txt
        b.TextColor3 = Color3.new(0.85, 0.85, 0.85)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(function() call(b) end)
        return b
    end

    -- FEATURE: FLY
    CreateButton("FLY ENGINE: OFF", function(b) 
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED 
        b.Text = AETHER_CONFIG.ENABLED and "FLY ENGINE: ACTIVE" or "FLY ENGINE: OFF"
        b.TextColor3 = AETHER_CONFIG.ENABLED and Color3.fromRGB(0, 255, 180) or Color3.new(0.85,0.85,0.85)
    end)

    -- FEATURE: PHANTOM (GOD MODE)
    CreateButton("PHANTOM GOD: OFF", function(b) 
        AETHER_CONFIG.PHANTOM = not AETHER_CONFIG.PHANTOM
        if AETHER_CONFIG.PHANTOM then
            local Char = LocalPlayer.Character
            Char.Archivable = true
            Internal.Ghost = Char:Clone()
            Internal.Ghost.Name = "Apex_Ghost"
            Internal.Ghost.Parent = Workspace
            for _, v in pairs(Internal.Ghost:GetDescendants()) do
                if v:IsA("BasePart") then 
                    v.Transparency = 0.5 
                    v.CanCollide = false 
                    v.Anchored = true 
                    v.Color = Color3.fromRGB(0, 255, 180)
                end
            end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            Root.CFrame = CFrame.new(GetNearestSafeHole(Root.Position))
            Root.Anchored = true
        else
            local target = Internal.Ghost.PrimaryPart.CFrame
            CleanupGhost()
            SafeTeleport(target)
        end
        b.Text = AETHER_CONFIG.PHANTOM and "PHANTOM GOD: ACTIVE" or "PHANTOM GOD: OFF"
        b.TextColor3 = AETHER_CONFIG.PHANTOM and Color3.fromRGB(0, 255, 180) or Color3.new(0.85,0.85,0.85)
    end)

    -- FEATURE: FORCE DUG SNAP
    CreateButton("FORCE DUG (X84 SNAP)", function()
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root then 
            SafeTeleport(CFrame.new(GetNearestSafeHole(Root.Position))) 
        end
    end)

    -- FEATURE: KILL SCRIPT
    CreateButton("TERMINATE ENGINE", function()
        AETHER_CONFIG.ACTIVE = false
        CleanupGhost()
        for _, c in pairs(Internal.Connections) do c:Disconnect() end
        Screen:Destroy()
    end)
end

-- // RUNTIME AUTHORITY //
table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()

print("[SOVEREIGN APEX] System Optimized for Mobile. Authority Locked.")
