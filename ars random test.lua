-- Lấy LocalPlayer
local player = game.Players.LocalPlayer

-- Tìm kiếm SpikeMace6e39aa4 trong Inventory
local spikeMace = player.leaderstats.Inventory.Weapons:FindFirstChild("SpikeMace05036dd")

-- Kiểm tra xem vũ khí có tồn tại không
if spikeMace then
    -- Log cấp độ hiện tại của vũ khí
    local currentLevel = spikeMace:FindFirstChild("Level") -- Giả sử rằng SpikeMace6e39aa4 có thuộc tính Level
    if currentLevel then
        print("Cấp độ hiện tại của SpikeMace6e39aa4 là: " .. tostring(currentLevel.Value))
    else
        print("SpikeMace6e39aa4 không có thuộc tính Level.")
    end
else
    print("Không tìm thấy SpikeMace6e39aa4 trong Inventory.")
end
