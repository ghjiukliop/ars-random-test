-- SCRIPT: Unit Recorder & Player with JSON

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local UnitEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
local currentFile = nil
local isRecording = false
local isReplaying = false
local actionsHistory = {}
local jsonFiles = {}

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UnitRecorderCodex"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "📼 Codex Recorder"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(0.9, 0, 0, 20)
status.Position = UDim2.new(0.05, 0, 0, 40)
status.Text = "🟢 Sẵn sàng"
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left

local fileNameInput = Instance.new("TextBox", frame)
fileNameInput.PlaceholderText = "Tên file (không cần .json)"
fileNameInput.Size = UDim2.new(0.9, 0, 0, 30)
fileNameInput.Position = UDim2.new(0.05, 0, 0, 65)
fileNameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
fileNameInput.TextColor3 = Color3.new(1, 1, 1)

local dropdownBtn = Instance.new("TextButton", frame)
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 30)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 100)
dropdownBtn.Text = "📂 Chọn file JSON ▼"
dropdownBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)

local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 150)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 135)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
dropdownFrame.Visible = false

local dropdownScroll = Instance.new("ScrollingFrame", dropdownFrame)
dropdownScroll.Size = UDim2.new(1, 0, 1, 0)
dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownScroll.ScrollBarThickness = 6
Instance.new("UIListLayout", dropdownScroll).Padding = UDim.new(0, 4)

local recordBtn = Instance.new("TextButton", frame)
recordBtn.Size = UDim2.new(0.9, 0, 0, 40)
recordBtn.Position = UDim2.new(0.05, 0, 0, 290)
recordBtn.Text = "⏺ Bắt đầu ghi"
recordBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
recordBtn.TextColor3 = Color3.new(1, 1, 1)

local replayBtn = Instance.new("TextButton", frame)
replayBtn.Size = UDim2.new(0.9, 0, 0, 40)
replayBtn.Position = UDim2.new(0.05, 0, 0, 340)
replayBtn.Text = "▶ Phát lại"
replayBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
replayBtn.TextColor3 = Color3.new(1, 1, 1)

local function updateDropdown()
    for _, c in ipairs(dropdownScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    jsonFiles = {}
    for _, file in pairs(listfiles()) do
        if file:match("%.json$") then
            local name = file:match("([^\\/]+)%.json$")
            table.insert(jsonFiles, name)

            local btn = Instance.new("TextButton", dropdownScroll)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.MouseButton1Click:Connect(function()
                currentFile = name
                dropdownBtn.Text = "📂 " .. name
                dropdownFrame.Visible = false
                status.Text = "📁 Đã chọn: " .. name
            end)
        end
    end
    dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #jsonFiles * 35)
end

UnitEvent.OnClientEvent:Connect(function(event, data)
    if isRecording then
        table.insert(actionsHistory, {
            event = event,
            data = data,
            timestamp = tick()
        })
        status.Text = "🔴 Ghi hành động: " .. event
    end
end)

recordBtn.MouseButton1Click:Connect(function()
    if isRecording then
        isRecording = false
        if currentFile then
            local encoded = HttpService:JSONEncode(actionsHistory)
            writefile(currentFile .. ".json", encoded)
            status.Text = "✅ Đã lưu: " .. currentFile .. ".json"
            updateDropdown()
        else
            status.Text = "⚠️ Không lưu vì chưa chọn tên file"
        end
        recordBtn.Text = "⏺ Bắt đầu ghi"
        recordBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    else
        local nameFromInput = fileNameInput.Text
        if nameFromInput and nameFromInput ~= "" then
            currentFile = nameFromInput
        end
        actionsHistory = {}
        isRecording = true
        status.Text = currentFile and ("🔴 Ghi file: " .. currentFile .. ".json") or "🔴 Ghi (không lưu)"
        recordBtn.Text = "⏹ Dừng ghi"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

replayBtn.MouseButton1Click:Connect(function()
    if isReplaying then return end
    if not currentFile then
        status.Text = "❗ Chưa chọn file để phát lại"
        return
    end
    local fullpath = currentFile .. ".json"
    if not isfile(fullpath) then
        status.Text = "❌ File không tồn tại"
        return
    end
    local content = readfile(fullpath)
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if ok and typeof(data) == "table" then
        isReplaying = true
        status.Text = "▶ Đang phát lại..."
        for _, act in ipairs(data) do
            UnitEvent:FireServer(act.event, act.data)
            wait(0.4)
        end
        status.Text = "✅ Đã phát xong"
        isReplaying = false
    else
        status.Text = "❌ Lỗi đọc file JSON"
    end
end)

dropdownBtn.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    if dropdownFrame.Visible then updateDropdown() end
end)

updateDropdown()
