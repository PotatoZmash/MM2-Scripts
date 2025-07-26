-- Load Rayfield GUI
local success, RayfieldLibrary = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("Rayfield failed to load!")
    return
end

local Rayfield = RayfieldLibrary()

local Window = Rayfield:CreateWindow({
    Name = "MM2 Safe Autofarm by Yureiii",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Autofarming BeachBalls",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🌴 Autofarm", 4483362458)

-- Setup
local plr = game.Players.LocalPlayer
local ts = game:GetService("TweenService")
local character = plr.Character or plr.CharacterAdded:Wait()
local humPart = character:WaitForChild("HumanoidRootPart")
local maxStepDistance = 25 -- distance per safe tween step

plr.CharacterAdded:Connect(function(char)
    character = char
    humPart = char:WaitForChild("HumanoidRootPart")
end)

local delay = 0.5
local map
getgenv().farm = false

-- Helper: Tween to position safely in steps
local function safeTweenTo(targetPos)
    if not humPart then return end
    local current = humPart.Position
    local totalDistance = (targetPos - current).Magnitude
    local direction = (targetPos - current).Unit

    local steps = math.ceil(totalDistance / maxStepDistance)
    for i = 1, steps do
        if not getgenv().farm then break end
        local stepDistance = math.min(maxStepDistance, (targetPos - humPart.Position).Magnitude)
        local nextPos = humPart.Position + direction * stepDistance

        -- Apply horizontal rotation
        local cframe = CFrame.new(nextPos) * CFrame.Angles(math.rad(90), 0, 0)
        local tween = ts:Create(humPart, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { CFrame = cframe })
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.02)
    end
end

-- Toggle: Start/Stop Autofarming
MainTab:CreateToggle({
    Name = "BeachBall Autofarm (Safe Step Tween)",
    CurrentValue = false,
    Callback = function(state)
        getgenv().farm = state

        while getgenv().farm do
            -- Refresh CoinContainer
            if not map or not map.Parent then
                for _, m in ipairs(game.Workspace:GetDescendants()) do
                    if m:IsA("Model") and m.Name == "CoinContainer" then
                        map = m
                        break
                    end
                end
            end

            if map and map.Parent then
                for _, coin in ipairs(map:GetChildren()) do
                    if not getgenv().farm then break end
                    if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                        local cv = coin:FindFirstChild("CoinVisual")
                        if cv and cv.Transparency ~= 1 then
                            humPart = character and character:FindFirstChild("HumanoidRootPart")
                            if not humPart then break end

                            local coinPos = (coin.CFrame * CFrame.new(0, 4, 0)).Position
                            local distance = (humPart.Position - coinPos).Magnitude
                            if distance <= 200 then -- skip unreachable coins
                                for _, p in pairs(character:GetChildren()) do
                                    if p:IsA("BasePart") then p.CanCollide = false end
                                end
                                safeTweenTo(coinPos)
                                task.wait(delay)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end,
})

-- Delay Input
MainTab:CreateInput({
    Name = "Delay After Each Coin",
    PlaceholderText = "Default = 0.5",
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
                Content = "Enter a valid number like 0.3",
                Duration = 3,
            })
        end
    end,
})
