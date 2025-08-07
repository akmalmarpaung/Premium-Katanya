-- ✅ Cek executor kompatibilitas Delta
if not getgenv then
    return game.Players.LocalPlayer:Kick("Executor tidak mendukung!")
end

-- ✅ Load Rayfield GUI (anime style)
loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "🌸 Fish It - Anime Hub by Akmal",
    LoadingTitle = "🐟 Ultimate Fishing GUI",
    LoadingSubtitle = "Delta Ready • Anime Style",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FishItAnimeHub",
        FileName = "fishit_config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- 🗂️ Tabs
local mainTab = Window:CreateTab("🎣 Fishing", 4483362458)
local sellTab = Window:CreateTab("💰 Sell & Shop", 4483362458)
local navTab = Window:CreateTab("🚤 Navigation", 4483362458)
local systemTab = Window:CreateTab("⚙️ System", 4483362458)

-- 🔄 Variabel global
getgenv().AutoFish = false
getgenv().PerfectMode = true
getgenv().FishDelay = 1
getgenv().AutoSell = false
getgenv().AutoAFK = true
getgenv().WebhookURL = "https://discord.com/api/webhooks/ISI_PUNYA_KAMU"
getgenv().ReturnPosition = nil
getgenv().AutoWeather = true
getgenv().EventRunning = false
getgenv().Admins = {"Mod", "Admin", "Owner"}


-- 🎣 Auto Perfect Fishing
mainTab:CreateToggle({
    Name = "Auto Perfect Fishing 🎯",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoFish = v
        while getgenv().AutoFish and task.wait(getgenv().FishDelay) do
            local args = {"Fishing", "Start"}
            game:GetService("ReplicatedStorage").Remotes.Gameplay:FireServer(unpack(args))
        end
    end
})

-- ⏱️ Custom Delay Fishing
mainTab:CreateSlider({
    Name = "Delay Antar Pancing (detik)",
    Range = {0.5, 5},
    Increment = 0.1,
    Suffix = " detik",
    CurrentValue = 1,
    Callback = function(Value)
        getgenv().FishDelay = Value
    end,
})

-- 💰 Auto Sell
sellTab:CreateToggle({
    Name = "Auto Sell Ikan 🐠",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoSell = v
        while getgenv().AutoSell and task.wait(2) do
            game:GetService("ReplicatedStorage").Remotes.Gameplay:FireServer("SellFish")
        end
    end
})

-- 📤 Webhook Discord untuk Legendary Only
local function sendLegendaryToWebhook(fishName, rarity)
    if rarity ~= "Legendary" then return end
    if not syn then return end

    local HttpService = game:GetService("HttpService")
    local data = {
        ["content"] = "**🎣 Legendary Catch!**",
        ["embeds"] = {{
            ["title"] = fishName,
            ["description"] = "Rarity: `" .. rarity .. "`",
            ["color"] = 16776960
        }}
    }
    syn.request({
        Url = getgenv().WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

-- 🎯 Deteksi Tangkap Ikan
game:GetService("ReplicatedStorage").Remotes.Gameplay.OnClientEvent:Connect(function(event, data)
    if event == "FishCaught" and data then
        local rarity = data.Rarity or "Unknown"
        local name = data.Name or "??"
        sendLegendaryToWebhook(name, rarity)
    end
end)


-- 🛒 Rod Shop
sellTab:CreateButton({
    Name = "Buka Toko Pancing 🎣",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.UI:FireServer("RodShop")
    end
})

-- 🧲 Bait Shop
sellTab:CreateButton({
    Name = "Buka Toko Umpan 🪱",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.UI:FireServer("BaitShop")
    end
})

-- 🚤 Access Semua Boat
navTab:CreateButton({
    Name = "Akses Semua Boat (Unlock) 🚤",
    Callback = function()
        for _, v in pairs(game:GetService("ReplicatedStorage").Boats:GetChildren()) do
            game:GetService("ReplicatedStorage").Remotes.Gameplay:FireServer("UnlockBoat", v.Name)
        end
    end
})

-- 🚤 Spawn Boat
navTab:CreateButton({
    Name = "Spawn Boat 🚢",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.Gameplay:FireServer("SpawnBoat")
    end
})

-- 📍 Teleportasi Lokasi
local teleportPoints = {
    ["Pantai"] = Vector3.new(200, 5, 100),
    ["Tengah Laut"] = Vector3.new(0, 5, 0),
    ["Toko"] = Vector3.new(-150, 5, 250)
}

for name, pos in pairs(teleportPoints) do
    navTab:CreateButton({
        Name = "Teleport ke " .. name,
        Callback = function()
            game.Players.LocalPlayer.Character:MoveTo(pos)
        end
    })
end

-- 📍 Teleport ke Pemain Lain
navTab:CreateInput({
    Name = "Teleport ke Pemain 🧍",
    PlaceholderText = "Masukkan nama pemain...",
    RemoveTextAfterFocusLost = false,
    Callback = function(playerName)
        local target = game.Players:FindFirstChild(playerName)
        if target and target.Character then
            game.Players.LocalPlayer.Character:MoveTo(target.Character.PrimaryPart.Position)
        end
    end
})

-- 🌦️ Auto Ganti Cuaca
eventTab:CreateToggle({
    Name = "Auto Weather ☁️🌤️🌧️",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoWeather = v
        while getgenv().AutoWeather and task.wait(10) do
            local desiredWeather = "Sunny"
            game:GetService("ReplicatedStorage").Remotes.Gameplay:FireServer("SetWeather", desiredWeather)
        end
    end
})

-- 🎉 Auto ke Event dan Balik
local lastPosition = nil
eventTab:CreateToggle({
    Name = "Auto Pergi ke Event dan Balik ⏪",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoEvent = v
        while getgenv().AutoEvent and task.wait(3) do
            local eventActive = workspace:FindFirstChild("EventZone")
            if eventActive then
                lastPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                game.Players.LocalPlayer.Character:MoveTo(eventActive.Position + Vector3.new(0, 5, 0))
                repeat task.wait(1) until not workspace:FindFirstChild("EventZone") or not getgenv().AutoEvent
                if lastPosition then
                    game.Players.LocalPlayer.Character:MoveTo(lastPosition)
                end
            end
        end
    end
})

-- 💤 Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- 🚨 Deteksi Admin & Auto Hoop Server
local function isAdmin(player)
    local groupId, rankId = 123456, 254 -- Ganti ini kalau perlu
    return player:IsInGroup(groupId) and player:GetRankInGroup(groupId) >= rankId
end

game.Players.PlayerAdded:Connect(function(plr)
    task.wait(2)
    if isAdmin(plr) then
        for i = 1, 100 do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("HOOP SERVER 🚨 ADMIN MASUK", "All")
            task.wait(0.5)
        end
    end
end)

-- 🎣 Kirim Legendary Fish ke Discord Webhook
local webhookUrl = "https://discord.com/api/webhooks/1402728758661615696/DKwauPx71M4t4wcFaoXcXa6oNYAsuNWg0DuyUgKPve54HU_ld_qD9J9Z0vgpYkIqMDYA" -- Ganti dengan URL webhook kamu

local function sendLegendaryFishToWebhook(fishName, rarity)
    if rarity == "Legendary" then
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "🎣 Legendary Fish Caught!",
                ["description"] = "**" .. fishName .. "** berhasil ditangkap!",
                ["color"] = 16776960
            }}
        }
        local json = game:GetService("HttpService"):JSONEncode(data)
        syn.request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end
end

-- Simulasi trigger fish catch
game:GetService("ReplicatedStorage").Remotes.Catch.OnClientEvent:Connect(function(data)
    sendLegendaryFishToWebhook(data.Name, data.Rarity)
end)

-- 🌸 GUI Style Anime
Rayfield:Notify({
    Title = "Fish It GUI",
    Content = "Theme: Anime Style 🌸",
    Duration = 6,
    Image = "rbxassetid://1234567890", -- Ganti dengan gambar anime
})

-- 🌸 Warna GUI (opsional)
Rayfield:LoadConfiguration()
Rayfield:SetTheme({
    PrimaryColor = Color3.fromRGB(255, 102, 204), -- Pink anime style
    SecondaryColor = Color3.fromRGB(255, 204, 229),
    Font = Enum.Font.GothamBold,
})

-- 🧼 Final: Notifikasi Siap
Rayfield:Notify({
    Title = "GUI Loaded ✅",
    Content = "Semua fitur siap digunakan.",
    Duration = 5
})