-- 616 RIVALS | main.lua
-- Runtime: Roblox Studio / Luau
-- Standalone combat simulation and interface

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = {
    Background = Color3.fromRGB(10, 10, 13),
    Panel = Color3.fromRGB(18, 18, 23),
    Secondary = Color3.fromRGB(27, 27, 34),
    Accent = Color3.fromRGB(220, 35, 55),
    Text = Color3.fromRGB(240, 240, 245),
    Muted = Color3.fromRGB(130, 130, 145),
    Green = Color3.fromRGB(50, 210, 130)
}

local Settings = {
    RageEnabled = false,
    VoidEnabled = false,
    VisualsEnabled = true,
    TargetMode = "Behind",
    TargetOffset = 5,
    VoidEvents = 0
}

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local Screen = Create("ScreenGui", {
    Name = "616CombatLab",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local Main = Create("Frame", {
    Size = UDim2.fromOffset(720, 480),
    Position = UDim2.new(0.5, -360, 0.5, -240),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0
}, Screen)

Create("UICorner", {
    CornerRadius = UDim.new(0, 12)
}, Main)

Create("UIStroke", {
    Color = Theme.Accent,
    Thickness = 1,
    Transparency = 0.35
}, Main)

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 65),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 12)
}, Header)

Create("TextLabel", {
    Size = UDim2.new(0, 180, 1, 0),
    Position = UDim2.fromOffset(22, 0),
    BackgroundTransparency = 1,
    Text = "616",
    TextColor3 = Theme.Accent,
    TextSize = 32,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

Create("TextLabel", {
    Size = UDim2.fromOffset(200, 30),
    Position = UDim2.fromOffset(95, 18),
    BackgroundTransparency = 1,
    Text = "COMBAT LAB",
    TextColor3 = Theme.Text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 175, 1, -65),
    Position = UDim2.fromOffset(0, 65),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, Main)

local Content = Create("Frame", {
    Size = UDim2.new(1, -190, 1, -85),
    Position = UDim2.fromOffset(185, 75),
    BackgroundTransparency = 1
}, Main)

local function ClearContent()
    for _, child in ipairs(Content:GetChildren()) do
        child:Destroy()
    end
end

local function Label(text, parent, position, size)
    return Create("TextLabel", {
        Size = size or UDim2.new(1, -20, 0, 30),
        Position = position or UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
end

local function Button(text, parent, position, callback)
    local button = Create("TextButton", {
        Size = UDim2.new(1, -20, 0, 38),
        Position = position,
        BackgroundColor3 = Theme.Secondary,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, parent)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, button)

    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.15),
            {BackgroundColor3 = Theme.Accent}
        ):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.15),
            {BackgroundColor3 = Theme.Secondary}
        ):Play()
    end)

    button.MouseButton1Click:Connect(callback)

    return button
end

local function Toggle(text, parent, position, initial, callback)
    local enabled = initial

    local button = Button(
        text .. ": " .. (enabled and "ON" or "OFF"),
        parent,
        position,
        function()
            enabled = not enabled

            button.Text = text .. ": " ..
                (enabled and "ON" or "OFF")

            callback(enabled)
        end
    )

    return button
end

local function Dashboard()
    ClearContent()

    Label(
        "CONTROL CENTER",
        Content,
        UDim2.fromOffset(10, 10),
        UDim2.new(1, -20, 0, 35)
    ).TextSize = 24

    Label(
        "616 COMBAT LAB",
        Content,
        UDim2.fromOffset(10, 55)
    )

    Label(
        "Standalone combat simulation environment.",
        Content,
        UDim2.fromOffset(10, 90)
    )

    Label(
        "STATUS: ONLINE",
        Content,
        UDim2.fromOffset(10, 145)
    ).TextColor3 = Theme.Green

    Label(
        "TARGET MODE: " .. Settings.TargetMode,
        Content,
        UDim2.fromOffset(10, 180)
    )

    Label(
        "SIMULATED VOID EVENTS: " .. Settings.VoidEvents,
        Content,
        UDim2.fromOffset(10, 215)
    )
end

local function RagePanel()
    ClearContent()

    Label(
        "RAGEBOT SIMULATOR",
        Content,
        UDim2.fromOffset(10, 10)
    ).TextSize = 23

    Toggle(
        "Simulation",
        Content,
        UDim2.fromOffset(10, 65),
        Settings.RageEnabled,
        function(value)
            Settings.RageEnabled = value
        end
    )

    local modes = {"Behind", "Above", "Below"}

    for index, mode in ipairs(modes) do
        Button(
            "TARGET POSITION: " .. mode,
            Content,
            UDim2.fromOffset(10, 115 + (index * 48)),
            function()
                Settings.TargetMode = mode
            end
        )
    end

    Label(
        "Position modes operate on simulated targets.",
        Content,
        UDim2.fromOffset(10, 300)
    )
end

local function VoidPanel()
    ClearContent()

    Label(
        "VOID SIMULATOR",
        Content,
        UDim2.fromOffset(10, 10)
    ).TextSize = 23

    Toggle(
        "Void Simulation",
        Content,
        UDim2.fromOffset(10, 65),
        Settings.VoidEnabled,
        function(value)
            Settings.VoidEnabled = value
        end
    )

    local counter = Label(
        "EVENTS: " .. Settings.VoidEvents,
        Content,
        UDim2.fromOffset(10, 125)
    )

    Button(
        "TRIGGER SIMULATED EVENT",
        Content,
        UDim2.fromOffset(10, 175),
        function()
            if Settings.VoidEnabled then
                Settings.VoidEvents += 1

                counter.Text =
                    "EVENTS: " .. Settings.VoidEvents
            end
        end
    )

    Button(
        "RESET COUNTER",
        Content,
        UDim2.fromOffset(10, 225),
        function()
            Settings.VoidEvents = 0
            counter.Text = "EVENTS: 0"
        end
    )
end

local function VisualPanel()
    ClearContent()

    Label(
        "VISUAL SETTINGS",
        Content,
        UDim2.fromOffset(10, 10)
    ).TextSize = 23

    Toggle(
        "Visual Interface",
        Content,
        UDim2.fromOffset(10, 65),
        Settings.VisualsEnabled,
        function(value)
            Settings.VisualsEnabled = value
        end
    )

    Label(
        "Interface visualization settings.",
        Content,
        UDim2.fromOffset(10, 120)
    )
end

local function ConfigPanel()
    ClearContent()

    Label(
        "CONFIGURATION",
        Content,
        UDim2.fromOffset(10, 10)
    ).TextSize = 23

    Button(
        "RESET SETTINGS",
        Content,
        UDim2.fromOffset(10, 65),
        function()
            Settings.RageEnabled = false
            Settings.VoidEnabled = false
            Settings.VisualsEnabled = true
            Settings.TargetMode = "Behind"
            Settings.TargetOffset = 5
            Settings.VoidEvents = 0
        end
    )

    Label(
        "616 DEFAULT PROFILE",
        Content,
        UDim2.fromOffset(10, 125)
    )
end

local Tabs = {
    {"Dashboard", Dashboard},
    {"Ragebot Lab", RagePanel},
    {"Void Simulator", VoidPanel},
    {"Visuals", VisualPanel},
    {"Configurations", ConfigPanel}
}

for index, tab in ipairs(Tabs) do
    Button(
        tab[1],
        Sidebar,
        UDim2.fromOffset(10, 25 + (index * 52)),
        tab[2]
    )
end

-- Drag window using its header.

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Dashboard()

print("[616] Combat Lab initialized.")
