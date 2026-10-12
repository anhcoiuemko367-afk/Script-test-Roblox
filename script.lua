local Window = Fluent:CreateWindow({
    Title = "⚡ KING HUB | Steal An Egg VIP PRO",
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

-- [[ THÀNH PHẦN HỆ THỐNG ]]
local Tabs = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "egg" }),
    Teleport = Window:AddTab({ Title = "Dịch Chuyển", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Cài Đặt", Icon = "settings" })
}

local Options = Fluent.Options
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ HÀM TỐI ƯU DỊCH CHUYỂN MƯỢT MÀ (TWEEN) ]]
local function TeleportTo(targetCFrame, speed)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    -- Vô hiệu hóa trọng lực tạm thời để không bị rớt/kẹt khi bay
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp
    
    tween:Play()
    tween.Completed:Wait()
    
    bv:Destroy()
end

-- [[ TÍNH NĂNG 1: AUTO FARM TRỨNG ]]
Tabs.Main:AddToggle("AutoEgg", {Title = "Auto Nhặt Trứng Siêu Tốc", Default = false})
Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Tốc độ di chuyển (An Toàn: 50-70)",
    Description = "Chỉnh cao quá có thể bị Game Kick!",
    Default = 60,
    Min = 30,
    Max = 150,
    Rounding = 0
})

task.spawn(function()
    while task.wait(0.5) do
        if Options.AutoEgg.Value then
            -- TÌM TRỨNG GẦN NHẤT (Chỉnh sửa Workspace theo cấu trúc game thực tế)
            local TargetEgg = nil
            local ShortestDistance = math.huge
            
            -- Giả định trứng nằm trong Workspace.Eggs hoặc Workspace.DroppedEggs
            local EggFolder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("DroppedEggs")
            if EggFolder then
                for _, egg in pairs(EggFolder:GetChildren()) do
                    if egg:IsA("BasePart") or egg:FindFirstChild("Handle") then
                        local eggPart = egg:IsA("BasePart") and egg or egg.Handle
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - eggPart.Position).Magnitude
                        if distance < ShortestDistance then
                            ShortestDistance = distance
                            TargetEgg = eggPart
                        end
                    end
                end
            end
            
            -- Tiến hành bay tới nhặt
            if TargetEgg then
                TeleportTo(TargetEgg.CFrame * CFrame.new(0, 2, 0), Options.TweenSpeed.Value)
                task.wait(0.1) -- Đợi 1 nhịp để game nhận diện đã nhặt được
            end
        end
    end
end)

-- [[ TÍNH NĂNG 2: AUTO BÁN / CẤT TRỨNG ]]
Tabs.Main:AddToggle("AutoSell", {Title = "Tự động bán / Cất vào Base", Default = false})

task.spawn(function()
    while task.wait(1) do
        if Options.AutoSell.Value then
            -- Tìm khu vực Base/Sell của người chơi
            local BaseArea = workspace:FindFirstChild("Unlocks") or workspace:FindFirstChild("Bases")
            -- Thay thế "MyBase" bằng logic tìm Base tương ứng với Tên người chơi
            if BaseArea and BaseArea:FindFirstChild(LocalPlayer.Name) then
                local sellPart = BaseArea[LocalPlayer.Name]:FindFirstChild("SellPart") or BaseArea[LocalPlayer.Name]
                TeleportTo(sellPart.CFrame, Options.TweenSpeed.Value)
            end
        end
    end
end)

-- [[ TÍNH NĂNG HỆ THỐNG & BẢO MẬT ]]
Tabs.Settings:AddButton({
    Title = "Bật Chống Treo Máy (Anti-AFK)",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
            Fluent:Notify({Title = "Anti-AFK", Content = "Đã ngăn chặn hệ thống Kick treo máy thành công!", Duration = 3})
        end)
    end
})

-- Hoàn tất thiết lập
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("KingHubConfig")
SaveManager:SetFolder("KingHubConfig/StealAnEgg")
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
