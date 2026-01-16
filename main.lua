--[[ 
    BLIND SHOT: AVATAR RESTORATION
    - Bypasses the "Storage Hiding" mechanic (client-side only).
    - Forces real player models to render at their puppet (cube) positions.
    - Note: client scripts cannot access ServerStorage or other server-only locations.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Ensure LocalPlayer is available
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function RestoreAvatars()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Prefer searching the workspace (client can only see replicated instances).
            local realChar = player.Character or workspace:FindFirstChild(player.Name, true) or game:FindFirstChild(player.Name, true)

            if realChar and realChar:IsA("Model") then
                -- Force descendants visible
                for _, part in pairs(realChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.Transparency = 0
                            part.LocalTransparencyModifier = 0
                        end)
                    elseif part:IsA("Decal") then
                        pcall(function() part.Transparency = 0 end)
                    end

                    -- Show beams/trails/anything with "laser" in the name
                    if part:IsA("Beam") or part:IsA("Trail") then
                        pcall(function() part.Enabled = true end)
                    elseif type(part.Name) == "string" and part.Name:lower():find("laser") then
                        pcall(function() if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 0 end end)
                    end
                end

                -- Clean up cube puppets near the real head
                local head = realChar:FindFirstChild("Head")
                if head then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name == "Part" and obj.Size and obj.Size.Y > 3 then
                            if (obj.Position - head.Position).Magnitude < 5 then
                                pcall(function()
                                    obj.Transparency = 1
                                    -- Some properties may not exist on older clients/parts; guard with pcall
                                    if obj.CanQuery ~= nil then
                                        obj.CanQuery = false
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Hide black/flash UI frames
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("Frame") and type(v.Name) == "string" then
                local lname = v.Name:lower()
                if lname:find("blind") or lname:find("black") then
                    pcall(function() v.Visible = false end)
                end
            end
        end
    end
end

-- Run every heartbeat
RunService.Heartbeat:Connect(function()
    pcall(RestoreAvatars)

    -- Lock stamina/energy attributes if character exists
    if LocalPlayer.Character then
        pcall(function()
            LocalPlayer.Character:SetAttribute("Stamina", 100)
            LocalPlayer.Character:SetAttribute("Energy", 100)
        end)
    end
end)

print("Avatar Restoration Loaded. Looking for hidden models...")
