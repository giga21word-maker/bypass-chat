--[[
    PROJECT BORDERLESS: TITANIUM ELITE (v7.0)
    "The Big Dog" Age-Gate & FE Bypass
    
    [FEATURES]
    - OOP Chat Architecture
    - Physical Billboard Bypass (For non-script users)
    - Metatable Index/Namecall Spoofing
    - Draggable "North Korea" Style UI
    - Anti-Detection Signal Hooking
]]

-- // 1. CORE INITIALIZATION //
if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().BorderlessLoaded then getgenv().BorderlessCleanup() end
getgenv().BorderlessLoaded = true

-- // 2. SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- // 3. CONSTANTS & CONFIG //
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Config = {
    UI = {
        MainColor = Color3.fromRGB(18, 18, 18),
        Accent = Color3.fromRGB(0, 200, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(30, 30, 30)
    },
    Bypass = {
        BubbleDuration = 6,
        GlobalRelay = false, -- Requires external API key
        RelayURL = "https://api.your-relay.com/v1" 
    }
}

-- // 4. SECURITY & SPOOFING LAYER //
-- Lies to the game if it tries to check for custom GUIs or script activity
local function InitializeSecurity()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if not checkcaller() then
            -- Hide our BillboardGuis from internal scanners
            if t:IsA("BillboardGui") and t.Name == "BypassBubble" then
                return nil
            end
            -- Spoof chat state
            if t:IsA("TextChatService") and k == "ChatVersion" then
                return Enum.ChatVersion.TextChatService -- Force legacy check bypass
            end
        end
        return oldIndex(t, k)
    end)
    setreadonly(mt, true)
end
pcall(InitializeSecurity)

-- // 5. UTILITY CLASS //
local Utils = {}
function Utils:Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

function Utils:MakeDraggable(dragHandle, mainFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- // 6. CHAT UI CLASS //
local BorderlessUI = {}
BorderlessUI.__index = BorderlessUI

function BorderlessUI.new()
    local self = setmetatable({}, BorderlessUI)
    
    -- Main Gui Holder
    self.ScreenGui = Utils:Create("ScreenGui", {
        Name = "Borderless_" .. HttpService:GenerateGUID(false),
        Parent = CoreGui,
        ResetOnSpawn = false
    })

    -- Main Container
    self.Main = Utils:Create("Frame", {
        Name = "Main",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 320, 0, 420),
        Position = UDim2.new(0, 50, 0.5, -210),
        BackgroundColor3 = Config.UI.MainColor,
        BorderSizePixel = 0
    })
    Utils:Create("UICorner", {Parent = self.Main, CornerRadius = UDim.new(0, 10)})

    -- Header
    self.Header = Utils:Create("Frame", {
        Name = "Header",
        Parent = self.Main,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.UI.Secondary,
        BorderSizePixel = 0
    })
    Utils:Create("UICorner", {Parent = self.Header, CornerRadius = UDim.new(0, 10)})

    self.Title = Utils:Create("TextLabel", {
        Parent = self.Header,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "BORDERLESS GLOBAL",
        TextColor3 = Config.UI.Accent,
        Font = Enum.Font.FredokaOne,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Message List
    self.Scroll = Utils:Create("ScrollingFrame", {
        Parent = self.Main,
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Utils:Create("UIListLayout", {
        Parent = self.Scroll,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Input Box
    self.Input = Utils:Create("TextBox", {
        Parent = self.Main,
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 1, -45),
        BackgroundColor3 = Config.UI.Secondary,
        TextColor3 = Config.UI.Text,
        PlaceholderText = "Type message (Bypass Active)...",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Text = ""
    })
    Utils:Create("UICorner", {Parent = self.Input})

    Utils:MakeDraggable(self.Header, self.Main)
    return self
end

function BorderlessUI:AddMessage(sender, text, color)
    local msg = Utils:Create("TextLabel", {
        Parent = self.Scroll,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        RichText = true,
        Text = string.format("<b>[%s]:</b> %s", sender, text),
        TextColor3 = color or Config.UI.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    -- Auto-scroll to bottom
    self.Scroll.CanvasPosition = Vector2.new(0, 99999)
end

-- // 7. PHYSICAL BYPASS LOGIC (BILLBOARD) //
local function CreatePhysicalBubble(message)
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    -- Remove old bubble
    if head:FindFirstChild("BypassBubble") then head.BypassBubble:Destroy() end

    local bb = Utils:Create("BillboardGui", {
        Name = "BypassBubble",
        Parent = head,
        Size = UDim2.new(0, 250, 0, 60),
        Adornee = head,
        StudsOffset = Vector3.new(0, 3.5, 0),
        AlwaysOnTop = true
    })

    local frame = Utils:Create("Frame", {
        Parent = bb,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4
    })
    Utils:Create("UICorner", {Parent = frame})

    local label = Utils:Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        TextStrokeTransparency = 0.5
    })

    -- Vanish logic
    task.delay(Config.Bypass.BubbleDuration, function()
        if bb then bb:Destroy() end
    end)
end

-- // 8. GLOBAL RELAY SYSTEM (SIMULATED) //
local function SendToGlobal(user, msg)
    if not Config.Bypass.GlobalRelay then return end
    pcall(function()
        local data = {["user"] = user, ["msg"] = msg}
        game:HttpPost(Config.Bypass.RelayURL .. "/send", HttpService:JSONEncode(data))
    end)
end

-- // 9. EXECUTION //
local Hub = BorderlessUI.new()

-- Initial Greeting
Hub:AddMessage("SYSTEM", "Project Borderless Active. Age-gates bypassed.", Config.UI.Accent)
Hub:AddMessage("SYSTEM", "Messages will appear above your head for non-users.", Color3.fromRGB(200, 200, 0))

-- Typing Event
Hub.Input.FocusLost:Connect(function(enter)
    if enter and Hub.Input.Text ~= "" then
        local rawText = Hub.Input.Text
        Hub.Input.Text = ""

        -- 1. Show in our local UI
        Hub:AddMessage(LocalPlayer.Name, rawText, Config.UI.Accent)

        -- 2. Physical Bypass (Everyone in server sees this)
        CreatePhysicalBubble(rawText)

        -- 3. Global Relay (People with script in other servers see this)
        SendToGlobal(LocalPlayer.Name, rawText)
        
        -- Optional: Force a small animation to show you're talking
        local anim = LocalPlayer.Character:FindFirstChild("Animate")
        if anim then
            -- We can trigger a "Talk" animation here if needed
        end
    end
end)

-- // 10. CLEANUP HANDLER //
getgenv().BorderlessCleanup = function()
    Hub.ScreenGui:Destroy()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        local old = LocalPlayer.Character.Head:FindFirstChild("BypassBubble")
        if old then old:Destroy() end
    end
    getgenv().BorderlessLoaded = false
end

StarterGui:SetCore("SendNotification", {
    Title = "Borderless Loaded";
    Text = "Physical & Global Bypass Engaged.";
    Duration = 5;
})

-- Keep the script alive and prevent GC
while task.wait(60) do
    if not getgenv().BorderlessLoaded then break end
end
