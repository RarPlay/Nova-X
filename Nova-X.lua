-- 🌌 NovaX Executer (Ultimate Edition v1.1 Refined by Ратмир)
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

ScreenGui.Name = "NovaX_UI"
ScreenGui.Parent = game.CoreGui

-- === MAIN FRAME ===
Frame.Size = UDim2.new(0, 420, 0, 320)
Frame.Position = UDim2.new(0.5, -210, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = true
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

-- === SHADOW EFFECT ===
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

Title.Text = "NovaX Executer ⚙️"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

Close.Text = "X"
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 22
Close.Parent = TitleBar

-- === SCRIPT BOX ===
ScriptBox.Size = UDim2.new(1, -20, 1, -100)
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
ToggleButton.Position = UDim2.new(0.5, -22, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.Text = "⚙️"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = ToggleButton

-- === SOUND EFFECT ===
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://9118823106"
clickSound.Volume = 0.5
clickSound.Parent = ScreenGui

local function playClick()
	clickSound:Play()
end

-- === FADE EFFECTS ===
local function FadeIn(frame)
	frame.Visible = true
	frame.BackgroundTransparency = 1
	for i = 1, 0, -0.1 do
		frame.BackgroundTransparency = i
		task.wait(0.03)
	end
end

local function FadeOut(frame)
	for i = 0, 1, 0.1 do
		frame.BackgroundTransparency = i
		task.wait(0.03)
	end
	frame.Visible = false
end

-- === BUTTON LOGIC ===
Execute.MouseButton1Click:Connect(function()
	playClick()
	local code = ScriptBox.Text
	Execute.Text = "⏳ Running..."
	task.wait(0.5)
	local func, err = loadstring(code)
	if func then
		func()
		Execute.Text = "✅ Done!"
	else
		Execute.Text = "❌ Error"
		warn("[NovaX] Error:\n"..err)
	end
	task.wait(1)
	Execute.Text = "▶ Execute"
end)

Clear.MouseButton1Click:Connect(function()
	playClick()
	ScriptBox.Text = ""
end)

Close.MouseButton1Click:Connect(function()
	playClick()
	TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 0, 0),
		Transparency = 1
	}):Play()
	task.wait(0.3)
	Frame.Visible = false
	ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
	playClick()
	ToggleButton.Visible = false
	FadeIn(Frame)
	Frame.Size = UDim2.new(0, 420, 0, 320)
	TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
end)

-- === DRAGGING ===
local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
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
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- === ANIMATION EFFECTS ===
local function animateButton(button, hover)
	local targetColor = hover and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(0, 170, 255)
	local scaleValue = hover and 1.05 or 1

	local scaleObj = button:FindFirstChild("UIScale") or Instance.new("UIScale", button)

	TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		BackgroundColor3 = targetColor
	}):Play()

	TweenService:Create(scaleObj, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Scale = scaleValue
	}):Play()

	if button == Execute then
		Title.TextColor3 = hover and Color3.fromRGB(64, 248, 64) or Color3.fromRGB(0, 255, 255)
	end
end

Execute.MouseEnter:Connect(function() animateButton(Execute, true) end)
Execute.MouseLeave:Connect(function() animateButton(Execute, false) end)
Clear.MouseEnter:Connect(function() animateButton(Clear, true) end)
Clear.MouseLeave:Connect(function() animateButton(Clear, false) end)

-- === ScriptBox Highlight Animation ===
ScriptBox.Focused:Connect(function()
	TweenService:Create(ScriptBox, TweenInfo.new(0.3), {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	}):Play()
end)

ScriptBox.FocusLost:Connect(function()
	TweenService:Create(ScriptBox, TweenInfo.new(0.3), {
		BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	}):Play()
end)
