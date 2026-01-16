--[[
    BLIND SHOT: TRUE VISION (v9.0)
    - Automatically identifies and removes "Proxy Cubes"
    - Unhides real Avatars, Clothing, and Gun Skins
    - Forces Lasers/Beams to be 100% visible
    - Pins Usernames to heads
]]

-- // 1. SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // 2. CONFIG //
local Settings = {
    RemoveCubes = true,    -- Deletes/Hides the placeholder boxes
    RevealAvatars = true,  -- Shows real skins/clothes
    ForceLasers = true,    -- Shows where they are pointing
    InfiniteEnergy = true
}

-- // 3. THE REVEAL ENGINE //
local function RevealEverything()
    -- Scan all players for their real models
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                -- 1. UNHIDE AVATAR & GUNS
                for _, part in pairs(char:GetDescendants()) do
                    -- Force visibility on real body parts and tools (guns)
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 0
                        part.LocalTransparencyModifier = 0
                    end

                    -- Force visibility on the Laser Beams
                    if Settings.ForceLasers and (part:IsA("Beam") or part:IsA("Trail") or part.Name:find("Laser")) then
                        if part:IsA("Beam") or part:IsA("Trail") then
                            part.Enabled = true
                            part.Transparency = NumberSequence.new(0)
                        else
                            part.Transparency = 0
                        end
                    end
                end

                -- 2. REMOVE THE CUBES
                -- The game usually names these 'Proxy', 'Fake', 'Cube', or 'Box'
                local proxy = char:FindFirstChild("Proxy") or char:FindFirstChild("Cube") or char:FindFirstChild("Box")
                if proxy then
                    proxy:Destroy() -- Deletes the cube so it doesn't block the avatar
                end
                
                -- Catch-all for any part that is a giant cube covering the player
                for _, p in pairs(char:GetChildren()) do
                    if p:IsA("BasePart") and p.ClassName == "Part" and p.Size.Y > 4 then
                        p.Transparency = 1 -- Hide the big placeholder box
                    end
                end

                -- 3. USERNAME TAGS
                if not char:FindFirstChild("Head"):FindFirstChild("TrueName") then
                    local bg = Instance.new("BillboardGui", char.Head)
                    bg.Name = "TrueName"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(0, 100, 0, 50)
                    bg.StudsOffset = Vector3.new(0, 3, 0)
                    local txt = Instance.new("TextLabel", bg)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = player.DisplayName
                    txt.TextColor3 = Color3.new(1, 1, 1)
                    txt.TextStrokeTransparency = 0
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 14
                end
            end
        end
    end
end

-- // 4. STAMINA & ENERGY //
local function LockStamina()
    local char = LocalPlayer.Character
    if char and Settings.InfiniteEnergy then
        char:SetAttribute("Energy", 100)
        char:SetAttribute("Stamina", 100)
        char:SetAttribute("CanDash", true)
    end
end

-- // 5. UI BYPASS //
local function ClearBlindfold()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("Frame") and (v.Name == "Blindfold" or v.Name == "Overlay" or v.Name == "Blackout") then
                v.Visible = false
                v.BackgroundTransparency = 1
            end
        end
    end
end

-- // 6. RUNTIME //
RunService.RenderStepped:Connect(function()
    RevealEverything()
    ClearBlindfold()
    LockStamina()
end)

-- // 7. UI //
local function BuildUI()
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "BlindShot_TrueVision"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 220, 0, 150)
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "TRUE VISION v9"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.Font = Enum.Font.FredokaOne
    Title.BackgroundTransparency = 1

    local function AddBtn(name, key, y)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0.9, 0, 0, 35)
        b.Position = UDim2.new(0.05, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = name .. ": ON"
        b.TextColor3 = Color3.fromRGB(0, 255, 120)
        b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b)

        b.MouseButton1Click:Connect(function()
            Settings[key] = not Settings[key]
            b.Text = name .. (Settings[key] and ": ON" or ": OFF")
            b.TextColor3 = Settings[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 50, 50)
        end)
    end

    AddBtn("Remove Cubes", "RemoveCubes", 45)
    AddBtn("Show Real Avatars", "RevealAvatars", 90)

    -- Draggable
    local d, ds, sp
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

BuildUI()
print("[TRUE VISION] Cubes removed. Real avatars forced.")
