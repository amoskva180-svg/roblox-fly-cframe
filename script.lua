-- =============================================================================
-- НАДЁЖНЫЙ CFRAME ПОЛЕТ ДЛЯ BUILD A BOAT И XENO (БЕЗ Т-ПОЗЫ)
-- =============================================================================
local UI = Instance.new("ScreenGui")
UI.Name = "XenoCFrameFlyUI"
UI.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 160)
Main.Position = UDim2.new(0.5, -150, 0.4, -80)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = UI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "  Dev Sandbox Hub 🛠️ (CFrame Fly)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Main

-- Кнопка Включения
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 45)
Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
Toggle.Text = "Полет: ВЫКЛ"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.Parent = Main

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(0, 6)
TCorner.Parent = Toggle

-- Поле ввода скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, -20, 0, 40)
SpeedInput.Position = UDim2.new(0, 10, 0, 95)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SpeedInput.Text = "2" -- Для CFrame скорость измеряется шагом за кадр (2 - оптимально, 5 - быстро)
SpeedInput.PlaceholderText = "Множитель скорости (например 2)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 14
SpeedInput.Parent = Main

local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(0, 6)
SCorner.Parent = SpeedInput

-- =============================================================================
-- ЛОГИКА ПОЛЕТА БЕЗ ИСПОЛЬЗОВАНИЯ ФИЗИКИ (ОБХОД БЛОКИРОВОК)
-- =============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local flying = false
local flySpeed = 2
local flyConnection

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function startFlying()
    if flying then return end
    flying = true
    Toggle.Text = "Полет: ВКЛ"
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)

    flyConnection = RunService.RenderStepped:Connect(function()
        local rootPart = getRoot()
        if not rootPart or not flying then return end

        local camera = workspace.CurrentCamera
        local cframe = rootPart.CFrame
        local direction = Vector3.new(0, 0, 0)

        -- Чтение нажатий клавиш движения
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end

        -- Мгновенно отключаем гравитационное падение во время покоя
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

        -- Перемещаем координатную сетку персонажа напрямую сквозь карту (Встроенный Noclip)
        if direction.Magnitude > 0 then
            rootPart.CFrame = CFrame.new(rootPart.Position + (direction.Unit * flySpeed)) * camera.CFrame.Rotation
        else
            rootPart.CFrame = CFrame.new(rootPart.Position) * camera.CFrame.Rotation
        end
    end)
end

function stopFlying()
    flying = false
    Toggle.Text = "Полет: ВЫКЛ"
    Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
end

-- Настройка интерфейса
Toggle.MouseButton1Click:Connect(function()
    if flying then stopFlying() else startFlying() end
end)

SpeedInput.FocusLost:Connect(function()
    local num = tonumber(SpeedInput.Text)
    if num then flySpeed = num else SpeedInput.Text = tostring(flySpeed) end
end)

player.CharacterAdded:Connect(function()
    stopFlying()
end)
