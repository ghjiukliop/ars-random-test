local function getWeaponIDs(weaponType)
    local weaponIDs = {}
    
    local playerWeapons = game:GetService("Players").LocalPlayer.leaderstats.Inventory.Weapons:GetChildren()
    for _, weapon in ipairs(playerWeapons) do
        local weaponName = weapon:GetAttribute("Name")
        -- Kiểm tra xem vũ khí có phải là loại đang tìm kiếm không
        if weaponName == weaponType then
            table.insert(weaponIDs, weapon.Name) -- Thêm ID của vũ khí vào danh sách
            print("Đã tìm thấy ID vũ khí:", weapon.Name) -- GỠ LỖI
        end
    end
    
    return weaponIDs
end

-- Lấy danh sách tên vũ khí ban đầu
local weaponTypes = getUniqueWeaponNames()
local selectedWeaponType = weaponTypes[1] or "" -- Loại vũ khí mặc định
local autoUpdateEnabled = false -- Trạng thái Auto Update
local autoSelectedEnabled = false -- Trạng thái Auto Update cho vũ khí đã chọn

-- Cập nhật ConfigSystem
ConfigSystem.DefaultConfig.SelectedWeaponType = selectedWeaponType
ConfigSystem.DefaultConfig.AutoUpdateEnabled = autoUpdateEnabled
ConfigSystem.DefaultConfig.AutoSelectedEnabled = autoSelectedEnabled

-- Dropdown để chọn loại vũ khí muốn nâng cấp
Tabs.Update:AddDropdown("WeaponTypeDropdown", {
    Title = "Select Weapon Type",
    Values = weaponTypes,
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedWeaponType or selectedWeaponType,
    Callback = function(weaponType)
        selectedWeaponType = weaponType
        ConfigSystem.CurrentConfig.SelectedWeaponType = weaponType
        ConfigSystem.SaveConfig()
        print("Selected Weapon Type:", selectedWeaponType) -- GỠ LỖI
    end
})

-- Hàm để lấy tất cả vũ khí theo level
local function getWeaponsByLevel(weaponType)
    local weaponsByLevel = {}
    
    -- Khởi tạo mảng để lưu trữ vũ khí theo level
    for i = 1, 7 do
        weaponsByLevel[i] = {}
    end
    
    local playerWeapons = game:GetService("Players").LocalPlayer.leaderstats.Inventory.Weapons:GetChildren()
    for _, weapon in ipairs(playerWeapons) do
        local weaponName = weapon:GetAttribute("Name")
        local weaponLevel = weapon:GetAttribute("Level") or 1
        
        -- Nếu không chọn loại vũ khí cụ thể hoặc vũ khí thuộc loại đã chọn
        if (not weaponType or weaponType == "" or weaponName == weaponType) and weaponLevel >= 1 and weaponLevel <= 7 then
            table.insert(weaponsByLevel[weaponLevel], weapon.Name)
            print("Đã tìm thấy vũ khí:", weaponName, "Level:", weaponLevel, "ID:", weapon.Name)
        end
    end
    
    return weaponsByLevel
end

-- Hàm để nâng cấp vũ khí theo level
local function upgradeWeaponsByLevel(weaponType)
    local weaponsByLevel = getWeaponsByLevel(weaponType)
    local anyUpgraded = false
    
    -- Duyệt qua từng level, bắt đầu từ level thấp nhất
    for level = 1, 6 do
        local weapons = weaponsByLevel[level]
        
        -- Nếu có ít nhất 3 vũ khí cùng level, thực hiện nâng cấp
        while #weapons >= 3 do
            -- Lấy 3 vũ khí đầu tiên để nâng cấp
            local upgradeWeapons = {
                weapons[1],
                weapons[2],
                weapons[3]
            }
            
            -- Xóa 3 vũ khí này khỏi danh sách
            table.remove(weapons, 1)
            table.remove(weapons, 1)
            table.remove(weapons, 1)
            
            -- Thực hiện nâng cấp
            local weaponName = game:GetService("Players").LocalPlayer.leaderstats.Inventory.Weapons:FindFirstChild(upgradeWeapons[1]):GetAttribute("Name")
            
            local args = {
                [1] = {
                    [1] = {
                        ["Type"] = weaponName,
                        ["BuyType"] = "Gems",
                        ["Weapons"] = upgradeWeapons,
                        ["Event"] = "UpgradeWeapon",
                        ["Level"] = level + 1
                    },
                    [2] = "\n"
                }
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
            print("Đang nâng cấp", #upgradeWeapons, "vũ khí", weaponName, "từ level", level, "lên level", level + 1)
            
            Fluent:Notify({
                Title = "Đang nâng cấp",
                Content = "Đang nâng cấp " .. weaponName .. " từ level " .. level .. " lên level " .. (level + 1),
                Duration = 3
            })
            
            anyUpgraded = true
            task.wait(1) -- Đợi 1 giây để tránh spam server
        end
    end
    
    if not anyUpgraded then
        Fluent:Notify({
            Title = "Thông báo",
            Content = "Không có vũ khí nào đủ số lượng để nâng cấp",
            Duration = 3
        })
    end
    
    return anyUpgraded
end

-- Nút để làm mới danh sách vũ khí
Tabs.Update:AddButton({
    Title = "Refresh Weapon List",
    Description = "Refresh the list of available weapons",
    Callback = function()
        weaponTypes = getUniqueWeaponNames()
        local weaponTypeDropdown = Fluent.Options.WeaponTypeDropdown
        if weaponTypeDropdown then
            weaponTypeDropdown:SetValues(weaponTypes)
            if #weaponTypes > 0 and not table.find(weaponTypes, selectedWeaponType) then
                selectedWeaponType = weaponTypes[1]
                weaponTypeDropdown:SetValue(selectedWeaponType)
                ConfigSystem.CurrentConfig.SelectedWeaponType = selectedWeaponType
                ConfigSystem.SaveConfig()
            end
        end
        
        Fluent:Notify({
            Title = "Danh sách đã làm mới",
            Content = "Đã cập nhật danh sách vũ khí có sẵn",
            Duration = 3
        })
    end
})

-- Toggle để bật/tắt nâng cấp vũ khí đã chọn
Tabs.Update:AddToggle("AutoSelectToggle", {
    Title = "Upgrade Selected Weapon",
    Default = ConfigSystem.CurrentConfig.AutoSelectedEnabled or false,
    Callback = function(state)
        autoSelectedEnabled = state
        ConfigSystem.CurrentConfig.AutoSelectedEnabled = state
        ConfigSystem.SaveConfig()
        
        if state then
            if not selectedWeaponType or selectedWeaponType == "" then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Vui lòng chọn loại vũ khí trước khi nâng cấp",
                    Duration = 3
                })
                return
            end
            
            task.spawn(function()
                while autoSelectedEnabled do
                    local upgraded = upgradeWeaponsByLevel(selectedWeaponType)
                    if not upgraded then
                        task.wait(5) -- Đợi lâu hơn nếu không có vũ khí nào được nâng cấp
                    else
                        task.wait(1) -- Đợi ngắn hơn nếu có vũ khí được nâng cấp
                    end
                end
            end)
        end
    end
})
