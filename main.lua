--[[
    VELOCITY-SYNC SPEED CONTROLLER
    - Uses CFrame Interpolation for smoother movement.
    - Optimized to prevent physics stuttering.
    - Toggleable via the [K] key.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local Settings = {
    Enabled = false,
    SpeedMultiplier = 2.5, -- Adjust this: 1.0 is normal, 2.5 is fast
    ToggleKey = Enum.KeyCode.K
}

-- // CORE SPEED ENGINE //
local function ApplySpeed()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

    if RootPart and Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
        -- We move the CFrame in the direction the player is walking
        local MoveVector = Humanoid.MoveDirection * (Settings.SpeedMultiplier / 5)
        RootPart.CFrame = RootPart.CFrame + MoveVector
    end
end

-- // INPUT TOGGLE //
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Settings.ToggleKey then
        Settings.Enabled = not Settings.Enabled
        print("Speed Hack Status: " .. (Settings.Enabled and "ENABLED" or "DISABLED"))
    end
end)

-- // RUNTIME //
RunService.Heartbeat:Connect(function()
    if Settings.Enabled then
        local success, err = pcall(ApplySpeed)
    end
end)

-- Ensure Stamina stays locked for Blind Shot as requested
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        LocalPlayer.Character:SetAttribute("Stamina", 100)
        LocalPlayer.Character:SetAttribute("Energy", 100)
    end
end)

print("Speed Controller Loaded. Press [K] to toggle.")
