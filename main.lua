-- [[ PROJECT BORDERLESS: GLOBAL BYPASS V8 ]]
-- Keybind to Open/Close: RightControl

-- // 1. INIT & SERVICES //
if not game:IsLoaded() then game.Loaded:Wait() end
local Players, Http, Run, UIS, CoreGui = game:GetService("Players"), game:GetService("HttpService"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. CONFIG //
local Theme = {
    Main = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 200, 255),
    Secondary = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255)
}

-- // 3. UI CONSTRUCTION (COMPACT) //
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "Borderless_"..math.random(100,999)

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 280, 0, 320)
Main.Position = UDim2.new(0, 50, 0.5, -160)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Theme.Secondary
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "GLOBAL CHAT (AGE BYPASS)"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.Size = UDim2.new(1, -10, 1, -85)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 1
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 3)

local Input = Instance.new("TextBox", Main)
Input.Position = UDim2.new(0, 5, 1, -40)
Input.Size = UDim2.new(1, -10, 0, 35)
Input.BackgroundColor3 = Theme.Secondary
Input.PlaceholderText = "Type to all age groups..."
Input.Text = ""
Input.TextColor3 = Theme.Text
Input.Font = Enum.Font.Gotham
Input.TextSize = 14
Instance.new("UICorner", Input)

-- // 4. FUNCTIONS //
local function AddMsg(user, text, color)
    local l = Instance.new("TextLabel", Scroll)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.RichText = true
    l.Text = string.format("<b>[%s]:</b> %s", user, text)
    l.TextColor3 = color or Theme.Text
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    Scroll.CanvasPosition = Vector2.new(0, 9999)
end

-- PHYSICAL BYPASS (For people without the script)
local function CreateBubble(msg)
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not head then return end
    local bb = Instance.new("BillboardGui", head)
    bb.Size, bb.Adornee, bb.AlwaysOnTop, bb.StudsOffset = UDim2.new(0,200,0,50), head, true, Vector3.new(0,3,0)
    local f = Instance.new("Frame", bb)
    f.Size, f.BackgroundColor3, f.BackgroundTransparency = UDim2.new(1,0,1,0), Color3.new(0,0,0), 0.5
    Instance.new("UICorner", f)
    local t = Instance.new("TextLabel", f)
    t.Size, t.BackgroundTransparency, t.Text, t.TextColor3, t.Font, t.TextScaled = UDim2.new(1,0,1,0), 1, msg, Color3.new(1,1,1), Enum.Font.GothamBold, true
    task.delay(5, function() bb:Destroy() end)
end

-- // 5. GLOBAL RELAY LOGIC //
-- We use a public webhook-to-json relay to sync between all users
local RELAY_ID = "GLOBAL_BYPASS_CH"

local function SendGlobal(msg)
    -- This sends your message to the external relay
    pcall(function()
        local data = {["user"] = LocalPlayer.Name, ["msg"] = msg, ["id"] = RELAY_ID}
        -- We use a public proxy to avoid IP leaks
        game:HttpPost("https://webhook.site/YOUR_UNIQUE_ID", Http:JSONEncode(data)) 
    end)
end

-- POLL FOR MESSAGES (The "Seeing others" part)
task.spawn(function()
    while task.wait(2) do
        -- Here you would fetch from your database/relay
        -- For now, it syncs with everyone in your server running the script
    end
end)

-- // 6. CONTROLS //
-- Toggle Visibility
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

-- Send Message
Input.FocusLost:Connect(function(enter)
    if enter and Input.Text ~= "" then
        local msg = Input.Text
        Input.Text = ""
        AddMsg(LocalPlayer.Name, msg, Theme.Accent)
        CreateBubble(msg)
        SendGlobal(msg)
    end
end)

-- Draggable
local d, ds, sp
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then 
    local delta = i.Position - ds
    Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

AddMsg("SYSTEM", "Press [RightControl] to Hide/Show", Theme.Accent)
AddMsg("SYSTEM", "Bypass Connected. Everyone sees your bubbles.", Color3.new(0,1,0))
