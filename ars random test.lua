-- Lấy đối tượng WyvernSlayer từ ReplicatedStorage
local weapon = game:GetService("ReplicatedStorage").__Assets.__Weapons:FindFirstChild("WyvernSlayer")

-- Kiểm tra xem đối tượng có tồn tại không
if weapon then
    print("Đối tượng WyvernSlayer đã được tìm thấy!")
    
    -- Log tên của đối tượng
    print("Tên: " .. weapon.Name)
    
    -- Log các thuộc tính của đối tượng
    for property, value in pairs(weapon:GetAttributes()) do
        print("Thuộc tính: " .. property .. " = " .. tostring(value))
    end
    
    -- Log các thuộc tính khác của đối tượng
    for _, child in pairs(weapon:GetChildren()) do
        print("Child: " .. child.Name)
    end
    
    -- Log các thuộc tính ẩn (nếu có)
    for _, prop in pairs(getgc()) do
        if typeof(prop) == "Instance" and prop == weapon then
            for i, v in pairs(prop:GetAttributes()) do
                print("Hidden Property: " .. i .. " = " .. tostring(v))
            end
        end
    end
else
    print("Không tìm thấy đối tượng WyvernSlayer trong ReplicatedStorage.")
end
