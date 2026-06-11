-- // ========================================================================= // --
-- //      ███████╗██╗     ██╗   ██╗███████╗██╗██╗   ██╗███╗   ███╗             // --
-- //      ██╔════╝██║     ╚██╗ ██╔╝██╔════╝██║██║   ██║████╗ ████║             // --
-- //      █████╗  ██║      ╚████╔╝ ███████╗██║██║   ██║██╔████╔██║             // --
-- //      ██╔══╝  ██║       ╚██╔╝  ╚════██║██║██║   ██║██║╚██╔╝██║             // --
-- //      ███████╗███████╗   ██║   ███████║██║╚██████╔╝██║ ╚═╝ ██║             // --
-- //      ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝             // --
-- // ========================================================================= // --
-- //                ELYSIUM.WIN — [FPS] One Tap | v1.0.1                       // --
-- // ========================================================================= // --

-- // [ Section: Safe Load ] // ---------------------------------------------------
local success, Library = pcall(function()
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local lib = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    lib.ThemeManager = ThemeManager
    lib.SaveManager  = SaveManager
    return lib
end)

if not success or not Library then
    warn("Library failed to load")
    return
end

local ThemeManager = Library.ThemeManager
local SaveManager  = Library.SaveManager
local Options      = Library.Options
local CheatConfig

-- // [ Section: Services ] // ---------------------------------------------------
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService  = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local VirtualUser      = game:GetService("VirtualUser")

local Camera = Workspace.CurrentCamera
if not Camera then
    repeat task.wait() Camera = Workspace.CurrentCamera until Camera
end

-- // [ Section: Utilities - General ] // ---------------------------------------
local function getGreeting()
    local hour = tonumber(os.date("%H"))
    if hour >= 5 and hour < 12 then return "Good Morning"
    elseif hour >= 12 and hour < 18 then return "Good Afternoon"
    elseif hour >= 18 and hour < 22 then return "Good Evening"
    else return "Good Night" end
end

local function normalizeKey(key)
    if typeof(key) == "string" then
        return Enum.KeyCode[key] or Enum.UserInputType[key]
    end
    return key
end

function isAimbotLockKeyDown()
    local rawKey = Options.ALock and Options.ALock.Value
    if not rawKey or rawKey == "None" then return false end
    local key = normalizeKey(rawKey)
    if not key then return false end
    if key.EnumType == Enum.KeyCode then
        return UserInputService:IsKeyDown(key)
    end
    if key.EnumType == Enum.UserInputType then
        return UserInputService:IsMouseButtonPressed(key)
    end
    return false
end

function setESPEnabled(enabled, updateToggle)
    CheatConfig.ESP.Enabled = enabled
    if updateToggle and Options.MasterESPEn and Options.MasterESPEn.SetValue then
        pcall(function()
            Options.MasterESPEn:SetValue(enabled)
        end)
    end
end

local function inputMatchesESPKey(input)
    local rawKey = Options.ESPKey and Options.ESPKey.Value
    if not rawKey or rawKey == "None" then return false end

    local key = normalizeKey(rawKey)
    if typeof(rawKey) == "table" then
        key = normalizeKey(rawKey.Key or rawKey.Value or rawKey[1])
    end
    if not key then return false end

    if key.EnumType == Enum.KeyCode then
        return input.KeyCode == key
    end
    if key.EnumType == Enum.UserInputType then
        return input.UserInputType == key
    end
    return false
end

-- // [ Section: State & Configuration ] // --------------------------------------
local math_floor = math.floor

CheatConfig = {
    ESP = {
        Enabled = false,
        Chams = false,
        Tracers = false,
        Skeleton = false,
        Text = false,
        MaxDistance = 500,
    },
    Box = {
        Enabled = false,
        Style = "Full Box",
        Color = Color3.fromRGB(190, 170, 255),
        Thickness = 1,
        Transparency = 1,
        WidthScale = 1, -- Изменено дефолтное значение
        CornerScale = 0.25,
        MaxDistance = 500,
    },
    ChamsSettings = {
        FillColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0.5,
    },
    TracersSettings = {
        Color = Color3.fromRGB(125, 85, 255),
        Transparency = 0.85,
        Thickness = 1,
        Origin = "Center",
    },
    TextSettings = {
        ShowDisplayName = false,
        NameColor = Color3.fromRGB(190, 170, 255),
        DistColor = Color3.fromRGB(190, 170, 255),
        NameSize = 12,
        DistSize = 11,
        NameTransparency = 0,
        DistTransparency = 0,
        OffsetY = 21,
        Font = 3,
        Outline = true,
        Centered = true,
        ShowDistance = true,
    },
    OOV = {
        Enabled = false,
        Color = Color3.fromRGB(125, 85, 255),
        Size = 20,
        Transparency = 1,
        Radius = 45,
        PulseEnabled = false,
        PulseSpeed = 3.5,
        PulseAmount = 0.5,
        Filled = true,
    },
    Crosshair = {
        Enabled = false,
        Style = "Cross",
        Position = "Center",
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        Size = 10,
        Thickness = 1,
        Gap = 4,
        CircleRadius = 12,
        DotRadius = 3,
        ShowCenterDot = false,
        CenterDotRadius = 2,
        Rotation = false,
        RotSpeed = 2,
        Outline = false,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineThickness = 1,
        HideGameCrosshair = true,
        Pulse = false,
        PulseSpeed = 3,
        PulseAmount = 0.25,
        Rainbow = false,
        RainbowSpeed = 1,
        OffsetX = 0,
        OffsetY = 0,
    },
    Trail = {
        Enabled = false,
        Color = Color3.fromRGB(125, 85, 255),
        Transparency = 0,
        Lifetime = 3,
        Thickness = 0.1,
        MaxPoints = 100,
        ShowOnSelf = false,
        AlwaysOnTop = true,
        MaxDistance = 500,
        MinDistance = 0.5,
    },
    Hitmarker = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 1.5,
        Size = 10,
        Gap = 5,
        Lifetime = 0.2,
        HitDetectionRadius = 60,
    },
    Hitsound = {
        Enabled = false,
        SoundId = "rbxassetid://139452805868562",
        Volume = 2,
        Pitch = 1,
    },
    BulletTracer = {
        Enabled = false,
        Color = Color3.fromRGB(190, 170, 255),
        Thickness = 1,
        Lifetime = 2,
        Material = Enum.Material.Neon,
        SpawnOffset = 2,
        Fade = true,
    },
    HitLogs = {
        Enabled = false,
        Color = Color3.fromRGB(190, 170, 255),
        Lifetime = 3,
        ShowPart = true,
        ShowHP = true,
    },
}

local CheatState = {
    ESPObjects = {},
    ESP = {},
    OOVObjects = {},
    OOVPulseTick = 0,
    TrailData = {},
    EnemyHealth = {},
    NPCHealth = {},
    LastAttackTime = 0,
    ActiveEntities = {},
    PrevHealth = {},
    LastDamageTime = {},
    OriginalSoundVolumes = {},
    LastShotTarget = nil,
    LastShotTime = 0,
    IsScopeVisible = false,
    ActiveLogs = {},
}

-- // [ Section: World Variables ] // -------------------------------------------
local FogEnabled = false
local FogStart = 0
local FogEnd = 1000
local FogColor = Color3.fromRGB(227, 219, 255)
local AmbientColor = Color3.fromRGB(227, 219, 255)
local AmbientColorEnabled = false

local ClockTimeEnabled = false
local ClockTimeValue = 14.5
local FullBrightEnabled = false
local FullBrightValue = 2
local NoShadowsEnabled = false
local SkyboxChangerEnabled = false
local SelectedSkybox = "Sunset"

-- // [ Section: Default Lighting Values ] // -----------------------------------
local DefaultClockTime = Lighting.ClockTime
local DefaultBrightness = Lighting.Brightness
local DefaultAmbient = Lighting.Ambient
local DefaultOutdoorAmbient = Lighting.OutdoorAmbient
local DefaultGlobalShadows = Lighting.GlobalShadows
local DefaultFogStart = Lighting.FogStart
local DefaultFogEnd = Lighting.FogEnd
local DefaultFogColor = Lighting.FogColor
local DefaultColorShiftTop = Lighting.ColorShift_Top
local DefaultColorShiftBottom = Lighting.ColorShift_Bottom
local DefaultExposureCompensation = Lighting.ExposureCompensation

-- // [ Section: World Visuals ] // ---------------------------------------------
local function cleanLighting()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") or (obj:IsA("Sky") and not SkyboxChangerEnabled) then
            obj:Destroy()
        end
    end
end

function applyCustomWorldVisuals()
    if NoShadowsEnabled or FullBrightEnabled then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = DefaultGlobalShadows
    end

    if FullBrightEnabled then
        local fullBrightAmbient = AmbientColorEnabled and Color3.new(AmbientColor.R * 0.75, AmbientColor.G * 0.75, AmbientColor.B * 0.75) or Color3.fromRGB(180, 180, 180)
        Lighting.Brightness = FullBrightValue
        Lighting.Ambient = fullBrightAmbient
        Lighting.OutdoorAmbient = fullBrightAmbient
        Lighting.ColorShift_Top = fullBrightAmbient
        Lighting.ColorShift_Bottom = fullBrightAmbient
        Lighting.ExposureCompensation = 0
    elseif AmbientColorEnabled then
        Lighting.Brightness = DefaultBrightness
        Lighting.Ambient = AmbientColor
        Lighting.OutdoorAmbient = AmbientColor
        Lighting.ColorShift_Top = AmbientColor
        Lighting.ColorShift_Bottom = AmbientColor
        Lighting.ExposureCompensation = DefaultExposureCompensation
    else
        Lighting.Brightness = DefaultBrightness
        Lighting.Ambient = DefaultAmbient
        Lighting.OutdoorAmbient = DefaultOutdoorAmbient
        Lighting.ColorShift_Top = DefaultColorShiftTop
        Lighting.ColorShift_Bottom = DefaultColorShiftBottom
        Lighting.ExposureCompensation = DefaultExposureCompensation
    end

    if ClockTimeEnabled then
        Lighting.ClockTime = ClockTimeValue
    else
        Lighting.ClockTime = DefaultClockTime
    end

    if FogEnabled then
        Lighting.FogStart = FogStart
        Lighting.FogEnd = FogEnd
        Lighting.FogColor = FogColor
    else
        Lighting.FogStart = DefaultFogStart
        Lighting.FogEnd = DefaultFogEnd
        Lighting.FogColor = DefaultFogColor
    end
end

-- // [ Section: Skybox System ] // --------------------------------------------
local SkyboxPresets = {
    Sunset = {
        Bk = "rbxassetid://151165214",
        Dn = "rbxassetid://151165197",
        Ft = "rbxassetid://151165224",
        Lf = "rbxassetid://151165191",
        Rt = "rbxassetid://151165206",
        Up = "rbxassetid://151165227",
    },
    ["Sun set 2"] = {
        Bk = "rbxassetid://151165214",
        Dn = "rbxassetid://151165197",
        Ft = "rbxassetid://151165224",
        Lf = "rbxassetid://151165191",
        Rt = "rbxassetid://151165206",
        Up = "rbxassetid://151165227",
    },
    ["Deep Space"] = {
        Bk = "rbxassetid://159454299",
        Dn = "rbxassetid://159454296",
        Ft = "rbxassetid://159454293",
        Lf = "rbxassetid://159454286",
        Rt = "rbxassetid://159454300",
        Up = "rbxassetid://159454288",
    },
    ["Nebula"] = {
        Bk = "rbxassetid://159454299",
        Dn = "rbxassetid://159454296",
        Ft = "rbxassetid://159454293",
        Lf = "rbxassetid://159454286",
        Rt = "rbxassetid://159454300",
        Up = "rbxassetid://159454288",
    },
    ["Blue Sky"] = {
        Bk = "rbxassetid://1012890",
        Dn = "rbxassetid://1012891",
        Ft = "rbxassetid://1012887",
        Lf = "rbxassetid://1012889",
        Rt = "rbxassetid://1012888",
        Up = "rbxassetid://1014449",
    },
}

function setSkybox(preset)
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not SkyboxChangerEnabled then
        if sky then sky:Destroy() end
        return
    end
    local cfg = SkyboxPresets[preset] or SkyboxPresets.Sunset
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    sky.SkyboxBk = cfg.Bk
    sky.SkyboxDn = cfg.Dn
    sky.SkyboxFt = cfg.Ft
    sky.SkyboxLf = cfg.Lf
    sky.SkyboxRt = cfg.Rt
    sky.SkyboxUp = cfg.Up
end

-- // [ Section: Highlight Cleaner ] // ----------------------------------------
local function cleanHighlight(obj)
    if obj:IsA("Highlight") and obj.Name ~= "ElysiumHighlight" then
        task.defer(function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
end

Workspace.DescendantAdded:Connect(cleanHighlight)
for _, desc in ipairs(Workspace:GetDescendants()) do
    cleanHighlight(desc)
end

-- // [ Section: Utilities - Drawing API ] // ------------------------------------
local DrawingAvailable = typeof(Drawing) == "table" and typeof(Drawing.new) == "function"
if not DrawingAvailable then warn("Drawing API not available") end

function newDrawing(className)
    if not DrawingAvailable then return { Visible = false, Remove = function() end } end
    local ok, obj = pcall(function() return Drawing.new(className) end)
    if ok and obj then return obj end
    return { Visible = false, Remove = function() end }
end

local function setLine(line, from, to)
    if line then
        line.From = from
        line.To = to
        line.Visible = true
    end
end

local function setBoxLine(lines, index, from, to, thickness)
    local base = lines[index]
    setLine(base, from, to)
    if base then base.Thickness = 1 end

    local extraA = lines[index + 8]
    local extraB = lines[index + 16]
    if extraA then extraA.Visible = false end
    if extraB then extraB.Visible = false end

    local t = math.clamp(thickness or 1, 1, 3)
    if t <= 1 then return end

    local delta = to - from
    local length = delta.Magnitude
    if length <= 0 then return end
    local normal = Vector2.new(-delta.Y / length, delta.X / length)

    if t == 2 then
        local offset = normal * 0.75
        setLine(extraA, from + offset, to + offset)
        if extraA then extraA.Thickness = 1 end
    else
        local offset = normal
        setLine(extraA, from + offset, to + offset)
        setLine(extraB, from - offset, to - offset)
        if extraA then extraA.Thickness = 1 end
        if extraB then extraB.Thickness = 1 end
    end
end

-- // [ Section: Utilities - UI Helpers ] // -------------------------------------
function isMouseOverCheatUI()
    if UserInputService:GetFocusedTextBox() then return true end
    local mouse = UserInputService:GetMouseLocation()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gunOverlay = playerGui:FindFirstChild("GunOverlay")
    for _, gui in ipairs(playerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)) do
        if not gui.Visible then continue end
        local screenGui = gui:FindFirstAncestorWhichIsA("ScreenGui")
        if not screenGui or not screenGui.Enabled then continue end
        if gunOverlay and gui:IsDescendantOf(gunOverlay) then continue end
        if Library.ScreenGui and gui:IsDescendantOf(Library.ScreenGui) then
            return true
        end
    end
    return false
end

-- // [ Section: Window & Watermark ] // ----------------------------------------
local Window = Library:CreateWindow({
    Title = "Elysium.win",
    Footer = "Game: [FPS] One Tap | Build: 07.06.2026 | v1.0.1 | © 2026. All Rights Reserved",
    ShowCustomCursor = true,
    NotifySide = "Right",
})

local Watermark = Library:AddDraggableLabel("Installing components...")

local FPS = 0
local Ping = 0

function getFPSColor(fps)
    if fps < 60 then return "#d16d6d"
    elseif fps < 90 then return "#d1b36d"
    else return "#6dd18a" end
end

function getPingColor(ms)
    if ms > 100 then return "#d16d6d"
    elseif ms > 50 then return "#d1b36d"
    else return "#6dd18a" end
end

-- // [ Section: Tabs ] // ------------------------------------------------------
local Tabs = {}
Tabs.Home       = Window:AddTab("Home", "house")
Tabs.Visuals    = Window:AddTab("Visuals", "eye")
Tabs.Combat     = Window:AddTab("Combat", "crosshair")
Tabs.Movement   = Window:AddTab("Movement", "footprints")
Tabs.Misc       = Window:AddTab("Miscellaneous", "layers")
Tabs.UISettings = Window:AddTab("Settings", "settings")

-- // [ Section: Technical Functions - Entity Caching ] // -----------------------
local function updateEntityCache()
    local newCache = {}
    local function checkModel(obj)
        if obj and obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                newCache[obj] = true
                if CheatState.PrevHealth[obj] == nil then
                    CheatState.PrevHealth[obj] = hum.Health
                    CheatState.LastDamageTime[obj] = 0
                end
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then checkModel(p.Character) end
    end

    local function scanFolder(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then checkModel(child)
            elseif child:IsA("Folder") then scanFolder(child)
            end
        end
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") then checkModel(child)
        elseif child:IsA("Folder") then scanFolder(child)
        end
    end
    CheatState.ActiveEntities = newCache
end

local HealthConnections = {}
local addHitLog

local HitsoundPresets = {
    Neverlose = "rbxassetid://139452805868562",
    Primordial = "rbxassetid://97511223764004",
    ["Call Of Duty"] = "rbxassetid://77082587278347",
    Metallic = "rbxassetid://78469882347907",
    ENB = "rbxassetid://113548957163072",
    Fatality = "rbxassetid://75978460596545",
    ["Trident Pierce"] = "rbxassetid://136159923155431",
    ["CS:GO"] = "rbxassetid://80803263857916",
}

local function playElysiumSound(forcePlay)
    local hs = CheatConfig.Hitsound
    if not hs.Enabled and not forcePlay then return end
    
    local sound = Instance.new("Sound")
    sound.Name = "Elysium_Hitsound"
    sound.SoundId = hs.SoundId
    sound.Volume = hs.Volume
    sound.PlaybackSpeed = hs.Pitch
    sound.Parent = Workspace.CurrentCamera
    
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

function triggerHitmarker()
    playElysiumSound()
    local cfg = CheatConfig.Hitmarker
    if not cfg.Enabled then return end

    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
    local g, s = cfg.Gap, cfg.Size
    local lines = {}

    local function createLine(p1, p2)
        local l = newDrawing("Line")
        l.Visible, l.Color, l.Thickness, l.Transparency, l.ZIndex = true, cfg.Color, cfg.Thickness, 1, 100
        l.From, l.To = p1, p2
        table.insert(lines, l)
    end

    createLine(Vector2.new(cx - g, cy - g), Vector2.new(cx - g - s, cy - g - s))
    createLine(Vector2.new(cx + g, cy - g), Vector2.new(cx + g + s, cy - g - s))
    createLine(Vector2.new(cx - g, cy + g), Vector2.new(cx - g - s, cy + g + s))
    createLine(Vector2.new(cx + g, cy + g), Vector2.new(cx + g + s, cy + g + s))

    task.spawn(function()
        local start = tick()
        while tick() - start < cfg.Lifetime do
            local ratio = 1 - ((tick() - start) / cfg.Lifetime)
            for _, l in ipairs(lines) do l.Transparency = ratio end
            RunService.RenderStepped:Wait()
        end
        for _, l in ipairs(lines) do l:Remove() end
    end)
end

local function monitorTargetHealth(target)
    if not target or HealthConnections[target] then return end
    local hum = target:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local lastH = hum.Health
    local hitPart = CheatState.LastShotPart or "Unknown"

    HealthConnections[target] = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not hum or not hum.Parent then 
            if HealthConnections[target] then HealthConnections[target]:Disconnect() end
            HealthConnections[target] = nil
            return 
        end

        local curH = hum.Health
        if curH < lastH and (tick() - CheatState.LastShotTime) < 0.5 then
            local damage = math_floor(lastH - curH)
            triggerHitmarker()
            if CheatConfig.HitLogs.Enabled then
                addHitLog(target.Name, hitPart, damage, math.max(0, math_floor(curH)))
            end
            if HealthConnections[target] then HealthConnections[target]:Disconnect() end
            HealthConnections[target] = nil
        end
        lastH = curH
    end)

    task.delay(0.6, function()
        if HealthConnections[target] then
            HealthConnections[target]:Disconnect()
            HealthConnections[target] = nil
        end
    end)
end

local function processHitDetection()
    local target = CheatState.LastShotTarget
    if target and target.Parent then
        monitorTargetHealth(target)
        CheatState.LastShotTarget = nil
    end

    for model in pairs(CheatState.ActiveEntities) do
        if model and model.Parent then
            local h = model:FindFirstChildOfClass("Humanoid")
            if h then 
                local cur = h.Health
                local prev = CheatState.PrevHealth[model] or cur
                if cur < prev and (tick() - CheatState.LastAttackTime) < 0.2 then
                    triggerHitmarker()
                end
                CheatState.PrevHealth[model] = cur 
            end
        end
    end
end

-- // [ Section: Technical Functions - Bullet Tracers ] // -----------------------
local function getLocalMuzzle()
    local vm = Camera:FindFirstChild("Viewmodel") or Camera:FindFirstChildOfClass("Model")
    if vm then
        local muzzle = vm:FindFirstChild("muzzle", true) or vm:FindFirstChild("Muzzle", true) or vm:FindFirstChild("Tip", true)
        if muzzle then return muzzle:IsA("Attachment") and muzzle.WorldPosition or muzzle.Position end
    end
    return Camera.CFrame.Position
end

local function spawnElysiumTracer(targetPos, ignoreObject)
    local cfg = CheatConfig.BulletTracer
    if not cfg.Enabled then return end

    local origin = getLocalMuzzle()
    local rayDir = targetPos - origin
    local rayDist = rayDir.Magnitude
    if rayDist <= 0 then return end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, ignoreObject}
    local wallHit = Workspace:Raycast(origin, rayDir, params)
    if wallHit then
        targetPos = wallHit.Position
        rayDir = targetPos - origin
        rayDist = rayDir.Magnitude
    end

local direction = rayDir.Unit
    local dist = (origin - targetPos).Magnitude
    local spawnOffset = cfg.SpawnOffset or 2
    if dist <= spawnOffset then return end

    local adjustedOrigin = origin + (direction * spawnOffset)
    local adjustedDist = dist - spawnOffset

    local BASE_THICK = 0.2
    local finalThick = BASE_THICK * cfg.Thickness

    local laser = Instance.new("Part")
    laser.Name = "Elysium_Laser"
    laser.Color = cfg.Color
    laser.Material = cfg.Material or Enum.Material.Neon
    laser.Anchored = true
    laser.CanCollide = false
    laser.CanTouch = false
    laser.CastShadow = false

    laser.Size = Vector3.new(finalThick, finalThick, adjustedDist)
    laser.CFrame = CFrame.lookAt(adjustedOrigin, targetPos) * CFrame.new(0, 0, -adjustedDist/2)
    laser.Parent = Workspace

    task.spawn(function()
        local duration = cfg.Lifetime
        local start = tick()
        while tick() - start < duration do
            local r = (tick() - start) / duration
            if cfg.Fade then
                laser.Transparency = r
                local currentThick = finalThick * (1 - r)
                laser.Size = Vector3.new(currentThick, currentThick, adjustedDist)
            else
                laser.Transparency = 0
            end
            RunService.RenderStepped:Wait()
        end
        laser:Destroy()
    end)
end

task.spawn(function()
    local effects = Workspace:WaitForChild("Effects", 10)
    if not effects then return end

    effects.ChildAdded:Connect(function(obj)
        if obj.Name == "Bullet" and CheatConfig.BulletTracer.Enabled then
            local distToCam = (obj.Position - Camera.CFrame.Position).Magnitude
            if distToCam < 7 then 
                task.wait()
                if not obj or not obj.Parent then return end
                local beam = obj:FindFirstChildOfClass("Beam")
                local hitPos = beam and beam.Attachment1 and beam.Attachment1.WorldPosition 
                    or (obj.Position + obj.CFrame.LookVector * 1000)
                spawnElysiumTracer(hitPos, obj)
                if obj:IsA("BasePart") then obj.Transparency = 1 end
                for _, v in ipairs(obj:GetDescendants()) do
                    if v:IsA("Beam") or v:IsA("Trail") then v.Enabled = false end
                end
            end
        end
    end)
end)

-- // [ Section: Technical Functions - Mute Logic ] // ---------------------------
local blackList = {
    ["128825426756691"] = true, -- Подтвержденный звук попадания по телу
    ["128829912119543"] = true, -- Брат-близнец (почти 100% звук хедшота!)
}


local function applyMuteLogic(sound)
    if not sound:IsA("Sound") or sound.Name == "Elysium_Hitsound" then return end
    
    local id = sound.SoundId:match("%d+")
    
    -- 1. СНАЧАЛА жестко проверяем блэклист!
    if id and blackList[id] then
        if CheatState.OriginalSoundVolumes[sound] == nil then
            CheatState.OriginalSoundVolumes[sound] = sound.Volume
        end
        
        -- Функция удержания громкости на нуле
        local function forceMute()
            if CheatConfig.Hitsound.Enabled then
                sound.Volume = 0
            else
                sound.Volume = CheatState.OriginalSoundVolumes[sound] or 0.5
            end
        end
        
        forceMute()
        -- Не даем самой игре вернуть громкость звуку
        sound:GetPropertyChangedSignal("Volume"):Connect(forceMute)
        return
    end

    -- 2. Остальные звуки выстрелов и окружения в камере не трогаем
    if sound:IsDescendantOf(Workspace.CurrentCamera) or sound:IsDescendantOf(LocalPlayer.Character) then
        return
    end
end

function onHitsoundEnabledChanged(enabled)
    CheatConfig.Hitsound.Enabled = enabled
    task.spawn(function()
        local areas = {game:GetService("SoundService"), Workspace, LocalPlayer:FindFirstChild("PlayerGui")}
        for _, area in ipairs(areas) do
            if area then
                local items = area:GetDescendants()
                for i, v in ipairs(items) do
                    if v:IsA("Sound") then pcall(applyMuteLogic, v) end
                    if i % 250 == 0 then task.wait() end
                end
            end
        end
    end)
end

-- // [ Section: Technical Functions - Weapon Tracking ] // ----------------------
local function setupWeaponTracking(character)
    if not character then return end
    local function onToolActivated(tool)
        if tool and tool:IsA("Tool") and tool.Parent == character then
            CheatState.LastAttackTime = tick()
        end
    end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Activated:Connect(function() onToolActivated(tool) end)
        end
    end
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Activated:Connect(function() onToolActivated(child) end)
        end
    end)
end

-- // [ Section: Technical Functions - Lobby Detection ] // ----------------------
local function isOtherPlayerInLobby(player)
    if not player or not player.Character then return true end
    if not player.Character:FindFirstChild("Primary") then return true end
    return false
end

-- // [ Section: Technical Functions - ESP Helpers ] // --------------------------
local function shouldShowESPForPlayer(player)
    if not player or not player.Parent then return false end
    if player == LocalPlayer then
        return CheatConfig.Trail.Enabled and CheatConfig.Trail.ShowOnSelf
    end
    local char = player.Character
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not hum or hum.Health <= 0 then return false end
    if not char:FindFirstChild("Primary") then return false end
    local dist = (Camera.CFrame.Position - root.Position).Magnitude
    return dist <= (CheatConfig.ESP.MaxDistance or 500)
end

-- // [ Section: Technical Functions - Hit Logs ] // ----------------------------
local function color3ToHex(color)
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

addHitLog = function(name, part, damage, remaining)
    local cfg = CheatConfig.HitLogs
    if not cfg.Enabled then return end

    local logText = string.format('<font color="%s">Hit %s</font>', color3ToHex(cfg.Color), name)
    if cfg.ShowPart then logText = logText .. string.format(" in %s", part) end
    logText = logText .. string.format(" | Damage: %d", damage)
    if cfg.ShowHP then logText = logText .. string.format(" | Left: %d HP", remaining) end
    
    Library:Notify({Title = "Elysium.win", Description = logText, Time = cfg.Lifetime})
end

-- // [ Section: Crosshair State & Drawing ] // --------------------------------
local CrosshairState = {
    Lines = {},
    OutlineLines = {},
    Circles = {},
    OutlineCircles = {},
    Angle = 0,
    PulseTick = 0,
}

local MAX_CROSSHAIR_LINES = 12

function newCrosshairLine(zIndex)
    local line = newDrawing("Line")
    line.Visible = false
    line.ZIndex = zIndex or 10
    return line
end

function newCrosshairCircle(zIndex)
    local circle = newDrawing("Circle")
    circle.Visible = false
    circle.ZIndex = zIndex or 10
    circle.NumSides = 24
    circle.Filled = true
    return circle
end

for i = 1, MAX_CROSSHAIR_LINES do
    CrosshairState.Lines[i] = newCrosshairLine(10)
    CrosshairState.OutlineLines[i] = newCrosshairLine(9)
end
CrosshairState.Circles[1] = newCrosshairCircle(10)
CrosshairState.OutlineCircles[1] = newCrosshairCircle(9)
CrosshairState.Circles[2] = newCrosshairCircle(10)
CrosshairState.OutlineCircles[2] = newCrosshairCircle(9)

function hideAllCrosshairDrawings()
    for _, line in ipairs(CrosshairState.Lines) do line.Visible = false end
    for _, line in ipairs(CrosshairState.OutlineLines) do line.Visible = false end
    for _, circle in ipairs(CrosshairState.Circles) do circle.Visible = false end
    for _, circle in ipairs(CrosshairState.OutlineCircles) do circle.Visible = false end
end

function getCrosshairCenter(ch)
    if ch.Position == "Mouse" and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        local m = UserInputService:GetMouseLocation()
        return m.X, m.Y
    end
    local vp = Camera.ViewportSize
    return vp.X / 2, vp.Y / 2
end

function getCrosshairColor(ch)
    if ch.Rainbow then
        local h = (tick() * ch.RainbowSpeed) % 1
        return Color3.fromHSV(h, 1, 1)
    end
    return ch.Color
end

function getCrosshairAlpha(ch)
    local alpha = 1 - ch.Transparency
    if ch.Pulse then
        alpha = alpha * (1 - ch.PulseAmount * 0.5 * (1 + math.sin(CrosshairState.PulseTick)))
    end
    return math.clamp(alpha, 0, 1)
end

function getCrosshairSize(ch)
    local size = ch.Size
    if ch.Pulse then
        size = size * (1 + ch.PulseAmount * 0.5 * math.sin(CrosshairState.PulseTick))
    end
    return size
end

function applyCrosshairLine(idx, fromPos, toPos, color, thickness, alpha, useOutline, ch)
    local line = CrosshairState.Lines[idx]
    local ol = CrosshairState.OutlineLines[idx]
    if not line then return end
    if useOutline and ch.Outline and ol then
        ol.From = fromPos
        ol.To = toPos
        ol.Color = ch.OutlineColor
        ol.Thickness = thickness + ch.OutlineThickness * 2
        ol.Transparency = alpha
        ol.Visible = true
    elseif ol then
        ol.Visible = false
    end
    line.From = fromPos
    line.To = toPos
    line.Color = color
    line.Thickness = thickness
    line.Transparency = alpha
    line.Visible = true
end

function applyCrosshairCircle(idx, pos, radius, filled, color, thickness, alpha, useOutline, ch)
    local circle = CrosshairState.Circles[idx]
    local ol = CrosshairState.OutlineCircles[idx]
    if not circle then return end
    if useOutline and ch.Outline and ol then
        ol.Position = pos
        ol.Radius = radius + ch.OutlineThickness
        ol.Filled = filled
        ol.Color = ch.OutlineColor
        ol.Thickness = thickness + ch.OutlineThickness
        ol.Transparency = alpha
        ol.Visible = true
    elseif ol then
        ol.Visible = false
    end
    circle.Position = pos
    circle.Radius = radius
    circle.Filled = filled
    circle.Color = color
    circle.Thickness = thickness
    circle.Transparency = alpha
    circle.Visible = true
end

function rotateOffset(dx, dy, angleDeg)
    local rad = math.rad(angleDeg)
    local cos_a = math.cos(rad)
    local sin_a = math.sin(rad)
    return dx * cos_a - dy * sin_a, dx * sin_a + dy * cos_a
end

function drawCrosshairStyle(ch)
    local cx, cy = getCrosshairCenter(ch)
    local color = getCrosshairColor(ch)
    local alpha = getCrosshairAlpha(ch)
    local pulseMod = 1
    if ch.Pulse then
        pulseMod = 1 + (math.sin(CrosshairState.PulseTick) * ch.PulseAmount)
    end
    local size = ch.Size * pulseMod
    local gap = ch.Gap * pulseMod
    local thick = ch.Thickness
    local angle = ch.Rotation and CrosshairState.Angle or 0
    local lineIdx = 0

    local function drawLine(f, t)
        lineIdx = lineIdx + 1
        applyCrosshairLine(lineIdx, f, t, color, thick, alpha, true, ch)
    end

    if ch.Style == "Cross" or ch.Style == "Plus" then
        local function arm(dx, dy)
            local rdx, rdy = rotateOffset(dx, dy, angle)
            local base = Vector2.new(cx + rdx * gap, cy + rdy * gap)
            drawLine(base, base + Vector2.new(rdx * size, rdy * size))
        end
        arm(0, -1); arm(0, 1); arm(-1, 0); arm(1, 0)
    elseif ch.Style == "Corners" then
        local dirs = {{-1,-1}, {1,-1}, {-1,1}, {1,1}}
        for _, d in ipairs(dirs) do
            local bx, by = rotateOffset(d[1] * gap, d[2] * gap, angle)
            local start = Vector2.new(cx + bx, cy + by)
            local hx, hy = rotateOffset(d[1] * size, 0, angle)
            drawLine(start, start + Vector2.new(hx, hy))
            local vx, vy = rotateOffset(0, d[2] * size, angle)
            drawLine(start, start + Vector2.new(vx, vy))
        end
    elseif ch.Style == "X" then
        local d = 0.707
        local function arm(dx, dy)
            local rdx, rdy = rotateOffset(dx, dy, angle)
            local base = Vector2.new(cx + rdx * gap, cy + rdy * gap)
            drawLine(base, base + Vector2.new(rdx * size, rdy * size))
        end
        arm(-d, -d); arm(d, -d); arm(-d, d); arm(d, d)
    elseif ch.Style == "Dot" then
        applyCrosshairCircle(1, Vector2.new(cx, cy), size, true, color, 1, alpha, true, ch)
    elseif ch.Style == "Circle" then
        applyCrosshairCircle(1, Vector2.new(cx, cy), size, false, color, thick, alpha, true, ch)
    end

    if ch.ShowCenterDot and ch.Style ~= "Dot" then
        applyCrosshairCircle(2, Vector2.new(cx, cy), ch.CenterDotRadius, true, color, 1, alpha, true, ch)
    end

    for i = lineIdx + 1, MAX_CROSSHAIR_LINES do
        if CrosshairState.Lines[i] then CrosshairState.Lines[i].Visible = false end
        if CrosshairState.OutlineLines[i] then CrosshairState.OutlineLines[i].Visible = false end
    end
end

function setCrosshairEnabled(enabled)
    CheatConfig.Crosshair.Enabled = enabled
    if not enabled then
        hideAllCrosshairDrawings()
    end
end

-- // [ Section: Visuals State ] // ---------------------------------------------
local OOVTextObjects = {}
local SkeletonColor = Color3.fromRGB(190, 170, 255)
local SkeletonTransparency = 0
local SkeletonThickness = 1

-- // [ Section: Game Features (Misc) - Scope & Effects ] // ------------------
local DisableScopeEnabled = false
local DisableScopeConnection = nil
local DisableScopeLoop = nil
local HandledScopeInstances = setmetatable({}, {__mode = "kv"})

local function ApplyDisableScope()
    if not DisableScopeEnabled then return end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local function processDescendant(desc)
        if not desc:IsA("GuiObject") then return end
        if HandledScopeInstances[desc] then return end
        local nameLower = string.lower(desc.Name)
        if nameLower == "scope" then
            HandledScopeInstances[desc] = true
            desc.Visible = false
        end
    end

    local queue = {playerGui}
    while #queue > 0 do
        local current = table.remove(queue, 1)
        for _, child in ipairs(current:GetChildren()) do
            processDescendant(child)
            if child:IsA("GuiObject") then
                table.insert(queue, child)
            end
        end
    end

    if not DisableScopeConnection then
        DisableScopeConnection = playerGui.DescendantAdded:Connect(processDescendant)
    end
end

function enableDisableScope()
    if DisableScopeLoop then task.cancel(DisableScopeLoop) end
    ApplyDisableScope()
    DisableScopeLoop = task.spawn(function()
        while DisableScopeEnabled do
            task.wait(30)
            for k in pairs(HandledScopeInstances) do
                HandledScopeInstances[k] = nil
            end
            ApplyDisableScope()
        end
    end)
end

function disableDisableScope()
    if DisableScopeConnection then
        DisableScopeConnection:Disconnect()
        DisableScopeConnection = nil
    end
    if DisableScopeLoop then
        task.cancel(DisableScopeLoop)
        DisableScopeLoop = nil
    end
    for k in pairs(HandledScopeInstances) do
        HandledScopeInstances[k] = nil
    end
end

function isScoped()
    if DisableScopeEnabled then return false end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    for _, child in ipairs(playerGui:GetDescendants()) do
        if child:IsA("GuiObject") and string.lower(child.Name) == "scope" and child.Visible then
            return true
        end
    end
    return false
end

local LowEffectsEnabled = false
local LowEffectsConn = nil
local LOW_EFFECT_KEYWORDS = {
    "bullet", "impact", "muzzle", "shell", "casing", "spark", "smoke",
    "tracer", "hole", "decal", "flash", "explosion", "debris", "particle", "beam", "trail"
}

function nameMatchesLowEffectKeyword(name)
    local lower = string.lower(name)
    for _, kw in ipairs(LOW_EFFECT_KEYWORDS) do
        if lower:find(kw, 1, true) then return true end
    end
    return false
end

function processLowEffectInstance(inst)
    if not LowEffectsEnabled or not inst then return end
    local localChar = LocalPlayer.Character
    if localChar and inst:IsDescendantOf(localChar) then return end
    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
        inst.Enabled = false
    elseif inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
        inst.Enabled = false
    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        local parentName = inst.Parent and inst.Parent.Name or ""
        if nameMatchesLowEffectKeyword(inst.Name) or nameMatchesLowEffectKeyword(parentName) then
            inst.Transparency = 1
        end
    end
end

function enableLowEffects()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        processLowEffectInstance(desc)
    end
    if LowEffectsConn then LowEffectsConn:Disconnect() end
    LowEffectsConn = Workspace.DescendantAdded:Connect(processLowEffectInstance)
end

function disableLowEffects()
    if LowEffectsConn then
        LowEffectsConn:Disconnect()
        LowEffectsConn = nil
    end
end

local AntiAfkEnabled = false
local AntiAfkThread = nil

function startAntiAfk()
    if AntiAfkThread then return end
    AntiAfkThread = task.spawn(function()
        while AntiAfkEnabled do
            task.wait(60)
            if not AntiAfkEnabled then break end
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0))
            end)
        end
        AntiAfkThread = nil
    end)
end

function stopAntiAfk()
    AntiAfkEnabled = false
    AntiAfkThread = nil
end

local SniperCustomizationEnabled = false
local SniperCustomColor = Color3.fromRGB(255, 255, 255)
local SniperCustomMaterial = Enum.Material.Plastic
local SniperCustomTransparency = 0
local SniperOriginalProps = {}

function getSniperModels()
    local models = {}
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local function addFrom(container)
        if not container then return end
        local tool = container:FindFirstChild("Sniper")
        local model = tool and tool:FindFirstChild("Model")
        if model then table.insert(models, model) end
    end
    addFrom(character)
    addFrom(backpack)
    return models
end

function shouldCustomizeSniperPart(part)
    if not part:IsA("BasePart") then return false end
    if part.Name == "Left Arm" or part.Name == "Right Arm" then return false end
    return true
end

function cacheSniperPart(part)
    if SniperOriginalProps[part] then return end
    local props = { Color = part.Color, Material = part.Material, Transparency = part.Transparency }
    if part:IsA("UnionOperation") then props.UsePartColor = part.UsePartColor end
    SniperOriginalProps[part] = props
end

function applySniperCustomization()
    for _, model in ipairs(getSniperModels()) do
        for _, obj in ipairs(model:GetDescendants()) do
            if shouldCustomizeSniperPart(obj) then
                cacheSniperPart(obj)
                if obj:IsA("UnionOperation") then obj.UsePartColor = true end
                obj.Color = SniperCustomColor
                obj.Material = SniperCustomMaterial
                obj.Transparency = SniperCustomTransparency
            end
        end
    end
end

function restoreSniperCustomization()
    for part, props in pairs(SniperOriginalProps) do
        if part and part.Parent then
            part.Color = props.Color
            part.Material = props.Material
            part.Transparency = props.Transparency
            if part:IsA("UnionOperation") and props.UsePartColor ~= nil then
                part.UsePartColor = props.UsePartColor
            end
        end
    end
    table.clear(SniperOriginalProps)
end

-- // [ Section: Player Variables (Movement) ] // ------------------------------
local WalkSpeedEnabled = false
local WalkSpeedValue = 16
local JumpPowerEnabled = false
local JumpPowerValue = 50
local InfiniteJumpEnabled = false
local InfiniteJumpConnection = nil
local OriginalJumpPower = nil
local OriginalUseJumpPower = nil
local BunnyHopEnabled = false
local BunnyHopLastJump = 0
local AntiSlipEnabled = false
local AntiSlipConnection = nil

-- // [ Section: Combat State ] // ---------------------------------------------
local AimbotEnabled = false
local AimbotLocked = false
local AimbotKey = nil
local AimbotWallCheck = false
local AimbotFOV = 200
local ShowFOV = true
local AimbotSmoothing = 0
local AimMethod = "Toggle"
local CurrentTarget = nil
local AimPart = "Head"
local LockKeyWasDown = false
local AutoShotMode = "WithAimbot"

local KillAuraEnabled = false
local KillAuraTarget = nil
local KillAuraDistance = 4
local KillAuraConnection = nil

local TriggerBotEnabled = false
local TriggerBotDelay = 0
local TriggerBotLastShot = 0
local SavedCustomCursor = nil

local SkipSpawnShield = true
local SpawnShieldDuration = 2.25
local PlayerSpawnTimes = {}

local SpinBotEnabled = false
local SpinBotSpeed = 25
local SpinBotBodyGyro = nil

function enableSpinBot()
    if not SpinBotEnabled then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not SpinBotBodyGyro then
        SpinBotBodyGyro = Instance.new("BodyGyro")
        SpinBotBodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
        SpinBotBodyGyro.P = 10000
        SpinBotBodyGyro.D = 100
    end
    SpinBotBodyGyro.Parent = hrp
    SpinBotBodyGyro.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinBotSpeed), 0)
end

function disableSpinBot()
    if SpinBotBodyGyro then
        SpinBotBodyGyro:Destroy()
        SpinBotBodyGyro = nil
    end
end

function updateSpinBot()
    if not SpinBotEnabled then return end
    if not isLocalAlive() or isSpectatorCamera() then
        disableSpinBot()
        return
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and SpinBotBodyGyro then
        SpinBotBodyGyro.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinBotSpeed), 0)
    else
        enableSpinBot()
    end
end

-- // [ Section: Kill Aura Logic ] // ------------------------------------------
local function getKillAuraTargets()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isTargetAlive(p) and not isOtherPlayerInLobby(p) then
            table.insert(targets, p.Character)
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if not Players:GetPlayerFromCharacter(obj) then
                local name = obj.Name:lower()
                if name:find("astration") or name:find("bot") or name:find("dummy") or name:find("npc") then
                    if obj.Humanoid.Health > 0 then
                        table.insert(targets, obj)
                    end
                end
            end
        end
    end
    return targets
end

local function stopKillAura()
    if KillAuraConnection then KillAuraConnection:Disconnect(); KillAuraConnection = nil end
    KillAuraTarget = nil
    Camera.CameraType = Enum.CameraType.Custom
    local myChar = LocalPlayer.Character
    if myChar then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function startKillAuraMove(targetModel)
    if KillAuraConnection then KillAuraConnection:Disconnect() end
    KillAuraTarget = targetModel
    Camera.CameraType = Enum.CameraType.Scriptable
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not KillAuraEnabled or not targetModel or not targetModel.Parent then
            stopKillAura()
            return
        end
        local hum = targetModel:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            stopKillAura()
            return
        end
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
        local targetHead = targetModel:FindFirstChild("Head")
        local myHead = myChar and myChar:FindFirstChild("Head")
        if myHRP and targetHRP then
            for _, part in ipairs(myChar:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            local behindPos = targetHRP.Position - (targetHRP.CFrame.LookVector * KillAuraDistance)
            myHRP.CFrame = CFrame.new(behindPos, targetHRP.Position)
            local myEyePos = myHead and myHead.Position or (myHRP.Position + Vector3.new(0, 2, 0))
            local targetLookPos = targetHead and targetHead.Position or (targetHRP.Position + Vector3.new(0, 1.5, 0))
            Camera.CFrame = CFrame.lookAt(myEyePos, targetLookPos)
        end
    end)
end

-- // [ Section: FOV Circles ] // ----------------------------------------------
local FOVCircle = newDrawing("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = 200
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

local ShowFOVCircle = true
local FOVCircleColor = Color3.fromRGB(255, 255, 255)
local FOVCircleLockedColor = Color3.fromRGB(255, 50, 50)
local FOVCircleThickness = 1
local FOVCircleTransparency = 0.5

-- // [ Section: ESP Core - Box ] // -------------------------------------------
ESP = {}
ESP.Box = {}
ESP.Trail = {}

local CachedPlayerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    CachedPlayerList[#CachedPlayerList + 1] = p
end
Players.PlayerAdded:Connect(function(p)
    CachedPlayerList[#CachedPlayerList + 1] = p
end)

function ESP.Box.Create(player)
    if player == LocalPlayer then return end
    if not CheatState.ESPObjects[player] then CheatState.ESPObjects[player] = {} end
    local obj = CheatState.ESPObjects[player]
    if obj.Box then
        for _, line in ipairs(obj.Box.AllLines) do pcall(function() line:Remove() end) end
    end
    local box = { AllLines = {} }
    for i = 1, 24 do
        local l = newDrawing("Line")
        l.Visible = false
        l.Thickness = 1
        l.ZIndex = 10
        table.insert(box.AllLines, l)
    end
    obj.Box = box
end

function ESP.Box.Hide(player)
    local obj = CheatState.ESPObjects[player]
    if obj and obj.Box and obj.Box.AllLines then
        for _, line in ipairs(obj.Box.AllLines) do line.Visible = false end
    end
end

function ESP.Box.Remove(player)
    local obj = CheatState.ESPObjects[player]
    if obj and obj.Box then
        for _, line in ipairs(obj.Box.AllLines) do pcall(function() line:Remove() end) end
        obj.Box = nil
    end
end

function ESP.Box.Update(player)
    if not CheatConfig.Box.Enabled or not shouldShowESPForPlayer(player) then
        ESP.Box.Hide(player)
        return
    end
    if not CheatState.ESPObjects[player] or not CheatState.ESPObjects[player].Box then
        ESP.Box.Create(player)
    end
    local objData = CheatState.ESPObjects[player]
    if not objData or not objData.Box then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head") or root
    if not root then return end
    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen or pos.Z < 2 then
        ESP.Box.Hide(player)
        return
    end
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
    local height = math.abs(headPos.Y - legPos.Y)
    local width = (height / 2) * (CheatConfig.Box.WidthScale or 1)
    local x, y = pos.X - width / 2, headPos.Y
    local lines = objData.Box.AllLines
    for i = 1, 24 do if lines[i] then lines[i].Visible = false end end
    local boxThickness = math.clamp(CheatConfig.Box.Thickness or 1, 1, 3)
    if CheatConfig.Box.Style == "Full Box" then
        setBoxLine(lines, 1, Vector2.new(x, y), Vector2.new(x + width, y), boxThickness)
        setBoxLine(lines, 2, Vector2.new(x + width, y), Vector2.new(x + width, y + height), boxThickness)
        setBoxLine(lines, 3, Vector2.new(x + width, y + height), Vector2.new(x, y + height), boxThickness)
        setBoxLine(lines, 4, Vector2.new(x, y + height), Vector2.new(x, y), boxThickness)
    else
        local l = width * 0.25
        setBoxLine(lines, 1, Vector2.new(x, y), Vector2.new(x + l, y), boxThickness)
        setBoxLine(lines, 2, Vector2.new(x, y), Vector2.new(x, y + l), boxThickness)
        setBoxLine(lines, 3, Vector2.new(x + width, y), Vector2.new(x + width - l, y), boxThickness)
        setBoxLine(lines, 4, Vector2.new(x + width, y), Vector2.new(x + width, y + l), boxThickness)
        setBoxLine(lines, 5, Vector2.new(x, y + height), Vector2.new(x + l, y + height), boxThickness)
        setBoxLine(lines, 6, Vector2.new(x, y + height), Vector2.new(x, y + height - l), boxThickness)
        setBoxLine(lines, 7, Vector2.new(x + width, y + height), Vector2.new(x + width - l, y + height), boxThickness)
        setBoxLine(lines, 8, Vector2.new(x + width, y + height), Vector2.new(x + width, y + height - l), boxThickness)
    end
    for i = 1, 24 do
        local line = lines[i]
        if line and line.Visible then
            line.Color = CheatConfig.Box.Color
            line.Thickness = 1
            line.Transparency = CheatConfig.Box.Transparency
        end
    end
end

-- // [ Section: ESP Core - Trail (Physical) ] // -----------------------------
local function updateTrailProperties(trail)
    if not trail or not trail:IsA("Trail") then return end
    local cfg = CheatConfig.Trail
    trail.Color = ColorSequence.new(cfg.Color)
    trail.Transparency = NumberSequence.new(cfg.Transparency)
    trail.Lifetime = cfg.Lifetime
    trail.WidthScale = NumberSequence.new(cfg.Thickness)
    trail.Enabled = cfg.Enabled
end

local function applyPhysicalTrail(player)
    local char = player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    if hrp:FindFirstChild("ElysiumTrail") then
        updateTrailProperties(hrp.ElysiumTrail)
        return
    end
    local a0 = Instance.new("Attachment")
    a0.Name = "TrailA0"
    a0.Position = Vector3.new(0, 0.8, 0)
    a0.Parent = hrp
    local a1 = Instance.new("Attachment")
    a1.Name = "TrailA1"
    a1.Position = Vector3.new(0, -0.8, 0)
    a1.Parent = hrp
    local trail = Instance.new("Trail")
    trail.Name = "ElysiumTrail"
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.FaceCamera = true
    trail.LightEmission = 1
    trail.Parent = hrp
    updateTrailProperties(trail)
end

local function clearPhysicalTrail(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("ElysiumTrail") then hrp.ElysiumTrail:Destroy() end
        if hrp:FindFirstChild("TrailA0") then hrp.TrailA0:Destroy() end
        if hrp:FindFirstChild("TrailA1") then hrp.TrailA1:Destroy() end
    end
end

-- // [ Section: ESP Core - Skeleton ] // --------------------------------------
local BonesR6 = {
    {"Head","Torso"}, {"Torso","HumanoidRootPart"},
    {"HumanoidRootPart","Left Arm"}, {"HumanoidRootPart","Right Arm"},
    {"HumanoidRootPart","Left Leg"}, {"HumanoidRootPart","Right Leg"},
}
local BonesR15 = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}

function getBonesForCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then return BonesR15 end
    return BonesR6
end

function removeSkeleton(player)
    local espData = CheatState.ESP[player]
    if espData and espData.SkeletonObject then
        local skel = espData.SkeletonObject
        for _, line in pairs(skel.lines) do pcall(function() line:Remove() end) end
        espData.SkeletonObject = nil
    end
end

function applySkeleton(player)
    if player == LocalPlayer then return end
    CheatState.ESP[player] = CheatState.ESP[player] or {}
    if not shouldShowESPForPlayer(player) then
        removeSkeleton(player)
        return
    end
    local character = player.Character
    if not character then return end
    removeSkeleton(player)
    local bones = getBonesForCharacter(character)
    local linesList = {}
    for i = 1, #bones do
        local line = newDrawing("Line")
        line.Visible = false
        line.Color = SkeletonColor
        line.Thickness = SkeletonThickness
        line.Transparency = 1 - SkeletonTransparency
        linesList[i] = line
    end
    CheatState.ESP[player].SkeletonObject = { lines = linesList, bones = bones }
end

-- // [ Section: ESP Core - Text ] // ------------------------------------------
function removeTextESP(player)
    local espData = CheatState.ESP[player]
    if espData and espData.TextObjects then
        local txtObj = espData.TextObjects
        pcall(function()
            if txtObj.nameText then txtObj.nameText:Remove() end
        end)
        espData.TextObjects = nil
    end
end

function applyTextESP(player)
    if player == LocalPlayer then return end
    CheatState.ESP[player] = CheatState.ESP[player] or {}
    if not shouldShowESPForPlayer(player) then
        removeTextESP(player)
        return
    end
    local character = player.Character
    if not character then return end
    removeTextESP(player)
    local ts = CheatConfig.TextSettings
    local nameText = newDrawing("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = ts.Outline
    nameText.Font = ts.Font
    nameText.Size = ts.NameSize
    nameText.Color = ts.NameColor
    nameText.Transparency = 1 - ts.NameTransparency
    CheatState.ESP[player].TextObjects = { nameText = nameText }
end

-- // [ Section: ESP Core - Chams ] // -----------------------------------------
function removeChams(player)
    local espData = CheatState.ESP[player]
    if espData and espData.ChamsObject then
        pcall(function() espData.ChamsObject:Destroy() end)
        espData.ChamsObject = nil
    end
end

function applyChams(player)
    if player == LocalPlayer then return end
    CheatState.ESP[player] = CheatState.ESP[player] or {}
    if not shouldShowESPForPlayer(player) then
        removeChams(player)
        return
    end
    local character = player.Character
    if not character then return end
    removeChams(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ElysiumHighlight"
    highlight.FillColor = CheatConfig.ChamsSettings.FillColor
    highlight.OutlineColor = CheatConfig.ChamsSettings.OutlineColor
    highlight.FillTransparency = CheatConfig.ChamsSettings.FillTransparency
    highlight.OutlineTransparency = CheatConfig.ChamsSettings.OutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    CheatState.ESP[player].ChamsObject = highlight
end

-- // [ Section: ESP Core - Tracer ] // ----------------------------------------
function removeTracer(player)
    local espData = CheatState.ESP[player]
    if espData and espData.TracerObject then
        pcall(function() espData.TracerObject:Remove() end)
        espData.TracerObject = nil
    end
end

function applyTracer(player)
    if player == LocalPlayer then return end
    CheatState.ESP[player] = CheatState.ESP[player] or {}
    if not shouldShowESPForPlayer(player) then
        removeTracer(player)
        return
    end
    removeTracer(player)
    local line = newDrawing("Line")
    line.Visible = false
    line.Color = CheatConfig.TracersSettings.Color
    line.Transparency = CheatConfig.TracersSettings.Transparency
    line.Thickness = CheatConfig.TracersSettings.Thickness
    CheatState.ESP[player].TracerObject = line
end

-- // [ Section: ESP Core - OOV ] // -------------------------------------------
function removeOOV(player)
    local data = CheatState.OOVObjects[player]
    if data then
        if data.lines then for _, line in ipairs(data.lines) do pcall(function() line:Remove() end) end end
        if data.text then pcall(function() data.text:Remove() end) end
        CheatState.OOVObjects[player] = nil
    end
end

function applyOOV(player)
    if player == LocalPlayer or not DrawingAvailable then return end
    removeOOV(player)
    local data = { lines = {}, text = newDrawing("Text") }
    for i = 1, 3 do
        local line = newDrawing("Line")
        line.Visible = false
        line.Thickness = 1
        data.lines[i] = line
    end
    data.text.Visible = false
    data.text.Center = true
    data.text.Outline = true
    data.text.Font = 2
    data.text.Size = 13
    CheatState.OOVObjects[player] = data
end

-- // [ Section: ESP Core - Trail (Drawing) ] // -------------------------------
ESP.Trail = {}

function ESP.Trail.Create(player)
    local cfg = CheatConfig.Trail
    if player == LocalPlayer and not cfg.ShowOnSelf then return end
    if CheatState.TrailData[player] then ESP.Trail.Remove(player) end
    CheatState.TrailData[player] = {
        points = {},
        segments = {},
        lastPos = nil,
        lastUpdate = tick(),
        folder = Instance.new("Folder", Workspace)
    }
    CheatState.TrailData[player].folder.Name = "ElysiumTrail_" .. player.Name
end

function ESP.Trail.Remove(player)
    local data = CheatState.TrailData[player]
    if data then
        if data.folder then data.folder:Destroy() end
        CheatState.TrailData[player] = nil
    end
end

function ESP.Trail.Update(player)
    local cfg = CheatConfig.Trail
    if not cfg.Enabled then
        ESP.Trail.Remove(player)
        return
    end

    local isSelf = (player == LocalPlayer)
    if isSelf and not cfg.ShowOnSelf then
        ESP.Trail.Remove(player)
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        ESP.Trail.Remove(player)
        return
    end

    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        ESP.Trail.Remove(player)
        return
    end

    if not isSelf then
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > (cfg.MaxDistance or 500) then
            ESP.Trail.Remove(player)
            return
        end
    end

    local data = CheatState.TrailData[player]
    if not data then
        ESP.Trail.Create(player)
        data = CheatState.TrailData[player]
        if not data then return end
    end

    local now = tick()
    local currentPos = root.Position
    local lastPos = data.lastPos

    local minDist = cfg.MinDistance or 0.5
    if not lastPos or (currentPos - lastPos).Magnitude > minDist then
        table.insert(data.points, { pos = currentPos, time = now })
        data.lastPos = currentPos
    end

    while #data.points > 0 and (now - data.points[1].time) > cfg.Lifetime do
        table.remove(data.points, 1)
    end

    if #data.points > cfg.MaxPoints then
        local excess = #data.points - cfg.MaxPoints
        for i = 1, excess do table.remove(data.points, 1) end
    end

    local neededSegments = math.max(0, #data.points - 1)
    if neededSegments < 1 then
        for _, seg in ipairs(data.segments) do seg.Visible = false end
        return
    end

    while #data.segments < neededSegments do
        local segment = Instance.new("CylinderHandleAdornment")
        segment.Adornee = Workspace.Terrain
        segment.ZIndex = 10
        segment.Parent = data.folder
        table.insert(data.segments, segment)
    end

    for i = 1, neededSegments do
        local seg = data.segments[i]
        local p1 = data.points[i].pos
        local p2 = data.points[i+1].pos
        local mag = (p1 - p2).Magnitude
        if mag < 0.1 then
            seg.Visible = false
        else
            seg.Height = mag
            local age1 = (now - data.points[i].time) / cfg.Lifetime
            local age2 = (now - data.points[i+1].time) / cfg.Lifetime
            local mixAge = (age1 + age2) / 2
            local alpha = math.clamp(1 - mixAge * (1 - cfg.Transparency), 0, 1)
            local width = cfg.Thickness * (1 - mixAge * 0.5)
            seg.Radius = width
            seg.Color3 = cfg.Color
            seg.Transparency = alpha
            seg.CFrame = CFrame.lookAt(p1:Lerp(p2, 0.5), p2)
            seg.AlwaysOnTop = cfg.AlwaysOnTop
            seg.Visible = true
        end
    end

    for i = neededSegments + 1, #data.segments do
        data.segments[i].Visible = false
    end
end

-- // [ Section: Combat Helpers ] // -------------------------------------------
function getOriginPoint()
    local vp = Camera.ViewportSize
    local origin = CheatConfig.TracersSettings.Origin
    if origin == "Bottom" then return Vector2.new(vp.X / 2, vp.Y)
    elseif origin == "Top" then return Vector2.new(vp.X / 2, 0)
    else return Vector2.new(vp.X / 2, vp.Y / 2) end
end

function getTargetPart(character)
    if not character then return nil end
    return character:FindFirstChild(AimPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

function isTargetVisible(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local char = targetPart.Parent
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    if dir.Magnitude < 0.01 then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(origin, dir, rayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(char)
end

function getClosestPlayerToCursor(maxFov)
    local mouse = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortest = maxFov or AimbotFOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local targetPart = player.Character:FindFirstChild(AimPart) or player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen or screenPoint.Z <= 0 then continue end
        local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - mouse).Magnitude
        if dist < shortest then
            shortest = dist
            closestPlayer = player
        end
    end
    return closestPlayer
end

function isTargetAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return getTargetPart(player.Character) ~= nil
end

function aimAt(player)
    if not player or not player.Character then return end
    local targetPart = player.Character:FindFirstChild(AimPart) or player.Character:FindFirstChild("Head")
    if not targetPart then return end
    local targetPos = targetPart.Position
    local lerpFactor = math.clamp(1 - AimbotSmoothing, 0.01, 1)
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), lerpFactor)
end

function isLocalAlive()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

function isSpectatorCamera()
    if isLocalAlive() then return false end
    local subject = Camera.CameraSubject
    if not subject then return true end
    if subject:IsA("Humanoid") then
        local owner = Players:GetPlayerFromCharacter(subject.Parent)
        return owner ~= LocalPlayer
    end
    return true
end

function canRunCombat()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

function updateCombatCursor()
    if not Library or not Options.ShowCustomCursor then return end
    Library.ShowCustomCursor = Options.ShowCustomCursor.Value
end

-- // [ Section: Player Stats & Character Setup ] // ---------------------------
function applyPlayerStats(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        OriginalUseJumpPower = humanoid.UseJumpPower
        OriginalJumpPower = humanoid.JumpPower
        if WalkSpeedEnabled then humanoid.WalkSpeed = WalkSpeedValue end
        if JumpPowerEnabled then humanoid.UseJumpPower = true; humanoid.JumpPower = JumpPowerValue end
    end
end

function onCharacterAdded(player, character)
    if player ~= LocalPlayer then
        ESP.Box.Remove(player)
        ESP.Trail.Remove(player)
        removeTextESP(player)
        removeChams(player)
        removeTracer(player)
        removeSkeleton(player)
        removeOOV(player)
        CheatState.ESP[player] = nil
    else
        CurrentTarget = nil
        AimbotLocked = false
        ESP.Trail.Remove(LocalPlayer)
        setupWeaponTracking(character)
    end
    character:WaitForChild("HumanoidRootPart", 10)
    if player == LocalPlayer then
        applyPlayerStats(character)
        if SniperCustomizationEnabled then restoreSniperCustomization(); applySniperCustomization() end
    end
end

function setupPlayer(player)
    if player == LocalPlayer then
        player.CharacterAdded:Connect(function(c) onCharacterAdded(player, c) end)
        if player.Character then applyPlayerStats(player.Character) end
        return
    end
    player.CharacterAdded:Connect(function(c) onCharacterAdded(player, c) end)
    if player.Character then onCharacterAdded(player, player.Character) end
end

local Backpack = LocalPlayer:WaitForChild("Backpack")
Backpack.ChildAdded:Connect(function(tool)
    if tool.Name == "Sniper" and SniperCustomizationEnabled then
        task.wait()
        table.clear(SniperOriginalProps)
        applySniperCustomization()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i = #CachedPlayerList, 1, -1 do
        if CachedPlayerList[i] == player then
            table.remove(CachedPlayerList, i)
            break
        end
    end
    PlayerSpawnTimes[player] = nil
    pcall(function()
        ESP.Box.Remove(player)
        ESP.Trail.Remove(player)
        removeChams(player)
        removeTracer(player)
        removeSkeleton(player)
        removeOOV(player)
        removeTextESP(player)
    end)
    CheatState.ESPObjects[player] = nil
    CheatState.ESP[player] = nil
end)

-- // [ Section: Render Functions - OOV, Text, Tracers, Skeleton ] // ---------
function renderOOV()
    local cfg = CheatConfig.OOV
    if not cfg.Enabled or not CheatConfig.ESP.Enabled then
        for player, data in pairs(CheatState.OOVObjects) do
            if data.lines then
                for _, l in ipairs(data.lines) do pcall(function() l:Remove() end) end
            end
            if data.text then pcall(function() data.text:Remove() end) end
            CheatState.OOVObjects[player] = nil
        end
        return
    end
    local vp = Camera.ViewportSize
    local cx, cy = vp.X / 2, vp.Y / 2
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not CheatState.OOVObjects[player] and shouldShowESPForPlayer(player) then
            applyOOV(player)
        end
        local data = CheatState.OOVObjects[player]
        if not data then continue end
        if not shouldShowESPForPlayer(player) then
            for _, l in ipairs(data.lines) do l.Visible = false end
            data.text.Visible = false
            continue
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local _, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then
                local dir     = (root.Position - Camera.CFrame.Position)
                local flat    = Vector3.new(dir.X, 0, dir.Z)
                local camFlat = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                local angle   = math.atan2(camFlat.X * flat.Z - camFlat.Z * flat.X, camFlat.X * flat.X + camFlat.Z * flat.Z)
                local px = cx + cfg.Radius * math.sin(angle)
                local py = cy - cfg.Radius * math.cos(angle)
                px = math.clamp(px, cfg.Size + 10, vp.X - cfg.Size - 10)
                py = math.clamp(py, cfg.Size + 10, vp.Y - cfg.Size - 10)
                local alpha = cfg.Transparency
                if cfg.PulseEnabled then
                    alpha = alpha * (0.6 + 0.4 * math.sin(tick() * ((cfg.PulseSpeed or 3.5) * 2)))
                end
                local tip   = Vector2.new(px + cfg.Size * math.sin(angle), py - cfg.Size * math.cos(angle))
                local left  = Vector2.new(px + cfg.Size * 0.5 * math.cos(angle), py + cfg.Size * 0.5 * math.sin(angle))
                local right = Vector2.new(px - cfg.Size * 0.5 * math.cos(angle), py - cfg.Size * 0.5 * math.sin(angle))
                for _, l in ipairs(data.lines) do
                    l.Color = cfg.Color
                    l.Transparency = alpha
                    l.Visible = true
                end
                data.lines[1].From = tip   data.lines[1].To = left
                data.lines[2].From = left  data.lines[2].To = right
                data.lines[3].From = right data.lines[3].To = tip
                data.text.Visible = false
            else
                for _, l in ipairs(data.lines) do l.Visible = false end
                data.text.Visible = false
            end
        else
            for _, l in ipairs(data.lines) do l.Visible = false end
            data.text.Visible = false
        end
    end
end

function renderTextESP()
    if not CheatConfig.ESP.Enabled or not CheatConfig.ESP.Text then return end
    for player, esp in pairs(CheatState.ESP) do
        if not shouldShowESPForPlayer(player) then
            if esp.TextObjects and esp.TextObjects.nameText then
                esp.TextObjects.nameText.Visible = false
            end
            continue
        end
        local data = esp.TextObjects
        if not data or not data.nameText then
            applyTextESP(player)
            data = CheatState.ESP[player] and CheatState.ESP[player].TextObjects
            if not data then continue end
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            data.nameText.Visible = false
            continue
        end
        local distance = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
        local head = char:FindFirstChild("Head")
        local topPos = head and (head.Position + Vector3.new(0, 0.7, 0)) or (root.Position + Vector3.new(0, 3, 0))
        local pos, visible = Camera:WorldToViewportPoint(topPos)
        if visible then
            local ts = CheatConfig.TextSettings
            local displayName = ts.ShowDisplayName and player.DisplayName or player.Name
            local line = displayName
            if ts.ShowDistance then line = line .. "  [" .. distance .. "m]" end
            data.nameText.Position = Vector2.new(pos.X, pos.Y - ts.OffsetY)
            data.nameText.Text = line
            data.nameText.Visible = true
        else
            data.nameText.Visible = false
        end
    end
end

function renderTracers()
    if not CheatConfig.ESP.Enabled or not CheatConfig.ESP.Tracers then return end
    for player, esp in pairs(CheatState.ESP) do
        if not shouldShowESPForPlayer(player) then
            if esp.TracerObject then esp.TracerObject.Visible = false end
            continue
        end
        local line = esp.TracerObject
        if not line then
            applyTracer(player)
            line = CheatState.ESP[player] and CheatState.ESP[player].TracerObject
            if not line then continue end
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            line.Visible = false
            continue
        end
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            line.From = getOriginPoint()
            line.To = Vector2.new(pos.X, pos.Y)
            line.Visible = true
        else
            line.Visible = false
        end
    end
end

function renderSkeleton()
    if not CheatConfig.ESP.Skeleton or not CheatConfig.ESP.Enabled then
        for _, esp in pairs(CheatState.ESP) do
            if esp.SkeletonObject and esp.SkeletonObject.lines then
                for _, line in ipairs(esp.SkeletonObject.lines) do line.Visible = false end
            end
        end
        return
    end
    for player, esp in pairs(CheatState.ESP) do
        if not shouldShowESPForPlayer(player) then
            if esp.SkeletonObject and esp.SkeletonObject.lines then
                for _, line in ipairs(esp.SkeletonObject.lines) do line.Visible = false end
            end
            continue
        end
        local data = esp.SkeletonObject
        if not data or not data.lines then
            applySkeleton(player)
            data = CheatState.ESP[player] and CheatState.ESP[player].SkeletonObject
            if not data then continue end
        end
        local char = player.Character
        if not char then
            for _, line in ipairs(data.lines) do line.Visible = false end
            continue
        end
        for i, bone in ipairs(data.bones) do
            local p1 = char:FindFirstChild(bone[1])
            local p2 = char:FindFirstChild(bone[2])
            local line = data.lines[i]
            if p1 and p2 and line then
                local a, aOn = Camera:WorldToViewportPoint(p1.Position)
                local b, bOn = Camera:WorldToViewportPoint(p2.Position)
                if aOn and bOn then
                    line.From = Vector2.new(a.X, a.Y)
                    line.To = Vector2.new(b.X, b.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif line then
                line.Visible = false
            end
        end
    end
end

function renderCrosshair()
    local ch = CheatConfig.Crosshair
    local char = LocalPlayer.Character
    local isSpawned = char and char:FindFirstChild("Primary")
    local isAlive = char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0
    local isScopedIn = CheatState.IsScopeVisible
    if not ch.Enabled or Library.Opened or not isSpawned or not isAlive or isScopedIn then
        hideAllCrosshairDrawings()
        return
    end
    CrosshairState.PulseTick = CrosshairState.PulseTick + (1 / 60) * ch.PulseSpeed
    if ch.Rotation then
        CrosshairState.Angle = (CrosshairState.Angle + ch.RotSpeed) % 360
    end
    hideAllCrosshairDrawings()
    drawCrosshairStyle(ch)
end

function renderBunnyhop()
    if not BunnyHopEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local state = hum:GetState()
        local now = tick()
        if (now - BunnyHopLastJump) > 0.1 then
            if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                BunnyHopLastJump = now
            end
        end
    end
end

function updateChamsDistance()
    if not CheatConfig.ESP.Enabled or not CheatConfig.ESP.Chams then
        for _, p in ipairs(Players:GetPlayers()) do removeChams(p) end
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not shouldShowESPForPlayer(player) then
            removeChams(player)
            continue
        end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local espData = CheatState.ESP[player]
            local highlight = espData and espData.ChamsObject
            if highlight then
                highlight.FillColor = CheatConfig.ChamsSettings.FillColor
                highlight.FillTransparency = CheatConfig.ChamsSettings.FillTransparency
                highlight.OutlineColor = CheatConfig.ChamsSettings.OutlineColor
                highlight.OutlineTransparency = CheatConfig.ChamsSettings.OutlineTransparency
            else
                applyChams(player)
            end
        else
            removeChams(player)
        end
    end
end

local function hideAllVisuals()
    for _, esp in pairs(CheatState.ESP) do
        if esp.TracerObject then esp.TracerObject.Visible = false end
        if esp.SkeletonObject then for _, l in ipairs(esp.SkeletonObject.lines) do l.Visible = false end end
        if esp.TextObjects and esp.TextObjects.nameText then esp.TextObjects.nameText.Visible = false end
    end
    for _, data in pairs(CheatState.ESPObjects) do
        if data.Box and data.Box.AllLines then
            for _, l in ipairs(data.Box.AllLines) do l.Visible = false end
        end
    end
    for _, data in pairs(CheatState.TrailData) do
        if data.lines then for _, l in ipairs(data.lines) do l.Visible = false end end
    end
end

local function syncVisuals()
    for player, obj in pairs(CheatState.ESP) do
        if obj.TracerObject then
            obj.TracerObject.Color = CheatConfig.TracersSettings.Color
            obj.TracerObject.Thickness = CheatConfig.TracersSettings.Thickness
            obj.TracerObject.Transparency = CheatConfig.TracersSettings.Transparency
        end
        if obj.SkeletonObject then
            for _, line in ipairs(obj.SkeletonObject.lines) do
                line.Color = SkeletonColor
                line.Thickness = SkeletonThickness
                line.Transparency = 1 - SkeletonTransparency
            end
        end
        if obj.ChamsObject then
            local cs = CheatConfig.ChamsSettings
            obj.ChamsObject.FillColor = cs.FillColor
            obj.ChamsObject.OutlineColor = cs.OutlineColor
            obj.ChamsObject.FillTransparency = cs.FillTransparency
            obj.ChamsObject.OutlineTransparency = cs.OutlineTransparency
        end
        if obj.TextObjects and obj.TextObjects.nameText then
            local ts = CheatConfig.TextSettings
            obj.TextObjects.nameText.Color = ts.NameColor
            obj.TextObjects.nameText.Size = ts.NameSize
            obj.TextObjects.nameText.Outline = ts.Outline
            obj.TextObjects.nameText.Font = ts.Font
        end
    end
    for player, data in pairs(CheatState.ESPObjects) do
        if data.Box then
            for _, line in ipairs(data.Box.AllLines) do
                line.Color = CheatConfig.Box.Color
                line.Thickness = 1
                line.Transparency = CheatConfig.Box.Transparency
            end
        end
    end
end

-- // [ Section: Optimized Render Loop ] // ------------------------------------
local Vec2new = Vector2.new
local tick = tick

local lastRayTime = 0
local rayInterval = 0.12
local logicFrame = 0
local PlayerLogicCache = {} 
local LastKeyStatus = false 
local AimbotToggleState = false
local LmbWasDown = false
local lastTracerSpawn = 0

RunService.RenderStepped:Connect(function()
    logicFrame = (logicFrame + 1) % 60
    local now = tick()

    -- Clean lighting periodically and force world visuals every frame
    if logicFrame == 0 then
        if ClockTimeEnabled or FogEnabled or FullBrightEnabled then
            cleanLighting() 
        end
    end

    -- Force apply world settings every frame
    applyCustomWorldVisuals()
    
    local every2 = (logicFrame % 2 == 0)
    local every5 = (logicFrame % 5 == 0)
    
    -- Cursor management
    if Library.Opened then 
        updateCombatCursor() 
    end

    -- Hit Detection
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not Library.Opened then
        if (now - lastRayTime) > 0.05 then
            lastRayTime = now
            local viewportSize = Camera.ViewportSize
            local screenCenter = viewportSize / 2
            local ray = Camera:ViewportPointToRay(screenCenter.X, screenCenter.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            if res then
                local target = res.Instance:FindFirstAncestorOfClass("Model")
                if target and CheatState.ActiveEntities[target] then
                    CheatState.LastShotTarget = target
                    CheatState.LastShotTime = now
                    CheatState.LastShotPart = res.Instance.Name
                end
            end
        end
    end
    
    if CheatConfig.Hitmarker.Enabled or CheatConfig.Hitsound.Enabled or CheatConfig.HitLogs.Enabled then
        processHitDetection()
    end

    -- Aimbot & FOV Circle
    local currentKeyIsDown = isAimbotLockKeyDown()
    if AimMethod:find("Toggle") then
        if currentKeyIsDown and not LastKeyStatus then
            AimbotToggleState = not AimbotToggleState
        end
    else
        AimbotToggleState = currentKeyIsDown
    end
    LastKeyStatus = currentKeyIsDown

    if AimbotEnabled then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = ShowFOVCircle
        if every5 then
            FOVCircle.Radius = AimbotFOV
            FOVCircle.Color = AimbotLocked and FOVCircleLockedColor or FOVCircleColor
        end
        if AimbotToggleState and canRunCombat() then
            if not CurrentTarget or not isTargetAlive(CurrentTarget) then
                CurrentTarget = getClosestPlayerToCursor()
            end
            if CurrentTarget then aimAt(CurrentTarget) AimbotLocked = true else AimbotLocked = false end
        else
            CurrentTarget = nil
            AimbotLocked = false
        end
    else
        FOVCircle.Visible = false
    end

    -- High Performance ESP Loop
    local espEnabled = CheatConfig.ESP.Enabled
    local maxDist = CheatConfig.ESP.MaxDistance or 500
    local camPos = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then 
            continue 
        end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not char or not root or not hum or hum.Health <= 0 then 
            ESP.Box.Hide(player)
            removeTracer(player)
            removeTextESP(player)
            removeSkeleton(player)
            continue 
        end

        local sPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if not onScreen or not espEnabled then
            ESP.Box.Hide(player)
            removeTracer(player)
            removeTextESP(player)
            removeSkeleton(player)
            continue
        end

        if not PlayerLogicCache[player] then PlayerLogicCache[player] = { dist = 0, screenPos = Vec2new(0,0) } end
        local pCache = PlayerLogicCache[player]
        pCache.screenPos = Vec2new(sPos.X, sPos.Y)

        if every5 then pCache.dist = (camPos - root.Position).Magnitude end
        if pCache.dist > maxDist then
            ESP.Box.Hide(player)
            removeTracer(player)
            removeTextESP(player)
            removeSkeleton(player)
            continue
        end

        if CheatConfig.Box.Enabled then ESP.Box.Update(player) else ESP.Box.Hide(player) end

        if CheatConfig.ESP.Tracers then
            local espData = CheatState.ESP[player]
            if not espData or not espData.TracerObject then applyTracer(player) espData = CheatState.ESP[player] end
            if espData.TracerObject then
                espData.TracerObject.From = getOriginPoint()
                espData.TracerObject.To = pCache.screenPos
                espData.TracerObject.Visible = true
            end
        else removeTracer(player) end

        if CheatConfig.ESP.Text then
            local espData = CheatState.ESP[player]
            if not espData or not espData.TextObjects then applyTextESP(player) espData = CheatState.ESP[player] end
            if espData.TextObjects then
                local head = char:FindFirstChild("Head") or root
                local hPos, hOn = Camera:WorldToViewportPoint(head.Position)
                if hOn then
                    if every2 then
                        local name = (CheatConfig.TextSettings.ShowDisplayName and player.DisplayName or player.Name)
                        if CheatConfig.TextSettings.ShowDistance then
                            name = name .. " [" .. math_floor(pCache.dist) .. "m]"
                        end
                        espData.TextObjects.nameText.Text = name
                    end
                    espData.TextObjects.nameText.Position = Vec2new(hPos.X, hPos.Y - CheatConfig.TextSettings.OffsetY)
                    espData.TextObjects.nameText.Visible = true
                else espData.TextObjects.nameText.Visible = false end
            end
        else removeTextESP(player) end

        if CheatConfig.ESP.Skeleton and pCache.dist < 180 then
            local espData = CheatState.ESP[player]
            if not espData or not espData.SkeletonObject then applySkeleton(player) espData = CheatState.ESP[player] end
            if espData and espData.SkeletonObject then
                local data = espData.SkeletonObject
                for i, bone in ipairs(data.bones) do
                    local b1, b2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                    local line = data.lines[i]
                    if b1 and b2 and line then
                        local v1, v1On = Camera:WorldToViewportPoint(b1.Position)
                        local v2, v2On = Camera:WorldToViewportPoint(b2.Position)
                        if v1On and v2On then
                            line.From = Vec2new(v1.X, v1.Y); line.To = Vec2new(v2.X, v2.Y); line.Visible = true
                        else line.Visible = false end
                    elseif line then line.Visible = false end
                end
            end
        else removeSkeleton(player) end
    end

    -- Update trails (throttled)
    if CheatConfig.Trail.Enabled and (logicFrame % 2 == 0) then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then
                if CheatConfig.Trail.ShowOnSelf then
                    ESP.Trail.Update(player)
                else
                    ESP.Trail.Remove(player)
                end
            else
                ESP.Trail.Update(player)
            end
        end
    end

    -- Post-process
    if CheatConfig.OOV.Enabled and espEnabled then 
        renderOOV() 
    else
        for _, p in ipairs(Players:GetPlayers()) do removeOOV(p) end
    end
    
    if every2 then updateChamsDistance() end
    renderCrosshair()
    if BunnyHopEnabled then renderBunnyhop() end
    if (logicFrame % 15 == 0) and SniperCustomizationEnabled then applySniperCustomization() end
end)

-- // [ Section: UI Building Functions ] // ------------------------------------
-- Notify
function notifyElysium(feat, state)
    Library:Notify({Title = "Elysium.win", Description = state and ('<font color="#6dd18a">'..feat..'</font> enabled') or ('<font color="#d16d6d">'..feat..'</font> disabled'), Time = 3})
end

-- // [ Section: UI Building Functions - Home Tab] // ------------------------------------
function buildHomeTab()
    local WelcomeGroup = Tabs.Home:AddLeftGroupbox("Welcome", "home")
    WelcomeGroup:AddLabel(string.format('<font color="#6dd18a">%s, %s!</font>', getGreeting(), LocalPlayer.Name))
    WelcomeGroup:AddDivider()
    WelcomeGroup:AddLabel("Current Game: [FPS] One Tap")
    WelcomeGroup:AddLabel("Build Date: 10.06.2026")
    WelcomeGroup:AddLabel("Version: v1.0.1")

    local ChangelogGroup = Tabs.Home:AddLeftGroupbox("Changelog", "code-xml")
    ChangelogGroup:AddLabel("[+] Fixed crosshair & OOV issues")
    ChangelogGroup:AddLabel("[*] Improved hitmarker reliability")

    local SocialsGroup = Tabs.Home:AddRightGroupbox("Socials & Info", "share-2")
    SocialsGroup:AddButton("Copy Discord Link", function()
        if setclipboard then
            setclipboard("https://discord.gg/elysium")
            Library:Notify("Discord link copied to clipboard!")
        else
            Library:Notify("Your executor does not support setclipboard.")
        end
    end)
    SocialsGroup:AddLabel("Developed by: Elysium Team")
    SocialsGroup:AddLabel("Supported Executors: Wave, Solara, Celery, Synapse Z")
end

-- // [ Section: UI Building Functions - Visuals Tab ] // ------------------------------------
function buildVisualsTab()
    local ESPTabbox = Tabs.Visuals:AddLeftTabbox()
    
    local EnableTab = ESPTabbox:AddTab("ESP")
    EnableTab:AddToggle("MasterESPEn", {Text="Enable ESP", Default=false, Callback=function(v)CheatConfig.ESP.Enabled=v end})
    :AddKeyPicker("ESPKey", {Default="None", Mode="Toggle", SyncToggleState=true, Text="ESP Key", Callback=function(v) CheatConfig.ESP.Enabled = v end})
    EnableTab:AddDivider()
    EnableTab:AddToggle("ChEn", {Text = "Enable Chams", Default = false, Callback = function(v) CheatConfig.ESP.Chams = v end})
    EnableTab:AddToggle("TxEn", {Text = "Enable Text", Default = false, Callback = function(v) CheatConfig.ESP.Text = v end})
    EnableTab:AddToggle("TrEn", {Text = "Enable Tracers", Default = false, Callback = function(v) CheatConfig.ESP.Tracers = v end})
    EnableTab:AddToggle("BoxEn", {Text = "Enable Boxes", Default = false, Callback = function(v) CheatConfig.Box.Enabled = v end})
    EnableTab:AddToggle("SkEn", {Text = "Enable Skeleton", Default = false, Callback = function(v) CheatConfig.ESP.Skeleton = v end})
    EnableTab:AddToggle("OVEn", {Text = "Enable OOV", Default = false, Callback = function(v) CheatConfig.OOV.Enabled = v end})

    local SettingsTab = ESPTabbox:AddTab("ESP Settings")
    
    SettingsTab:AddLabel("Chams Settings")
    SettingsTab:AddLabel("Fill Color"):AddColorPicker("ChamsFill", {Default = CheatConfig.ChamsSettings.FillColor, Callback = function(v) CheatConfig.ChamsSettings.FillColor = v; syncVisuals() end})
    SettingsTab:AddLabel("Outline Color"):AddColorPicker("ChamsOutline", {Default = CheatConfig.ChamsSettings.OutlineColor, Callback = function(v) CheatConfig.ChamsSettings.OutlineColor = v; syncVisuals() end})
    SettingsTab:AddSlider("FillTrans", {Text = "Fill Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.ChamsSettings.FillTransparency = v; syncVisuals() end})
    SettingsTab:AddSlider("OutTrans", {Text = "Outline Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.ChamsSettings.OutlineTransparency = v; syncVisuals() end})
    SettingsTab:AddDivider()

    SettingsTab:AddLabel("Text Settings")
    SettingsTab:AddToggle("TSDN", {Text = "Use Display Name", Default = false, Callback = function(v) CheatConfig.TextSettings.ShowDisplayName = v end})
    SettingsTab:AddToggle("TSD", {Text = "Show Distance", Default = true, Callback = function(v) CheatConfig.TextSettings.ShowDistance = v end})
    SettingsTab:AddDropdown("TextFont", {Values={"UI","Plex","Monospace"}, Default="Monospace", Text="Text Font", Callback=function(v) CheatConfig.TextSettings.Font = ({UI=0,Plex=2,Monospace=3})[v] or 3 syncVisuals() end})
    SettingsTab:AddSlider("TextSize", {Text = "Font Size", Default = 12, Min = 8, Max = 14, Rounding = 1, Callback = function(v) CheatConfig.TextSettings.NameSize = v; syncVisuals() end})
    SettingsTab:AddLabel("Text Color"):AddColorPicker("TextColor", {Default = CheatConfig.TextSettings.NameColor, Callback = function(v) CheatConfig.TextSettings.NameColor = v; syncVisuals() end})
    SettingsTab:AddDivider()

    SettingsTab:AddLabel("Tracers Settings")
    SettingsTab:AddDropdown("TracerOrigin", {Values = {"Bottom", "Center", "Top"}, Default = "Center", Text = "Origin", Callback = function(v) CheatConfig.TracersSettings.Origin = v end})
    SettingsTab:AddLabel("Color"):AddColorPicker("TracerColor", {Default = CheatConfig.TracersSettings.Color, Callback = function(v) CheatConfig.TracersSettings.Color = v; syncVisuals() end})
    SettingsTab:AddSlider("TracerThick", {Text = "Thickness", Default = 1, Min = 1, Max = 2.5, Rounding = 1, Callback = function(v) CheatConfig.TracersSettings.Thickness = math.clamp(v, 1, 2.5); syncVisuals() end})
    SettingsTab:AddSlider("TracerTrans", {Text = "Transparency", Default = 0.85, Min = 0, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.TracersSettings.Transparency = v; syncVisuals() end})
    SettingsTab:AddDivider()

    SettingsTab:AddLabel("Boxes Settings")
    SettingsTab:AddDropdown("BoxStyle", {Values = {"Corner Box", "Full Box"}, Default = "Full Box", Text = "Style", Callback = function(v) CheatConfig.Box.Style = v end})
    SettingsTab:AddLabel("Color"):AddColorPicker("BoxColor", {Default = CheatConfig.Box.Color, Callback = function(v) CheatConfig.Box.Color = v; syncVisuals() end})
    SettingsTab:AddSlider("BoxSize", {Text = "Size", Default = 0.6, Min = 0.3, Max = 1.2, Rounding = 1, Callback = function(v) CheatConfig.Box.WidthScale = v end})
    SettingsTab:AddSlider("BoxThick", {Text = "Thickness", Default = 1, Min = 1, Max = 3, Rounding = 1, Callback = function(v) CheatConfig.Box.Thickness = math.clamp(v, 1, 3); syncVisuals() end})
    SettingsTab:AddSlider("BoxTrans", {Text = "Transparency", Default = 1, Min = 0, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.Box.Transparency = v; syncVisuals() end})
    SettingsTab:AddDivider()

    SettingsTab:AddLabel("Skeleton Settings")
    SettingsTab:AddLabel("Color"):AddColorPicker("SkelColor", {Default = SkeletonColor, Callback = function(v) SkeletonColor = v; syncVisuals() end})
    SettingsTab:AddSlider("SkelThick", {Text = "Thickness", Default = 1, Min = 1, Max = 2.5, Rounding = 1, Callback = function(v) SkeletonThickness = v; syncVisuals() end})
    SettingsTab:AddSlider("SkelTrans", {Text = "Transparency", Default = 0, Min = 0, Max = 1, Rounding = 1, Callback = function(v) SkeletonTransparency = v; syncVisuals() end})
    SettingsTab:AddDivider()

    SettingsTab:AddLabel("OOV Arrows Settings")
    SettingsTab:AddLabel("Color"):AddColorPicker("OOVColor", {Default = CheatConfig.OOV.Color, Callback = function(v) CheatConfig.OOV.Color = v end})
    SettingsTab:AddSlider("OOVRadius", {Text = "Radius", Default = 45, Min = 10, Max = 200, Rounding = 1, Callback = function(v) CheatConfig.OOV.Radius = v end})
    SettingsTab:AddSlider("OOVSize", {Text = "Arrow Size", Default = 20, Min = 5, Max = 35, Rounding = 1, Callback = function(v) CheatConfig.OOV.Size = v end})
    SettingsTab:AddSlider("OOVTrans", {Text = "Transparency", Default = 1, Min = 0, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.OOV.Transparency = v end})
    SettingsTab:AddToggle("OOVPulse", {Text = "Pulse Effect", Default = false, Callback = function(v) CheatConfig.OOV.PulseEnabled = v end})
    SettingsTab:AddSlider("OOVPulseSpeed", {Text = "Pulse Speed", Default = 3.5, Min = 1, Max = 5, Rounding = 1, Callback = function(v) CheatConfig.OOV.PulseSpeed = v end})

    local WorldTabbox = Tabs.Visuals:AddLeftTabbox()

    local BasicTab = WorldTabbox:AddTab("World")
    BasicTab:AddToggle("ClockTimeEn", {Text = "Enable Clock Time", Default = false, Callback = function(v) ClockTimeEnabled = v end})
    BasicTab:AddSlider("ClockTimeVal", {Text = "Clock Time", Default = 14.5, Min = 0, Max = 24, Rounding = 1, Callback = function(v) ClockTimeValue = v end})
    BasicTab:AddDivider()
    BasicTab:AddToggle("FullBrightEn", {Text = "FullBright", Default = false, Callback = function(v) FullBrightEnabled = v end})
    BasicTab:AddSlider("FullBrightVal", {Text = "Brightness", Default = 2, Min = 1, Max = 7, Rounding = 1, Callback = function(v) FullBrightValue = v end})
    BasicTab:AddToggle("NoShadowsEn", {Text = "Disable Shadows", Default = false, Callback = function(v) NoShadowsEnabled = v end})

    local AdvancedTab = WorldTabbox:AddTab("Advanced")
    
    AdvancedTab:AddLabel("Skybox Changer")
    AdvancedTab:AddToggle("SkyboxChangerEnabled", {Text="Enable Skybox Changer", Default=false, Callback=function(v)SkyboxChangerEnabled=v;setSkybox(SelectedSkybox)end})
    AdvancedTab:AddDropdown("SkyboxPreset", {Values={"Sunset","Sun set 2","Deep Space","Nebula","Blue Sky"}, Default="Sunset", Text="Skybox", Callback=function(v)SelectedSkybox=v;setSkybox(SelectedSkybox)end})
    AdvancedTab:AddDivider()
    AdvancedTab:AddToggle("FogEnabled", {Text="Enable Fog", Default=false, Callback=function(v)FogEnabled=v end})
    AdvancedTab:AddLabel("Fog Color"):AddColorPicker("FogColor", {Default=FogColor, Callback=function(v)FogColor=v end})
    AdvancedTab:AddSlider("FogStart", {Text="Fog Start", Default=0, Min=0, Max=2000, Rounding=1, Callback=function(v)FogStart=v end})
    AdvancedTab:AddSlider("FogEnd", {Text="Fog End", Default=1000, Min=100, Max=2000, Rounding=1, Callback=function(v)FogEnd=v end})
    AdvancedTab:AddDivider()
    AdvancedTab:AddToggle("AmbientColorEnabled", {Text="Enable Ambient Color", Default=false, Callback=function(v)AmbientColorEnabled=v end})
    AdvancedTab:AddLabel("Ambient Color"):AddColorPicker("AmbientColor", {Default=AmbientColor, Callback=function(v)AmbientColor=v end})

    local BulletTabbox = Tabs.Visuals:AddRightTabbox()
    local BMainTab = BulletTabbox:AddTab("Bullet Tracers")
    local BSetTab = BulletTabbox:AddTab("Settings")

    BMainTab:AddToggle("BTrEn", {Text = "Enable Bullet Tracers", Default = false, Callback = function(v) CheatConfig.BulletTracer.Enabled = v end})
    BMainTab:AddLabel("Laser Color"):AddColorPicker("BTCol", {Default = CheatConfig.BulletTracer.Color, Callback = function(v) CheatConfig.BulletTracer.Color = v end})
    BMainTab:AddSlider("BTThick", {Text = "Laser Thickness", Default = 1, Min = 1, Max = 5, Rounding = 1, Callback = function(v) CheatConfig.BulletTracer.Thickness = v end})
    BMainTab:AddSlider("BTLife", {Text = "Laser Lifetime", Default = 2, Min = 0.1, Max = 8, Rounding = 1, Callback = function(v) CheatConfig.BulletTracer.Lifetime = v end})

    BSetTab:AddDropdown("BTMat", {Values={"Neon","ForceField","Plastic","SmoothPlastic","Glass"}, Default="Neon", Text="Material", Callback=function(v) CheatConfig.BulletTracer.Material = Enum.Material[v] end})
    BSetTab:AddSlider("BTOfs", {Text="Spawn Offset", Default=2, Min=0, Max=10, Rounding=1, Callback=function(v) CheatConfig.BulletTracer.SpawnOffset = v end})
    BSetTab:AddToggle("BTFade", {Text="Fade Effect", Default=true, Callback=function(v) CheatConfig.BulletTracer.Fade = v end})

    local DamageTabbox = Tabs.Visuals:AddRightTabbox()
    local DMainTab = DamageTabbox:AddTab("Damage Logs")
    local DSetTab = DamageTabbox:AddTab("Settings")

    DMainTab:AddToggle("HLEn", {Text = "Enable Hit Logs", Default = false, Callback = function(v) CheatConfig.HitLogs.Enabled = v end})
    DMainTab:AddLabel("Log Color"):AddColorPicker("LogCol", {Default = CheatConfig.HitLogs.Color, Callback = function(v) CheatConfig.HitLogs.Color = v end})
    DMainTab:AddSlider("LogLife", {Text = "Log Lifetime", Default = 3, Min = 1, Max = 10, Rounding = 1, Callback = function(v) CheatConfig.HitLogs.Lifetime = v end})

    DSetTab:AddToggle("DLPart", {Text="Show Hit Part", Default=true, Callback=function(v) CheatConfig.HitLogs.ShowPart = v end})
    DSetTab:AddToggle("DLHP", {Text="Show Remaining HP", Default=true, Callback=function(v) CheatConfig.HitLogs.ShowHP = v end})

    local HitGroup = Tabs.Visuals:AddRightGroupbox("Hitmarker")
    HitGroup:AddToggle("HMEn", {Text = "Enable Hitmarker", Default = false, Callback = function(v) CheatConfig.Hitmarker.Enabled = v end})
    HitGroup:AddLabel("Color"):AddColorPicker("HMCol", {Default = CheatConfig.Hitmarker.Color, Callback = function(v) CheatConfig.Hitmarker.Color = v end})
    HitGroup:AddSlider("HMThick", {Text = "Thickness", Default = 1.5, Min = 1, Max = 5, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Thickness = v end})
    HitGroup:AddSlider("HMSize", {Text = "Size", Default = 10, Min = 2, Max = 40, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Size = v end})
    HitGroup:AddSlider("HMGap", {Text = "Center Gap", Default = 5, Min = 0, Max = 20, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Gap = v end})
    HitGroup:AddSlider("HMLife", {Text = "Lifetime (sec)", Default = 0.2, Min = 0.1, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Lifetime = v end})

    local AudioGroup = Tabs.Visuals:AddRightGroupbox("Hitsound")
    AudioGroup:AddToggle("HSEn", {Text = "Enable Hitsound", Default = false, Callback = function(v) onHitsoundEnabledChanged(v) end})
    AudioGroup:AddDropdown("HSPreset", {Values = {"Neverlose", "Primordial", "Call Of Duty", "Metallic", "ENB", "Fatality", "Trident Pierce", "CS:GO"}, Default = "Neverlose", Text = "Sound Preset", Callback = function(v)
        CheatConfig.Hitsound.SoundId = HitsoundPresets[v] or HitsoundPresets.Neverlose
    end})
    AudioGroup:AddSlider("HSVol", {Text = "Volume", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CheatConfig.Hitsound.Volume = v end})
    AudioGroup:AddSlider("HSPitch", {Text = "Pitch", Default = 1, Min = 0.1, Max = 2, Rounding = 1, Callback = function(v) CheatConfig.Hitsound.Pitch = v end})
    AudioGroup:AddButton("Test Hitsound", function()
        playElysiumSound(true)
    end)
end

-- // [ Section: UI Building Functions - Combat Tab ] // ------------------------------------
function buildCombatTab()
    local AimG = Tabs.Combat:AddLeftGroupbox("Aimbot", "crosshair")
    local AimS = Tabs.Combat:AddRightGroupbox("Aimbot Settings", "settings")
    local Trig = Tabs.Combat:AddLeftGroupbox("Trigger Bot", "zap")
    local Aura = Tabs.Combat:AddLeftGroupbox("Instant Kill", "zap")

    AimG:AddToggle("AEn", {Text = "Enable Aimbot", Default = false, Callback = function(v) AimbotEnabled = v end})
    AimG:AddLabel("Lock Key"):AddKeyPicker("ALock", {Default = "None", Mode = "Toggle", Text = "Lock"})
    AimG:AddDropdown("APart", {Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Default = "Head", Text = "Target Part", Callback = function(v) AimPart = v end})

    AimS:AddSlider("ASmooth", {Text = "Smoothing", Default = 0, Min = 0, Max = 0.9, Rounding = 1, Callback = function(v) AimbotSmoothing = v end})
    AimS:AddSlider("AFov", {Text = "FOV Radius", Default = 200, Min = 50, Max = 800, Rounding = 1, Callback = function(v) AimbotFOV = v; FOVCircle.Radius = v end})
    AimS:AddToggle("AWCheck", {Text = "Wall Check", Default = false, Callback = function(v) AimbotWallCheck = v end})
    AimS:AddDivider()
    AimS:AddToggle("SFOV", {Text = "Show FOV Circle", Default = true, Callback = function(v) ShowFOVCircle = v end})
    AimS:AddLabel("FOV Color"):AddColorPicker("FCol", {Default = FOVCircleColor, Callback = function(v) FOVCircleColor = v end})
    AimS:AddLabel("Locked Color"):AddColorPicker("LCol", {Default = FOVCircleLockedColor, Callback = function(v) FOVCircleLockedColor = v end})

    Trig:AddToggle("TEn", {Text = "Enable Trigger Bot", Default = false, Callback = function(v) TriggerBotEnabled = v; notifyElysium("Trigger Bot", v) end})
    Trig:AddSlider("TDelay", {Text = "Shot Delay (ms)", Default = 2, Min = 0, Max = 100, Rounding = 1, Callback = function(v) TriggerBotDelay = v / 1000 end})

    Aura:AddToggle("KEn", {Text = "Enable Kill Aura", Default = false, Callback = function(v) KillAuraEnabled = v; notifyElysium("Kill Aura", v) end})
    Aura:AddSlider("KDist", {Text = "Distance", Default = 4, Min = 1, Max = 15, Rounding = 1, Callback = function(v) KillAuraDistance = v end})
end

-- // [ Section: UI Building Functions - Misc Tab ] // ------------------------------------
function buildMiscTab()
    local CrossMain = Tabs.Misc:AddLeftGroupbox("Crosshair", "crosshair")
    local Game = Tabs.Misc:AddLeftGroupbox("Game Settings", "gamepad-2")

    CrossMain:AddToggle("CrEn", {Text = "Enable Crosshair", Default = false, Callback = function(v) setCrosshairEnabled(v) end})
    CrossMain:AddDropdown("CrStyle", {Values = {"Cross","Plus","T","X","Corners","Dot","Circle"}, Default = "Cross", Text = "Style", Callback = function(v) CheatConfig.Crosshair.Style = v end})
    CrossMain:AddDivider()
    CrossMain:AddToggle("HitEn", {Text = "Enable Hitmarker", Default = false, Callback = function(v) CheatConfig.Hitmarker.Enabled = v end})

    local CrossSettings = Tabs.Misc:AddRightGroupbox("Crosshair Settings", "settings")
    CrossSettings:AddLabel("Color"):AddColorPicker("CrCol", {Default = CheatConfig.Crosshair.Color, Callback = function(v) CheatConfig.Crosshair.Color = v end})
    CrossSettings:AddSlider("CrTrans", {Text = "Transparency", Default = 0, Min = 0, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.Transparency = v end})
    CrossSettings:AddSlider("CrSize", {Text = "Size", Default = 10, Min = 2, Max = 100, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.Size = v end})
    CrossSettings:AddSlider("CrThick", {Text = "Thickness", Default = 1, Min = 1, Max = 6, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.Thickness = v end})
    CrossSettings:AddSlider("CrGap", {Text = "Gap", Default = 4, Min = 0, Max = 50, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.Gap = v end})
    CrossSettings:AddDivider()
    CrossSettings:AddToggle("CrPulse", {Text = "Pulse Effect", Default = false, Callback = function(v) CheatConfig.Crosshair.Pulse = v end})
    CrossSettings:AddSlider("CrPulseAm", {Text = "Pulse Amount", Default = 0.25, Min = 0.05, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.PulseAmount = v end})
    CrossSettings:AddSlider("CrPulseSpd", {Text = "Pulse Speed", Default = 3, Min = 1, Max = 10, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.PulseSpeed = v end})
    CrossSettings:AddDivider()
    CrossSettings:AddToggle("CrRot", {Text = "Rotation", Default = false, Callback = function(v) CheatConfig.Crosshair.Rotation = v end})
    CrossSettings:AddSlider("CrRotSpd", {Text = "Rotation Speed", Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.RotSpeed = v end})
    CrossSettings:AddDivider()
    CrossSettings:AddToggle("CrDot", {Text = "Center Dot", Default = false, Callback = function(v) CheatConfig.Crosshair.ShowCenterDot = v end})
    CrossSettings:AddSlider("CrDotRad", {Text = "Dot Radius", Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v) CheatConfig.Crosshair.CenterDotRadius = v end})
    CrossSettings:AddToggle("HideGameCrosshair", {Text = "Hide Game Crosshair", Default = CheatConfig.Crosshair.HideGameCrosshair, Callback = function(v) CheatConfig.Crosshair.HideGameCrosshair = v end})

    local HitSettings = Tabs.Misc:AddRightGroupbox("Hitmarker Settings", "target")
    HitSettings:AddLabel("Color"):AddColorPicker("HitCol", {Default = CheatConfig.Hitmarker.Color, Callback = function(v) CheatConfig.Hitmarker.Color = v end})
    HitSettings:AddSlider("HitThick", {Text = "Thickness", Default = 1.5, Min = 1, Max = 5, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Thickness = v end})
    HitSettings:AddSlider("HitSize", {Text = "Line Length", Default = 10, Min = 2, Max = 40, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Size = v end})
    HitSettings:AddSlider("HitGap", {Text = "Center Gap", Default = 5, Min = 0, Max = 20, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Gap = v end})
    HitSettings:AddSlider("HitLife", {Text = "Lifetime", Default = 0.2, Min = 0.1, Max = 1, Rounding = 1, Callback = function(v) CheatConfig.Hitmarker.Lifetime = v end})

    Game:AddToggle("DScope", {Text = "Disable Scope", Default = false, Callback = function(v) 
        DisableScopeEnabled = v
        if v then enableDisableScope() else disableDisableScope() end
    end})
    Game:AddToggle("LEff", {Text = "Low Effects (FPS Boost)", Default = false, Callback = function(v) 
        LowEffectsEnabled = v
        if v then enableLowEffects() else disableLowEffects() end
    end})
    Game:AddToggle("AAfk", {Text = "Anti-AFK", Default = false, Callback = function(v) 
        AntiAfkEnabled = v
        if v then startAntiAfk() else stopAntiAfk() end
    end})
    Game:AddDivider()
    Game:AddToggle("SCust", {Text = "Enable Sniper Custom", Default = false, Callback = function(v) 
        SniperCustomizationEnabled = v
        if v then applySniperCustomization() else restoreSniperCustomization() end
    end})
    Game:AddLabel("Sniper Color"):AddColorPicker("SCol", {Default = Color3.fromRGB(255,255,255), Callback = function(v) 
        SniperCustomColor = v
        applySniperCustomization()
    end})
    Game:AddSlider("STrans", {Text = "Sniper Transparency", Default = 0, Min = 0, Max = 1, Rounding = 1, Callback = function(v) 
        SniperCustomTransparency = v
        applySniperCustomization()
    end})
end

-- // [ Section: UI Building Functions - Movement Tab ] // ------------------------------------
function buildMoveTab()
    local Move = Tabs.Movement:AddLeftGroupbox("Movement", "user")
    local Jump = Tabs.Movement:AddRightGroupbox("Jump", "chevrons-up")
    Move:AddToggle("WSEn", {Text = "Enable Walk Speed", Default = false, Callback = function(v) WalkSpeedEnabled = v end})
    Move:AddSlider("WSVal", {Text = "Speed Value", Default = 16, Min = 16, Max = 200, Rounding = 1, Callback = function(v) WalkSpeedValue = v end})
    Move:AddToggle("BHop", {Text = "Bunny Hop", Default = false, Callback = function(v) BunnyHopEnabled = v end})
    Jump:AddToggle("JPEn", {Text = "Enable Jump Power", Default = false, Callback = function(v) JumpPowerEnabled = v end})
    Jump:AddSlider("JPVal", {Text = "Power Value", Default = 50, Min = 50, Max = 300, Rounding = 1, Callback = function(v) JumpPowerValue = v end})
    Jump:AddToggle("InfJ", {Text = "Infinite Jump", Default = false, Callback = function(v) InfiniteJumpEnabled = v end})
end

-- // [ Section: UI Building Functions - Settings Tab ] // ------------------------------------
function buildSettingsTab()
    local Menu = Tabs.UISettings:AddLeftGroupbox("Menu", "wrench")
    Menu:AddToggle("KeyMenu", {Text = "Open Keybind Menu", Default = true, Callback = function(v) Library.KeybindFrame.Visible = v end})
    Menu:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(v) Library.ShowCustomCursor = v end})
    Menu:AddDropdown("NotifySide", {Values = {"Left", "Right"}, Default = "Right", Text = "Notification Side", Callback = function(v) Library:SetNotifySide(v) end})
    Menu:AddDropdown("DPIScale", {Values = {"50%","75%","100%","125%","150%","175%","200%"}, Default = "100%", Text = "DPI Scale", Callback = function(v) Library:SetScale(tonumber(v:sub(1,-2))/100) end})
    Menu:AddSlider("Corner", {Text = "Corner Radius", Default = 2, Min = 0, Max = 20, Rounding = 1, Callback = function(v) Window:SetCornerRadius(v) end})
    Menu:AddDivider()
    Menu:AddLabel("Menu Bind"):AddKeyPicker("MenuKey", {Default = "RightShift", NoUI = true, Text = "Menu"})
    Menu:AddButton("Unload", function() Library:Unload() end)

    Library.ToggleKeybind = Options.MenuKey
    ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({"MenuKey"})
    ThemeManager:ApplyToTab(Tabs.UISettings); SaveManager:BuildConfigSection(Tabs.UISettings)
end

-- // [ Section: Final Startup & Persistent Loops ] // -------------------------
ThemeManager:ApplyTheme("Quant")
ThemeManager:SetFolder("ElysiumWin")
SaveManager:SetFolder("ElysiumWin/FPSOneTap")

buildHomeTab()
buildVisualsTab()
buildCombatTab()
buildMiscTab()
buildMoveTab()
buildSettingsTab()

SaveManager:LoadAutoloadConfig()

local function lockScope(obj)
    if obj:IsA("GuiObject") and obj.Name:lower():find("scope") then
        local function updateState()
            CheatState.IsScopeVisible = obj.Visible
            if DisableScopeEnabled and obj.Visible then
                obj.Visible = false
            end
        end
        obj:GetPropertyChangedSignal("Visible"):Connect(updateState)
        updateState()
    end
end

game.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") then
        pcall(applyMuteLogic, obj)
    elseif obj:IsA("GuiObject") then
        lockScope(obj)
    end
end)

for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
    lockScope(v)
end

RunService.RenderStepped:Connect(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local crossGui = pg and pg:FindFirstChild("Crosshair")
    if not crossGui then return end

    local shouldHideGameCross = CheatConfig.Crosshair.Enabled and CheatConfig.Crosshair.HideGameCrosshair

    for _, obj in ipairs(crossGui:GetChildren()) do
        if obj:IsA("GuiObject") then
            local name = obj.Name:lower()
            if not name:find("scope") then
                if shouldHideGameCross then
                    if obj.Visible then obj.Visible = false end
                else
                    if not obj.Visible then obj.Visible = true end
                end
            end
        end
    end
end)

-- // [ Section: МОЩНЫЙ TRIGGER BOT (Engine Level) ] // -------------------------
RunService.RenderStepped:Connect(function()
    -- Если триггер выключен, меню открыто или ты мертв — ничего не делаем
    if not TriggerBotEnabled or Library.Opened or not isLocalAlive() then return end
    
    local now = tick()
    -- Проверка задержки выстрела
    if now - TriggerBotLastShot < (TriggerBotDelay or 0) then return end

    -- Находим наше оружие (Тул в руках)
    local character = LocalPlayer.Character
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- Raycast: проверяем, что прицел на враге
    local vpSize = Camera.ViewportSize
    local center = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    
    local params = RaycastParams.new()
    -- Игнорируем себя, камеру и спецэффекты, чтобы не стрелять в "невидимки"
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, Camera, Workspace:FindFirstChild("Effects")}
    
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    
    if result and result.Instance then
        -- Ищем модель игрока или NPC
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
            -- Проверяем, что это не мы сами и цель жива
            local hum = hitModel:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and hitModel ~= character then
                
                -- Проверка на команду (если нужно)
                local targetPlayer = Players:GetPlayerFromCharacter(hitModel)
                -- В [FPS] One Tap обычно Free For All, поэтому стреляем во всех
                
                TriggerBotLastShot = now
                
                -- СПОСОБ 1: Прямая активация Тулзы (самый надежный)
                tool:Activate()
                
                -- СПОСОБ 2: Если в игре кастомная система, имитируем клик через инжектор
                if mouse1press and mouse1release then
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                end
            end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
RunService:BindToRenderStep("SpinBotUpdate", Enum.RenderPriority.Camera.Value + 1, updateSpinBot)

task.spawn(function()
    while true do
        updateEntityCache()
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local frames = 0
        local start = tick()
        while tick() - start < 1 do
            RunService.RenderStepped:Wait()
            frames += 1
        end
        FPS = frames
    end
end)

task.spawn(function()
    while true do
        local stats = game:GetService("Stats")
        local network = stats.Network.ServerStatsItem["Data Ping"]
        Ping = math.floor(network:GetValue())
        local timeStr = os.date("%H:%M:%S")
        local fpsColor = getFPSColor(FPS)
        local pingColor = getPingColor(Ping)
        Watermark:SetText(string.format(
            '%s | FPS: <font color="%s">%d</font> | Ping: <font color="%s">%d ms</font> | Time: %s',
            LocalPlayer.Name, fpsColor, FPS, pingColor, Ping, timeStr
        ))
        task.wait(1)
    end
end)

onHitsoundEnabledChanged(CheatConfig.Hitsound.Enabled)

Library.KeybindFrame.Visible = true
Library:Notify({Title = "Elysium.win", Description = "Script loaded successfully. All World features are now functional!", Time = 5})
