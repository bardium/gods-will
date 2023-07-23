--[[
CREDITS:
UI Library: Inori & wally
Script: goosebetter
]]

repeat
	task.wait()
until game:IsLoaded()

local start = tick()
local client = game:GetService('Players').LocalPlayer;

local UI = loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/LinoriaLib/main/Library.lua'))()
local themeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/LinoriaLib/main/addons/ThemeManager.lua'))()

local metadata = loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/gods-will/main/metadata.lua'))()
local httpService = game:GetService('HttpService')
local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request

local runService = game:GetService('RunService')
local repStorage = game:GetService('ReplicatedStorage')
local tpService = game:GetService('TeleportService')

do
	if shared._unload then
		pcall(shared._unload)
	end

	function shared._unload()
		if shared._id then
			pcall(runService.UnbindFromRenderStep, runService, shared._id)
		end

		UI:Unload()

		for i = 1, #shared.threads do
			coroutine.close(shared.threads[i])
		end

		for i = 1, #shared.callbacks do
			task.spawn(shared.callbacks[i])
		end
	end

	shared.threads = {}
	shared.callbacks = {}

	shared._id = httpService:GenerateGUID(false)
end

do
	local thread = task.spawn(function()
		local function getGlobalWalkSpeed()
			local allWalkSpeeds = {}

			for _, v in ipairs(game.Players:GetPlayers()) do
				if v ~= client and v.Character and v.Character:FindFirstChildOfClass('Humanoid') then
					local humanoid = v.Character:FindFirstChildOfClass('Humanoid')
					if tonumber(humanoid.WalkSpeed) > 0 then
						table.insert(allWalkSpeeds, tonumber(humanoid.WalkSpeed))
					end
				end
			end

			local walkSpeedCounts = {}
			for _, walkSpeed in ipairs(allWalkSpeeds) do
				if walkSpeedCounts[walkSpeed] then
					walkSpeedCounts[walkSpeed] = walkSpeedCounts[walkSpeed] + 1
				else
					walkSpeedCounts[walkSpeed] = 1
				end
			end
			
			local mostCommonWalkSpeed = 4
			local highestCount = 0
			for walkSpeed, count in pairs(walkSpeedCounts) do
				if count > highestCount then
					mostCommonWalkSpeed = walkSpeed
					highestCount = count
				end
			end
			return tonumber(mostCommonWalkSpeed)
		end
		while true do
			task.wait()
			if ((Toggles.DarumaGameFreeze) and (Toggles.DarumaGameFreeze.Value)) then
				if workspace:FindFirstChild('DarumaGameStart') then
					if (((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace.DarumaGameStart.Value == true then
						if workspace:FindFirstChild('NotLooking') and client.Character and client.Character:FindFirstChildOfClass('Humanoid') then
							local humanoid = client.Character:FindFirstChildOfClass('Humanoid')
							if workspace.NotLooking.Value == false then
								task.wait(Options.FreezeDelay.Value)
								humanoid.WalkSpeed = 0
								UI:Notify('Stop moving or you will die. Do not hold any keys.', 3)
								repeat task.wait() until workspace.NotLooking.Value == true or ((not Toggles.DarumaGameFreeze) or (not Toggles.DarumaGameFreeze.Value))
							else
								if client.Character and client.Character:FindFirstChildOfClass('Humanoid') then
									UI:Notify('You can move again.', 3)
									client.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = getGlobalWalkSpeed()
									repeat task.wait() until workspace.NotLooking.Value == false or ((not Toggles.DarumaGameFreeze) or (not Toggles.DarumaGameFreeze.Value))
									if client.Character and client.Character:FindFirstChildOfClass('Humanoid') then
										client.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = getGlobalWalkSpeed()
									end
								end
							end
						end
					else
						UI:Notify('Daruma game is over or hasnt started.', 3)
						Toggles.DarumaGameFreeze:SetValue(false)
						if client.Character and client.Character:FindFirstChildOfClass('Humanoid') then
							client.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = getGlobalWalkSpeed()
						end
					end
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		local correctDoorHighlight = nil
		if game.CoreGui:FindFirstChild('correctDoorHighlight') then
			correctDoorHighlight = game.CoreGui.correctDoorHighlight
		else
			correctDoorHighlight = Instance.new('Highlight', game.CoreGui)
		end
		correctDoorHighlight.Name = 'correctDoorHighlight'
		while true do
			task.wait()
			if ((Toggles.HighlightCorrectDoor) and (Toggles.HighlightCorrectDoor.Value)) then
				if workspace:FindFirstChild('CorrectDoor') and workspace:FindFirstChild('MainRooms') and workspace.MainRooms:FindFirstChild('DiamondPlateRooms', true) then
					if (((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace.DoorsGameOn.Value == true then
						local diamondPlateRooms = workspace.MainRooms:FindFirstChild('DiamondPlateRooms', true)

						for _, v in ipairs(diamondPlateRooms:GetChildren()) do
							if v:FindFirstChild('ActualDoor') and v.ActualDoor:FindFirstChild('Door') and v.ActualDoor.Door:FindFirstChildOfClass('Decal') then
								if v.ActualDoor.Door:FindFirstChildOfClass('Decal').Texture == workspace.CorrectDoor.Value then
									correctDoorHighlight.FillColor = Color3.new(0, 1, 0)
									correctDoorHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
									correctDoorHighlight.Adornee = v.ActualDoor
								end
							end
						end
					else
						UI:Notify('Doors game is over or hasnt started.', 3)
						Toggles.HighlightCorrectDoor:SetValue(false)
					end
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.TPToCorrectDoor) and (Toggles.TPToCorrectDoor.Value)) then
				if workspace:FindFirstChild('CorrectDoor') and workspace:FindFirstChild('MainRooms') and workspace.MainRooms:FindFirstChild('DiamondPlateRooms', true) then
					if (((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace.DoorsGameOn.Value == true then
						local diamondPlateRooms = workspace.MainRooms:FindFirstChild('DiamondPlateRooms', true)

						for _, v in ipairs(diamondPlateRooms:GetChildren()) do
							if v:FindFirstChild('ActualDoor') and v:FindFirstChild('Slider') and v.ActualDoor:FindFirstChild('Door') and v.ActualDoor.Door:FindFirstChildOfClass('Decal') then
								if v.ActualDoor.Door:FindFirstChildOfClass('Decal').Texture == workspace.CorrectDoor.Value then
									client.Character:PivotTo(v.Slider:GetPivot() * CFrame.new(0, 5, 0))
								end
							end
						end
					else
						UI:Notify('Doors game is over or hasnt started.', 3)
						Toggles.TPToCorrectDoor:SetValue(false)
					end
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.HighlightCorrectChairs) and (Toggles.HighlightCorrectChairs.Value)) then
				if workspace:FindFirstChild('MusicalChairsMap') and workspace.MusicalChairsMap:FindFirstChild('Chairs') then
					for _, v in ipairs(workspace.MusicalChairsMap.Chairs:GetChildren()) do
						if v:FindFirstChild('school-room-chair') and v:FindFirstChild('school-room-chair'):FindFirstChild('Meshes/Grime desk_Chair wood.001') then
							local mainPart = v:FindFirstChild('school-room-chair'):FindFirstChild('Meshes/Grime desk_Chair wood.001')
							mainPart.BrickColor = BrickColor.new('Lime green')
							mainPart.Material = Enum.Material.Neon
							mainPart.Transparency = 0.5
							mainPart.TextureID = ''
							mainPart.Size = Vector3.new(3, 3, 3)
							mainPart.CanCollide = false
						end
					end
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.VoteMostPopular) and (Toggles.VoteMostPopular.Value)) then
				if (((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace:FindFirstChild('VOTINGON') and workspace.VOTINGON.Value == true then
					local highestVotes = 0
					local mostPopular = nil
					for _, v in ipairs(game.Players:GetPlayers()) do
						if v ~= client then
							if mostPopular == nil then
								mostPopular = v
							end
							if tonumber(v:GetAttribute('Votes')) and tonumber(v:GetAttribute('Votes')) > highestVotes then
								mostPopular = v
								highestVotes = tonumber(v:GetAttribute('Votes'))
							end
						end
					end
					if mostPopular ~= nil then
						warn('Voted for', mostPopular.Name)
						game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("VotePersonOut"):FireServer(mostPopular.Name)
					end
				else

				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.RequestChairAura) and (Toggles.RequestChairAura.Value)) then
				game:GetService("ReplicatedStorage").RequestChair:FireServer()
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

local function addRichText(label)
	label.TextLabel.RichText = true
end

local Window = UI:CreateWindow({
	Title = string.format('gods will - version %s | updated: %s', metadata.version, metadata.updated),
	AutoShow = true,

	Center = true,
	Size = UDim2.fromOffset(550, 527),
})

local Tabs = {}
local Groups = {}

Tabs.Main = Window:AddTab('Main')
Tabs.UISettings = Window:AddTab('UI Settings')

Groups.Games = Tabs.Main:AddLeftGroupbox('Games')
Groups.Games:AddToggle('DarumaGameFreeze', { Text = 'Freeze During Daruma Game' })
Groups.Games:AddSlider('FreezeDelay',   { Text = 'Freeze Delay', Min = 0, Max = 0.65, Default = 0.25, Suffix = 's', Rounding = 3, Compact = true })

local DependencySlider = Groups.Games:AddDependencyBox();
addRichText(DependencySlider:AddLabel('<font color="#ff430a">Freeze Delay greater than 0.45s\ncan get you killed.</font>'))

DependencySlider:SetupDependencies({
	{ Options.FreezeDelay, 0.45 }
});

Groups.Games:AddToggle('HighlightCorrectDoor', { Text = 'Highlight Correct Door' })
Groups.Games:AddToggle('HighlightCorrectChairs', { Text = 'Highlight Correct Chairs' })
Groups.Games:AddToggle('VoteMostPopular', { Text = 'Vote Most Popular' })
Groups.Games:AddButton('Finish Sled Game', function()
	pcall(function()
		if workspace:FindFirstChild('Finish') and workspace:FindFirstChild('SledGame') and ((((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace.SledGame.Value == true) then
			for _, v in ipairs(client.Character.PrimaryPart:GetChildren()) do
				if v:IsA('BodyVelocity') or v:IsA('BodyGyro') then
					v:Destroy()
				end
			end
			task.wait()
			for _, v in ipairs(workspace:GetChildren()) do
				if v.Name == 'Finish' and v:IsA('BasePart') then
					client.Character:PivotTo(v:GetPivot())
				end
			end
		else
			UI:Notify('Sled game is over or hasnt started.', 3)
		end
	end)
end)

Groups.Misc = Tabs.Main:AddRightGroupbox('Misc')
Groups.Misc:AddToggle('DisableGameChecks', { Text = 'Disable In Game Checks' })
local collectingCoins = false
Groups.Misc:AddButton('Collect All Coins', function()
	if not collectingCoins then
		collectingCoins = true
		pcall(function()
			local oldPivot = client.Character:GetPivot()
			local coins = workspace:FindFirstChild('Coins')

			if coins then
				for _, v in ipairs(coins:GetChildren()) do
					if v:IsA('BasePart') then
						client.Character:PivotTo(v:GetPivot())
						task.wait()
					end
				end
			end
			client.Character:PivotTo(oldPivot)
		end)
		collectingCoins = false
	else
		UI:Notify('Collecting coins, please wait.', 1)
	end
end)
Groups.Misc:AddButton('Fix Speed', function()
	pcall(function()
		local allWalkSpeeds = {}

		for _, v in ipairs(game.Players:GetPlayers()) do
			if v ~= client and v.Character and v.Character:FindFirstChildOfClass('Humanoid') then
				local humanoid = v.Character:FindFirstChildOfClass('Humanoid')
				if tonumber(humanoid.WalkSpeed) > 0 then
					table.insert(allWalkSpeeds, tonumber(humanoid.WalkSpeed))
				end
			end
		end

		local walkSpeedCounts = {}
		for _, walkSpeed in ipairs(allWalkSpeeds) do
			if walkSpeedCounts[walkSpeed] then
				walkSpeedCounts[walkSpeed] = walkSpeedCounts[walkSpeed] + 1
			else
				walkSpeedCounts[walkSpeed] = 1
			end
		end

		local mostCommonWalkSpeed = 4
		local highestCount = 0
		for walkSpeed, count in pairs(walkSpeedCounts) do
			if count > highestCount then
				mostCommonWalkSpeed = walkSpeed
				highestCount = count
			end
		end
		client.Character.Humanoid.WalkSpeed = tonumber(mostCommonWalkSpeed)
	end)
end)

Groups.Blatant = Tabs.Main:AddRightGroupbox('Blatant')
Groups.Blatant:AddToggle('TPToCorrectDoor', { Text = 'TP Correct Door Room' })
Groups.Blatant:AddToggle('RequestChairAura', { Text = 'Throw Chair Aura' })
Groups.Blatant:AddButton('Disappear From Monkey Boss Fight', function()
	pcall(function()
		if (((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace.MonkeyGameStart.Value == true then
			client.Character:PivotTo(client.Character:GetPivot() * CFrame.new(0, -100, 0))
		else
			UI:Notify('Monkey boss fight game is over or hasnt started.', 3)
		end
	end)
end)
Groups.Blatant:AddButton('TP To Rocket', function()
	pcall(function()
		if (((Toggles.DisableGameChecks) and (Toggles.DisableGameChecks.Value))) or workspace.MonkeyGameStart.Value == true then
			if workspace.Effects:FindFirstChild('Rocket') then
				client.Character:PivotTo(workspace.Effects.Rocket:GetPivot())
			else
				UI:Notify('Rocket not found.', 3)
			end
		else
			UI:Notify('Monkey boss fight game is over or hasnt started.', 3)
		end
	end)
end)
Groups.Blatant:AddButton('Disappear From Hide and Seek', function()
	pcall(function()
		client.Character:PivotTo(CFrame.new(client.Character:GetPivot().Position.X, 460, client.Character:GetPivot().Position.Z))
	end)
end)
Groups.Blatant:AddButton('Disappear From Dodgeball', function()
	pcall(function()
		client.Character:PivotTo(CFrame.new(client.Character:GetPivot().Position.X, 80, client.Character:GetPivot().Position.Z))
	end)
end)

Groups.Configs = Tabs.UISettings:AddRightGroupbox('Configs')
Groups.Credits = Tabs.UISettings:AddRightGroupbox('Credits')

addRichText(Groups.Credits:AddLabel('<font color="#0bff7e">Goose Better</font> - script'))
addRichText(Groups.Credits:AddLabel('<font color="#3da5ff">wally & Inori</font> - ui library'))

Groups.UISettings = Tabs.UISettings:AddRightGroupbox('UI Settings')
Groups.UISettings:AddLabel(metadata.message or 'no message found!', true)
Groups.UISettings:AddDivider()
Groups.UISettings:AddButton('Unload Script', function() pcall(shared._unload) end)
Groups.UISettings:AddButton('Copy Discord', function()
	if pcall(setclipboard, "https://discord.gg/hSm6DyF6X7") then
		UI:Notify('Successfully copied discord link to your clipboard!', 5)
	end
end)
if game.PlaceId ~= 14136710162 and game.PlaceId ~= 12826178482 then
	Groups.UISettings:AddButton('Return To Lobby', function()
		tpService:Teleport(12826178482, client)
	end)
end

Groups.UISettings:AddLabel('Menu toggle'):AddKeyPicker('MenuToggle', { Default = 'Delete', NoUI = true })

UI.ToggleKeybind = Options.MenuToggle

themeManager:SetLibrary(UI)
themeManager:ApplyToGroupbox(Tabs.UISettings:AddLeftGroupbox('Themes'))

UI:Notify(string.format('Loaded script in %.4f second(s)!', tick() - start), 3)
