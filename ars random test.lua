--// Dịch vụ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local farms = workspace:FindFirstChild("Farm")

--// Biến
local playerFarm = nil
local plantObjects = {}
local allPlantNames = { -- Danh sách toàn bộ cây bạn cung cấp
	"Apple","Avocado","Banana","Beanstalk","Blood Banana","Blueberry","Cacao","Cactus","Candy Blossom",
	"Celestiberry","Cherry Blossom","Cherry OLD","Coconut","Corn","Cranberry","Crimson Vine","Cursed Fruit",
	"Dragon Fruit","Durian","Easter Egg","Eggplant","Ember Lily","Foxglove","Glowshroom","Grape","Hive Fruit",
	"Lemon","Lilac","Lotus","Mango","Mint","Moon Blossom","Moon Mango","Moon Melon","Moonflower","Moonglow",
	"Nectarine","Papaya","Passionfruit","Peach","Pear","Pepper","Pineapple","Pink Lily","Purple Cabbage",
	"Purple Dahlia","Raspberry","Rose","Soul Fruit","Starfruit","Strawberry","Succulent","Sunflower","Tomato",
	"Venus Fly Trap"
}
local selectedPlants = {}
local collecting = false

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

--// Lấy danh sách cây trong farm của người chơi
local plantsFolder = playerFarm.Important:FindFirstChild("Plants_Physical")
if not plantsFolder then
	warn("❌ Không tìm thấy Plants_Physical.")
	return
end

plantObjects = plantsFolder:GetChildren()

--// Tạo giao diện
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MultiFruitCollectorGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 280, 0, 300)
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
title.Text = "🌿 Multi Fruit Collector"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Gotham
title.TextSize = 16
title.BorderSizePixel = 0

local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.PlaceholderText = "🔍 Tìm kiếm cây..."
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.ClearTextOnFocus = false
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14

local dropdownList = Instance.new("ScrollingFrame", frame)
dropdownList.Size = UDim2.new(1, -20, 0, 180)
dropdownList.Position = UDim2.new(0, 10, 0, 75)
dropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
dropdownList.BorderSizePixel = 0
dropdownList.ScrollBarThickness = 6
dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", dropdownList)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 2)

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, -20, 0, 30)
autoBtn.Position = UDim2.new(0, 10, 1, -40)
autoBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 90)
autoBtn.Text = "▶️ Bắt đầu Auto"
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 14

--// Hàm thu thập
local function collectFruit(fruit)
	if not fruit:IsA("Model") then return end
	local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		fireproximityprompt(prompt)
		return
	end
	local click = fruit:FindFirstChildWhichIsA("ClickDetector", true)
	if click then
		fireclickdetector(click)
		return
	end
end

--// Hàm kiểm tra người chơi có cây này không
local function playerHasPlant(plantName)
	for _, plant in ipairs(plantObjects) do
		if plant.Name == plantName then
			return true
		end
	end
	return false
end

--// Tạo nút cây trong dropdown
local function createPlantButton(name)
	local btn = Instance.new("TextButton", dropdownList)
	btn.Size = UDim2.new(1, 0, 0, 25)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left

	local selectedMark = Instance.new("TextLabel", btn)
	selectedMark.Size = UDim2.new(0, 20, 1, 0)
	selectedMark.Position = UDim2.new(1, -22, 0, 0)
	selectedMark.Text = ""
	selectedMark.TextColor3 = Color3.new(0, 1, 0)
	selectedMark.BackgroundTransparency = 1
	selectedMark.Font = Enum.Font.Gotham
	selectedMark.TextSize = 18

	btn.MouseButton1Click:Connect(function()
		if selectedPlants[name] then
			selectedPlants[name] = nil
			selectedMark.Text = ""
		else
			if playerHasPlant(name) then
				selectedPlants[name] = true
				selectedMark.Text = "✔"
			else
				warn("Bạn không có cây " .. name)
			end
		end
	end)
	return btn
end

-- Tạo tất cả nút cây
local plantButtons = {}
for _, name in ipairs(allPlantNames) do
	plantButtons[name] = createPlantButton(name)
end

--// Lọc danh sách theo search
local function updateDropdownList(searchText)
	searchText = searchText:lower()
	local yPos = 0
	for name, btn in pairs(plantButtons) do
		if searchText == "" or name:lower():find(searchText) then
			btn.Visible = true
		else
			btn.Visible = false
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateDropdownList(searchBox.Text)
end)

-- Khởi tạo danh sách hiện tất cả
updateDropdownList("")

--// Vòng lặp thu thập
task.spawn(function()
	while true do
		if collecting and next(selectedPlants) then
			for plantName in pairs(selectedPlants) do
				for _, plant in ipairs(plantObjects) do
					if plant.Name == plantName then
						local fruitFolder = plant:FindFirstChild("Fruits")
						if fruitFolder then
							for _, fruit in ipairs(fruitFolder:GetChildren()) do
								collectFruit(fruit)
								task.wait(0.02) -- Tốc độ thu thập
							end
						end
					end
				end
			end
			task.wait(0.1) -- Delay giữa các vòng thu thập
		else
			task.wait(0.5)
		end
	end
end)

--// Bật/tắt auto
autoBtn.MouseButton1Click:Connect(function()
	collecting = not collecting
	autoBtn.Text = collecting and "⏸️ Dừng Auto" or "▶️ Bắt đầu Auto"
	autoBtn.BackgroundColor3 = collecting and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(80, 130, 90)
end)
