-- 🌌 NovaX Executer (Ultimate Edition v1.3 Refined++ by Ратмир)
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
local HistoryLabel = Instance.new("TextLabel")

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

-- === CLOSE ===
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

-- === HISTORY ===
HistoryLabel.Size = UDim2.new(1, -20, 0, 25)
HistoryLabel.Position = UDim2.new(0, 10, 1, -80)
HistoryLabel.BackgroundTransparency = 1
HistoryLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
HistoryLabel.Font = Enum.Font.Code
HistoryLabel.TextSize = 14
HistoryLabel.TextXAlignment = Enum.TextXAlignment.Left
HistoryLabel.Text = "History: (none yet)"
HistoryLabel.Parent = Frame

-- === TOGGLE BUTTON ===
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0.5, -22, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.Text = "🔰"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.Visible = false
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

local themes = {
    ["Dark"] = {frame = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(0, 255, 255)},
    ["Neon"] = {frame = Color3.fromRGB(10, 10, 30), accent = Color3.fromRGB(255, 0, 255)},
    ["Ice"]  = {frame = Color3.fromRGB(30, 40, 50), accent = Color3.fromRGB(150, 255, 255)}
}

local currentTheme = "Dark"
local yPos = 30
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
    end)
    yPos += 30
end

-- === TAB SYSTEM ===
local tabs = {}
local currentTab = nil
local tabCount = 1

-- Tab buttons container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = Frame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.FillDirection = Enum.FillDirection.Horizontal
tabListLayout.Padding = UDim.new(0, 5)
tabListLayout.Parent = tabContainer

-- Add Tab button
local addTabButton = Instance.new("TextButton")
addTabButton.Size = UDim2.new(0, 35, 0, 30)
addTabButton.Text = "+"
addTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
addTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addTabButton.Font = Enum.Font.SourceSansBold
addTabButton.TextSize = 18
addTabButton.Parent = tabContainer
Instance.new("UICorner", addTabButton)

-- Adjust ScriptBox position
ScriptBox.Position = UDim2.new(0, 10, 0, 85)
ScriptBox.Size = UDim2.new(1, -20, 1, -155)

-- Adjust History position
HistoryLabel.Position = UDim2.new(0, 10, 1, -110)

-- Tab class
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    
    self.name = name or "Tab " .. tabCount  
    self.script = "-- Enter Lua code here"  
    self.id = tabCount  
    
    -- Create tab button  
    self.button = Instance.new("TextButton")  
    self.button.Size = UDim2.new(0, 80, 0, 30)  
    self.button.Text = self.name  
    self.button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
    self.button.TextColor3 = Color3.fromRGB(200, 200, 200)  
    self.button.Font = Enum.Font.SourceSans  
    self.button.TextSize = 14  
    self.button.Parent = tabContainer  
    Instance.new("UICorner", self.button)  
    
    -- Close button for tab  
    self.closeButton = Instance.new("TextButton")  
    self.closeButton.Size = UDim2.new(0, 20, 0, 20)  
    self.closeButton.Position = UDim2.new(1, -25, 0, 5)  
    self.closeButton.Text = "×"  
    self.closeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
    self.closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
    self.closeButton.Font = Enum.Font.SourceSansBold  
    self.closeButton.TextSize = 16  
    self.closeButton.Visible = false  
    self.closeButton.ZIndex = 2  
    self.closeButton.Parent = self.button  
    Instance.new("UICorner", self.closeButton)  
    
    -- Connect events  
    self.button.MouseButton1Click:Connect(function()  
        self:select()  
    end)  
    
    self.closeButton.MouseButton1Click:Connect(function()  
        self:close()  
    end)  
    
    -- Hover effects  
    self.button.MouseEnter:Connect(function()  
        if self ~= currentTab then  
            TweenService:Create(self.button, TweenInfo.new(0.2), {  
                BackgroundColor3 = Color3.fromRGB(70, 70, 70)  
            }):Play()  
        end  
        self.closeButton.Visible = true  
    end)  
    
    self.button.MouseLeave:Connect(function()  
        if self ~= currentTab then  
            TweenService:Create(self.button, TweenInfo.new(0.2), {  
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
            }):Play()  
        end  
        self.closeButton.Visible = false  
    end)  
    
    tabCount = tabCount + 1  
    return self
end

function Tab:select()
    if currentTab then
        -- Save current tab's script
        currentTab.script = ScriptBox.Text

        -- Deselect current tab  
        TweenService:Create(currentTab.button, TweenInfo.new(0.2), {  
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),  
            TextColor3 = Color3.fromRGB(200, 200, 200)  
        }):Play()  
    end  
    
    -- Select this tab  
    currentTab = self  
    ScriptBox.Text = self.script  
    
    TweenService:Create(self.button, TweenInfo.new(0.2), {  
        BackgroundColor3 = Color3.fromRGB(0, 120, 215),  
        TextColor3 = Color3.fromRGB(255, 255, 255)  
    }):Play()  
    
    playClick()
end

function Tab:close()
    if #tabs <= 1 then return end -- Don't close last tab

    playClick()  
    
    -- Find tab index  
    local index = table.find(tabs, self)  
    if index then  
        table.remove(tabs, index)  
    end  
    
    -- Remove UI elements  
    self.button:Destroy()  
    
    -- If closing current tab, select another one  
    if self == currentTab then  
        if index and tabs[index] then  
            tabs[index]:select()  
        else  
            tabs[#tabs]:select()  
        end  
    end
end

function Tab:rename(newName)
    self.name = newName
    self.button.Text = newName
end

-- Create first tab
local function createInitialTab()
    local tab = Tab.new("Main")
    table.insert(tabs, tab)
    tab:select()
end

-- Add Tab button functionality
addTabButton.MouseButton1Click:Connect(function()
    playClick()

    local newTab = Tab.new("Tab " .. tabCount)  
    table.insert(tabs, newTab)  
    newTab:select()
end)

-- Tab animations
addTabButton.MouseEnter:Connect(function()
    TweenService:Create(addTabButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 80, 80),
        Size = UDim2.new(0, 40, 0, 32)
    }):Play()
end)

addTabButton.MouseLeave:Connect(function()
    TweenService:Create(addTabButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(0, 35, 0, 30)
    }):Play()
end)

-- Initialize tabs
createInitialTab()

-- Auto-save for tabs
if writefile and readfile then
    local tabsDataPath = "NovaX_Tabs.txt"

    -- Save tabs on close  
    game:GetService("UserInputService").WindowFocusReleased:Connect(function()  
        pcall(function()  
            local tabsData = {}  
            for _, tab in pairs(tabs) do  
                table.insert(tabsData, {  
                    name = tab.name,  
                    script = tab.script  
                })  
            end  
            writefile(tabsDataPath, game:GetService("HttpService"):JSONEncode(tabsData))  
        end)  
    end)  
    
    -- Load tabs on start  
    pcall(function()  
        local saved = readfile(tabsDataPath)  
        local tabsData = game:GetService("HttpService"):JSONDecode(saved)  
        
        if tabsData and #tabsData > 0 then  
            -- Clear initial tab  
            for _, tab in pairs(tabs) do  
                tab.button:Destroy()  
            end  
            tabs = {}  
            
            -- Load saved tabs  
            for i, tabData in ipairs(tabsData) do  
                local tab = Tab.new(tabData.name)  
                tab.script = tabData.script  
                table.insert(tabs, tab)  
                
                if i == 1 then  
                    tab:select()  
                end  
            end  
        end  
    end)
end

-- === SOUND EFFECTS ===
local clickSound = Instance.new("Sound", ScreenGui)
clickSound.SoundId = "rbxassetid://9118823106"
clickSound.Volume = 1.0

local successSound = Instance.new("Sound", ScreenGui)
successSound.SoundId = "rbxassetid://6026984224"

local errorSound = Instance.new("Sound", ScreenGui)
errorSound.SoundId = "rbxassetid://6026984222"

local function playClick() 
    if clickSound then 
        clickSound:Play() 
    end 
end

local function playSuccess() 
    if successSound then 
        successSound:Play() 
    end 
end

local function playError() 
    if errorSound then 
        errorSound:Play() 
    end 
end

-- === HISTORY HANDLING ===
local history = {}
local function addHistory(entry)
    table.insert(history, 1, entry)
    if #history > 5 then table.remove(history, 6) end
    HistoryLabel.Text = "History: " .. table.concat(history, " | ")
end

-- === AUTO SAVE ===
local scriptPath = "NovaX_LastScript.txt"
if writefile and readfile then
    pcall(function() 
        if isfile and isfile(scriptPath) then
            ScriptBox.Text = readfile(scriptPath) 
        end
    end)
    ScriptBox:GetPropertyChangedSignal("Text"):Connect(function()
        pcall(function() 
            writefile(scriptPath, ScriptBox.Text) 
        end)
    end)
end

-- === EXECUTE BUTTON (ИСПРАВЛЕННЫЙ) ===
Execute.MouseButton1Click:Connect(function()
    playClick()
    
    -- Сохраняем скрипт текущей вкладки
    if currentTab then
        currentTab.script = ScriptBox.Text
    end
    
    local code = ScriptBox.Text
    Execute.Text = "⏳ Running..."
    
    task.wait(0.3)
    
    local func, err = loadstring(code)
    if func then
        local ok, result = pcall(func)
        if ok then
            playSuccess()
            Execute.Text = "✅ Done!"
            addHistory("Success")
        else
            playError()
            Execute.Text = "⚠️ Runtime error"
            warn("Runtime Error: " .. tostring(result))
            addHistory("Error: " .. tostring(result))
        end
    else
        playError()
        Execute.Text = "❌ Syntax error"
        warn("Syntax Error: " .. tostring(err))
        addHistory("Error: " .. tostring(err))
    end
    
    task.wait(1)
    Execute.Text = "▶ Execute"
end)

-- === CLEAR BUTTON ===
Clear.MouseButton1Click:Connect(function()
    playClick()
    ScriptBox.Text = ""
end)

-- === SETTINGS TOGGLE ===
SettingsButton.MouseButton1Click:Connect(function()
    playClick()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

-- === CLOSE ANIMATION ===
Close.MouseButton1Click:Connect(function()
    playClick()
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
    playClick()
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- === DRAGGING TOGGLE ===
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

-- === BUTTON HOVER EFFECTS ===
local function animateButton(button, hover)
    local targetColor = hover and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(0, 170, 255)
    local scaleValue = hover and 1.05 or 1
    local scaleObj = button:FindFirstChild("UIScale") or Instance.new("UIScale", button)
    local stroke = button:FindFirstChild("UIStroke") or Instance.new("UIStroke", button)
    stroke.Thickness = 2
    stroke.Transparency = hover and 0.5 or 1
    stroke.Color = targetColor
    TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(scaleObj, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Scale = scaleValue}):Play()
end

Execute.MouseEnter:Connect(function() animateButton(Execute, true) end)
Execute.MouseLeave:Connect(function() animateButton(Execute, false) end)
Clear.MouseEnter:Connect(function() animateButton(Clear, true) end)
Clear.MouseLeave:Connect(function() animateButton(Clear, false) end)

print("NovaX Executer loaded successfully! Click the toggle button to open.")
