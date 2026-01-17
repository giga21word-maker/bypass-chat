-- // CHRONOS ALPHA 0.1.1 //
-- STATUS: Deep-Scan & Velocity Sync
-- BYPASS: Tether-Movement (Anti-TP Back)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. SYSTEM CONFIG //
local ALPHA_CONFIG = {
    ENABLED = false,
    VERSION = "0.1.1-DRIVE",
    SENSE_RANGE = 60,
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false,
    Log = "Ready",
    Dragging = false
}

-- // 2. RECURSIVE DEEP SCAN //
local function FindPrompt(parent, targetAction)
    for _, v in pairs(parent:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if v.ActionText:find(targetAction) or v.ObjectText:find("Key") then
                return v
            end
        end
    end
    return nil
end

local function HasKey()
    return Character:FindFirstChild("Key") or LocalPlayer.Backpack:FindFirstChild("Key")
end

-- // 3. TETHER MOVEMENT (BYPASS) //
local function TetherMove(targetPos)
    local distance = (Root.Position - targetPos).Magnitude
    local steps = math.floor(distance / 2) -- Move in 2-stud increments
    
    for i = 1, steps do
        local alpha = i / steps
        Root.CFrame = Root.CFrame:Lerp(CFrame.new(targetPos), alpha)
        -- Spoof velocity so server thinks we are running
        Root.AssemblyLinearVelocity = (targetPos - Root.Position).Unit * 20
        task.wait(0.03) 
    end
    Root.AssemblyLinearVelocity = Vector3.zero
end

-- // 4. CORE ENGINE //
local function ProcessRoom()
    if Internal.IsProcessing or not ALPHA_CONFIG.ENABLED then return end
    
    -- Get Current and Next Room
    local rooms = Internal.Rooms:GetChildren()
    table.sort(rooms, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)
    local currentRoom = rooms[#rooms]
    if not currentRoom then return end

    local door = currentRoom:FindFirstChild("Door") or currentRoom:FindFirstChild("DoorModel")
    if not door or door:GetAttribute("Opened") or door:GetAttribute("Fake") then return end

    Internal.IsProcessing = true
    Internal.Log = "Analyzing Room " .. currentRoom.Name

    -- STEP 1: KEY HUNT
    local isLocked = door:FindFirstChild("Lock", true)
    if isLocked and not HasKey() then
        Internal.Log = "Searching for Key..."
        local keyPrompt = FindPrompt(currentRoom, "Collect")
        if keyPrompt then
            -- Move to key first (to prevent anti-cheat kick for far interaction)
            TetherMove(keyPrompt.Parent.WorldPosition or keyPrompt.Parent.Position)
            task.wait(0.1)
            fireproximityprompt(keyPrompt)
            repeat task.wait(0.1) until HasKey() or not ALPHA_CONFIG.ENABLED
        end
    end

    -- STEP 2: DOOR ACTION
    Internal.Log = "Unlocking Door..."
    local doorPrompt = FindPrompt(door, "Unlock") or FindPrompt(door, "Open")
    if doorPrompt then
        TetherMove(doorPrompt.Parent.WorldPosition or doorPrompt.Parent.Position)
        fireproximityprompt(doorPrompt)
        -- Wait for Server State
        local t = 0
        while not door:GetAttribute("Opened") and t < 40 do
            task.wait(0.1)
            t = t + 1
        end
    end

    -- STEP 3: TRANSITION
    if door:GetAttribute("Opened") then
        Internal.Log = "Transitioning..."
        local nextRoom = Internal.Rooms:WaitForChild(tostring(tonumber(currentRoom.Name) + 1), 5)
        if nextRoom then
            TetherMove(nextRoom:GetModelCFrame().Position + Vector3.new(0, 2, 0))
        end
    end

    Internal.IsProcessing = false
    Internal.Log = "Standby"
end

-- // 5. DRAGGABLE GUI //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosDrive") then CoreGui.ChronosDrive:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosDrive"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 200, 0, 100)
    Main.Position = UDim2.new(0.5, -100, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.Active = true
    Main.Draggable = true -- Built-in legacy drag for Alpha
    Instance.new("UICorner", Main)
    
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -20, 0, 40)
    B.Position = UDim2.new(0, 10, 0, 10)
    B.Text = "ENABLE DRIVE"
    B.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Code
    Instance.new("UICorner", B)

    local L = Instance.new("TextLabel", Main)
    L.Size = UDim2.new(1, -20, 0, 30)
    L.Position = UDim2.new(0, 10, 0, 60)
    L.Text = "LOG: STARTING"
    L.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    L.BackgroundTransparency = 1
    L.Font = Enum.Font.Code
    L.TextSize = 12

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.ENABLED = not ALPHA_CONFIG.ENABLED
        B.Text = ALPHA_CONFIG.ENABLED and "DRIVE ACTIVE" or "ENABLE DRIVE"
        B.TextColor3 = ALPHA_CONFIG.ENABLED and Color3.new(0, 1, 0.5) or Color3.new(1, 1, 1)
    end)

    task.spawn(function()
        while true do
            L.Text = "LOG: " .. Internal.Log:upper()
            task.wait(0.2)
        end
    end)
end

-- // 6. INITIATE //
task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        pcall(ProcessRoom)
        task.wait(0.5)
    end
end)

BuildUI()
