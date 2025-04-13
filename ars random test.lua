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
local moveSpeed = 50 -- studs/sec
local canCollideOriginal = nil
local activeTween = nil

local function getEnemyHealthFromGUI(enemy)
    if enemy and enemy:FindFirstChild("HealthBar") and enemy.HealthBar.Main:FindFirstChild("Bar")
       and enemy.HealthBar.Main.Bar:FindFirstChild("Amount") and enemy.HealthBar.Main.Bar.Amount:IsA("TextLabel") then
        local healthString = enemy.HealthBar.Main.Bar.Amount.Text
        local healthMatch = healthString:match("(%d+)")
        return tonumber(healthMatch) or 0
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
            local dist = (humanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestEnemy = enemy
            end
        end
    end
    return nearestEnemy
end

local function moveToEnemy(enemy)
    if enemy and humanoidRootPart then
        if activeTween then activeTween:Cancel() end -- Hủy tween cũ nếu có

        local targetPos = enemy:WaitForChild("HumanoidRootPart").Position + Vector3.new(0, 2, 0)
        local distance = (humanoidRootPart.Position - targetPos).Magnitude
        local duration = distance / moveSpeed

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        activeTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
        activeTween:Play()
    end
end

local function setCanCollide(canCollide)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = canCollide
        end
    end
end

local checkTargetInterval = 0.5
local lastCheckTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
    lastCheckTime += deltaTime

    for i = #recentlyKilledEnemies, 1, -1 do
        if recentlyKilledEnemies[i] and not recentlyKilledEnemies[i]:IsDescendantOf(game) then
            table.remove(recentlyKilledEnemies, i)
        end
    end

    if lastCheckTime >= checkTargetInterval then
        lastCheckTime = 0

        if not targetEnemy then
            local nearestSL1 = findNearestSL1Enemy()
            if nearestSL1 then
                targetEnemy = nearestSL1
                print("🎯 Đã tìm thấy mục tiêu SL1:", targetEnemy.Name)
                if canCollideOriginal == nil then
                    canCollideOriginal = humanoidRootPart.CanCollide
                end
                setCanCollide(false)
                moveToEnemy(targetEnemy)
            else
                print("⚠️ Không tìm thấy kẻ địch SL1.")
                if canCollideOriginal ~= nil then
                    setCanCollide(canCollideOriginal)
                    canCollideOriginal = nil
                end
            end
        elseif targetEnemy and getEnemyHealthFromGUI(targetEnemy) <= 0 then
            print("💀 Mục tiêu", targetEnemy.Name, "đã hết máu.")
            table.insert(recentlyKilledEnemies, targetEnemy)
            targetEnemy = nil
            if canCollideOriginal ~= nil then
                setCanCollide(canCollideOriginal)
                canCollideOriginal = nil
            end
        elseif targetEnemy then
            moveToEnemy(targetEnemy) -- Luôn gọi moveToEnemy nếu còn sống
            print("➡️ Đang theo dõi:", targetEnemy.Name, "Máu:", getEnemyHealthFromGUI(targetEnemy))
        end
    end
end)

character:Destroying:Connect(function()
    if canCollideOriginal ~= nil then
        setCanCollide(canCollideOriginal)
    end
end)

game:GetService("Debris"):AddItem(script, 5)
