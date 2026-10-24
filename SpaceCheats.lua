-- SpaceCheats v0.1.0 — interface prototype.
-- All combat/ESP/movement switches store preferences only.
-- This version does not change weapons, aim, players, or movement.
-- The FOV option draws a UI preview circle only.
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
assert(player, "SpaceCheats precisa executar no cliente Roblox.")
local parent = player:WaitForChild("PlayerGui")
local env = (type(getgenv) == "function" and getgenv()) or _G
local previous = env.SpaceCheatsPreview
if type(previous) == "table" and type(previous.Destroy) == "function" then
    previous.Destroy()
end
local C = {
    bg = Color3.fromRGB(8, 12, 21), panel = Color3.fromRGB(14, 21, 35),
    card = Color3.fromRGB(20, 30, 48), line = Color3.fromRGB(35, 53, 77),
    blue = Color3.fromRGB(48, 139, 255), text = Color3.fromRGB(233, 241, 255),
    muted = Color3.fromRGB(143, 162, 188)
}
local settings = {
    Aimbot = false, VisibleCheck = true, TeamCheck = true,
    BoxESP = false, ShowFOV = false, InfiniteJump = false,
    FastFire = false, InstantReload = false, FOVRadius = 100,
    Smoothness = 50, AimPart = "Head"
}
local defaults = {}
for k, v in pairs(settings) do defaults[k] = v end
local connections, refreshers, alive = {}, {}, true
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function make(class, props, container)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = container
    return obj
end
local function corner(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end
local function label(container, text, size, position, dimensions, color)
    return make("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = size,
        TextColor3 = color or C.text, BackgroundTransparency = 1,
        Position = position, Size = dimensions, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    }, container)
end
local function button(container, text, position, size, color)
    local obj = make("TextButton", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 14,
        TextColor3 = C.text, BackgroundColor3 = color or C.card,
        BorderSizePixel = 0, Position = position, Size = size,
        AutoButtonColor = true
    }, container)
    corner(obj, 8)
    return obj
end
local gui = make("ScreenGui", {
    Name = "SpaceCheatsPreview", ResetOnSpawn = false,
    IgnoreGuiInset = false, DisplayOrder = 80, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, parent)
local root = make("Frame", {
    BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)
}, gui)
local fov = make("Frame", {
    Name = "FOVPreview", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(200, 200),
    BackgroundTransparency = 1, Visible = false
}, root)
corner(fov, 10000)
make("UIStroke", {Color = C.blue, Thickness = 2, Transparency = 0.15}, fov)
local window = make("Frame", {
    Name = "Menu", Size = UDim2.fromOffset(550, 400),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true
}, root)
corner(window, 14)
make("UIStroke", {Color = C.line, Thickness = 1}, window)
local scale = make("UIScale", {Scale = 1}, window)
local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = C.panel, BorderSizePixel = 0,
    Active = true
}, window)
label(header, "S", 24, UDim2.fromOffset(18, 10), UDim2.fromOffset(30, 40), C.blue)
label(header, "SpaceCheats", 21, UDim2.fromOffset(56, 8), UDim2.fromOffset(250, 28))
label(header, "MOBILE  /  INTERFACE v0.1", 10, UDim2.fromOffset(57, 36), UDim2.fromOffset(270, 16), C.muted)
local minimize = button(header, "—", UDim2.new(1, -83, 0, 15), UDim2.fromOffset(30, 30))
local close = button(header, "×", UDim2.new(1, -44, 0, 15), UDim2.fromOffset(30, 30))
local sidebar = make("Frame", {
    Position = UDim2.fromOffset(0, 62), Size = UDim2.new(0, 130, 1, -98),
    BackgroundColor3 = C.panel, BorderSizePixel = 0
}, window)
label(sidebar, "CATEGORIAS", 10, UDim2.fromOffset(16, 14), UDim2.fromOffset(110, 20), C.muted)
local content = make("Frame", {
    Position = UDim2.fromOffset(144, 76), Size = UDim2.new(1, -158, 1, -126),
    BackgroundTransparency = 1
}, window)
local status = label(window, "PRÉVIA DE MENU • nenhuma alteração na partida", 11,
    UDim2.new(0, 16, 1, -31), UDim2.new(1, -32, 0, 23), C.muted)
local launcher = button(root, "S  SpaceCheats", UDim2.new(0, 12, 1, -50),
    UDim2.fromOffset(145, 38), C.blue)
launcher.Visible = false
local pages, tabs = {}, {}
local current = "Combate"
local function selectPage(name)
    current = name
    for key, page in pairs(pages) do
        page.Visible = key == name
        tabs[key].BackgroundColor3 = key == name and C.blue or C.panel
    end
end
for index, name in ipairs({"Combate", "ESP", "Misc"}) do
    local tab = button(sidebar, name, UDim2.fromOffset(10, 44 + (index - 1) * 49),
        UDim2.fromOffset(110, 40))
    local page = make("ScrollingFrame", {
        Name = name, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.blue,
        CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    make("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 12)}, page)
    local title = label(page, name, 19, UDim2.new(), UDim2.new(1, 0, 0, 28))
    title.LayoutOrder = 0
    pages[name], tabs[name] = page, tab
    connect(tab.Activated, function() selectPage(name) end)
end
local order = 0
local function row(page, title, description)
    order = order + 1
    local box = make("Frame", {
        Size = UDim2.new(1, 0, 0, 66), BackgroundColor3 = C.card,
        BorderSizePixel = 0, LayoutOrder = order
    }, pages[page])
    corner(box, 9)
    label(box, title, 13, UDim2.fromOffset(12, 7), UDim2.new(1, -116, 0, 24))
    label(box, description, 10, UDim2.fromOffset(12, 32), UDim2.new(1, -116, 0, 28), C.muted)
    return box
end
local function changed(key, title)
    fov.Visible = settings.ShowFOV
    fov.Size = UDim2.fromOffset(settings.FOVRadius * 2, settings.FOVRadius * 2)
    status.Text = title .. " • preferência da prévia"
end
local function toggle(page, key, title, description)
    local box = row(page, title, description)
    local switch = button(box, "", UDim2.new(1, -84, 0, 17), UDim2.fromOffset(72, 32))
    local function refresh()
        switch.Text = settings[key] and "ON" or "OFF"
        switch.BackgroundColor3 = settings[key] and C.blue or C.line
    end
    table.insert(refreshers, refresh)
    connect(switch.Activated, function()
        settings[key] = not settings[key]
        refresh()
        changed(key, title)
    end)
    refresh()
end
local function stepper(page, key, title, description, min, max, step, suffix)
    local box = row(page, title, description)
    box.Size = UDim2.new(1, 0, 0, 104)
    local minus = button(box, "−", UDim2.fromOffset(12, 65), UDim2.fromOffset(42, 30))
    local plus = button(box, "+", UDim2.new(1, -54, 0, 65), UDim2.fromOffset(42, 30))
    local value = label(box, "", 13, UDim2.fromOffset(64, 65), UDim2.new(1, -128, 0, 30), C.blue)
    value.TextXAlignment = Enum.TextXAlignment.Center
    local function refresh() value.Text = tostring(settings[key]) .. suffix end
    local function adjust(delta)
        settings[key] = math.clamp(settings[key] + delta, min, max)
        refresh()
        changed(key, title)
    end
    connect(minus.Activated, function() adjust(-step) end)
    connect(plus.Activated, function() adjust(step) end)
    table.insert(refreshers, refresh)
    refresh()
end
toggle("Combate", "Aimbot", "Aimbot • cabeça", "Preferência; sem mover a câmera.")
toggle("Combate", "VisibleCheck", "Checar visibilidade", "Filtro planejado para obstáculos.")
toggle("Combate", "TeamCheck", "Checar equipe", "Filtro planejado para aliados.")
stepper("Combate", "Smoothness", "Suavidade", "Ajuste de preferência.", 0, 100, 5, "%")
toggle("Combate", "FastFire", "Fast Fire", "Cadência; sem alterar armas.")
toggle("Combate", "InstantReload", "Instant Reload", "Recarga; sem alterar armas.")
toggle("ESP", "BoxESP", "ESP caixa", "Preferência; sem marcar jogadores.")
toggle("ESP", "ShowFOV", "ESP FOV • círculo", "Mostra o círculo de prévia na tela.")
stepper("ESP", "FOVRadius", "Raio do FOV", "Raio em pixels da prévia.", 30, 240, 10, " px")
toggle("Misc", "InfiniteJump", "Infinite Jump", "Preferência; sem alterar saltos.")
local reset = button(pages.Misc, "Restaurar configurações", UDim2.new(), UDim2.new(1, 0, 0, 40))
reset.LayoutOrder = 100
connect(reset.Activated, function()
    for k, v in pairs(defaults) do settings[k] = v end
    for _, refresh in ipairs(refreshers) do refresh() end
    changed("reset", "Configurações restauradas")
end)
selectPage(current)
local function dimensions()
    local size = root.AbsoluteSize
    if size.X < 1 or size.Y < 1 then
        size = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(720, 450)
    end
    return size
end
local function fit()
    local size = dimensions()
    scale.Scale = math.min(1, (size.X - 24) / 550, (size.Y - 24) / 400)
    window.Position = UDim2.fromOffset(
        (size.X - 550 * scale.Scale) / 2, (size.Y - 400 * scale.Scale) / 2)
end
connect(root:GetPropertyChangedSignal("AbsoluteSize"), fit)
fit()
local dragInput, dragStart, dragPosition
connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragInput, dragStart, dragPosition = input, input.Position, window.Position
    end
end)
connect(Input.InputChanged, function(input)
    if not dragInput then return end
    if input ~= dragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local delta, size = input.Position - dragStart, dimensions()
    window.Position = UDim2.fromOffset(
        math.clamp(dragPosition.X.Offset + delta.X, 0, math.max(0, size.X - 550 * scale.Scale)),
        math.clamp(dragPosition.Y.Offset + delta.Y, 0, math.max(0, size.Y - 400 * scale.Scale)))
end)
connect(Input.InputEnded, function(input)
    if input == dragInput then dragInput = nil end
end)
connect(minimize.Activated, function()
    window.Visible, launcher.Visible = false, true
end)
connect(launcher.Activated, function()
    window.Visible, launcher.Visible = true, false
end)
local session = {Settings = settings, Version = "0.1.0", Mode = "UI_PREVIEW"}
function session.Destroy()
    if not alive then return end
    alive = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    gui:Destroy()
    if env.SpaceCheatsPreview == session then env.SpaceCheatsPreview = nil end
end
connect(close.Activated, session.Destroy)
env.SpaceCheatsPreview = session
return session

