--[[
    BLIND SHOT: ULTIMATE REVEAL & ETERNAL STAMINA (v6.0)
    Target Game: Blind Shot (MisfitsBStoo)
    
    [CORE FEATURES]
    - Ghost Reveal: Forces all invisible characters to be 100% visible.
    - Highlight ESP: Outlines players in bright red (Visible through UI overlays).
    - Blindfold Bypass: Detects and deletes the black screen GUI.
    - Eternal Energy: Infinite Dash and Ability power for 2026 mechanics.
]]

-- // 1. SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. CONFIGURATION //
local Config = {
    Enabled = true,
    RevealPlayers = true,   -- The "Unhider"
    InfiniteEnergy = true,  -- Infinite Dash/Stamina
    RemoveBlindfold = true, -- Removes the Black Overlay
    ESPColor = Color3.fromRGB(255, 0, 50)
}

-- // 3. VISION & REVEAL ENGINE //
-- This is the specific function to "Unhide" players
local function UnhidePlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            
            -- Method A: Force Visibility (Bypasses LocalTransparencyModifier)
            -- The game uses this to hide players from your local camera
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    if Config.RevealPlayers then
                        -- Setting this to 0 ensures the engine renders the part
                        part.LocalTransparencyModifier = 0
                        part.Transparency = 0
                    end
                end
            end

            -- Method B: Highlight ESP
            -- This makes them glow even if the game tries other hiding tricks
            local highlight = char:FindFirstChild("RevealHighlight")
            if Config.RevealPlayers then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "RevealHighlight"
                    highlight.Parent = char
                    highlight.FillColor = Config.ESPColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.4
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

-- // 4. GUI & OVERLAY BYPASS //
local function BypassBlindfold()
    if not Config.RemoveBlindfold then return end
    
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        -- Searches for the specific frames the game uses to black out your screen
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("Frame") or v:IsA("ImageLabel") then
                -- Common names used in the 2026 version of Blind Shot
                if v.Name:lower():find("blind") or v.Name:lower():find("overlay") or v.Name:lower():find("blackout") then
                    v.Visible = false
                    v.BackgroundTransparency = 1
                end
            end
        end
    end
end

-- // 5. ENERGY & STAMINA SYSTEM //
local function LockEnergy()
    local char = LocalPlayer.Character
    if not char or not Config.InfiniteEnergy then return end

    -- Enforce Attributes (The game uses these for Dashing and Special Abilities)
    char:SetAttribute("Energy", 100)
    char:SetAttribute("Stamina", 100)
    char:SetAttribute("CanDash", true)

    -- Fix for the 2026 cooldown bug where abilities get stuck
    local cooldown = char:FindFirstChild("AbilityCooldown")
    if cooldown then cooldown.Value = 0 end
end

-- // 6. RUNTIME CONTROL //
-- We use RenderStepped for Vision and Heartbeat for Physics/Attributes
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        UnhidePlayers()
        BypassBlindfold()
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        LockEnergy()
    end
end)

-- // 7. INTERFACE //
local function CreateUI()
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "BlindShot_Reveal_v6"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 240, 0, 180)
    Main.Position = UDim2.new(0.1, 0, 0.5, -90)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "REVEAL MASTER v6"
    Title.TextColor3 = Color3.fromRGB(255, 50, 50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1

    local function MakeToggle(name, configKey, yPos)
        local btn = Instance.new("TextButton", Main)
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.95
        btn.Text = name .. ": ON"
        btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        btn.Font = Enum.Font.Gotham
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            btn.Text = name .. (Config[configKey] and ": ON" or ": OFF")
            btn.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
        end)
    end

    MakeToggle("Reveal Players", "RevealPlayers", 45)
    MakeToggle("Remove Blindfold", "RemoveBlindfold", 90)
    MakeToggle("Inf Dash/Energy", "InfiniteEnergy", 135)

    -- Drag Logic
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

CreateUI()
print("[BLIND SHOT] Reveal Script v6.0 Initialized. Good luck!")
