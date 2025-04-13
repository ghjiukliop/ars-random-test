local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Đường dẫn tới folder chứa toàn bộ kẻ địch
local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")

local targetEnemy = nil
local recentlyKilledEnemies = {} -- Bảng để lưu trữ các kẻ địch vừa bị "tiêu diệt"

-- Cài đặt cho việc di chuyển nhanh và xuyên vật thể
local moveSpeed = 50 -- Tốc độ di chuyển tới mục tiêu (studs/giây)
local canCollideOriginal = nil

local function getEnemyHealthFromGUI(enemy)
    if enemy and enemy:FindFirstChild("HealthBar") and enemy.HealthBar.Main:FindFirstChild("Bar") and enemy.HealthBar.Main.Bar:FindFirstChild("Amount") and enemy.HealthBar.Main.Bar.Amount:IsA("TextLabel") then
        local healthString = enemy.HealthBar.Main.Bar.Amount.Text
        local healthMatch = healthString:match("(%d+)")
        if healthMatch then
            return tonumber(healthMatch) or 0
        else
            return 0
        end
    else
        return 0
    end
end

local function findNearestSL1Enemy()
    local nearestEnemy = nil
    local minDistance = math.huge

    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local attributes = enemy:GetAttributes()
        local isRecentlyKilled = false
        for _, killedEnemy in ipairs(recentlyKilledEnemies) do
            if killedEnemy == enemy then
                isRecentlyKilled = true
                break
            end
        end

        if attributes and attributes["ID"] == "SL1" and enemy:FindFirstChild("HumanoidRootPart") and not isRecentlyKilled then
            local enemyRootPart = enemy:WaitForChild("HumanoidRootPart")
            local distance = (humanoidRootPart.Position - enemyRootPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestEnemy = enemy
            end
        end
    end
    return nearestEnemy
end

local function moveToEnemy(enemy)
    if enemy and humanoidRootPart then
        local targetPosition = enemy:WaitForChild("HumanoidRootPart").Position
        local distance = (humanoidRootPart.Position - targetPosition).Magnitude
        local duration = distance / moveSpeed -- Tính thời gian di chuyển dựa trên tốc độ và khoảng cách

        local tweenInfo = TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out,
            0,
            false,
            0
        )

        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPosition + Vector3.new(0, 2, 0))})
        tween:Play()
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

    -- Xóa các kẻ địch đã chết khỏi danh sách sau một khoảng thời gian
    for i = #recentlyKilledEnemies, 1, -1 do
        if recentlyKilledEnemies[i] and not recentlyKilledEnemies[i]:IsDescendantOf(game) then
            table.remove(recentlyKilledEnemies, i)
        end
    end

    if lastCheckTime >= checkTargetInterval then
        lastCheckTime = 0

        if not targetEnemy then
            -- Tìm mục tiêu SL1 gần nhất khi chưa có mục tiêu
            local nearestSL1 = findNearestSL1Enemy()
            if nearestSL1 then
                targetEnemy = nearestSL1
                print("Đã tìm thấy mục tiêu SL1:", targetEnemy.Name)
                if canCollideOriginal == nil then
                    canCollideOriginal = character:WaitForChild("HumanoidRootPart").CanCollide
                end
                setCanCollide(false) -- Bật đi xuyên vật thể
                moveToEnemy(targetEnemy)
            else
                print("Không tìm thấy kẻ địch SL1.")
                if canCollideOriginal ~= nil then
                    setCanCollide(canCollideOriginal) -- Khôi phục CanCollide
                    canCollideOriginal = nil
                end
            end
        elseif targetEnemy and getEnemyHealthFromGUI(targetEnemy) <= 0 then
            -- Mục tiêu hiện tại đã hết máu
            print("Mục tiêu hiện tại:", targetEnemy.Name, "đã hết máu (GUI). Tìm mục tiêu mới.")
            table.insert(recentlyKilledEnemies, targetEnemy) -- Thêm kẻ địch đã chết vào danh sách
            targetEnemy = nil -- Reset targetEnemy để tìm mục tiêu mới ở frame tiếp theo
            if canCollideOriginal ~= nil then
                setCanCollide(canCollideOriginal) -- Khôi phục CanCollide
                canCollideOriginal = nil
            end
        elseif targetEnemy then
            -- Luôn di chuyển đến mục tiêu nếu có mục tiêu
            moveToEnemy(targetEnemy)
            print("Đang theo dõi mục tiêu:", targetEnemy.Name, "Máu (GUI):", getEnemyHealthFromGUI(targetEnemy))
        end
    end
end

-- Đảm bảo CanCollide được khôi phục khi script bị dừng hoặc nhân vật bị xóa
character:Destroying:Connect(function()
    if canCollideOriginal ~= nil then
        setCanCollide(canCollideOriginal)
    end
end)

game:GetService("Debris"):AddItem(script, 5) -- Đảm bảo script tự xóa sau một thời gian nếu có lỗi ngăn chặn Destroying event
