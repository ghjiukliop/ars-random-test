-- Lấy đối tượng Weapon
local weapon = workspace.__Main.__Players.ALS_Clone15:FindFirstChild("Weapon")

-- Kiểm tra xem Weapon có tồn tại không
if weapon then
    -- Hàm để log tất cả các thuộc tính của đối tượng
    local function logProperties(obj)
        print("Logging properties for: " .. obj.Name)
        for _, property in pairs(obj:GetAttributes()) do
            print("Attribute: " .. tostring(property))
        end
        
        for _, child in pairs(obj:GetChildren()) do
            print("Child: " .. child.Name)
            logProperties(child) -- Gọi đệ quy để log các thuộc tính của con
        end
        
        -- Log các thuộc tính của đối tượng
        for _, prop in pairs(getgc()) do
            if typeof(prop) == "Instance" and prop == obj then
                for i, v in pairs(prop:GetAttributes()) do
                    print("Hidden Property: " .. i .. " = " .. tostring(v))
                end
            end
        end
    end

    -- Gọi hàm logProperties để log thông tin
    logProperties(weapon)
else
    print("Không tìm thấy Weapon trong ALS_Clone15.")
end
