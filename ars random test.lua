-- Weapon Upgrade UI and Logic Script (No Level Required)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local weaponFolder = player:WaitForChild("leaderstats"):WaitForChild("Inventory"):WaitForChild("Weapons")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent

-- Danh sách weapon theo tên console
local weaponTypes = {
    SpikeMace = "Spike Maul",
    DualKando = "Twin Kando Blade",
    DualSteelNaginata = "Twin Iron Naginata",
    CrystalScepter = "Prim Scepter",
    GemStaff = "Jeweled Rod",
    DualBoneMace = "Twin Bone Crushers"
}

local selectedWeapon = nil
local upgrading = false

-- GUI tạo dropdown và nút bật
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- Dropdown chọn weapon
local dropdown = Instance.new("TextButton", gui)
dropdown.Size = UDim2.new(0, 180, 0, 30)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn weapon"
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.SourceSansBold
dropdown.TextSize = 16

-- Toggle auto-upgrade
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 180, 0, 30)
toggle.Position = UDim2.new(0, 20, 0, 70)
toggle.Text = "🔁 Auto Upgrade OFF"
toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 16

toggle.MouseButton1Click:Connect(function()
    upgrading = not upgrading
    toggle.Text = upgrading and "🔁 Auto Upgrade ON" or "🔁 Auto Upgrade OFF"
    toggle.BackgroundColor3 = upgrading and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Dropdown menu logic
local menu = nil

dropdown.MouseButton1Click:Connect(function()
    if menu and menu.Parent then
        menu:Destroy()
        menu = nil
        return
    end

    local count = 0 for _ in pairs(weaponTypes) do count = count + 1 end

    menu = Instance.new("Frame", gui)
    menu.Size = UDim2.new(0, 180, 0, count * 30)
    menu.Position = UDim2.new(0, 20, 0, 140)
    menu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    local i = 0
    for weaponCode, displayName in pairs(weaponTypes) do
        i = i + 1
        local btn = Instance.new("TextButton", menu)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        btn.Text = displayName
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.MouseButton1Click:Connect(function()
            selectedWeapon = weaponCode
            dropdown.Text = displayName
            if menu then
                menu:Destroy()
                menu = nil
            end
        end)
    end
end)

-- Hàm gửi yêu cầu nâng cấp (không cần Level)
local function tryUpgrade(typeName, ids)
    local args = {
        [1] = {
            [1] = {
                ["Type"] = typeName,
                ["BuyType"] = "Gems",
                ["Weapons"] = ids,
                ["Event"] = "UpgradeWeapon"
            },
            [2] = "\n"
        }
    }
    remote:FireServer(unpack(args))
end

-- Lấy danh sách vũ khí theo tên
local function getWeaponIdsByType(typename)
    local found = {}
    for _, item in ipairs(weaponFolder:GetChildren()) do
        if typeof(item) == "Instance" and item:IsA("Folder") and item.Name:match("^" .. typename) then
            table.insert(found, item.Name)
        end
    end
    return found
end

-- Vòng lặp nâng cấp liên tục mỗi khi đủ 3 vũ khí cùng tên
RunService.Heartbeat:Connect(function()
    if not upgrading or not selectedWeapon then return end

    local weaponIds = getWeaponIdsByType(selectedWeapon)
    while #weaponIds >= 3 do
        local using = {weaponIds[1], weaponIds[2], weaponIds[3]}
        tryUpgrade(selectedWeapon, using)
        wait(0.3)
        weaponIds = getWeaponIdsByType(selectedWeapon)
    end
end)
