-- Kết hợp script dịch chuyển và quét máu các enemy cùng tên, ưu tiên enemy còn sống

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local selectedEnemyName = nil
local lastEnemy = nil
local enemyNames = {"Gonshee", "longIn", "Largalgan", "daek", "anders", "Soondoo"}

-- Dropdown
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 150, 0, 40)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn enemy"
dropdown.Parent = gui

local currentMenu = nil

local function destroyMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
end

dropdown.MouseButton1Click:Connect(function()
    destroyMenu()
    local menu = Instance.new("Frame", gui)
    menu.Size = UDim2.new(0, 150, 0, #enemyNames * 30)
    menu.Position = UDim2.new(0, 20, 0, 140)
    menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    currentMenu = menu

    for i, name in ipairs(enemyNames) do
        local btn = Instance.new("TextButton", menu)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        btn.Text = name
        btn.MouseButton1Click:Connect(function()
            selectedEnemyName = name
            dropdown.Text = name
            destroyMenu()
            lastEnemy = nil -- reset để chọn lại enemy gần nhất còn sống
        end)
    end
end)

-- Nút dịch chuyển thủ công
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 150, 0, 40)
teleportButton.Position = UDim2.new(0, 20, 0, 60)
teleportButton.Text = "🔁 Dịch chuyển"
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
teleportButton.TextColor3 = Color3.new(1,1,1)
teleportButton.Parent = gui

teleportButton.MouseButton1Click:Connect(function()
    lastEnemy = nil
end)

local function getClientEnemies()
    return workspace:FindFirstChild("__Main")
        and workspace.__Main:FindFirstChild("__Enemies")
        and workspace.__Main.__Enemies:FindFirstChild("Client")
end

-- Trả về enemy gần nhất còn máu
local function getBestAliveEnemy(name)
    local enemies = getClientEnemies()
    if not enemies then return nil end

    local bestEnemy, minDist = nil, math.huge

    for _, enemy in pairs(enemies:GetChildren()) do
        local head = enemy:FindFirstChild("Head")
        local title = enemy:FindFirstChild("HealthBar")
            and enemy.HealthBar:FindFirstChild("Main")
            and enemy.HealthBar.Main:FindFirstChild("Title")

        local hpAmount = enemy.HealthBar and enemy.HealthBar.Main
            and enemy.HealthBar.Main:FindFirstChild("Bar")
            and enemy.HealthBar.Main.Bar:FindFirstChild("Amount")

        if title and title:IsA("TextLabel") and title.Text == name and head and hpAmount and hpAmount:IsA("TextLabel") then
            local hp = tonumber(hpAmount.Text)
            if hp and hp > 0 then
                local dist = (head.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    bestEnemy = enemy
                end
            end
        end
    end
    return bestEnemy
end

-- Theo dõi liên tục
RunService.RenderStepped:Connect(function()
    if not selectedEnemyName then return end

    -- Nếu enemy hiện tại chết hoặc không hợp lệ -> tìm mới
    if lastEnemy then
        local hpAmount = lastEnemy:FindFirstChild("HealthBar")
            and lastEnemy.HealthBar:FindFirstChild("Main")
            and lastEnemy.HealthBar.Main:FindFirstChild("Bar")
            and lastEnemy.HealthBar.Main.Bar:FindFirstChild("Amount")

        if not lastEnemy:FindFirstChild("Head") or not hpAmount or not hpAmount:IsA("TextLabel") or tonumber(hpAmount.Text) == 0 then
            lastEnemy = nil
        end
    end

    -- Tìm kẻ địch mới nếu cần
    if not lastEnemy then
        lastEnemy = getBestAliveEnemy(selectedEnemyName)
        if lastEnemy then
            print("🎯 Đã chọn enemy mới:", selectedEnemyName)
        end
    end

    -- Dịch chuyển đến đầu enemy
    if lastEnemy and lastEnemy:FindFirstChild("Head") then
        local tween = TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
            CFrame = lastEnemy.Head.CFrame * CFrame.new(0, 2, 0)
        })
        tween:Play()
    end
end)
