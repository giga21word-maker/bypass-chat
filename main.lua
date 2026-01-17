-- // CHRONOS ALPHA 0.0.1 //
-- STATUS: Initial Build
-- FOCUS: Stable Door Interaction & Position Syncing

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. ALPHA CONFIGURATION //
local ALPHA_CONFIG = {
    AUTO_SKIP = false,
    DETECTION_DIST = 18,
    VERSION = "0.0.1-ALPHA",
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false
}

-- // 2. SMART INTERACTION //
local function AlphaSkip(doorModel)
    if Internal.IsProcessing then return end
    Internal.IsProcessing = true

    -- Trigger Interaction (Unlock/Open)
    -- We search for the prompt within the door model
    local prompt = doorModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        task.wait(0.2) -- Alpha buffer for server response
    end

    -- Position Sync (The Skip)
    -- Instead of a big TP, we move to the door's exit point
    local nextRoomNum = tonumber(doorModel.Parent.Name) + 1
    local nextRoom = Internal.Rooms:WaitForChild(tostring(nextRoomNum), 3)

    if nextRoom then
        -- Move to the entrance of the next room
        local targetCF = nextRoom:GetModelCFrame()
        Root.CFrame = targetCF + Vector3.new(0, 2, 0)
        print("[ALPHA] Synced to Room: " .. nextRoom.Name)
    end

    task.wait(0.5)
    Internal.IsProcessing = false
end

-- // 3. MONITORING LOOP //
task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        if ALPHA_CONFIG.AUTO_SKIP then
            -- Find the door in the latest room
            for _, room in pairs(Internal.Rooms:GetChildren()) do
                local door = room:FindFirstChild("Door") or room:FindFirstChild("DoorModel")
                if door then
                    local primary = door:FindFirstChild("Door") or door.PrimaryPart
                    if primary and (Root.Position - primary.Position).Magnitude < ALPHA_CONFIG.DETECTION_DIST then
                        AlphaSkip(door)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- // 4. MINIMALIST ALPHA UI //
local function BuildAlphaUI()
    if CoreGui:FindFirstChild("ChronosAlpha") then CoreGui.ChronosAlpha:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosAlpha"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 180, 0, 80)
    Main.Position = UDim2.new(0.5, -90, 0.05, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Main)
    
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -20, 1, -20)
    B.Position = UDim2.new(0, 10, 0, 10)
    B.Text = "ALPHA SKIP: OFF"
    B.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Code
    Instance.new("UICorner", B)

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.AUTO_SKIP = not ALPHA_CONFIG.AUTO_SKIP
        B.Text = ALPHA_CONFIG.AUTO_SKIP and "ALPHA SKIP: ON" or "ALPHA SKIP: OFF"
        B.TextColor3 = ALPHA_CONFIG.AUTO_SKIP and Color3.new(0, 1, 0.7) or Color3.new(1, 1, 1)
    end)
end

BuildAlphaUI()
