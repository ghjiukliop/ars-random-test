local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local actionsHistory = {}
local isRecording = false
local isReplaying = false
local jsonFiles = {}

-- Kết nối RemoteEvent
local function getUnitEvent()
    local networking = ReplicatedStorage:WaitForChild("Networking", 5)
    if not networking then error("Không tìm thấy Networking") end
    local unitEvent = networking:WaitForChild("UnitEvent", 5)
    if not unitEvent then error("Không tìm thấy UnitEvent") end
    return unitEvent
end

local UnitEvent = getUnitEvent()

-- Tạo GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AdvancedUnitRecorder"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2

local title = Instance.new("TextLabel", mainFrame)
title.Text = "📁 UNIT ACTION RECORDER"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold

-- Ô nhập tên file JSON
local fileNameInput = Instance.new("TextBox", mainFrame)
fileNameInput.PlaceholderText = "Nhập tên file (không cần .json)"
fileNameInput.Size = UDim2.new(0.9, 0, 0, 30)
fileNameInput.Position = UDim2.new(0.05, 0, 0, 50)
fileNameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
fileNameInput.TextColor3 = Color3.new(1, 1, 1)

-- Nút lưu JSON
local saveBtn = Instance.new("TextButton", mainFrame)
saveBtn.Text = "💾 LƯU FILE JSON"
saveBtn.Size = UDim2.new(0.9, 0, 0, 30)
saveBtn.Position = UDim2.new(0.05, 0, 0, 90)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
saveBtn.TextColor3 = Color3.new(1, 1, 1)

-- Dropdown chọn file
local dropdownBtn = Instance.new("TextButton", mainFrame)
dropdownBtn.Text = "📂 CHỌN FILE JSON ▼"
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 30)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 130)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)

local dropdownFrame = Instance.new("Frame", mainFrame)
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 150)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 165)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
dropdownFrame.Visible = false

local dropdownScroll = Instance.new("ScrollingFrame", dropdownFrame)
dropdownScroll.Size = UDim2.new(1, 0, 1, 0)
dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local dropdownLayout = Instance.new("UIListLayout", dropdownScroll)
dropdownLayout.Padding = UDim.new(0, 5)

-- Nút ghi hành động
local recordBtn = Instance.new("TextButton", mainFrame)
recordBtn.Text = "⏺ BẮT ĐẦU GHI"
recordBtn.Size = UDim2.new(0.9, 0, 0, 40)
recordBtn.Position = UDim2.new(0.05, 0, 0, 330)
recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
recordBtn.TextColor3 = Color3.new(1, 1, 1)

-- Nút phát lại
local replayBtn = Instance.new("TextButton", mainFrame)
replayBtn.Text = "▶ PHÁT LẠI HÀNH ĐỘNG"
replayBtn.Size = UDim2.new(0.9, 0, 0, 40)
replayBtn.Position = UDim2.new(0.05, 0, 0, 380)
replayBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
replayBtn.TextColor3 = Color3.new(1, 1, 1)

-- Hiển thị trạng thái
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Text = "🟢 TRẠNG THÁI: SẴN SÀNG"
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 430)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Cập nhật dropdown
local function updateDropdown()
    jsonFiles = {}
    for _, file in pairs(listfiles()) do
        if file:match("%.json$") then
            table.insert(jsonFiles, file:match("([^\\/]+)%.json$"))
        end
    end
    
    -- Xóa các nút cũ
    for _, child in ipairs(dropdownScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Thêm nút mới
    for i, fileName in ipairs(jsonFiles) do
        local fileBtn = Instance.new("TextButton", dropdownScroll)
        fileBtn.Text = fileName
        fileBtn.Size = UDim2.new(1, 0, 0, 30)
        fileBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
        fileBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        fileBtn.TextColor3 = Color3.new(1, 1, 1)
        
        fileBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = "📂 "..fileName
            dropdownFrame.Visible = false
        end)
    end
    
    dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #jsonFiles * 35)
end

-- Lưu vào JSON
local function saveToJSON()
    local fileName = fileNameInput.Text
    if fileName == "" then
        statusLabel.Text = "🔴 LỖI: Chưa nhập tên file!"
        return
    end
    
    if #actionsHistory == 0 then
        statusLabel.Text = "🔴 LỖI: Không có hành động nào!"
        return
    end
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(actionsHistory)
    end)
    
    if success then
        writefile(fileName..".json", json)
        statusLabel.Text = "🟢 ĐÃ LƯU: "..fileName..".json"
        updateDropdown()
    else
        statusLabel.Text = "🔴 LỖI: Không thể tạo JSON!"
    end
end

-- Tải từ JSON
local function loadFromJSON()
    local selectedFile = dropdownBtn.Text:match("📂 (.+)$")
    if not selectedFile or selectedFile == "CHỌN FILE JSON ▼" then
        statusLabel.Text = "🔴 LỖI: Chưa chọn file!"
        return
    end
    
    if not isfile(selectedFile..".json") then
        statusLabel.Text = "🔴 LỖI: File không tồn tại!"
        return
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(selectedFile..".json"))
    end)
    
    if success then
        actionsHistory = data
        statusLabel.Text = "🟢 ĐÃ TẢI: "..selectedFile.." ("..#actionsHistory.." hành động)"
    else
        statusLabel.Text = "🔴 LỖI: File JSON không hợp lệ!"
    end
end

-- Ghi lại hành động
UnitEvent.OnClientEvent:Connect(function(action, data)
    if not isRecording then return end
    
    table.insert(actionsHistory, {
        type = action,
        data = data,
        time = os.time()
    })
    
    statusLabel.Text = "🔵 ĐANG GHI: "..action
end)

-- Phát lại hành động
local function replayActions()
    if isReplaying then return end
    if #actionsHistory == 0 then
        statusLabel.Text = "🔴 LỖI: Không có hành động!"
        return
    end
    
    isReplaying = true
    statusLabel.Text = "🟠 ĐANG PHÁT LẠI..."
    
    for _, action in ipairs(actionsHistory) do
        UnitEvent:FireServer(action.type, action.data)
        wait(0.5)
    end
    
    isReplaying = false
    statusLabel.Text = "🟢 PHÁT LẠI HOÀN TẤT!"
end

-- Kết nối nút
dropdownBtn.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    if dropdownFrame.Visible then updateDropdown() end
end)

saveBtn.MouseButton1Click:Connect(saveToJSON)
dropdownBtn.MouseButton1Click:Connect(loadFromJSON)

recordBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        actionsHistory = {}
        recordBtn.Text = "⏹ DỪNG GHI"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        statusLabel.Text = "🔴 ĐANG GHI..."
    else
        recordBtn.Text = "⏺ BẮT ĐẦU GHI"
        recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 ĐÃ DỪNG ("..#actionsHistory.." hành động)"
    end
end)

replayBtn.MouseButton1Click:Connect(replayActions)

-- Khởi động
updateDropdown()
statusLabel.Text = "🟢 SẴN SÀNG - Chọn file hoặc bắt đầu ghi!"
