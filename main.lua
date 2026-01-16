--[[
    AETHER-WALK V7: OBLITERATOR + PHANTOM GOD + COORDINATE TOOL
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - UPDATED: God Mode now uses Phantom-Anchor (Health Lock + CanTouch bypass).
    - ADDED: "Copy Position" button to F9 console for fixing zone coords.
    - FIXED: Vertical Ascent/Descent and Speed Masking at 16.
    ----------------------------------------------------------
]]

-- // 1. CORE SYSTEM SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // 2. ELITE CONFIGURATION //
local AETHER_CONFIG = {
    ENABLED = false,
    GOD_MODE = false,
    SPEED = 80,
    MAX_CAP = 1000,
    UI_COLOR = Color3.fromRGB(0, 255, 180),
    SAVED_POS = nil,
    VERSION = "V7.0.0 - Phantom Edition"
}

-- Current Zones (Use the Copy Position tool to give me new numbers!)
local ZONES = {
    ["BASE"] = Vector3.new(0, 5, 0),
    ["LEGENDARY"] = Vector3.new(0, 5, 1200),
    ["MYTHIC"] = Vector3.new(0, 5, 2500),
    ["COSMIC"] = Vector3.new(0, 5, 4500),
    ["CELESTIAL"] = Vector3.new(0, 5, 8000)
}

-- // 3. INTERNAL ENGINE STATE //
local Internal = {
    SpeedBuffer = 80,
    UIVisible = true
}

-- // 4. THE PHANTOM BYPASS (GOD MODE + ANTI-CHEAT) //
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            -- Masking for Anti-Cheat
            Hum.WalkSpeed = 16
            Char:SetAttribute("Stamina", 100)
            Char:SetAttribute("Energy", 100)
            
            if AETHER_CONFIG.ENABLED then
                Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end

            -- PHANTOM GOD MODE: Disables touches so the Tsunami script can't find you
            if AETHER_CONFIG.GOD_MODE then
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") then 
                        part.CanTouch = false 
                    end
                end
                Hum.MaxHealth = 999999
                Hum.Health = 999999
                Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            else
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") then 
                        part.CanTouch = true 
                    end
                end
            end
        end
    end)
end

-- // 5. THE AETHER-FLY ENGINE (3D VECTORING) //
local function ExecuteAether(dt)
    if not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    local Look = Camera.CFrame.LookVector
    local MoveDir = Hum.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        local TargetVelocity = Look * AETHER_CONFIG.SPEED
        Root.AssemblyLinearVelocity = TargetVelocity
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.08)
    else
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0) -- Weightless Hover
    end
end

-- // 6. MODULAR UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV7_System") then CoreGui.AetherV7_System:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV7_System"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 260, 0, 440)
    Main.Position = UDim2.new(0.05, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = AETHER_CONFIG.UI_COLOR

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "AETHER WALK - " .. AETHER_CONFIG.VERSION
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -20, 1, -60)
    Scroll.Position = UDim2.new(0, 10, 0, 50)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 2.2, 0)
    Scroll.ScrollBarThickness = 0

    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0, 8)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateButton(text, color, callback)
        local btn = Instance.new("TextButton", Scroll)
        btn.Size = UDim2.new(0.95, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = text
        btn.TextColor3 = color
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        Instance.new("UICorner", btn)
        btn.MouseButton1Down:Connect(callback)
        return btn
    end

    -- SPEED INPUT
    local SpeedBox = Instance.new("TextBox", Scroll)
    SpeedBox.Size = UDim2.new(0.95, 0, 0, 45)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedBox.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 25
    SpeedBox.ClearTextOnFocus = false
    Instance.new("UICorner", SpeedBox)

    -- MAIN TOGGLES
    local FlyToggle = CreateButton("FLY ENGINE: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED
    end)

    local GodToggle = CreateButton("GOD MODE: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE
    end)

    CreateButton("THE DUG (CLIP TO PIT)", Color3.new(1, 1, 1), function()
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0)
    end)

    -- COORDINATE TOOLS
    CreateButton("--- DEV TOOLS ---", Color3.new(0.6, 0.6, 0.6), function() end)
    
    CreateButton("COPY MY POSITION (F9)", Color3.fromRGB(255, 255, 0), function()
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        print("ZONE COORDS: Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")")
    end)

    CreateButton("SAVE SPOT", Color3.new(0, 1, 0), function()
        AETHER_CONFIG.SAVED_POS = LocalPlayer.Character.HumanoidRootPart.CFrame
    end)

    CreateButton("LOAD SPOT", Color3.new(1, 1, 0), function()
        if AETHER_CONFIG.SAVED_POS then LocalPlayer.Character.HumanoidRootPart.CFrame = AETHER_CONFIG.SAVED_POS end
    end)

    -- ZONE TPs
    CreateButton("--- ZONE TELEPORTS ---", Color3.new(0.6, 0.6, 0.6), function() end)
    for zone, pos in pairs(ZONES) do
        CreateButton("TP TO " .. zone, Color3.fromRGB(0, 180, 255), function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end)
    end

    -- UI UPDATES
    RunService.RenderStepped:Connect(function()
        FlyToggle.Text = AETHER_CONFIG.ENABLED and "FLY ENGINE: ON" or "FLY ENGINE: OFF"
        FlyToggle.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
        GodToggle.Text = AETHER_CONFIG.GOD_MODE and "GOD MODE: ON" or "GOD MODE: OFF"
        GodToggle.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
    end)

    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber(SpeedBox.Text)
        if n then Internal.SpeedBuffer = n end
    end)

    SpeedBox.FocusLost:Connect(function()
        AETHER_CONFIG.SPEED = math.clamp(Internal.SpeedBuffer, 0, AETHER_CONFIG.MAX_CAP)
        SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    end)

    -- Dragging
    local d, dS, sP
    Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; dS = i.Position; sP = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dS; Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

-- // RUNTIME //
RunService.Heartbeat:Connect(function(dt)
    ExecuteAether(dt)
    GlobalBypassSync()
end)

BuildUI()
print("[SUCCESS] Aether-Walk V7 Loaded. Use F9 to check copied coordinates.")
