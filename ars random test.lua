-- Đảm bảo rằng bạn đã có quyền truy cập vào các dịch vụ cần thiết
local player = game.Players.LocalPlayer

-- Tìm kiếm SpikeMace6e39aa4 trong Inventory
local spikeMace = player.leaderstats.Inventory.Weapons:FindFirstChild("SpikeMace6e39aa4")

if spikeMace then
    -- Giả sử rằng SpikeMace6e39aa4 có thuộc tính Level
    local level = spikeMace:FindFirstChild("Level") -- Kiểm tra xem có thuộc tính Level không
    if level then
        print("Level của SpikeMace6e39aa4 là: " .. tostring(level.Value)) -- In ra giá trị Level
    else
        print("SpikeMace6e39aa4 không có thuộc tính Level.")
    end
else
    print("Không tìm thấy SpikeMace6e39aa4 trong Inventory.")
end
