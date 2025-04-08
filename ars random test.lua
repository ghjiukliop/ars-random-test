-- 👾 Danh sách kẻ địch cần theo dõi
local enemyNames = {
    "Gonshee",
    "longIn",
    "Largalgan",
    "daek",
    "anders",
    "Soondoo"
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "EnemyTrackerGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Dropdown menu
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 200, 0, 50)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn enemy"
dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Parent = gui

dropdown.MouseButton1Click:Connect(function()
    for _, child in pairs(gui:GetChildren()) do
        if child:IsA("TextButton") and child.Name == "Option" then
            child:Destroy()
        end
    end

    for i, name in ipairs(enemyNames) do
        local option = Instance.new("TextButton")
        option.Name = "Option"
        option.Size = UDim2.new(0, 200, 0, 30)
        option.Position = UDim2.new(0, 20, 0, 100 + i * 35)
        option.Text = name
        option.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        option.TextColor3 = Color3.new(1, 1, 1)
        option.Parent = gui

        option.MouseButton1Click:Connect(function()
            dropdown.Text = name
        end)
    end
end)

-- Toggle button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0, 20, 0, 320)
toggle.Text = "Tự động dịch chuyển: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Parent = gui

local autoTeleport = false
local lastTarget = nil

toggle.MouseButton1Click:Connect(function()
    autoTeleport = not autoTeleport
    toggle.Text = "Tự động dịch chuyển: " .. (autoTeleport and "ON" or "OFF")
    toggle.BackgroundColor3 = autoTeleport and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
end)

-- Hàm tìm enemy gần nhất theo tên
local function getNearestEnemyByName(name)
    local enemiesFolder = workspace:FindFirstChild("__Main")
    if not enemiesFolder then return nil end
    enemiesFolder = enemiesFolder:FindFirstChild("__Enemies")
    if not enemiesFolder then return nil end
    local clientFolder = enemiesFolder:FindFirstChild("Client")
    if not clientFolder then return nil end

    local closest, minDist = nil, math.huge
    for _, enemy in pairs(clientFolder:GetChildren()) do
        local title = enemy:FindFirstChild("HealthBar")
            and enemy.HealthBar:FindFirstChild("Main")
            and enemy.HealthBar.Main:FindFirstChild("Title")

        if title and title:IsA("TextLabel") and title.Text:lower() == name:lower() then
            local root = enemy:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = root
                end
            end
        end
    end
    return closest
end

-- Tự động tween đến enemy gần nhất
RunService.RenderStepped:Connect(function()
    if autoTeleport and dropdown.Text ~= "Chọn enemy" then
        if lastTarget and lastTarget.Parent == nil then
            lastTarget = nil -- Enemy cũ đã biến mất
        end

        if not lastTarget then
            local target = getNearestEnemyByName(dropdown.Text)
            if target then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tween = TweenService:Create(
                        hrp,
                        TweenInfo.new(1, Enum.EasingStyle.Linear),
                        {CFrame = target.CFrame + Vector3.new(0, 5, 0)}
                    )
                    tween:Play()
                    lastTarget = target
                end
            end
        end
    end
end)