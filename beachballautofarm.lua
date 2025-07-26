-- Load Rayfield Library
local success, RayfieldLibrary = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("Rayfield Library failed to load!")
    return
end

local Rayfield = RayfieldLibrary()

-- Create Main GUI Window
local Window = Rayfield:CreateWindow({
    Name = "MM2 Summer BeachBall Autofarm | by Yureiii",
    LoadingTitle = "Loading Rayfield GUI...",
    LoadingSubtitle = "Powered by Rayfield",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Player / Character Setup
local plr = game.Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local humPart = character:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(char)
    character = char
    humPart = char:WaitForChild("HumanoidRootPart")
end)

-- Setup Variables
local map
local delay = 2.5
getgenv().farm = false

-- Autofarm Toggle
Window:CreateToggle({
    Name = "BeachBall Autofarm",
    CurrentValue = false,
    Callback = function(value)
        getgenv().farm = value
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
                            if not humPart or not humPart.Parent then
                                humPart = character and character:FindFirstChild("HumanoidRootPart")
                                if not humPart then break end
                            end
                            for _, p in pairs(character:GetChildren()) do
                                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                            end
                            humPart.CFrame = coin.CFrame * CFrame.new(0, 6, 0)
                            task.wait(delay)
                        end
                    end
                end
            end
            task.wait(1)
        end
    end,
})

-- Delay Input Box
Window:CreateInput({
    Name = "Farm Delay (seconds)",
    PlaceholderText = "Default: 2.5",
    RemoveTextAfterFocusLost = true,
    Callback = function(input)
        delay = tonumber(input) or 2.5
    end,
})

-- Anti-AFK Button
Window:CreateButton({
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
            Title = "Anti-AFK",
            Content = "Anti-AFK has been enabled!",
            Duration = 4,
        })
    end,
})

-- Footer Credit Label
Window:CreateParagraph({
    Title = "Script by Yureiii",
    Content = "Join: t.me/arceusxscripts",
})
