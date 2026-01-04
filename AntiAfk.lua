repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

if getgenv().AntiAfkV6 then
	pcall(function() game.CoreGui.AntiAfkV6:Destroy() end)
end
getgenv().AntiAfkV6 = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AntiAfkV6"
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.fromOffset(240,125)
main.Position = UDim2.fromScale(0.1,0.15)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Visible = true

Instance.new("UICorner",main).CornerRadius = UDim.new(0,8)

local scale = Instance.new("UIScale")
scale.Parent = main
scale.Scale = 1

local top = Instance.new("TextLabel")
top.Parent = main
top.Size = UDim2.new(1,0,0,28)
top.BackgroundTransparency = 1
top.Text = "Anti AFK | By Hieudepzai"
top.Font = Enum.Font.GothamBold
top.TextSize = 14
top.TextColor3 = Color3.fromRGB(255,255,255)

local close = Instance.new("TextButton")
close.Parent = main
close.Size = UDim2.fromOffset(28,28)
close.Position = UDim2.new(1,-28,0,0)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.fromRGB(255,80,80)
close.BackgroundTransparency = 1

close.MouseButton1Click:Connect(function()
	getgenv().AntiAfkV6 = false
	gui:Destroy()
end)

local fpsText = Instance.new("TextLabel")
fpsText.Parent = main
fpsText.Position = UDim2.fromOffset(12,40)
fpsText.Size = UDim2.fromOffset(200,18)
fpsText.BackgroundTransparency = 1
fpsText.Font = Enum.Font.Gotham
fpsText.TextSize = 13
fpsText.TextColor3 = Color3.fromRGB(200,200,200)
fpsText.Text = "FPS: 0"

local pingText = Instance.new("TextLabel")
pingText.Parent = main
pingText.Position = UDim2.fromOffset(12,58)
pingText.Size = UDim2.fromOffset(200,18)
pingText.BackgroundTransparency = 1
pingText.Font = Enum.Font.Gotham
pingText.TextSize = 13
pingText.TextColor3 = Color3.fromRGB(200,200,200)
pingText.Text = "Ping: 0 ms"

local timeText = Instance.new("TextLabel")
timeText.Parent = main
timeText.Position = UDim2.fromOffset(12,76)
timeText.Size = UDim2.fromOffset(200,18)
timeText.BackgroundTransparency = 1
timeText.Font = Enum.Font.Gotham
timeText.TextSize = 13
timeText.TextColor3 = Color3.fromRGB(120,255,120)
timeText.Text = "Time: 0:0:0"

local hintText = Instance.new("TextLabel")
hintText.Parent = main
hintText.Position = UDim2.fromOffset(12,96)
hintText.Size = UDim2.fromOffset(200,16)
hintText.BackgroundTransparency = 1
hintText.Font = Enum.Font.Gotham
hintText.TextSize = 11
hintText.TextColor3 = Color3.fromRGB(150,150,150)
hintText.Text = "Press H to Hide / Show"

local dragging, dragStart, startPos

main.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local showing = true
local tweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

local function hide()
	showing = false
	TweenService:Create(scale,tweenInfo,{Scale = 0.8}):Play()
	TweenService:Create(main,tweenInfo,{BackgroundTransparency = 1}):Play()
	task.wait(0.2)
	main.Visible = false
end

local function show()
	main.Visible = true
	scale.Scale = 0.8
	main.BackgroundTransparency = 1
	showing = true
	TweenService:Create(scale,tweenInfo,{Scale = 1}):Play()
	TweenService:Create(main,tweenInfo,{BackgroundTransparency = 0}):Play()
end

UserInputService.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.H then
		if showing then hide() else show() end
	end
end)

lp.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

local fpsSamples = {}

RunService.RenderStepped:Connect(function(dt)
	table.insert(fpsSamples,1,dt)
	if #fpsSamples > 60 then table.remove(fpsSamples) end
	local total = 0
	for _,v in ipairs(fpsSamples) do total += v end
	fpsText.Text = "FPS: "..math.floor(#fpsSamples / total)
end)

task.spawn(function()
	while getgenv().AntiAfkV6 do
		local net = Stats:FindFirstChild("Network")
		if net and net:FindFirstChild("ServerStatsItem") then
			pingText.Text = "Ping: "..math.floor(net.ServerStatsItem["Data Ping"]:GetValue()).." ms"
		end
		task.wait(1)
	end
end)

local s,m,h = 0,0,0
task.spawn(function()
	while getgenv().AntiAfkV6 do
		task.wait(1)
		s += 1
		if s >= 60 then s = 0 m += 1 end
		if m >= 60 then m = 0 h += 1 end
		timeText.Text = "Time: "..h..":"..m..":"..s
	end
end)
