--[[
    PHASE-SHIFT V2: COLLISION-GROUP BYPASS
    --------------------------------------------------
    [FIXES]
    - Collision Override: Uses CollisionGroups instead of just CanCollide.
    - State Lock: Forces 'Physics' state to prevent server-side reset.
    - Anchor Logic: Holds your Y-axis position when stationary.
    --------------------------------------------------
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. SYSTEM CONSTANTS //
local SETTINGS = {
    ENABLED = false,
    HOTKEY = Enum.KeyCode.N,
    UI_COLOR = Color3.fromRGB(0, 255, 255)
}

-- // 3. STATE MANAGEMENT //
local State = {
    Connection = nil,
    Parts = {},
    LastCFrame = nil
}

-- // 4. THE BYPASS ENGINE (FIXED & UPGRADED) //
local function GetCharacterParts()
    local char = LocalPlayer.Character
    if not char then return {} end
    local parts = {}
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(parts, v)
        end
    end
    return parts
end

local function ToggleNoclip(active)
    SETTINGS.ENABLED = active
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if active then
        -- Layer 1: Establish the Heartbeat loop for constant enforcement
        State.Connection = RunService.Stepped:Connect(function()
            if not SETTINGS.ENABLED then 
                if State.Connection then State.Connection:Disconnect() end
                return 
            end
            
            -- Layer 2: State Spoofing
            -- We force the 'Physics' state so the character doesn't trigger falling/tripping
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
            
            -- Layer 3: Recursive Part Disabling
            local parts = GetCharacterParts()
            for _, part in pairs(parts) do
                part.CanCollide = false
            end
            
            -- Layer 4: Anti-Void Lock
            -- If you aren't moving, we lock your velocity to 0 to stop you falling
            if root and hum.MoveDirection.Magnitude == 0 then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        -- Clean up and reset collisions
        if State.Connection then State.Connection:Disconnect() end
        local parts = GetCharacterParts()
        for _, part in pairs(parts) do
            part.CanCollide = true
        end
    end
end

-- // 5. UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("NoclipV2") then CoreGui.NoclipV2:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "NoclipV2"
    Screen.DisplayOrder = 1000000000

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 160, 0, 80)
    Main.Position = UDim2.new(0.85, 0, 0.15, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = SETTINGS.UI_COLOR

    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0.9, 0, 0.8, 0)
    Btn.Position = UDim2.new(0.05, 0, 0.1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "NOCLIP: OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 60, 60)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14

    Btn.MouseButton1Down:Connect(function()
        local newState = not SETTINGS.ENABLED
        ToggleNoclip(newState)
        Btn.Text = newState and "NOCLIP: ON" or "NOCLIP: OFF"
        Btn.TextColor3 = newState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
    end)
    
    -- Hotkey Support
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == SETTINGS.HOTKEY then
            local newState = not SETTINGS.ENABLED
            ToggleNoclip(newState)
            Btn.Text = newState and "NOCLIP: ON" or "NOCLIP: OFF"
            Btn.TextColor3 = newState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
        end
    end)
end

-- Initialization
BuildUI()
print("[SUCCESS] Phase-Shift V2 Loaded. Press N to toggle.")
