-- // CHRONOS ALPHA 0.0.6 //
-- STATUS: Ghost-Protocol Logic
-- BYPASS: Remote-Spoof & Physics Jitter
-- SAFETY: Multi-Stage Validation

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- // 1. AUTHORITY CONFIGURATION //
local ALPHA_CONFIG = {
    AUTO_SKIP = false,
    VERSION = "0.0.6-ALPHA",
    RANGE = 45, -- Increased range for faster sensing
    SKIP_SPEED = 0.4,
    ACTIVE = true
}

local Internal = {
    Rooms = Workspace:WaitForChild("CurrentRooms"),
    IsProcessing = false,
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- // 2. INVENTORY & ITEM SCANNER (FASTER) //
local function GetKeyInRoom(room)
    for _, v in pairs(room:GetDescendants()) do
        if v.Name == "Key" and v:IsA("Model") then
            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then return prompt end
        end
    end
    return nil
end

local function HasKey()
    return LocalPlayer.Backpack:FindFirstChild("Key") or Character:FindFirstChild("Key")
end

-- // 3. ANTI-DUPE (SMART SCAN) //
local function IsSafeDoor(door)
    if not door:IsA("Model") then return false end
    -- Real doors have specific child names and attributes
    if door:FindFirstChild("Fake") or door:GetAttribute("Fake") then return false end
    
    local doorNum = door:FindFirstChild("Sign", true) or door:FindFirstChild("Number", true)
    if doorNum and doorNum:IsA("TextLabel") then
        local expected = tonumber(door.Parent.Name) + 1
        if tonumber(doorNum.Text) ~= expected then return false end
    end
    return true
end

-- // 4. ADVANCED SKIP SEQUENCE //
local function ExecuteGhostSkip(room)
    if Internal.IsProcessing then return end
    
    local door = room:FindFirstChild("Door") or room:FindFirstChild("DoorModel")
    if not door or not IsSafeDoor(door) then return end
    if door:GetAttribute("Opened") then return end
    
    Internal.IsProcessing = true
    
    -- STAGE 1: KEY-SEQUENCE
    local lock = door:FindFirstChild("Lock", true)
    if lock and not HasKey() then
        local keyPrompt = GetKeyInRoom(room)
        if keyPrompt then
            fireproximityprompt(keyPrompt)
            -- Handshake wait
            local t = 0
            while not HasKey() and t < 30 do task.wait(0.1) t = t + 1 end
        end
    end

    -- STAGE 2: DOOR-SEQUENCE
    local doorPrompt = door:FindFirstChildWhichIsA("ProximityPrompt", true)
    if doorPrompt then
        fireproximityprompt(doorPrompt)
        local t = 0
        while not door:GetAttribute("Opened") and t < 40 do task.wait(0.1) t = t + 1 end
    end

    -- STAGE 3: BYPASS TELEPORT
    if door:GetAttribute("Opened") then
        local nextNum = tostring(tonumber(room.Name) + 1)
        local nextRoom = Internal.Rooms:WaitForChild(nextNum, 5)
        
        if nextRoom then
            local target = nextRoom:FindFirstChild("Entrance") or nextRoom.PrimaryPart
            if target then
                -- Jitter-Stutter TP (Bypass Anti-Cheat)
                for i = 1, 8 do
                    local alpha = i / 8
                    local jitter = Vector3.new(math.random(-1,1)/10, 0, math.random(-1,1)/10)
                    Root.CFrame = Root.CFrame:Lerp(target.CFrame + Vector3.new(0, 3, 0), alpha) + jitter
                    Root.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.02)
                end
            end
        end
    end

    task.wait(ALPHA_CONFIG.SKIP_SPEED)
    Internal.IsProcessing = false
end

-- // 5. DRAGGABLE UI (OPTIMIZED) //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosAlpha") then CoreGui.ChronosAlpha:Destroy() end
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosAlpha"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 200, 0, 100)
    Main.Position = UDim2.new(0.5, -100, 0.1, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 180, 0)

    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(1, -20, 1, -20)
    B.Position = UDim2.new(0, 10, 0, 10)
    B.Text = "ACTIVATE GHOST-SKIP"
    B.Font = Enum.Font.Code
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", B)

    -- DRAG LOGIC
    B.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Internal.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = false
        end
    end)

    B.MouseButton1Down:Connect(function()
        ALPHA_CONFIG.AUTO_SKIP = not ALPHA_CONFIG.AUTO_SKIP
        B.Text = ALPHA_CONFIG.AUTO_SKIP and "GHOST: ACTIVE" or "GHOST: PAUSED"
        B.TextColor3 = ALPHA_CONFIG.AUTO_SKIP and Color3.fromRGB(0, 255, 150) or Color3.new(1, 1, 1)
    end)
end

-- // 6. RUNTIME MONITOR //
task.spawn(function()
    while ALPHA_CONFIG.ACTIVE do
        if ALPHA_CONFIG.AUTO_SKIP then
            local room = Internal.Rooms:FindFirstChild(tostring(#Internal.Rooms:GetChildren() - 1))
            if room then
                ExecuteGhostSkip(room)
            end
        end
        task.wait(0.1)
    end
end)

BuildUI()
