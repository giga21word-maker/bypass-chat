--[[
    AETHER-WALK V13: HYPER-STUTTER & PHYSICS INJECTION
    ----------------------------------------------------------
    [PROJECT LOG: 2026-01-16]
    - FIXED: Ghost Slowdown. Injected BodyVelocity for forced speed.
    - FIXED: Slow TP. Upgraded to Hyper-Stutter (Instant segmented jumps).
    - FIXED: Void Death. Added Y-Level Floor Check (Phantom Anchor).
    - UPDATED: Base Coordinate restored to Vector3.new(66, 3, 7).
    - STABLE: Zero lines deleted, physics and bypass logic overhauled.
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
    VERSION = "V13.0.0 - Hyper-Stutter",
    SAFE_BASE = Vector3.new(66, 3, 7) -- RESTORED BASE
}

-- UPDATED ZONES
local ZONES = {
    ["BASE"] = AETHER_CONFIG.SAFE_BASE,
    ["LEGENDARY"] = Vector3.new(0, 5, 1200),
    ["MYTHIC"] = Vector3.new(0, 5, 2500),
    ["COSMIC"] = Vector3.new(0, 5, 4500),
    ["CELESTIAL"] = Vector3.new(0, 5, 8000)
}

-- // 3. INTERNAL ENGINE STATE //
local Internal = {
    SpeedBuffer = 80,
    UIVisible = true,
    GhostModel = nil,
    IsTeleporting = false,
    BV = nil, -- BodyVelocity for Ghost
    BG = nil  -- BodyGyro for Ghost
}

-- // 4. SMART BYPASS ENGINE (HYPER-STUTTER TP) //
local function SmartTeleport(targetCFrame)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root or Internal.IsTeleporting then return end
    
    Internal.IsTeleporting = true
    local startPos = Root.Position
    local endPos = targetCFrame.Position
    local dist = (startPos - endPos).Magnitude
    
    if dist > 30 then
        -- V13 Hyper-Stutter: High frequency jumps to bypass detection
        local stepCount = math.clamp(math.floor(dist/15), 5, 20)
        for i = 1, stepCount do
            Root.CFrame = CFrame.new(startPos:Lerp(endPos, i/stepCount))
            -- No wait() here for "Instant" feel, but staggered for server-logic
            game:GetService("RunService").Stepped:Wait() 
        end
    end
    Root.CFrame = targetCFrame
    Internal.IsTeleporting = false
end

-- // 5. GHOST PROJECTION ENGINE (V13 PHYSICS INJECTION) //
local function CleanupGhost()
    if Internal.GhostModel then 
        Internal.GhostModel:Destroy() 
    end
    Internal.GhostModel = nil
    if Internal.BV then Internal.BV:Destroy() end
    if Internal.BG then Internal.BG:Destroy() end
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function HandleGhostLogic(dt)
    if not AETHER_CONFIG.GOD_MODE or not Internal.GhostModel then return end
    
    local GhostRoot = Internal.GhostModel:FindFirstChild("HumanoidRootPart")
    local GhostHum = Internal.GhostModel:FindFirstChildOfClass("Humanoid")
    local RealChar = LocalPlayer.Character
    
    if GhostRoot and GhostHum then
        Camera.CameraSubject = GhostHum
        
        -- Physics Reinforcement
        if not Internal.BV then
            Internal.BV = Instance.new("BodyVelocity", GhostRoot)
            Internal.BV.MaxForce = Vector3.new(1,1,1) * math.huge
            Internal.BG = Instance.new("BodyGyro", GhostRoot)
            Internal.BG.MaxTorque = Vector3.new(1,1,1) * math.huge
        end
        
        local MoveDir = RealChar:FindFirstChildOfClass("Humanoid").MoveDirection
        if MoveDir.Magnitude > 0 then
            local TargetVel = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
            Internal.BV.Velocity = TargetVel
            Internal.BG.CFrame = Camera.CFrame
        else
            Internal.BV.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- // 6. THE PHANTOM BYPASS //
local function GlobalBypassSync()
    local Char = LocalPlayer.Character
    if not Char or Internal.IsTeleporting then return end
    
    pcall(function()
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local Root = Char:FindFirstChild("HumanoidRootPart")
        
        if Hum and Root then
            Hum.WalkSpeed = 16
            
            if AETHER_CONFIG.GOD_MODE then
                if not Internal.GhostModel then
                    Char.Archivable = true
                    Internal.GhostModel = Char:Clone()
                    Internal.GhostModel.Name = "Aether_Ghost_V13"
                    Internal.GhostModel.Parent = Workspace
                    
                    for _, p in pairs(Internal.GhostModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 0.5
                            p.Color = Color3.fromRGB(0, 255, 180)
                            p.CanCollide = false
                            p.CanTouch = false
                            p.Massless = true 
                        elseif p:IsA("Humanoid") then
                            p.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                    end
                    Internal.GhostModel:SetPrimaryPartCFrame(Root.CFrame)
                end

                -- V13 VOID CHECK & BASE ANCHOR
                if Root.Position.Y < (AETHER_CONFIG.SAFE_BASE.Y - 10) then
                    Root.CFrame = CFrame.new(AETHER_CONFIG.SAFE_BASE + Vector3.new(0, 2, 0))
                end
                
                Root.Anchored = true
                Hum.MaxHealth = 999999
                Hum.Health = 999999
            else
                if Internal.GhostModel then
                    Root.Anchored = false
                    local targetReturn = Internal.GhostModel.PrimaryPart.CFrame
                    CleanupGhost()
                    SmartTeleport(targetReturn)
                end
            end
        end
    end)
end

-- // 7. THE AETHER-FLY ENGINE //
local function ExecuteAether(dt)
    if AETHER_CONFIG.GOD_MODE then 
        HandleGhostLogic(dt) 
        return 
    end
    if not AETHER_CONFIG.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local MoveDir = Char:FindFirstChildOfClass("Humanoid").MoveDirection
    if MoveDir.Magnitude > 0 then
        local TargetVelocity = Camera.CFrame.LookVector * AETHER_CONFIG.SPEED
        Root.AssemblyLinearVelocity = TargetVelocity
        Root.CFrame = Root.CFrame + (TargetVelocity * dt * 0.08)
    else
        Root.AssemblyLinearVelocity = Vector3.new(0, 1.15, 0)
    end
end

-- // 8. MODULAR UI //
local function BuildUI()
    if CoreGui:FindFirstChild("AetherV13_System") then CoreGui.AetherV13_System:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "AetherV13_System"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 260, 0, 440)
    Main.Position = UDim2.new(0.05, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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
        btn.TextSize = 11
        Instance.new("UICorner", btn)
        btn.MouseButton1Down:Connect(callback)
        return btn
    end

    local SpeedBox = Instance.new("TextBox", Scroll)
    SpeedBox.Size = UDim2.new(0.95, 0, 0, 45)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SpeedBox.Text = tostring(AETHER_CONFIG.SPEED)
    SpeedBox.TextColor3 = AETHER_CONFIG.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 25
    SpeedBox.ClearTextOnFocus = false
    Instance.new("UICorner", SpeedBox)

    local FlyToggle = CreateButton("FLY ENGINE: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.ENABLED = not AETHER_CONFIG.ENABLED
    end)

    local GodToggle = CreateButton("PHANTOM GOD: OFF", Color3.new(1, 0.2, 0.2), function()
        AETHER_CONFIG.GOD_MODE = not AETHER_CONFIG.GOD_MODE
    end)

    CreateButton("THE DUG (CLIP TO PIT)", Color3.new(1, 1, 1), function()
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -35, 0)
    end)

    CreateButton("COPY POSITION TO CLIPBOARD", Color3.fromRGB(255, 255, 0), function()
        local posPart = (Internal.GhostModel and Internal.GhostModel.PrimaryPart) or LocalPlayer.Character.HumanoidRootPart
        local pos = posPart.Position
        local formatted = "Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
        if setclipboard then setclipboard(formatted) end
        print("Copied to Clipboard: " .. formatted)
    end)

    CreateButton("--- ZONE TELEPORTS ---", Color3.new(0.6, 0.6, 0.6), function() end)
    for zone, pos in pairs(ZONES) do
        CreateButton("TP TO " .. zone, Color3.fromRGB(0, 180, 255), function()
            SmartTeleport(CFrame.new(pos))
        end)
    end

    RunService.RenderStepped:Connect(function()
        FlyToggle.Text = AETHER_CONFIG.ENABLED and "FLY ENGINE: ON" or "FLY ENGINE: OFF"
        FlyToggle.TextColor3 = AETHER_CONFIG.ENABLED and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
        GodToggle.Text = AETHER_CONFIG.GOD_MODE and "PHANTOM GOD: ON" or "PHANTOM GOD: OFF"
        GodToggle.TextColor3 = AETHER_CONFIG.GOD_MODE and Color3.new(0, 1, 0.5) or Color3.new(1, 0.2, 0.2)
    end)

    SpeedBox.FocusLost:Connect(function()
        AETHER_CONFIG.SPEED = tonumber(SpeedBox.Text) or 80
    end)

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
print("[AETHER V13] Hyper-Stutter Engine Online.")
