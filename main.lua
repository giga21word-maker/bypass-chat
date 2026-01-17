-- // PROJECT EGOR ALPHA 0.0.2 //
-- STATUS: Toggle & Reset Logic Added
-- FEATURE: Animation Overclock + Draggable Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- // 1. EGOR CONFIGURATION //
local EGOR_CONFIG = {
    ENABLED = false,
    LEG_SPEED = 18, 
    WALK_SPEED = 3,
    VERSION = "0.0.2-EGOR",
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 2. ANIMATION OVERRIDE //
local function UpdateEgor()
    if not EGOR_CONFIG.ENABLED then 
        -- Reset to Normal
        Humanoid.WalkSpeed = 16
        local tracks = Humanoid:GetPlayingAnimationTracks()
        for _, t in pairs(tracks) do t:AdjustSpeed(1) end
        return 
    end

    if Humanoid.MoveDirection.Magnitude > 0 then
        Humanoid.WalkSpeed = EGOR_CONFIG.WALK_SPEED
        local tracks = Humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(tracks) do
            if track.Name:lower():find("run") or track.Name:lower():find("walk") or track.Animation.AnimationId:find("run") then
                track:AdjustSpeed(EGOR_CONFIG.LEG_SPEED)
            end
        end
    else
        Humanoid.WalkSpeed = 16 -- Normal speed while idle so you don't "slide"
    end
end

-- // 3. DRAGGABLE UI //
local function BuildUI()
    if CoreGui:FindFirstChild("EgorAlpha") then CoreGui.EgorAlpha:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "EgorAlpha"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 150, 0, 70)
    Main.Position = UDim2.new(0.5, -75, 0.15, 0)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 100, 0) -- Egor Orange

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -10, 1, -10)
    B.Position = UDim2.new(0, 5, 0, 5)
    B.Text = "EGOR: OFF"
    B.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Code
    B.TextSize = 14
    Instance.new("UICorner", B)

    -- Drag System
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

    B.MouseButton1Down:Connect(function()
        EGOR_CONFIG.ENABLED = not EGOR_CONFIG.ENABLED
        B.Text = EGOR_CONFIG.ENABLED and "EGOR: ON" or "EGOR: OFF"
        B.TextColor3 = EGOR_CONFIG.ENABLED and Color3.new(1, 0.5, 0) or Color3.new(1, 1, 1)
    end)
end

-- // 4. RUNTIME //
RunService.RenderStepped:Connect(function()
    if EGOR_CONFIG.ACTIVE and Humanoid and Humanoid.Parent then
        UpdateEgor()
    end
end)

-- Character Refresh Logic
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
end)

BuildUI()
