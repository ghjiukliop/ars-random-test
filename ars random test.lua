local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local weaponFolder = player.leaderstats.Inventory.Weapons

local selectedType = "SpikeMace" -- đổi tên này nếu muốn nâng vũ khí khác

-- Hàm lấy mọi vũ khí có tên bắt đầu bằng "SpikeMace"
local function getWeaponList()
    local list = {}
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if item:IsA("Folder") and item.Name:match("^" .. selectedType) then
            table.insert(list, item.Name)
        end
    end
    return list
end

-- Gửi yêu cầu upgrade
local function upgrade(weapons, level)
    local args = {
        [1] = {
            [1] = {
                ["Type"] = selectedType,
                ["BuyType"] = "Gems",
                ["Weapons"] = weapons,
                ["Event"] = "UpgradeWeapon",
                ["Level"] = level
            },
            [2] = "\n"
        }
    }
    remote:FireServer(unpack(args))
    print("🔥 Upgrade " .. selectedType .. " to level " .. level .. " with: ", weapons[1], weapons[2], weapons[3])
end

-- Main loop: từ level 2 đến 10, mỗi cấp upgrade 15 lần nếu đủ
task.spawn(function()
    for level = 2, 9 do
        for i = 1, 15 do
            local all = getWeaponList()
            if #all >= 3 then
                local chosen = {all[1], all[2], all[3]}
                upgrade(chosen, level)
                task.wait(0.3)
            else
                print("❗ Không đủ vũ khí để nâng cấp ở level " .. level)
                break
            end
        end
    end
end)
