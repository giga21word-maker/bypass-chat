--[[
    STRATUS-WALK V2: FULL-AXIS AXIS BYPASS
    --------------------------------------------------
    [UPGRADES]
    - Vertical Vectoring: Look down to descend, look up to ascend.
    - Anti-Kick Buffer: Randomizes velocity by 0.1% to mimic network lag.
    - State Persistence: Locked 'Running' state to bypass fly-detection.
    - Speed Multiplier: Integrated input support.
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // 2. SYSTEM CONFIG //
local STRATUS_SETTINGS = {
    ENABLED = false,
    FLY_SPEED = 50,
    JITTER = 0.05,
    UI_COLOR = Color3.fromRGB(0, 255, 200),
    GUI_NAME = "Stratus_V2_Quantum"
}

-- // 3. INTERNAL ENGINE STATE //
local Engine = {
    BodyVel = nil,
    BodyGyro = nil,
    Loop = nil,
    SpeedBuffer = 50
}

-- // 4. ATTRIBUTE GUARD (INSTRUCTION SYNC) //
-- Never delete, only fix/upgrade. 
local function SyncAttributes()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    pcall(function()
        Char:SetAttribute("Stamina", 100)
        Char:SetAttribute("Energy", 100)
        Char:SetAttribute("CanDash", true)
        
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum.WalkSpeed = 16 end
    end)
end

-- // 5. THE 3D AXIS ENGINE //
local function ToggleEngine(active)
    STRATUS_SETTINGS.ENABLED = active
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    if active then
        -- Initialize Physics Anchors
        Engine.BodyVel = Instance.new("BodyVelocity")
        Engine.BodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        Engine.BodyVel.Velocity = Vector3.new(0, 0, 0)
        Engine.BodyVel.Parent = Root

        Engine.BodyGyro = Instance.new("BodyGyro")
        Engine.BodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        Engine.BodyGyro.D = 500
        Engine.BodyGyro.P = 3000
        Engine.BodyGyro.Parent = Root

        -- Execution Loop
        Engine.Loop = RunService.RenderStepped:Connect(function()
            -- BYPASS: Force 'Running' to prevent Fly-Detection kicks
            Hum:ChangeState(Enum.HumanoidStateType.Running)
            
            local Look = Camera.CFrame.LookVector
            local Move = Hum.MoveDirection
            
            if Move.Magnitude > 0 then
                -- 3D DIRECTIONAL FLIGHT:
                -- Multiplying move direction by camera look vector allows 
                -- for true 3D space movement.
                local TargetVelocity = Look * STRATUS_SETTINGS.FLY_SPEED
                
                -- Anti-Cheat Jitter: Adds tiny variation to velocity
                local Jitter = 1 + (math.random(-100, 100) / 1000 * STRATUS_SETTINGS.JITTER)
                Engine.BodyVel.Velocity = TargetVelocity * Jitter
            else
                -- Stationary Hover
                Engine.BodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Lock character orientation to camera (Upright)
            Engine.BodyGyro.CFrame = Camera.CFrame
        end)
    else
        -- Clean Cleanup
        if Engine.BodyVel then Engine.BodyVel:Destroy() end
        if Engine.BodyGyro then Engine.BodyGyro:Destroy() end
        if Engine.Loop then Engine.Loop:Disconnect() end
        Hum:ChangeState(Enum.HumanoidStateType.Landing)
    end
end

-- // 6. ADVANCED MOBILE UI (STICKY INPUT) //
local function BuildUI()
    if CoreGui:FindFirstChild(STRATUS_SETTINGS.GUI_NAME) then 
        CoreGui:FindFirstChild(STRATUS_SETTINGS.GUI_NAME):Destroy() 
    end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = STRATUS_SETTINGS.GUI_NAME
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 160)
    Main.Position = UDim2.new(0.05, 0, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = STRATUS_SETTINGS.UI_COLOR

    -- SPEED INPUT BOX
    local InputFrame = Instance.new("Frame", Main)
    InputFrame.Size = UDim2.new(0.8, 0, 0, 45)
    InputFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
    InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", InputFrame)

    local SpeedBox = Instance.new("TextBox", InputFrame)
    SpeedBox.Size = UDim2.new(1, 0, 1, 0)
    SpeedBox.BackgroundTransparency = 1
    SpeedBox.Text = tostring(STRATUS_SETTINGS.FLY_SPEED)
    SpeedBox.TextColor3 = STRATUS_SETTINGS.UI_COLOR
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.TextSize = 25
    SpeedBox.ClearTextOnFocus = false

    -- TOGGLE BUTTON
    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 55)
    Toggle.Position = UDim2.new(0.1, 0, 0.55, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Toggle.Text = "ENGINE: OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 60, 60)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 18
    Instance.new("UICorner", Toggle)

    -- // INTERACTION //
    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber(SpeedBox.Text)
        if n then Engine.SpeedBuffer = n end
    end)

    SpeedBox.FocusLost:Connect(function()
        STRATUS_SETTINGS.FLY_SPEED = math.clamp(Engine.SpeedBuffer, 0, 500)
        SpeedBox.Text = tostring(STRATUS_SETTINGS.FLY_SPEED)
    end)

    Toggle.MouseButton1Down:Connect(function()
        local newState = not STRATUS_SETTINGS.ENABLED
        ToggleEngine(newState)
        Toggle.Text = newState and "ENGINE: ON" or "ENGINE: OFF"
        Toggle.TextColor3 = newState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
        Toggle.BackgroundColor3 = newState and Color3.fromRGB(20, 50, 30) or Color3.fromRGB(30, 30, 30)
    end)
    
    -- Mobile Drag Handler
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

-- // 7. RUNTIME //
RunService.Heartbeat:Connect(SyncAttributes)

BuildUI()
print("[SUCCESS] Stratus V2: 3D-Axis Fly Active.")
