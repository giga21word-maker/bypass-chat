-- // GHOST-SYNC: MOBILE APEX V23.5 //
-- FEATURE: Chunk-TP (5 Holes at a time)
-- SAFETY: Void-Floor + Velocity Reset

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
    VERSION = "V23.5.0 - Quantum Step",
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
    DragOffset = Vector2.new(0, 0)
}

-- // 2. SAFETY: VOID FLOOR //
local function CreateSafetyFloor(pos)
    local Floor = Instance.new("Part")
    Floor.Size = Vector3.new(20, 1, 20)
    Floor.Position = pos + Vector3.new(0, -1, 0)
    Floor.Anchored = true
    Floor.Transparency = 1
    Floor.Parent = Workspace
    game:GetService("Debris"):AddItem(Floor, 2.1) -- Auto-deletes after the 2s wait
end

-- // 3. GRID MATH //
local function GetNearestSafeHole(pos)
    local relativeX = pos.X - AETHER_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relativeX / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL
    return Vector3.new(snapX + AETHER_CONFIG.HOLE_X_OFFSET, AETHER_CONFIG.SAFE_Y, pos.Z)
end

-- // 4. CHUNK-TP BYPASS (5 Holes -> Wait 2s) //
local function QuantumTeleport(targetCF)
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
            
            -- CHUNK LOGIC: Only wait 2 seconds every 5 holes
            if i % 5 == 0 then
                print("[APEX] CHUNK REACHED. STABILIZING FOR 2S...")
                CreateSafetyFloor(Root.Position)
                Root.AssemblyLinearVelocity = Vector3.zero -- RESET AC TRACKING
                task.wait(2)
            end
            
            local nextX = startPos.X + (direction * (i * AETHER_CONFIG.HOLE_INTERVAL))
            local targetHole = Vector3.new(nextX, AETHER_CONFIG.SAFE_Y, endPos.Z)
            
            Root.CFrame = CFrame.new(targetHole)
            RunService.Heartbeat:Wait()
        end
    end
    
    -- Final Arrival
    task.wait(1)
    Root.CFrame = targetCF
    Root.Anchored = false
    print("[APEX] ARRIVED SAFELY.")
    Internal.IsWarpping = false
end

-- // 5. PHANTOM CORE //
local function StopPhantom()
    if Internal.Ghost then
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        if GhostRoot then
            local targetPos = GhostRoot.Position
            local safeHoleCF = CFrame.new(GetNearestSafeHole(targetPos))
            
            Internal.Ghost:Destroy()
            Internal.Ghost = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            task.spawn(function()
                QuantumTeleport(safeHoleCF)
            end)
        end
    end
end

-- // 6. RUNTIME //
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
        -- Anti-Death: Lock real body in hole
        Root.CFrame = CFrame.new(GetNearestSafeHole(Root.Position))
        Root.Anchored = true
        Root.AssemblyLinearVelocity = Vector3.zero
    elseif AETHER_CONFIG.ENABLED then
        Root.Anchored = false
        if Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
        else
            Root.AssemblyLinearVelocity = Vector3.new(0, 1.1, 0)
        end
    end
end

-- // 7. UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherApex") then CoreGui.AetherApex:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherApex"
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 250, 0, 150)
    Main.Position = UDim2.new(0.5, -125, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 180)

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0, 200, 0, 50)
    B.Position = UDim2.new(0.1, 0, 0.3, 0)
    B.Text = "TOGGLE PHANTOM"
    B.Font = Enum.Font.GothamBold
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
            B.Text = "PHANTOM ACTIVE"
        else
            B.Text = "RETURNING (5-STEP)..."
            StopPhantom()
            task.wait(3)
            B.Text = "TOGGLE PHANTOM"
        end
    end)
end

table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
