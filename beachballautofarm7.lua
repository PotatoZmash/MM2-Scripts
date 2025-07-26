-- Load Rayfield GUI
local success, RayfieldLibrary = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("Rayfield failed to load!")
    return
end

local Rayfield = RayfieldLibrary()

-- GUI Window
local Window = Rayfield:CreateWindow({
    Name = "MM2 Summer Autofarm | by Yureiii",
    Name = "MM2 Summer Autofarm ⛱️🌞| by Norqueloid",
    LoadingTitle = "Loading Rayfield...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- Tabs
local MainTab = Window:CreateTab("🌴 Autofarm", 4483362458)
local UtilityTab = Window:CreateTab("⚙️ Utilities", 6034818373)
local InfoTab = Window:CreateTab("📌 Info", 6031302924)

-- Setup
local plr = game.Players.LocalPlayer
local ts = game:GetService("TweenService")
local character = plr.Character or plr.CharacterAdded:Wait()
local humPart = character:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(char)
    character = char
    humPart = char:WaitForChild("HumanoidRootPart")
end)

-- Vars
local map
local delay = 1.2
local delay = 0.6
getgenv().farm = false

-- Autofarm Toggle (Safe Tween)
MainTab:CreateToggle({
    Name = "BeachBall Autofarm (Safe Mode)",
    CurrentValue = false,
    Callback = function(state)
        getgenv().farm = state
        while getgenv().farm do
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

                            local distance = (humPart.Position - coin.Position).Magnitude
                            if distance <= 90 then -- Prevent anti-cheat
                                for _, p in pairs(character:GetChildren()) do
                                    if p:IsA("BasePart") and p.CanCollide then
                                        p.CanCollide = false
                                    end
                                end
                                local goal = { CFrame = coin.CFrame * CFrame.new(0, 3, 0) }
                                local tween = ts:Create(humPart, TweenInfo.new(1.5, Enum.EasingStyle.Linear), goal)
                                tween:Play()
                                tween.Completed:Wait()
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

-- Delay Input (with confirmation)
MainTab:CreateInput({
    Name = "Tween Delay (seconds)",
    PlaceholderText = "Default = 1.2",
    PlaceholderText = "Default = 0.6",
    RemoveTextAfterFocusLost = true,
    Callback = function(input)
        local val = tonumber(input)
        if val then
            delay = val
            Rayfield:Notify({
                Title = "Delay Updated",
                Content = "New tween delay: " .. tostring(val) .. "s",
                Duration = 4,
            })
        else
            Rayfield:Notify({
                Title = "Invalid Input",
                Content = "Enter a number like 0.8 or 1.5",
                Duration = 4,
            })
        end
    end,
})

-- Anti-AFK Button
UtilityTab:CreateButton({
    Name = "Enable Anti-AFK",
    Callback = function()
        local GC = getconnections or get_signal_cons
        if GC then
            for _, v in pairs(GC(plr.Idled)) do
                if v.Disable then v:Disable() elseif v.Disconnect then v:Disconnect() end
            end
        else
            local vu = cloneref(game:GetService("VirtualUser"))
            plr.Idled:Connect(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
        Rayfield:Notify({
            Title = "Anti-AFK Enabled",
            Content = "You will not be kicked for being idle.",
            Duration = 5,
        })
    end,
})

-- Info Tab
InfoTab:CreateParagraph({
    Title = "Script by Yureiii",
    Content = "t.me/arceusxscripts\nSafe + Smooth Autofarm for MM2 BeachBalls.",
    Title = "Script by Norqueloid",
    Content = "www.youtube.com/@norqueloid\nSafe + Smooth Autofarm for MM2 BeachBalls.",
})
