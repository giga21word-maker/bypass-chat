.")--[[ 
    BLIND SHOT: AVATAR RESTORATION
    - Bypasses the "Storage Hiding" mechanic.
    - Forces real player models to render at their puppet (cube) positions.
    - Zero bluff, zero console errors.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // THE RESTORATION ENGINE //
local function RestoreAvatars()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- 1. Find the player's 'True' character (often stashed in Storage or hidden)
            -- We search the entire game for a model with the player's name
            local realChar = player.Character or game:FindFirstChild(player.Name, true)
            
            if realChar and realChar:IsA("Model") then
                -- 2. Force it to be visible
                for _, part in pairs(realChar:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 0
                        -- This is the property that overrides "Hidden" states
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                    
                    -- 3. Show the Gun/Laser specifically
                    if part:IsA("Beam") or part:IsA("Trail") or part.Name:find("Laser") then
                        if part:IsA("Beam") or part:IsA("Trail") then
                            part.Enabled = true
                        else
                            part.Transparency = 0
                        end
                    end
                end
                
                -- 4. Clean up the Cubes
                -- If we find a part that is just a big box at the player's location, hide it
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Name == "Part" and obj.Size.Y > 3 then
                        -- Check if it's near the player to ensure we don't delete the map
                        local head = realChar:FindFirstChild("Head")
                        if head and (obj.Position - head.Position).Magnitude < 5 then
                            obj.Transparency = 1
                            obj.CanQuery = false
                        end
                    end
                end
            end
        end
    end
    
    -- 5. Bypass the black screen UI
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("Frame") and (v.Name:lower():find("blind") or v.Name:lower():find("black")) then
                v.Visible = false
            end
        end
    end
end

-- // RUNTIME //
RunService.Heartbeat:Connect(function()
    pcall(RestoreAvatars)
    
    -- Lock Stamina/Energy as requested in previous instructions
    if LocalPlayer.Character then
        LocalPlayer.Character:SetAttribute("Stamina", 100)
        LocalPlayer.Character:SetAttribute("Energy", 100)
    end
end)

print("Avatar Restoration Loaded. Looking for hidden models...")
