-- // CHRONOS ALPHA 0.0.2 //
-- STATUS: Anti-TP-Back Patch
-- FOCUS: Position Validation & Sift-Sliding

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
    DETECTION_DIST = 15,
    SLIDE_SPEED = 0.08, -- Time between slide steps (lower = faster)
    VERSION = "0.0.2-ALPHA",
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false
}

-- // 2. THE SIFT-SLIDE (BYPASS) //
local function SiftSlide(targetCF)
    local startCF = Root.CFrame
    local steps = 6 -- Move in 6 mini-steps to look like walking/lag
    
    for i = 1, steps do
        local alpha = i / steps
        Root.CFrame = startCF:Lerp(targetCF, alpha)
        Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Kill momentum to bypass AC
        task.wait(ALPHA_CONFIG.SLIDE_SPEED)
    end
end

-- // 3. SMART INTERACTION //
local function AlphaSkip(doorModel)
    if Internal.IsProcessing then return end
    
    -- Check if door is already open to avoid redundant skips
    if doorModel:GetAttribute("Opened") then return end
    
    Internal.IsProcessing = true

    -- Trigger Interaction
    local prompt = doorModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        -- Wait for the game to register the door is opening
        repeat task.wait() until doorModel:GetAttribute("Opened") or not ALPHA_CONFIG.AUTO_SKIP
    end

    -- SIFT-SLIDE TO NEXT ROOM
    local nextRoomNum = tonumber(doorModel.Parent.Name) + 1
    local nextRoom = Internal.Rooms:WaitForChild(tostring(nextRoomNum), 3)

    if nextRoom then
        -- Find the entrance point of the next room
        local entrance = nextRoom:FindFirstChild("Entrance") or nextRoom.PrimaryPart
        if entrance then
            SiftSlide(entrance.CFrame + Vector3.new(0, 2, 0))
            print("[ALPHA] Sifted to Room: " .. nextRoom.Name)
        end
    end

    task.wait(0.3)
    Internal.IsProcessing = false
end

-- // 4. MONITORING LOOP //
task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        if ALPHA_CONFIG.AUTO_SKIP then
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
        task.wait(0.1)
    end
end)

-- // 5. UI //
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
    B.Text = "PATCH 0.0.2: OFF"
    B.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Code
    Instance.new("UICorner", B)

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.AUTO_SKIP = not ALPHA_CONFIG.AUTO_SKIP
        B.Text = ALPHA_CONFIG.AUTO_SKIP and "ALPHA SKIP: ON" or "ALPHA SKIP: OFF"
        B.TextColor3 = ALPHA_CONFIG.AUTO_SKIP and Color3.new(1, 0.8, 0) or Color3.new(1, 1, 1)
    end)
end

BuildAlphaUI()
