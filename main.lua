--[[
    BLIND SHOT: RAW AVATAR OVERRIDE (v10.0)
    - No fluff, no attributes, just raw character rendering.
    - Forces Real Avatars to their respective Cube positions.
    - Deletes all Proxy/Cube models globally.
]]

-- // SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- // CONFIG //
local SETTINGS = {
    ENABLED = true,
    FORCE_TRANSPARENCY = 0,
    SHOW_LASERS = true
}

-- // CORE OVERRIDE ENGINE //
local function GlobalOverride()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            
            -- 1. Locate the Player's Real Character
            -- Sometimes the game moves it out of Workspace
            local char = player.Character
            if char then
                -- 2. Delete the Cubes (Proxy Models)
                -- We look for anything that isn't a standard character part but is inside the model
                for _, obj in pairs(char:GetChildren()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("cube") or obj.Name:lower():find("proxy") or obj.Name:lower():find("part")) then
                        if obj.Size.X > 2 and obj.Size.Y > 2 then -- Identifies the giant placeholder cube
                            obj:Destroy()
                        end
                    end
                end

                -- 3. Force Render Real Avatar Parts
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        -- Override the game's hiding system
                        part.Transparency = SETTINGS.FORCE_TRANSPARENCY
                        part.LocalTransparencyModifier = SETTINGS.FORCE_TRANSPARENCY
                        part.CanCollide = false -- Prevent physics glitches
                    end

                    -- 4. Force Render the Gun and Lasers
                    if SETTINGS.SHOW_LASERS then
                        if part:IsA("Beam") or part:IsA("Trail") then
                            part.Enabled = true
                            part.Transparency = NumberSequence.new(0)
                        elseif part.Name:lower():find("laser") then
                            part.Transparency = 0
                        end
                    end
                end

                -- 5. Force Username Visibility
                local head = char:FindFirstChild("Head")
                if head then
                    local human = char:FindFirstChildOfClass("Humanoid")
                    if human then
                        human.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.All
                        human.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
                    end
                end
            end
        end
    end

    -- 6. Kill the Blindfold Screen
    local localGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if localGui then
        for _, v in pairs(localGui:GetDescendants()) do
            if v:IsA("Frame") and (v.Name:lower():find("blind") or v.Name:lower():find("black")) then
                v.Visible = false
            end
        end
    end
end

-- // RUNTIME //
-- RenderStepped runs before every frame is drawn, ensuring the game cannot hide them
RunService.RenderStepped:Connect(function()
    if SETTINGS.ENABLED then
        GlobalOverride()
    end
end)

-- // INFINITE STAMINA LOCK //
RunService.Heartbeat:Connect(function()
    local myChar = Players.LocalPlayer.Character
    if myChar then
        myChar:SetAttribute("Stamina", 100)
        myChar:SetAttribute("Energy", 100)
    end
end)

print("[OVERRIDE] Blind Shot v10.0: Cubes Deleted. Avatars Forced.")
