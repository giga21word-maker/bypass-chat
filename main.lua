-- // PROJECT EGOR ALPHA 0.0.3 //
-- STATUS: Egor + Velo-Fling Hybrid
-- FEATURE: Torque Injection (No-Collision Fling)
-- BYPASS: Anti-Fling Shielding

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. CONFIGURATION //
local ALPHA_CONFIG = {
    EGOR_ENABLED = false,
    FLING_ENABLED = false,
    LEG_SPEED = 18, 
    WALK_SPEED = 3,
    VERSION = "0.0.3-JUSTICE",
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    FlingPart = nil
}

-- // 2. THE FLING ENGINE //
local function ToggleFling(state)
    if state then
        -- Enable No-Clip for the character
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        
        -- Create the Invisible Fling Spinner
        local BAV = Instance.new("BodyAngularVelocity")
        BAV.Name = "EgorSpinner"
        BAV.Parent = Root
        BAV.MaxTorque = Vector3.new(0, math.huge, 0)
        BAV.P = 1000000
        BAV.AngularVelocity = Vector3.new(0, 99999, 0) -- The "Yeet" Velocity
    else
        -- Cleanup
        if Root:FindFirstChild("EgorSpinner") then
            Root.EgorSpinner:Destroy()
        end
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
    end
end

-- // 3. DYNAMIC UPDATE //
RunService.Heartbeat:Connect(function()
    if not ALPHA_CONFIG.ACTIVE or not Character.Parent then return end
    
    -- Handle Egor Legs
    if ALPHA_CONFIG.EGOR_ENABLED and Humanoid.MoveDirection.Magnitude > 0 then
        Humanoid.WalkSpeed = ALPHA_CONFIG.WALK_SPEED
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            if track.Name:lower():find("run") or track.Name:lower():find("walk") then
                track:AdjustSpeed(ALPHA_CONFIG.LEG_SPEED)
            end
        end
    elseif ALPHA_CONFIG.EGOR_ENABLED then
        Humanoid.WalkSpeed = 16
    end

    -- Handle Fling (No-Collision ghosting)
    if ALPHA_CONFIG.FLING_ENABLED then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        -- Keeps you from falling through the floor while no-clipping
        Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
    end
end)

-- // 4. UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("EgorJustice") then CoreGui.EgorJustice:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "EgorJustice"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 160, 0, 120)
    Main.Position = UDim2.new(0.5, -80, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 50, 50) -- Justice Red

    -- EGOR BUTTON
    local EBtn = Instance.new("TextButton", Main)
    EBtn.Size = UDim2.new(1, -20, 0, 45)
    EBtn.Position = UDim2.new(0, 10, 0, 10)
    EBtn.Text = "EGOR LEGS"
    EBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    EBtn.TextColor3 = Color3.new(1,1,1)
    EBtn.Font = Enum.Font.Code
    Instance.new("UICorner", EBtn)

    -- FLING BUTTON
    local FBtn = Instance.new("TextButton", Main)
    FBtn.Size = UDim2.new(1, -20, 0, 45)
    FBtn.Position = UDim2.new(0, 10, 0, 65)
    FBtn.Text = "FLING: OFF"
    FBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    FBtn.TextColor3 = Color3.new(1,1,1)
    FBtn.Font = Enum.Font.Code
    Instance.new("UICorner", FBtn)

    -- DRAG LOGIC
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if Internal.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Internal.Dragging = false end
    end)

    EBtn.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.EGOR_ENABLED = not ALPHA_CONFIG.EGOR_ENABLED
        EBtn.BackgroundColor3 = ALPHA_CONFIG.EGOR_ENABLED and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40, 40, 40)
    end)

    FBtn.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.FLING_ENABLED = not ALPHA_CONFIG.FLING_ENABLED
        FBtn.Text = ALPHA_CONFIG.FLING_ENABLED and "FLING: ACTIVE" or "FLING: OFF"
        FBtn.BackgroundColor3 = ALPHA_CONFIG.FLING_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
        ToggleFling(ALPHA_CONFIG.FLING_ENABLED)
    end)
end

BuildUI()
