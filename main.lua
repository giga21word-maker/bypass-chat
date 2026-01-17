-- // GHOST-SYNC: TSUNAMI-SAFE V22 //
-- Optimized for: Hole-Snapping / Safe-Node Stutter
-- URL: https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua

--[[
    AETHER V22: TSUNAMI-SAFE AUTHORITY
    ----------------------------------------------------------
    - NEW: Dug-Hole Snap. Automatically finds the nearest X84, Y-3 hole.
    - FIXED: TP Stutter. Now "Hole-Hops" during transit to stay safe.
    - FIXED: Movement Drag. Removed Physics-velocity for absolute CFraming.
    ----------------------------------------------------------
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local CONFIG = {
    ENABLED = false,
    PHANTOM = false,
    SPEED = 85,
    HOLE_X_OFFSET = 282, -- Start point
    HOLE_INTERVAL = 84,  -- Distance between holes (282-198)
    SAFE_Y = -3,
    VERSION = "V22 Safe-Hole"
}

local Internal = {
    Ghost = nil,
    Loop = nil,
    IsWarpping = false
}

-- // 1. SAFE HOLE CALCULATION //
local function GetNearestSafeHole(currentPos)
    -- Logic: Find the nearest hole on the X84 grid at Y-3
    local relativeX = currentPos.X - CONFIG.HOLE_X_OFFSET
    local snapX = math.round(relativeX / CONFIG.HOLE_INTERVAL) * CONFIG.HOLE_INTERVAL
    local finalX = snapX + CONFIG.HOLE_X_OFFSET
    
    return Vector3.new(finalX, CONFIG.SAFE_Y, currentPos.Z)
end

-- // 2. SMART STUTTER (HOLE-HOPPING) //
local function SafeStutterTP(targetCF)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsWarpping then return end
    
    Internal.IsWarpping = true
    local startPos = Root.Position
    local endPos = targetCF.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 30 then
        local steps = math.clamp(math.floor(dist/20), 5, 15)
        for i = 1, steps do
            local alpha = i/steps
            local lerpPos = startPos:Lerp(endPos, alpha)
            
            -- STUTTER FIX: Instead of random jitter, snap to a safe hole during the hop
            local safeStep = GetNearestSafeHole(lerpPos)
            Root.CFrame = CFrame.new(safeStep)
            
            task.wait(0.1) -- Small delay to ensure tsunami check passes
        end
    end
    
    Root.CFrame = targetCF
    Internal.IsWarpping = false
end

-- // 3. PHANTOM CORE //
local function CleanupGhost()
    if Internal.Ghost then Internal.Ghost:Destroy() end
    Internal.Ghost = nil
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then Root.Anchored = false end
end

local function HandlePhantom(dt)
    if not CONFIG.PHANTOM or not Internal.Ghost then return end
    local GhostRoot = Internal.Ghost:FindFirstChild("HumanoidRootPart")
    local RealChar = LocalPlayer.Character
    
    if GhostRoot and RealChar then
        Camera.CameraSubject = Internal.Ghost:FindFirstChildOfClass("Humanoid")
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        
        if MoveDir.Magnitude > 0 then
            local look = Camera.CFrame.LookVector
            local rot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
            -- Direct CFrame translation to prevent slowing
            GhostRoot.CFrame = rot + (MoveDir * CONFIG.SPEED * dt)
        end
    end
end

-- // 4. COMMAND FUNCTIONS //
local function ForceDug()
    local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local safeSpot = GetNearestSafeHole(Root.Position)
        SafeStutterTP(CFrame.new(safeSpot))
        print("[AETHER] Snapped to nearest Safe Hole: " .. tostring(safeSpot))
    end
end

local function TogglePhantom()
    CONFIG.PHANTOM = not CONFIG.PHANTOM
    if CONFIG.PHANTOM then
        local Char = LocalPlayer.Character
        Char.Archivable = true
        Internal.Ghost = Char:Clone()
        Internal.Ghost.Parent = Workspace
        for _, v in pairs(Internal.Ghost:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0.5 v.CanCollide = false v.Anchored = true end
        end
        -- Lock real body in a safe hole while phantom is out
        local Root = Char:FindFirstChild("HumanoidRootPart")
        Root.CFrame = CFrame.new(GetNearestSafeHole(Root.Position))
        Root.Anchored = true
    else
        local target = Internal.Ghost.PrimaryPart.CFrame
        CleanupGhost()
        SafeStutterTP(target)
    end
end

-- // 5. RUNTIME //
RunService.Heartbeat:Connect(function(dt)
    if CONFIG.PHANTOM then HandlePhantom(dt) end
end)

-- Keybinds: Z = Phantom, X = Force Dug Hole
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then TogglePhantom()
    elseif input.KeyCode == Enum.KeyCode.X then ForceDug() end
end)

print("[AETHER V22] Safe-Node Authority Loaded. Z = Phantom, X = Dug Snap.")
