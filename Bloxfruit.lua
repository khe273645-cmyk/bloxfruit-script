--[[
    Blox Fruit VIP Script - Giao diện Tiếng Việt
    Hỗ trợ: Auto Farm, Auto Raid, Auto Săn Trái, Auto Đảo
    Chạy được trên PC và Mobile
--]]

-- Kiểm tra và tạo giao diện
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KiuetsVN/Ui_Library/main/Ui_Library"))()

local Window = Library:CreateWindow("Blox Fruit", true) -- true = giao diện kéo thả

-- Tab Chính
local MainTab = Window:CreateTab("⚔️ Farm Chính")
local FruitTab = Window:CreateTab("🍎 Săn Trái")
local RaidTab = Window:CreateTab("🌀 Auto Raid")
local SettingTab = Window:CreateTab("⚙️ Cài Đặt")

-- Biến toàn cục
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Trạng thái các chức năng
local autoFarm = false
local autoCollectFruit = false
local autoRaid = false
local targetFruit = "Leopard"

-- Hàm lấy vị trí hiện tại
local function getNearestNPC()
    local nearest = nil
    local shortest = math.huge
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local humanoid = v:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and v ~= char then
                local pos = v.HumanoidRootPart.Position
                local dist = (pos - hrp.Position).Magnitude
                if dist < shortest and dist <= 50 then
                    shortest = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- Tự động tấn công
local function attack(target)
    if not target then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Di chuyển đến gần
    hrp.CFrame = CFrame.new(target.HumanoidRootPart.Position)
    wait(0.1)
    
    -- Gửi lệnh tấn công
    local args = {
        [1] = target.HumanoidRootPart.Position,
        [2] = target
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat"):FireServer(unpack(args))
end

-- Auto Farm chính
coroutine.wrap(function()
    while true do
        if autoFarm then
            local target = getNearestNPC()
            if target then
                attack(target)
            end
        end
        wait(0.1)
    end
end)()

-- Auto Săn Trái (chạy vòng quanh đảo)
coroutine.wrap(function()
    while true do
        if autoCollectFruit then
            local fruit = workspace:FindFirstChildWhichIsA("Tool")
            if fruit and fruit:IsA("Tool") then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = fruit.Handle.CFrame
                    wait(0.3)
                    -- Nhặt trái
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Collect"):FireServer(fruit)
                end
            end
        end
        wait(0.5)
    end
end)()

-- Tạo giao diện

-- Tab Farm Chính
MainTab:Toggle("🤖 Tự Động Farm (Bật/Tắt)", false, function(state)
    autoFarm = state
    Library:Notification("Thông Báo", "Auto Farm đã " .. (state and "BẬT" or "TẮT"), 2)
end)

MainTab:Toggle("🏃 Tự Động Luyện Chỉ Tay", false, function(state)
    if state then
        -- Code luyện chỉ tay
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton1(Vector2.new())
    end
    Library:Notification("Thông Báo", "Luyện chỉ tay đã " .. (state and "BẬT" or "TẮT"), 2)
end)

MainTab:Button("🔄 Teleport về Đảo Bắt Đầu", function()
    local startIsland = CFrame.new(-1000, 80, 2000)
    if LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = startIsland
        Library:Notification("Di Chuyển", "Đã về đảo khởi điểm", 1)
    end
end)

-- Tab Săn Trái
FruitTab:Toggle("🍎 Tự Động Săn Trái", false, function(state)
    autoCollectFruit = state
    Library:Notification("Săn Trái", "Auto Săn Trái đã " .. (state and "BẬT" or "TẮT"), 2)
end)

FruitTab:Dropdown("🎯 Chọn Trái Mong Muốn", {"Leopard", "Dragon", "Kitsune", "Buddha", "Magma", "Ice"}, function(selected)
    targetFruit = selected
    Library:Notification("Chọn Trái", "Mục tiêu: " .. targetFruit, 1)
end)

-- Tab Auto Raid
RaidTab:Toggle("🌀 Tự Động Raid (Bật/Tắt)", false, function(state)
    autoRaid = state
    if autoRaid then
        -- Gọi code raid
        local args = {
            [1] = "StartRaid"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Raid"):FireServer(unpack(args))
    end
    Library:Notification("Auto Raid", "Raid đã " .. (state and "BẬT" or "TẮT"), 2)
end)

RaidTab:Button("🔄 Ghép Đội Raid", function()
    local args = {
        [1] = "RequestRaid"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Raid"):FireServer(unpack(args))
    Library:Notification("Raid", "Đã gửi yêu cầu ghép đội", 1)
end)

-- Tab Cài Đặt
SettingTab:Button("🟢 Tái Tạo Nhân Vật (Fix lỗi)", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
    wait(0.5)
    Library:Notification("Fix", "Đã hồi sinh nhân vật", 1)
end)

SettingTab:Button("🌍 Teleport đến NPC Gần Nhất", function()
    local nearest = getNearestNPC()
    if nearest and nearest:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame
        Library:Notification("Teleport", "Đã đến gần NPC", 1)
    else
        Library:Notification("Lỗi", "Không tìm thấy NPC nào", 1)
    end
end)

-- Phím tắt toàn cục
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Nhấn F1 để bật/tắt Auto Farm
    if input.KeyCode == Enum.KeyCode.F1 then
        autoFarm = not autoFarm
        Library:Notification("Phím Tắt", "Auto Farm: " .. (autoFarm and "BẬT" or "TẮT"), 1)
    end
    
    -- Nhấn F2 để bật/tắt Auto Săn Trái
    if input.KeyCode == Enum.KeyCode.F2 then
        autoCollectFruit = not autoCollectFruit
        Library:Notification("Phím Tắt", "Săn Trái: " .. (autoCollectFruit and "BẬT" or "TẮT"), 1)
    end
end)

-- Thông báo khởi động
Library:Notification("✅ Thành Công", "Script đã sẵn sàng!\nNhấn F1 = Farm | F2 = Săn Trái", 3)
