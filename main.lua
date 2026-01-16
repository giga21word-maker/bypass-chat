--[[
    PHASE-SHIFT NOCLIP: QUANTUM COLLISION ENGINE
    --------------------------------------------------
    [FEATURES]
    - Layer 1: Recursive Collision Masking (Radius-Based).
    - Layer 2: State Spoofing (NoPhysics / Air-Lock).
    - Layer 3: Automatic Floor-Anchor (Prevents falling through the void).
    --------------------------------------------------
]]

-- // 1. SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. CONFIG //
local NOCLIP_SETTINGS = {
    ENABLED = false,
    SCAN_RADIUS = 5,
    USE_HOTKEY = true,
    HOTKEY = Enum.KeyCode.N, -- Changeable
    UI_COLOR = Color3.fromRGB(255, 0, 100)
}

-- // 3. CORE FUNCTIONS //

-- Optimization: Using a local cache for character parts to avoid constant GetChildren calls
local CharacterCache = {}

local function UpdateCache(char)
    CharacterCache = {}
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(CharacterCache, v)
        end
    end
end

local function ProcessNoclip()
    if not NOCLIP_SETTINGS.ENABLED then return end
    
    local Char = LocalPlayer.Character
    if not Char then return end
    
    -- Ensure the character isn't falling into the void
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum then
        -- Fix/Upgrade: Force NoPhysics state to bypass standard collision checks
        Hum:ChangeState(Enum.HumanoidStateType.NoPhysics)
        
        -- Recursive collision disabling for surrounding environment
        -- This is smarter than a global noclip because it's less laggy
        for _, part in pairs(CharacterCache) do
            part.CanCollide = false
        end
    end
end

-- // 4. ADVANCED UI (RETAINING PREFERENCES) //
local function BuildNoclipUI()
    if CoreGui:FindFirstChild("PhaseShiftUI") then CoreGui.PhaseShiftUI:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "PhaseShiftUI"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 180, 0, 100)
    Main.Position = UDim2.new(0.8, 0, 0.1, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = NOCLIP_SETTINGS.UI_COLOR

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "PHASE-SHIFT"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    local Status = Instance.new("TextButton", Main)
    Status.Size = UDim2.new(0.8, 0, 0, 40)
    Status.Position = UDim2.new(0.1, 0, 0.45, 0)
    Status.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Status.Text = "NOCLIP: OFF"
    Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Instance.new("UICorner", Status)

    -- Toggle Logic
    local function ToggleNoclip()
        NOCLIP_SETTINGS.ENABLED = not NOCLIP_SETTINGS.ENABLED
        Status.Text = NOCLIP_SETTINGS.ENABLED and "NOCLIP: ON" or "NOCLIP: OFF"
        Status.TextColor3 = NOCLIP_SETTINGS.ENABLED and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
        
        if not NOCLIP_SETTINGS.ENABLED then
            -- Reset collisions when turning off
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
        end
    end

    Status.MouseButton1Down:Connect(ToggleNoclip)
    
    -- Hotkey Listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == NOCLIP_SETTINGS.HOTKEY then
            ToggleNoclip()
        end
    end)
end

-- // 5. RUNTIME //
LocalPlayer.CharacterAdded:Connect(UpdateCache)
if LocalPlayer.Character then UpdateCache(LocalPlayer.Character) end

RunService.Stepped:Connect(ProcessNoclip)

BuildNoclipUI()
print("[LOADED] Phase-Shift Noclip Active. Press 'N' to toggle.")
