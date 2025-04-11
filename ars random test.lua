local pet = game:GetService("Players").LocalPlayer.leaderstats.Inventory.Pets:FindFirstChild("Aki02caf6e")

if pet then
    print("🧸 Chi tiết pet:", pet.Name)
    for _, attr in ipairs(pet:GetChildren()) do
        if attr:IsA("StringValue") then
            print("   🔠 String -", attr.Name, "=", attr.Value)
        elseif attr:IsA("NumberValue") then
            print("   🔢 Number -", attr.Name, "=", attr.Value)
        elseif attr:IsA("BoolValue") then
            print("   🔘 Bool -", attr.Name, "=", tostring(attr.Value))
        elseif attr:IsA("Folder") then
            print("   📂 Folder -", attr.Name)
            for _, sub in ipairs(attr:GetChildren()) do
                print("      ↳", sub.Name, "=", sub.Value)
            end
        else
            print("   📎 Khác -", attr.Name, "-", attr.ClassName)
        end
    end
else
    warn("❌ Không tìm thấy pet tên Aki02caf6e")
end

