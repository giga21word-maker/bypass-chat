-- // GHOST-SYNC: NEURO-LINK V23.7 //
-- FEATURE: Essence Retrieval (Brain Rot Interaction)
-- BYPASS: High-Frequency Jitter Stutter
-- SAFETY: Vector-Sync Anchor

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
    VERSION = "V23.7.0 - Neuro-Link",
    HOLE_X_OFFSET = 282,
    HOLE_INTERVAL = 84,
    SAFE_Y = -3,
    ACTIVE = true
}

local Internal = {
    Ghost = nil,
    GrabbedObject = nil,
    IsWarpping = false,
    Connections = {},
    Dragging = false,
    DragOffset = Vector2.new(0, 0)
}

-- // 2. INTERACTION MATH //
local function GetNearestSafeHole(pos)
    local relativeX = pos.X - AETHER_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relativeX / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL
    return Vector3.new(snapX + AETHER_CONFIG.HOLE_X_OFFSET, AETHER_CONFIG.SAFE_Y, pos.Z)
end

-- // 3. STUTTER TELEPORT (FIXED) //
local function StutterTP(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 15 then
        local steps = math.clamp(math.floor(dist/10), 5, 25)
        for i = 1, steps do
            local alpha = i/steps
            local lerpPos = startPos:Lerp(endPos, alpha)
            
            -- High-Freq Jitter: Jumps 0.2 studs up/down/left/right to spoof movement
            local jitter = Vector3.new(math.random(-2,2)/10, math.random(-2,2)/10, math.random(-2,2)/10)
            Root.CFrame = CFrame.new(GetNearestSafeHole(lerpPos) + jitter)
            
            RunService.Heartbeat:Wait()
        end
    end
    
    Root.CFrame = targetCF
    Internal.IsWarpping = false
end

-- // 4. BRAIN ROT RETRIEVAL SYSTEM //
local function ScanForInteractable()
    if not Internal.Ghost then return end
    local GhostPos = Internal.Ghost.PrimaryPart.Position
    
    -- Looks for objects nearby the Phantom (Brain Rot, etc)
    for _, item in pairs(Workspace:GetChildren()) do
        if item:IsA("BasePart") and not item.Anchored and (item.Position - GhostPos).Magnitude < 10 then
            return item
        elseif item:IsA("Model") and item.PrimaryPart and (item.PrimaryPart.Position - GhostPos).Magnitude < 10 then
            return item.PrimaryPart
        end
    end
    return nil
end

-- // 5. CORE LOGIC //
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
            
            -- Interaction: Keep grabbed object at Phantom
            if Internal.GrabbedObject then
                Internal.GrabbedObject.CFrame = GhostRoot.CFrame * CFrame.new(0, 0, -3)
                Internal.GrabbedObject.AssemblyLinearVelocity = Vector3.zero
            end
        end
        
        -- ANCHOR REAL BODY IN SAFE HOLE
        Root.CFrame = CFrame.new(GetNearestSafeHole(Root.Position))
        Root.Anchored = true
        Root.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // 6. UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("NeuroApex") then CoreGui.NeuroApex:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "NeuroApex"
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 240, 0, 180)
    Main.Position = UDim2.new(0.5, -120, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 180)

    local function CreateBtn(txt, pos, call)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0, 200, 0, 40)
        b.Position = pos
        b.Text = txt
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(function() call(b) end)
    end

    CreateBtn("TOGGLE PHANTOM", UDim2.new(0.1, 0, 0.15, 0), function(b)
        AETHER_CONFIG.PHANTOM = not AETHER_CONFIG.PHANTOM
        if AETHER_CONFIG.PHANTOM then
            local Char = LocalPlayer.Character
            Char.Archivable = true
            Internal.Ghost = Char:Clone()
            Internal.Ghost.Parent = Workspace
            for _, v in pairs(Internal.Ghost:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.5 v.CanCollide = false v.Anchored = true end
            end
            b.Text = "PHANTOM: ON"
        else
            if Internal.Ghost then
                local finalPos = Internal.Ghost.PrimaryPart.CFrame
                Internal.Ghost:Destroy()
                Internal.Ghost = nil
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                StutterTP(finalPos)
            end
            b.Text = "PHANTOM: OFF"
        end
    end)

    CreateBtn("GRAB NEARBY", UDim2.new(0.1, 0, 0.5, 0), function(b)
        if not Internal.GrabbedObject then
            local target = ScanForInteractable()
            if target then
                Internal.GrabbedObject = target
                b.Text = "GRABBED!"
                b.TextColor3 = Color3.fromRGB(0, 255, 180)
            else
                b.Text = "NOTHING NEARBY"
                task.wait(1)
                b.Text = "GRAB NEARBY"
            end
        else
            Internal.GrabbedObject = nil
            b.Text = "RELEASED"
            b.TextColor3 = Color3.new(1,1,1)
            task.wait(1)
            b.Text = "GRAB NEARBY"
        end
    end)
end

table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
