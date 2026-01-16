--[[
    PROJECT FORSAKEN: ETERNAL (v1.0)
    Infinite Stamina & Anti-Exhaustion Engine
    
    [FEATURES]
    - Dynamic Attribute Locking (Bypasses local drain)
    - Anti-Exhaustion State Freeze
    - Multi-Method Support (Handles both Attributes and ObjectValues)
    - Optimized RunService Heartbeat
]]

-- // 1. INITIALIZATION //
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. CONFIGURATION //
local Settings = {
    Enabled = true,
    LockValue = 100, -- Standard Max Stamina
    Methods = {"Attribute", "ValueObject", "DataFolder"},
    ToggleKey = Enum.KeyCode.RightShift -- Shift is for sprint, so RightShift is safe for toggle
}

-- // 3. CORE LOGIC ENGINE //
local Eternal = {
    Connection = nil,
    Character = nil,
    Humanoid = nil
}

-- This function handles the actual "Infinite" logic
function Eternal:ApplyStaminaLock()
    if not self.Character then return end

    -- METHOD A: Attributes (Most likely for Forsaken)
    -- We set it to 100 and also ensure "MaxStamina" is locked
    if self.Character:GetAttribute("Stamina") then
        self.Character:SetAttribute("Stamina", Settings.LockValue)
        
        -- Bypass the "Exhausted" state if the game uses it
        if self.Character:GetAttribute("Exhausted") ~= nil then
            self.Character:SetAttribute("Exhausted", false)
        end
    end

    -- METHOD B: Data Folder (Used in some Forsaken versions/clones)
    local data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("leaderstats")
    if data then
        local stam = data:FindFirstChild("Stamina")
        if stam and stam:IsA("NumberValue") then
            stam.Value = Settings.LockValue
        end
    end

    -- METHOD C: State Interceptor
    -- Some versions of the game tie stamina to the Humanoid's metadata
    if self.Humanoid then
        if self.Humanoid:GetAttribute("Stamina") then
            self.Humanoid:SetAttribute("Stamina", Settings.LockValue)
        end
    end
end

-- // 4. CHARACTER MONITORING //
-- We need to re-hook the script every time you respawn
local function OnCharacterAdded(char)
    Eternal.Character = char
    Eternal.Humanoid = char:WaitForChild("Humanoid")
    
    -- Force a refresh on the attributes
    task.wait(1)
    if char:GetAttribute("Stamina") then
        Settings.LockValue = char:GetAttribute("MaxStamina") or 100
    end
end

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- // 5. THE RUNTIME LOOP //
-- Using Heartbeat because it runs after physics, making it harder for the game to override us
Eternal.Connection = RunService.Heartbeat:Connect(function()
    if Settings.Enabled then
        Eternal:ApplyStaminaLock()
    end
end)

-- // 6. USER INTERFACE (PC & MOBILE) //
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "Eternal_Stamina"

-- Small Status Indicator
local StatusFrame = Instance.new("Frame", Screen)
StatusFrame.Size = UDim2.new(0, 180, 0, 40)
StatusFrame.Position = UDim2.new(0.5, -90, 0, 50)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusFrame.BorderSizePixel = 0
Instance.new("UICorner", StatusFrame)

local StatusLabel = Instance.new("TextLabel", StatusFrame)
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ETERNAL STAMINA: ON"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14

-- Mobile Toggle Button
local MobileToggle = Instance.new("TextButton", Screen)
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(1, -70, 0.5, -25)
MobileToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MobileToggle.Text = "STAM"
MobileToggle.TextColor3 = Color3.new(1,1,1)
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.Visible = UserInputService.TouchEnabled
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)

-- // 7. INTERACTION HANDLERS //
local function Toggle()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        StatusLabel.Text = "ETERNAL STAMINA: ON"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        StatusLabel.Text = "ETERNAL STAMINA: OFF"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.ToggleKey then
        Toggle()
    end
end)

MobileToggle.MouseButton1Click:Connect(Toggle)

-- Dragging logic for the status bar
local drag, ds, sp
StatusFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; ds = i.Position; sp = StatusFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - ds
        StatusFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() drag = false end)

print("[ETERNAL] Forsaken Stamina Engine Loaded")
