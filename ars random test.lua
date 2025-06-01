--// Dịch vụ
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

--// Danh sách tên cây cố định
local allPlantNames = {
    "Apple", "Avocado", "Banana", "Beanstalk", "Blood Banana", "Blueberry", "Cacao", "Cactus", "Candy Blossom",
    "Celestiberry", "Cherry Blossom", "Cherry OLD", "Coconut", "Corn", "Cranberry", "Crimson Vine", "Cursed Fruit",
    "Dragon Fruit", "Durian", "Easter Egg", "Eggplant", "Ember Lily", "Foxglove", "Glowshroom", "Grape", "Hive Fruit",
    "Lemon", "Lilac", "Lotus", "Mango", "Mint", "Moon Blossom", "Moon Mango", "Moon Melon", "Moonflower", "Moonglow",
    "Nectarine", "Papaya", "Passionfruit", "Peach", "Pear", "Pepper", "Pineapple", "Pink Lily", "Purple Cabbage",
    "Purple Dahlia", "Raspberry", "Rose", "Soul Fruit", "Starfruit", "Strawberry", "Succulent", "Sunflower",
    "Tomato", "Venus Fly Trap"
}

local selectedPlantNames = {}
local collecting = false
local playerFarm

--// Tìm farm của người chơi
local farms = workspace:FindFirstChild("Farm")
if farms then
	for _, farm in ipairs(farms:GetChildren()) do
		local owner = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data") and farm.Important.Data:FindFirstChild("Owner")
		if owner and owner.Value == player.Name then
			playerFarm = farm
			break
		end
	end
end

if not playerFarm then
	warn("❌ Không tìm thấy farm của người chơi.")
	return
end

local plantObjects = playerFarm.Important:FindFirstChild("Plants_Physical")
if not plantObjects then
	warn("❌ Không tìm thấy Plants_Physical.")
	return
end

--// Giao diện
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FruitCollectorGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌿 Auto Fruit Collector"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Gotham
title.TextSize = 16
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0

-- Label hiển thị cây đã chọn
local selectedLabel = Instance.new("TextLabel", frame)
selectedLabel.Size = UDim2.new(1, -20, 0, 40)
selectedLabel.Position = UDim2.new(0, 10, 0, 35)
selectedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
selectedLabel.TextColor3 = Color3.new(1, 1, 1)
selectedLabel.Font = Enum.Font.Gotham
selectedLabel.TextSize = 14
selectedLabel.TextWrapped = true
selectedLabel.Text = "🌱 Cây đã chọn: (Chưa có)"
selectedLabel.BorderSizePixel = 0

-- Hàm cập nhật label
local function updateSelectedLabel()
	if #selectedPlantNames == 0 then
		selectedLabel.Text = "🌱 Cây đã chọn: (Chưa có)"
	else
		selectedLabel.Text = "🌱 Cây đã chọn:\n" .. table.concat(selectedPlantNames, ", ")
	end
end

-- Danh sách cây để chọn
local dropdownList = Instance.new("ScrollingFrame", frame)
dropdownList.Position = UDim2.new(0, 10, 0, 80)
dropdownList.Size = UDim2.new(1, -20, 0, 150)
dropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
dropdownList.BorderSizePixel = 0
dropdownList.ScrollBarThickness = 6
dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.Visible = true

local layout = Instance.new("UIListLayout", dropdownList)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 2)

-- Tạo các nút chọn cây
for _, name in ipairs(allPlantNames) do
	local btn = Instance.new("TextButton", dropdownList)
	btn.Size = UDim2.new(1, 0, 0, 25)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13

	btn.MouseButton1Click:Connect(function()
		local index = table.find(selectedPlantNames, name)
		if index then
			table.remove(selectedPlantNames, index)
			btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		else
			table.insert(selectedPlantNames, name)
			btn.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
		end
		updateSelectedLabel()
	end)
end

-- Nút bật auto
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, -20, 0, 30)
autoBtn.Position = UDim2.new(0, 10, 1, -40)
autoBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 90)
autoBtn.Text = "▶️ Bắt đầu Auto"
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 14

-- Hàm thu thập
local function collectFruit(fruit)
	if not fruit:IsA("Model") then return end
	local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then fireproximityprompt(prompt) return end
	local click = fruit:FindFirstChildWhichIsA("ClickDetector", true)
	if click then fireclickdetector(click) return end
end

-- Tự động thu thập trái cây (liên tục, không delay giữa cây)
task.spawn(function()
	while true do
		if collecting and #selectedPlantNames > 0 then
			for _, plant in ipairs(plantObjects:GetChildren()) do
				if table.find(selectedPlantNames, plant.Name) then
					local fruits = plant:FindFirstChild("Fruits")
					if fruits then
						for _, fruit in ipairs(fruits:GetChildren()) do
							collectFruit(fruit)
							task.wait(0.05)
						end
					end
				end
			end
		end
		task.wait(0.1)
	end
end)

-- Bật / tắt auto
autoBtn.MouseButton1Click:Connect(function()
	collecting = not collecting
	autoBtn.Text = collecting and "⏸️ Dừng Auto" or "▶️ Bắt đầu Auto"
	autoBtn.BackgroundColor3 = collecting and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(80, 130, 90)
end)
