--[[
    STRATUS-WALK V3: CFRAME VECTOR ENGINE
    --------------------------------------------------
    [FIXES]
    - Flight Fix: Uses CFrame manipulation instead of BodyMovers.
    - Vertical Sync: Look Up = Ascend, Look Down = Descend.
    - Animation Lock: Keeps walking legs active while floating.
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

-- // 2. CONFIG //
local STRATUS_V3 = {
    ENABLED = false,
    SPEED = 50,
    UI_COLOR = Color3.fromRGB(0, 180, 255)
}

-- // 3. FLY ENGINE //
local function ExecuteFlight(dt)
    if not STRATUS_V3.ENABLED then return end
    
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if not Root or not Hum then return end

    -- BYPASS: Force 'Running' state so the game doesn't think we are falling
    Hum:ChangeState(Enum.HumanoidStateType.Running)

    if Hum.MoveDirection.Magnitude > 0 then
        -- 3D VECTOR MATH: 
        -- Takes your Camera direction and your MoveDirection to find where to 'Float'
        local Look = Camera.CFrame.LookVector
        local Move = Hum.MoveDirection
        
        -- This is the core 'Fly' logic:
        -- It moves your CFrame in 3D space based on where you look.
        local TargetVelocity = Look * (STRATUS_V3.SPEED * dt)
        Root.CFrame = Root.CFrame + TargetVelocity
        
        -- Visual Sync: Keeps your character upright and legs moving
        Root.AssemblyLinearVelocity = Vector3.new(0, 0.05, 0) 
    else
        -- HOVER LOGIC: Zero out gravity effects
        Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- // 4. MOBILE UI //
local function BuildUI()
    if CoreGui:FindFirstChild("StratusFlyV3") then CoreGui.StratusFlyV3:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "StratusFlyV3"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 180, 0, 120)
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = STRATUS_V3.UI_COLOR

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "STRATUS FLY V3"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.8, 0, 0, 50)
    Toggle.Position = UDim2.new(0.1, 0, 0.45, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Toggle.Text = "FLY: OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 60, 60)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 14
    Instance.new("UICorner", Toggle)

    Toggle.MouseButton1Down:Connect(function()
        STRATUS_V3.ENABLED = not STRATUS_V3.ENABLED
        Toggle.Text = STRATUS_V3.ENABLED and "FLY: ON" or "FLY: OFF"
        Toggle.TextColor3 = STRATUS_V3.ENABLED and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 60, 60)
        
        if not STRATUS_V3.ENABLED then
            -- Reset physics when disabled
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Landing)
            end
        end
    end)
end

-- // 5. RUNTIME //
RunService.Heartbeat:Connect(function(dt)
    pcall(ExecuteFlight, dt)
    
    -- Instruction Sync: Attribute Guard
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("Stamina", 100)
        char:SetAttribute("Energy", 100)
    end
end)

BuildUI()
print("[LOADED] Stratus Fly V3: CFrame Vectoring Active.")
