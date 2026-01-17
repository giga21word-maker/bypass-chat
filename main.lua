-- // GHOST-SYNC: MOBILE APEX V23.6 //
-- BYPASS: Raycast-Height Validation + Velocity Spoof
-- SAFETY: Void-Check + 5-Chunk Segmenting

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
    VERSION = "V23.6.0 - Sentinel Shield",
    HOLE_X_OFFSET = 282,
    HOLE_INTERVAL = 84,
    SAFE_Y = -3, -- Default target, but now validated
    ACTIVE = true
}

local Internal = {
    Ghost = nil,
    IsWarpping = false,
    Connections = {},
    Dragging = false,
    DragOffset = Vector2.new(0, 0)
}

-- // 2. SENTINEL HEIGHT VALIDATION //
local function GetSafePosition(pos)
    -- Raycast down to find the floor
    local rayParam = RaycastParams.new()
    rayParam.FilterDescendantsInstances = {LocalPlayer.Character, Internal.Ghost}
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    
    local ray = Workspace:Raycast(pos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), rayParam)
    
    local targetX = (math.round((pos.X - AETHER_CONFIG.HOLE_X_OFFSET) / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL) + AETHER_CONFIG.HOLE_X_OFFSET
    
    if ray then
        -- Floor found! Stay exactly at the floor level or slightly below (-3)
        return Vector3.new(targetX, ray.Position.Y - 2.5, pos.Z)
    else
        -- NO FLOOR! Stay at safe Y-3 but don't drop further
        return Vector3.new(targetX, AETHER_CONFIG.SAFE_Y, pos.Z)
    end
end

-- // 3. CHUNK-TP (5-HOLE STEP) //
local function SentinelTeleport(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    
    local direction = (endPos.X > startPos.X) and 1 or -1
    local totalHoles = math.floor(math.abs(endPos.X - startPos.X) / AETHER_CONFIG.HOLE_INTERVAL)

    if totalHoles > 0 then
        for i = 1, totalHoles do
            if not AETHER_CONFIG.ACTIVE then break end
            
            -- Wait 2s every 5 holes to clear speed history
            if i % 5 == 0 then
                Root.AssemblyLinearVelocity = Vector3.new(0, -1, 0) -- Spoof falling
                task.wait(2)
            end
            
            local nextX = startPos.X + (direction * (i * AETHER_CONFIG.HOLE_INTERVAL))
            local safeTarget = GetSafePosition(Vector3.new(nextX, AETHER_CONFIG.SAFE_Y, endPos.Z))
            
            -- Add tiny Jitter to bypass "Pixel-Perfect" detection
            local jitter = Vector3.new(math.random(-10,10)/100, 0, math.random(-10,10)/100)
            Root.CFrame = CFrame.new(safeTarget + jitter)
            
            RunService.Heartbeat:Wait()
        end
    end
    
    Root.CFrame = targetCF
    task.wait(0.5)
    Internal.IsWarpping = false
end

-- // 4. PHANTOM STOP //
local function StopPhantom()
    if Internal.Ghost then
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        if GhostRoot then
            local targetPos = GhostRoot.Position
            local finalCF = CFrame.new(GetSafePosition(targetPos))
            
            Internal.Ghost:Destroy()
            Internal.Ghost = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            task.spawn(function()
                SentinelTeleport(finalCF)
            end)
        end
    end
end

-- // 5. RUNTIME //
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
        -- Safe-Lock real body
        Root.CFrame = CFrame.new(GetSafePosition(Root.Position))
        Root.Anchored = true
    elseif AETHER_CONFIG.ENABLED then
        Root.Anchored = false
        if Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
        else
            Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
        end
    end
end

-- // 6. UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherApex") then CoreGui.AetherApex:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherApex"
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 260, 0, 160)
    Main.Position = UDim2.new(0.5, -130, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 180)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "SENTINEL APEX V23.6"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0, 220, 0, 50)
    B.Position = UDim2.new(0, 20, 0, 60)
    B.Text = "TOGGLE PHANTOM"
    B.Font = Enum.Font.GothamBold
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
            B.Text = "ACTIVE (GHOST OUT)"
        else
            B.Text = "5-CHUNK RETURN..."
            StopPhantom()
            task.wait(1)
            B.Text = "TOGGLE PHANTOM"
        end
    end)
end

table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
