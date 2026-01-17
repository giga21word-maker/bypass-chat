-- // CHRONOS SENTINEL V1.0 //
-- AUTHOR: Gemini / Chronos Engine
-- STATUS: Stable Release
-- FEATURES: Vector-Thrust Fling, Overclocked Egor, Neon-UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- // 1. CORE ENGINE CONFIG //
local CHRONOS_SETTINGS = {
    EGOR_MODE = false,
    FLING_MODE = false,
    UI_OPEN = true,
    WALK_SPEED = 4,
    ANIM_MULTIPLIER = 22,
    FLING_STRENGTH = 999999,
    ACCENT_COLOR = Color3.fromRGB(0, 255, 200)
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 2. THE VECTOR-THRUST ENGINE //
local function ManagePhysics(state)
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
        -- Collision Bypass
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

-- // 3. STYLISH UI CONSTRUCTION //
local function BuildChronosUI()
    if CoreGui:FindFirstChild("ChronosSentinel") then CoreGui.ChronosSentinel:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosSentinel"
    Screen.ResetOnSpawn = false

    local Main = Instance.new("Frame", Screen)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 210, 0, 160)
    Main.Position = UDim2.new(0.5, -105, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    local Glow = Instance.new("UIStroke", Main)
    Glow.Color = CHRONOS_SETTINGS.ACCENT_COLOR
    Glow.Thickness = 1.5
    Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Header.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS SENTINEL V1.0"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- Buttons Utility
    local function CreateButton(name, pos, text)
        local btn = Instance.new("TextButton", Main)
        btn.Name = name
        btn.Size = UDim2.new(1, -20, 0, 45)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        btn.Text = text
        btn.Font = Enum.Font.Code
        btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn)
        
        local bGlow = Instance.new("UIStroke", btn)
        bGlow.Color = Color3.fromRGB(40, 40, 45)
        bGlow.Thickness = 1
        
        return btn
    end

    local EgorBtn = CreateButton("EgorBtn", UDim2.new(0, 10, 0, 45), "EGOR DRIVE: OFF")
    local FlingBtn = CreateButton("FlingBtn", UDim2.new(0, 10, 0, 100), "AERO-FLING: OFF")

    -- Logic for Toggles
    EgorBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        EgorBtn.TextColor3 = CHRONOS_SETTINGS.EGOR_MODE and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(0.8, 0.8, 0.8)
        EgorBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ACTIVE" or "EGOR DRIVE: OFF"
    end)

    FlingBtn.MouseButton1Down:Connect(function()
        CHRONOS_SETTINGS.FLING_MODE = not CHRONOS_SETTINGS.FLING_MODE
        FlingBtn.TextColor3 = CHRONOS_SETTINGS.FLING_MODE and Color3.fromRGB(255, 50, 50) or Color3.new(0.8, 0.8, 0.8)
        FlingBtn.Text = CHRONOS_SETTINGS.FLING_MODE and "FLING: LETHAL" or "AERO-FLING: OFF"
        ManagePhysics(CHRONOS_SETTINGS.FLING_MODE)
    end)

    -- // UI INTERACTIVITY //
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

    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            CHRONOS_SETTINGS.UI_OPEN = not CHRONOS_SETTINGS.UI_OPEN
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = CHRONOS_SETTINGS.UI_OPEN and 0 or 1}):Play()
            Main.Visible = CHRONOS_SETTINGS.UI_OPEN
        end
    end)
end

-- // 4. ADVANCED RUNTIME //
RunService.Stepped:Connect(function()
    if not Character or not Root then return end
    
    -- Overclocked Animation Logic
    if CHRONOS_SETTINGS.EGOR_MODE then
        if Humanoid.MoveDirection.Magnitude > 0 then
            Humanoid.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
            local tracks = Humanoid:GetPlayingAnimationTracks()
            for _, t in pairs(tracks) do
                if t.Name:lower():find("run") or t.Name:lower():find("walk") or t.Animation.AnimationId:find("run") then
                    t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
                end
            end
        else
            Humanoid.WalkSpeed = 16
        end
    end

    -- Fling Stabilization (Anti-Float)
    if CHRONOS_SETTINGS.FLING_MODE then
        Root.AssemblyLinearVelocity = Vector3.new(Root.AssemblyLinearVelocity.X, 0, Root.AssemblyLinearVelocity.Z)
        -- Keep character upright while spinning
        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, math.rad(tick()*1200 % 360), 0)
    end
end)

BuildChronosUI()
