-- ✅ Auto Chase SL1 Enemy with Noclip (Updated Version)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")

local targetEnemy = nil
local recentlyKilledEnemies = {}

-- ⚙️ Tốc độ di chuyển
local moveSpeed = 150

-- 🧊 Noclip system
local Noclip = nil
local Clip = nil

function noclip()
	Clip = false
	local function Nocl()
		if not Clip and player.Character ~= nil then
			for _, v in pairs(player.Character:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
				end
			end
		end
		wait(0.21)
	end
	Noclip = RunService.Stepped:Connect(Nocl)
end

function clip()
	if Noclip then Noclip:Disconnect() end
	Clip = true
end

-- 🚫 Tắt noclip khi huỷ nhân vật
character.Destroying:Connect(function()
	clip()
end)

-- Lấy máu từ HealthBar GUI
local function getEnemyHealthFromGUI(enemy)
	if enemy and enemy:FindFirstChild("HealthBar") then
		local amountLabel = enemy.HealthBar:FindFirstChild("Main")
			and enemy.HealthBar.Main:FindFirstChild("Bar")
			and enemy.HealthBar.Main.Bar:FindFirstChild("Amount")

		if amountLabel and amountLabel:IsA("TextLabel") then
			local text = amountLabel.Text
			local value = tonumber(text:match("%d+"))
			return value or 0
		end
	end
	return 0
end

-- Tìm enemy gần nhất có ID = SL1
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

-- Bắt đầu noclip
noclip()

-- Theo dõi mục tiêu
local checkTargetInterval = 0.5
local lastCheckTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
	lastCheckTime = lastCheckTime + deltaTime

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
			else
				print("❌ Không tìm thấy enemy SL1.")
				clip()
			end
		elseif getEnemyHealthFromGUI(targetEnemy) <= 0 then
			print("☠️ Mục tiêu", targetEnemy.Name, "đã chết.")
			table.insert(recentlyKilledEnemies, targetEnemy)
			targetEnemy = nil
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
