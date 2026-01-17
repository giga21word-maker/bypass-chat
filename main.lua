-- // CHRONOS ALPHA 0.0.5 //
-- STATUS: Anti-Dupe + Inventory Verification
-- FOCUS: Logical Consistency & Seamless Flow

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. ALPHA CONFIGURATION //
local ALPHA_CONFIG = {
    AUTO_SKIP = false,
    VERSION = "0.0.5-ALPHA",
    RANGE = 22,
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false,
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 2. SMART SENSORS (FAKE DOOR DETECTION) //
local function IsRealDoor(door)
    -- Fake doors (Dupe) usually have a "Fake" tag or lack the room number attribute
    -- Real doors are children of the room they belong to
    local roomNum = tonumber(door.Parent.Name)
    local doorLabel = door:FindFirstChild("Sign", true) or door:FindFirstChild("Number", true)
    
    if doorLabel and doorLabel:IsA("TextLabel") or doorLabel:IsA("SurfaceGui") then
        local num = tonumber(doorLabel.Text)
        if num and num ~= roomNum + 1 then
            return false -- This is a Dupe door!
        end
    end
    return true
end

-- // 3. INVENTORY CHECKER //
local function HasKey()
    return LocalPlayer.Backpack:FindFirstChild("Key") or Character:FindFirstChild("Key")
end

-- // 4. AUTOMATED SEQUENCE //
local function AlphaSequence(room)
    if Internal.IsProcessing then return end
    
    local doorModel = room:FindFirstChild("Door") or room:FindFirstChild("DoorModel")
    if not doorModel or not IsRealDoor(doorModel) then return end
    if doorModel:GetAttribute("Opened") then return end
    
    Internal.IsProcessing = true
    
    -- SEARCH FOR KEY IF LOCKED
    local isLocked = doorModel:FindFirstChild("Lock", true)
    if isLocked and not HasKey() then
        for _, v in pairs(room:GetDescendants()) do
            if v.Name == "Key" and v:FindFirstChildOfClass("ProximityPrompt") then
                fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                repeat task.wait(0.1) until HasKey() or not ALPHA_CONFIG.AUTO_SKIP
                break
            end
        end
    end

    -- UNLOCK AND OPEN
    local prompt = doorModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        -- Wait for server to confirm "Opened"
        local t = 0
        while not doorModel:GetAttribute("Opened") and t < 25 do
            task.wait(0.1)
            t = t + 1
        end
    end

    -- TELEPORT TO ENTRANCE
    if doorModel:GetAttribute("Opened") then
        local nextRoom = Internal.Rooms:WaitForChild(tostring(tonumber(room.Name) + 1), 2)
        if nextRoom then
            Root.CFrame = nextRoom:GetModelCFrame() + Vector3.new(0, 2, 0)
        end
    end

    Internal.IsProcessing = false
end

-- // 5. DRAGGABLE UI //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosAlpha") then CoreGui.ChronosAlpha:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosAlpha"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 160, 0, 80)
    Main.Position = UDim2.new(0.5, -80, 0.1, 0)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", Main)
    
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -20, 1, -20)
    B.Position = UDim2.new(0, 10, 0, 10)
    B.Text = "ALPHA SKIP: OFF"
    B.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Code
    Instance.new("UICorner", B)

    -- Drag Logic
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Internal.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Internal.Dragging = false end
    end)

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.AUTO_SKIP = not ALPHA_CONFIG.AUTO_SKIP
        B.Text = ALPHA_CONFIG.AUTO_SKIP and "SKIP: ON" or "SKIP: OFF"
    end)
end

task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        if ALPHA_CONFIG.AUTO_SKIP then
            for _, room in pairs(Internal.Rooms:GetChildren()) do
                if (Root.Position - room:GetModelCFrame().Position).Magnitude < ALPHA_CONFIG.RANGE then
                    AlphaSequence(room)
                end
            end
        end
        task.wait(0.2)
    end
end)

BuildUI()
