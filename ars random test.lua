local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local weaponFolder = player.leaderstats.Inventory.Weapons

local selectedType = "SpikeMace"
local upgradeLevel = 2
local upgrading = false

-- Giao diện ON/OFF
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "AutoUpgradeToggle"

local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 180, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 100)
toggleBtn.Text = "🔁 Auto Upgrade OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16

toggleBtn.MouseButton1Click:Connect(function()
    upgrading = not upgrading
    toggleBtn.Text = upgrading and "🔁 Auto Upgrade ON" or "🔁 Auto Upgrade OFF"
    toggleBtn.BackgroundColor3 = upgrading and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Lấy tất cả SpikeMace hiện có trong kho
local function getWeaponList()
    local list = {}
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if item:IsA("Folder") and item.Name:match("^" .. selectedType) then
            table.insert(list, item.Name)
        end
    end
    return list
end

-- Gửi lệnh nâng cấp
local function upgrade(weapons)
    local args = {
        [1] = {
            [1] = {
                ["Type"] = selectedType,
                ["BuyType"] = "Gems",
                ["Weapons"] = weapons,
                ["Event"] = "UpgradeWeapon",
                ["Level"] = upgradeLevel
            },
            [2] = "\n"
        }
    }
    remote:FireServer(unpack(args))
    print("🔥 Nâng cấp: " .. table.concat(weapons, ", "))
end

-- Vòng lặp nâng từng nhóm 3 cây một nếu ON
task.spawn(function()
    while true do
        if upgrading then
            local list = getWeaponList()
            while #list >= 3 and upgrading do
                local group = {list[1], list[2], list[3]}
                upgrade(group)
                task.wait(0.3)
                table.remove(list, 1)
                table.remove(list, 1)
                table.remove(list, 1)
            end
        end
        task.wait(1)
    end
end)
