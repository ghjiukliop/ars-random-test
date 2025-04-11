-- Auto Sell Pet Script with Dropdown Rank Selector

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local petFolder = player.leaderstats.Inventory:WaitForChild("Pets")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local rankList = {"E", "D", "C", "B", "A", "S", "SS", "G", "N"}
local selectedRank = "E" -- Mặc định bán từ Rank E trở xuống
local autoSelling = false

-- Dropdown chọn Rank
local dropdown = Instance.new("TextButton", gui)
dropdown.Size = UDim2.new(0, 150, 0, 30)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "Chọn Rank bán (<=)"
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1, 1, 1)

local currentMenu = nil
dropdown.MouseButton1Click:Connect(function()
    if currentMenu then currentMenu:Destroy() end
    local menu = Instance.new("Frame", gui)
    menu.Position = UDim2.new(0, 20, 0, 130)
    menu.Size = UDim2.new(0, 150, 0, #rankList * 30)
    menu.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    currentMenu = menu

    for i, rank in ipairs(rankList) do
        local btn = Instance.new("TextButton", menu)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        btn.Text = rank
        btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.MouseButton1Click:Connect(function()
            selectedRank = rank
            dropdown.Text = "Bán Pet <= Rank: " .. rank
            menu:Destroy()
        end)
    end
end)

-- Nút bật auto sell
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 150, 0, 30)
toggle.Position = UDim2.new(0, 20, 0, 60)
toggle.Text = "Auto Sell: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)

toggle.MouseButton1Click:Connect(function()
    autoSelling = not autoSelling
    toggle.Text = autoSelling and "Auto Sell: ON" or "Auto Sell: OFF"
    toggle.BackgroundColor3 = autoSelling and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(120, 50, 50)
end)

-- Hàm quy đổi Rank thành số để so sánh
local function getRankValue(rankStr)
    local valueMap = {
        E = 1, D = 2, C = 3, B = 4, A = 5, S = 6, SS = 7, G = 8, N = 9
    }
    return valueMap[rankStr] or 0
end

-- Vòng lặp bán pet theo rank
RunService.Heartbeat:Connect(function()
    if not autoSelling then return end

    for _, pet in ipairs(petFolder:GetChildren()) do
        local rankStr = pet:GetAttribute("Rank")
        if typeof(rankStr) == "string" and getRankValue(rankStr) <= getRankValue(selectedRank) then
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "SellPet",
                        ["Pets"] = {
                            [1] = pet.Name
                        }
                    },
                    [2] = "\t"
                }
            }
            remote:FireServer(unpack(args))
            print("💰 Đã bán pet:", pet.Name, "(Rank:", rankStr .. ")")
            task.wait(0.3)
        end
    end
end)
