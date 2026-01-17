-- // AETHER-REACH V25.0 //
-- FEATURE: Dynamic Grab-Box (Physics Anchor)
-- FIXED: Ghost Movement Controls (Vector-Thrust)
-- BYPASS: Multi-Layer Physics Masking

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // 1. AUTHORITY CONFIGURATION //
local AETHER_CONFIG = {
    ENABLED = false,
    PHANTOM = false,
    SPEED = 90,
    VERSION = "V25.0.0 - Aether Reach",
    HOLE_X_OFFSET = 282,
    HOLE_INTERVAL = 84,
    SAFE_Y = -3.5,
    ACTIVE = true
}

local Internal = {
    Ghost = nil,
    GrabBox = nil,
    IsWarpping = false,
    Connections = {},
    Dragging = false,
    DragOffset = Vector2.new(0, 0)
}

-- // 2. SMART MATH: GRID AUTHORITY //
local function GetValidatedHole(pos)
    local relX = pos.X - AETHER_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relX / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL
    return Vector3.new(snapX + AETHER_CONFIG.HOLE_X_OFFSET, AETHER_CONFIG.SAFE_Y, pos.Z)
end

-- // 3. PHYSICS GRAB-BOX //
local function CreateGrabBox()
    local Box = Instance.new("Part")
    Box.Name = "AetherGrabBox"
    Box.Size = Vector3.new(8, 8, 8) -- Large interaction radius
    Box.Transparency = 0.8 -- Slightly visible so you can see your grab range
    Box.Color = Color3.fromRGB(0, 255, 180)
    Box.CanCollide = false
    Box.Anchored = true
    Box.Parent = Workspace
    Internal.GrabBox = Box
end

-- // 4. ADVANCED MOVEMENT & INTERACTION //
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
            -- FIXED MOVEMENT: Uses Camera Relative Vectoring
            local MoveDir = Hum.MoveDirection
            if MoveDir.Magnitude > 0 then
                local camCF = Camera.CFrame
                local look = camCF.LookVector
                local right = camCF.RightVector
                
                -- Remove Y component from vectors for flat movement
                local forward = Vector3.new(look.X, 0, look.Z).Unit
                local side = Vector3.new(right.X, 0, right.Z).Unit
                
                local velocity = (forward * MoveDir.Z + side * MoveDir.X) * AETHER_CONFIG.SPEED
                GhostRoot.CFrame = GhostRoot.CFrame + (velocity * dt)
                
                -- Smooth rotation
                GhostRoot.CFrame = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + forward)
            end

            -- GRAB-BOX SYNC: Follows Ghost to allow interactions
            if Internal.GrabBox then
                Internal.GrabBox.CFrame = GhostRoot.CFrame
            end
        end
        
        -- SAFE-LOCK REAL BODY
        Root.CFrame = CFrame.new(GetValidatedHole(Root.Position))
        Root.Anchored = true
        Root.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // 5. BYPASS TELEPORT (STUTTER-SINK) //
local function AetherTeleport(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    local distance = (startPos - endPos).Magnitude
    
    if distance > 10 then
        local steps = math.clamp(math.floor(distance / 12), 4, 35)
        for i = 1, steps do
            local alpha = i / steps
            local nextHole = GetValidatedHole(startPos:Lerp(endPos, alpha))
            
            -- STUTTER BYPASS: Random micro-waits to look like jittery lag
            Root.CFrame = CFrame.new(nextHole + Vector3.new(math.random(-5,5)/100, 0, math.random(-5,5)/100))
            if i % 4 == 0 then RunService.Heartbeat:Wait() end
        end
    end
    
    -- WAKE UP CALL: Force character physics to reset
    Root.CFrame = targetCF
    task.wait(0.1)
    Root.Anchored = false
    Root.AssemblyLinearVelocity = Vector3.new(0, 5, 0) -- Kickstart physics
    Internal.IsWarpping = false
end

-- // 6. UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherUI") then CoreGui.AetherUI:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherUI"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 150)
    Main.Position = UDim2.new(0.5, -110, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 180)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "AETHER REACH " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.BackgroundTransparency = 1

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0, 180, 0, 60)
    B.Position = UDim2.new(0.09, 0, 0.4, 0)
    B.Text = "ACTIVATE PHANTOM"
    B.Font = Enum.Font.GothamBlack
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", B)

    B.MouseButton1Down:Connect(function()
        AETHER_CONFIG.PHANTOM = not AETHER_CONFIG.PHANTOM
        if AETHER_CONFIG.PHANTOM then
            local Char = LocalPlayer.Character
            Char.Archivable = true
            Internal.Ghost = Char:Clone()
            Internal.Ghost.Parent = Workspace
            for _, v in pairs(Internal.Ghost:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.5 v.CanCollide = false v.Anchored = true end
            end
            CreateGrabBox() -- Spawns interaction sphere
            B.Text = "RELEASE PHANTOM"
        else
            local finalCF = Internal.Ghost.PrimaryPart.CFrame
            if Internal.GrabBox then Internal.GrabBox:Destroy() end
            Internal.Ghost:Destroy()
            Internal.Ghost = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            task.spawn(function()
                AetherTeleport(finalCF)
                B.Text = "ACTIVATE PHANTOM"
            end)
        end
    end)
end

table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
