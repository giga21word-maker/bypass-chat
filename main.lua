--[[
    PHANTOM-STEP V5: PACKET-SHIFTING EDITION (v2026)
    --------------------------------------------------
    [FIXES]
    - Sticky Input: Speed no longer deletes when keyboard closes.
    - Large UI: Bigger text box and buttons for mobile fingers.
    - Display Priority: Forced above all game menus (ZIndex 2B).
    
    [UPGRADES]
    - Packet-Shifting: Randomizes position updates to bypass server delta-checks.
    - Friction Bypass: Forces movement even during "Stun" or "Slow" states.
    - Attribute Lock: Fixed Stamina/Energy for Blind Shot.
    --------------------------------------------------
]]

-- // 1. SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // 2. CONFIG //
local SETTINGS = {
    ENABLED = false,
    POWER = 5,
    JITTER = 0.22,
    MAX_LIMIT = 120,
    UI_COLOR = Color3.fromRGB(0, 255, 150)
}

-- // 3. STATE //
local Engine = {
    LastSpeed = 5,
    Clock = 0,
    IsMobile = UserInputService.TouchEnabled
}

-- // 4. ATTRIBUTE PERSISTENCE (INSTRUCTION SYNC) //
local function ForceAttributeLock()
    local char = LocalPlayer.Character
    if not char then return end
    
    pcall(function()
        -- Direct Attribute Forcing for Blind Shot
        char:SetAttribute("Stamina", 100)
        char:SetAttribute("Energy", 100)
        char:SetAttribute("CanDash", true)
        
        -- Fix/Upgrade: Override all speed-reduction children
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("speed") or v.Name:lower():find("slow")) then
                v.Value = 1 -- Neutralize slowing values
            end
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end)
end

-- // 5. THE PACKET-SHIFT ENGINE //
local function ApplyBypass(dt)
    if not SETTINGS.ENABLED then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if root and hum and hum.MoveDirection.Magnitude > 0 then
        -- Raycast to confirm ground (No-Fly Bypass)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        local groundCheck = Workspace:Raycast(root.Position, Vector3.new(0, -9, 0), rayParams)
        
        if groundCheck then
            Engine.Clock = Engine.Clock + dt
            
            -- PACKET SHIFTING (The 'Stronger' Logic)
            -- Mimics high ping by adding a sine-wave offset to the velocity delta
            local noise = math.sin(Engine.Clock * 22) * SETTINGS.JITTER
            local moveVal = (SETTINGS.POWER * (1 + noise))
            
            -- Move using CFrame Pivot (Safest method)
            local targetPos = root.CFrame + (hum.MoveDirection * (moveVal * dt * 6.5))
            root.CFrame = root.CFrame:Lerp(targetPos, 0.85)
        end
    end
end

-- // 6. RECONSTRUCTED MOBILE GUI (LARGE SCALE) //
local function BuildUI()
    if CoreGui:FindFirstChild("PhantomV5") then CoreGui.PhantomV5:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "PhantomV5"
    Screen.DisplayOrder = 1000000000

    -- Floating Toggle Button
    local Trigger = Instance.new("TextButton", Screen)
    Trigger.Size = UDim2.new(0, 60, 0, 60)
    Trigger.Position = UDim2.new(0.02, 0, 0.4, 0)
    Trigger.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Trigger.Text = "P5"
    Trigger.TextColor3 = SETTINGS.UI_COLOR
    Trigger.Font = Enum.Font.GothamBold
    Trigger.TextSize = 25
    Instance.new("UICorner", Trigger).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Trigger).Color = SETTINGS.UI_COLOR

    -- Main Panel
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 240, 0, 280)
    Main.Position = UDim2.new(0.15, 0, 0.35, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.Visible = false
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = SETTINGS.UI_COLOR

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Text = "PHANTOM V5"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 20
    Title.BackgroundTransparency = 1

    -- LARGE INPUT BOX
    local InputFrame = Instance.new("Frame", Main)
    InputFrame.Size = UDim2.new(0.8, 0, 0, 60)
    InputFrame.Position = UDim2.new(0.1, 0, 0.25, 0)
    InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", InputFrame)

    local SpeedBox = Instance.new("TextBox", InputFrame)
    SpeedBox.Size = UDim2.new(1, 0, 1, 0)
    SpeedBox.BackgroundTransparency = 1
    SpeedBox.Text = tostring(SETTINGS.POWER)
    SpeedBox.PlaceholderText = "INPUT"
    SpeedBox.TextColor3 = SETTINGS.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 35 -- Very large for mobile
    SpeedBox.ClearTextOnFocus = false

    -- APPLY/TOGGLE BUTTON
    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 60)
    Toggle.Position = UDim2.new(0.1, 0, 0.65, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 50, 50)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 20
    Instance.new("UICorner", Toggle)

    -- // LOGIC //
    Trigger.MouseButton1Down:Connect(function()
        Main.Visible = not Main.Visible
        Trigger.Text = Main.Visible and "X" or "P5"
    end)

    -- Sticky Input Logic: Save value even if cleared
    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber(SpeedBox.Text)
        if n then Engine.LastSpeed = n end
    end)

    SpeedBox.FocusLost:Connect(function()
        SETTINGS.POWER = math.clamp(Engine.LastSpeed, 0, SETTINGS.MAX_LIMIT)
        SpeedBox.Text = tostring(SETTINGS.POWER)
    end)

    Toggle.MouseButton1Down:Connect(function()
        SETTINGS.ENABLED = not SETTINGS.ENABLED
        Toggle.Text = SETTINGS.ENABLED and "ON" or "OFF"
        Toggle.TextColor3 = SETTINGS.ENABLED and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 50, 50)
        Toggle.BackgroundColor3 = SETTINGS.ENABLED and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(40, 40, 40)
    end)

    -- Mobile Drag
    local d, dS, sP
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; dS = i.Position; sP = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dS
            Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

-- // RUNTIME //
RunService.Heartbeat:Connect(function(dt)
    pcall(ApplyBypass, dt)
    ForceAttributeLock()
end)

RunService.Stepped:Connect(function()
    local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Hum then Hum.WalkSpeed = 16 end
end)

BuildUI()
print("[LOADED] Phantom-Step V5: Ultra Bypass ready.")
