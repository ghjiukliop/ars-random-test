local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local weaponFolder = player.leaderstats.Inventory.Weapons

local selectedType = "SpikeMace"
local upgradeLevel = 2
local upgrading = false
local blacklist = {}

-- Tạo GUI bật/tắt nâng cấp
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

-- Blacklist check
local function isBlacklisted(name)
    for _, v in ipairs(blacklist) do
        if v == name then return true end
    end
    return false
end

-- Lấy danh sách SpikeMace và sắp xếp theo mã HEX thời gian
local function getWeaponListByTime(includeBlacklist)
    local raw = {}
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if item:IsA("Folder") and item.Name:match("^SpikeMace") then
            if includeBlacklist or not isBlacklisted(item.Name) then
                local hex = item.Name:match("^SpikeMace(%x+)")
                local ts = tonumber(hex, 16) or 0
                table.insert(raw, {Name = item.Name, Time = ts})
            end
        end
    end
    table.sort(raw, function(a, b) return a.Time < b.Time end)
    local sorted = {}
    for _, entry in ipairs(raw) do
        table.insert(sorted, entry.Name)
    end
    return sorted
end

-- Đếm số lượng weapon hiện tại
local function countWeapons()
    local count = 0
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if item:IsA("Folder") and item.Name:match("^SpikeMace") then
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
                ["Type"] = "SpikeMace",
                ["BuyType"] = "Gems",
                ["Weapons"] = weapons,
                ["Event"] = "UpgradeWeapon",
                ["Level"] = upgradeLevel
            },
            [2] = "\\n"
        }
    }
    remote:FireServer(unpack(args))
    print("📤 Gửi nâng cấp:", table.concat(weapons, ", "))
    task.wait(0.5)
    local post = countWeapons()
    return post < pre
end

-- Vòng lặp nâng cấp
task.spawn(function()
    while true do
        if upgrading then
            local list = getWeaponListByTime(false)
            if #list >= 3 then
                local group = {list[1], list[2], list[3]}
                if not safeUpgrade(group) then
                    for _, w in ipairs(group) do
                        table.insert(blacklist, w)
                    end
                    print("❌ Thất bại. Đã thêm vào blacklist:", table.concat(group, ", "))
                else
                    blacklist = {}
                    print("✅ Thành công. Xoá toàn bộ blacklist.")
                end
            else
                print("⚠️ Không đủ weapon chưa blacklist. Thử với blacklist...")
                local retry = getWeaponListByTime(true)
                if #retry >= 3 then
                    local group = {retry[1], retry[2], retry[3]}
                    if safeUpgrade(group) then
                        print("✅ Thành công từ blacklist. Reset blacklist.")
                        blacklist = {}
                    else
                        print("❌ Lại thất bại. Gỡ nhóm này khỏi blacklist.")
                        for _, w in ipairs(group) do
                            for i = #blacklist, 1, -1 do
                                if blacklist[i] == w then
                                    table.remove(blacklist, i)
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                else
                    print("⏸️ Hết weapon để thử. Đợi 1 giây rồi kiểm tra lại.")
                    task.wait(1)
                end
            end
        else
            task.wait(1)
        end
    end
end)
