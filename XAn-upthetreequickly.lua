local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local targetPos = Vector3.new(3031.69, 2280.83, -7322.75)
local currentTween = nil 

-- --- GIAO DIỆN (GUI) ---
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "XanTeleportGui"

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 45, 0, 45)
-- Vị trí mới ở góc trên bên phải màn hình
btn.Position = UDim2.new(0.72, 0, 0.05, 0) 
btn.Text = "XAn"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
btn.ZIndex = 10

Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", btn)
stroke.Thickness = 3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- --- HIỆU ỨNG CẦU VỒNG ---
task.spawn(function()
    while btn.Parent do
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 0.8, 1)
        btn.BackgroundColor3 = color
        stroke.Color = color
        task.wait()
    end
end)

-- --- HỆ THỐNG NOCLIP ---
local noclipConn
local function setNoclip(state)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        local char = player.Character
        if not char then return end
        local parts = {}
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(parts, v) end
        end
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in pairs(parts) do part.CanCollide = false end
        end)
    else
        local char = player.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

-- --- HÀM DỊCH CHUYỂN ---
local function TweenToPosition()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if currentTween then 
        currentTween:Cancel() 
    end

    local distance = (hrp.Position - targetPos).Magnitude
    local speed = 120
    local duration = distance / speed

    setNoclip(true)

    currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos)
    })

    currentTween:Play()

    currentTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            setNoclip(false)
            currentTween = nil
        end
    end)
end

-- --- LOGIC KÉO THẢ & CLICK ---
local dragging, dragStart, startPos

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = (input.Position - dragStart).Magnitude
            dragging = false
            
            if delta < 20 then 
                TweenToPosition()
            end
        end
    end
end)
