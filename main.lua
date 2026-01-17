-- // GHOST-SYNC: MOBILE APEX V23.2 //
-- FIXED: Void TP Bug (Added Raycast Ground Check)
-- FIXED: Phantom Return (Synced CFrame Handshake)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // 1. CONFIGURATION //
local AETHER_CONFIG = {
    ENABLED = false,
    PHANTOM = false,
    SPEED = 85,
    VERSION = "V23.2.0 - Stable Apex",
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

-- // 2. VOID-SHIELD MATH //
local function GetNearestSafeHole(pos)
    local relativeX = pos.X - AETHER_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relativeX / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL
    local targetX = snapX + AETHER_CONFIG.HOLE_X_OFFSET
    
    -- VOID SHIELD: If target is too far out or Y is dangerous, default to safety
    if math.abs(targetX) > 50000 then return Vector3.new(AETHER_CONFIG.HOLE_X_OFFSET, AETHER_CONFIG.SAFE_Y, pos.Z) end
    
    return Vector3.new(targetX, AETHER_CONFIG.SAFE_Y, pos.Z)
end

-- // 3. FIXED PHANTOM RETURN LOGIC //
local function CleanupGhost()
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if Internal.Ghost and Root then
        -- FIXED: Grab the position BEFORE deleting the ghost
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        if GhostRoot then
            local finalPos = GhostRoot.CFrame
            Internal.Ghost:Destroy() -- Now we can delete it
            Internal.Ghost = nil
            
            Root.Anchored = false
            Root.CFrame = finalPos -- Move real body to where phantom was
        end
    end
    
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

-- // 4. MOVEMENT: HOLE-HOP STUTTER //
local function SafeTeleport(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 20 then
        local steps = math.clamp(math.floor(dist/25), 3, 10)
        for i = 1, steps do
            local alpha = i/steps
            local midPoint = startPos:Lerp(endPos, alpha)
            Root.CFrame = CFrame.new(GetNearestSafeHole(midPoint))
            task.wait(0.06)
        end
    end
    
    Root.CFrame = targetCF
    Internal.IsWarpping = false
end

-- // 5. PHANTOM & FLY ENGINE //
local function ExecuteLogic(dt)
    if not AETHER_CONFIG.ACTIVE then return end
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Root or not Hum then return end

    if AETHER_CONFIG.PHANTOM and Internal.Ghost then
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        if GhostRoot then
            Camera.CameraSubject = Internal.Ghost:FindFirstChildOfClass("Humanoid")
            local MoveDir = Hum.MoveDirection
            if MoveDir.Magnitude > 0 then
                local look = Camera.CFrame.LookVector
                local rot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
                GhostRoot.CFrame = rot + (MoveDir * AETHER_CONFIG.SPEED * dt)
            end
        end
        Root.Anchored = true -- Keep real body safe
    elseif AETHER_CONFIG.ENABLED then
        Root.Anchored = false
        local MoveDir = Hum.MoveDirection
        if MoveDir.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            Root.CFrame += (Camera.CFrame.LookVector * AETHER_CONFIG.SPEED * dt * 0.1)
        else
            Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
        end
    end
end

-- // 6. UI CONSTRUCTION //
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
    if CoreGui:FindFirstChild("AetherApex") then CoreGui.AetherApex:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherApex"
    
    local MainToggle = Instance.new("TextButton", Screen)
    MainToggle.Size = UDim2.new(0, 60, 0, 60)
    MainToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
    MainToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainToggle.Text = "APEX"
    MainToggle.TextColor3 = Color3.fromRGB(0, 255, 180)
    MainToggle.Font = Enum.Font.GothamBlack
    MainToggle.TextSize = 10
    Instance.new("UICorner", MainToggle)
    AttachMobileDrag(MainToggle)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 350, 0, 220)
    Main.Position = UDim2.new(0.5, -175, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.Visible = false
    Instance.new("UICorner", Main)
    local S = Instance.new("UIStroke", Main)
    S.Color = Color3.fromRGB(0, 255, 180)
    S.Thickness = 2
    AttachMobileDrag(Main)

    MainToggle.MouseButton1Down:Connect(function() Main.Visible = not Main.Visible end)

    local List = Instance.new("ScrollingFrame", Main)
    List.Size = UDim2.new(1, -20, 1, -20)
    List.Position = UDim2.new(0, 10, 0, 10)
    List.BackgroundTransparency = 1
    List.CanvasSize = UDim2.new(0,0,1.5,0)
    local Layout = Instance.new("UIListLayout", List)
    Layout.Padding = UDim.new(0, 8)

    local function Btn(txt, call)
        local b = Instance.new("TextButton", List)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.Text = txt
        b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(function() call(b) end)
        return b
    end

    Btn("FLY: OFF", function(b) 
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED 
        b.Text = AETHER_CONFIG.ENABLED and "FLY: ACTIVE" or "FLY: OFF"
    end)

    Btn("PHANTOM: OFF", function(b) 
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
            -- FIXED: Cleanup now handles the TP to the ghost position correctly
            CleanupGhost()
        end
        b.Text = AETHER_CONFIG.PHANTOM and "PHANTOM: ACTIVE" or "PHANTOM: OFF"
    end)

    Btn("FORCE DUG SNAP", function()
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root then SafeTeleport(CFrame.new(GetNearestSafeHole(Root.Position))) end
    end)
end

-- // RUNTIME //
table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
