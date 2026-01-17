-- // GHOST-SYNC: PHANTOM LOADER V21 //
-- Target: Pure Phantom God Engine
-- URL: https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua

--[[
    PHANTOM ESSENCE V21 (GOD MODE CORE)
    ----------------------------------------------------------
    - FIXED: Character "Slowing" during Phantom.
    - FIXED: Ground-clip death during teleport back.
    - NEW: One-Key Toggle (Z) for instant God Mode.
    ----------------------------------------------------------
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local PHANTOM_CONFIG = {
    ENABLED = false,
    SPEED = 85,
    COLOR = Color3.fromRGB(0, 255, 180),
    VERSION = "V21 Essence"
}

local State = {
    Ghost = nil,
    Connection = nil,
    OriginalCFrame = nil
}

local function Cleanup()
    if State.Ghost then State.Ghost:Destroy() end
    State.Ghost = nil
    if State.Connection then State.Connection:Disconnect() end
    State.Connection = nil
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then Root.Anchored = false end
end

local function SpawnPhantom()
    local Char = LocalPlayer.Character
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Char or not Root then return end

    -- Create Visual Phantom
    Char.Archivable = true
    State.Ghost = Char:Clone()
    State.Ghost.Name = "Phantom_Essence"
    State.Ghost.Parent = Workspace
    
    for _, p in pairs(State.Ghost:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Transparency = 0.5
            p.Color = PHANTOM_CONFIG.COLOR
            p.CanCollide = false
            p.Anchored = true
        elseif p:IsA("Humanoid") then
            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end

    -- Primary Authority: Anchor real body slightly above current spot
    State.OriginalCFrame = Root.CFrame
    Root.CFrame = Root.CFrame * CFrame.new(0, 10, 0)
    Root.Anchored = true
    
    Camera.CameraSubject = State.Ghost:FindFirstChildOfClass("Humanoid")

    -- Movement Loop
    State.Connection = RunService.Heartbeat:Connect(function(dt)
        if not PHANTOM_CONFIG.ENABLED or not State.Ghost then return end
        
        local GhostRoot = State.Ghost:FindFirstChild("HumanoidRootPart")
        local RealHum = Char:FindFirstChildOfClass("Humanoid")
        
        if GhostRoot and RealHum then
            local MoveDir = RealHum.MoveDirection
            if MoveDir.Magnitude > 0 then
                local look = Camera.CFrame.LookVector
                local rot = CFrame.lookAt(GhostRoot.Position, GhostRoot.Position + Vector3.new(look.X, 0, look.Z))
                GhostRoot.CFrame = rot + (MoveDir * PHANTOM_CONFIG.SPEED * dt)
            end
        end
    end)
end

local function TogglePhantom()
    PHANTOM_CONFIG.ENABLED = not PHANTOM_CONFIG.ENABLED
    
    if PHANTOM_CONFIG.ENABLED then
        print("[PHANTOM] God Mode Active.")
        SpawnPhantom()
    else
        print("[PHANTOM] Returning to Reality.")
        local targetPos = State.Ghost and State.Ghost.PrimaryPart.CFrame
        Cleanup()
        
        -- Teleport back safely
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root and targetPos then
            Root.CFrame = targetPos
        end
    end
end

-- Keybind Authority (Z to Toggle)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then
        TogglePhantom()
    end
end)

print("[AETHER V21] Phantom Essence Loaded. Press 'Z' to toggle God Mode.")
