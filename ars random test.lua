local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")

local targetEnemy = nil
local recentlyKilledEnemies = {}
local canCollideOriginal = humanoidRootPart.CanCollide

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

-- Di chuyển đến enemy với TweenService
local function moveToEnemy(enemy)
    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
    if enemyHRP then
        if canCollideOriginal ~= nil then
            humanoidRootPart.CanCollide = false
        end

        local goalPosition = enemyHRP.Position + Vector3.new(0, 2, 0)
        local tweenInfo = TweenInfo.new(
            0.4, -- thời gian tween
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )

        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(goalPosition)})
        tween:Play()
    end
end

local function restoreCanCollide()
    if canCollideOriginal ~= nil then
        humanoidRootPart.CanCollide = canCollideOriginal
    end
end

local checkTargetInterval = 0.5
local lastCheckTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
    lastCheckTime += deltaTime

    -- Dọn danh sách kẻ địch đã chết
    for i = #recentlyKilledEnemies, 1, -1 do
        if not recentlyKilledEnemies[i]:IsDescendantOf(game) then
            table.remove(recentlyKilledEnemies, i)
        end
    end

    if lastCheckTime >= checkTargetInterval then
        lastCheckTime = 0

        if not targetEnemy then
            local nearest = findNearestSL1Enemy()
            if nearest then
                targetEnemy = nearest
                print("🎯 Tìm thấy mục tiêu:", targetEnemy.Name)
                moveToEnemy(targetEnemy)
            else
                print("❌ Không tìm thấy enemy SL1.")
                restoreCanCollide()
            end
        elseif getEnemyHealthFromGUI(targetEnemy) <= 0 then
            print("☠️ Mục tiêu", targetEnemy.Name, "đã chết.")
            table.insert(recentlyKilledEnemies, targetEnemy)
            targetEnemy = nil
            restoreCanCollide()
        elseif targetEnemy then
            local dist = (humanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).Magnitude
            if dist > 10 then
                moveToEnemy(targetEnemy)
            end

            local hp = getEnemyHealthFromGUI(targetEnemy)
            print("❤️ Đang theo dõi:", targetEnemy.Name, " - HP:", hp)
        end
    end
end)

-- Khôi phục CanCollide khi character bị phá hủy
character.Destroying:Connect(function()
    restoreCanCollide()
end)
