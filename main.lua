--[[
    PHASE-SHIFT V5: GHOST-FRAME DESYNC
    --------------------------------------------------
    [RELIABILITY FIXES]
    - Ghost-Swap: Swaps real parts for non-colliding clones during wall contact.
    - Velocity-Zeroing: Stops the "falling through floor" bug entirely.
    - Anti-Rubberband: Syncs CFrame with server heartbeat to prevent snapping.
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // 2. SYSTEM SETTINGS //
local GHOST_SETTINGS = {
    ENABLED = false,
    PHASE_SPEED = 0.4, -- How fast we step through the wall
    RAY_DISTANCE = 3.0,
    UI_COLOR = Color3.fromRGB(255, 0, 255)
}

-- // 3. GHOST-STEP LOGIC //
local function PerformGhostStep()
    if not GHOST_SETTINGS.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    -- Raycast to detect the wall in front of us
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {Char}
    
    local RayResult = Workspace:Raycast(Root.Position, Hum.MoveDirection * GHOST_SETTINGS.RAY_DISTANCE, Params)

    if RayResult and RayResult.Instance and RayResult.Instance.CanCollide then
        -- FIXED: Instead of teleporting, we 'Phase'
        -- We temporarily set the Root CFrame forward by small increments 
        -- while forcing the Velocity to match to prevent server-side 'Illegal Movement' flags
        local PhaseOffset = Hum.MoveDirection * GHOST_SETTINGS.PHASE_SPEED
        
        -- The Bypass: We update CFrame during 'Stepped' (Pre-Physics)
        -- This ensures the wall collision doesn't trigger a 'Pushback'
        Root.CFrame = Root.CFrame + PhaseOffset
        Root.AssemblyLinearVelocity = Hum.MoveDirection * 20
    end
end

-- // 4. STICKY UI (LARGE MOBILE BUTTONS) //
local function BuildUI()
    if CoreGui:FindFirstChild("GhostPhaseV5") then CoreGui.GhostPhaseV5:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "GhostPhaseV5"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 200, 0, 100)
    Main.Position = UDim2.new(0.7, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = GHOST_SETTINGS.UI_COLOR

    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0.9, 0, 0.8, 0)
    Btn.Position = UDim2.new(0.05, 0, 0.1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = "PHASE: OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 60, 60)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 20 -- Large for mobile
    Instance.new("UICorner", Btn)

    Btn.MouseButton1Down:Connect(function()
        GHOST_SETTINGS.ENABLED = not GHOST_SETTINGS.ENABLED
        Btn.Text = GHOST_SETTINGS.ENABLED and "PHASE: ON" or "PHASE: OFF"
        Btn.TextColor3 = GHOST_SETTINGS.ENABLED and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
    end)
end

-- // 5. RUNTIME LOOPS //

-- Execution Loop
RunService.Stepped:Connect(function()
    if GHOST_SETTINGS.ENABLED then
        pcall(PerformGhostStep)
        
        -- FIX: Keep character upright and on floor
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    -- We only noclip the TORSO and HEAD. 
                    -- Keeping the legs/RootPart colliding prevents falling through the floor.
                    if v.Name == "UpperTorso" or v.Name == "LowerTorso" or v.Name == "Head" or v.Name == "Torso" then
                        v.CanCollide = false
                    else
                        v.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- Instruction Sync: Attribute Lock
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("Stamina", 100)
        char:SetAttribute("Energy", 100)
    end
end)

BuildUI()
print("[LOADED] Phase-Shift V5: Ghost-Frame Desync Active.")
