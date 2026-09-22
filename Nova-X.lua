--[[
    NovaX v2 — Full-Screen Tabbed Executor UI  (fixed)
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
    Title             = "NovaX",
    SysFolder         = "Nova-X-sys",
    MaxLogLines       = 500,
    IntegrityInterval = 10,
    SplashImage       = "rbxassetid://1316045217",
    IYUrl             = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
    ScriptBloxAPI     = "https://scriptblox-api-proxy.vercel.app/api",
}

local THEMES = {
    Dark = { frame = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(0, 255, 255)   },
    Neon = { frame = Color3.fromRGB(10, 10, 30), accent = Color3.fromRGB(255, 0, 255)   },
    Ice  = { frame = Color3.fromRGB(30, 40, 50), accent = Color3.fromRGB(150, 255, 255) },
}
local THEME_ORDER = { "Dark", "Neon", "Ice" }

-- ============================================================
-- [FIX] Forward declarations
-- ============================================================
local currentTheme = "Dark"
local currentLang  = "RU"
local pages        = {}
local applyTheme
local saveConfig
local glowToggle
local glowEnabled  = true
local ToggleButton

-- ============================================================
-- i18n
-- ============================================================
local LOCALES = {
    RU = { execute="Выполнить", clear="Очистить", empty="Пусто!", running="Выполняется...",
           done="Готово!", syntax="Синтаксис", runtime="Ошибка", settings="Настройки",
           browser="Браузер", script="ScriptBlox", iy="Infinite Yield", search="Поиск...",
           fullscreen="Полный экран", glow="Свечение", language="Язык", autoexec="Автозапуск",
           save="Сохранить", open="Открыть", runNow="Запустить", newTab="Новая вкладка" },
    EN = { execute="Execute", clear="Clear", empty="Empty!", running="Running...",
           done="Done!", syntax="Syntax Error", runtime="Runtime Error", settings="Settings",
           browser="Browser", script="ScriptBlox", iy="Infinite Yield", search="Search...",
           fullscreen="Full Screen", glow="Glow", language="Language", autoexec="Autoexec",
           save="Save", open="Open", runNow="Run Now", newTab="New Tab" },
    DE = { execute="Ausführen", clear="Löschen", empty="Leer!", running="Läuft...",
           done="Fertig!", syntax="Syntaxfehler", runtime="Laufzeitfehler",
           settings="Einstellungen", browser="Browser", script="ScriptBlox", iy="Infinite Yield",
           search="Suchen...", fullscreen="Vollbild", glow="Leuchten", language="Sprache",
           autoexec="Autostart", save="Speichern", open="Öffnen", runNow="Jetzt starten",
           newTab="Neuer Tab" },
    ES = { execute="Ejecutar", clear="Limpiar", empty="¡Vacío!", running="Ejecutando...",
           done="¡Hecho!", syntax="Error de sintaxis", runtime="Error en tiempo de ejecución",
           settings="Ajustes", browser="Navegador", script="ScriptBlox", iy="Infinite Yield",
           search="Buscar...", fullscreen="Pantalla completa", glow="Brillo", language="Idioma",
           autoexec="Autoinicio", save="Guardar", open="Abrir", runNow="Ejecutar ahora",
           newTab="Nueva pestaña" },
}

local function t(key)
    local loc = LOCALES[currentLang] or LOCALES.EN
    return loc[key] or key
end

-- ============================================================
-- File system
-- ============================================================
local hasWrite = writefile and appendfile

local sysPath   = CONFIG.SysFolder
local themePath = sysPath .. "/Theme.txt"
local logPath   = sysPath .. "/ExecutionLog.txt"
local tabsPath  = sysPath .. "/tabs.json"
local execPath  = sysPath .. "/autoexec.txt"
local cfgPath   = sysPath .. "/config.json"

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
local function toStr(v) local ok, s = pcall(tostring, v) return ok and s or "<?>" end
local function joinArgs(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = toStr(select(i, ...)) end
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
    local line = string.format("[%s] [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), tag, toStr(msg))
    safeCall(appendfile, logPath, line)
    logLineCount += 1
    rotateLogIfNeeded()
end

local function setupFileSystem()
    if not (writefile and makefolder and isfolder) then return end
    if not isfolder(sysPath) then safeCall(makefolder, sysPath) end
    if not fileExists(logPath)  then safeCall(writefile, logPath,  "NovaX Execution Log\n") end
    if not fileExists(tabsPath) then safeCall(writefile, tabsPath, "{}") end
end

local function installLoggerHooks()
    if not hasWrite then return end
    local oldPrint, oldWarn = print, warn
    print = function(...) writeLog("PRINT", joinArgs(...)); oldPrint(...) end
    warn  = function(...) writeLog("WARN",  joinArgs(...)); oldWarn(...)  end
    writeLog("SYSTEM", "NovaX logger initialized.")
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

local function resolveGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    local player = Players.LocalPlayer
    if player then
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if pg then return pg end
    end
    return nil
end

-- ============================================================
-- ScreenGui + Splash
-- ============================================================
local guiParent = resolveGuiParent()
if not guiParent then
    -- [FIX] last-resort fallback so UI still shows
    local player = Players.LocalPlayer
    guiParent = player and player:WaitForChild("PlayerGui") or Instance.new("Folder")
    if guiParent.ClassName == "Folder" then
        guiParent = game:GetService("CoreGui")
    end
end

local ScreenGui = new("ScreenGui", {
    Name           = "NovaX_UI",
    ResetOnSpawn   = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

do
    local splash = new("ImageLabel", {
        Size                   = UDim2.new(0, 200, 0, 200),
        Position               = UDim2.new(0.5, -100, 0.5, -100),
        BackgroundTransparency = 1,
        Image                  = CONFIG.SplashImage,
        ZIndex                 = 200,
    }, ScreenGui)

    task.spawn(function()
        TweenService:Create(splash, TweenInfo.new(1), { Size = UDim2.new(0, 300, 0, 300) }):Play()
        task.wait(1)
        TweenService:Create(splash, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
        task.wait(0.5)
        splash:Destroy()
    end)
end

-- ============================================================
-- Main Window + Glow
-- ============================================================
local Frame = new("Frame", {
    Name                   = "MainFrame",
    Size                   = UDim2.fromScale(1, 1),
    Position               = UDim2.fromScale(0, 0),
    BackgroundColor3       = THEMES.Dark.frame,
    BackgroundTransparency = 0.15,
    BorderSizePixel        = 0,
    Visible                = false,
    Active                 = true,
    ZIndex                 = 1,
}, ScreenGui)

-- [FIX] initial thickness = 3 so glow is visible by default
local GlowStroke = new("UIStroke", {
    Thickness       = 3,
    Color           = Color3.fromRGB(0, 255, 255),
    Transparency    = 0.4,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, Frame)

-- ============================================================
-- Sidebar
-- ============================================================
local Sidebar = new("Frame", {
    Name             = "Sidebar",
    Size             = UDim2.new(0, 140, 1, 0),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel  = 0,
    ZIndex           = 2,
}, Frame)

local SidebarTitle = new("TextLabel", {
    Size                   = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Text                   = CONFIG.Title,
    TextColor3             = THEMES.Dark.accent,
    Font                   = Enum.Font.SourceSansBold,
    TextSize               = 22,
    ZIndex                 = 3,
}, Sidebar)

local CloseBtn = new("TextButton", {
    Text             = "✕",
    Size             = UDim2.new(0, 30, 0, 30),
    Position         = UDim2.new(1, -35, 0, 10),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
    ZIndex           = 3,
}, Sidebar)
corner(CloseBtn, 6)

local categoryDefs = {
    { key = "execute",  icon = "▶",  label = "Execute"        },
    { key = "script",   icon = "S",  label = "ScriptBlox"     }, -- [FIX] ASCII-safe
    { key = "iy",       icon = "Y",  label = "Infinite Yield" },
    { key = "settings", icon = "*",  label = "Settings"       },
    { key = "browser",  icon = "B",  label = "Browser"        },
}

local categoryButtons = {}
local currentCategory = "execute"

local function switchCategory(key)
    currentCategory = key
    local theme = THEMES[currentTheme] or THEMES.Dark
    for k, btn in pairs(categoryButtons) do
        btn.BackgroundColor3 = (k == key) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(25, 25, 25)
        btn.TextColor3       = (k == key) and theme.accent or Color3.fromRGB(200, 200, 200)
    end
    for k, page in pairs(pages) do
        page.Visible = (k == key)
    end
end

local yOffset = 60
for _, def in ipairs(categoryDefs) do
    local btn = new("TextButton", {
        Name             = "Cat_" .. def.key,
        Size             = UDim2.new(1, -10, 0, 36),
        Position         = UDim2.new(0, 5, 0, yOffset),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        TextColor3       = Color3.fromRGB(200, 200, 200),
        Text             = def.icon .. "  " .. def.label,
        Font             = Enum.Font.SourceSans,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
    }, Sidebar)
    corner(btn, 6)
    btn.MouseButton1Click:Connect(function() switchCategory(def.key) end)
    categoryButtons[def.key] = btn
    yOffset += 42
end

-- ============================================================
-- Content
-- ============================================================
local Content = new("Frame", {
    Name                   = "Content",
    Size                   = UDim2.new(1, -140, 1, 0),
    Position               = UDim2.new(0, 140, 0, 0),
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
    Size                   = UDim2.new(1, -20, 0, 36),
    Position               = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    CanvasSize             = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness     = 0,
    ZIndex                 = 3,
}, execPage)

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding       = UDim.new(0, 4),
    SortOrder     = Enum.SortOrder.LayoutOrder,
}, TabBar)

local ScriptBox = new("TextBox", {
    Size                   = UDim2.new(1, -20, 1, -130),
    Position               = UDim2.new(0, 10, 0, 56),
    BackgroundColor3       = Color3.fromRGB(12, 12, 12),
    TextColor3             = Color3.fromRGB(0, 255, 0),
    TextStrokeTransparency = 0.8,
    MultiLine              = true,
    ClearTextOnFocus       = false,
    Text                   = "",
    Font                   = Enum.Font.Code,
    TextSize               = 16,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Top,
    ZIndex                 = 3,
}, execPage)
corner(ScriptBox, 6)

local ExecuteBtn = new("TextButton", {
    Text             = "> " .. t("execute"),
    Size             = UDim2.new(0, 140, 0, 36),
    Position         = UDim2.new(0, 10, 1, -46),
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
    ZIndex           = 3,
}, execPage)
corner(ExecuteBtn, 8)

local ClearBtn = new("TextButton", {
    Text             = "X " .. t("clear"),
    Size             = UDim2.new(0, 120, 0, 36),
    Position         = UDim2.new(1, -130, 1, -46),
    BackgroundColor3 = Color3.fromRGB(200, 60, 60),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
    ZIndex           = 3,
}, execPage)
corner(ClearBtn, 8)

-- ============================================================
-- Tab persistence
-- ============================================================
local tabsData   = {}
local activeTabId = nil
local tabButtons = {}

local function saveTabs()
    if not hasWrite then return end
    safeCall(writefile, tabsPath, HttpService:JSONEncode(tabsData))
end

local function loadTabs()
    if not (readfile and isfile) then return end
    if not fileExists(tabsPath) then return end
    local ok, raw = safeCall(readfile, tabsPath)
    if not ok or type(raw) ~= "string" then return end
    local ok2, data = safeCall(HttpService.JSONDecode, HttpService, raw)
    if ok2 and type(data) == "table" then tabsData = data end
end

local function rebuildTabBar()
    for _, btn in pairs(tabButtons) do btn:Destroy() end
    tabButtons = {}

    -- [FIX] stable ordering: sort by key
    local ids = {}
    for id in pairs(tabsData) do ids[#ids + 1] = id end
    table.sort(ids)

    local order = 0
    for _, id in ipairs(ids) do
        local tab = tabsData[id]
        order += 1
        local btn = new("TextButton", {
            Name             = "Tab_" .. id,
            Size             = UDim2.new(0, 90, 1, -4),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            TextColor3       = Color3.fromRGB(200, 200, 200),
            Text             = tab.name or ("Tab " .. order),
            Font             = Enum.Font.SourceSans,
            TextSize         = 13,
            LayoutOrder      = order,
            ZIndex           = 4,
        }, TabBar)
        corner(btn, 5)

        btn.MouseButton1Click:Connect(function()
            if activeTabId and tabsData[activeTabId] then
                tabsData[activeTabId].code = ScriptBox.Text
            end
            activeTabId = id
            ScriptBox.Text = tabsData[id].code or ""
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            saveTabs()
        end)
        tabButtons[id] = btn
    end

    local addBtn = new("TextButton", {
        Size             = UDim2.new(0, 36, 1, -4),
        BackgroundColor3 = Color3.fromRGB(50, 80, 50),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Text             = "+",
        Font             = Enum.Font.SourceSansBold,
        TextSize         = 18,
        LayoutOrder      = 9999,
        ZIndex           = 4,
    }, TabBar)
    corner(addBtn, 5)

    addBtn.MouseButton1Click:Connect(function()
        if activeTabId and tabsData[activeTabId] then
            tabsData[activeTabId].code = ScriptBox.Text
        end
        local id = tostring(tick())
        tabsData[id] = { name = t("newTab"), code = "" }
        activeTabId = id
        saveTabs()
        rebuildTabBar()
        ScriptBox.Text = ""
    end)

    if not activeTabId then
        local firstId = ids[1]
        if firstId then
            activeTabId = firstId
            ScriptBox.Text = tabsData[firstId].code or ""
            if tabButtons[firstId] then
                tabButtons[firstId].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
    end
end

-- ============================================================
-- Page: ScriptBlox
-- ============================================================
local scriptPage = makePage("script")

-- [FIX] Named so scriptPage.SearchBox works later
local SearchBox = new("TextBox", {
    Name             = "SearchBox",
    Size             = UDim2.new(1, -100, 0, 34),
    Position         = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    PlaceholderText  = t("search"),
    Text             = "",
    Font             = Enum.Font.SourceSans,
    TextSize         = 15,
    ZIndex           = 3,
}, scriptPage)
corner(SearchBox, 6)

local SearchBtn = new("TextButton", {
    Text             = "Search",
    Size             = UDim2.new(0, 60, 0, 34),
    Position         = UDim2.new(1, -70, 0, 10),
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 14,
    ZIndex           = 3,
}, scriptPage)
corner(SearchBtn, 6)

local ResultsFrame = new("ScrollingFrame", {
    Size                   = UDim2.new(1, -20, 1, -60),
    Position               = UDim2.new(0, 10, 0, 54),
    BackgroundTransparency = 1,
    CanvasSize             = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness     = 6,
    ZIndex                 = 3,
}, scriptPage)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, ResultsFrame)

local function clearResults()
    for _, child in pairs(ResultsFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function addScriptCard(scriptData, order)
    local card = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        LayoutOrder      = order,
        ZIndex           = 4,
    }, ResultsFrame)
    corner(card, 8)

    new("TextLabel", {
        Size                   = UDim2.new(1, -10, 0, 22),
        Position               = UDim2.new(0, 5, 0, 4),
        BackgroundTransparency = 1,
        Text                   = scriptData.title or "Untitled",
        TextColor3             = Color3.fromRGB(255, 255, 255),
        Font                   = Enum.Font.SourceSansBold,
        TextSize               = 14,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, card)

    new("TextLabel", {
        Size                   = UDim2.new(1, -10, 0, 18),
        Position               = UDim2.new(0, 5, 0, 26),
        BackgroundTransparency = 1,
        Text                   = (scriptData.game and scriptData.game.name) or "Unknown Game",
        TextColor3             = Color3.fromRGB(180, 180, 180),
        Font                   = Enum.Font.SourceSans,
        TextSize               = 12,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, card)

    local openBtn = new("TextButton", {
        Text             = "Open",
        Size             = UDim2.new(0, 110, 0, 26),
        Position         = UDim2.new(1, -120, 0, 48),
        BackgroundColor3 = Color3.fromRGB(0, 150, 200),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.SourceSansBold,
        TextSize         = 12,
        ZIndex           = 5,
    }, card)
    corner(openBtn, 5)

    local runBtn = new("TextButton", {
        Text             = "Run",
        Size             = UDim2.new(0, 90, 0, 26),
        Position         = UDim2.new(1, -215, 0, 48),
        BackgroundColor3 = Color3.fromRGB(0, 180, 80),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.SourceSansBold,
        TextSize         = 12,
        ZIndex           = 5,
    }, card)
    corner(runBtn, 5)

    openBtn.MouseButton1Click:Connect(function()
        if activeTabId and tabsData[activeTabId] then tabsData[activeTabId].code = ScriptBox.Text end
        local id = tostring(tick())
        tabsData[id] = { name = scriptData.title or "Script", code = scriptData.script or "-- No code" }
        activeTabId = id
        saveTabs()
        rebuildTabBar()
        ScriptBox.Text = tabsData[id].code
        switchCategory("execute")
    end)

    runBtn.MouseButton1Click:Connect(function()
        local loader = loadstring or load
        if loader and scriptData.script then
            local fn = loader(scriptData.script)
            if fn then pcall(fn) end
        end
    end)
end

SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchBox.Text
    if query == "" then return end
    clearResults()

    task.spawn(function()
        local url = CONFIG.ScriptBloxAPI .. "/search?q=" .. HttpService:UrlEncode(query) .. "&max=10"
        local ok, response = pcall(function() return game:HttpGet(url) end)
        if not ok then warn("[NovaX] ScriptBlox request failed.") return end
        local ok2, data = pcall(function() return HttpService:JSONDecode(response) end)
        if not ok2 or not data or not data.result or not data.result.scripts then return end
        local order = 0
        for _, script in ipairs(data.result.scripts) do
            order += 1
            addScriptCard(script, order)
        end
    end)
end)

-- ============================================================
-- Page: Infinite Yield
-- ============================================================
local iyPage = makePage("iy")

new("TextLabel", {
    Size                   = UDim2.new(1, -20, 0, 60),
    Position               = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text                   = "Infinite Yield\nMost powerful admin commands.",
    TextColor3             = Color3.fromRGB(200, 200, 200),
    Font                   = Enum.Font.SourceSans,
    TextSize               = 16,
    TextYAlignment         = Enum.TextYAlignment.Top,
    ZIndex                 = 3,
}, iyPage)

local IYBtn = new("TextButton", {
    Text             = "Run Infinite Yield",
    Size             = UDim2.new(0, 260, 0, 44),
    Position         = UDim2.new(0.5, -130, 0, 90),
    BackgroundColor3 = Color3.fromRGB(80, 60, 160),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 17,
    ZIndex           = 3,
}, iyPage)
corner(IYBtn, 8)

IYBtn.MouseButton1Click:Connect(function()
    local loader = loadstring or load
    if not loader then warn("[NovaX] No loadstring for IY.") return end
    pcall(function()
        local src = game:HttpGet(CONFIG.IYUrl)
        local fn = loader(src)
        if fn then fn() end
    end)
end)

-- ============================================================
-- Page: Settings
-- ============================================================
local settingsPage = makePage("settings")

local SettingsScroll = new("ScrollingFrame", {
    Size                   = UDim2.new(1, -20, 1, -20),
    Position               = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    CanvasSize             = UDim2.new(0, 0, 0, 700),
    ScrollBarThickness     = 6,
    ZIndex                 = 3,
}, settingsPage)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, SettingsScroll)

local function sectionHeader(text, order)
    return new("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = (THEMES[currentTheme] or THEMES.Dark).accent,
        Font                   = Enum.Font.SourceSansBold,
        TextSize               = 16,
        TextXAlignment         = Enum.TextXAlignment.Left,
        LayoutOrder            = order,
        ZIndex                 = 4,
    }, SettingsScroll)
end

sectionHeader("Theme", 1)

local themeRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    LayoutOrder            = 2,
    ZIndex                 = 4,
}, SettingsScroll)

local themeX = 0
for _, name in ipairs(THEME_ORDER) do
    local btn = new("TextButton", {
        Size             = UDim2.new(0, 90, 0, 30),
        Position         = UDim2.new(0, themeX, 0, 2),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Text             = name,
        Font             = Enum.Font.SourceSans,
        TextSize         = 14,
        ZIndex           = 5,
    }, themeRow)
    corner(btn, 6)
    btn.MouseButton1Click:Connect(function()
        if applyTheme then applyTheme(name) end
    end)
    themeX += 96
end

sectionHeader("Fullscreen / Glow", 3)

local glowRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    LayoutOrder            = 4,
    ZIndex                 = 4,
}, SettingsScroll)

-- [FIX] assign to forward-declared local
glowToggle = new("TextButton", {
    Text             = "Glow: ON",
    Size             = UDim2.new(0, 120, 0, 30),
    Position         = UDim2.new(0, 0, 0, 2),
    BackgroundColor3 = Color3.fromRGB(0, 150, 80),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 14,
    ZIndex           = 5,
}, glowRow)
corner(glowToggle, 6)

glowToggle.MouseButton1Click:Connect(function()
    glowEnabled = not glowEnabled
    glowToggle.Text = "Glow: " .. (glowEnabled and "ON" or "OFF")
    glowToggle.BackgroundColor3 = glowEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(80, 30, 30)
    GlowStroke.Thickness = glowEnabled and 3 or 0
    if saveConfig then saveConfig() end
end)

local colorRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    LayoutOrder            = 5,
    ZIndex                 = 4,
}, SettingsScroll)

local glowColors = {
    { name = "Cyan",   c = Color3.fromRGB(0, 255, 255) },
    { name = "Pink",   c = Color3.fromRGB(255, 0, 150) },
    { name = "Lime",   c = Color3.fromRGB(0, 255, 80)  },
    { name = "Gold",   c = Color3.fromRGB(255, 200, 0) },
    { name = "Purple", c = Color3.fromRGB(180, 0, 255) },
}
local cx = 0
for _, gc in ipairs(glowColors) do
    local cb = new("TextButton", {
        Size             = UDim2.new(0, 70, 0, 28),
        Position         = UDim2.new(0, cx, 0, 3),
        BackgroundColor3 = gc.c,
        TextColor3       = Color3.fromRGB(0, 0, 0),
        Text             = gc.name,
        Font             = Enum.Font.SourceSansBold,
        TextSize         = 11,
        ZIndex           = 5,
    }, colorRow)
    corner(cb, 5)
    cb.MouseButton1Click:Connect(function()
        GlowStroke.Color = gc.c
        if saveConfig then saveConfig() end
    end)
    cx += 76
end

sectionHeader("Language", 6)

local langRow = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    LayoutOrder            = 7,
    ZIndex                 = 4,
}, SettingsScroll)

local lx = 0
for code in pairs(LOCALES) do
    local lb = new("TextButton", {
        Size             = UDim2.new(0, 60, 0, 30),
        Position         = UDim2.new(0, lx, 0, 2),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Text             = code,
        Font             = Enum.Font.SourceSansBold,
        TextSize         = 14,
        ZIndex           = 5,
    }, langRow)
    corner(lb, 6)
    lb.MouseButton1Click:Connect(function()
        currentLang = code
        if saveConfig then saveConfig() end
        ExecuteBtn.Text = "> " .. t("execute")
        ClearBtn.Text   = "X " .. t("clear")
        -- [FIX] name lookup instead of index
        local sb = scriptPage:FindFirstChild("SearchBox")
        if sb then sb.PlaceholderText = t("search") end
    end)
    lx += 66
end

sectionHeader("Autoexec", 8)

local AutoExecBox = new("TextBox", {
    Size             = UDim2.new(1, -20, 0, 90),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    TextColor3       = Color3.fromRGB(0, 255, 0),
    Text             = "",
    PlaceholderText  = "-- Auto-execute script on load",
    MultiLine        = true,
    ClearTextOnFocus = false,
    Font             = Enum.Font.Code,
    TextSize         = 13,
    TextXAlignment   = Enum.TextXAlignment.Left,
    TextYAlignment   = Enum.TextYAlignment.Top,
    LayoutOrder      = 9,
    ZIndex           = 4,
}, SettingsScroll)
corner(AutoExecBox, 6)

local SaveAutoBtn = new("TextButton", {
    Text             = t("save"),
    Size             = UDim2.new(0, 140, 0, 32),
    BackgroundColor3 = Color3.fromRGB(0, 150, 200),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 15,
    LayoutOrder      = 10,
    ZIndex           = 5,
}, SettingsScroll)
corner(SaveAutoBtn, 6)

SaveAutoBtn.MouseButton1Click:Connect(function()
    if hasWrite then
        safeCall(writefile, execPath, AutoExecBox.Text)
        SaveAutoBtn.Text = "Saved!"
        task.wait(1.5)
        SaveAutoBtn.Text = t("save")
    end
end)

local ResetBtn = new("TextButton", {
    Text             = "Factory Reset",
    Size             = UDim2.new(0, 160, 0, 32),
    BackgroundColor3 = Color3.fromRGB(90, 30, 30),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 14,
    LayoutOrder      = 11,
    ZIndex           = 5,
}, SettingsScroll)
corner(ResetBtn, 6)

-- ============================================================
-- Page: Browser
-- ============================================================
local browserPage = makePage("browser")

local UrlBox = new("TextBox", {
    Size             = UDim2.new(1, -100, 0, 34),
    Position         = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    PlaceholderText  = "https://...",
    Text             = "",
    Font             = Enum.Font.SourceSans,
    TextSize         = 14,
    ZIndex           = 3,
}, browserPage)
corner(UrlBox, 6)

new("TextButton", {
    Text             = "Go",
    Size             = UDim2.new(0, 40, 0, 34),
    Position         = UDim2.new(1, -50, 0, 10),
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    TextColor3       = Color3.fromRGB(255, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 16,
    ZIndex           = 3,
}, browserPage)

local BrowserPlaceholder = new("Frame", {
    Size             = UDim2.new(1, -20, 1, -60),
    Position         = UDim2.new(0, 10, 0, 54),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    ZIndex           = 3,
}, browserPage)
corner(BrowserPlaceholder, 8)

new("TextLabel", {
    Size                   = UDim2.new(1, -20, 1, -20),
    Position               = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text                   = "Browser placeholder\n\nRoblox cannot render real web pages\ninside ViewportFrame.",
    TextColor3             = Color3.fromRGB(150, 150, 150),
    Font                   = Enum.Font.SourceSans,
    TextSize               = 14,
    ZIndex                 = 4,
}, BrowserPlaceholder)

-- ============================================================
-- Config persistence
-- ============================================================
local cfg = {
    theme       = "Dark",
    glowEnabled = true,
    glowColor   = { 0, 255, 255 },
    lang        = "RU",
}

-- [FIX] plain function (assign to forward-declared local)
function saveConfig()
    if not hasWrite then return end
    cfg.theme       = currentTheme
    cfg.glowEnabled = glowEnabled
    cfg.glowColor   = { GlowStroke.Color.R * 255, GlowStroke.Color.G * 255, GlowStroke.Color.B * 255 }
    cfg.lang        = currentLang
    safeCall(writefile, cfgPath, HttpService:JSONEncode(cfg))
end

local function loadConfig()
    if not (readfile and isfile) then return end
    if not fileExists(cfgPath) then return end
    local ok, raw = safeCall(readfile, cfgPath)
    if not ok or type(raw) ~= "string" then return end
    local ok2, data = safeCall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end

    if data.theme and THEMES[data.theme] and applyTheme then applyTheme(data.theme) end
    if data.lang and LOCALES[data.lang] then currentLang = data.lang end
    if data.glowEnabled ~= nil then
        glowEnabled = data.glowEnabled
        if glowToggle then
            glowToggle.Text = "Glow: " .. (glowEnabled and "ON" or "OFF")
            glowToggle.BackgroundColor3 = glowEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(80, 30, 30)
        end
        GlowStroke.Thickness = glowEnabled and 3 or 0
    end
    if data.glowColor then
        GlowStroke.Color = Color3.fromRGB(
            data.glowColor[1] or 0,
            data.glowColor[2] or 255,
            data.glowColor[3] or 255
        )
    end
end

-- ============================================================
-- Theme
-- ============================================================
-- [FIX] plain function (assign to forward-declared local)
function applyTheme(name)
    local t2 = THEMES[name]
    if not t2 then return end
    currentTheme = name
    Frame.BackgroundColor3  = t2.frame
    SidebarTitle.TextColor3 = t2.accent
    if categoryButtons[currentCategory] then
        categoryButtons[currentCategory].TextColor3 = t2.accent
    end
    if hasWrite then safeCall(writefile, themePath, name) end
    if saveConfig then saveConfig() end
end

local function loadSavedTheme()
    if not (readfile and isfile) then return end
    if not fileExists(themePath) then return end
    local ok, saved = safeCall(readfile, themePath)
    if ok and type(saved) == "string" then
        saved = saved:gsub("%s+$", "")
        if THEMES[saved] then applyTheme(saved) end
    end
end

-- ============================================================
-- Execute logic
-- ============================================================
ExecuteBtn.MouseButton1Click:Connect(function()
    local code = ScriptBox.Text
    if code == "" then
        ExecuteBtn.Text = t("empty")
        task.wait(1)
        ExecuteBtn.Text = "> " .. t("execute")
        return
    end

    ExecuteBtn.Text = t("running")
    ExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)

    local loader = loadstring or load
    if not loader then
        ExecuteBtn.Text = "Unsupported"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1)
        ExecuteBtn.Text = "> " .. t("execute")
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        return
    end

    local fn, err = loader(code)
    if not fn then
        ExecuteBtn.Text = t("syntax")
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        writeLog("SYNTAX_ERROR", err)
    else
        local ok, result = pcall(fn)
        if ok then
            ExecuteBtn.Text = t("done")
            ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            writeLog("SUCCESS", "Script executed.")
        else
            ExecuteBtn.Text = t("runtime")
            ExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            writeLog("RUNTIME_ERROR", result)
        end
    end

    if activeTabId and tabsData[activeTabId] then
        tabsData[activeTabId].code = code
        saveTabs()
    end

    task.wait(1.5)
    ExecuteBtn.Text = "> " .. t("execute")
    ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
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
-- [FIX] assign to forward-declared local
ToggleButton = new("TextButton", {
    Name             = "ToggleButton",
    Size             = UDim2.new(0, 50, 0, 50),
    Position         = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    Text             = "NX",
    TextColor3       = Color3.fromRGB(0, 255, 255),
    Font             = Enum.Font.SourceSansBold,
    TextSize         = 20,
    ZIndex           = 100,
}, ScreenGui)
corner(ToggleButton, 12)

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = false
    Frame.Visible = true
    Frame.BackgroundTransparency = 0.15
    TweenService:Create(Frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.15 }):Play()
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
            ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.delay(4, function()
                if confirmState then
                    confirmState = false
                    ResetBtn.Text = "Factory Reset"
                    ResetBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
                end
            end)
        else
            confirmState = false
            if hasWrite and delfile then
                for _, p in ipairs({ logPath, themePath, tabsPath, execPath, cfgPath }) do
                    if fileExists(p) then safeCall(delfile, p) end
                end
            end
            applyTheme("Dark")
            ResetBtn.Text = "Done!"
            task.wait(1.5)
            ResetBtn.Text = "Factory Reset"
            ResetBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
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
            warn("[NovaX][CRITICAL] System directory missing.")
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
installLoggerHooks()
loadTabs()
rebuildTabBar()
loadSavedTheme()
loadConfig()

if readfile and fileExists(execPath) then
    local ok, code = safeCall(readfile, execPath)
    if ok and code and code ~= "" then
        task.spawn(function()
            local loader = loadstring or load
            if loader then
                local fn = loader(code)
                if fn then pcall(fn) end
            end
        end)
    end
end

switchCategory("execute")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NovaX",
        Text = "Loaded successfully!",
        Duration = 5,
    })
end)

print("[NovaX] v2 loaded.")
