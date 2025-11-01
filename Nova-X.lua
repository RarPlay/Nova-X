-- 🌌 NovaX Executer (Ultimate Edition v1.3 Refined++ by Ратмир)
print([[
  
  _   _                  __   __
 | \ | |                 \ \ / /
 |  \| | _____   ____ _   \ V / 
 | . ` |/ _ \ \ / / _` |   | |  
 | |\  | (_) \ V / (_| |  / ^ \ 
 |_| \_|\___/ \_/ \__,_| /_/ \_\
]])
print("[NovaX] Nova X start!")

game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "NovaX",
Text = "Hac4ing Successfully!",
Duration = 5
})

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- === ELEMENTS ===
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Close = Instance.new("TextButton")
local Execute = Instance.new("TextButton")
local Clear = Instance.new("TextButton")
local ScriptBox = Instance.new("TextBox")
local ToggleButton = Instance.new("TextButton")
local SettingsButton = Instance.new("TextButton")
local SettingsFrame = Instance.new("Frame")
local ThemeLabel = Instance.new("TextLabel")
local SplashImage = Instance.new("ImageLabel")

ScreenGui.Name = "NovaX_UI"
local parentGui = (gethui and gethui()) 
    or (game:FindFirstChildOfClass("CoreGui")) 
    or (game.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")) 
    or (Instance.new("ScreenGui"))

ScreenGui.Parent = parentGui 
local sysPath = "Nova-X-sys"
ScreenGui.Parent = parentGui

-- === SPLASH IMAGE ===
SplashImage.Size = UDim2.new(0, 200, 0, 200)
SplashImage.Position = UDim2.new(0.5, -100, 0.5, -100)
SplashImage.BackgroundTransparency = 1
SplashImage.Image = "rbxassetid://1316045217"
SplashImage.Parent = ScreenGui

task.spawn(function()
TweenService:Create(SplashImage, TweenInfo.new(1), {Size = UDim2.new(0, 300, 0, 300)}):Play()
task.wait(1)
TweenService:Create(SplashImage, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
task.wait(0.5)
SplashImage:Destroy()
end)

-- === MAIN FRAME ===
Frame.Size = UDim2.new(0, 420, 0, 320)
Frame.Position = UDim2.new(0.5, -210, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Active = true
Frame.Parent = ScreenGui

-- === SHADOW ===
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.5
shadow.ZIndex = 0
shadow.Parent = Frame

-- === TITLE BAR ===
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

Title.Text = "NovaX"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- === SETTINGS BUTTON ===
SettingsButton.Text = "⚙️"
SettingsButton.Size = UDim2.new(0, 40, 0, 40)
SettingsButton.Position = UDim2.new(1, -80, 0, 0)
SettingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.Font = Enum.Font.SourceSansBold
SettingsButton.TextSize = 20
SettingsButton.Parent = TitleBar

-- === CLOSE BUTTON ===
Close.Text = "X"
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 22
Close.Parent = TitleBar

-- === SCRIPT BOX ===
ScriptBox.Size = UDim2.new(1, -20, 1, -120)
ScriptBox.Position = UDim2.new(0, 10, 0, 50)
ScriptBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScriptBox.TextColor3 = Color3.fromRGB(0, 255, 0)
ScriptBox.TextStrokeTransparency = 0.8
ScriptBox.MultiLine = true
ScriptBox.ClearTextOnFocus = false
ScriptBox.Text = "-- Enter Lua code here"
ScriptBox.Font = Enum.Font.Code
ScriptBox.TextSize = 16
ScriptBox.Parent = Frame

-- === BUTTONS ===
Execute.Text = "▶ Execute"
Execute.Size = UDim2.new(0, 120, 0, 35)
Execute.Position = UDim2.new(0, 40, 1, -45)
Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Execute.TextColor3 = Color3.fromRGB(255, 255, 255)
Execute.Font = Enum.Font.SourceSansBold
Execute.TextSize = 18
Execute.Parent = Frame

Clear.Text = "🧹 Clear"
Clear.Size = UDim2.new(0, 120, 0, 35)
Clear.Position = UDim2.new(1, -160, 1, -45)
Clear.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
Clear.TextColor3 = Color3.fromRGB(255, 255, 255)
Clear.Font = Enum.Font.SourceSansBold
Clear.TextSize = 18
Clear.Parent = Frame

-- === TOGGLE BUTTON ===
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0.5, -22, 0.5, -22)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.Text = "🪐"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

-- === SETTINGS PANEL ===
SettingsFrame.Size = UDim2.new(0, 150, 0, 100)
SettingsFrame.Position = UDim2.new(1, -160, 0, 45)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.Visible = false
SettingsFrame.Parent = Frame
Instance.new("UICorner", SettingsFrame)

ThemeLabel.Size = UDim2.new(1, 0, 0, 30)
ThemeLabel.Text = "🎨 Theme:"
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeLabel.Font = Enum.Font.SourceSansBold
ThemeLabel.TextSize = 16
ThemeLabel.Parent = SettingsFrame

-- === THEMES ===
local themes = {
["Dark"] = {frame = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(0, 255, 255)},
["Neon"] = {frame = Color3.fromRGB(10, 10, 30), accent = Color3.fromRGB(255, 0, 255)},
["Ice"]  = {frame = Color3.fromRGB(30, 40, 50), accent = Color3.fromRGB(150, 255, 255)}
}

local currentTheme = "Dark"
local yPos = 30
local themePath = "Nova-X-sys/Theme.txt"
local logPath = "Nova-X-sys/ExecutionLog.txt"

-- === GLOBAL CONSOLE LOGGER (NovaX Monitoring System v2.1 Persistent) ===
local logPath = sysPath .. "/ExecutionLog.txt"
if writefile and readfile and appendfile then
    pcall(function()
        if not isfolder(sysPath) then
            makefolder(sysPath)
        end
        if not isfile(logPath) then
            writefile(logPath, "")
        end
    end)

    local function writeLog(tag, msg)
        local time = os.date("[%Y-%m-%d %H:%M:%S]")
        local line = string.format("%s [%s] %s\n", time, tag, tostring(msg))
        appendfile(logPath, line)
    end

    -- перехватываем стандартные функции
    local oldPrint = print
    local oldWarn = warn
    local oldError = error

    function print(...)
        local msg = table.concat({...}, " ")
        writeLog("PRINT", msg)
        oldPrint(...)
    end

    function warn(...)
        local msg = table.concat({...}, " ")
        writeLog("WARN", msg)
        oldWarn(...)
    end

    function error(...)
        local msg = table.concat({...}, " ")
        writeLog("ERROR", msg)
        oldError(...)
    end

    writeLog("SYSTEM", "NovaX Logger initialized (persistent mode).")
else
    warn("[NovaX] Logging unavailable: missing writefile/appendfile support.")
end 

if isfile(themePath) then
local savedTheme = readfile(themePath)
if themes[savedTheme] then
currentTheme = savedTheme
Frame.BackgroundColor3 = themes[savedTheme].frame
Title.TextColor3 = themes[savedTheme].accent
    end
end

for name, _ in pairs(themes) do
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -10, 0, 25)
btn.Position = UDim2.new(0, 5, 0, yPos)
btn.Text = name
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.SourceSans
btn.TextSize = 16
btn.Parent = SettingsFrame
Instance.new("UICorner", btn)
btn.MouseButton1Click:Connect(function()
currentTheme = name
Frame.BackgroundColor3 = themes[name].frame
Title.TextColor3 = themes[name].accent
if writefile then writefile(themePath, name) end
end)
yPos += 30
end

-- === EXECUTE BUTTON ===
Execute.MouseButton1Click:Connect(function()
local code = ScriptBox.Text
Execute.Text = "⏳ Running..."
task.wait(0.3)
local loader = loadstring or load          -- используем то, что есть
if not loader then
    warn("[NovaX] Your executor does not support loadstring or load.")
    Execute.Text = "❌ Unsupported"
    return
end

local func, err = loader(code)
if func then
local ok, result = pcall(func)
if ok then
Execute.Text = "✅ Done!"
if writefile then writefile(logPath, (readfile(logPath) or "") .. os.date().." | Success\n") end
else
Execute.Text = "⚠️ Runtime error"
warn(result)
if writefile then writefile(logPath, (readfile(logPath) or "") .. os.date().." | Runtime error: "..tostring(result).."\n") end
end
else
Execute.Text = "❌ Syntax error"
warn(err)
if writefile then writefile(logPath, (readfile(logPath) or "") .. os.date().." | Syntax error: "..tostring(err).."\n") end
end
task.wait(1)
Execute.Text = "▶ Execute"
end)

-- === CLEAR BUTTON ===
Clear.MouseButton1Click:Connect(function()
ScriptBox.Text = ""
end)

-- === SETTINGS TOGGLE ===
SettingsButton.MouseButton1Click:Connect(function()
SettingsFrame.Visible = not SettingsFrame.Visible
end)

-- === CLOSE ANIMATION ===
Close.MouseButton1Click:Connect(function()
local tween = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset, Frame.Position.Y.Scale, Frame.Position.Y.Offset - 200),
BackgroundTransparency = 1
})
tween:Play()
task.wait(0.4)
Frame.Visible = false
ToggleButton.Visible = true
end)

-- === TOGGLE OPEN ===
ToggleButton.MouseButton1Click:Connect(function()
ToggleButton.Visible = false
Frame.Visible = true
Frame.Position = UDim2.new(0.5, -210, 0.5, -200)
TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
Position = UDim2.new(0.5, -210, 0.5, -160),
BackgroundTransparency = 0
}):Play()
end)

-- === DRAGGING FRAME ===
local dragging, dragStart, startPos
Frame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 and not Close:IsMouseOver() then
dragging = true
dragStart = input.Position
startPos = Frame.Position
end
end)
UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
local delta = input.Position - dragStart
Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- === DRAGGING TOGGLE BUTTON ===
local draggingToggle = false
local toggleStart, togglePos
ToggleButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
draggingToggle = true
toggleStart = input.Position
togglePos = ToggleButton.Position
end
end)
UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement and draggingToggle then
local delta = input.Position - toggleStart
ToggleButton.Position = UDim2.new(togglePos.X.Scale, togglePos.X.Offset + delta.X, togglePos.Y.Scale, togglePos.Y.Offset + delta.Y)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingToggle = false end
end)

-- ⚙️ функции сохранения и загрузки позиции
local HttpService = game:GetService("HttpService")

local function saveButtonPosition(button)
	if not writefile then return end
	local data = {
		X = button.Position.X.Scale,
		Y = button.Position.Y.Scale,
		XO = button.Position.X.Offset,
		YO = button.Position.Y.Offset
	}
	writefile(button.Name .. "_pos.json", HttpService:JSONEncode(data))
end

local function loadButtonPosition(button)
	if not readfile or not isfile then return end
	if isfile(button.Name .. "_pos.json") then
		local raw = readfile(button.Name .. "_pos.json")
		local data = HttpService:JSONDecode(raw)
		button.Position = UDim2.new(data.X, data.XO, data.Y, data.YO)
	end
end

local function makeDraggable(button)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = button.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					saveButtonPosition(button)
				end
			end)
		end
	end)

	button.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- 🌌 NovaMore основная кнопка
local NovaMoreButton = Instance.new("TextButton")
NovaMoreButton.Name = "NovaMoreButton"
NovaMoreButton.Text = "NovaMore"
NovaMoreButton.Size = UDim2.new(0, 120, 0, 40)
NovaMoreButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
NovaMoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NovaMoreButton.Position = UDim2.new(0.5, -60, 0.5, 60)
NovaMoreButton.Parent = ScreenGui

makeDraggable(NovaMoreButton)
loadButtonPosition(NovaMoreButton)

-- 🪐 меню NovaMore
local NovaMoreFrame = Instance.new("Frame")
NovaMoreFrame.Name = "NovaMoreFrame"
NovaMoreFrame.Size = UDim2.new(0, 250, 0, 180)
NovaMoreFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
NovaMoreFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
NovaMoreFrame.Visible = false
NovaMoreFrame.Parent = ScreenGui

-- ❌ кнопка закрытия меню
local CloseNovaMore = Instance.new("TextButton")
CloseNovaMore.Name = "CloseNovaMore"
CloseNovaMore.Text = "✖"
CloseNovaMore.Size = UDim2.new(0, 30, 0, 30)
CloseNovaMore.Position = UDim2.new(1, -35, 0, 5)
CloseNovaMore.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseNovaMore.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseNovaMore.Parent = NovaMoreFrame

-- 💡 Кнопка Infinite Yield
local InfiniteYieldButton = Instance.new("TextButton")
InfiniteYieldButton.Text = "⚙️ Infinite Yield"
InfiniteYieldButton.Size = UDim2.new(0, 200, 0, 35)
InfiniteYieldButton.Position = UDim2.new(0.5, -100, 0, 50)
InfiniteYieldButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
InfiniteYieldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteYieldButton.Parent = NovaMoreFrame

-- 💫 Кнопка SPIN ALL
local SpinAllButton = Instance.new("TextButton")
SpinAllButton.Text = "🌀 Spin All"
SpinAllButton.Size = UDim2.new(0, 200, 0, 35)
SpinAllButton.Position = UDim2.new(0.5, -100, 0, 95)
SpinAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
SpinAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinAllButton.Parent = NovaMoreFrame

-- 🏭 Кнопка сброса
local FactoryResetButton = Instance.new("TextButton")
FactoryResetButton.Text = "🏭 To Factory"
FactoryResetButton.Size = UDim2.new(0, 200, 0, 35)
FactoryResetButton.Position = UDim2.new(0.5, -100, 0, 140)
FactoryResetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
FactoryResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FactoryResetButton.Parent = NovaMoreFrame

-- 🔘 логика кнопок
NovaMoreButton.MouseButton1Click:Connect(function()
	NovaMoreFrame.Visible = not NovaMoreFrame.Visible
end)

CloseNovaMore.MouseButton1Click:Connect(function()
	NovaMoreFrame.Visible = false
end)

InfiniteYieldButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

SpinAllButton.MouseButton1Click:Connect(function()
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	task.spawn(function()
		while task.wait(60) do
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					for i = 1, 120 do
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(i * 30), 0)
							task.wait(0.05)
						end
					end
				end
			end
		end
	end)
end)

FactoryResetButton.MouseButton1Click:Connect(function()
	for _, file in ipairs({"NovaMoreButton_pos.json"}) do
		if isfile and isfile(file) then delfile(file) end
	end
	NovaMoreFrame.Visible = false
	NovaMoreButton.Position = UDim2.new(0.5, -60, 0.5, 60)
	saveButtonPosition(NovaMoreButton)
end)


-- === SYSTEM INTEGRITY WATCHDOG ===
task.spawn(function()
while task.wait(1) do -- каждые 2 секунды проверка
if not isfolder(sysPath) then
warn("[NovaX][CRITICAL] System directory missing. Self-termination initiated.")
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "NovaX Security",
Text = "System directory missing. Terminating...",
Duration = 5
})
task.wait(4)
Frame:Destroy()
ToggleButton:Destroy()
warn("[NovaX] Terminated due to integrity failure.")
break
end
end
end)

