local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()



--// --- [ SERVICES & CONSTANTS ] ---

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")



--// --- [ SETTINGS VARIABLES ] ---

local Config = {

    Aimbot = false,

    FOVRadius = 150,

    FOVVisible = true,

    FOVColor = Color3.fromRGB(0, 255, 255),

    

    ESP = false,

    Tracers = false,

    Health = false,

    ESPColor = Color3.fromRGB(255, 0, 0),

    TracerColor = Color3.fromRGB(255, 255, 0)

}



--// --- [ DRAWING OBJECTS ] ---

local FOVCircle = Drawing.new("Circle")

FOVCircle.Thickness = 2

FOVCircle.NumSides = 60

FOVCircle.Filled = false

FOVCircle.Transparency = 1



--// --- [ UI SETUP ] ---

local win = DiscordLib:Window("GEMINI HUB | ULTIMATE")



-- [ SERVER 1: COMBAT ]

local combatServ = win:Server("Combat", "")

local aimChannel = combatServ:Channel("Aimbot & FOV")



aimChannel:Toggle("Enable Aimbot Lock", false, function(bool)

    Config.Aimbot = bool

end)



aimChannel:Toggle("Show FOV Circle", true, function(bool)

    Config.FOVVisible = bool

end)



aimChannel:Slider("FOV Size", 50, 500, 150, function(v)

    Config.FOVRadius = v

end)



aimChannel:Colorpicker("FOV Color", Color3.fromRGB(0, 255, 255), function(color)

    Config.FOVColor = color

end)



-- [ SERVER 2: VISUALS ]

local visualServ = win:Server("Visuals", "")

local espMain = visualServ:Channel("ESP Settings")



espMain:Toggle("Enable ESP Box", false, function(bool)

    Config.ESP = bool

end)



espMain:Toggle("Enable Tracers", false, function(bool)

    Config.Tracers = bool

end)



espMain:Toggle("Enable Health Bar", false, function(bool)

    Config.Health = bool

end)



local espColors = visualServ:Channel("Colors & Customization")



espColors:Colorpicker("Box/Health Color", Color3.fromRGB(255, 0, 0), function(color)

    Config.ESPColor = color

end)



espColors:Colorpicker("Tracer Color", Color3.fromRGB(255, 255, 0), function(color)

    Config.TracerColor = color

end)



--// --- [ CORE LOGIC ] ---



-- หาเป้าหมายที่อยู่ใกล้เมาส์ที่สุด และต้องอยู่ในวงกลม

local function getClosestTarget()

    local target = nil

    local dist = Config.FOVRadius



    for _, player in pairs(Players:GetPlayers()) do

        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then

            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            if onScreen then

                local mouseLocation = UserInputService:GetMouseLocation()

                local magnitude = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude

                if magnitude < dist then

                    target = player

                    dist = magnitude

                end

            end

        end

    end

    return target

end



-- ระบบ ESP สำหรับผู้เล่นแต่ละคน

local function createESP(player)

    local box = Drawing.new("Square")

    local tracer = Drawing.new("Line")

    local healthBar = Drawing.new("Line")

    

    local function cleanup()

        box:Remove()

        tracer:Remove()

        healthBar:Remove()

    end



    local connection

    connection = RunService.RenderStepped:Connect(function()

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player ~= LocalPlayer then

            local root = player.Character.HumanoidRootPart

            local hum = player.Character.Humanoid

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)



            if onScreen and hum.Health > 0 then

                local sizeX = 2000 / pos.Z

                local sizeY = 3000 / pos.Z



                -- Logic: Box

                if Config.ESP then

                    box.Size = Vector2.new(sizeX, sizeY)

                    box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)

                    box.Color = Config.ESPColor

                    box.Visible = true

                else box.Visible = false end



                -- Logic: Tracer

                if Config.Tracers then

                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

                    tracer.To = Vector2.new(pos.X, pos.Y)

                    tracer.Color = Config.TracerColor

                    tracer.Visible = true

                else tracer.Visible = false end



                -- Logic: Health Bar

                if Config.Health then

                    local barSize = sizeY * (hum.Health / hum.MaxHealth)

                    healthBar.From = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y + sizeY / 2)

                    healthBar.To = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y + sizeY / 2 - barSize)

                    healthBar.Color = Color3.fromRGB(255 - (255 * (hum.Health/hum.MaxHealth)), 255 * (hum.Health/hum.MaxHealth), 0)

                    healthBar.Thickness = 2

                    healthBar.Visible = true

                else healthBar.Visible = false end

            else

                box.Visible = false

                tracer.Visible = false

                healthBar.Visible = false

            end

        else

            box.Visible = false

            tracer.Visible = false

            healthBar.Visible = false

            if not player.Parent then

                cleanup()

                connection:Disconnect()

            end

        end

    end)

end



--// --- [ MAIN RENDER LOOP ] ---

RunService.RenderStepped:Connect(function()

    -- FOV Update

    local mouseLoc = UserInputService:GetMouseLocation()

    FOVCircle.Position = mouseLoc

    FOVCircle.Radius = Config.FOVRadius

    FOVCircle.Color = Config.FOVColor

    FOVCircle.Visible = Config.FOVVisible



    -- Aimbot Lock

    if Config.Aimbot then

        local target = getClosestTarget()

        if target and target.Character and target.Character:FindFirstChild("Head") then

            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)

        end

    end

end)



-- Initialize ESP for all

for _, p in pairs(Players:GetPlayers()) do createESP(p) end

Players.PlayerAdded:Connect(createESP)



DiscordLib:Notification("Ghost Hub", "Script Loaded Successfully!", "Okay")
