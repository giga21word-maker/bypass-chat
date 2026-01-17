-- // CHRONOS SENTINEL V2.5 SUPREME //
-- AUTHOR: Gemini / Chronos Engine
-- STATUS: Egor Physics + Precision Drag Patch
-- FEATURES: Moon-Jump, Turbo-Climb, Vector-Fling, Auto-Respawn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- // 1. SUPREME CONFIGURATION //
local CHRONOS_SETTINGS = {
    EGOR_MODE = false,
    FLING_MODE = false,
    UI_OPEN = true,
    
    WALK_SPEED = 4,
    ANIM_MULTIPLIER = 25,
    FLING_STRENGTH = 999999,
    
    MOON_GRAVITY = 45,
    NORMAL_GRAVITY = 196.2,
    
    ACCENT_COLOR = Color3.fromRGB(0, 255, 180),
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragInput = nil,
    DragStart = nil,
    StartPos = nil
}

-- // 2. PERSISTENCE & RESET //
local function ReHook(NewChar)
    Character = NewChar
    Root = NewChar:WaitForChild("HumanoidRootPart")
    Humanoid = NewChar:WaitForChild("Humanoid")
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
end

LocalPlayer.CharacterAdded:Connect(ReHook)

local function FullReset()
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
    Humanoid.WalkSpeed = 16
    Humanoid.JumpPower = 50
    local animator = Humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(1)
        end
    end
end

local function ManageFling(state)
    if not Root then return end
    local spin = Root:FindFirstChild("ChronosSpin")
    local thrust = Root:FindFirstChild("ChronosThrust")
    
    if state then
        if not spin then
            spin = Instance.new("BodyAngularVelocity", Root)
            spin.Name = "ChronosSpin"
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
        end
        if not thrust then
            thrust = Instance.new("BodyThrust", Root)
            thrust.Name = "ChronosThrust"
            thrust.Force = Vector3.new(CHRONOS_SETTINGS.FLING_STRENGTH, 0, CHRONOS_SETTINGS.FLING_STRENGTH)
        end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if spin then spin:Destroy() end
        if thrust then thrust:Destroy() end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
    end
end

-- // 3. STYLISH UI //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosSupremeV2") then CoreGui.ChronosSupremeV2:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosSupremeV2"
    Screen.ResetOnSpawn = false

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 165)
    Main.Position = UDim2.new(0.5, -110, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    local Glow = Instance.new("UIStroke", Main)
    Glow.Color = CHRONOS_SETTINGS.ACCENT_COLOR
    Glow.Thickness = 2

    -- Header (Optimized Drag)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS V2.5"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 11
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 0.2, 0.2)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextSize = 16

    -- Buttons
    local function CreateBtn(text, pos)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(1, -20, 0, 45)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        b.Text = text
        b.Font = Enum.Font.Code
        b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        b.TextSize = 13
        Instance.new("UICorner", b)
        return b
    end

    local EBtn = CreateBtn("EGOR DRIVE: OFF", UDim2.new(0, 10, 0, 45))
    local FBtn = CreateBtn("AERO-FLING: OFF", UDim2.new(0, 10, 0, 105))

    -- Interaction Logic
    EBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        if not CHRONOS_SETTINGS.EGOR_MODE then FullReset() end
        EBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ON" or "EGOR DRIVE: OFF"
        EBtn.TextColor3 = CHRONOS_SETTINGS.EGOR_MODE and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)

    FBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.FLING_MODE = not CHRONOS_SETTINGS.FLING_MODE
        FBtn.Text = CHRONOS_SETTINGS.FLING_MODE and "FLING: ACTIVE" or "AERO-FLING: OFF"
        FBtn.TextColor3 = CHRONOS_SETTINGS.FLING_MODE and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
        ManageFling(CHRONOS_SETTINGS.FLING_MODE)
    end)

    CloseBtn.MouseButton1Down:Connect(function() Screen:Destroy() CHRONOS_SETTINGS.ACTIVE = false end)

    -- // PRECISION DRAG SYSTEM //
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Internal.Dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if Internal.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)

    -- RightControl Toggle
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
end

-- // 4. SUPREME RUNTIME //
RunService.Heartbeat:Connect(function()
    if not Root or not Humanoid or not CHRONOS_SETTINGS.ACTIVE then return end
    
    -- EGOR PHYSICS & ANIMATION
    if CHRONOS_SETTINGS.EGOR_MODE then
        workspace.Gravity = CHRONOS_SETTINGS.MOON_GRAVITY
        
        -- Handle Walk/Run
        if Humanoid.MoveDirection.Magnitude > 0 then
            Humanoid.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
            local tracks = Humanoid:GetPlayingAnimationTracks()
            for _, t in pairs(tracks) do
                if t.Name:lower():find("run") or t.Name:lower():find("walk") or t.Animation.AnimationId:find("run") then
                    t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
                end
            end
        end
        
        -- Handle Ladders
        if Humanoid:GetState() == Enum.HumanoidStateType.Climbing then
            Humanoid.WalkSpeed = 2 -- Slow climb speed
            local tracks = Humanoid:GetPlayingAnimationTracks()
            for _, t in pairs(tracks) do
                if t.Name:lower():find("climb") then
                    t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER * 1.5)
                end
            end
        end
    end

    -- FLING STABILIZATION
    if CHRONOS_SETTINGS.FLING_MODE then
        Root.AssemblyLinearVelocity = Vector3.new(Root.AssemblyLinearVelocity.X, 0, Root.AssemblyLinearVelocity.Z)
        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, math.rad(tick()*1800 % 360), 0)
    end
end)

BuildUI()
