--// Dịch vụ
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local farms = workspace:FindFirstChild("Farm")

--// Biến
local playerFarm = nil
local collecting = false
local selectedPlantName = nil

--// Danh sách tên cây có thể chọn
local allPlantNames = {
	"Apple", "Avocado", "Banana", "Beanstalk", "Blood Banana", "Blueberry", "Cacao", "Cactus", "Candy Blossom",
	"Celestiberry", "Cherry Blossom", "Cherry OLD", "Coconut", "Corn", "Cranberry", "Crimson Vine", "Cursed Fruit",
	"Dragon Fruit", "Durian", "Easter Egg", "Eggplant", "Ember Lily", "Foxglove", "Glowshroom", "Grape", "Hive Fruit",
	"Lemon", "Lilac", "Lotus", "Mango", "Mint", "Moon Blossom", "Moon Mango", "Moon Melon", "Moonflower",
	"Moonglow", "Nectarine", "Papaya", "Passionfruit", "Peach", "Pear", "Pepper", "Pineapple", "Pink Lily",
	"Purple Cabbage", "Purple Dahlia", "Raspberry", "Rose", "Soul Fruit", "Starfruit", "Strawberry", "Succulent",
	"Sunflower", "Tomato", "Venus Fly Trap"
}

--// Tìm farm của người chơi
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

local plantsFolder = playerFarm.Important:FindFirstChild("Plants_Physical")
if not plantsFolder then
	warn("❌ Không tìm thấy Plants_Physical.")
	return
end

--// Giao diện
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FruitCollectorGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 220)
frame.Position = UDim2.new(0, 20, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.05
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "🌿 Auto Fruit Collector"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Gotham
title.TextSize = 16
title.BorderSizePixel = 0

local dropdown = Instance.new("TextButton", frame)
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 40)
dropdown.Text = "🔽 Chọn loại cây"
dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 14

local dropdownList = Instance.new("ScrollingFrame", frame)
dropdownList.Size = UDim2.new(1, -20, 0, 120)
dropdownList.Position = UDim2.new(0, 10, 0, 75)
dropdownList.Visible = false
dropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
dropdownList.BorderSizePixel = 0
dropdownList.ScrollBarThickness = 6
dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", dropdownList)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 2)

for _, name in ipairs(allPlantNames) do
	local btn = Instance.new("TextButton", dropdownList)
	btn.Size = UDim2.new(1, 0, 0, 25)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13

	btn.MouseButton1Click:Connect(function()
		selectedPlantName = name
		dropdown.Text = "🌳 " .. selectedPlantName
		dropdownList.Visible = false
	end)
end

dropdown.MouseButton1Click:Connect(function()
	dropdownList.Visible = not dropdownList.Visible
end)

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, -20, 0, 30)
autoBtn.Position = UDim2.new(0, 10, 1, -40)
autoBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 90)
autoBtn.Text = "▶️ Bắt đầu Auto"
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 14

autoBtn.MouseButton1Click:Connect(function()
	collecting = not collecting
	autoBtn.Text = collecting and "⏸️ Dừng Auto" or "▶️ Bắt đầu Auto"
	autoBtn.BackgroundColor3 = collecting and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(80, 130, 90)
end)

--// Hàm thu thập
local function collectFruit(fruit)
	if not fruit:IsA("Model") then return end
	local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then fireproximityprompt(prompt) return end
	local click = fruit:FindFirstChildWhichIsA("ClickDetector", true)
	if click then fireclickdetector(click) return end
end

--// Vòng lặp thu thập liên tục
coroutine.wrap(function()
	while true do
		if collecting and selectedPlantName then
			local foundPlant = false
			for _, plant in ipairs(plantsFolder:GetChildren()) do
				if plant.Name == selectedPlantName then
					foundPlant = true
					local fruitFolder = plant:FindFirstChild("Fruits")
					if fruitFolder then
						for _, fruit in ipairs(fruitFolder:GetChildren()) do
							collectFruit(fruit)
							task.wait(0.05)
						end
					end
				end
			end
			if not foundPlant then
				print("⛔ Không có cây '" .. selectedPlantName .. "' trong farm của bạn.")
			end
		end
		task.wait(0.05)
end)()
