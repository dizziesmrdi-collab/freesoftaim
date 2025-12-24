-- HARD SOFT AIM - PC
-- LocalScript | vlastní FPS test

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===== NASTAVENÍ =====
local ENABLED = true
local AIM_KEY = Enum.UserInputType.MouseButton2 -- pravé tlačítko
local FOV_RADIUS = 170
local SMOOTHNESS = 0.2   -- ↑ tvrdší
local TARGET_PART = "Head" -- nebo HumanoidRootPart
-- ====================

local aiming = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == AIM_KEY then
		aiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == AIM_KEY then
		aiming = false
	end
end)

-- střed obrazovky (lepší než Mouse.Hit)
local function screenCenter()
	local v = Camera.ViewportSize
	return Vector2.new(v.X / 2, v.Y / 2)
end

-- nejbližší cíl ve FOV
local function getClosestTarget()
	local closest, shortest = nil, FOV_RADIUS
	local center = screenCenter()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local part = plr.Character:FindFirstChild(TARGET_PART)
			local hum = plr.Character:FindFirstChild("Humanoid")

			if part and hum and hum.Health > 0 then
				local pos, visible = Camera:WorldToViewportPoint(part.Position)
				if visible then
					local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if dist < shortest then
						shortest = dist
						closest = part
					end
				end
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	if not ENABLED or not aiming then return end

	local target = getClosestTarget()
	if target then
		local camPos = Camera.CFrame.Position
		local cf = CFrame.new(camPos, target.Position)
		Camera.CFrame = Camera.CFrame:Lerp(cf, SMOOTHNESS)
	end
end)
