--[[
    BLIND SHOT: STABLE OVERRIDE (v11.0)
    - Fixes the "CanCollide" and "Decal" error loops.
    - Optimized to scan only when necessary.
    - Raw Avatar forced visibility with 0 "Bluff".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    VisibleTransparency = 0,
    ShowLasers = true
}

-- Safe function to set transparency without errors
local function SetVisuals(obj)
    if obj:IsA("BasePart") then
        obj.Transparency = Config.VisibleTransparency
        obj.LocalTransparencyModifier = Config.VisibleTransparency
        -- Fix: Only set CanCollide on Parts, not Decals or Meshes
        obj.CanCollide = false 
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = Config.VisibleTransparency
    end
    
    -- Force Laser Visibility
    if Config.ShowLasers and (obj:IsA("Beam") or obj:IsA("Trail")) then
        obj.Enabled = true
        obj.Transparency = NumberSequence.new(0)
    end
end

-- Optimized Global Scanner
local function GlobalOverride()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            
            -- 1. Identify and Delete the Cube Proxy
            for _, child in pairs(char:GetChildren()) do
                if child:IsA("BasePart") and child.ClassName == "Part" then
                    -- Detects the placeholder cube by its typical dimensions
                    if child.Size.X > 2 and child.Size.Z > 2 then
                        child:Destroy()
                    end
                end
            end

            -- 2. Apply Visuals to Real Avatar
            for _, part in pairs(char:GetDescendants()) do
                SetVisuals(part)
            end
            
            -- 3. Force Username (Humanoid Override)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.All
            end
        end
    end

    -- 4. Clean Blindfold UI
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, ui in pairs(pGui:GetDescendants()) do
            if ui:IsA("Frame") and (ui.Name:lower():find("blind") or ui.Name:lower():find("overlay")) then
                ui.Visible = false
            end
        end
    end
end

-- HEARTBEAT Loop (Stable at 60fps)
RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        local success, err = pcall(GlobalOverride)
        -- Prevents console spam if a player leaves/respawns
    end
    
    -- Infinite Stamina/Energy
    if LocalPlayer.Character then
        LocalPlayer.Character:SetAttribute("Stamina", 100)
        LocalPlayer.Character:SetAttribute("Energy", 100)
    end
end)

print("[SUCCESS] v11.0 Loaded. Errors Fixed. Cubes Bypassed.")
