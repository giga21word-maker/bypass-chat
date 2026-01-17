-- // CHRONOS SENTINEL V3.1 PREMIUM //
-- STATUS: Walking-Fling Fix + Jump Scaler + Precision Drag
-- FEATURES: Moon-Jump, Turbo-Climb, Mobile-Fling, Respawn Support

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- // 1. ULTRA CONFIGURATION //
local CHRONOS_SETTINGS = {
    EGOR_MODE = false,
    FLING_MODE = false,
    UI_OPEN = true,
    MINIMIZED = false,
    
    WALK_SPEED = 4,
    ANIM_MULTIPLIER = 25,
    FLING_STRENGTH = 999999,
    
    MOON_GRAVITY = 45,
    NORMAL_GRAVITY = 196.2,
    EGOR_JUMP_POWER = 15, -- Fixed low power for moon jumps
    
    ACCENT_COLOR = Color3.fromRGB(0, 255, 180),
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // LOADSTRING INJECTION (PREVIOUSLY REQUESTED) //
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua"))()
end)

-- // 2. CHARACTER HOOKS //
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

-- // 3. STABILIZED FLING ENGINE (FIXED MOVEMENT) //
local function ManageFling(state)
    if not Root then return end
    local spin = Root:FindFirstChild("UltraSpin")
    
    if state then
        if not spin then
            spin = Instance.new("BodyAngularVelocity", Root)
            spin.Name = "UltraSpin"
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            -- High velocity spin that doesn't interfere with LinearVelocity (walking)
            spin.AngularVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
        end
        -- Disable collisions to slip into other players' hitboxes
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if spin then spin:Destroy() end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        Root.AssemblyAngularVelocity = Vector3.zero
    end
end

-- // 4. ADVANCED GUI //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosUltra") then CoreGui.ChronosUltra:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosUltra"

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 160)
    Main.Position = UDim2.new(0.5, -110, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = CHRONOS_SETTINGS.ACCENT_COLOR

    -- Header (Drag Handle)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS PREMIUM V3.1"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -65, 0, 2)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.BackgroundTransparency = 1
    MinBtn.TextSize = 20

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
    CloseBtn.BackgroundTransparency = 1

    -- Buttons Container
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, 0, 1, -35)
    Content.Position = UDim2.new(0, 0, 0, 35)
    Content.BackgroundTransparency = 1

    local EBtn = Instance.new("TextButton", Content)
    EBtn.Size = UDim2.new(1, -20, 0, 45)
    EBtn.Position = UDim2.new(0, 10, 0, 10)
    EBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    EBtn.Text = "EGOR DRIVE: OFF"
    EBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", EBtn)

    local FBtn = Instance.new("TextButton", Content)
    FBtn.Size = UDim2.new(1, -20, 0, 45)
    FBtn.Position = UDim2.new(0, 10, 0, 65)
    FBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FBtn.Text = "MOBILE FLING: OFF"
    FBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", FBtn)

    -- // INTERACTION //
    EBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        if not CHRONOS_SETTINGS.EGOR_MODE then FullReset() end
        EBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ON" or "EGOR DRIVE: OFF"
        EBtn.TextColor3 = CHRONOS_SETTINGS.EGOR_MODE and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)

    FBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.FLING_MODE = not CHRONOS_SETTINGS.FLING_MODE
        FBtn.Text = CHRONOS_SETTINGS.FLING_MODE and "FLING: ACTIVE" or "MOBILE FLING: OFF"
        FBtn.TextColor3 = CHRONOS_SETTINGS.FLING_MODE and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 1)
        ManageFling(CHRONOS_SETTINGS.FLING_MODE)
    end)

    MinBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.MINIMIZED = not CHRONOS_SETTINGS.MINIMIZED
        Content.Visible = not CHRONOS_SETTINGS.MINIMIZED
        Main:TweenSize(CHRONOS_SETTINGS.MINIMIZED and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 160), "Out", "Quart", 0.3, true)
    end)

    CloseBtn.MouseButton1Down:Connect(function() Screen:Destroy() CHRONOS_SETTINGS.ACTIVE = false end)

    -- // PRECISION DRAG //
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
end

-- // 5. RUNTIME //
RunService.Heartbeat:Connect(function()
    if not Root or not Humanoid or not CHRONOS_SETTINGS.ACTIVE then return end
    
    if CHRONOS_SETTINGS.EGOR_MODE then
        workspace.Gravity = CHRONOS_SETTINGS.MOON_GRAVITY
        Humanoid.JumpPower = CHRONOS_SETTINGS.EGOR_JUMP_POWER -- Fix for high jumping
        
        if Humanoid.MoveDirection.Magnitude > 0 then
            Humanoid.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
            for _, t in pairs(Humanoid:GetPlayingAnimationTracks()) do
                if t.Name:lower():find("run") or t.Name:lower():find("walk") then
                    t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
                end
            end
        end
        if Humanoid:GetState() == Enum.HumanoidStateType.Climbing then
            Humanoid.WalkSpeed = 2
            for _, t in pairs(Humanoid:GetPlayingAnimationTracks()) do
                if t.Name:lower():find("climb") then t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER) end
            end
        end
    end

    if CHRONOS_SETTINGS.FLING_MODE then
        -- Spin that doesn't anchor LinearVelocity (Fixed Walking)
        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, math.rad(tick()*2500 % 360), 0)
    end
end)

BuildUI()
