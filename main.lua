-- // CHRONOS ALPHA 0.1.0 //
-- STATUS: Core Re-Verification Build
-- FEATURES: Recursive Search, Anti-Dupe, Drag-UI, Debugger
-- BYPASS: Velocity Masking + Frame-Lerping

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. CONFIGURATION VERIFICATION //
local ALPHA_CONFIG = {
    ENABLED = false,
    VERSION = "0.1.0-ALPHA",
    RANGE = 50,
    SPEED = 0.5,
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false,
    DebugStatus = "Initializing...",
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 2. SMART DEBUGGER //
local function UpdateStatus(txt)
    Internal.DebugStatus = txt
    if CoreGui:FindFirstChild("ChronosAlpha") then
        local label = CoreGui.ChronosAlpha.Main:FindFirstChild("Status")
        if label then label.Text = "LOG: " .. txt:upper() end
    end
end

-- // 3. VERIFIED SCANNER //
local function FindKeyInRoom(room)
    for _, obj in pairs(room:GetDescendants()) do
        -- Search for Key by name or Attribute
        if (obj.Name == "Key" or obj:GetAttribute("PickupName") == "Key") then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then return prompt end
        end
    end
    return nil
end

local function HasKey()
    return LocalPlayer.Backpack:FindFirstChild("Key") or Character:FindFirstChild("Key")
end

-- // 4. ADVANCED DOOR BYPASS //
local function AlphaLogic()
    if Internal.IsProcessing or not ALPHA_CONFIG.ENABLED then return end
    
    -- Find latest room
    local children = Internal.Rooms:GetChildren()
    table.sort(children, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)
    local currentRoom = children[#children]
    
    if not currentRoom then return end
    UpdateStatus("Scanning Room " .. currentRoom.Name)

    local door = currentRoom:FindFirstChild("Door") or currentRoom:FindFirstChild("DoorModel")
    if not door or door:GetAttribute("Opened") then return end

    -- Check for Dupe (Anti-Cheat for Fake Doors)
    local sign = door:FindFirstChild("Sign", true) or door:FindFirstChild("Number", true)
    if sign and sign:IsA("TextLabel") then
        local doorNum = tonumber(sign.Text)
        if doorNum and doorNum ~= tonumber(currentRoom.Name) + 1 then
            UpdateStatus("Dupe Detected! Ignoring.")
            return
        end
    end

    Internal.IsProcessing = true

    -- STAGE 1: KEY ACQUISITION
    local lock = door:FindFirstChild("Lock", true)
    if lock and not HasKey() then
        UpdateStatus("Hunting Key...")
        local key = FindKeyInRoom(currentRoom)
        if key then
            fireproximityprompt(key)
            task.wait(0.3)
        end
    end

    -- STAGE 2: DOOR UNLOCK
    UpdateStatus("Opening Door...")
    local prompt = door:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        local t = 0
        while not door:GetAttribute("Opened") and t < 30 do
            task.wait(0.1)
            t = t + 1
        end
    end

    -- STAGE 3: POSITION SYNC (BYPASS TP)
    if door:GetAttribute("Opened") then
        UpdateStatus("Sifting to Next Room")
        local nextRoom = Internal.Rooms:WaitForChild(tostring(tonumber(currentRoom.Name) + 1), 3)
        if nextRoom then
            local targetPos = nextRoom:GetModelCFrame() + Vector3.new(0, 2, 0)
            -- Sift movement to bypass Anti-Cheat TP check
            for i = 1, 10 do
                Root.CFrame = Root.CFrame:Lerp(targetPos, i/10)
                Root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                task.wait(0.02)
            end
        end
    end

    task.wait(ALPHA_CONFIG.SPEED)
    Internal.IsProcessing = false
end

-- // 5. DRAGGABLE UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosAlpha") then CoreGui.ChronosAlpha:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosAlpha"

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 110)
    Main.Position = UDim2.new(0.5, -110, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -20, 0, 50)
    B.Position = UDim2.new(0, 10, 0, 10)
    B.Text = "START ALPHA SKIP"
    B.Font = Enum.Font.Code
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", B)

    local DebugLabel = Instance.new("TextLabel", Main)
    DebugLabel.Name = "Status"
    DebugLabel.Size = UDim2.new(1, -20, 0, 30)
    DebugLabel.Position = UDim2.new(0, 10, 0, 65)
    DebugLabel.Text = "LOG: STANDBY"
    DebugLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    DebugLabel.Font = Enum.Font.Code
    DebugLabel.TextSize = 10
    DebugLabel.BackgroundTransparency = 1

    -- DRAG LOGIC
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if Internal.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = false
        end
    end)

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.ENABLED = not ALPHA_CONFIG.ENABLED
        B.Text = ALPHA_CONFIG.ENABLED and "SKIP ACTIVE" or "START ALPHA SKIP"
        B.TextColor3 = ALPHA_CONFIG.ENABLED and Color3.new(0, 1, 0.6) or Color3.new(1, 1, 1)
        UpdateStatus(ALPHA_CONFIG.ENABLED and "Scanning..." or "Paused")
    end)
end

-- // 6. RUNTIME //
task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        pcall(AlphaLogic)
        task.wait(0.2)
    end
end)

BuildUI()
