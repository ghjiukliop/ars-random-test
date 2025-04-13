local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Đường dẫn tới folder chứa toàn bộ kẻ địch
local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")

local targetEnemy = nil
local recentlyKilledEnemies = {}

-- Lấy HP từ GUI của enemy
local function getEnemyHealthFromGUI(enemy)
    if enemy and enemy:FindFirstChild("HealthBar") then
        local amountLabel = enemy.HealthBar:FindFirstChild("Main") and enemy.HealthBar.Main:FindFirstChild("Bar") and enemy.HealthBar.Main.Bar:FindFirstChild("Amount")
        if amountLabel and amountLabel:IsA("TextLabel") then
            local text = amountLabel.Text
            local value = tonumber(text:match("%d+"))
            return value or 0
        end
    end
    return 0
end

-- Tìm enemy SL1 gần nhất chưa bị tiêu diệt
local function findNearestSL1Enemy()
    local nearestEnemy = nil
    local minDistance = math.huge

    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local attributes = enemy:GetAttributes()
        local isRecentlyKilled = table.find(recentlyKilledEnemies, enemy) ~= nil

        if attributes and attributes["ID"] == "SL1" and enemy:FindFirstChild("HumanoidRootPart") and not isRecentlyKilled then
            local enemyRootPart = enemy:FindFirstChild("HumanoidRootPart")
            local distance = (humanoidRootPart.Position - enemyRootPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestEnemy = enemy
            end
        end
    end
    return nearestEnemy
end

-- Teleport lại gần enemy
local function teleportToEnemy(enemy)
    if enemy and humanoidRootPart then
        local enemyRootPart = enemy:FindFirstChild("HumanoidRootPart")
        if enemyRootPart then
            humanoidRootPart.CFrame = enemyRootPart.CFrame + Vector3.new(0, 2, 0)
        end
    end
end

local checkTargetInterval = 0.5
local lastCheckTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
    lastCheckTime += deltaTime

    -- Dọn danh sách enemy đã chết (không còn tồn tại trong game)
    for i = #recentlyKilledEnemies, 1, -1 do
        if not recentlyKilledEnemies[i]:IsDescendantOf(game) then
            table.remove(recentlyKilledEnemies, i)
        end
    end

    if lastCheckTime >= checkTargetInterval then
        lastCheckTime = 0

        if not targetEnemy then
            local nearestSL1 = findNearestSL1Enemy()
            if nearestSL1 then
                targetEnemy = nearestSL1
                print("🔍 Đã tìm thấy mục tiêu SL1 gần nhất:", targetEnemy.Name)
                teleportToEnemy(targetEnemy)
            else
                print("❌ Không tìm thấy kẻ địch SL1.")
            end
        elseif getEnemyHealthFromGUI(targetEnemy) <= 0 then
            print("☠️ Mục tiêu:", targetEnemy.Name, "đã chết.")
            table.insert(recentlyKilledEnemies, targetEnemy)
            targetEnemy = nil
        else
            -- Vẫn đang theo dõi mục tiêu hiện tại
            local distance = (humanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).Magnitude
            if distance > 10 then
                teleportToEnemy(targetEnemy)
            end

            local currentHP = getEnemyHealthFromGUI(targetEnemy)
            print("❤️ Theo dõi:", targetEnemy.Name, " - HP:", currentHP)
        end
    end
end)
