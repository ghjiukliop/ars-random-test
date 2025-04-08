local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Xử lý respawn
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
end)

-- Tạo GUI an toàn
local gui = Instance.new("ScreenGui")
gui.Name = "EnemyTeleporterUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local selectedEnemyName = nil
local lastEnemy = nil
local enemyNames = {"Gonshee", "longIn", "Largalgan", "daek", "anders", "Soondoo"}
local currentTween = nil

-- Hủy tween hiện tại
local function cancelTween()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

-- Dropdown
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 150, 0, 40)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn enemy"
dropdown.Parent = gui

local currentMenu = nil

local function destroyMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
end

dropdown.MouseButton1Click:Connect(function()
    destroyMenu()
    local menu = Instance.new("Frame", gui)
    menu.Size = UDim2.new(0, 150, 0, #enemyNames * 30)
    menu.Position = UDim2.new(0, 20, 0, 140)
    menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    currentMenu = menu

    for i, name in ipairs(enemyNames) do
        local btn = Instance.new("TextButton", menu)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        btn.Text = name
        btn.MouseButton1Click:Connect(function()
            selectedEnemyName = name
            dropdown.Text = name
            destroyMenu()
            lastEnemy = nil -- reset để chọn lại enemy gần nhất còn sống
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
    lastEnemy = nil
    cancelTween()
end)

local function getClientEnemies()
    local main = workspace:FindFirstChild("__Main")
    if not main then return nil end
    
    local enemies = main:FindFirstChild("__Enemies")
    if not enemies then return nil end
    
    return enemies:FindFirstChild("Client")
end

local function getEnemyHealth(enemy)
    if not enemy then return 0 end
    
    local healthBar = enemy:FindFirstChild("HealthBar")
    if not healthBar then return 0 end
    
    local main = healthBar:FindFirstChild("Main")
    if not main then return 0 end
    
    local bar = main:FindFirstChild("Bar")
    if not bar then return 0 end
    
    local amount = bar:FindFirstChild("Amount")
    if not amount or not amount:IsA("TextLabel") then return 0 end
    
    return tonumber(amount.Text) or 0
end

local function getBestAliveEnemy(name)
    local enemies = getClientEnemies()
    if not enemies then return nil end

    local bestEnemy, minDist = nil, math.huge

    for _, enemy in pairs(enemies:GetChildren()) do
        local head = enemy:FindFirstChild("Head")
        local title = enemy:FindFirstChild("HealthBar")
            and enemy.HealthBar:FindFirstChild("Main")
            and enemy.HealthBar.Main:FindFirstChild("Title")

        if title and title:IsA("TextLabel") and title.Text == name and head then
            local hp = getEnemyHealth(enemy)
            if hp > 0 then
                local dist = (head.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    bestEnemy = enemy
                end
            end
        end
    end
    return bestEnemy
end

-- Giảm tần suất kiểm tra
local lastCheck = 0
RunService.Heartbeat:Connect(function(step)
    if not selectedEnemyName or not root then return end
    
    -- Kiểm tra mỗi 0.2 giây thay vì mỗi frame
    if time() - lastCheck < 0.2 then return end
    lastCheck = time()

    -- Nếu enemy hiện tại chết hoặc không hợp lệ -> tìm mới
    if lastEnemy then
        local hp = getEnemyHealth(lastEnemy)
        if not lastEnemy:FindFirstChild("Head") or hp <= 0 then
            lastEnemy = nil
            cancelTween()
        end
    end

    -- Tìm kẻ địch mới nếu cần
    if not lastEnemy then
        lastEnemy = getBestAliveEnemy(selectedEnemyName)
        if lastEnemy then
            print("🎯 Đã chọn enemy mới:", selectedEnemyName)
        end
    end

    -- Dịch chuyển đến đầu enemy
    if lastEnemy and lastEnemy:FindFirstChild("Head") then
        cancelTween()
        currentTween = TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
            CFrame = lastEnemy.Head.CFrame * CFrame.new(0, 2, 0)
        })
        currentTween:Play()
    end
end)

-- Cleanup khi script kết thúc
gui.Destroying:Connect(function()
    cancelTween()
end)
