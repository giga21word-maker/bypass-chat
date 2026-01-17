-- // GHOST-SYNC: MOBILE APEX V23.4 //
-- FEATURE: Delayed Segmented TP (2s Interval)
-- BYPASS: Heartbeat Handshake + Wait Buffer

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
    VERSION = "V23.4.0 - Delayed Return",
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

-- // 2. GRID MATH //
local function GetNearestSafeHole(pos)
    local relativeX = pos.X - AETHER_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relativeX / AETHER_CONFIG.HOLE_INTERVAL) * AETHER_CONFIG.HOLE_INTERVAL
    return Vector3.new(snapX + AETHER_CONFIG.HOLE_X_OFFSET, AETHER_CONFIG.SAFE_Y, pos.Z)
end

-- // 3. SEGMENTED TP BYPASS (Wait 2s -> Move) //
local function SafeTeleportDelayed(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    print("[APEX] SEGMENTED TP STARTED. STAND STILL.")

    local startPos = Root.Position
    local endPos = targetCF.Position
    
    -- Calculate path in "Big TPs" (Hole to Hole)
    local direction = (endPos.X > startPos.X) and 1 or -1
    local totalHoles = math.floor(math.abs(endPos.X - startPos.X) / AETHER_CONFIG.HOLE_INTERVAL)

    if totalHoles > 0 then
        for i = 1, totalHoles do
            if not AETHER_CONFIG.ACTIVE then break end
            
            -- WAIT 2 SECONDS (As requested for bypass)
            task.wait(2) 
            
            local nextX = startPos.X + (direction * (i * AETHER_CONFIG.HOLE_INTERVAL))
            local targetHole = Vector3.new(nextX, AETHER_CONFIG.SAFE_Y, endPos.Z)
            
            -- BIG TP TO NEXT HOLE
            Root.CFrame = CFrame.new(targetHole)
            print("[APEX] MOVED TO CELL: " .. i .. "/" .. totalHoles)
            
            RunService.Heartbeat:Wait()
        end
    end
    
    -- Final arrival to exact Phantom location
    task.wait(2)
    Root.CFrame = targetCF
    print("[APEX] ARRIVED AT PHANTOM DESTINATION.")
    Internal.IsWarpping = false
end

-- // 4. PHANTOM STOP LOGIC //
local function StopPhantom()
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Internal.Ghost and Root then
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        if GhostRoot then
            -- 1. Get the safest hole near where the phantom currently is
            local targetPos = GhostRoot.Position
            local safeHoleCF = CFrame.new(GetNearestSafeHole(targetPos))
            
            -- 2. Clean up the ghost first so camera resets
            Internal.Ghost:Destroy()
            Internal.Ghost = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            -- 3. Execute the Segmented 2s TP
            task.spawn(function()
                SafeTeleportDelayed(safeHoleCF)
                Root.Anchored = false
            end)
        end
    end
end

-- // 5. RUNTIME LOGIC //
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
        -- Keep real body in nearest safe hole while phantom moves
        Root.CFrame = CFrame.new(GetNearestSafeHole(Root.Position))
        Root.Anchored = true
    elseif AETHER_CONFIG.ENABLED then
        Root.Anchored = false
        if Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            Root.CFrame += (Camera.CFrame.LookVector * AETHER_CONFIG.SPEED * dt * 0.1)
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
    Main.Size = UDim2.new(0, 320, 0, 200)
    Main.Position = UDim2.new(0.5, -160, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 180)

    local List = Instance.new("UIListLayout", Main)
    List.Padding = UDim.new(0, 10)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center
    List.VerticalAlignment = Enum.VerticalAlignment.Center

    local function CreateBtn(txt, call)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0, 280, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.Text = txt
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b)
        b.MouseButton1Down:Connect(function() call(b) end)
    end

    CreateBtn("PHANTOM: OFF", function(b)
        AETHER_CONFIG.PHANTOM = not AETHER_CONFIG.PHANTOM
        if AETHER_CONFIG.PHANTOM then
            local Char = LocalPlayer.Character
            Char.Archivable = true
            Internal.Ghost = Char:Clone()
            Internal.Ghost.Parent = Workspace
            for _, v in pairs(Internal.Ghost:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.5 v.CanCollide = false v.Anchored = true end
            end
            b.Text = "PHANTOM: ACTIVE"
        else
            b.Text = "STOPPING... (WAITING 2S)"
            StopPhantom()
            task.wait(2.5) -- Small delay to prevent spam
            b.Text = "PHANTOM: OFF"
        end
    end)
end

table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
