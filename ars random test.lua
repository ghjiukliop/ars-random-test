local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitEvent = ReplicatedStorage.Networking.UnitEvent
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local actionsHistory = {}
local isRecording = false
local isReplaying = false

-- Tạo GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UnitActionRecorder"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local title = Instance.new("TextLabel", mainFrame)
title.Text = "UNIT ACTION RECORDER"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.TextColor3 = Color3.new(1, 1, 1)

-- Nút ghi
local recordBtn = Instance.new("TextButton", mainFrame)
recordBtn.Text = "Bắt đầu ghi"
recordBtn.Size = UDim2.new(0.9, 0, 0, 30)
recordBtn.Position = UDim2.new(0.05, 0, 0, 40)
recordBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)

-- Nút phát lại
local replayBtn = Instance.new("TextButton", mainFrame)
replayBtn.Text = "Phát lại"
replayBtn.Size = UDim2.new(0.9, 0, 0, 30)
replayBtn.Position = UDim2.new(0.05, 0, 0, 80)
replayBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60)

-- Hiển thị trạng thái
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Text = "Trạng thái: Đang chờ"
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0, 120)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)

-- Hiển thị lịch sử
local historyLabel = Instance.new("TextLabel", mainFrame)
historyLabel.Text = "Hành động: 0"
historyLabel.Size = UDim2.new(0.9, 0, 0, 30)
historyLabel.Position = UDim2.new(0.05, 0, 0, 160)
historyLabel.BackgroundTransparency = 1
historyLabel.TextColor3 = Color3.new(1, 1, 1)

-- Hàm ghi lại hành động
local function logAction(actionType, data)
    if not isRecording then return end
    
    local action = {
        type = actionType,
        data = data,
        timestamp = os.time()
    }
    
    table.insert(actionsHistory, action)
    historyLabel.Text = "Hành động: " .. #actionsHistory
    print("Đã ghi hành động:", actionType)
end

-- Kết nối sự kiện UnitEvent
local originalFireServer = UnitEvent.FireServer
UnitEvent.FireServer = function(self, ...)
    local args = {...}
    
    -- Ghi lại hành động
    if args[1] == "Render" then
        logAction("Place", args[2])
    elseif args[1] == "Upgrade" then
        logAction("Upgrade", args[2])
    elseif args[1] == "Sell" then
        logAction("Sell", args[2])
    end
    
    return originalFireServer(self, ...)
end

-- Nút ghi
recordBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    
    if isRecording then
        actionsHistory = {}
        recordBtn.Text = "Dừng ghi"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        statusLabel.Text = "Trạng thái: Đang ghi"
        historyLabel.Text = "Hành động: 0"
    else
        recordBtn.Text = "Bắt đầu ghi"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        statusLabel.Text = "Trạng thái: Đã dừng"
        print("Đã ghi được", #actionsHistory, "hành động")
    end
end)

-- Nút phát lại
replayBtn.MouseButton1Click:Connect(function()
    if isReplaying or #actionsHistory == 0 then return end
    
    isReplaying = true
    statusLabel.Text = "Trạng thái: Đang phát lại"
    
    for i, action in ipairs(actionsHistory) do
        local args
        
        if action.type == "Place" then
            args = {
                [1] = "Render",
                [2] = action.data
            }
        elseif action.type == "Upgrade" then
            args = {
                [1] = "Upgrade",
                [2] = action.data
            }
        elseif action.type == "Sell" then
            args = {
                [1] = "Sell",
                [2] = action.data
            }
        end
        
        UnitEvent:FireServer(unpack(args))
        wait(0.5) -- Delay giữa các hành động
    end
    
    isReplaying = false
    statusLabel.Text = "Trạng thái: Phát lại hoàn tất"
end)

-- Kiểm tra unit hiện có
local function scanExistingUnits()
    for _, unit in pairs(workspace.Units:GetChildren()) do
        print("Unit tồn tại:", unit.Name)
    end
end

-- Quét unit khi bắt đầu
scanExistingUnits()
