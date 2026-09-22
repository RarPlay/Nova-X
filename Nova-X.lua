--[[
    NovaX v3.5 — Audit Fixes Round 4 (Full Rewrite)
    ================================================================
    Исправления:
      • safeHttpGet: универсальный резолвер HTTP-запросов
      • loadstring fallback с уведомлением
      • gethui / CoreGui fallback с тестом
      • FS (файловая система) с единым флагом hasFS
      • GenerateGUID вместо tick() для ID вкладок
      • Перетаскивание окна за Sidebar
      • AutomaticCanvasSize с корректным Offset
      • Fallback для BuilderSans шрифтов
      • clampColor для безопасного чтения конфига
      • Обработка ошибок IY / Browser
    ================================================================
]]

-- ============================================================
-- Services
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

-- ============================================================
-- Config
-- ============================================================
local CONFIG = {
    Title              = "NovaX",
    SysFolder          = "Nova-X-sys",
    MaxLogLines        = 500,
    IntegrityInterval  = 10,
    SplashImage        = "rbxassetid://1316045217",
    IYUrl              = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
    RoScriptsAPI       = "https://api.roscripts.io/v1",
    ScriptBloxProxy    = "https://scriptblox-api-proxy.vercel.app/api",
    ScriptBloxOfficial = "https://scriptblox.com/api/script",
}

local ICONS = {
    execute  = "rbxassetid://10734950020",
    script   = "rbxassetid://10734950456",
    iy       = "rbxassetid://10734957828",
    settings = "rbxassetid://10734951556",
    browser  = "rbxassetid://10734951307",
    search   = "rbxassetid://10734950876",
    open     = "rbxassetid://10734950985",
    run      = "rbxassetid://10734958214",
    clear    = "rbxassetid://10734950314",
    save     = "rbxassetid://10734950186",
    close    = "rbxassetid://10734950938",
}

local THEMES = {
    Dark = { frame = Color3.fromRGB(18, 18, 22), accent = Color3.fromRGB(0, 220, 255),   closeAccent = Color3.fromRGB(200, 50, 60)  },
    Neon = { frame = Color3.fromRGB(12, 10, 28), accent = Color3.fromRGB(220, 80, 255),  closeAccent = Color3.fromRGB(230, 60, 110) },
    Ice  = { frame = Color3.fromRGB(22, 30, 40), accent = Color3.fromRGB(140, 230, 255), closeAccent = Color3.fromRGB(200, 70, 80)  },
}
local THEME_ORDER = { "Dark", "Neon", "Ice" }
local LANG_ORDER  = { "RU", "EN", "DE", "ES" }

-- ============================================================
-- Forward declarations
-- ============================================================
local currentTheme  = "Dark"
local currentLang   = "RU"
local pages         = {}
local applyTheme
local saveConfig
local applyLang
local glowToggle
local glowEnabled   = true
local userGlowColor = nil
local ToggleButton
local toggleGlow
local closeGlow
local CloseBtn

-- ============================================================
-- Безопасные утилиты
-- ============================================================

-- [NEW] Универсальный HTTP-резолвер
local function safeHttpGet(url)
    local executors = {
        function() return game:HttpGet(url) end,
        function() return game:HttpGetAsync(url) end,
        function() return game:GetService("HttpService"):GetAsync(url) end,
    }
    for _, fn in ipairs(executors) do
        local ok, res = pcall(fn)
        if ok and type(res) == "string" and #res > 0 then
            return res
        end
    end
    return nil
end

-- [NEW] Безопасный Color3 с clamp
local function clampColor(v)
    return math.clamp(tonumber(v) or 0, 0, 255)
end

-- [NEW] Безопасный loadstring
local function getLoader()
    local loader = loadstring or load
    if not loader then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "NovaX",
                Text = "loadstring недоступен в этом executor'е",
                Duration = 5,
            })
        end)
    end
    return loader
end

-- [NEW] ID генератор без коллизий
local function makeId()
    return HttpService:GenerateGUID(false)
end

-- ============================================================
-- i18n
-- ============================================================
local LOCALES = {
    RU = { execute="Выполнить", clear="Очистить", empty="Пусто!", running="Выполняется...",
           done="Готово!", syntax="Синтаксис", runtime="Ошибка", settings="Настройки",
           browser="Браузер", script="ScriptBlox", iy="Infinite Yield", search="Поиск...",
           fullscreen="Полный экран", glow="Свечение", language="Язык", autoexec="Автозапуск",
           save="Сохранить", open="Открыть", runNow="Запустить", newTab="Новая вкладка",
           theme="Тема" },
    EN = { execute="Execute", clear="Clear", empty="Empty!", running="Running...",
           done="Done!", syntax="Syntax Error", runtime="Runtime Error", settings="Settings",
           browser="Browser", script="ScriptBlox", iy="Infinite Yield", search="Search...",
           fullscreen="Full Screen", glow="Glow", language="Language", autoexec="Autoexec",
           save="Save", open="Open", runNow="Run Now", newTab="New Tab",
           theme="Theme" },
    DE = { execute="Ausführen", clear="Löschen", empty="Leer!", running="Läuft...",
           done="Fertig!", syntax="Syntaxfehler", runtime="Laufzeitfehler",
           settings="Einstellungen", browser="Browser", script="ScriptBlox", iy="Infinite Yield",
           search="Suchen...", fullscreen="Vollbild", glow="Leuchten", language="Sprache",
           autoexec="Autostart", save="Speichern", open="Öffnen", runNow="Jetzt starten",
           newTab="Neuer Tab", theme="Design" },
    ES = { execute="Ejecutar", clear="Limpiar", empty="¡Vacío!", running="Ejecutando...",
           done="¡Hecho!", syntax="Error de sintaxis", runtime="Error en tiempo de ejecución",
           settings="Ajustes", browser="Navegador", script="ScriptBlox", iy="Infinite Yield",
           search="Buscar...", fullscreen="Pantalla completa", glow="Brillo", language="Idioma",
           autoexec="Autoinicio", save="Guardar", open="Abrir", runNow="Ejecutar ahora",
           newTab="Nueva pestaña", theme="Tema" },
}

local function t(key)
    local loc = LOCALES[currentLang] or LOCALES.EN
    return loc[key] or key
end

-- ============================================================
-- File system [REFACTORED]
-- ============================================================
local FS = {
    write   = writefile,
    read    = readfile,
    exists  = isfile,
    folder  = isfolder,
    mkdir   = makefolder,
    delete  = delfile,
    append  = appendfile,
}
local hasFS = FS.write and FS.read and FS.exists and FS.folder and FS.mkdir

local sysPath   = CONFIG.SysFolder
local themePath = sysPath .. "/Theme.txt"
local logPath   = sysPath .. "/ExecutionLog.txt"
local tabsPath  = sysPath .. "/tabs.json"
local execPath  = sysPath .. "/autoexec.txt"
local cfgPath   = sysPath .. "/config.json"

local logLineCount = 0

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then warn("[NovaX] safeCall failed:", result) end
    return ok, result
end

local function fileExists(path)
    if not (FS.exists and FS.read) then return false end
    local ok, exists = safeCall(FS.exists, path)
    return ok and exists
end

-- ============================================================
-- Logging
-- ============================================================
local function toStr(v) local ok, s = pcall(tostring, v) return ok and s or "<?>" end

local function rotateLogIfNeeded()
    if not hasFS then return end
    if logLineCount < CONFIG.MaxLogLines then return end
    safeCall(FS.write, logPath, "NovaX Execution Log (rotated)\n")
    logLineCount = 0
end

local function writeLog(tag, msg)
    if not hasFS then return end
    local line = string.format("[%s] [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), tag, toStr(msg))
    safeCall(FS.append, logPath, line)
    logLineCount += 1
    rotateLogIfNeeded()
end

local function setupFileSystem()
    if not hasFS then return end
    if not FS.folder(sysPath) then safeCall(FS.mkdir, sysPath) end
    if not fileExists(logPath)  then safeCall(FS.write, logPath,  "NovaX Execution Log\n") end
    if not fileExists(tabsPath) then safeCall(FS.write, tabsPath, "{}") end
end

-- ============================================================
-- UI helpers
-- ============================================================
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function new(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function icon(parent, iconId, size, pos, color, z)
    return new("ImageLabel", {
        Size                   = size or UDim2.new(0, 18, 0, 18),
        Position               = pos or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image                  = iconId,
        ImageColor3            = color or Color3.fromRGB(200, 200, 200),
        ZIndex                 = z or 5,
    }, parent)
end

local function addHover(btn, baseColor, hoverColor, baseSize, hoverSize)
    local origSize  = baseSize or btn.Size
    local origColor = baseColor or btn.BackgroundColor3
    local origPos   = btn.Position
    local hoverCol  = hoverColor or origColor:Lerp(Color3.new(1,1,1), 0.15)
    local hoverSz   = hoverSize or UDim2.new(origSize.X.Scale, origSize.X.Offset + 2,
                                              origSize.Y.Scale, origSize.Y.Offset + 2)
    local ap = btn.AnchorPoint
    local compX = (ap.X == 0) and -1 or 0
    local compY = (ap.Y == 0) and -1 or 0

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size             = hoverSz,
            BackgroundColor3 = hoverCol,
            Position         = UDim2.new(origPos.X.Scale, origPos.X.Offset + compX,
                                          origPos.Y.Scale, origPos.Y.Offset + compY),
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size             = origSize,
            BackgroundColor3 = origColor,
            Position         = origPos,
        }):Play()
    end)
end

-- [NEW] Безопасный резолвер GUI-родителя
local function resolveGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui and hui.Parent ~= nil then return hui end
    end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then
        local ok3, test = pcall(function()
            local sg = Instance.new("ScreenGui")
            sg.Parent = core
            sg:Destroy()
        end)
        if ok3 then return core end
    end
    local player = Players.LocalPlayer
    if player then
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if pg then return pg end
    end
    return nil
end

-- [NEW] Fallback для шрифтов
local FONT_REGULAR, FONT_BOLD
do
    local ok1 = pcall(function() FONT_REGULAR = Enum.Font.BuilderSans end)
    if not ok1 then FONT_REGULAR = Enum.Font.Gotham end
    local ok2 = pcall(function() FONT_BOLD = Enum.Font.BuilderSansBold end)
    if not ok2 then FONT_BOLD = Enum.Font.GothamBold end
end

-- ============================================================
-- ScreenGui + Splash
-- ============================================================
local guiParent = resolveGuiParent()
if not guiParent then
    local player = Players.LocalPlayer
    guiParent = player and player:WaitForChild("PlayerGui") or game:GetService("CoreGui")
end

local ScreenGui = new("ScreenGui", {
    Name           = "NovaX_UI",
    ResetOnSpawn   = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)
pcall(function() ScreenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)

do
    local SplashGui = new("ScreenGui", {
        Name           = "NovaX_Splash",
        ResetOnSpawn   = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, guiParent)
    pcall(function() SplashGui.ScreenInsets = Enum.ScreenInsets.None end)

    local splash = new("ImageLabel", {
        Size                   = UDim2.new(0, 200, 0, 200),
        Position               = UDim2.new(0.5, -100, 0.5, -100),
        BackgroundTransparency = 1,
        Image                  = CONFIG.SplashImage,
        ZIndex                 = 200,
    }, SplashGui)

    task.spawn(function()
        TweenService:Create(splash, TweenInfo.new(1), { Size = UDim2.new(0, 300, 0, 300) }):Play()
        task.wait(1)
        TweenService:Create(splash, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
        task.wait(0.5)
        SplashGui:Destroy()
    end)
end

-- ============================================================
-- Main Window
-- ============================================================
local Frame = new("Frame", {
    Name                   = "MainFrame",
    Size                   = UDim2.fromScale(1, 1),
    Position               = UDim2.fromScale(0, 0),
    BackgroundColor3       = THEMES.Dark.frame,
    BackgroundTransparency = 0.08,
    BorderSizePixel        = 0,
    Visible                = false,
    Active                 = true,
    ClipsDescendants       = false,
    ZIndex                 = 1,
}, ScreenGui)
corner(Frame, 0)

local bgGradient = new("UIGradient", {
    Rotation     = 35,
    Color        = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEMES.Dark.frame:Lerp(THEMES.Dark.accent, 0.08)),
        ColorSequenceKeypoint.new(0.5, THEMES.Dark.frame),
        ColorSequenceKeypoint.new(1, THEMES.Dark.frame:Lerp(Color3.new(0,0,0), 0.3)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 0.5),
    }),
}, Frame)

local GlowInner = new("UIStroke", {
    Thickness       = 1.5,
    Color           = THEMES.Dark.accent,
    Transparency    = 0.15,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, Frame)

local GlowOuter = new("UIStroke", {
    Thickness       = 6,
    Color           = THEMES.Dark.accent,
    Transparency    = 0.75,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, Frame)

task.spawn(function()
    while Frame.Parent do
        TweenService:Create(GlowOuter, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.85,
        }):Play()
        task.wait(2)
        TweenService:Create(GlowOuter, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.65,
        }):Play()
        task.wait(2)
    end
end)

-- ============================================================
-- Sidebar
-- ============================================================
local Sidebar = new("Frame", {
    Name                   = "Sidebar",
    Size                   = UDim2.new(0, 160, 1, 0),
    BackgroundColor3       = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.15,
    BorderSizePixel        = 0,
    ZIndex                 = 2,
}, Frame)

new("Frame", {
    Size             = UDim2.new(0, 1, 1, 0),
    Position         = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.9,
    BorderSizePixel  = 0,
    ZIndex           = 3,
}, Sidebar)

local SidebarTitle = new("TextLabel", {
    Size                   = UDim2.new(1, -20, 0, 50),
    Position               = UDim2.new(0, 16, 0, 8),
    BackgroundTransparency = 1,
    Text                   = CONFIG.Title,
    TextColor3             = THEMES.Dark.accent,
    Font                   = FONT_BOLD,
    TextSize               = 24,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 3,
}, Sidebar)

-- [NEW] Перетаскивание окна за Sidebar
do
    local dragging = false
    local dragStart, startPos

    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local categoryDefs = {
    { key = "execute",  icon = ICONS.execute,  label = "Execute"        },
    { key = "script",   icon = ICONS.script,   label = "ScriptBlox"     },
    { key = "iy",       icon = ICONS.iy,       label = "Infinite Yield" },
    { key = "settings", icon = ICONS.settings, label = "Settings"       },
    { key = "browser",  icon = ICONS.browser,  label = "Browser"        },
}

local categoryButtons = {}
local currentCategory = "execute"

local function switchCategory(key)
    currentCategory = key
    local theme = THEMES[currentTheme] or THEMES.Dark
    for k, btn in pairs(categoryButtons) do
        local active = (k == key)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = active and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(20, 20, 26),
            BackgroundTransparency = active and 0.1 or 0.4,
        }):Play()
        for _, ch in pairs(btn:GetChildren()) do
            if ch:IsA("ImageLabel") then
                TweenService:Create(ch, TweenInfo.new(0.2), {
                    ImageColor3 = active and theme.accent or Color3.fromRGB(160, 160, 170),
                }):Play()
            elseif ch:IsA("TextLabel") then
                TweenService:Create(ch, TweenInfo.new(0.2), {
                    TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(180, 180, 190),
                }):Play()
            end
        end
    end
    for k, page in pairs(pages) do
        page.Visible = (k == key)
    end
end

local yOffset = 70
for _, def in ipairs(categoryDefs) do
    local btn = new("TextButton", {
        Name                   = "Cat_" .. def.key,
        Size                   = UDim2.new(1, -16, 0, 40),
        Position               = UDim2.new(0, 8, 0, yOffset),
        BackgroundColor3       = Color3.fromRGB(20, 20, 26),
        BackgroundTransparency = 0.4,
        Text                   = "",
        BorderSizePixel        = 0,
        ZIndex                 = 3,
    }, Sidebar)
    corner(btn, 10)

    icon(btn, def.icon, UDim2.new(0, 18, 0, 18), UDim2.new(0, 12, 0.5, -9),
         Color3.fromRGB(160, 160, 170), 4)

    new("TextLabel", {
        Size                   = UDim2.new(1, -44, 1, 0),
        Position               = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text                   = def.label,
        TextColor3             = Color3.fromRGB(180, 180, 190),
        Font                   = FONT_REGULAR,
        TextSize               = 14,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
    }, btn)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        if currentCategory ~= def.key then
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.4 }):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function() switchCategory(def.key) end)
    categoryButtons[def.key] = btn
    yOffset += 46
end

-- ============================================================
-- Content container
-- ============================================================
local Content = new("Frame", {
    Name                   = "Content",
    Size                   = UDim2.new(1, -160, 1, 0),
    Position               = UDim2.new(0, 160, 0, 0),
    BackgroundTransparency = 1,
    ZIndex                 = 2,
}, Frame)

local function makePage(key)
    local p = new("Frame", {
        Name                   = "Page_" .. key,
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible                = false,
        ZIndex                 = 2,
    }, Content)
    pages[key] = p
    return p
end

-- ============================================================
-- Page: Execute
-- ============================================================
local execPage = makePage("execute")

local TabBar = new("ScrollingFrame", {
    Size                   = UDim2.new(1, -24, 0, 40),
    Position               = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    CanvasSize             = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness     = 0,
    ZIndex                 = 3,
}, execPage)

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding       = UDim.new(0, 6),
    SortOrder     = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, TabBar)

local ScriptBox = new("TextBox", {
    Size                   = UDim2.new(1, -24, 1, -140),
    Position               = UDim2.new(0, 12, 0, 60),
    BackgroundColor3       = Color3.fromRGB(8, 8, 12),
    BackgroundTransparency = 0.15,
    TextColor3             = Color3.fromRGB(130, 255, 160),
    TextStrokeTransparency = 1,
    MultiLine              = true,
    ClearTextOnFocus       = false,
    Text                   = "",
    Font                   = Enum.Font.Code,
    TextSize               = 16,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Top,
    ZIndex                 = 3,
    PlaceholderText        = "-- " .. t("execute") .. "...",
    PlaceholderColor3      = Color3.fromRGB(90, 90, 100),
}, execPage)
corner(ScriptBox, 12)

local editorStroke = new("UIStroke", {
    Thickness       = 1,
    Color           = THEMES.Dark.accent,
    Transparency    = 0.8,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, ScriptBox)

local ExecuteBtn = new("TextButton", {
    Text                   = "",
    Size                   = UDim2.new(0, 160, 0, 40),
    Position               = UDim2.new(0, 12, 1, -52),
    BackgroundColor3       = Color3.fromRGB(0, 150, 220),
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, execPage)
corner(ExecuteBtn, 10)
icon(ExecuteBtn, ICONS.execute, UDim2.new(0, 16, 0, 16), UDim2.new(0, 14, 0.5, -8),
     Color3.new(1,1,1), 4)
local execLabel = new("TextLabel", {
    Size                   = UDim2.new(1, -40, 1, 0),
    Position               = UDim2.new(0, 38, 0, 0),
    BackgroundTransparency = 1,
    Text                   = t("execute"),
    TextColor3             = Color3.new(1,1,1),
    Font                   = FONT_BOLD,
    TextSize               = 15,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 4,
}, ExecuteBtn)
addHover(ExecuteBtn, Color3.fromRGB(0, 150, 220), Color3.fromRGB(0, 180, 255))

local ClearBtn = new("TextButton", {
    Text                   = "",
    Size                   = UDim2.new(0, 130, 0, 40),
    Position               = UDim2.new(1, -142, 1, -52),
    BackgroundColor3       = Color3.fromRGB(45, 45, 55),
    BackgroundTransparency = 0.2,
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, execPage)
corner(ClearBtn, 10)
icon(ClearBtn, ICONS.clear, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0.5, -8),
     Color3.fromRGB(255, 160, 160), 4)
local clearLabel = new("TextLabel", {
    Size                   = UDim2.new(1, -38, 1, 0),
    Position               = UDim2.new(0, 36, 0, 0),
    BackgroundTransparency = 1,
    Text                   = t("clear"),
    TextColor3             = Color3.fromRGB(255, 200, 200),
    Font                   = FONT_REGULAR,
    TextSize               = 14,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 4,
}, ClearBtn)
addHover(ClearBtn, Color3.fromRGB(45, 45, 55), Color3.fromRGB(90, 40, 50))

-- ============================================================
-- Tab persistence
-- ============================================================
local tabsData    = {}
local activeTabId = nil
local rebuildDepth = 0

local function saveTabs()
    if not hasFS then return end
    safeCall(FS.write, tabsPath, HttpService:JSONEncode(tabsData))
end

local function loadTabs()
    if not (FS.read and FS.exists) then return end
    if not fileExists(tabsPath) then return end
    local ok, raw = safeCall(FS.read, tabsPath)
    if not ok or type(raw) ~= "string" then return end
    local ok2, data = safeCall(HttpService.JSONDecode, HttpService, raw)
    if ok2 and type(data) == "table" then tabsData = data end
end

local function rebuildTabBar()
    -- [NEW] Guard от рекурсии
    if rebuildDepth > 3 then return end
    rebuildDepth += 1

    for _, child in ipairs(TabBar:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local ids = {}
    for id in pairs(tabsData) do ids[#ids + 1] = id end
    table.sort(ids)

    local order = 0
    for _, id in ipairs(ids) do
        local tab = tabsData[id]
        order += 1
        local btn = new("TextButton", {
            Name                   = "Tab_" .. id,
            Size                   = UDim2.new(0, 100, 1, -6),
            BackgroundColor3       = Color3.fromRGB(28, 28, 36),
            BackgroundTransparency = 0.3,
            TextColor3             = Color3.fromRGB(200, 200, 210),
            Text                   = tab.name or ("Tab " .. order),
            Font                   = FONT_REGULAR,
            TextSize               = 13,
            LayoutOrder            = order,
            BorderSizePixel        = 0,
            ZIndex                 = 4,
        }, TabBar)
        corner(btn, 8)
        addHover(btn, Color3.fromRGB(28, 28, 36), Color3.fromRGB(40, 40, 52),
                 UDim2.new(0, 100, 1, -6), UDim2.new(0, 102, 1, -4))

        btn.MouseButton1Click:Connect(function()
            if activeTabId and tabsData[activeTabId] then
                tabsData[activeTabId].code = ScriptBox.Text
            end
            activeTabId = id
            ScriptBox.Text = tabsData[id].code or ""
            for _, child in ipairs(TabBar:GetChildren()) do
                if child:IsA("TextButton") and child.Name ~= "AddTab" then
                    child.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                    child.BackgroundTransparency = 0.3
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
            btn.BackgroundTransparency = 0.1
            saveTabs()
        end)
    end

    local addBtn = new("TextButton", {
        Name                   = "AddTab",
        Size                   = UDim2.new(0, 36, 1, -6),
        BackgroundColor3       = Color3.fromRGB(35, 55, 45),
        BackgroundTransparency = 0.2,
        Text                   = "+",
        TextColor3             = Color3.new(1,1,1),
        Font                   = FONT_BOLD,
        TextSize               = 20,
        LayoutOrder            = 9999,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
    }, TabBar)
    corner(addBtn, 8)
    addHover(addBtn, Color3.fromRGB(35, 55, 45), Color3.fromRGB(50, 90, 65),
             UDim2.new(0, 36, 1, -6), UDim2.new(0, 38, 1, -4))

    addBtn.MouseButton1Click:Connect(function()
        if activeTabId and tabsData[activeTabId] then
            tabsData[activeTabId].code = ScriptBox.Text
        end
        local id = makeId()  -- [FIX] GenerateGUID
        tabsData[id] = { name = t("newTab"), code = "" }
        activeTabId = id
        saveTabs()
        rebuildTabBar()
        ScriptBox.Text = ""
    end)

    -- Подсветка активной вкладки
    if activeTabId and tabsData[activeTabId] then
        local activeBtn = TabBar:FindFirstChild("Tab_" .. activeTabId)
        if activeBtn then
            activeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
            activeBtn.BackgroundTransparency = 0.1
        end
    else
        local firstId = ids[1]
        if firstId then
            activeTabId = firstId
            ScriptBox.Text = tabsData[firstId].code or ""
            local firstBtn = TabBar:FindFirstChild("Tab_" .. firstId)
            if firstBtn then
                firstBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
                firstBtn.BackgroundTransparency = 0.1
            end
        else
            -- [NEW] Авто-создание первой вкладки
            local id = makeId()
            tabsData[id] = { name = t("newTab"), code = "" }
            activeTabId = id
            saveTabs()
            rebuildDepth -= 1
            return rebuildTabBar()
        end
    end

    rebuildDepth -= 1
end

-- ============================================================
-- Page: ScriptBlox / RoScripts
-- ============================================================
local scriptPage = makePage("script")

local SearchBox = new("TextBox", {
    Name                   = "SearchBox",
    Size                   = UDim2.new(1, -110, 0, 40),
    Position               = UDim2.new(0, 12, 0, 12),
    BackgroundColor3       = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.2,
    TextColor3             = Color3.new(1,1,1),
    PlaceholderText        = t("search"),
    PlaceholderColor3      = Color3.fromRGB(100, 100, 110),
    Text                   = "",
    Font                   = FONT_REGULAR,
    TextSize               = 14,
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, scriptPage)
corner(SearchBox, 10)
new("UIPadding", { PaddingLeft = UDim.new(0, 40) }, SearchBox)
icon(SearchBox, ICONS.search, UDim2.new(0, 16, 0, 16), UDim2.new(0, 14, 0.5, -8),
     Color3.fromRGB(120, 120, 130), 4)

local SearchBtn = new("TextButton", {
    Text                   = "Go",
    Size                   = UDim2.new(0, 60, 0, 40),
    Position               = UDim2.new(1, -72, 0, 12),
    BackgroundColor3       = Color3.fromRGB(0, 150, 220),
    TextColor3             = Color3.new(1,1,1),
    Font                   = FONT_BOLD,
    TextSize               = 14,
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, scriptPage)
corner(SearchBtn, 10)
addHover(SearchBtn, Color3.fromRGB(0, 150, 220), Color3.fromRGB(0, 180, 255))

local ResultsFrame = new("ScrollingFrame", {
    Size                   = UDim2.new(1, -24, 1, -68),
    Position               = UDim2.new(0, 12, 0, 62),
    BackgroundTransparency = 1,
    CanvasSize             = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize    = Enum.AutomaticSize.Y,  -- [FIX]
    ScrollBarThickness     = 4,
    ScrollBarImageColor3   = Color3.fromRGB(80, 80, 100),
    ZIndex                 = 3,
}, scriptPage)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, ResultsFrame)

local function clearResults()
    for _, child in pairs(ResultsFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

-- [FIX] Ленивый резолвер кода
local function resolveScriptCode(scriptData)
    if type(scriptData.script) == "string" and #scriptData.script > 0 then
        return scriptData.script
    end
    if type(scriptData.loadstringUrl) == "string" and #scriptData.loadstringUrl > 0 then
        return safeHttpGet(scriptData.loadstringUrl)
    end
    return nil
end

local function addScriptCard(scriptData, order)
    local card = new("Frame", {
        Size                   = UDim2.new(1, 0, 0, 90),
        BackgroundColor3       = Color3.fromRGB(22, 22, 30),
        BackgroundTransparency = 0.15,
        BorderSizePixel        = 0,
        LayoutOrder            = order,
        ZIndex                 = 4,
    }, ResultsFrame)
    corner(card, 12)

    new("Frame", {
        Size                   = UDim2.new(0, 3, 0.7, 0),
        Position               = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3       = THEMES[currentTheme].accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel        = 0,
        ZIndex                 = 5,
    }, card)

    new("TextLabel", {
        Size                   = UDim2.new(1, -20, 0, 22),
        Position               = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text                   = scriptData.title or "Untitled",
        TextColor3             = Color3.new(1,1,1),
        Font                   = FONT_BOLD,
        TextSize               = 15,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, card)

    new("TextLabel", {
        Size                   = UDim2.new(1, -20, 0, 18),
        Position               = UDim2.new(0, 14, 0, 32),
        BackgroundTransparency = 1,
        Text                   = scriptData.gameName or "Unknown Game",
        TextColor3             = Color3.fromRGB(140, 140, 155),
        Font                   = FONT_REGULAR,
        TextSize               = 12,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, card)

    local openBtn = new("TextButton", {
        Text             = t("open"),
        Size             = UDim2.new(0, 100, 0, 30),
        Position         = UDim2.new(1, -110, 1, -38),
        BackgroundColor3 = Color3.fromRGB(35, 35, 48),
        BackgroundTransparency = 0.2,
        TextColor3       = Color3.fromRGB(200, 220, 255),
        Font             = FONT_REGULAR,
        TextSize         = 13,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, card)
    corner(openBtn, 8)
    addHover(openBtn, Color3.fromRGB(35, 35, 48), Color3.fromRGB(50, 60, 80))

    local runBtn = new("TextButton", {
        Text             = t("runNow"),
        Size             = UDim2.new(0, 100, 0, 30),
        Position         = UDim2.new(1, -220, 1, -38),
        BackgroundColor3 = Color3.fromRGB(0, 120, 70),
        TextColor3       = Color3.new(1,1,1),
        Font             = FONT_BOLD,
        TextSize         = 13,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, card)
    corner(runBtn, 8)
    addHover(runBtn, Color3.fromRGB(0, 120, 70), Color3.fromRGB(0, 160, 90))

    openBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local code = resolveScriptCode(scriptData) or "-- Failed to fetch script"
            if activeTabId and tabsData[activeTabId] then
                tabsData[activeTabId].code = ScriptBox.Text
            end
            local id = makeId()
            tabsData[id] = { name = scriptData.title or "Script", code = code }
            activeTabId = id
            saveTabs()
            rebuildTabBar()
            ScriptBox.Text = code
            switchCategory("execute")
        end)
    end)

    runBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local code = resolveScriptCode(scriptData)
            if not code then return end
            local loader = getLoader()
            if loader then
                local fn = loader(code)
                if fn then pcall(fn) end
            end
        end)
    end)
end

local function fetchAndRender(url, normalizer)
    local response = safeHttpGet(url)
    if not response then
        writeLog("HTTP", "Request failed: " .. tostring(url))
        return false
    end
    local ok2, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not ok2 or type(data) ~= "table" then
        writeLog("HTTP", "JSON decode failed: " .. tostring(response):sub(1, 80))
        return false
    end
    local scripts = normalizer(data)
    if not scripts or #scripts == 0 then return false end
    for i, s in ipairs(scripts) do addScriptCard(s, i) end
    return true
end

local function normalizeRoScripts(data)
    if not (data.result and data.result.scripts) then return nil end
    local out = {}
    for _, s in ipairs(data.result.scripts) do
        if type(s) == "table" then
            out[#out + 1] = {
                title         = s.title,
                gameName      = s.game and s.game.name or "Unknown Game",
                loadstringUrl = s.loadstring,
                script        = nil,
            }
        end
    end
    return out
end

local function normalizeScriptBlox(data)
    if not (data.result and data.result.scripts) then return nil end
    local out = {}
    for _, s in ipairs(data.result.scripts) do
        if type(s) == "table" then
            out[#out + 1] = {
                title    = s.title,
                gameName = s.game and s.game.name or "Unknown Game",
                script   = s.script or "-- No code",
            }
        end
    end
    return out
end

local function normalizeScriptBloxOfficial(data)
    local list
    if data.result and data.result.scripts then list = data.result.scripts
    elseif data.scripts then list = data.scripts
    else return nil end
    local out = {}
    for _, s in ipairs(list) do
        if type(s) == "table" then
            out[#out + 1] = {
                title    = s.title or s.name,
                gameName = s.game and s.game.name or "Unknown Game",
                script   = s.script or s.code or "-- No code",
            }
        end
    end
    return out
end

local function performSearch(query)
    if query == "" then return end
    clearResults()

    task.spawn(function()
        local enc = HttpService:UrlEncode(query)

        if fetchAndRender(CONFIG.RoScriptsAPI .. "/scripts/search?q=" .. enc .. "&max=10", normalizeRoScripts) then
            return
        end
        if fetchAndRender(CONFIG.ScriptBloxProxy .. "/search?q=" .. enc .. "&max=10", normalizeScriptBlox) then
            return
        end
        if fetchAndRender(CONFIG.ScriptBloxOfficial .. "/search?q=" .. enc .. "&max=10", normalizeScriptBloxOfficial) then
            return
        end

        local errCard = new("Frame", {
            Size             = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = Color3.fromRGB(60, 25, 25),
            BackgroundTransparency = 0.3,
            BorderSizePixel  = 0,
            LayoutOrder      = 1,
            ZIndex           = 4,
        }, ResultsFrame)
        corner(errCard, 12)
        new("TextLabel", {
            Size                   = UDim2.new(1, -20, 1, -10),
            Position               = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text                   = "Не удалось загрузить скрипты.\nВсе источники недоступны.",
            TextColor3             = Color3.fromRGB(255, 200, 200),
            Font                   = FONT_REGULAR,
            TextSize               = 13,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
            ZIndex                 = 5,
        }, errCard)
    end)
end

SearchBtn.MouseButton1Click:Connect(function()
    performSearch(SearchBox.Text)
end)

-- ============================================================
-- Page: Infinite Yield
-- ============================================================
local iyPage = makePage("iy")

new("TextLabel", {
    Size                   = UDim2.new(1, -24, 0, 60),
    Position               = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text                   = "Infinite Yield\nMost powerful admin commands.",
    TextColor3             = Color3.fromRGB(180, 180, 190),
    Font                   = FONT_REGULAR,
    TextSize               = 16,
    TextYAlignment         = Enum.TextYAlignment.Top,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 3,
}, iyPage)

local IYBtn = new("TextButton", {
    Text                   = "",
    Size                   = UDim2.new(0, 280, 0, 48),
    Position               = UDim2.new(0.5, -140, 0, 100),
    BackgroundColor3       = Color3.fromRGB(70, 50, 140),
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, iyPage)
corner(IYBtn, 12)
icon(IYBtn, ICONS.iy, UDim2.new(0, 20, 0, 20), UDim2.new(0, 16, 0.5, -10),
     Color3.new(1,1,1), 4)
new("TextLabel", {
    Size                   = UDim2.new(1, -50, 1, 0),
    Position               = UDim2.new(0, 46, 0, 0),
    BackgroundTransparency = 1,
    Text                   = "Run Infinite Yield",
    TextColor3             = Color3.new(1,1,1),
    Font                   = FONT_BOLD,
    TextSize               = 17,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 4,
}, IYBtn)
addHover(IYBtn, Color3.fromRGB(70, 50, 140), Color3.fromRGB(100, 70, 190))

IYBtn.MouseButton1Click:Connect(function()
    local loader = getLoader()
    if not loader then return end
    task.spawn(function()
        local ok, err = pcall(function()
            local src = safeHttpGet(CONFIG.IYUrl)
            if not src then error("Failed to fetch IY source") end
            local fn = loader(src)
            if fn then fn() end
        end)
        if not ok then
            writeLog("IY_ERROR", tostring(err))
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title    = "NovaX",
                    Text     = "Infinite Yield load failed",
                    Duration = 4,
                })
            end)
        end
    end)
end)

-- ============================================================
-- Page: Settings
-- ============================================================
local settingsPage = makePage("settings")

local SettingsScroll = new("ScrollingFrame", {
    Size                   = UDim2.new(1, -24, 1, -24),
    Position               = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    CanvasSize             = UDim2.new(0, 0, 0, 700),
    ScrollBarThickness     = 4,
    ScrollBarImageColor3   = Color3.fromRGB(80, 80, 100),
    ZIndex                 = 3,
}, settingsPage)
new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, SettingsScroll)

local sectionHeaders = {}
local function sectionHeader(text, order, key)
    local lbl = new("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = (THEMES[currentTheme] or THEMES.Dark).accent,
        Font                   = FONT_BOLD,
        TextSize               = 15,
        TextXAlignment         = Enum.TextXAlignment.Left,
        LayoutOrder            = order,
        ZIndex                 = 4,
    }, SettingsScroll)
    if key then sectionHeaders[key] = lbl end
    return lbl
end

sectionHeader(t("theme"), 1, "theme")

local themeRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
    LayoutOrder            = 2,
    ZIndex                 = 4,
}, SettingsScroll)

local themeX = 0
for _, name in ipairs(THEME_ORDER) do
    local btn = new("TextButton", {
        Size                   = UDim2.new(0, 90, 0, 32),
        Position               = UDim2.new(0, themeX, 0, 2),
        BackgroundColor3       = Color3.fromRGB(35, 35, 45),
        BackgroundTransparency = 0.3,
        TextColor3             = Color3.fromRGB(220, 220, 230),
        Text                   = name,
        Font                   = FONT_REGULAR,
        TextSize               = 14,
        BorderSizePixel        = 0,
        ZIndex                 = 5,
    }, themeRow)
    corner(btn, 8)
    addHover(btn, Color3.fromRGB(35, 35, 45), Color3.fromRGB(55, 55, 70),
             UDim2.new(0, 90, 0, 32), UDim2.new(0, 92, 0, 34))
    btn.MouseButton1Click:Connect(function()
        if applyTheme then applyTheme(name) end
    end)
    themeX += 100
end

sectionHeader(t("glow"), 3, "glow")

local glowRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
    LayoutOrder            = 4,
    ZIndex                 = 4,
}, SettingsScroll)

glowToggle = new("TextButton", {
    Text                   = "Glow: ON",
    Size                   = UDim2.new(0, 120, 0, 32),
    Position               = UDim2.new(0, 0, 0, 2),
    BackgroundColor3       = Color3.fromRGB(0, 130, 70),
    BorderSizePixel        = 0,
    TextColor3             = Color3.new(1,1,1),
    Font                   = FONT_BOLD,
    TextSize               = 13,
    ZIndex                 = 5,
}, glowRow)
corner(glowToggle, 8)
addHover(glowToggle, Color3.fromRGB(0, 130, 70), Color3.fromRGB(0, 170, 90),
         UDim2.new(0, 120, 0, 32), UDim2.new(0, 122, 0, 34))

glowToggle.MouseButton1Click:Connect(function()
    glowEnabled = not glowEnabled
    glowToggle.Text = "Glow: " .. (glowEnabled and "ON" or "OFF")
    glowToggle.BackgroundColor3 = glowEnabled and Color3.fromRGB(0, 130, 70) or Color3.fromRGB(70, 30, 35)
    GlowInner.Thickness = glowEnabled and 1.5 or 0
    GlowOuter.Thickness = glowEnabled and 6 or 0
    if saveConfig then saveConfig() end
end)

local colorRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
    LayoutOrder            = 5,
    ZIndex                 = 4,
}, SettingsScroll)

local glowColors = {
    { name = "Cyan",   c = Color3.fromRGB(0, 220, 255) },
    { name = "Pink",   c = Color3.fromRGB(220, 80, 255) },
    { name = "Lime",   c = Color3.fromRGB(0, 230, 120) },
    { name = "Gold",   c = Color3.fromRGB(255, 190, 50) },
    { name = "Red",    c = Color3.fromRGB(255, 70, 90) },
}
local cx = 0
for _, gc in ipairs(glowColors) do
    local cb = new("TextButton", {
        Size             = UDim2.new(0, 70, 0, 30),
        Position         = UDim2.new(0, cx, 0, 3),
        BackgroundColor3 = gc.c,
        TextColor3       = Color3.fromRGB(0, 0, 0),
        Text             = gc.name,
        Font             = FONT_BOLD,
        TextSize         = 11,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, colorRow)
    corner(cb, 6)
    addHover(cb, gc.c, gc.c:Lerp(Color3.new(1,1,1), 0.2),
             UDim2.new(0, 70, 0, 30), UDim2.new(0, 72, 0, 32))
    cb.MouseButton1Click:Connect(function()
        userGlowColor = gc.c
        GlowInner.Color = gc.c
        GlowOuter.Color = gc.c
        if toggleGlow then toggleGlow.Color = gc.c end
        if saveConfig then saveConfig() end
    end)
    cx += 78
end

sectionHeader(t("language"), 6, "language")

local langRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
    LayoutOrder            = 7,
    ZIndex                 = 4,
}, SettingsScroll)

local lx = 0
for _, code in ipairs(LANG_ORDER) do
    if LOCALES[code] then
        local lb = new("TextButton", {
            Size                   = UDim2.new(0, 60, 0, 32),
            Position               = UDim2.new(0, lx, 0, 2),
            BackgroundColor3       = Color3.fromRGB(35, 35, 45),
            BackgroundTransparency = 0.3,
            TextColor3             = Color3.fromRGB(220, 220, 230),
            Text                   = code,
            Font                   = FONT_BOLD,
            TextSize               = 14,
            BorderSizePixel        = 0,
            ZIndex                 = 5,
        }, langRow)
        corner(lb, 8)
        addHover(lb, Color3.fromRGB(35, 35, 45), Color3.fromRGB(55, 55, 70),
                 UDim2.new(0, 60, 0, 32), UDim2.new(0, 62, 0, 34))
        lb.MouseButton1Click:Connect(function()
            currentLang = code
            if saveConfig then saveConfig() end
            if applyLang then applyLang() end
        end)
        lx += 68
    end
end

sectionHeader(t("autoexec"), 8, "autoexec")

local AutoExecBox = new("TextBox", {
    Size                   = UDim2.new(1, -20, 0, 90),
    BackgroundColor3       = Color3.fromRGB(10, 10, 14),
    BackgroundTransparency = 0.2,
    TextColor3             = Color3.fromRGB(130, 255, 160),
    Text                   = "",
    PlaceholderText        = "-- Auto-execute script on load",
    PlaceholderColor3      = Color3.fromRGB(90, 90, 100),
    MultiLine              = true,
    ClearTextOnFocus       = false,
    Font                   = Enum.Font.Code,
    TextSize               = 13,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Top,
    BorderSizePixel        = 0,
    LayoutOrder            = 9,
    ZIndex                 = 4,
}, SettingsScroll)
corner(AutoExecBox, 10)

local SaveAutoBtn = new("TextButton", {
    Text                   = t("save"),
    Size                   = UDim2.new(0, 140, 0, 34),
    BackgroundColor3       = Color3.fromRGB(0, 130, 190),
    TextColor3             = Color3.new(1,1,1),
    Font                   = FONT_BOLD,
    TextSize               = 14,
    BorderSizePixel        = 0,
    LayoutOrder            = 10,
    ZIndex                 = 5,
}, SettingsScroll)
corner(SaveAutoBtn, 8)
addHover(SaveAutoBtn, Color3.fromRGB(0, 130, 190), Color3.fromRGB(0, 160, 220),
         UDim2.new(0, 140, 0, 34), UDim2.new(0, 142, 0, 36))

SaveAutoBtn.MouseButton1Click:Connect(function()
    if hasFS then
        safeCall(FS.write, execPath, AutoExecBox.Text)
        SaveAutoBtn.Text = "Saved!"
        task.wait(1.5)
        SaveAutoBtn.Text = t("save")
    end
end)

-- [NEW] Подгрузка автоэкзека в UI
task.defer(function()
    if FS.read and fileExists(execPath) then
        local ok, txt = safeCall(FS.read, execPath)
        if ok and type(txt) == "string" and #txt > 0 then
            AutoExecBox.Text = txt
        end
    end
end)

local ResetBtn = new("TextButton", {
    Text                   = "Factory Reset",
    Size                   = UDim2.new(0, 160, 0, 34),
    BackgroundColor3       = Color3.fromRGB(70, 25, 30),
    TextColor3             = Color3.fromRGB(255, 200, 200),
    Font                   = FONT_REGULAR,
    TextSize               = 13,
    BorderSizePixel        = 0,
    LayoutOrder            = 11,
    ZIndex                 = 5,
}, SettingsScroll)
corner(ResetBtn, 8)
addHover(ResetBtn, Color3.fromRGB(70, 25, 30), Color3.fromRGB(120, 35, 45),
         UDim2.new(0, 160, 0, 34), UDim2.new(0, 162, 0, 36))

-- ============================================================
-- Page: Browser
-- ============================================================
local browserPage = makePage("browser")

local UrlBox = new("TextBox", {
    Size                   = UDim2.new(1, -110, 0, 40),
    Position               = UDim2.new(0, 12, 0, 12),
    BackgroundColor3       = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.2,
    TextColor3             = Color3.new(1,1,1),
    PlaceholderText        = "https://...",
    PlaceholderColor3      = Color3.fromRGB(100, 100, 110),
    Text                   = "",
    Font                   = FONT_REGULAR,
    TextSize               = 14,
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, browserPage)
corner(UrlBox, 10)

local BrowserGoBtn = new("TextButton", {
    Text             = "Go",
    Size             = UDim2.new(0, 60, 0, 40),
    Position         = UDim2.new(1, -72, 0, 12),
    BackgroundColor3 = Color3.fromRGB(0, 150, 220),
    TextColor3       = Color3.new(1,1,1),
    Font             = FONT_BOLD,
    TextSize         = 14,
    BorderSizePixel  = 0,
    ZIndex           = 3,
}, browserPage)
corner(BrowserGoBtn, 10)
addHover(BrowserGoBtn, Color3.fromRGB(0, 150, 220), Color3.fromRGB(0, 180, 255))

local BrowserPlaceholder = new("Frame", {
    Size                   = UDim2.new(1, -24, 1, -68),
    Position               = UDim2.new(0, 12, 0, 62),
    BackgroundColor3       = Color3.fromRGB(22, 22, 30),
    BackgroundTransparency = 0.3,
    BorderSizePixel        = 0,
    ZIndex                 = 3,
}, browserPage)
corner(BrowserPlaceholder, 12)

local BrowserText = new("TextLabel", {
    Size                   = UDim2.new(1, -30, 1, -20),
    Position               = UDim2.new(0, 15, 0, 10),
    BackgroundTransparency = 1,
    Text                   = "Browser placeholder\n\nRoblox cannot render real web pages.\nВведи URL и нажми Go — покажу первые 4000 символов ответа.",
    TextColor3             = Color3.fromRGB(120, 120, 135),
    Font                   = FONT_REGULAR,
    TextSize               = 14,
    TextWrapped            = true,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Top,
    ZIndex                 = 4,
}, BrowserPlaceholder)

BrowserGoBtn.MouseButton1Click:Connect(function()
    local url = UrlBox.Text
    if url == "" then return end
    if not url:match("^https://") then
        BrowserText.Text = "Only HTTPS URLs allowed"
        return
    end
    BrowserText.Text = "Loading " .. url .. "..."
    task.spawn(function()
        local res = safeHttpGet(url)
        if not res then
            BrowserText.Text = "❌ Failed to fetch:\n" .. tostring(url)
            writeLog("BROWSER", "Fetch failed: " .. tostring(url))
            return
        end
        BrowserText.Text = string.format("[%d bytes]\n\n%s", #res, res:sub(1, 4000))
        writeLog("BROWSER", "Fetched " .. url .. " (" .. #res .. " bytes)")
    end)
end)

-- ============================================================
-- Close button
-- ============================================================
CloseBtn = new("TextButton", {
    Name                   = "CloseBtn",
    Text                   = "",
    Size                   = UDim2.new(0, 52, 0, 52),
    Position               = UDim2.new(1, -24, 1, -24),
    AnchorPoint            = Vector2.new(1, 1),
    BackgroundColor3       = THEMES.Dark.closeAccent,
    BackgroundTransparency = 0.1,
    BorderSizePixel        = 0,
    ZIndex                 = 60,
}, Frame)
corner(CloseBtn, 14)
icon(CloseBtn, ICONS.close, UDim2.new(0, 22, 0, 22), UDim2.new(0.5, -11, 0.5, -11),
     Color3.new(1,1,1), 61)

closeGlow = new("UIStroke", {
    Thickness       = 2,
    Color           = THEMES.Dark.closeAccent:Lerp(Color3.new(1,1,1), 0.2),
    Transparency    = 0.4,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, CloseBtn)

addHover(CloseBtn, THEMES.Dark.closeAccent, THEMES.Dark.closeAccent:Lerp(Color3.new(1,1,1), 0.15),
         UDim2.new(0, 52, 0, 52), UDim2.new(0, 56, 0, 56))

-- ============================================================
-- Config persistence
-- ============================================================
local cfg = {}

function saveConfig()
    if not hasFS then return end
    cfg.theme       = currentTheme
    cfg.glowEnabled = glowEnabled
    cfg.glowColor   = userGlowColor and {
        userGlowColor.R * 255,
        userGlowColor.G * 255,
        userGlowColor.B * 255,
    } or nil
    cfg.lang        = currentLang
    safeCall(FS.write, cfgPath, HttpService:JSONEncode(cfg))
end

function applyLang()
    if execLabel then execLabel.Text = t("execute") end
    if clearLabel then clearLabel.Text = t("clear") end
    if SaveAutoBtn then SaveAutoBtn.Text = t("save") end
    if SearchBox then SearchBox.PlaceholderText = t("search") end
    if ScriptBox then ScriptBox.PlaceholderText = "-- " .. t("execute") .. "..." end
    if sectionHeaders then
        if sectionHeaders.theme    then sectionHeaders.theme.Text    = t("theme")    end
        if sectionHeaders.glow     then sectionHeaders.glow.Text     = t("glow")     end
        if sectionHeaders.language then sectionHeaders.language.Text = t("language") end
        if sectionHeaders.autoexec then sectionHeaders.autoexec.Text = t("autoexec") end
    end
end

local function loadConfig()
    if not (FS.read and FS.exists) then return end
    if not fileExists(cfgPath) then return end
    local ok, raw = safeCall(FS.read, cfgPath)
    if not ok or type(raw) ~= "string" then return end
    local ok2, data = safeCall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end

    if data.lang and LOCALES[data.lang] then
        currentLang = data.lang
        if applyLang then applyLang() end
    end

    if data.theme and THEMES[data.theme] and applyTheme then applyTheme(data.theme, true) end

    if type(data.glowColor) == "table" and #data.glowColor >= 3 then
        local c = Color3.fromRGB(
            clampColor(data.glowColor[1]),
            clampColor(data.glowColor[2]),
            clampColor(data.glowColor[3])
        )
        userGlowColor = c
        GlowInner.Color = c
        GlowOuter.Color = c
        if toggleGlow then toggleGlow.Color = c end
    end

    if data.glowEnabled ~= nil then
        glowEnabled = data.glowEnabled
        if glowToggle then
            glowToggle.Text = "Glow: " .. (glowEnabled and "ON" or "OFF")
            glowToggle.BackgroundColor3 = glowEnabled and Color3.fromRGB(0, 130, 70) or Color3.fromRGB(70, 30, 35)
        end
        GlowInner.Thickness = glowEnabled and 1.5 or 0
        GlowOuter.Thickness = glowEnabled and 6 or 0
    end
end

-- ============================================================
-- Theme
-- ============================================================
function applyTheme(name, skipSave)
    local t2 = THEMES[name]
    if not t2 then return end
    currentTheme = name

    TweenService:Create(Frame, TweenInfo.new(0.3), {
        BackgroundColor3 = t2.frame,
    }):Play()

    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, t2.frame:Lerp(t2.accent, 0.08)),
        ColorSequenceKeypoint.new(0.5, t2.frame),
        ColorSequenceKeypoint.new(1, t2.frame:Lerp(Color3.new(0,0,0), 0.3)),
    })

    local glowColor = userGlowColor or t2.accent
    GlowInner.Color = glowColor
    GlowOuter.Color = glowColor
    if toggleGlow then toggleGlow.Color = glowColor end

    SidebarTitle.TextColor3 = t2.accent
    editorStroke.Color = t2.accent

    if closeGlow then
        closeGlow.Color = t2.closeAccent:Lerp(Color3.new(1,1,1), 0.2)
    end

    if ToggleButton then
        local togIcon = ToggleButton:FindFirstChildOfClass("ImageLabel")
        if togIcon then
            TweenService:Create(togIcon, TweenInfo.new(0.3), {
                ImageColor3 = glowColor,
            }):Play()
        end
    end

    for k, btn in pairs(categoryButtons) do
        local active = (k == currentCategory)
        for _, ch in pairs(btn:GetChildren()) do
            if ch:IsA("ImageLabel") then
                ch.ImageColor3 = active and t2.accent or Color3.fromRGB(160, 160, 170)
            end
        end
    end

    if hasFS then safeCall(FS.write, themePath, name) end
    if not skipSave and saveConfig then saveConfig() end
end

local function loadSavedTheme()
    if not (FS.read and FS.exists) then return end
    if not fileExists(themePath) then return end
    local ok, saved = safeCall(FS.read, themePath)
    if ok and type(saved) == "string" then
        saved = saved:gsub("%s+$", "")
        if THEMES[saved] then applyTheme(saved, true) end
    end
end

-- ============================================================
-- Execute logic
-- ============================================================
ExecuteBtn.MouseButton1Click:Connect(function()
    -- [FIX] Подстраховка на случай отсутствия вкладки
    if not (activeTabId and tabsData[activeTabId]) then
        local id = makeId()
        tabsData[id] = { name = t("newTab"), code = "" }
        activeTabId = id
        rebuildTabBar()
    end

    local code = ScriptBox.Text
    if code == "" then
        execLabel.Text = t("empty")
        task.wait(1)
        execLabel.Text = t("execute")
        return
    end

    execLabel.Text = t("running")
    ExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)

    local loader = getLoader()
    if not loader then
        execLabel.Text = "Unsupported"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.wait(1)
        execLabel.Text = t("execute")
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
        return
    end

    local fn, err = loader(code)
    if not fn then
        execLabel.Text = t("syntax")
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        writeLog("SYNTAX_ERROR", err)
    else
        local ok, result = pcall(fn)
        if ok then
            execLabel.Text = t("done")
            ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
            writeLog("SUCCESS", "Script executed.")
        else
            execLabel.Text = t("runtime")
            ExecuteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            writeLog("RUNTIME_ERROR", result)
        end
    end

    if activeTabId and tabsData[activeTabId] then
        tabsData[activeTabId].code = code
        saveTabs()
    end

    task.wait(1.5)
    execLabel.Text = t("execute")
    ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
end)

ClearBtn.MouseButton1Click:Connect(function()
    ScriptBox.Text = ""
    if activeTabId and tabsData[activeTabId] then
        tabsData[activeTabId].code = ""
        saveTabs()
    end
end)

-- ============================================================
-- Close / Open
-- ============================================================
CloseBtn.MouseButton1Click:Connect(function()
    if activeTabId and tabsData[activeTabId] then
        tabsData[activeTabId].code = ScriptBox.Text
        saveTabs()
    end

    local descendants = Frame:GetDescendants()
    for _, inst in ipairs(descendants) do
        if inst:IsA("GuiObject") and inst ~= Frame then
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                TweenService:Create(inst, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
            end
            if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                TweenService:Create(inst, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
            end
            TweenService:Create(inst, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
        end
    end
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
    }):Play()

    task.wait(0.3)
    Frame.Visible = false
    if ToggleButton then ToggleButton.Visible = true end
end)

-- ============================================================
-- Floating Toggle Button
-- ============================================================
ToggleButton = new("TextButton", {
    Name                   = "ToggleButton",
    Size                   = UDim2.new(0, 56, 0, 56),
    Position               = UDim2.new(0.5, 0, 0, 24),
    AnchorPoint            = Vector2.new(0.5, 0),
    BackgroundColor3       = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.1,
    Text                   = "",
    BorderSizePixel        = 0,
    ZIndex                 = 100,
}, ScreenGui)
corner(ToggleButton, 14)

toggleGlow = new("UIStroke", {
    Thickness       = 2,
    Color           = THEMES.Dark.accent,
    Transparency    = 0.3,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, ToggleButton)

icon(ToggleButton, ICONS.execute, UDim2.new(0, 24, 0, 24), UDim2.new(0.5, -12, 0.5, -12),
     THEMES.Dark.accent, 101)

addHover(ToggleButton, Color3.fromRGB(12, 12, 16), Color3.fromRGB(25, 25, 35),
         UDim2.new(0, 56, 0, 56), UDim2.new(0, 60, 0, 60))

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = false
    Frame.Visible = true
    Frame.BackgroundTransparency = 1
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.08,
    }):Play()
end)

-- ============================================================
-- Factory Reset
-- ============================================================
do
    local confirmState = false
    ResetBtn.MouseButton1Click:Connect(function()
        if not confirmState then
            confirmState = true
            ResetBtn.Text = "Confirm Reset"
            ResetBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
            task.delay(4, function()
                if confirmState then
                    confirmState = false
                    ResetBtn.Text = "Factory Reset"
                    ResetBtn.BackgroundColor3 = Color3.fromRGB(70, 25, 30)
                end
            end)
        else
            confirmState = false
            if hasFS and FS.delete then
                for _, p in ipairs({ logPath, themePath, tabsPath, execPath, cfgPath }) do
                    if fileExists(p) then safeCall(FS.delete, p) end
                end
            end

            glowEnabled   = true
            currentLang   = "RU"
            userGlowColor = nil
            if glowToggle then
                glowToggle.Text = "Glow: ON"
                glowToggle.BackgroundColor3 = Color3.fromRGB(0, 130, 70)
            end
            GlowInner.Thickness = 1.5
            GlowOuter.Thickness = 6
            applyTheme("Dark")
            if applyLang then applyLang() end

            ResetBtn.Text = "Done!"
            task.wait(1.5)
            ResetBtn.Text = "Factory Reset"
            ResetBtn.BackgroundColor3 = Color3.fromRGB(70, 25, 30)
        end
    end)
end

-- ============================================================
-- Integrity check
-- ============================================================
task.spawn(function()
    if not hasFS then return end
    while ScreenGui.Parent and task.wait(CONFIG.IntegrityInterval) do
        local ok, exists = pcall(FS.folder, sysPath)
        if not ok or not exists then
            writeLog("CRITICAL", "System directory missing — terminating")
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "NovaX Security",
                    Text = "System directory missing. Terminating...",
                    Duration = 5,
                })
            end)
            task.wait(4)
            ScreenGui:Destroy()
            break
        end
    end
end)

-- ============================================================
-- Boot
-- ============================================================
setupFileSystem()
loadTabs()
rebuildTabBar()
loadSavedTheme()
loadConfig()

task.spawn(function()
    task.wait(0.1)
    if FS.read and fileExists(execPath) then
        local ok, code = safeCall(FS.read, execPath)
        if ok and code and code ~= "" then
            local loader = getLoader()
            if loader then
                local fn = loader(code)
                if fn then pcall(fn) end
            end
        end
    end
end)

switchCategory("execute")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NovaX",
        Text = "Loaded successfully!",
        Duration = 5,
    })
end)

writeLog("SYSTEM", "NovaX v3.5 loaded.")
