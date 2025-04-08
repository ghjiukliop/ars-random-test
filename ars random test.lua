--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local enemyNames = {
    "Gonshee", "longIn", "Largalgan", "daek", "anders", "Soondoo"
}

local selectedEnemyName = enemyNames[1]
local attachedEnemy = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "EnemyTrackerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 200, 0, 50)
dropdown.Position = UDim2.new(0, 50, 0, 50)
dropdown.Text = selectedEnemyName
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.SourceSansBold
dropdown.TextScaled = true
dropdown.Parent = gui

local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(0, 200, 0, #enemyNames * 30)
dropdownList.Position = UDim2.new(0, 50, 0, 100)
dropdownList.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
dropdownList.Visible = false
dropdownList.Parent = gui

for i, name in ipairs(enemyNames) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextScaled = true
    button.Parent = dropdownList

    button.MouseButton1Click:Connect(function()
        selectedEnemyName = name
        dropdown.Text = name
        dropdownList.Visible = false
        attachedEnemy = nil -- Reset target
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)

-- Manual Teleport Button
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 200, 0, 40)
te...
