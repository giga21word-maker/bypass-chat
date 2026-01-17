-- // PROJECT EGOR ALPHA 0.0.1 //
-- STATUS: Leg-Spin Initial Build
-- FEATURE: Animation Overclock + Physics Drag

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- // 1. EGOR CONFIGURATION //
local EGOR_CONFIG = {
    ENABLED = true,
    LEG_SPEED = 15, -- How fast the legs spin (Funny range: 10 - 25)
    WALK_SPEED = 4, -- How slow you actually move (Egor range: 2 - 6)
    VERSION = "0.0.1-EGOR"
}

-- // 2. ANIMATION OVERRIDE ENGINE //
local function ApplyEgorEffect()
    -- Get all currently playing animations
    local PlayingAnims = Humanoid:GetPlayingAnimationTracks()
    
    for _, track in pairs(PlayingAnims) do
        -- Check if it's a "Walk" or "Run" animation
        if track.Animation.AnimationId:find("walk") or track.Animation.AnimationId:find("run") or track.Name:lower():find("run") or track.Name:lower():find("walk") then
            -- The "Egor" Magic:
            -- We set the speed of the animation to be huge
            track:AdjustSpeed(EGOR_CONFIG.LEG_SPEED)
        end
    end
    
    -- Set the actual movement speed to be very slow
    Humanoid.WalkSpeed = EGOR_CONFIG.WALK_SPEED
end

-- // 3. RUNTIME SYNC //
-- We use Stepped to ensure the animation speed stays high even if the game tries to reset it
RunService.Stepped:Connect(function()
    if EGOR_CONFIG.ENABLED and Humanoid.Health > 0 then
        -- Only apply when moving
        if Humanoid.MoveDirection.Magnitude > 0 then
            ApplyEgorEffect()
        else
            -- Reset speed when standing still so it doesn't look weird idle
            Humanoid.WalkSpeed = 16
        end
    end
end)

-- // 4. CLEANUP ON DEATH //
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
end)

print("EGOR DRIVE DEPLOYED: LEGS SET TO " .. EGOR_CONFIG.LEG_SPEED)
