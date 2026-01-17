-- // CHRONOS SENTINEL V2.0 SUPREME //
-- AUTHOR: Gemini / Chronos Engine
-- STATUS: Persistence & UI Overhaul
-- FEATURES: Vector-Fling, Overclocked Egor, Auto-Respawn, Minimize Logic

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
    ANIM_MULTIPLIER = 22,
    FLING_STRENGTH = 999999,
    ACCENT_COLOR = Color3.fromRGB(0, 255, 180),
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 2. PERSISTENCE ENGINE (FIXES DEATH BUG) //
local function ReHook(NewChar)
    Character = NewChar
    Root = NewChar:WaitForChild("HumanoidRootPart")
    Humanoid = NewChar:WaitForChild("Humanoid")
    
    -- Cleanup physics if we died while flinging
    CHRONOS_SETTINGS.FLING_MODE = false
    CHRONOS_SETTINGS.EGOR_MODE = false
end

LocalPlayer.CharacterAdded:Connect(ReHook)

-- // 3. PHYSICS & RESET LOGIC //
local function ClearGlitch()
    Humanoid.WalkSpeed = 16
    local animator = Humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(1)
        end
    end
end

local function ManagePhysics(state)
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

-- // 4. STYLISH UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosSupreme") then CoreGui.ChronosSupreme:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosSupreme"
    Screen.ResetOnSpawn = false

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 160)
    Main.Position = UDim2.new(0.5, -110, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    local Glow = Instance.new("UIStroke", Main)
    Glow.Color = CHRONOS_SETTINGS.ACCENT_COLOR
    Glow.Thickness = 1.8

    -- Header (Drag Area)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS SUPREME V2.0"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 11
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -35, 0, 2)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = CHRONOS_SETTINGS.ACCENT_COLOR
    MinBtn.Font = Enum.Font.Code
    MinBtn.BackgroundTransparency = 1
    MinBtn.TextSize = 20

    -- Buttons
    local function CreateMenuBtn(text, pos, color)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(1, -20, 0, 45)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
        b.Text = text
        b.Font = Enum.Font.Code
        b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        b.TextSize = 13
        Instance.new("UICorner", b)
        return b
    end

    local EBtn = CreateMenuBtn("EGOR DRIVE: OFF", UDim2.new(0, 10, 0, 45))
    local FBtn = CreateMenuBtn("AERO-FLING: OFF", UDim2.new(0, 10, 0, 100))

    -- Interaction Logic
    EBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        if not CHRONOS_SETTINGS.EGOR_MODE then ClearGlitch() end
        EBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ACTIVE" or "EGOR DRIVE: OFF"
        EBtn.TextColor3 = CHRONOS_SETTINGS.EGOR_MODE and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(0.9, 0.9, 0.9)
    end)

    FBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.FLING_MODE = not CHRONOS_SETTINGS.FLING_MODE
        FBtn.Text = CHRONOS_SETTINGS.FLING_MODE and "FLING: LETHAL" or "AERO-FLING: OFF"
        FBtn.TextColor3 = CHRONOS_SETTINGS.FLING_MODE and Color3.fromRGB(255, 50, 50) or Color3.new(0.9, 0.9, 0.9)
        ManagePhysics(CHRONOS_SETTINGS.FLING_MODE)
    end)

    MinBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.UI_OPEN = not CHRONOS_SETTINGS.UI_OPEN
        EBtn.Visible = CHRONOS_SETTINGS.UI_OPEN
        FBtn.Visible = CHRONOS_SETTINGS.UI_OPEN
        Main:TweenSize(CHRONOS_SETTINGS.UI_OPEN and UDim2.new(0, 220, 0, 160) or UDim2.new(0, 220, 0, 35), "Out", "Quad", 0.3, true)
    end)

    -- Fixed Dragging
    Header.InputBegan:Connect(function(input)
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

    -- Global Bind (RightControl)
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
end

-- // 5. SUPREME RUNTIME //
RunService.Stepped:Connect(function()
    if not Root or not Humanoid then return end
    
    if CHRONOS_SETTINGS.EGOR_MODE and Humanoid.MoveDirection.Magnitude > 0 then
        Humanoid.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
        local tracks = Humanoid:GetPlayingAnimationTracks()
        for _, t in pairs(tracks) do
            if t.Name:lower():find("run") or t.Name:lower():find("walk") or t.Animation.AnimationId:find("run") then
                t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
            end
        end
    end

    if CHRONOS_SETTINGS.FLING_MODE then
        -- Stabilize Y velocity to prevent you from flying away
        Root.AssemblyLinearVelocity = Vector3.new(Root.AssemblyLinearVelocity.X, 0, Root.AssemblyLinearVelocity.Z)
        -- Keep upright
        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, math.rad(tick()*1500 % 360), 0)
    end
end)

BuildUI()
