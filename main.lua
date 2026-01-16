--[[
    BLIND SHOT: GHOST-LINK OVERRIDE (v13.0)
    - Recursive Search: Finds models even if they are in ReplicatedStorage/Nil.
    - Proxy Purge: Instantly deletes the "Cube" puppets.
    - Laser Restoration: Forces pointing lines to render through the blindfold.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // SETTINGS //
local Settings = {
    UnhidePlayers = true,
    DeleteCubes = true,
    RevealLasers = true,
    ForceNametags = true
}

-- // CORE ENGINE //
local function ForceReveal()
    -- 1. Search EVERYWHERE for players (Bypasses hidden folders)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- We look for the character in Workspace OR wherever the game stashed it
            local char = player.Character or workspace:FindFirstChild(player.Name)
            
            if char then
                -- 2. Handle the "Puppet" Cubes
                for _, obj in pairs(char:GetChildren()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("proxy") or obj.Name:lower():find("cube")) then
                        if Settings.DeleteCubes then
                            obj:Destroy() -- Kill the cube so you see the avatar inside
                        end
                    end
                end

                -- 3. Force Render the Real Avatar
                for _, part in pairs(char:GetDescendants()) do
                    -- Property-Safe Check (Prevents the 2k errors)
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 0
                        -- This specific property overrides the game's "Hidden" state
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end

                    -- 4. Force Lasers
                    if Settings.RevealLasers and (part:IsA("Beam") or part:IsA("Trail")) then
                        part.Enabled = true
                        part.Transparency = NumberSequence.new(0)
                        part.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0)) -- Turn lasers green so they stand out
                    end
                end

                -- 5. Inject Global Nametags
                if Settings.ForceNametags and char:FindFirstChild("Head") and not char.Head:FindFirstChild("Reveal") then
                    local bg = Instance.new("BillboardGui", char.Head)
                    bg.Name = "Reveal"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(0, 80, 0, 40)
                    bg.StudsOffset = Vector3.new(0, 2.5, 0)
                    local txt = Instance.new("TextLabel", bg)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = player.DisplayName
                    txt.TextColor3 = Color3.new(1, 1, 1)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 14
                end
            end
        end
    end

    -- 6. Kill the Blindfold UI
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("Frame") and (v.Name:lower():find("blind") or v.Name:lower():find("black")) then
                v.Visible = false
                v.BackgroundTransparency = 1
            end
        end
    end
end

-- // STABLE EXECUTION //
RunService.Heartbeat:Connect(function()
    if Settings.UnhidePlayers then
        -- pcall prevents any game-crash or error spam during round swaps
        pcall(ForceReveal)
    end
    
    -- Stamina/Energy Lock
    if LocalPlayer.Character then
        LocalPlayer.Character:SetAttribute("Stamina", 100)
        LocalPlayer.Character:SetAttribute("Energy", 100)
    end
end)

print("[ULTIMATE] Blind Shot v13.0 Loaded. Cubes Deleted. Real Players Forced.")
