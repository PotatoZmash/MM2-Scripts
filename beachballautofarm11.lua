-- Load Rayfield GUI
local success, RayfieldLibrary = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("Rayfield failed to load!")
    return
end

local Rayfield = RayfieldLibrary()

-- GUI Setup
local Window = Rayfield:CreateWindow({
    Name = "MM2 Autofarm | Safe TP by Yureiii",
    LoadingTitle = "Teleporting to BeachBalls...",
    LoadingSubtitle = "Safe Range Enabled",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🌴 Autofarm", 4483362458)

-- Variables
local plr = game.Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local humPart = character:WaitForChild("HumanoidRootPart")
local delay = 0.3
local map
getgenv().farm = false

-- Update on respawn
plr.CharacterAdded:Connect(function(char)
    character = char
    humPart = char:WaitForChild("HumanoidRootPart")
end)

-- Main Autofarm Toggle
MainTab:CreateToggle({
    Name = "BeachBall Autofarm (Teleport, Safe Range)",
    CurrentValue = false,
    Callback = function(state)
        getgenv().farm = state

        -- Disable physics
        if character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").PlatformStand = state
        end

        while getgenv().farm do
            -- Find CoinContainer
            if not map or not map.Parent then
                for _, m in ipairs(game.Workspace:GetDescendants()) do
                    if m:IsA("Model") and m.Name == "CoinContainer" then
                        map = m
                        break
                    end
                end
            end

            -- Farm loop
            if map and map.Parent then
                for _, coin in ipairs(map:GetChildren()) do
                    if not getgenv().farm then break end
                    if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                        local cv = coin:FindFirstChild("CoinVisual")
                        if cv and cv.Transparency ~= 1 then
                            humPart = character and character:FindFirstChild("HumanoidRootPart")
                            if not humPart then break end

                            local coinPos = (coin.CFrame * CFrame.new(0, 4, 0))
                            local distance = (humPart.Position - coinPos.Position).Magnitude
                            if distance <= 60 then -- ✅ Reduced range for safety
                                for _, p in pairs(character:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        p.CanCollide = false
                                    end
                                end
                                humPart.CFrame = coinPos
                                task.wait(delay)
                            end
                        end
                    end
                end
            end
            task.wait(0.3)
        end

        -- Re-enable physics
        if not state and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end,
})

-- Delay Input
MainTab:CreateInput({
    Name = "Delay After Each Teleport",
    PlaceholderText = "Default = 0.3",
    RemoveTextAfterFocusLost = true,
    Callback = function(input)
        local val = tonumber(input)
        if val then
            delay = val
            Rayfield:Notify({
                Title = "Delay Updated",
                Content = "New delay: " .. tostring(val) .. "s",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Invalid Input",
                Content = "Use a number like 0.25 or 0.6",
                Duration = 3,
            })
        end
    end,
})
