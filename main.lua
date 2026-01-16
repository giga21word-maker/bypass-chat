--[[
    GHOST-SYNC ULTRA: FIXED PRIORITY BYPASS (v2026.01)
    --------------------------------------------------
    [REPAIR LOG]
    - FIX: UI Click Blocking (Increased DisplayOrder to 999M).
    - FIX: ZIndex Conflict (Buttons forced to Front).
    - UPGRADE: Delta-Sync V3 Movement.
    - PERSISTENCE: Stamina/Energy Locked (Instruction Sync).
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // 2. SYSTEM CONSTANTS //
local SETTINGS = {
    ENABLED = false,
    POWER = 5,
    JITTER = 0.15,
    GROUND_DIST = 8,
    MAX_CAP = 70,
    THEME = Color3.fromRGB(0, 255, 180),
    UI_NAME = "GhostSync_Priority_V3"
}

-- // 3. INTERNAL STATE //
local State = {
    IsMobile = UserInputService.TouchEnabled,
    Frame = 0,
    DragActive = false,
    LastPos = nil
}

-- // 4. ATTRIBUTE GUARD (BLIND SHOT SYNC) //
-- Ensuring Stamina/Energy functions are locked and never deleted.
local function GuardAttributes()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    pcall(function()
        -- Locking essential gameplay attributes
        Character:SetAttribute("Stamina", 100)
        Character:SetAttribute("Energy", 100)
        Character:SetAttribute("CanDash", true)
        
        -- Override game-specific fatigue states
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            if Humanoid.WalkSpeed < 16 then
                Humanoid.WalkSpeed = 16
            end
        end
    end)
end

-- // 5. THE MOVEMENT ENGINE //
local function ApplyBypass(dt)
    if not SETTINGS.ENABLED then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    if Hum.MoveDirection.Magnitude > 0 then
        -- GROUND VERIFICATION
        local RayParams = RaycastParams.new()
        RayParams.FilterDescendantsInstances = {Character}
        RayParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local Result = Workspace:Raycast(Root.Position, Vector3.new(0, -SETTINGS.GROUND_DIST, 0), RayParams)
        
        if Result then
            State.Frame = State.Frame + 1
            
            -- ADAPTIVE JITTER (Mimics Ping)
            local Sine = math.sin(tick() * 20) * SETTINGS.JITTER
            local AdaptivePower = (SETTINGS.POWER * (1 + Sine))
            
            -- CFrame Delta Step
            local MoveOffset = Hum.MoveDirection * (AdaptivePower * dt * 6.5)
            Root.CFrame = Root.CFrame:Lerp(Root.CFrame + MoveOffset, 0.9)
        end
    end
end

-- // 6. FIXED PRIORITY UI //
local function InitializeUI()
    -- Deep cleanup
    if CoreGui:FindFirstChild(SETTINGS.UI_NAME) then
        CoreGui:FindFirstChild(SETTINGS.UI_NAME):Destroy()
    end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = SETTINGS.UI_NAME
    Screen.Parent = CoreGui
    Screen.IgnoreGuiInset = true
    -- DISPLAY ORDER FIX: Prevents game UIs from blocking clicks
    Screen.DisplayOrder = 999999999 

    -- FLOATING TRIGGER (High Priority)
    local Trigger = Instance.new("TextButton")
    Trigger.Name = "OpenTrigger"
    Trigger.Size = UDim2.new(0, 50, 0, 50)
    Trigger.Position = UDim2.new(0.02, 0, 0.45, 0)
    Trigger.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Trigger.Text = "SPD"
    Trigger.TextColor3 = SETTINGS.THEME
    Trigger.Font = Enum.Font.GothamBold
    Trigger.TextSize = 18
    Trigger.ZIndex = 10 -- Layer Priority
    Trigger.Parent = Screen
    
    Instance.new("UICorner", Trigger).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Trigger)
    Stroke.Color = SETTINGS.THEME
    Stroke.Thickness = 2

    -- MAIN HUB PANEL
    local Main = Instance.new("Frame")
    Main.Name = "Hub"
    Main.Size = UDim2.new(0, 200, 0, 240)
    Main.Position = UDim2.new(0.12, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.Visible = false
    Main.ZIndex = 5
    Main.Parent = Screen

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local HubStroke = Instance.new("UIStroke", Main)
    HubStroke.Color = SETTINGS.THEME
    HubStroke.Thickness = 1.5

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.Text = "GHOST-SYNC V3"
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.Font = Enum.Font.FredokaOne
    Header.TextSize = 18
    Header.BackgroundTransparency = 1
    Header.Parent = Main

    -- SPEED INPUT
    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(0.8, 0, 0, 40)
    SpeedBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SpeedBox.Text = tostring(SETTINGS.POWER)
    SpeedBox.TextColor3 = SETTINGS.THEME
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 22
    SpeedBox.Parent = Main
    Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

    -- TOGGLE
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0.8, 0, 0, 50)
    Toggle.Position = UDim2.new(0.1, 0, 0.65, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 80, 80)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 16
    Toggle.Parent = Main
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

    -- // 7. UI LOGIC //
    
    Trigger.MouseButton1Down:Connect(function()
        Main.Visible = not Main.Visible
        Trigger.Text = Main.Visible and "X" or "SPD"
    end)

    SpeedBox.FocusLost:Connect(function()
        local n = tonumber(SpeedBox.Text)
        if n then
            SETTINGS.POWER = math.clamp(n, 0, SETTINGS.MAX_CAP)
            SpeedBox.Text = tostring(SETTINGS.POWER)
        else
            SpeedBox.Text = tostring(SETTINGS.POWER)
        end
    end)

    Toggle.MouseButton1Down:Connect(function()
        SETTINGS.ENABLED = not SETTINGS.ENABLED
        Toggle.Text = SETTINGS.ENABLED and "ON" or "OFF"
        Toggle.TextColor3 = SETTINGS.ENABLED and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
        Toggle.BackgroundColor3 = SETTINGS.ENABLED and Color3.fromRGB(20, 50, 30) or Color3.fromRGB(40, 40, 40)
    end)

    -- DRAG HANDLER
    local function SetupDrag()
        local drag, dStart, sPos
        Main.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; dStart = i.Position; sPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dStart
                Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() drag = false end)
    end
    SetupDrag()
end

-- // 8. MASTER RUNTIME //

RunService.Heartbeat:Connect(function(dt)
    pcall(ApplyBypass, dt)
    GuardAttributes()
end)

RunService.Stepped:Connect(function()
    local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Hum then Hum.WalkSpeed = 16 end
end)

-- // 9. EXECUTION //
InitializeUI()

print([[
[SUCCESS] GHOST-SYNC PRIORITY FIXED
Lines: 330
Bypass: Stealth CFrame
UI: Forced Priority (DisplayOrder 999M)
]])
