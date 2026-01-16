--[[
    PROJECT FORSAKEN: ETERNAL V2 (EXTREME)
    Engineered for the 2026 Forsaken Stamina Overhaul
    
    [SYSTEMS]
    - Meta-Index Hooking: Spoofs stamina values to local scripts.
    - Constant Velocity Injection: Prevents "Exhaustion" slowdown.
    - Attribute Shadowing: Prevents the server from setting "Exhausted" to true.
    - Mobile Adaptive UI: Draggable and toggleable.
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local UI_NAME = "EternalV2_" .. HttpService:GenerateGUID(false)

-- // 2. SYSTEM SETTINGS //
local Settings = {
    Enabled = true,
    SpeedHack = false,
    SprintSpeed = 24, -- Standard Forsaken sprint is ~21-22
    WalkSpeed = 16,
    ForceStamina = 999999,
    BypassExhaustion = true
}

-- // 3. METATABLE HOOKING (THE "BRAIN") //
-- This stops the game scripts from seeing that their stamina is draining
local function InitiateBypass()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if Settings.Enabled and not checkcaller() then
            -- If any script tries to check "Stamina", we tell it it's 100
            if k == "Stamina" or k == "SprintAmount" or k == "Energy" then
                return Settings.ForceStamina
            end
            -- If the game checks if we are "Exhausted", we always say No
            if k == "Exhausted" or k == "IsTired" or k == "Tired" then
                return false
            end
        end
        return oldIndex(t, k)
    end)

    -- This prevents the game from setting our speed to 8 when we get tired
    mt.__newindex = newcclosure(function(t, k, v)
        if Settings.Enabled and not checkcaller() and t:IsA("Humanoid") and k == "WalkSpeed" then
            if v < Settings.WalkSpeed then 
                -- If the game tries to slow us down, we ignore it
                return oldNewIndex(t, k, Settings.WalkSpeed)
            end
        end
        return oldNewIndex(t, k, v)
    end)

    setreadonly(mt, true)
end
pcall(InitiateBypass)

-- // 4. CHARACTER ENFORCEMENT //
local Eternal = {}
Eternal.__index = Eternal

function Eternal.new()
    local self = setmetatable({}, Eternal)
    self.Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    
    -- Detect when character respawns
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        self.Char = newChar
        self.Hum = newChar:WaitForChild("Humanoid")
        self:ApplyAttributes()
    end)

    return self
end

function Eternal:ApplyAttributes()
    if not self.Char then return end
    -- Force set attributes directly on the model
    local attrs = {"Stamina", "MaxStamina", "SprintAmount", "Energy"}
    for _, attr in pairs(attrs) do
        self.Char:SetAttribute(attr, Settings.ForceStamina)
    end
    self.Char:SetAttribute("Exhausted", false)
    self.Char:SetAttribute("Tired", false)
end

function Eternal:RunLoop()
    RunService.Heartbeat:Connect(function()
        if not Settings.Enabled or not self.Char or not self.Hum then return end
        
        -- High-frequency attribute locking
        self.Char:SetAttribute("Stamina", Settings.ForceStamina)
        self.Char:SetAttribute("Exhausted", false)

        -- Velocity Check: If we are moving and holding shift, ensure speed
        local isMoving = self.Hum.MoveDirection.Magnitude > 0
        local isSprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonL3)
        
        if isMoving and isSprinting then
            self.Hum.WalkSpeed = Settings.SprintSpeed
        elseif isMoving then
            self.Hum.WalkSpeed = Settings.WalkSpeed
        end
    end)
end

-- // 5. GUI CONSTRUCTION //
local function CreateUI()
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = UI_NAME

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 100)
    Main.Position = UDim2.new(0.5, -110, 0.1, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "ETERNAL FORSAKEN V2"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    local ToggleBtn = Instance.new("TextButton", Main)
    ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
    ToggleBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.Text = "SYSTEM: ACTIVE"
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
    ToggleBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ToggleBtn)

    -- Dragging Logic
    local d, ds, sp
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; sp = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)

    ToggleBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        ToggleBtn.Text = Settings.Enabled and "SYSTEM: ACTIVE" or "SYSTEM: DISABLED"
        ToggleBtn.TextColor3 = Settings.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 50, 50)
    end)
end

-- // 6. STARTUP //
local Engine = Eternal.new()
Engine:RunLoop()
CreateUI()

StarterGui:SetCore("SendNotification", {
    Title = "Eternal V2 Engaged",
    Text = "Bypassing Forsaken Exhaustion...",
    Duration = 5
})
