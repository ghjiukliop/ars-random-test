local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local weaponFolder = player.leaderstats.Inventory.Weapons

local selectedType = "SpikeMace" -- Loại vũ khí
local upgradeLevel = 2            -- Mức cấp độ muốn nâng (có thể thay đổi)

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

-- Gửi yêu cầu nâng cấp
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
    print("🔥 Đã nâng 3 cây " .. selectedType .. " lên cấp " .. upgradeLevel)
end

-- Thực hiện nâng cấp từng nhóm 3 cây một
task.spawn(function()
    local list = getWeaponList()
    while #list >= 3 do
        local group = {list[1], list[2], list[3]}
        upgrade(group)
        task.wait(0.3)

        -- Xoá 3 cây đã dùng để tránh dùng lại
        table.remove(list, 1)
        table.remove(list, 1)
        table.remove(list, 1)
    end
    print("✅ Đã nâng cấp xong tất cả nhóm 3 cây có thể.")
end)
