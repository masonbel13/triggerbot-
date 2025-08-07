local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Cấu hình mặc định
getgenv().TriggerbotConfig = getgenv().TriggerbotConfig or {
Delay = "0.1",
Prediction = "0.1",
Range = "10",
CheckWall = true
}

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

-- Nút bật/tắt Triggerbot
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 90, 0, 30)
toggle.Position = UDim2.new(0, 10, 0.8, 0)
toggle.Text = "Trigger: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.BorderSizePixel = 0
toggle.Draggable = true
toggle.Active = true

local isEnabled = false
toggle.MouseButton1Click:Connect(function()
isEnabled = not isEnabled
toggle.Text = isEnabled and "Trigger: ON" or "Trigger: OFF"
end)

-- Nút "+"
local plusButton = Instance.new("TextButton", gui)
plusButton.Size = UDim2.new(0, 30, 0, 30)
plusButton.Position = UDim2.new(0, 110, 0.8, 0)
plusButton.Text = "+"
plusButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
plusButton.TextColor3 = Color3.new(1,1,1)
plusButton.TextScaled = true
plusButton.BorderSizePixel = 0
plusButton.Draggable = true
plusButton.Active = true

-- Menu chỉnh Delay / Prediction / Range
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 200, 0, 230)
menu.Position = UDim2.new(0, 10, 0.65, 0)
menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menu.Visible = false
menu.Active = true
menu.Draggable = true

plusButton.MouseButton1Click:Connect(function()
menu.Visible = not menu.Visible
end)

-- Delay
local delayLabel = Instance.new("TextLabel", menu)
delayLabel.Size = UDim2.new(0, 180, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 10)
delayLabel.Text = "Delay (s):"
delayLabel.BackgroundTransparency = 1
delayLabel.TextColor3 = Color3.new(1,1,1)

local delayBox = Instance.new("TextBox", menu)
delayBox.Size = UDim2.new(0, 180, 0, 25)
delayBox.Position = UDim2.new(0, 10, 0, 30)
delayBox.PlaceholderText = "0.1"
delayBox.Text = getgenv().TriggerbotConfig.Delay
delayBox.TextColor3 = Color3.new(1,1,1)
delayBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
delayBox.FocusLost:Connect(function()
getgenv().TriggerbotConfig.Delay = delayBox.Text
end)

-- Prediction
local predLabel = Instance.new("TextLabel", menu)
predLabel.Size = UDim2.new(0, 180, 0, 20)
predLabel.Position = UDim2.new(0, 10, 0, 60)
predLabel.Text = "Prediction (s):"
predLabel.BackgroundTransparency = 1
predLabel.TextColor3 = Color3.new(1,1,1)

local predBox = Instance.new("TextBox", menu)
predBox.Size = UDim2.new(0, 180, 0, 25)
predBox.Position = UDim2.new(0, 10, 0, 80)
predBox.PlaceholderText = "0.1"
predBox.Text = getgenv().TriggerbotConfig.Prediction
predBox.TextColor3 = Color3.new(1,1,1)
predBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
predBox.FocusLost:Connect(function()
getgenv().TriggerbotConfig.Prediction = predBox.Text
end)

-- Range
local rangeLabel = Instance.new("TextLabel", menu)
rangeLabel.Size = UDim2.new(0, 180, 0, 20)
rangeLabel.Position = UDim2.new(0, 10, 0, 110)
rangeLabel.Text = "Target Range (px):"
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.new(1,1,1)

local rangeBox = Instance.new("TextBox", menu)
rangeBox.Size = UDim2.new(0, 180, 0, 25)
rangeBox.Position = UDim2.new(0, 10, 0, 130)
rangeBox.PlaceholderText = "10"
rangeBox.Text = getgenv().TriggerbotConfig.Range
rangeBox.TextColor3 = Color3.new(1,1,1)
rangeBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
rangeBox.FocusLost:Connect(function()
getgenv().TriggerbotConfig.Range = rangeBox.Text
end)

-- CheckWall toggle
local wallCheckBtn = Instance.new("TextButton", menu)
wallCheckBtn.Size = UDim2.new(0, 180, 0, 25)
wallCheckBtn.Position = UDim2.new(0, 10, 0, 215)
wallCheckBtn.Text = "Check Wall: " .. tostring(getgenv().TriggerbotConfig.CheckWall and "ON" or "OFF")
wallCheckBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
wallCheckBtn.TextColor3 = Color3.new(1,1,1)
wallCheckBtn.TextScaled = true

wallCheckBtn.MouseButton1Click:Connect(function()
getgenv().TriggerbotConfig.CheckWall = not getgenv().TriggerbotConfig.CheckWall
wallCheckBtn.Text = "Check Wall: " .. (getgenv().TriggerbotConfig.CheckWall and "ON" or "OFF")
end)

-- Check tường
local function isVisible(part)
if not getgenv().TriggerbotConfig.CheckWall then return true end
local origin = camera.CFrame.Position
local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Blacklist
ray.FilterDescendantsInstances = {player.Character, part.Parent}
local result = workspace:Raycast(origin, direction, ray)
return result == nil
end

-- Tìm địch trong vùng tâm
local function getTarget(range)
for _, plr in pairs(Players:GetPlayers()) do
if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0 then
for _, part in pairs(plr.Character:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
local screenPos, visible = camera:WorldToViewportPoint(part.Position)
if visible and isVisible(part) then
local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
if dist < tonumber(range) then
return plr
end
end
end
end
end
end
end

-- Tự động bắn
local lastShot = 0
RunService.RenderStepped:Connect(function()
if not isEnabled then return end

local delay = tonumber(delayBox.Text) or 0.1  
local prediction = tonumber(predBox.Text) or 0.1  
local range = tonumber(rangeBox.Text) or 10  

local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")  
local target = getTarget(range)  

if tool and target and tick() - lastShot >= delay then  
	pcall(function()  
		tool:Activate()  
	end)  
	lastShot = tick()  
end

end)