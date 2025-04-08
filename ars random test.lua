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

-- GUI: Dropdown để chọn enemy
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 150, 0, 40)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn enemy"
dropdown.Parent = gui

dropdown.MouseButton1Click:Connect(function()
	local menu = Instance.new("Frame", gui)
	menu.Size = UDim2.new(0, 150, 0, #enemyNames * 30)
	menu.Position = UDim2.new(0, 20, 0, 140)
	menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

	for i, name in ipairs(enemyNames) do
		local btn = Instance.new("TextButton", menu)
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
		btn.Text = name
		btn.MouseButton1Click:Connect(function()
			selectedEnemyName = name
			dropdown.Text = name
			menu:Destroy()
			lastEnemy = nil -- reset lại để chọn enemy mới
		end)
	end
end)

-- Nút dịch chuyển thủ công
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 150, 0, 40)
teleportButton.Position = UDim2.new(0, 180, 0, 100)
teleportButton.Text = "🔁 Dịch chuyển"
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
teleportButton.TextColor3 = Color3.new(1,1,1)
teleportButton.Parent = gui

teleportButton.MouseButton1Click:Connect(function()
	lastEnemy = nil
end)

-- Tìm danh sách enemy còn sống có tên được chọn
local function getLivingEnemiesByName(name)
	local clientEnemies = workspace:FindFirstChild("__Main")
		and workspace.__Main:FindFirstChild("__Enemies")
		and workspace.__Main.__Enemies:FindFirstChild("Client")

	if not clientEnemies then return {} end

	local living = {}
	for _, enemy in pairs(clientEnemies:GetChildren()) do
		local head = enemy:FindFirstChild("Head")
		if enemy:FindFirstChild("HealthBar")
			and enemy.HealthBar:FindFirstChild("Main")
			and enemy.HealthBar.Main:FindFirstChild("Title")
			and enemy.HealthBar.Main:FindFirstChild("Bar")
			and enemy.HealthBar.Main.Bar:FindFirstChild("Amount") then

			local title = enemy.HealthBar.Main.Title
			local amount = enemy.HealthBar.Main.Bar.Amount

			if title:IsA("TextLabel") and title.Text == name then
				if amount:IsA("TextLabel") and tonumber(amount.Text) and tonumber(amount.Text) > 0 then
					table.insert(living, enemy)
				end
			end
		end
	end
	return living
end

-- Lấy enemy gần nhất còn sống theo tên
local function getNearestLivingEnemy(name)
	local candidates = getLivingEnemiesByName(name)
	local closest, minDist = nil, math.huge
	for _, enemy in pairs(candidates) do
		local head = enemy:FindFirstChild("Head")
		if head then
			local dist = (head.Position - root.Position).Magnitude
			if dist < minDist then
				minDist = dist
				closest = enemy
			end
		end
	end
	return closest
end

-- Theo dõi và dịch chuyển bằng Tween
RunService.RenderStepped:Connect(function()
	if not selectedEnemyName then return end

	if lastEnemy and lastEnemy:FindFirstChild("HealthBar")
		and lastEnemy.HealthBar:FindFirstChild("Main")
		and lastEnemy.HealthBar.Main:FindFirstChild("Bar")
		and lastEnemy.HealthBar.Main.Bar:FindFirstChild("Amount") then

		local amount = lastEnemy.HealthBar.Main.Bar.Amount
		if amount:IsA("TextLabel") and tonumber(amount.Text) == 0 then
			lastEnemy = nil
		end
	end

	if not lastEnemy or not lastEnemy:FindFirstChild("Head") then
		lastEnemy = getNearestLivingEnemy(selectedEnemyName)
		if lastEnemy then
			print("➡️ Dịch chuyển đến enemy:", selectedEnemyName)
		end
	end

	if lastEnemy and lastEnemy:FindFirstChild("Head") then
		local targetPos = lastEnemy.Head.CFrame * CFrame.new(0, 2, 0)
		local tween = TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			CFrame = targetPos
		})
		tween:Play()
	end
end)
