-- Dịch chuyển đến kẻ địch được chọn gần nhất, bám vào đầu và quét máu
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
    lastEnemy = nil -- reset để trigger lại dịch chuyển
end)

-- Tìm kẻ địch gần nhất theo tên
local function getNearestEnemyByName(name)
    local clientEnemies = workspace:FindFirstChild("__Main")
        and workspace.__Main:FindFirstChild("__Enemies")
        and workspace.__Main.__Enemies:FindFirstChild("Client")

    if not clientEnemies then return nil end

    local closest, minDist = nil, math.huge
    for _, enemy in pairs(clientEnemies:GetChildren()) do
        local head = enemy:FindFirstChild("Head")
        if enemy.Name and enemy:FindFirstChild("HealthBar")
            and enemy.HealthBar:FindFirstChild("Main")
            and enemy.HealthBar.Main:FindFirstChild("Title") then

            local title = enemy.HealthBar.Main.Title
            if title:IsA("TextLabel") and title.Text == name then
                if head then
                    local dist = (head.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = enemy
                    end
                end
            end
        end
    end
    return closest
end

-- Theo dõi và dịch chuyển nếu máu = 0
RunService.RenderStepped:Connect(function()
    if not selectedEnemyName then return end

    if lastEnemy and lastEnemy:FindFirstChild("HealthBar") and lastEnemy.HealthBar:FindFirstChild("Main")
        and lastEnemy.HealthBar.Main:FindFirstChild("Bar") then

        local bar = lastEnemy.HealthBar.Main.Bar:FindFirstChild("Amount")
        if bar and bar:IsA("TextLabel") then
            if tonumber(bar.Text) == 0 then
                lastEnemy = nil -- chết, tìm enemy mới
            end
        end
    end

    if not lastEnemy or not lastEnemy:FindFirstChild("Head") then
        lastEnemy = getNearestEnemyByName(selectedEnemyName)
        if lastEnemy then
            print("🔍 Đã chọn enemy:", selectedEnemyName)
        end
    end

    if lastEnemy and lastEnemy:FindFirstChild("Head") then
        local tween = TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
            CFrame = lastEnemy.Head.CFrame * CFrame.new(0, 2, 0)
        })
        tween:Play()
    end
end)
