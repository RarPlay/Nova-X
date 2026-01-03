-- 2.5
-- Don't touch anything, it will break.
print("[NovaX] Nova X start!")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NovaX",
    Text = "Loading Successfully!",
    Duration = 5
})

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentGui = (gethui and gethui())
    or (game:FindFirstChildOfClass("CoreGui"))
    or (game.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    or (Instance.new("ScreenGui"))

ScreenGui.Parent = parentGui
local sysPath = "Nova-X-sys"

SplashImage.Size = UDim2.new(0, 200, 0, 200)
SplashImage.Position = UDim2.new(0.5, -100, 0.5, -100)
SplashImage.BackgroundTransparency = 1
SplashImage.Image = "rbxassetid://1316045217"
SplashImage.ZIndex = 10
SplashImage.Parent = ScreenGui

task.spawn(function()
    TweenService:Create(SplashImage, TweenInfo.new(1), {Size = UDim2.new(0, 300, 0, 300)}):Play()
    task.wait(1)
    TweenService:Create(SplashImage, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    task.wait(0.5)
    SplashImage:Destroy()
end)

Frame.Size = UDim2.new(0, 420, 0, 320)
Frame.Position = UDim2.new(0.5, -210, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ImageTransparency = 0.5
shadow.ZIndex = -1
shadow.Parent = Frame

TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = Frame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

Title.Text = "NovaX"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = TitleBar

SettingsButton.Text = "⚙️"
SettingsButton.Size = UDim2.new(0, 40, 0, 40)
SettingsButton.Position = UDim2.new(1, -80, 0, 0)
SettingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.Font = Enum.Font.SourceSansBold
SettingsButton.TextSize = 20
SettingsButton.ZIndex = 3
SettingsButton.Parent = TitleBar

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 8)
SettingsCorner.Parent = SettingsButton

Close.Text = "X"
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 22
Close.ZIndex = 3
Close.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

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
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.Parent = Frame

local ScriptBoxCorner = Instance.new("UICorner")
ScriptBoxCorner.CornerRadius = UDim.new(0, 6)
ScriptBoxCorner.Parent = ScriptBox

Execute.Text = "▶ Execute"
Execute.Size = UDim2.new(0, 120, 0, 35)
Execute.Position = UDim2.new(0, 40, 1, -45)
Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Execute.TextColor3 = Color3.fromRGB(255, 255, 255)
Execute.Font = Enum.Font.SourceSansBold
Execute.TextSize = 18
Execute.Parent = Frame

local ExecuteCorner = Instance.new("UICorner")
ExecuteCorner.CornerRadius = UDim.new(0, 8)
ExecuteCorner.Parent = Execute

Clear.Text = "🧹 Clear"
Clear.Size = UDim2.new(0, 120, 0, 35)
Clear.Position = UDim2.new(1, -160, 1, -45)
Clear.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
Clear.TextColor3 = Color3.fromRGB(255, 255, 255)
Clear.Font = Enum.Font.SourceSansBold
Clear.TextSize = 18
Clear.Parent = Frame

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 8)
ClearCorner.Parent = Clear

ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.Text = "🪐"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

SettingsFrame.Size = UDim2.new(0, 150, 0, 160)
SettingsFrame.Position = UDim2.new(1, -160, 0, 45)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 5
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
local themePath = sysPath .. "/Theme.txt"
local logPath = sysPath .. "/ExecutionLog.txt"

-- === FILE SYSTEM SETUP ===
if writefile and readfile and makefolder and isfolder and isfile then
    pcall(function()
        if not isfolder(sysPath) then
            makefolder(sysPath)
        end
        if not isfile(logPath) then
            writefile(logPath, "NovaX Execution Log\n")
        end
    end)
end

local function writeLog(tag, msg)  
    if not writefile or not appendfile then return end
    
    local time = os.date("[%Y-%m-%d %H:%M:%S]")  
    local line = string.format("%s [%s] %s\n", time, tag, tostring(msg))  
    
    pcall(function()
        appendfile(logPath, line)  
    end)
end

if writefile and readfile then
    local oldPrint = print  
    local oldWarn = warn  
    local oldError = error  

    print = function(...)  
        local msg = table.concat({...}, " ")  
        writeLog("PRINT", msg)  
        oldPrint(...)  
    end  

    warn = function(...)  
        local msg = table.concat({...}, " ")  
        writeLog("WARN", msg)  
        oldWarn(...)  
    end  

    error = function(...)  
        local msg = table.concat({...}, " ")  
        writeLog("ERROR", msg)  
        oldError(...)  
    end  

    writeLog("SYSTEM", "NovaX Logger initialized (persistent mode).")
else
    warn("[NovaX] Logging unavailable: missing writefile/appendfile support.")
end

if readfile and isfile and isfile(themePath) then
    local success, savedTheme = pcall(function()
        return readfile(themePath)
    end)
    if success and themes[savedTheme] then
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
        if writefile then 
            pcall(function()
                writefile(themePath, name) 
            end)
        end
    end)
    yPos += 30
end

Execute.MouseButton1Click:Connect(function()
    local code = ScriptBox.Text
    if code == "" or code == "-- Enter Lua code here" then
        Execute.Text = "⚠️ Empty!"
        task.wait(1)
        Execute.Text = "▶ Execute"
        return
    end
    
    Execute.Text = "⏳ Running..."
    Execute.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    local loader = loadstring or load
    if not loader then
        warn("[NovaX] Your executor does not support loadstring or load.")
        Execute.Text = "❌ Unsupported"
        Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1)
        Execute.Text = "▶ Execute"
        Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        return
    end

    local func, err = loader(code)
    if func then
        local ok, result = pcall(func)
        if ok then
            Execute.Text = "✅ Done!"
            Execute.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            writeLog("SUCCESS", "Script executed successfully")
        else
            Execute.Text = "⚠️ Runtime error"
            Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            warn("[NovaX] Runtime error: " .. tostring(result))
            writeLog("RUNTIME_ERROR", result)
        end
    else
        Execute.Text = "❌ Syntax error"
        Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        warn("[NovaX] Syntax error: " .. tostring(err))
        writeLog("SYNTAX_ERROR", err)
    end
    
    task.wait(1.5)
    Execute.Text = "▶ Execute"
    Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

Clear.MouseButton1Click:Connect(function()
    ScriptBox.Text = ""
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

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

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = false
    Frame.Visible = true
    Frame.BackgroundTransparency = 0
    Frame.Position = UDim2.new(0.5, -210, 0.5, -200)
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -210, 0.5, -160),
        BackgroundTransparency = 0
    }):Play()
end)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local draggingToggle = false
local toggleStart, togglePos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = true
        toggleStart = input.Position
        togglePos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingToggle then
        local delta = input.Position - toggleStart
        ToggleButton.Position = UDim2.new(togglePos.X.Scale, togglePos.X.Offset + delta.X, togglePos.Y.Scale, togglePos.Y.Offset + delta.Y)
    end
end)

local function saveButtonPosition(button)
    if not writefile then return end
    local data = {
        X = button.Position.X.Scale,
        Y = button.Position.Y.Scale,
        XO = button.Position.X.Offset,
        YO = button.Position.Y.Offset
    }
    pcall(function()
        writefile(sysPath .. "/" .. button.Name .. "_pos.json", HttpService:JSONEncode(data))
    end)
end

local function loadButtonPosition(button)
    if not readfile or not isfile then return end
    pcall(function()
        local filePath = sysPath .. "/" .. button.Name .. "_pos.json"
        if isfile(filePath) then
            local raw = readfile(filePath)
            local data = HttpService:JSONDecode(raw)
            button.Position = UDim2.new(data.X, data.XO, data.Y, data.YO)
        end
    end)
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local NovaMoreButton = Instance.new("TextButton")
NovaMoreButton.Name = "NovaMoreButton"
NovaMoreButton.Text = "🧭"
NovaMoreButton.Size = UDim2.new(0, 45, 0, 45)
NovaMoreButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
NovaMoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NovaMoreButton.Font = Enum.Font.SourceSansBold
NovaMoreButton.TextSize = 20
NovaMoreButton.Position = UDim2.new(0, 20, 0, 80)
NovaMoreButton.ZIndex = 10
NovaMoreButton.Parent = ScreenGui

local NovaMoreCorner = Instance.new("UICorner")
NovaMoreCorner.CornerRadius = UDim.new(0, 10)
NovaMoreCorner.Parent = NovaMoreButton

makeDraggable(NovaMoreButton)
loadButtonPosition(NovaMoreButton)

local NovaMoreFrame = Instance.new("Frame")
NovaMoreFrame.Name = "NovaMoreFrame"
NovaMoreFrame.Size = UDim2.new(0, 250, 0, 180)
NovaMoreFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
NovaMoreFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
NovaMoreFrame.Visible = false
NovaMoreFrame.ZIndex = 15
NovaMoreFrame.Parent = ScreenGui

local NovaMoreFrameCorner = Instance.new("UICorner")
NovaMoreFrameCorner.CornerRadius = UDim.new(0, 12)
NovaMoreFrameCorner.Parent = NovaMoreFrame

local CloseNovaMore = Instance.new("TextButton")
CloseNovaMore.Name = "CloseNovaMore"
CloseNovaMore.Text = "✖"
CloseNovaMore.Size = UDim2.new(0, 30, 0, 30)
CloseNovaMore.Position = UDim2.new(1, -35, 0, 5)
CloseNovaMore.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseNovaMore.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseNovaMore.Font = Enum.Font.SourceSansBold
CloseNovaMore.TextSize = 16
CloseNovaMore.Parent = NovaMoreFrame

local CloseNovaMoreCorner = Instance.new("UICorner")
CloseNovaMoreCorner.CornerRadius = UDim.new(0, 8)
CloseNovaMoreCorner.Parent = CloseNovaMore

local InfiniteYieldButton = Instance.new("TextButton")
InfiniteYieldButton.Text = "⚙️ Infinite Yield"
InfiniteYieldButton.Size = UDim2.new(0, 200, 0, 35)
InfiniteYieldButton.Position = UDim2.new(0.5, -100, 0, 50)
InfiniteYieldButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
InfiniteYieldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteYieldButton.Font = Enum.Font.SourceSansBold
InfiniteYieldButton.TextSize = 16
InfiniteYieldButton.Parent = NovaMoreFrame

local IYCorner = Instance.new("UICorner")
IYCorner.CornerRadius = UDim.new(0, 8)
IYCorner.Parent = InfiniteYieldButton

local FactoryResetButton = Instance.new("TextButton")
FactoryResetButton.Text = "🔄 Factory Reset"
FactoryResetButton.Size = UDim2.new(0, 200, 0, 35)
FactoryResetButton.Position = UDim2.new(0.5, -100, 0, 100)
FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
FactoryResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FactoryResetButton.Font = Enum.Font.SourceSansBold
FactoryResetButton.TextSize = 16
FactoryResetButton.Parent = NovaMoreFrame

local FactoryCorner = Instance.new("UICorner")
FactoryCorner.CornerRadius = UDim.new(0, 8)
FactoryCorner.Parent = FactoryResetButton

NovaMoreButton.MouseButton1Click:Connect(function()
    NovaMoreFrame.Visible = not NovaMoreFrame.Visible
end)

CloseNovaMore.MouseButton1Click:Connect(function()
    NovaMoreFrame.Visible = false
end)

InfiniteYieldButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    if not success then
        warn("[NovaX] Failed to load Infinite Yield: " .. tostring(result))
    end
    NovaMoreFrame.Visible = false
end)

FactoryResetButton.MouseButton1Click:Connect(function()
    if FactoryResetButton.Text == "🔄 Factory Reset" then
        -- First click: show confirmation
        local confirmed = Instance.new("TextLabel")
        confirmed.Size = UDim2.new(1, -20, 0, 30)
        confirmed.Position = UDim2.new(0, 10, 0, 150)
        confirmed.BackgroundTransparency = 1
        confirmed.Text = "⚠️ This will delete all settings!"
        confirmed.TextColor3 = Color3.fromRGB(255, 100, 100)
        confirmed.Font = Enum.Font.SourceSansBold
        confirmed.TextSize = 14
        confirmed.Parent = NovaMoreFrame
        
        FactoryResetButton.Text = "❌ Confirm Reset"
        FactoryResetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- Schedule reset of button after 5 seconds if not confirmed
        task.delay(5, function()
            if FactoryResetButton.Text == "❌ Confirm Reset" then
                FactoryResetButton.Text = "🔄 Factory Reset"
                FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
                if confirmed and confirmed.Parent then
                    confirmed:Destroy()
                end
            end
        end)
    elseif FactoryResetButton.Text == "❌ Confirm Reset" then
        -- Second click: perform reset
        if writefile and delfile and isfolder then
            pcall(function()
                -- Clear logs
                if isfile(logPath) then
                    delfile(logPath)
                end
                -- Clear theme settings
                if isfile(themePath) then
                    delfile(themePath)
                end
                -- Clear saved positions
                local togglePosFile = sysPath .. "/ToggleButton_pos.json"
                local novaPosFile = sysPath .. "/NovaMoreButton_pos.json"
                
                if isfile(togglePosFile) then
                    delfile(togglePosFile)
                end
                if isfile(novaPosFile) then
                    delfile(novaPosFile)
                end
                
                -- Reset UI to defaults
                Frame.BackgroundColor3 = themes["Dark"].frame
                Title.TextColor3 = themes["Dark"].accent
                currentTheme = "Dark"
                ToggleButton.Position = UDim2.new(0, 20, 0, 20)
                NovaMoreButton.Position = UDim2.new(0, 20, 0, 80)
                
                FactoryResetButton.Text = "✅ Reset Complete!"
                FactoryResetButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                
                if writeLog then
                    writeLog("SYSTEM", "Factory reset performed")
                end
                
                task.wait(2)
                FactoryResetButton.Text = "🔄 Factory Reset"
                FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
            end)
        else
            -- Show error if file functions not available
            FactoryResetButton.Text = "❌ No Permission"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(2)
            FactoryResetButton.Text = "🔄 Factory Reset"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if writefile and readfile and isfolder then
            local folderExists = pcall(function()
                return isfolder(sysPath)
            end)
            
            if not folderExists then
                warn("[NovaX][CRITICAL] System directory missing. Self-termination initiated.")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "NovaX Security",
                    Text = "System directory missing. Terminating...",
                    Duration = 5
                })
                task.wait(4)
                ScreenGui:Destroy()
                warn("[NovaX] Terminated due to integrity failure.")
                break
            end
        end
    end
end)

print("[NovaX] Interface loaded successfully!")-- 2.5
-- Don't touch anything, it will break.

print([[


---
__   __                 __   __
| \ | |                 \ \ / /
|  \| | _____   ____ _   \ V / 
| . \ |/ _ \ \ / / _\ |   | |  
| |\  | (_) \ V / (| |   / . \ 
|_| \_|\___/ \_/ \__,_| /_/ \_\
]])
print("[NovaX] Nova X start!")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NovaX",
    Text = "Loading Successfully!",
    Duration = 5
})

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentGui = (gethui and gethui())
    or (game:FindFirstChildOfClass("CoreGui"))
    or (game.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    or (Instance.new("ScreenGui"))

ScreenGui.Parent = parentGui
local sysPath = "Nova-X-sys"

SplashImage.Size = UDim2.new(0, 200, 0, 200)
SplashImage.Position = UDim2.new(0.5, -100, 0.5, -100)
SplashImage.BackgroundTransparency = 1
SplashImage.Image = "rbxassetid://1316045217"
SplashImage.ZIndex = 10
SplashImage.Parent = ScreenGui

task.spawn(function()
    TweenService:Create(SplashImage, TweenInfo.new(1), {Size = UDim2.new(0, 300, 0, 300)}):Play()
    task.wait(1)
    TweenService:Create(SplashImage, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    task.wait(0.5)
    SplashImage:Destroy()
end)

Frame.Size = UDim2.new(0, 420, 0, 320)
Frame.Position = UDim2.new(0.5, -210, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ImageTransparency = 0.5
shadow.ZIndex = -1
shadow.Parent = Frame

TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = Frame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

Title.Text = "NovaX"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = TitleBar

SettingsButton.Text = "⚙️"
SettingsButton.Size = UDim2.new(0, 40, 0, 40)
SettingsButton.Position = UDim2.new(1, -80, 0, 0)
SettingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.Font = Enum.Font.SourceSansBold
SettingsButton.TextSize = 20
SettingsButton.ZIndex = 3
SettingsButton.Parent = TitleBar

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 8)
SettingsCorner.Parent = SettingsButton

Close.Text = "X"
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 22
Close.ZIndex = 3
Close.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

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
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.Parent = Frame

local ScriptBoxCorner = Instance.new("UICorner")
ScriptBoxCorner.CornerRadius = UDim.new(0, 6)
ScriptBoxCorner.Parent = ScriptBox

Execute.Text = "▶ Execute"
Execute.Size = UDim2.new(0, 120, 0, 35)
Execute.Position = UDim2.new(0, 40, 1, -45)
Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Execute.TextColor3 = Color3.fromRGB(255, 255, 255)
Execute.Font = Enum.Font.SourceSansBold
Execute.TextSize = 18
Execute.Parent = Frame

local ExecuteCorner = Instance.new("UICorner")
ExecuteCorner.CornerRadius = UDim.new(0, 8)
ExecuteCorner.Parent = Execute

Clear.Text = "🧹 Clear"
Clear.Size = UDim2.new(0, 120, 0, 35)
Clear.Position = UDim2.new(1, -160, 1, -45)
Clear.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
Clear.TextColor3 = Color3.fromRGB(255, 255, 255)
Clear.Font = Enum.Font.SourceSansBold
Clear.TextSize = 18
Clear.Parent = Frame

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 8)
ClearCorner.Parent = Clear

ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.Text = "🪐"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

SettingsFrame.Size = UDim2.new(0, 150, 0, 160)
SettingsFrame.Position = UDim2.new(1, -160, 0, 45)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 5
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
local themePath = sysPath .. "/Theme.txt"
local logPath = sysPath .. "/ExecutionLog.txt"

-- === FILE SYSTEM SETUP ===
if writefile and readfile and makefolder and isfolder and isfile then
    pcall(function()
        if not isfolder(sysPath) then
            makefolder(sysPath)
        end
        if not isfile(logPath) then
            writefile(logPath, "NovaX Execution Log\n")
        end
    end)
end

local function writeLog(tag, msg)  
    if not writefile or not appendfile then return end
    
    local time = os.date("[%Y-%m-%d %H:%M:%S]")  
    local line = string.format("%s [%s] %s\n", time, tag, tostring(msg))  
    
    pcall(function()
        appendfile(logPath, line)  
    end)
end

if writefile and readfile then
    local oldPrint = print  
    local oldWarn = warn  
    local oldError = error  

    print = function(...)  
        local msg = table.concat({...}, " ")  
        writeLog("PRINT", msg)  
        oldPrint(...)  
    end  

    warn = function(...)  
        local msg = table.concat({...}, " ")  
        writeLog("WARN", msg)  
        oldWarn(...)  
    end  

    error = function(...)  
        local msg = table.concat({...}, " ")  
        writeLog("ERROR", msg)  
        oldError(...)  
    end  

    writeLog("SYSTEM", "NovaX Logger initialized (persistent mode).")
else
    warn("[NovaX] Logging unavailable: missing writefile/appendfile support.")
end

if readfile and isfile and isfile(themePath) then
    local success, savedTheme = pcall(function()
        return readfile(themePath)
    end)
    if success and themes[savedTheme] then
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
        if writefile then 
            pcall(function()
                writefile(themePath, name) 
            end)
        end
    end)
    yPos += 30
end

Execute.MouseButton1Click:Connect(function()
    local code = ScriptBox.Text
    if code == "" or code == "-- Enter Lua code here" then
        Execute.Text = "⚠️ Empty!"
        task.wait(1)
        Execute.Text = "▶ Execute"
        return
    end
    
    Execute.Text = "⏳ Running..."
    Execute.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    local loader = loadstring or load
    if not loader then
        warn("[NovaX] Your executor does not support loadstring or load.")
        Execute.Text = "❌ Unsupported"
        Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1)
        Execute.Text = "▶ Execute"
        Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        return
    end

    local func, err = loader(code)
    if func then
        local ok, result = pcall(func)
        if ok then
            Execute.Text = "✅ Done!"
            Execute.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            writeLog("SUCCESS", "Script executed successfully")
        else
            Execute.Text = "⚠️ Runtime error"
            Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            warn("[NovaX] Runtime error: " .. tostring(result))
            writeLog("RUNTIME_ERROR", result)
        end
    else
        Execute.Text = "❌ Syntax error"
        Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        warn("[NovaX] Syntax error: " .. tostring(err))
        writeLog("SYNTAX_ERROR", err)
    end
    
    task.wait(1.5)
    Execute.Text = "▶ Execute"
    Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

Clear.MouseButton1Click:Connect(function()
    ScriptBox.Text = ""
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

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

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = false
    Frame.Visible = true
    Frame.BackgroundTransparency = 0
    Frame.Position = UDim2.new(0.5, -210, 0.5, -200)
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -210, 0.5, -160),
        BackgroundTransparency = 0
    }):Play()
end)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local draggingToggle = false
local toggleStart, togglePos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = true
        toggleStart = input.Position
        togglePos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingToggle then
        local delta = input.Position - toggleStart
        ToggleButton.Position = UDim2.new(togglePos.X.Scale, togglePos.X.Offset + delta.X, togglePos.Y.Scale, togglePos.Y.Offset + delta.Y)
    end
end)

local function saveButtonPosition(button)
    if not writefile then return end
    local data = {
        X = button.Position.X.Scale,
        Y = button.Position.Y.Scale,
        XO = button.Position.X.Offset,
        YO = button.Position.Y.Offset
    }
    pcall(function()
        writefile(sysPath .. "/" .. button.Name .. "_pos.json", HttpService:JSONEncode(data))
    end)
end

local function loadButtonPosition(button)
    if not readfile or not isfile then return end
    pcall(function()
        local filePath = sysPath .. "/" .. button.Name .. "_pos.json"
        if isfile(filePath) then
            local raw = readfile(filePath)
            local data = HttpService:JSONDecode(raw)
            button.Position = UDim2.new(data.X, data.XO, data.Y, data.YO)
        end
    end)
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local NovaMoreButton = Instance.new("TextButton")
NovaMoreButton.Name = "NovaMoreButton"
NovaMoreButton.Text = "🧭"
NovaMoreButton.Size = UDim2.new(0, 45, 0, 45)
NovaMoreButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
NovaMoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NovaMoreButton.Font = Enum.Font.SourceSansBold
NovaMoreButton.TextSize = 20
NovaMoreButton.Position = UDim2.new(0, 20, 0, 80)
NovaMoreButton.ZIndex = 10
NovaMoreButton.Parent = ScreenGui

local NovaMoreCorner = Instance.new("UICorner")
NovaMoreCorner.CornerRadius = UDim.new(0, 10)
NovaMoreCorner.Parent = NovaMoreButton

makeDraggable(NovaMoreButton)
loadButtonPosition(NovaMoreButton)

local NovaMoreFrame = Instance.new("Frame")
NovaMoreFrame.Name = "NovaMoreFrame"
NovaMoreFrame.Size = UDim2.new(0, 250, 0, 180)
NovaMoreFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
NovaMoreFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
NovaMoreFrame.Visible = false
NovaMoreFrame.ZIndex = 15
NovaMoreFrame.Parent = ScreenGui

local NovaMoreFrameCorner = Instance.new("UICorner")
NovaMoreFrameCorner.CornerRadius = UDim.new(0, 12)
NovaMoreFrameCorner.Parent = NovaMoreFrame

local CloseNovaMore = Instance.new("TextButton")
CloseNovaMore.Name = "CloseNovaMore"
CloseNovaMore.Text = "✖"
CloseNovaMore.Size = UDim2.new(0, 30, 0, 30)
CloseNovaMore.Position = UDim2.new(1, -35, 0, 5)
CloseNovaMore.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseNovaMore.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseNovaMore.Font = Enum.Font.SourceSansBold
CloseNovaMore.TextSize = 16
CloseNovaMore.Parent = NovaMoreFrame

local CloseNovaMoreCorner = Instance.new("UICorner")
CloseNovaMoreCorner.CornerRadius = UDim.new(0, 8)
CloseNovaMoreCorner.Parent = CloseNovaMore

local InfiniteYieldButton = Instance.new("TextButton")
InfiniteYieldButton.Text = "⚙️ Infinite Yield"
InfiniteYieldButton.Size = UDim2.new(0, 200, 0, 35)
InfiniteYieldButton.Position = UDim2.new(0.5, -100, 0, 50)
InfiniteYieldButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
InfiniteYieldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteYieldButton.Font = Enum.Font.SourceSansBold
InfiniteYieldButton.TextSize = 16
InfiniteYieldButton.Parent = NovaMoreFrame

local IYCorner = Instance.new("UICorner")
IYCorner.CornerRadius = UDim.new(0, 8)
IYCorner.Parent = InfiniteYieldButton

local FactoryResetButton = Instance.new("TextButton")
FactoryResetButton.Text = "🔄 Factory Reset"
FactoryResetButton.Size = UDim2.new(0, 200, 0, 35)
FactoryResetButton.Position = UDim2.new(0.5, -100, 0, 100)
FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
FactoryResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FactoryResetButton.Font = Enum.Font.SourceSansBold
FactoryResetButton.TextSize = 16
FactoryResetButton.Parent = NovaMoreFrame

local FactoryCorner = Instance.new("UICorner")
FactoryCorner.CornerRadius = UDim.new(0, 8)
FactoryCorner.Parent = FactoryResetButton

NovaMoreButton.MouseButton1Click:Connect(function()
    NovaMoreFrame.Visible = not NovaMoreFrame.Visible
end)

CloseNovaMore.MouseButton1Click:Connect(function()
    NovaMoreFrame.Visible = false
end)

InfiniteYieldButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    if not success then
        warn("[NovaX] Failed to load Infinite Yield: " .. tostring(result))
    end
    NovaMoreFrame.Visible = false
end)

FactoryResetButton.MouseButton1Click:Connect(function()
    if FactoryResetButton.Text == "🔄 Factory Reset" then
        -- First click: show confirmation
        local confirmed = Instance.new("TextLabel")
        confirmed.Size = UDim2.new(1, -20, 0, 30)
        confirmed.Position = UDim2.new(0, 10, 0, 150)
        confirmed.BackgroundTransparency = 1
        confirmed.Text = "⚠️ This will delete all settings!"
        confirmed.TextColor3 = Color3.fromRGB(255, 100, 100)
        confirmed.Font = Enum.Font.SourceSansBold
        confirmed.TextSize = 14
        confirmed.Parent = NovaMoreFrame
        
        FactoryResetButton.Text = "❌ Confirm Reset"
        FactoryResetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- Schedule reset of button after 5 seconds if not confirmed
        task.delay(5, function()
            if FactoryResetButton.Text == "❌ Confirm Reset" then
                FactoryResetButton.Text = "🔄 Factory Reset"
                FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
                if confirmed and confirmed.Parent then
                    confirmed:Destroy()
                end
            end
        end)
    elseif FactoryResetButton.Text == "❌ Confirm Reset" then
        -- Second click: perform reset
        if writefile and delfile and isfolder then
            pcall(function()
                -- Clear logs
                if isfile(logPath) then
                    delfile(logPath)
                end
                -- Clear theme settings
                if isfile(themePath) then
                    delfile(themePath)
                end
                -- Clear saved positions
                local togglePosFile = sysPath .. "/ToggleButton_pos.json"
                local novaPosFile = sysPath .. "/NovaMoreButton_pos.json"
                
                if isfile(togglePosFile) then
                    delfile(togglePosFile)
                end
                if isfile(novaPosFile) then
                    delfile(novaPosFile)
                end
                
                -- Reset UI to defaults
                Frame.BackgroundColor3 = themes["Dark"].frame
                Title.TextColor3 = themes["Dark"].accent
                currentTheme = "Dark"
                ToggleButton.Position = UDim2.new(0, 20, 0, 20)
                NovaMoreButton.Position = UDim2.new(0, 20, 0, 80)
                
                FactoryResetButton.Text = "✅ Reset Complete!"
                FactoryResetButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                
                if writeLog then
                    writeLog("SYSTEM", "Factory reset performed")
                end
                
                task.wait(2)
                FactoryResetButton.Text = "🔄 Factory Reset"
                FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
            end)
        else
            -- Show error if file functions not available
            FactoryResetButton.Text = "❌ No Permission"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(2)
            FactoryResetButton.Text = "🔄 Factory Reset"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if writefile and readfile and isfolder then
            local folderExists = pcall(function()
                return isfolder(sysPath)
            end)
            
            if not folderExists then
                warn("[NovaX][CRITICAL] System directory missing. Self-termination initiated.")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "NovaX Security",
                    Text = "System directory missing. Terminating...",
                    Duration = 5
                })
                task.wait(4)
                ScreenGui:Destroy()
                warn("[NovaX] Terminated due to integrity failure.")
                break
            end
        end
    end
end)

print("[NovaX] Interface loaded successfully!")
