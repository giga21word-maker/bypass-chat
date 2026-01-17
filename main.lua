-- // OMNI-SOVEREIGN V24.0 //
-- CORE: Advanced Physics Masking & Proxy Interaction
-- SAFETY: Sentinel Tsunami Sensor + Void-Shield
-- BYPASS: Jitter-Interpolation + Velocity Spoofing

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // 1. AUTHORITY CONFIGURATION //
local SOVEREIGN_CONFIG = {
    ENABLED = false,
    PHANTOM = false,
    SPEED = 92, -- Optimized for bypass thresholds
    VERSION = "V24.0.0 - Omni-Sovereign",
    HOLE_X_OFFSET = 282,
    HOLE_INTERVAL = 84,
    SAFE_Y = -3.2, -- Sub-floor offset for max safety
    TSUNAMI_ACTIVE = false,
    ACTIVE = true
}

local Internal = {
    Ghost = nil,
    IsWarpping = false,
    Connections = {},
    Dragging = false,
    DragOffset = Vector2.new(0, 0),
    CurrentFrame = nil,
    HeldItem = nil
}

-- // 2. SMART MATH: VALIDATED GRID //
local function GetValidatedHole(pos)
    local relX = pos.X - SOVEREIGN_CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relX / SOVEREIGN_CONFIG.HOLE_INTERVAL) * SOVEREIGN_CONFIG.HOLE_INTERVAL
    local targetX = snapX + SOVEREIGN_CONFIG.HOLE_X_OFFSET
    
    -- Ground Validation: Raycast to ensure we aren't snapping to empty void
    local rayParam = RaycastParams.new()
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    rayParam.FilterDescendantsInstances = {LocalPlayer.Character, Internal.Ghost}
    
    local ray = Workspace:Raycast(Vector3.new(targetX, 50, pos.Z), Vector3.new(0, -100, 0), rayParam)
    local finalY = ray and (ray.Position.Y - 2.8) or SOVEREIGN_CONFIG.SAFE_Y
    
    return Vector3.new(targetX, finalY, pos.Z)
end

-- // 3. BYPASS ENGINE: JITTER-INTERPOLATION //
local function SovereignTeleport(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    local distance = (startPos - endPos).Magnitude
    
    -- High-End Bypass: Uses small bursts and physics resets
    if distance > 10 then
        local steps = math.clamp(math.floor(distance / 15), 5, 40)
        for i = 1, steps do
            if not SOVEREIGN_CONFIG.ACTIVE then break end
            local alpha = i / steps
            local nextHole = GetValidatedHole(startPos:Lerp(endPos, alpha))
            
            -- Jitter Spoof: Randomize coordinates by 0.05 to mimic real movement noise
            local jitter = Vector3.new(math.random(-5,5)/100, 0, math.random(-5,5)/100)
            Root.CFrame = CFrame.new(nextHole + jitter)
            
            -- Physics Masking: Tell the server we are falling/moving naturally
            Root.AssemblyLinearVelocity = Vector3.new(0, -0.5, 0)
            
            if i % 3 == 0 then task.wait(0.04) end -- Anti-Cheat buffer
            RunService.Heartbeat:Wait()
        end
    end
    
    -- Final Handshake: Wake up physics to prevent "Invincibility Freeze"
    Root.CFrame = targetCF
    task.wait(0.1)
    Root.Anchored = false
    Root.AssemblyLinearVelocity = Vector3.new(0, 2, 0)
    Internal.IsWarpping = false
end

-- // 4. INTERACTION PROXY (PROXIMITY SYNC) //
-- This allows your Ghost to trigger "E" prompts on Brain Rot items
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if SOVEREIGN_CONFIG.PHANTOM and Internal.Ghost then
        local dist = (Internal.Ghost.PrimaryPart.Position - prompt.Parent.WorldPosition).Magnitude
        if dist < (prompt.MaxActivationDistance + 5) then
            -- Force interaction if the ghost is close enough
            prompt:InputHoldBegin()
        end
    end
end)

-- // 5. TSUNAMI SENTINEL (SENSORS) //
task.spawn(function()
    while SOVEREIGN_CONFIG.ACTIVE do
        -- Scan for parts named "Water" or "Wave" or "KillPart" with high Y-values
        local waveFound = false
        for _, v in pairs(Workspace:GetChildren()) do
            if (v.Name:lower():find("water") or v.Name:lower():find("wave")) and v:IsA("BasePart") then
                if v.Position.Y > 10 then waveFound = true break end
            end
        end
        SOVEREIGN_CONFIG.TSUNAMI_ACTIVE = waveFound
        task.wait(1)
    end
end)

-- // 6. GHOST CORE //
local function TogglePhantom(state)
    local Char = LocalPlayer.Character
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    if state then
        -- ENTER GHOST MODE
        Char.Archivable = true
        Internal.Ghost = Char:Clone()
        Internal.Ghost.Name = "Omni_Ghost"
        Internal.Ghost.Parent = Workspace
        
        for _, v in pairs(Internal.Ghost:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0.5
                v.CanCollide = false
                v.Anchored = true
                v.Color = Color3.fromRGB(0, 255, 180)
            end
        end
        
        -- Lock real body in validated safe hole
        Root.CFrame = CFrame.new(GetValidatedHole(Root.Position))
        Root.Anchored = true
    else
        -- EXIT GHOST MODE
        if SOVEREIGN_CONFIG.TSUNAMI_ACTIVE then
            warn("[SENTINEL] TSUNAMI DETECTED. RETURN BLOCKED FOR SAFETY.")
            return false
        end

        local finalCF = Internal.Ghost.PrimaryPart.CFrame
        Internal.Ghost:Destroy()
        Internal.Ghost = nil
        Camera.CameraSubject = Char:FindFirstChildOfClass("Humanoid")
        
        task.spawn(function()
            SovereignTeleport(finalCF)
        end)
    end
    return true
end

-- // 7. RUNTIME AUTHORITY //
local function ExecuteLogic(dt)
    if not SOVEREIGN_CONFIG.ACTIVE then return end
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Root or not Hum then return end

    if SOVEREIGN_CONFIG.PHANTOM and Internal.Ghost then
        Camera.CameraSubject = Internal.Ghost:FindFirstChildOfClass("Humanoid")
        local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
        
        if GhostRoot then
            local MoveDir = Hum.MoveDirection
            if MoveDir.Magnitude > 0 then
                local look = Camera.CFrame.LookVector
                local moveVec = (Vector3.new(look.X, 0, look.Z).Unit * MoveDir.Z) + (Camera.CFrame.RightVector * MoveDir.X)
                GhostRoot.CFrame = GhostRoot.CFrame + (moveVec * SOVEREIGN_CONFIG.SPEED * dt)
            end
        end
        -- Hard-Lock real body safely
        Root.CFrame = CFrame.new(GetValidatedHole(Root.Position))
        Root.Anchored = true
    end
end

-- // 8. ADVANCED UI //
local function BuildUI()
    if CoreGui:FindFirstChild("OmniApex") then CoreGui.OmniApex:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "OmniApex"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 240, 0, 140)
    Main.Position = UDim2.new(0.5, -120, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Main)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(0, 255, 180)
    Stroke.Thickness = 2

    local StatusLabel = Instance.new("TextLabel", Main)
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Text = "SYSTEM: READY"
    StatusLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 10
    StatusLabel.BackgroundTransparency = 1

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0, 200, 0, 60)
    B.Position = UDim2.new(0, 20, 0, 40)
    B.Text = "ACTIVATE PHANTOM"
    B.Font = Enum.Font.GothamBlack
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", B)

    -- Dynamic UI Updates
    RunService.Heartbeat:Connect(function()
        if SOVEREIGN_CONFIG.TSUNAMI_ACTIVE then
            StatusLabel.Text = "WARNING: TSUNAMI DETECTED"
            StatusLabel.TextColor3 = Color3.new(1, 0, 0)
            Stroke.Color = Color3.new(1, 0, 0)
        else
            StatusLabel.Text = SOVEREIGN_CONFIG.PHANTOM and "STATUS: GHOST ACTIVE" or "STATUS: STANDBY"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
            Stroke.Color = Color3.fromRGB(0, 255, 180)
        end
    end)

    B.MouseButton1Down:Connect(function()
        if not SOVEREIGN_CONFIG.PHANTOM then
            if TogglePhantom(true) then
                SOVEREIGN_CONFIG.PHANTOM = true
                B.Text = "DEACTIVATE"
            end
        else
            if TogglePhantom(false) then
                SOVEREIGN_CONFIG.PHANTOM = false
                B.Text = "ACTIVATE PHANTOM"
            end
        end
    end)
end

table.insert(Internal.Connections, RunService.Heartbeat:Connect(ExecuteLogic))
BuildUI()
