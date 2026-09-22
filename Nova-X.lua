--[[
    NovaX - Clean Refactor
    ------------------------------------------------------------
    A Roblox executor UI with:
      * Code box + Execute / Clear
      * Theme switcher (Dark / Neon / Ice) with persistence
      * Persistent logging (print / warn)
      * Floating Toggle button + NovaMore quick-tools panel
      * Infinite Yield loader + Factory Reset
      * Integrity check

    Notes:
      * We intentionally do NOT override the global `error` function,
        because doing so can break pcall semantics.
      * The integrity check now correctly inspects the boolean
        returned by `isfolder`, not just the pcall success flag.
]]

-- ============================================================
-- Services
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")
local Players          = game:GetService("Players")

-- ============================================================
-- Configuration
-- ============================================================
local CONFIG = {
    Title             = "NovaX",
    SysFolder         = "Nova-X-sys",
    MaxLogLines       = 500,
    IntegrityInterval = 10,
    SplashImage       = "rbxassetid://1316045217",
    IYUrl             = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
}

local THEMES = {
    Dark = { frame = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(0, 255, 255)   },
    Neon = { frame = Color3.fromRGB(10, 10, 30), accent = Color3.fromRGB(255, 0, 255)   },
    Ice  = { frame = Color3.fromRGB(30, 40, 50), accent = Color3.fromRGB(150, 255, 255) },
}

-- ============================================================
-- File-system capabilities
-- ============================================================
local hasWrite = writefile and appendfile
local hasRead  = readfile and isfile and isfolder

local sysPath   = CONFIG.SysFolder
local themePath = sysPath .. "/Theme.txt"
local logPath   = sysPath .. "/ExecutionLog.txt"

local logLineCount = 0

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    return ok, result
end

local function fileExists(path)
    if not (isfile and readfile) then return false end
    local ok, exists = safeCall(isfile, path)
    return ok and exists
end

-- ============================================================
-- Logging
-- ============================================================
local function toStr(v)
    local ok, s = pcall(tostring, v)
    return ok and s or "<?>"
end

local function joinArgs(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = toStr(select(i, ...))
    end
    return table.concat(parts, " ")
end

local function rotateLogIfNeeded()
    if not hasWrite then return end
    if logLineCount < CONFIG.MaxLogLines then return end
    safeCall(writefile, logPath, "NovaX Execution Log (rotated)\n")
    logLineCount = 0
end

local function writeLog(tag, msg)
    if not hasWrite then return end
    local line = string.format(
        "[%s] [%s] %s\n",
        os.date("%Y-%m-%d %H:%M:%S"),
        tag,
        toStr(msg)
    )
    safeCall(appendfile, logPath, line)
    logLineCount += 1
    rotateLogIfNeeded()
end

local function setupFileSystem()
    if not (writefile and makefolder and isfolder) then return end
    if not isfolder(sysPath) then
        safeCall(makefolder, sysPath)
    end
    if not fileExists(logPath) then
        safeCall(writefile, logPath, "NovaX Execution Log\n")
    end
end

local function installLoggerHooks()
    if not hasWrite then
        warn("[NovaX] Logging unavailable: missing writefile/appendfile support.")
        return
    end

    local oldPrint, oldWarn = print, warn

    print = function(...)
        writeLog("PRINT", joinArgs(...))
        oldPrint(...)
    end

    warn = function(...)
        writeLog("WARN", joinArgs(...))
        oldWarn(...)
    end

    -- Intentionally not overriding `error`.
    writeLog("SYSTEM", "NovaX logger initialized.")
end

-- ============================================================
-- UI construction helpers
-- ============================================================
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function new(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- ============================================================
-- ScreenGui + splash
-- ============================================================
local function resolveGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local core = game:FindFirstChildOfClass("CoreGui")
    if core then return core end
    local player = Players.LocalPlayer
    if player then
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if pg then return pg end
    end
    -- Fallback: create and parent to CoreGui so it actually renders.
    local temp = Instance.new("ScreenGui")
    temp.Parent = game:GetService("CoreGui")
    return temp
end

local ScreenGui = new("ScreenGui", {
    Name             = "NovaX_UI",
    ResetOnSpawn     = false,
    ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
}, resolveGuiParent())

do
    local splash = new("ImageLabel", {
        Size                  = UDim2.new(0, 200, 0, 200),
        Position              = UDim2.new(0.5, -100, 0.5, -100),
        BackgroundTransparency = 1,
        Image                 = CONFIG.SplashImage,
        ZIndex                = 10,
    }, ScreenGui)

    task.spawn(function()
        TweenService:Create(splash, TweenInfo.new(1), {
            Size = UDim2.new(0, 300, 0, 300),
        }):Play()
        task.wait(1)
        TweenService:Create(splash, TweenInfo.new(0.5), {
            ImageTransparency = 1,
        }):Play()
        task.wait(0.5)
        splash:Destroy()
    end)
end

-- ============================================================
-- Main window
-- ============================================================
local Frame = new("Frame", {
    Size             = UDim2.new(0, 420, 0, 320),
    Position         = UDim2.new(0.5, -210, 0.5, -160),
    BackgroundColor3 = THEMES.Dark.frame,
    BorderSizePixel  = 0,
    Visible          = false,
    Active           = true,
}, ScreenGui)
corner(Frame, 8)

-- Soft shadow
new("ImageLabel", {
    Size                  = UDim2.new(1, 30, 1, 30),
    Position              = UDim2.new(0, -15, 0, -15),
    BackgroundTransparency = 1,
    Image                 = CONFIG.SplashImage,
    ImageColor3           = Color3.fromRGB(0, 0, 0),
    ScaleType             = Enum.ScaleType.Slice,
    SliceCenter           = Rect.new(10, 10, 118, 118),
    ImageTransparency     = 0.5,
    ZIndex                = -1,
}, Frame)

-- Title bar
local TitleBar = new("Frame", {
    Size             = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    BorderSizePixel  = 0,
    ZIndex           = 2,
}, Frame)
corner(TitleBar, 8)

local Title = new("TextLabel", {
    Text              = CONFIG.Title,
    Size              = UDim2.new(1, -100, 1, 0),
    Position          = UDim2.new(0, 10, 0, 0),
    TextColor3        = THEMES.Dark.accent,
    Font              = Enum.Font.SourceSansBold,
    TextSize          = 22,
    BackgroundTransparency = 1,
    TextXAlignment    = Enum.TextXAlignment.Left,
    ZIndex            = 3,
}, TitleBar)

local SettingsButton = new("TextButton", {
    Text             = "⚙️",
    Size             = UDim2.new(0, 40, 0, 40),
    Position         = UDim2.new(1, -80, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 20,
    ZIndex           = 3,
}, TitleBar)
corner(SettingsButton, 8)

local Close = new("TextButton", {
    Text             = "X",
    Size             = UDim2.new(0, 40, 0, 40),
    Position         = UDim2.new(1, -40, 0, 0),
    BackgroundColor3 = Color3.fromRGB(255, 50, 50),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 22,
    ZIndex           = 3,
}, TitleBar)
corner(Close, 8)

-- Script input
local ScriptBox = new("TextBox", {
    Size                  = UDim2.new(1, -20, 1, -120),
    Position              = UDim2.new(0, 10, 0, 50),
    BackgroundColor3      = Color3.fromRGB(15, 15, 15),
    TextColor3            = Color3.fromRGB(0, 255, 0),
    TextStrokeTransparency = 0.8,
    MultiLine             = true,
    ClearTextOnFocus      = false,
    Text                  = "-- Enter Lua code here",
    Font                  = Enum.Font.Code,
    TextSize              = 16,
    TextXAlignment        = Enum.TextXAlignment.Left,
    TextYAlignment        = Enum.TextYAlignment.Top,
}, Frame)
corner(ScriptBox, 6)

-- Action buttons
local Execute = new("TextButton", {
    Text             = "▶ Execute",
    Size             = UDim2.new(0, 120, 0, 35),
    Position         = UDim2.new(0, 40, 1, -45),
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 18,
}, Frame)
corner(Execute, 8)

local Clear = new("TextButton", {
    Text             = "🧹 Clear",
    Size             = UDim2.new(0, 120, 0, 35),
    Position         = UDim2.new(1, -160, 1, -45),
    BackgroundColor3 = Color3.fromRGB(255, 80, 80),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 18,
}, Frame)
corner(Clear, 8)

-- Settings panel
local SettingsFrame = new("Frame", {
    Size             = UDim2.new(0, 150, 0, 160),
    Position         = UDim2.new(1, -160, 0, 45),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Visible          = false,
    ZIndex           = 5,
}, Frame)
corner(SettingsFrame, 8)

new("TextLabel", {
    Size                  = UDim2.new(1, 0, 0, 30),
    Text                  = "🎨 Theme:",
    BackgroundTransparency = 1,
    TextColor3            = Color3.fromRGB(255, 255, 255),
    Font                  = Enum.Font.SourceSansBold,
    TextSize              = 16,
}, SettingsFrame)

-- ============================================================
-- Dragging helper (target = what moves, handle = what you grab)
-- ============================================================
local function makeDraggable(target, handle, onRelease)
    handle = handle or target
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if onRelease then onRelease() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- Theme system
-- ============================================================
local currentTheme = "Dark"

local function applyTheme(name)
    local t = THEMES[name]
    if not t then return end
    currentTheme = name
    Frame.BackgroundColor3 = t.frame
    Title.TextColor3       = t.accent

    if hasWrite then
        safeCall(writefile, themePath, name)
    end
end

local function loadSavedTheme()
    if not (readfile and isfile) then return end
    if not fileExists(themePath) then return end
    local ok, saved = safeCall(readfile, themePath)
    if ok and THEMES[saved] then
        applyTheme(saved)
    end
end

do
    local yPos = 30
    for name in pairs(THEMES) do
        local btn = new("TextButton", {
            Size             = UDim2.new(1, -10, 0, 25),
            Position         = UDim2.new(0, 5, 0, yPos),
            Text             = name,
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            TextColor3       = Color3.fromRGB(255, 255, 255),
            Font             = Enum.Font.SourceSans,
            TextSize         = 16,
        }, SettingsFrame)
        corner(btn, 6)
        btn.MouseButton1Click:Connect(function()
            applyTheme(name)
        end)
        yPos += 30
    end
end

-- ============================================================
-- Floating buttons
-- ============================================================
local function savePosition(button)
    if not hasWrite then return end
    local data = {
        X  = button.Position.X.Scale,
        Y  = button.Position.Y.Scale,
        XO = button.Position.X.Offset,
        YO = button.Position.Y.Offset,
    }
    safeCall(
        writefile,
        sysPath .. "/" .. button.Name .. "_pos.json",
        HttpService:JSONEncode(data)
    )
end

local function loadPosition(button)
    if not (readfile and isfile) then return end
    local path = sysPath .. "/" .. button.Name .. "_pos.json"
    if not fileExists(path) then return end
    local ok, raw = safeCall(readfile, path)
    if not ok then return end
    local ok2, data = safeCall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end
    button.Position = UDim2.new(data.X, data.XO, data.Y, data.YO)
end

-- Toggle button
local ToggleButton = new("TextButton", {
    Name             = "ToggleButton",
    Size             = UDim2.new(0, 45, 0, 45),
    Position         = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    Text             = "🪐",
    TextColor3       = Color3.fromRGB(0, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 22,
    ZIndex           = 10,
}, ScreenGui)
corner(ToggleButton, 10)
loadPosition(ToggleButton)
makeDraggable(ToggleButton, nil, function() savePosition(ToggleButton) end)

-- NovaMore button
local NovaMoreButton = new("TextButton", {
    Name             = "NovaMoreButton",
    Size             = UDim2.new(0, 45, 0, 45),
    Position         = UDim2.new(0, 20, 0, 80),
    BackgroundColor3 = Color3.fromRGB(0, 255, 255),
    Text             = "🧭",
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 20,
    ZIndex           = 10,
}, ScreenGui)
corner(NovaMoreButton, 10)
loadPosition(NovaMoreButton)
makeDraggable(NovaMoreButton, nil, function() savePosition(NovaMoreButton) end)

-- ============================================================
-- NovaMore quick-tools panel
-- ============================================================
local NovaMoreFrame = new("Frame", {
    Name             = "NovaMoreFrame",
    Size             = UDim2.new(0, 250, 0, 180),
    Position         = UDim2.new(0.5, -125, 0.5, -90),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    Visible          = false,
    ZIndex           = 15,
}, ScreenGui)
corner(NovaMoreFrame, 12)

local CloseNovaMore = new("TextButton", {
    Name             = "CloseNovaMore",
    Text             = "✖",
    Size             = UDim2.new(0, 30, 0, 30),
    Position         = UDim2.new(1, -35, 0, 5),
    BackgroundColor3 = Color3.fromRGB(80, 30, 30),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
}, NovaMoreFrame)
corner(CloseNovaMore, 8)

local InfiniteYieldButton = new("TextButton", {
    Text             = "⚙️ Infinite Yield",
    Size             = UDim2.new(0, 200, 0, 35),
    Position         = UDim2.new(0.5, -100, 0, 50),
    BackgroundColor3 = Color3.fromRGB(60, 60, 90),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
}, NovaMoreFrame)
corner(InfiniteYieldButton, 8)

local FactoryResetButton = new("TextButton", {
    Text             = "🔄 Factory Reset",
    Size             = UDim2.new(0, 200, 0, 35),
    Position         = UDim2.new(0.5, -100, 0, 100),
    BackgroundColor3 = Color3.fromRGB(90, 30, 30),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
}, NovaMoreFrame)
corner(FactoryResetButton, 8)

-- ============================================================
-- Event handlers
-- ============================================================
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
        warn("[NovaX] Executor lacks loadstring/load.")
        Execute.Text = "❌ Unsupported"
        Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1)
        Execute.Text = "▶ Execute"
        Execute.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        return
    end

    local fn, err = loader(code)
    if not fn then
        Execute.Text = "❌ Syntax error"
        Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        warn("[NovaX] Syntax error: " .. tostring(err))
        writeLog("SYNTAX_ERROR", err)
    else
        local ok, result = pcall(fn)
        if ok then
            Execute.Text = "✅ Done!"
            Execute.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            writeLog("SUCCESS", "Script executed successfully.")
        else
            Execute.Text = "⚠️ Runtime error"
            Execute.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            warn("[NovaX] Runtime error: " .. tostring(result))
            writeLog("RUNTIME_ERROR", result)
        end
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
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position             = UDim2.new(
            Frame.Position.X.Scale, Frame.Position.X.Offset,
            Frame.Position.Y.Scale, Frame.Position.Y.Offset - 200
        ),
        BackgroundTransparency = 1,
    }):Play()
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
        Position             = UDim2.new(0.5, -210, 0.5, -160),
        BackgroundTransparency = 0,
    }):Play()
end)

NovaMoreButton.MouseButton1Click:Connect(function()
    NovaMoreFrame.Visible = not NovaMoreFrame.Visible
end)

CloseNovaMore.MouseButton1Click:Connect(function()
    NovaMoreFrame.Visible = false
end)

InfiniteYieldButton.MouseButton1Click:Connect(function()
    local loader = loadstring or load
    if not loader then
        warn("[NovaX] Infinite Yield: no loadstring available.")
        NovaMoreFrame.Visible = false
        return
    end

    local ok, err = pcall(function()
        local src = game:HttpGet(CONFIG.IYUrl)
        local fn = loader(src)
        if fn then fn() end
    end)

    if not ok then
        warn("[NovaX] Failed to load Infinite Yield: " .. tostring(err))
    end
    NovaMoreFrame.Visible = false
end)

-- ============================================================
-- Factory Reset (two-step confirmation)
-- ============================================================
do
    local resetConfirmLabel = nil

    local function clearConfirmLabel()
        if resetConfirmLabel and resetConfirmLabel.Parent then
            resetConfirmLabel:Destroy()
        end
        resetConfirmLabel = nil
    end

    local function resetButtonToIdle()
        FactoryResetButton.Text = "🔄 Factory Reset"
        FactoryResetButton.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
    end

    local function performReset()
        if not (writefile and delfile and isfolder) then
            FactoryResetButton.Text = "❌ No Permission"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(2)
            resetButtonToIdle()
            return
        end

        safeCall(function()
            if fileExists(logPath)   then delfile(logPath)   end
            if fileExists(themePath) then delfile(themePath) end

            local togglePosFile = sysPath .. "/ToggleButton_pos.json"
            local novaPosFile   = sysPath .. "/NovaMoreButton_pos.json"
            if fileExists(togglePosFile) then delfile(togglePosFile) end
            if fileExists(novaPosFile)   then delfile(novaPosFile)   end

            Frame.BackgroundColor3 = THEMES.Dark.frame
            Title.TextColor3       = THEMES.Dark.accent
            currentTheme           = "Dark"
            ToggleButton.Position   = UDim2.new(0, 20, 0, 20)
            NovaMoreButton.Position = UDim2.new(0, 20, 0, 80)

            FactoryResetButton.Text = "✅ Reset Complete!"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            writeLog("SYSTEM", "Factory reset performed.")

            task.wait(2)
            resetButtonToIdle()
        end)
    end

    FactoryResetButton.MouseButton1Click:Connect(function()
        if FactoryResetButton.Text == "🔄 Factory Reset" then
            clearConfirmLabel()

            resetConfirmLabel = new("TextLabel", {
                Size                  = UDim2.new(1, -20, 0, 30),
                Position              = UDim2.new(0, 10, 0, 150),
                BackgroundTransparency = 1,
                Text                  = "⚠️ This will delete all settings!",
                TextColor3            = Color3.fromRGB(255, 100, 100),
                Font                  = Enum.Font.SourceSansBold,
                TextSize              = 14,
            }, NovaMoreFrame)

            FactoryResetButton.Text = "❌ Confirm Reset"
            FactoryResetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

            task.delay(5, function()
                if FactoryResetButton.Text == "❌ Confirm Reset" then
                    resetButtonToIdle()
                    clearConfirmLabel()
                end
            end)
        elseif FactoryResetButton.Text == "❌ Confirm Reset" then
            clearConfirmLabel()
            performReset()
        end
    end)
end

-- ============================================================
-- Integrity check
-- ============================================================
task.spawn(function()
    if not (writefile and isfolder) then return end

    while task.wait(CONFIG.IntegrityInterval) do
        local ok, exists = pcall(isfolder, sysPath)
        if not ok or not exists then
            warn("[NovaX][CRITICAL] System directory missing. Self-termination initiated.")
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title    = "NovaX Security",
                    Text     = "System directory missing. Terminating...",
                    Duration = 5,
                })
            end)
            task.wait(4)
            ScreenGui:Destroy()
            warn("[NovaX] Terminated due to integrity failure.")
            break
        end
    end
end)

-- ============================================================
-- Boot
-- ============================================================
setupFileSystem()
installLoggerHooks()
loadSavedTheme()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title    = "NovaX",
        Text     = "Loading Successfully!",
        Duration = 5,
    })
end)

print("[NovaX] Interface loaded successfully!")
