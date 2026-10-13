--==================================================--
--     BlockSpin Ultimate Fishing Farm (Hermanos)    --
--               Created by: dev night              --
--==================================================--

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("BlockSpin | Fishing Farm Pro (dev night)", "GrapeTheme")

-- الإعدادات الأساسية
local Settings = {
    AutoFish = false,
    FastReel = true,
    AutoEquipRod = true,
    AutoSell = false,
    SellWhenFull = true,
    AutoTeleport = false,
    SelectedZone = "Level 10 Spot",
    AntiAFK = true
}

-- إحداثيات مناطق الصيد ومواقع البيع
-- (يمكنك ضبط الأرقام بدقة حسب إحداثيات ماب BlockSpin)
local Zones = {
    ["Level 10 Spot"] = Vector3.new(120, 10, 250),
    ["Level 40 Spot"] = Vector3.new(340, 10, -180),
    ["Level 70 Spot"] = Vector3.new(-220, 10, 520)
}

local SellNPCLocation = Vector3.new(50, 10, 50)

-- ==================== 1. تبويب الصيد والتلفيل ====================
local FishTab = Window:NewTab("الصيد والتلفيل 🎣")
local FishSec = FishTab:NewSection("إعدادات الصيد المتقدمة (Auto Fishing)")

FishSec:NewToggle("تفعيل الصيد التلقائي (Auto Fish)", "رمي وسحب الصنارة تلقائياً", function(state)
    Settings.AutoFish = state
end)

FishSec:NewToggle("تجهيز الصنارة تلقائياً (Auto Equip Rod)", "تجهيز الصنارة من الشنطة إن لم تكن بيدك", function(state)
    Settings.AutoEquipRod = state
end)

FishSec:NewToggle("سحب سريع (Fast Reel)", "تسريع عملية الصيد بدون انتظار", function(state)
    Settings.FastReel = state
end)

-- ==================== 2. تبويب الانتقال والمناطق ====================
local ZoneTab = Window:NewTab("مناطق الصيد 📍")
local ZoneSec = ZoneTab:NewSection("الانتقال لمنطقة الصيد حسب اللفل")

ZoneSec:NewDropdown("اختر منطقة الصيد", "حدد المنطقة المخصصة لسطح الصيد", {"Level 10 Spot", "Level 40 Spot", "Level 70 Spot"}, function(v)
    Settings.SelectedZone = v
    if Settings.AutoTeleport then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and Zones[v] then
            char.HumanoidRootPart.CFrame = CFrame.new(Zones[v])
        end
    end
end)

ZoneSec:NewToggle("انتقال تلقائي للمنطقة (Auto Teleport)", "الانتقال فوراً للموقع المختار", function(state)
    Settings.AutoTeleport = state
    if state then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and Zones[Settings.SelectedZone] then
            char.HumanoidRootPart.CFrame = CFrame.new(Zones[Settings.SelectedZone])
        end
    end
end)

-- ==================== 3. تبويب البيع والتخزين ====================
local SellTab = Window:NewTab("البيع والتخزين 💰")
local SellSec = SellTab:NewSection("إعدادات Auto Sell")

SellSec:NewToggle("بيع الأسماك تلقائياً (Auto Sell)", "الذهاب للتاجر وبيع الأسماك ثم العودة", function(state)
    Settings.AutoSell = state
end)

SellSec:NewToggle("البيع عند امتلاء الحقيبة فقط", "عدم الذهاب للبيع إلا إذا امتلأت الشنطة", function(state)
    Settings.SellWhenFull = state
end)

SellSec:NewButton("بيع كل الأسماك الآن", "الانتقال فوراً للبيع والرجوع", function()
    pcall(function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local oldPos = char.HumanoidRootPart.CFrame
            char.HumanoidRootPart.CFrame = CFrame.new(SellNPCLocation)
            task.wait(1)
            -- تفاعل مع تاجر السمك
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                end
            end
            task.wait(1)
            char.HumanoidRootPart.CFrame = oldPos
        end
    end)
end)

-- ==================== 4. تبويب الحماية واللاعب ====================
local MiscTab = Window:NewTab("الحماية واللاعب ⚙️")
local MiscSec = MiscTab:NewSection("إعدادات الإقامة والسرعة")

MiscSec:NewToggle("مانع الخروج الآلي (Anti-AFK)", "يمنع اللعبة من إخراجك بسبب عدم الحركة", function(state)
    Settings.AntiAFK = state
end)

MiscSec:NewSlider("سرعة المشي (WalkSpeed)", "تعديل السرعة", 100, 16, function(v)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end)

-- ==================== 5. تبويب الحقوق ====================
local DevTab = Window:NewTab("المطور 👑")
local DevSec = DevTab:NewSection("dev night")
DevSec:NewLabel("تم تطوير هب الصيد بواسطة: dev night")
DevSec:NewButton("نسخ الحقوق", "نسخ اسم dev night", function()
    setclipboard("dev night")
end)

-- ==================== محرك السكربت الخلفي ====================

-- مانع الـ AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- حلقة الفارم التلقائي
task.spawn(function()
    while task.wait(Settings.FastReel and 0.15 or 0.4) do
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char then return end

            if Settings.AutoFish then
                -- 1. تجهيز الصنارة تلقائياً
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool and Settings.AutoEquipRod then
                    for _, item in pairs(player.Backpack:GetChildren()) do
                        if item:IsA("Tool") and (item.Name:lower():find("fish") or item.Name:lower():find("rod") or item.Name:lower():find("صيد")) then
                            item.Parent = char
                            tool = item
                            break
                        end
                    end
                end

                -- 2. تفعيل الصنارة (رمي / سحب)
                if tool then
                    tool:Activate()
                end

                -- 3. الضغط التلقائي على أزرار السحب/الصيد التي تظهر في الشاشة
                if player:FindFirstChild("PlayerGui") then
                    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                            local txt = gui.Text:lower()
                            if txt:find("reel") or txt:find("catch") or txt:find("pull") or txt:find("صيد") then
                                for _, event in pairs(getconnections(gui.MouseButton1Click)) do
                                    event:Fire()
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

print("--------------------------------------")
print("Fishing Farm Pro Loaded Successfully!")
print("Developer: dev night")
print("--------------------------------------")
