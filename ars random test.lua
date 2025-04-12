local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Kiểm tra và kết nối RemoteEvent đúng cách
local function getUnitEvent()
    local networking = ReplicatedStorage:FindFirstChild("Networking")
    if not networking then
        networking = ReplicatedStorage:WaitForChild("Networking", 5)
        if not networking then
            error("Không tìm thấy thư mục Networking trong ReplicatedStorage")
        end
    end

    local unitEvent = networking:FindFirstChild("UnitEvent")
    if not unitEvent then
        unitEvent = networking:WaitForChild("UnitEvent", 5)
        if not unitEvent then
            error("Không tìm thấy RemoteEvent UnitEvent")
        end
    end

    return unitEvent
end

local UnitEvent = getUnitEvent()
local player = Players.LocalPlayer
local actionsHistory = {}
local isRecording = false
local isReplaying = false

-- Tạo GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UnitActionRecorderPro"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "⚡ UNIT RECORDER PRO"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Nút ghi
local recordBtn = Instance.new("TextButton", mainFrame)
recordBtn.Text = "⏺ BẮT ĐẦU GHI"
recordBtn.Size = UDim2.new(0.9, 0, 0, 40)
recordBtn.Position = UDim2.new(0.05, 0, 0, 50)
recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
recordBtn.TextColor3 = Color3.new(1, 1, 1)
recordBtn.Font = Enum.Font.GothamSemibold

-- Nút phát lại
local replayBtn = Instance.new("TextButton", mainFrame)
replayBtn.Text = "▶ PHÁT LẠI"
replayBtn.Size = UDim2.new(0.9, 0, 0, 40)
replayBtn.Position = UDim2.new(0.05, 0, 0, 100)
replayBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
replayBtn.TextColor3 = Color3.new(1, 1, 1)
replayBtn.Font = Enum.Font.GothamSemibold

-- Nút lưu JSON
local saveBtn = Instance.new("TextButton", mainFrame)
saveBtn.Text = "💾 LƯU VÀO JSON"
saveBtn.Size = UDim2.new(0.9, 0, 0, 30)
saveBtn.Position = UDim2.new(0.05, 0, 0, 160)
saveBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.Gotham

-- Nút tải JSON
local loadBtn = Instance.new("TextButton", mainFrame)
loadBtn.Text = "📂 TẢI TỪ JSON"
loadBtn.Size = UDim2.new(0.9, 0, 0, 30)
loadBtn.Position = UDim2.new(0.05, 0, 0, 200)
loadBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
loadBtn.TextColor3 = Color3.new(1, 1, 1)
loadBtn.Font = Enum.Font.Gotham

-- Hiển thị trạng thái
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Text = "🟢 Trạng thái: SẴN SÀNG"
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 240)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Hàm lưu vào JSON
local function saveToJSON()
    if #actionsHistory == 0 then
        statusLabel.Text = "🔴 Lỗi: Không có dữ liệu để lưu"
        return
    end
    
    local success, jsonString = pcall(function()
        return HttpService:JSONEncode(actionsHistory)
    end)
    
    if success then
        writefile("UnitActions.json", jsonString)
        statusLabel.Text = "🟢 Đã lưu vào UnitActions.json"
    else
        statusLabel.Text = "🔴 Lỗi khi chuyển đổi JSON"
    end
end

-- Hàm tải từ JSON
local function loadFromJSON()
    if not isfile("UnitActions.json") then
        statusLabel.Text = "🔴 Lỗi: Không tìm thấy file JSON"
        return
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile("UnitActions.json"))
    end)
    
    if success then
        actionsHistory = data
        statusLabel.Text = "🟢 Đã tải "..#actionsHistory.." hành động"
    else
        statusLabel.Text = "🔴 Lỗi khi đọc file JSON"
    end
end

-- Hàm ghi lại hành động
local function logAction(actionType, data)
    if not isRecording then return end
    
    local action = {
        type = actionType,
        data = data,
        timestamp = os.time()
    }
    
    table.insert(actionsHistory, action)
    statusLabel.Text = "🔵 Đã ghi: "..actionType
end

-- Kết nối sự kiện UnitEvent
UnitEvent.OnClientEvent:Connect(function(action, data)
    if action == "Render" then
        logAction("Place", data)
    elseif action == "Upgrade" then
        logAction("Upgrade", data)
    elseif action == "Sell" then
        logAction("Sell", data)
    end
end)

-- Nút ghi
recordBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    
    if isRecording then
        actionsHistory = {}
        recordBtn.Text = "⏹ DỪNG GHI"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        statusLabel.Text = "🔴 Trạng thái: ĐANG GHI"
    else
        recordBtn.Text = "⏺ BẮT ĐẦU GHI"
        recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 Trạng thái: ĐÃ DỪNG"
    end
end)

-- Nút phát lại
replayBtn.MouseButton1Click:Connect(function()
    if isReplaying or #actionsHistory == 0 then return end
    
    isReplaying = true
    statusLabel.Text = "🟡 Trạng thái: ĐANG PHÁT LẠI"
    
    for i, action in ipairs(actionsHistory) do
        if action.type == "Place" then
            UnitEvent:FireServer("Render", action.data)
        elseif action.type == "Upgrade" then
            UnitEvent:FireServer("Upgrade", action.data)
        elseif action.type == "Sell" then
            UnitEvent:FireServer("Sell", action.data)
        end
        
        wait(0.5)
    end
    
    isReplaying = false
    statusLabel.Text = "🟢 Trạng thái: PHÁT LẠI HOÀN TẤT"
end)

-- Nút lưu JSON
saveBtn.MouseButton1Click:Connect(saveToJSON)

-- Nút tải JSON
loadBtn.MouseButton1Click:Connect(loadFromJSON)

-- Thông báo khởi động thành công
statusLabel.Text = "🟢 Sẵn sàng sử dụng!"
