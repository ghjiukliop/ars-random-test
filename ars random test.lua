-- Danh sách tên kẻ địch
local enemyNames = {
    "Gonshee", "longIn", "Largalgan", "daek", "anders", "Soondoo"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local currentEnemy = nil
local selectedEnemyName = enemyNames[1] -- Mặc định là enemy đầu tiên trong danh sách

-- UI Dropdown
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "EnemyDropdownGui"

local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 200, 0, 40)
dropdown.Position = UDim2.new(0, 10, 0, 100)
dropdown.Text = "Chọn kẻ địch"
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Parent = ScreenGui

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0, 200, 0, #enemyNames * 30)
listFrame.Position = UDim2.new(0, 10, 0, 140)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.Visible = false
listFrame.Parent = ScreenGui

for i, name in ipairs(enemyNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = listFrame

    btn.MouseButton1Click:Connect(function()
        selectedEnemyName = name
        dropdown.Text = "Đã chọn: " .. name
        listFrame.Visible = false
        currentEnemy = nil -- reset khi chọn enemy khác
    end)
end

dropdown.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
end)

-- Hàm tìm kẻ địch gần nhất
local function getNearestEnemyByName(name)
    local closest = nil
    local minDist = math.huge
    for _, enemy in pairs(workspace.__Main.__Enemies.Client:GetChildren()) do
        local title = enemy:FindFirstChild("HealthBar")
            and enemy.HealthBar:FindFirstChild("Main")
            and enemy.HealthBar.Main:FindFirstChild("Title")

        if title and title:IsA("TextLabel") and title.Text == name then
            local head = enemy:FindFirstChild("Head")
            if head then
                local dist = (head.Position - humanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = enemy
                end
            end
        end
    end
    return closest
end

-- Theo dõi enemy
RunService.Heartbeat:Connect(function()
    if not currentEnemy or not currentEnemy:FindFirstChild("Head") or not currentEnemy:FindFirstChild("HealthBar") then
        currentEnemy = getNearestEnemyByName(selectedEnemyName)
    end

    if currentEnemy then
        local head = currentEnemy:FindFirstChild("Head")
        local amount = currentEnemy.HealthBar.Main.Bar:FindFirstChild("Amount")

        if head and amount and amount:IsA("TextLabel") then
            local hp = tonumber(amount.Text) or 0
            print("🧠 HP:", hp)

            if hp <= 0 then
                currentEnemy = getNearestEnemyByName(selectedEnemyName)
                return
            end

            -- Tween nhân vật tới head
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
            local goal = {CFrame = head.CFrame * CFrame.new(0, 2, 0)}
            TweenService:Create(humanoidRootPart, tweenInfo, goal):Play()
        end
    end
end)
