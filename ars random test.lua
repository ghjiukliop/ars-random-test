local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")

local targetEnemy = nil
local recentlyKilledEnemies = {}
local canCollideOriginal = humanoidRootPart.CanCollide

local moveSpeed = 80 -- tốc độ di chuyển

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

		if attributes and attributes["ID"] == "SL1" and enemy:FindFirstChild("Head") and not isRecentlyKilled then
			local enemyHead = enemy:FindFirstChild("Head")
			local distance = (humanoidRootPart.Position - enemyHead.Position).Magnitude
			if distance < minDistance then
				minDistance = distance
				nearestEnemy = enemy
			end
		end
	end
	return nearestEnemy
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
				humanoidRootPart.CanCollide = false -- bật đi xuyên
			else
				print("❌ Không tìm thấy enemy SL1.")
				restoreCanCollide()
			end
		elseif getEnemyHealthFromGUI(targetEnemy) <= 0 then
			print("☠️ Mục tiêu", targetEnemy.Name, "đã chết.")
			table.insert(recentlyKilledEnemies, targetEnemy)
			targetEnemy = nil
			restoreCanCollide()
		end
	end

	-- Nếu đang có mục tiêu, di chuyển vật lý tới HEAD của kẻ địch
	if targetEnemy and targetEnemy:FindFirstChild("Head") then
		local enemyHead = targetEnemy.Head
		local direction = (enemyHead.Position - humanoidRootPart.Position).Unit
		local distance = (enemyHead.Position - humanoidRootPart.Position).Magnitude

		if distance > 3 then
			humanoidRootPart.Velocity = direction * moveSpeed
		else
			humanoidRootPart.Velocity = Vector3.zero
		end

		print("❤️ Đang theo dõi:", targetEnemy.Name, " - HP:", getEnemyHealthFromGUI(targetEnemy))
	end
end)

character.Destroying:Connect(function()
	restoreCanCollide()
end)
