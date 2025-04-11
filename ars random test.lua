local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent
local petFolder = player.leaderstats.Inventory.Pets

local selectedRank = 1
local autoSelling = false

-- GUI setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoSellPetGui"

-- Dropdown
local dropdown = Instance.new("TextButton", gui)
dropdown.Size = UDim2.new(0, 180, 0, 40)
dropdown.Position = UDim2.new(0, 20, 0, 100)
dropdown.Text = "🎯 Rank = " .. selectedRank
dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.SourceSansBold
dropdown.TextSize = 16

-- Toggle ON/OFF
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 180, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 150)
toggleBtn.Text = "🛑 Auto Sell OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16

dropdown.MouseButton1Click:Connect(function()
    local menu = Instance.new("Frame", gui)
    menu.Size = UDim2.new(0, 180, 0, 9 * 30)
    menu.Position = UDim2.new(0, 20, 0, 140)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    for i = 1, 9 do
        local btn = Instance.new("TextButton", menu)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        btn.Text = tostring(i)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.MouseButton1Click:Connect(function()
            selectedRank = i
            dropdown.Text = "🎯 Rank = " .. selectedRank
            menu:Destroy()
        end)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    autoSelling = not autoSelling
    toggleBtn.Text = autoSelling and "✅ Auto Sell ON" or "🛑 Auto Sell OFF"
    toggleBtn.BackgroundColor3 = autoSelling and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Auto Sell Loop
task.spawn(function()
    while true do
        if autoSelling then
            for _, pet in ipairs(petFolder:GetChildren()) do
                local rank = pet:GetAttribute("Rank")
                if typeof(rank) == "number" and rank == selectedRank then
                    local args = {
                        [1] = {
                            [1] = {
                                ["Event"] = "SellPet",
                                ["Pets"] = { pet.Name }
                            },
                            [2] = "\\t"
                        }
                    }
                    remote:FireServer(unpack(args))
                    print("💰 Đã bán pet:", pet.Name, "(Rank " .. rank .. ")")
                    task.wait(0.3)
                end
            end
        end
        task.wait(1)
    end
end)
