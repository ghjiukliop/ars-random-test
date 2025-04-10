-- Lấy LocalPlayer
local player = game.Players.LocalPlayer

-- Tìm kiếm SpikeMace239923f trong Inventory
local spikeMace = player.leaderstats.Inventory.Weapons:FindFirstChild("SpikeMace239923f")

-- Kiểm tra xem vũ khí có tồn tại không
if spikeMace then
    -- Log cấp độ hiện tại của vũ khí
    local currentLevel = spikeMace:FindFirstChild("Level") -- Giả sử rằng SpikeMace239923f có thuộc tính Level
    if currentLevel then
        print("Cấp độ hiện tại của SpikeMace239923f là: " .. tostring(currentLevel.Value))
    else
        print("SpikeMace239923f không có thuộc tính Level.")
    end
else
    print("Không tìm thấy SpikeMace239923f trong Inventory.")
end
