-- Auto Upgrade UI + Khởi tạo biến

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local weaponFolder = player:WaitForChild("leaderstats"):WaitForChild("Inventory"):WaitForChild("Weapons")

-- Danh sách weapon theo tên code
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

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoUpgradeGUI"
gui.ResetOnSpawn = false

-- Dropdown chọn weapon
local dropdown = Instance.new("TextButton", gui)
dropdown.Size = UDim2.new(0, 180, 0, 30)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn weapon"
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.SourceSansBold
dropdown.TextSize = 16

-- Toggle Auto Upgrade
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


local Players = game:GetService("Players")
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- Kiểm tra xem Backpack có tồn tại không
if backpack then
    print("Thông tin của Backpack:")
    
    -- Duyệt qua tất cả các đối tượng trong Backpack
    for _, item in ipairs(backpack:GetChildren()) do
        print("Tên: " .. item.Name)
        print("Loại: " .. item.ClassName)
        
        -- Nếu có thuộc tính nào bạn muốn log, bạn có thể thêm vào đây
        if item:IsA("Tool") then
            print("Mô tả: " .. (item:FindFirstChild("Description") and item.Description.Value or "Không có mô tả"))
        end
        
        print("----------")  -- Dòng phân cách giữa các đối tượng
    end
else
    print("Backpack không tồn tại.")
end
