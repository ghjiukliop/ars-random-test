-- SCRIPT: Unit Recorder & Player with JSON (No custom path)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local UnitEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
local currentFile = nil
local isRecording = false
local isReplaying = false
local actionsHistory = {}
local jsonFiles = {}
local lastSaveFolder = nil -- Biến lưu đường dẫn thư mục đã chọn

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UnitRecorderCodex"
gui.ResetOnSpawn = false -- Để GUI không bị reset khi nhân vật respawn

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 450) -- Tăng kích thước frame để chứa nút mở thư mục
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

local openFolderBtn = Instance.new("TextButton", frame)
openFolderBtn.Size = UDim2.new(0.9, 0, 0, 30)
openFolderBtn.Position = UDim2.new(0.05, 0, 0, 100)
openFolderBtn.Text = "📂 Mở thư mục..."
openFolderBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
openFolderBtn.TextColor3 = Color3.new(1, 1, 1)

local dropdownBtn = Instance.new("TextButton", frame)
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 30)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 135)
dropdownBtn.Text = "▼ Chọn file JSON đã lưu"
dropdownBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
dropdownBtn.Visible = false -- Ẩn cho đến khi chọn thư mục

local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 150)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 170)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
dropdownFrame.Visible = false

local dropdownScroll = Instance.new("ScrollingFrame", dropdownFrame)
dropdownScroll.Size = UDim2.new(1, 0, 1, 0)
dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownScroll.ScrollBarThickness = 6
Instance.new("UIListLayout", dropdownScroll).Padding = UDim.new(0, 4)

local recordBtn = Instance.new("TextButton", frame)
recordBtn.Size = UDim2.new(0.9, 0, 0, 40)
recordBtn.Position = UDim2.new(0.05, 0, 0, 340)
recordBtn.Text = "⏺ Bắt đầu ghi"
recordBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
recordBtn.TextColor3 = Color3.new(1, 1, 1)

local replayBtn = Instance.new("TextButton", frame)
replayBtn.Size = UDim2.new(0.9, 0, 0, 40)
replayBtn.Position = UDim2.new(0.05, 0, 0, 390)
replayBtn.Text = "▶ Phát lại"
replayBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
replayBtn.TextColor3 = Color3.new(1, 1, 1)

local function populateDropdown(folderPath)
    if not folderPath or folderPath == "" then
        status.Text = "⚠️ Chưa chọn thư mục lưu file."
        dropdownBtn.Visible = false
        dropdownFrame.Visible = false
        return
    end

    for _, c in ipairs(dropdownScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    jsonFiles = {}

    local success, files = pcall(function()
        return listfiles(folderPath)
    end)

    if success and files then
        local jsonCount = 0
        for _, file in pairs(files) do
            if typeof(file) == "string" and file:match("%.json$") then
                local name = file:match("([^\/]+)%.json$")
                if name then
                    table.insert(jsonFiles, name)
                    jsonCount += 1

                    local btn = Instance.new("TextButton", dropdownScroll)
                    btn.Size = UDim2.new(1, 0, 0, 30)
                    btn.Text = name
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90) end)
                    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70) end)
                    btn.MouseButton1Click:Connect(function()
                        currentFile = name
                        dropdownBtn.Text = "▼ " .. name
                        dropdownFrame.Visible = false
                        status.Text = "📁 Đã chọn: " .. name .. ".json"
                    end)
                end
            end
        end
        dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, jsonCount * 35)
        dropdownBtn.Visible = jsonCount > 0
    else
        status.Text = "❌ Lỗi khi đọc thư mục: " .. (files or "")
        dropdownBtn.Visible = false
        dropdownFrame.Visible = false
    end
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
        if currentFile and lastSaveFolder then
            local encoded = HttpService:JSONEncode(actionsHistory)
            local fullPath = lastSaveFolder .. "/" .. currentFile .. ".json" -- Thêm đường dẫn thư mục
            local success, errorMessage = pcall(writefile, fullPath, encoded)
            if success then
                status.Text = "✅ Đã lưu: " .. fullPath
                populateDropdown(lastSaveFolder) -- Cập nhật dropdown sau khi lưu
            else
                status.Text = "⚠️ Lỗi khi lưu: " .. errorMessage
            end
        else
            status.Text = "⚠️ Không lưu: chưa chọn tên file hoặc thư mục"
        end
        recordBtn.Text = "⏺ Bắt đầu ghi"
        recordBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    else
        local nameFromInput = fileNameInput.Text
        if nameFromInput and nameFromInput ~= "" then
            currentFile = nameFromInput
        else
            currentFile = nil -- Không lưu nếu không có tên file
        end
        actionsHistory = {}
        isRecording = true
        status.Text = currentFile and lastSaveFolder and ("🔴 Ghi vào: " .. lastSaveFolder .. "/" .. currentFile .. ".json") or "🔴 Ghi (không lưu)"
        recordBtn.Text = "⏹ Dừng ghi"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

replayBtn.MouseButton1Click:Connect(function()
    if isReplaying then return end
    if not currentFile or not lastSaveFolder then
        status.Text = "❗ Chưa chọn file để phát lại"
        return
    end
    local fullpath = lastSaveFolder .. "/" .. currentFile .. ".json"
    local success, content = pcall(readfile, fullpath)
    if success and content then
        local ok, data = pcall(HttpService.JSONDecode, content)
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
    else
        status.Text = "❌ File không tồn tại: " .. fullpath
    end
end)

dropdownBtn.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

openFolderBtn.MouseButton1Click:Connect(function()
    -- Yêu cầu người dùng chọn một thư mục
    local chosenFolder = UserInputService:SelectFile() -- Hàm này có thể không hoạt động trên mọi executor
    if chosenFolder then
        lastSaveFolder = chosenFolder
        status.Text = "📁 Đã chọn thư mục: " .. chosenFolder
        populateDropdown(chosenFolder)
    else
        status.Text = "⚠️ Không có thư mục nào được chọn."
        dropdownBtn.Visible = false
        dropdownFrame.Visible = false
    end
end)

-- Gọi populateDropdown với thư mục đã lưu lần trước (nếu có) khi GUI được tạo
if lastSaveFolder then
    populateDropdown(lastSaveFolder)
end
