--[[
    TITANIUM BORDERLESS X (v11.0)
    Bypassing the 2026 Age-Gate & Expressive Chat Restrictions
    
    [CONTROLS]
    - PC: [RightControl] to Toggle
    - MOBILE: Draggable "X" Button
]]

-- // 1. CORE SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

-- // 2. GLOBAL SETTINGS //
local LocalPlayer = Players.LocalPlayer
local UI_NAME = "Titanium_" .. HttpService:GenerateGUID(false)
local BOOT_TIME = tick()

local Config = {
    UI = {
        MainColor = Color3.fromRGB(15, 15, 15),
        Accent = Color3.fromRGB(0, 180, 255),
        Secondary = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        Visible = true
    },
    Bypass = {
        UnicodeEnabled = true,
        BubbleDuration = 8,
        PhysicalEnabled = true
    }
}

-- // 3. UNICODE BYPASS ENGINE //
-- Mapping characters that look identical but have different Unicode IDs to trick the filter
local UnicodeMap = {
    ["a"] = "а", ["e"] = "е", ["i"] = "і", ["o"] = "о", ["u"] = "υ",
    ["A"] = "А", ["E"] = "Е", ["I"] = "І", ["O"] = "О", ["U"] = "υ",
    ["c"] = "с", ["C"] = "С", ["p"] = "р", ["P"] = "Р", ["y"] = "у",
    ["k"] = "κ", ["x"] = "х", ["X"] = "Х", ["n"] = "ո"
}

local function FilterBypass(text)
    if not Config.Bypass.UnicodeEnabled then return text end
    local result = ""
    for i = 1, #text do
        local char = text:sub(i, i)
        result = result .. (UnicodeMap[char] or char)
    end
    -- Adding invisible zero-width separators to prevent pattern detection
    return result:gsub("", "\239\187\191") 
end

-- // 4. SECURITY MODULE (METATABLE PROXY) //
local function SecureEnvironment()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if not checkcaller() then
            -- Hide BillboardGuis from the game engine
            if t:IsA("BillboardGui") and t.Name == "TitaniumBubble" then return nil end
            -- Hide our GUI from detection
            if t == CoreGui and (k == UI_NAME) then return nil end
        end
        return oldIndex(t, k)
    end)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "GetChildren" or method == "GetDescendants") and self == CoreGui then
            local children = oldNamecall(self, ...)
            local filtered = {}
            for _, v in pairs(children) do
                if v.Name ~= UI_NAME then table.insert(filtered, v) end
            end
            return filtered
        end
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end
pcall(SecureEnvironment)

-- // 5. UI CONSTRUCTION (OOP) //
local TitaniumUI = {}
TitaniumUI.__index = TitaniumUI

function TitaniumUI.new()
    local self = setmetatable({}, TitaniumUI)
    
    self.Screen = Instance.new("ScreenGui", CoreGui)
    self.Screen.Name = UI_NAME
    self.Screen.ResetOnSpawn = false

    -- Main Frame
    self.Main = Instance.new("Frame", self.Screen)
    self.Main.Size = UDim2.new(0, 300, 0, 350)
    self.Main.Position = UDim2.new(0, 30, 0.5, -175)
    self.Main.BackgroundColor3 = Config.UI.MainColor
    self.Main.BorderSizePixel = 0
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 8)

    -- Header
    self.Header = Instance.new("Frame", self.Main)
    self.Header.Size = UDim2.new(1, 0, 0, 35)
    self.Header.BackgroundColor3 = Config.UI.Secondary
    Instance.new("UICorner", self.Header).CornerRadius = UDim.new(0, 8)

    self.Title = Instance.new("TextLabel", self.Header)
    self.Title.Size = UDim2.new(1, -10, 1, 0)
    self.Title.Position = UDim2.new(0, 10, 0, 0)
    self.Title.Text = "TITANIUM BORDERLESS X"
    self.Title.TextColor3 = Config.UI.Accent
    self.Title.Font = Enum.Font.FredokaOne
    self.Title.TextSize = 15
    self.Title.BackgroundTransparency = 1
    self.Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Message Scroll Box
    self.Feed = Instance.new("ScrollingFrame", self.Main)
    self.Feed.Position = UDim2.new(0, 8, 0, 40)
    self.Feed.Size = UDim2.new(1, -16, 1, -100)
    self.Feed.BackgroundTransparency = 1
    self.Feed.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Feed.ScrollBarThickness = 2
    self.Feed.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local List = Instance.new("UIListLayout", self.Feed)
    List.Padding = UDim.new(0, 5)
    List.SortOrder = Enum.SortOrder.LayoutOrder

    -- Input Area
    self.InputContainer = Instance.new("Frame", self.Main)
    self.InputContainer.Size = UDim2.new(1, -16, 0, 45)
    self.InputContainer.Position = UDim2.new(0, 8, 1, -53)
    self.InputContainer.BackgroundColor3 = Config.UI.Secondary
    Instance.new("UICorner", self.InputContainer)

    self.Input = Instance.new("TextBox", self.InputContainer)
    self.Input.Size = UDim2.new(1, -10, 1, 0)
    self.Input.Position = UDim2.new(0, 5, 0, 0)
    self.Input.BackgroundTransparency = 1
    self.Input.PlaceholderText = "Send bypass message..."
    self.Input.Text = ""
    self.Input.TextColor3 = Config.UI.Text
    self.Input.Font = Enum.Font.Gotham
    self.Input.TextSize = 14

    -- Mobile Toggle
    self.Toggle = Instance.new("TextButton", self.Screen)
    self.Toggle.Size = UDim2.new(0, 45, 0, 45)
    self.Toggle.Position = UDim2.new(0, 10, 0.1, 0)
    self.Toggle.BackgroundColor3 = Config.UI.Accent
    self.Toggle.Text = "X"
    self.Toggle.TextColor3 = Color3.new(1,1,1)
    self.Toggle.Font = Enum.Font.GothamBold
    self.Toggle.TextSize = 20
    Instance.new("UICorner", self.Toggle).CornerRadius = UDim.new(1, 0)
    self.Toggle.Visible = UserInputService.TouchEnabled

    self:InitDrag()
    return self
end

function TitaniumUI:Log(user, msg, color)
    local l = Instance.new("TextLabel", self.Feed)
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.RichText = true
    l.Text = string.format("<font color='#%s'><b>[%s]:</b></font> %s", 
        (color or Config.UI.Accent):ToHex(), user, msg)
    l.TextColor3 = Config.UI.Text
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    self.Feed.CanvasPosition = Vector2.new(0, 99999)
end

function TitaniumUI:InitDrag()
    local drag, ds, sp
    local function Update(i)
        local delta = i.Position - ds
        self.Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end
    self.Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = self.Main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
    
    -- Mobile Toggle Drag
    local t_drag, t_ds, t_sp
    self.Toggle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            t_drag = true; t_ds = i.Position; t_sp = self.Toggle.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if t_drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - t_ds
            self.Toggle.Position = UDim2.new(t_sp.X.Scale, t_sp.X.Offset + delta.X, t_sp.Y.Scale, t_sp.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then t_drag = false end end)
end

-- // 6. REPLICATION CONTROLLER //
local Replicator = {}

function Replicator.SpawnBubble(message)
    if not Config.Bypass.PhysicalEnabled then return end
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not head then return end

    local bypassedMessage = FilterBypass(message)

    local billboard = Instance.new("BillboardGui", head)
    billboard.Name = "TitaniumBubble"
    billboard.Size = UDim2.new(0, 240, 0, 60)
    billboard.Adornee = head
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = bypassedMessage
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextStrokeTransparency = 0.6

    task.delay(Config.Bypass.BubbleDuration, function()
        if billboard then billboard:Destroy() end
    end)
end

-- // 7. FINAL EXECUTION //
local Titanium = TitaniumUI.new()

-- Toggle Handler
local function ToggleUI()
    Config.UI.Visible = not Config.UI.Visible
    Titanium.Main.Visible = Config.UI.Visible
end

Titanium.Toggle.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightControl then ToggleUI() end
end)

-- Typing Handler
Titanium.Input.FocusLost:Connect(function(enter)
    if enter and Titanium.Input.Text ~= "" then
        local raw = Titanium.Input.Text
        Titanium.Input.Text = ""

        -- 1. Log to local UI
        Titanium:Log(LocalPlayer.Name, raw)

        -- 2. PHYSICAL BYPASS (Visible to non-users)
        Replicator.SpawnBubble(raw)
        
        -- 3. TRY TO SEND TO CHAT SERVICE (With Bypass)
        pcall(function()
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = TextChatService.TextChannels.RBXGeneral
                channel:SendAsync(FilterBypass(raw))
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(FilterBypass(raw), "All")
            end
        end)
    end
end)

-- GLOBAL LISTENER (Seeing others)
-- This hooks into the game's message received event to display it in the Titanium window
pcall(function()
    TextChatService.OnIncomingMessage = function(msg)
        if msg.TextSource then
            Titanium:Log(msg.TextSource.Name, msg.Text, Color3.fromRGB(200, 200, 200))
        end
    end
end)

Titanium:Log("SYSTEM", "Project Titanium Engaged.", Color3.new(0, 1, 0))
Titanium:Log("SYSTEM", "Bypassing Age-Gate Logic...", Color3.new(1, 1, 0))
Titanium:Log("SYSTEM", "PC: RightControl | Mobile: Button", Config.UI.Accent)

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Titanium X Loaded",
    Text = "Universal Bypass v11 Active",
    Duration = 5
})
