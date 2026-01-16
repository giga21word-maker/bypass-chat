-- Event-driven Avatar Restoration (optimized)
-- Replaces the heavy per-frame scanning approach with event-driven handling
-- Note: clients cannot access server-only containers (ServerStorage). This only affects
-- instances that are already replicated to the client.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Weak set to remember hidden cubes (avoids memory leaks)
local hiddenCubes = setmetatable({}, { __mode = "k" })

-- Track character connections so we can clean up
local charConnections = {}

-- Utility: set property if different (wrapped in pcall for safety on writes)
local function safeSet(instance, prop, value)
    local ok, err = pcall(function()
        if instance[prop] ~= value then
            instance[prop] = value
        end
    end)
    return ok, err
end

-- Restore visible parts/decals/beams/trails in a model (only writes when needed)
local function restoreModel(model)
    if not model or not model:IsA("Instance") then return end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Transparency and LocalTransparencyModifier (if exists)
            if part.Transparency ~= 0 then
                pcall(function() part.Transparency = 0 end)
            end
            -- LocalTransparencyModifier exists on some clients; check safely
            if part.LocalTransparencyModifier and part.LocalTransparencyModifier ~= 0 then
                pcall(function() part.LocalTransparencyModifier = 0 end)
            end
        elseif part:IsA("Decal") then
            if part.Transparency ~= 0 then
                pcall(function() part.Transparency = 0 end)
            end
        elseif part:IsA("Beam") or part:IsA("Trail") then
            if part.Enabled == false then
                pcall(function() part.Enabled = true end)
            end
        end

        -- Show anything with "laser" in its name if it's a part or decal
        local name = part.Name
        if type(name) == "string" and name:lower():find("laser") then
            if part:IsA("BasePart") or part:IsA("Decal") then
                if part.Transparency ~= 0 then
                    pcall(function() part.Transparency = 0 end)
                end
            end
        end
    end
end

-- Hide cube-like puppets near a head (runs once per character and on DescendantAdded events)
local function hideCubesNearHead(head)
    if not head or not head:IsA("BasePart") then return end

    -- One-time scan of existing workspace descendants (cheap because it's not per-frame)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Part" and obj.Size and obj.Size.Y > 3 then
            if not hiddenCubes[obj] then
                local ok, dist = pcall(function() return (obj.Position - head.Position).Magnitude end)
                if ok and dist and dist < 5 then
                    hiddenCubes[obj] = true
                    pcall(function()
                        obj.Transparency = 1
                        if obj.CanQuery ~= nil then
                            obj.CanQuery = false
                        end
                    end)
                end
            end
        end
    end
end

-- When workspace gets a new descendant, if it's a cube puppet and near any known head, hide it.
-- We keep a simple lookup of current heads to test proximity.
local knownHeads = setmetatable({}, { __mode = "k" })

local function onWorkspaceDescendantAdded(desc)
    if not desc or not desc:IsA("BasePart") then return end
    if desc.Name ~= "Part" or not desc.Size or desc.Size.Y <= 3 then return end
    if hiddenCubes[desc] then return end

    -- Check against each known head quickly
    for head in pairs(knownHeads) do
        if head and head.Parent then
            local ok, dist = pcall(function() return (desc.Position - head.Position).Magnitude end)
            if ok and dist and dist < 5 then
                hiddenCubes[desc] = true
                pcall(function()
                    desc.Transparency = 1
                    if desc.CanQuery ~= nil then
                        desc.CanQuery = false
                    end
                end)
                return
            end
        end
    end
end

Workspace.DescendantAdded:Connect(onWorkspaceDescendantAdded)

-- Setup handlers for a single player's character
local function onCharacterAdded(player, character)
    if not character or not character:IsA("Model") then return end

    -- Restore visible parts initially
    spawn(function()
        -- small delay to let character fully replicate if needed
        wait(0.1)
        restoreModel(character)
    end)

    -- Attempt to hide nearby cube puppets for this character's head
    local head = character:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        knownHeads[head] = true
        hideCubesNearHead(head)
    end

    -- Listen for new descendants on the character (e.g., parts or effects appearing)
    local dConn
    dConn = character.DescendantAdded:Connect(function(desc)
        if desc and (desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Beam") or desc:IsA("Trail")) then
            -- small, targeted restore for this new descendant
            spawn(function()
                pcall(function()
                    if desc:IsA("BasePart") then
                        if desc.Transparency ~= 0 then desc.Transparency = 0 end
                        if desc.LocalTransparencyModifier and desc.LocalTransparencyModifier ~= 0 then
                            desc.LocalTransparencyModifier = 0
                        end
                    elseif desc:IsA("Decal") and desc.Transparency ~= 0 then
                        desc.Transparency = 0
                    elseif (desc:IsA("Beam") or desc:IsA("Trail")) and desc.Enabled == false then
                        desc.Enabled = true
                    end
                end)
            end)
        end

        -- If a Head is added after initial load, track it for cube-hiding
        if desc and desc.Name == "Head" and desc:IsA("BasePart") then
            knownHeads[desc] = true
            hideCubesNearHead(desc)
        end
    end)

    -- Save connection to clean up later
    charConnections[character] = dConn

    -- Clean up when character is removed
    local removedConn
    removedConn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            -- disconnect descendant listener
            if dConn then dConn:Disconnect() end
            if removedConn then removedConn:Disconnect() end
            charConnections[character] = nil
            -- remove any head entries referencing this character
            for head in pairs(knownHeads) do
                if head and head.Parent == nil then
                    knownHeads[head] = nil
                end
            end
        end
    end)
end

-- Player handling
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char) onCharacterAdded(player, char) end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end)

-- Initialize for existing players
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function(char) onCharacterAdded(player, char) end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

-- Hide black/flash UI frames: one-time pass + listen for new children
local function hideBlackFrames(playerGui)
    if not playerGui then return end
    for _, v in ipairs(playerGui:GetDescendants()) do
        if v:IsA("Frame") and type(v.Name) == "string" then
            local lname = v.Name:lower()
            if lname:find("blind") or lname:find("black") then
                pcall(function() v.Visible = false end)
            end
        end
    end

    -- Listen for new children, check only the new child
    playerGui.ChildAdded:Connect(function(child)
        pcall(function()
            if child:IsA("Frame") and type(child.Name) == "string" then
                local n = child.Name:lower()
                if n:find("blind") or n:find("black") then
                    child.Visible = false
                end
            end
        end)
    end)
end

-- Run one-time GUI pass for local player
if LocalPlayer:FindFirstChild("PlayerGui") then
    hideBlackFrames(LocalPlayer.PlayerGui)
else
    -- Wait for PlayerGui if it doesn't exist yet
    LocalPlayer:GetPropertyChangedSignal("PlayerGui"):Connect(function()
        if LocalPlayer:FindFirstChild("PlayerGui") then
            hideBlackFrames(LocalPlayer.PlayerGui)
        end
    end)
end

print("Optimized Avatar Restoration loaded. Event-driven and less laggy.")
