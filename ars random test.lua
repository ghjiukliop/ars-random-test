local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")

local targetEnemy = nil
local recentlyKilledEnemies = {}

-- ⚙️ Dễ dàng điều chỉnh tốc độ
local moveSpeed = 150

-- Lưu lại trạng thái CanCollide gốc của từng part
local originalCollideStates = {}

-- Đi xuyên vật thể cho toàn bộ part
local function setNoCollideAllParts()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			originalCollideStates[part] = part.CanCollide
			part.CanCollide = false
		end
	end
end

-- Khôi phục trạng thái CanCollide
local function restoreCollideAllParts()
	for part, original in pairs(originalCollideStates) do
		if part and part:IsA("BasePart") then
			part.CanCollide = original
		end
	end
	originalCollideStates = {}
end

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
			local distance = (humanoidRootPart.Position - enemy.Head.Position).Magnitude
			if distance < minDistance then
				minDistance = distance
				nearestEnemy = enemy
			end
		end
	end
	return nearestEnemy
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
				setNoCollideAllParts()
			else
				print("❌ Không tìm thấy enemy SL1.")
				restoreCollideAllParts()
			end
		elseif getEnemyHealthFromGUI(targetEnemy) <= 0 then
			print("☠️ Mục tiêu", targetEnemy.Name, "đã chết.")
			table.insert(recentlyKilledEnemies, targetEnemy)
			targetEnemy = nil
			restoreCollideAllParts()
		end
	end

	-- Nếu đang có mục tiêu, di chuyển vật lý tới đầu kẻ địch
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

-- Khi nhân vật bị huỷ
character.Destroying:Connect(function()
	restoreCollideAllParts()
end)
