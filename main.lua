-- // CHRONOS ALPHA 0.0.4 //
-- STATUS: Inventory Verification & UI Mobility
-- FOCUS: Logical Flow & UX Improvement

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. ALPHA CONFIGURATION //
local ALPHA_CONFIG = {
    AUTO_SKIP = false,
    VERSION = "0.0.4-ALPHA",
    RANGE = 25,
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false,
    Dragging = false,
    DragInput = nil,
    DragStart = nil,
    StartPos = nil
}

-- // 2. INVENTORY VERIFIER //
local function HasKey()
    -- Checks if key is in inventory or currently held
    if LocalPlayer.Backpack:FindFirstChild("Key") or (Character and Character:FindFirstChild("Key")) then
        return true
    end
    return false
end

-- // 3. ITEM & KEY SCANNER //
local function GetKeyInRoom(room)
    for _, v in pairs(room:GetDescendants()) do
        if (v.Name == "Key" or v:FindFirstChild("Key")) and v:FindFirstChildWhichIsA("ProximityPrompt") then
            return v:FindFirstChildWhichIsA("ProximityPrompt")
        end
    end
    return nil
end

-- // 4. THE VERIFIED SEQUENCE //
local function AlphaSequence(room)
    if Internal.IsProcessing then return end
    
    local doorModel = room:FindFirstChild("Door") or room:FindFirstChild("DoorModel")
    if not doorModel then return end
    if doorModel:GetAttribute("Opened") then return end
    
    Internal.IsProcessing = true
    
    -- STEP 1: Handle Locking
    local doorPart = doorModel:FindFirstChild("Door") or doorModel.PrimaryPart
    local isLocked = doorModel:FindFirstChild("Lock") or (doorPart and doorPart:FindFirstChild("Lock"))
    
    if isLocked and not HasKey() then
        local keyPrompt = GetKeyInRoom(room)
        if keyPrompt then
            fireproximityprompt(keyPrompt)
            -- WAIT FOR INVENTORY SYNC
            local timeout = 0
            while not HasKey() and timeout < 20 do
                task.wait(0.1)
                timeout = timeout + 1
            end
            task.wait(0.3) -- Safety buffer for server handshake
        end
    end

    -- STEP 2: Unlock and Open (Only if not locked or we have the key)
    if not isLocked or HasKey() then
        local doorPrompt = doorModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        if doorPrompt then
            fireproximityprompt(doorPrompt)
            local timeout = 0
            while not doorModel:GetAttribute("Opened") and timeout < 30 do
                task.wait(0.05)
                timeout = timeout + 1
            end
        end
    end

    -- STEP 3: Instant Sift TP (Only if door is open)
    if doorModel:GetAttribute("Opened") then
        local nextRoomNum = tonumber(room.Name) + 1
        local nextRoom = Internal.Rooms:WaitForChild(tostring(nextRoomNum), 2)
        
        if nextRoom then
            local entrance = nextRoom:FindFirstChild("Entrance") or nextRoom.PrimaryPart
            if entrance then
                for i = 1, 5 do
                    Root.CFrame = Root.CFrame:Lerp(entrance.CFrame + Vector3.new(0, 2, 0), i/5)
                    task.wait()
                end
            end
        end
    end

    Internal.IsProcessing = false
end

-- // 5. UI CONSTRUCTION WITH DRAG //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosAlpha") then CoreGui.ChronosAlpha:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosAlpha"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 180, 0, 100)
    Main.Position = UDim2.new(0.5, -90, 0.1, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)
    
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 25)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = "CHRONOS " .. ALPHA_CONFIG.VERSION
    Title.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Title.Font = Enum.Font.Code
    Title.TextSize = 12
    Title.BackgroundTransparency = 1

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -20, 0, 50)
    B.Position = UDim2.new(0, 10, 0, 35)
    B.Text = "START SKIP"
    B.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Code
    Instance.new("UICorner", B)

    -- // DRAG LOGIC //
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Internal.Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Internal.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.AUTO_SKIP = not ALPHA_CONFIG.AUTO_SKIP
        B.Text = ALPHA_CONFIG.AUTO_SKIP and "SKIP: ACTIVE" or "SKIP: PAUSED"
        B.TextColor3 = ALPHA_CONFIG.AUTO_SKIP and Color3.new(0.5, 1, 0.5) or Color3.new(1, 1, 1)
    end)
end

-- // 6. RUNTIME //
task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        if ALPHA_CONFIG.AUTO_SKIP then
            for _, room in pairs(Internal.Rooms:GetChildren()) do
                local door = room:FindFirstChild("Door") or room:FindFirstChild("DoorModel")
                if door then
                    local primary = door:FindFirstChild("Door") or door.PrimaryPart
                    if primary and (Root.Position - primary.Position).Magnitude < ALPHA_CONFIG.RANGE then
                        AlphaSequence(room)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

BuildUI()uildUI()
