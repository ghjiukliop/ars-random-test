local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local weaponFolder = player.leaderstats.Inventory.Weapons

local selectedType = "SpikeMace"
local upgradeLevel = 2
local upgrading = false
local blacklist = {}

-- Giao diện nút bật/tắt
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UpgradeToggleGui"

local toggleBtn = Instance.new("TextButton", gui)
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

-- Blacklist logic
local function isBlacklisted(name)
    for _, v in ipairs(blacklist) do
        if v == name then return true end
    end
    return false
end

-- Lấy danh sách vũ khí chưa bị blacklist
local function getWeaponList()
    local list = {}
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if item:IsA("Folder") and item.Name:match("^" .. selectedType) and not isBlacklisted(item.Name) then
            table.insert(list, item.Name)
        end
    end
    return list
end

-- Đếm tổng vũ khí hiện có
local function countWeapons()
    local count = 0
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if item:IsA("Folder") and item.Name:match("^" .. selectedType) then
            count += 1
        end
    end
    return count
end

-- Gửi nâng cấp và kiểm tra kết quả
local function safeUpgrade(weapons)
    local pre = countWeapons()

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
    print("📤 Gửi nâng: " .. table.concat(weapons, ", "))
    task.wait(0.5)

    local post = countWeapons()
    if post < pre then
        print("✅ Thành công! Xoá toàn bộ blacklist.")
        blacklist = {}
        return true
    else
        for _, w in ipairs(weapons) do
            table.insert(blacklist, w)
        end
        print("❌ Thất bại. Blacklist nhóm: " .. table.concat(weapons, ", "))
        return false
    end
end

-- Luồng tự động nâng cấp nếu ON
task.spawn(function()
    while true do
        if upgrading then
            local list = getWeaponList()
            if #list >= 3 then
                local group = {list[1], list[2], list[3]}
                safeUpgrade(group)
                task.wait(0.3)
            else
                print("⏸️ Không còn đủ vũ khí chưa bị blacklist.")
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end
end)
