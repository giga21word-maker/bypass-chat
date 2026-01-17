-- // CHRONOS SENTINEL V3.2 ETERNAL //
-- STATUS: Instant-Boot Fix + Rainbow Accent + Jump Fix
-- FEATURES: Moon-Jump, Turbo-Climb, Mobile-Fling, Chat-Bypass

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

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
    EGOR_JUMP_POWER = 18, 
    
    ACCENT_COLOR = Color3.fromRGB(0, 255, 180),
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // LOADSTRING INJECTION //
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua"))()
end)

-- // 2. CORE UTILITIES //
local function GetCharacter()
    local Char = LocalPlayer.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    return Char, Hum, Root
end

local function FullReset()
    local _, Hum, _ = GetCharacter()
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
    if Hum then
        Hum.WalkSpeed = 16
        Hum.JumpPower = 50
        local animator = Hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1)
            end
        end
    end
end

-- // 3. STABILIZED FLING ENGINE //
local function ManageFling(state)
    local Char, _, Root = GetCharacter()
    if not Root then return end
    
    local spin = Root:FindFirstChild("UltraSpin")
    if state then
        if not spin then
            spin = Instance.new("BodyAngularVelocity", Root)
            spin.Name = "UltraSpin"
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
        end
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if spin then spin:Destroy() end
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- // 4. ADVANCED GUI //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosUltra") then CoreGui.ChronosUltra:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosUltra"
    Screen.ResetOnSpawn = false

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 160)
    Main.Position = UDim2.new(0.5, -110, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main)
    
    local Glow = Instance.new("UIStroke", Main)
    Glow.Color = CHRONOS_SETTINGS.ACCENT_COLOR
    Glow.Thickness = 2

    -- Header (Drag Handle)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS ETERNAL"
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
    EBtn.Font = Enum.Font.Code
    Instance.new("UICorner", EBtn)

    local FBtn = Instance.new("TextButton", Content)
    FBtn.Size = UDim2.new(1, -20, 0, 45)
    FBtn.Position = UDim2.new(0, 10, 0, 65)
    FBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FBtn.Text = "MOBILE FLING: OFF"
    FBtn.TextColor3 = Color3.new(1, 1, 1)
    FBtn.Font = Enum.Font.Code
    Instance.new("UICorner", FBtn)

    -- Logic
    EBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        if not CHRONOS_SETTINGS.EGOR_MODE then FullReset() end
        EBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ON" or "EGOR DRIVE: OFF"
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

    -- Dragging Logic
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

    -- Rainbow Effect Loop
    task.spawn(function()
        while CHRONOS_SETTINGS.ACTIVE do
            if CHRONOS_SETTINGS.EGOR_MODE then
                local hue = tick() % 5 / 5
                Glow.Color = Color3.fromHSV(hue, 1, 1)
                EBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
            else
                Glow.Color = CHRONOS_SETTINGS.ACCENT_COLOR
                EBtn.TextColor3 = Color3.new(1,1,1)
            end
            task.wait()
        end
    end)
end

-- // 5. RUNTIME //
RunService.Heartbeat:Connect(function()
    if not CHRONOS_SETTINGS.ACTIVE then return end
    local _, Hum, Root = GetCharacter()
    if not Hum or not Root then return end
    
    if CHRONOS_SETTINGS.EGOR_MODE then
        workspace.Gravity = CHRONOS_SETTINGS.MOON_GRAVITY
        Hum.JumpPower = CHRONOS_SETTINGS.EGOR_JUMP_POWER
        
        if Hum.MoveDirection.Magnitude > 0 then
            Hum.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
            for _, t in pairs(Hum:GetPlayingAnimationTracks()) do
                if t.Name:lower():find("run") or t.Name:lower():find("walk") then
                    t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
                end
            end
        end
        if Hum:GetState() == Enum.HumanoidStateType.Climbing then
            Hum.WalkSpeed = 2
            for _, t in pairs(Hum:GetPlayingAnimationTracks()) do
                if t.Name:lower():find("climb") then t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER) end
            end
        end
    end

    if CHRONOS_SETTINGS.FLING_MODE then
        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, math.rad(tick()*3000 % 360), 0)
    end
end)

BuildUI()
