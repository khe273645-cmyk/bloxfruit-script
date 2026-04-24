--[[
    khanhdepzai Hub - Bản sửa chữa
    Giao diện giữ nguyên, core farm hoạt động
--]]

-- ==========================================
-- SERVICES
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- PLAYER & CHARACTER
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 5)
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ==========================================
-- LOAD UI LIBRARY (cập nhật link mới)
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/khanhdepzaihub/UI/main/ui_BananaHub.lua"))()

local Window = Library:CreateWindow({
    Title = "khanhdepzai Hub",
    Desc = "- Blox Fruit",
})

-- ==========================================
-- TẠO CÁC TABS
-- ==========================================
local function AddTab(name)
    return Window:AddTab(name)
end

local MainTab = AddTab("Cày Cấp")
local MiscTab = AddTab("Tiện Ích")
local TeleportTab = AddTab("Dịch Chuyển")

-- =============================
-- BIẾN AUTO FARM
-- =============================
local autoFarm = false
local autoAttack = false
local attackRange = 50

-- =============================
-- TÌM QUÁI GẦN NHẤT
-- =============================
local function getNearestEnemy()
    local nearest, shortest = nil, math.huge
    local char = Player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < shortest and dist <= attackRange then
                    shortest = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- =============================
-- TẤN CÔNG (click chuột)
-- =============================
local function doAttack()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
end

-- =============================
-- DI CHUYỂN ĐẾN QUÁI
-- =============================
local function moveTo(target)
    if not target then return end
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

-- =============================
-- VÒNG LẶP AUTO FARM
-- =============================
spawn(function()
    while true do
        if autoFarm then
            local enemy = getNearestEnemy()
            if enemy then
                moveTo(enemy)
                doAttack()
            end
        end
        wait(0.15)
    end
end)

-- =============================
-- GIAO DIỆN (Section)
-- =============================
local function AddSection(tab, name)
    local group = tab:AddLeftGroupbox(name)
    return group
end

local farmGroup = AddSection(MainTab, "⚔️ TỰ ĐỘNG FARM")
local miscGroup = AddSection(MiscTab, "🛠️ TIỆN ÍCH")
local teleGroup = AddSection(TeleportTab, "🌍 DỊCH CHUYỂN")

-- Nút bật/tắt
farmGroup:AddToggle("Auto Farm Level", {
    Text = "Bật/Tắt",
    Default = false,
    Callback = function(state)
        autoFarm = state
        autoAttack = state
    end
})

farmGroup:AddSlider("Khoảng cách tấn công", {
    Text = "Khoảng cách",
    Min = 30,
    Max = 100,
    Default = 50,
    Callback = function(v)
        attackRange = v
    end
})

miscGroup:AddButton("Tăng tốc chạy", function()
    if Player.Character then
        Player.Character.Humanoid.WalkSpeed = 100
    end
end)

miscGroup:AddButton("Reset tốc độ", function()
    if Player.Character then
        Player.Character.Humanoid.WalkSpeed = 16
    end
end)

miscGroup:AddButton("Hồi sinh nhân vật", function()
    if Player.Character then
        Player.Character:BreakJoints()
    end
end)

teleGroup:AddButton("Về đảo khởi đầu", function()
    if Player.Character then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1000, 80, 2000)
    end
end)

teleGroup:AddButton("Lên Sky Island", function()
    if Player.Character then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(250, 200, 1000)
    end
end)

-- =============================
-- ANTI AFK
-- =============================
local vu = VirtualUser
Player.Idled:Connect(function()
    if vu then
        pcall(function()
            vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- =============================
-- THÔNG BÁO
-- =============================
Library:Notify({
    Title = "khanhdepzai Hub",
    Description = "Đã sẵn sàng! Bật Auto Farm Level để bắt đầu.",
    Duration = 4
})
