shared.env = require(game:GetService("ReplicatedFirst"):WaitForChild("SharedEnvironment"))
local serverCreationTime = os.time()
shared.serverCreationTime = serverCreationTime
local dss = game:GetService("DataStoreService")
local textService = game:GetService("TextService")
local runService = game:GetService("RunService")
local insertService = game:GetService("InsertService")
local messagingService = game:GetService("MessagingService")
local bans = dss:GetDataStore("GameBans")
local leaderboard = dss:GetOrderedDataStore("TimeTrialLeaderboard","reset1")
local levelLeaderboard = dss:GetOrderedDataStore("LevelsLeaderboard")
local scores = dss:GetDataStore("TimeTrialScores")
local playerFlags = dss:GetDataStore("PlayerFlags")
local badgeservice = game:GetService("BadgeService")
local marketplace = game:GetService("MarketplaceService")
local gps = game:GetService("GamePassService")
local http = game:GetService("HttpService")
local physics = game:GetService("PhysicsService")

if not shared.env then repeat wait() until shared.env end wait = shared.env.wait
local discord = require(game.ServerScriptService.DiscordAPI)
local recentearned = {}
local recentmoves = {}
local recentinvokes = {}
local playerRankNums = {}
local playerSessionMults = {}
local cache = {}
local plrsResetting = {}
local respawnLocations = {}
local key = {}
local playerMsData = {}
shared.playerMsData = {}
shared.lastBagCollections = {}
shared.LostCombo = {}
shared.LastCombo = {}
shared.skinBags = {}
shared.dunces = {}
shared.pastPlayerPositions = {}
shared.teleportBagCollections = {}
shared.donotsave = {}
shared.playerSessionMults = playerSessionMults
local customCola = {
	[18205436] = {spam=true,tex="http://www.roblox.com/asset/?id=4666333195"},
	[22402288] = {spam=true,tex="http://www.roblox.com/asset/?id=12108219"},
	[16624761] = {spam=false,tex="http://www.roblox.com/asset/?id=12942764"},
	[8547230] = {spam=true,tex="http://www.roblox.com/asset/?id=4746735403"},
	[129460113] = {spam=false,tex="http://www.roblox.com/asset/?id=32800131"},
	[55505117] = {spam=false,tex="http://www.roblox.com/asset/?id=4653447459"},
	[40272877] = {spam=true,tex="http://www.roblox.com/asset/?id=4666256728"},
	[26157542] = {spam=false,tex="http://www.roblox.com/asset/?id=4653366549"}
}
function customizeCola(cola,id)
	if customCola[id] then
		cola.Mesh.TextureId = customCola[id].tex or cola.Mesh.TextureId
	end
end
local ranks = {
	--creator = {num=1000,name="Creator",inc=5,plrid=18205436},
	--builder = {num=997,name="Architect",inc=8,plrid=78653945},
	winner = {num=25,name="Apex",inc=1,level=1000},
	giveup = {num=24,name="i give up",inc=1,level=900},
	please = {num=23,name="Please",inc=1,level=800},
	stop = {num=22,name="Stop",inc=1,level=700},
	how = {num=21,name="HOW",inc=1,level=600},
	why = {num=20,name="Why",inc=1,level=500},
	immo = {num=19,name="Immortal",inc=1,level=400},
	archon = {num=18,name="Archon",inc=1,level=300},
	sentinel = {num=17,name="Sentinel",inc=1,level=250},
	vanguard = {num=16,name="Vanguard",inc=1,level=200},
	titan = {num=15,name="Titan",inc=1,level=150},
	deity = {num=14,name="Deity",inc=1,level=120},
	god = {num=13,name="God",inc=1,level=100},
	infa = {num=12,name="Infamous",inc=1,level=90},
	legend = {num=11,name="Legend",inc=1,level=80},
	lord = {num=10,name="Lord",inc=1,level=70},
	hero = {num=9,name="Hero",inc=1,level=60},
	ace = {num=9,name="Ace",inc=1,level=50},
	master = {num=8,name="Master",inc=1,level=40},
	prof = {num=7,name="Professional",inc=1,level=30},
	expert = {num=6,name="Expert",inc=1,level=25},
	adv = {num=5,name="Advanced",inc=1,level=20},
	adept = {num=4,name="Adept",inc=1,level=15},
	interm = {num=3,name="Intermediate",inc=1,level=10},
	novice = {num=2,name="Novice",inc=1,level=6},
	beginner = {num=1,name="Beginner",inc=1,level=0},
}
local builtInAudio = {
	{words={"exit","exit this earth's atomosphere","exit this earths atomosphere"},id=904414008},
	{words={"nuclear","nuclear star","nuclear-star"},id=1882656833},
	{words={"image material"},id=695028088},
	{words={"deltamax"},id=575189622},
	{words={"ttfaf","through the fire and flames"},id=1768601780},
	{words={"distorted space"},id=1751171913},
	{words={"united"},id=1823321902},
	{words={"big black","the big black"},id=1150843377},
	{words={"everything will freeze"},id=569045108},
	{words={"reality distortion"},id=1317963324},
	{words={"lost in time"},id=1029598117},
	{words={"tengaku"},id=1356425939},
	{words={"world's end","worlds end"},id=1314271226},
	{words={"world's end cover","worlds end cover"},id=1618768506},
	{words={"end of an empire"},id=709022162},
	{words={"galaxy collapse"},id=1190864485},
	{words={"beat saber"},id=1721442795},
	{words={"escape"},id=1721448336},
	{words={"country rounds"},id=1721446905},
	{words={"legend"},id=1749293661},
	{words={"time to say goodbye"},id=1914677175},
	{words={"i can fly in the universe"},id=1645825883},
	{words={"angel voices"},id=2112616277},
}
local altSpawnsData = {
	SpawnLocation = {name="def_spawn",pos1=Vector3.new(-36.5,301.5,-177),pos2=Vector3.new(36.5,247.5,-64)},
	AltSpawn1 = {name="Crest Site",pos1=Vector3.new(348.299,384.3,-1338.947),pos2=Vector3.new(416.299,330.3,-1245.947)},
	AltSpawn2 = {name="Uptown Site",pos1=Vector3.new(-1096.705, 291, -1728.459),pos2=Vector3.new(-1160.705, 240.782, -1823.459)},
	AltSpawn3 = {name="Hilton Site",pos1=Vector3.new(123.7,223.5,132.203),pos2=Vector3.new(236.7,169.5,205.203)},
	AltSpawn4 = {name="Downtown Site",pos1=Vector3.new(-652.501,252.6,-491.997),pos2=Vector3.new(-539.499,198.7,-419)},
	AltSpawn5 = {name="Vertex Site",pos1=Vector3.new(1228.304,415.304,980.052),pos2=Vector3.new(1336.302,361.304,1071.049)},
	AltSpawn6 = {name="Office Site",pos1=Vector3.new(-1179.499, 258.6, 788.049),pos2=Vector3.new(-1269.499, 210.5, 869.05)},
	AltSpawn7 = {name="Park Site",pos1=Vector3.new(2543.627, 217.604, -1506.52),pos2=Vector3.new(2614.627, 167.004, -1395.52)},
	AltSpawn8 = {name="Arch Site",pos1=Vector3.new(2009.585, 271.094, 241.133),pos2=Vector3.new(2115.585, 218.994, 152.132)},
	AltSpawn9 = {name="Townside Site",pos1=Vector3.new(2379.298, 143.804, 1662.046),pos2=Vector3.new(2485.297, 89.724, 1573.045)},
	AltSpawn10 = {name="Highrise Site",pos1=Vector3.new(57.883, 1091.583, 2016.602),pos2=Vector3.new(172.116, 1024.653, 1933.752)},
}

workspace:WaitForChild("IsVIPServer").Value = game.VIPServerId ~= ""

local dataStore = dss:GetDataStore("Parkour")
workspace:WaitForChild("BagSpawns").Parent = game.ServerStorage
game.ReplicatedStorage:WaitForChild("ServerKey").Value = math.random(2500,5000)
local origDisplayDistance = game.StarterPlayer.NameDisplayDistance
local serverKey = game.ReplicatedStorage:WaitForChild("ServerKey").Value
local cryptKey = {4*(serverKey/100),4*(serverKey/100),4*(serverKey/100),1*(serverKey/100),2*(serverKey/100)}
local cryptModule = require(game.ReplicatedStorage:WaitForChild("Encoding"))
local selfbandebounce = {}
local respawnDebounce = {}
function genKey()
	local l = math.random() > .5 and string.upper(string.char(math.random(97,122))) or string.lower(string.char(math.random(97,122)))
	local n = math.random(0,9)
	return math.random() > .5 and tostring(l) or tostring(n)
end
function cwrap(f) coroutine.wrap(f)() end
for i,v in pairs(game.ReplicatedStorage.SKEY:GetChildren()) do
	local cKeyS
	repeat
		cKeyS = genKey()
	until not game.ReplicatedStorage.SKEY:FindFirstChild("v"..cKeyS)
	v.Name = "v"..cKeyS
	v.Value = i-1
	key["v"..cKeyS] = i-1
end
for i,v in pairs(game.ReplicatedStorage.LKEY:GetChildren()) do
	local n = string.sub(v.Name,2)
	local s
	for u,c in pairs(game.ReplicatedStorage.SKEY:GetChildren()) do
		if c.Value == n then s = string.sub(c.Name,2) break end
	end
	v.Value = s
end
function spairs(t, order)
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end
function commaValue(amount)
	local formatted = amount or 0
	while true do  
		local form,k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		formatted = form
		if (k<=0) then
			break
		end
	end
	return formatted
end
local dupeTable = shared.env.dupeTable
function hasPass(plr,id,toPrompt)
	--local has = hasPass(sourceplr,id)
	local cached = cache[plr.Name.."."..id]
	local has = false
	if cached and cached.t > tick() then
		has = cached.bool
	else
		has = marketplace:PlayerOwnsAsset(plr,id) 
		local success,has2 = pcall(function() return marketplace:UserOwnsGamePassAsync(plr.userId,id) end)
		has = has == true and has or (success and has2 or false)
		cache[plr.Name.."."..id] = {bool=has,t=tick()+200}
	end
	--if not has and toPrompt then game:GetService("MarketplaceService"):PromptGamePassPurchase(sourceplr,id) end
	return (has or game.PlaceId == 446422432)
end
shared.hasPass = hasPass
function hasBadge(plrOrId,id)
	local has = false
	if type(plrOrId) == "string" or type(plrOrId) == "number" then
		local cached = cache[plrOrId.."."..id]
		if cached and cached.t > tick() then
			has = cached.bool
		else
			has = (badgeservice:UserHasBadgeAsync(plrOrId,id) or game.PlaceId == 446422432)
			cache[plrOrId.."."..id] = {bool=has,t=tick()+600}
		end
	else
		local cached = cache[plrOrId.Name.."."..id]
		if cached and cached.t > tick() then
			has = cached.bool
		else
			has = (badgeservice:UserHasBadgeAsync(plrOrId.userId,id) or game.PlaceId == 446422432)
			cache[plrOrId.Name.."."..id] = {bool=has,t=tick()+600}
		end
		--if not has and toPrompt then game:GetService("MarketplaceService"):PromptGamePassPurchase(sourceplr,id) end
	end
	return (has or game.PlaceId == 446422432)
end
shared.hasBadge = hasBadge
function awardBadge(plr,id)
	if not cache[plr.Name.."."..id] or not cache[plr.Name.."."..id].bool then
		cache[plr.Name.."."..id] = {bool=true,t=tick()+600}
		badgeservice:AwardBadge(plr.userId,id)
	end
end
function getAdminLevel(plr)
	return script.Parent.GetAdminLevel:Invoke(plr.userId) or 0
end
function updateLeaderstats(plr)
	repeat wait() until shared.playerMetadata[plr] and shared.playerMetadata[plr].loaded
	local plrData = game.ReplicatedStorage.PlayerData:WaitForChild(plr.Name)
	local generic = plrData:WaitForChild("Generic")
	local stats = plr.leaderstats
	local level = generic and generic.Level
	local points = generic and generic.Points
	local pointsValue = stats:FindFirstChild("Points") or stats:FindFirstChild("TestPoints")
	if pointsValue then pointsValue.Value = points.Value end
	if level then stats.Level.Value = level.Value end
	local prevnum = playerRankNums[plr]
	local highest = 0
	local rankName,rankNum,rankInc
	for i,v in pairs(ranks) do
		local num,name,inc,req = v.num,v.name,v.inc,nil
		for u,c in pairs(v) do
			if u == "points" then req = {"points",c} elseif u == "plrid" then req = {"id",c} elseif u == "level" then req = {"level",c} end
		end
		if req[1] == "points" then
			if points.Value >= req[2] and num > highest then
				rankNum,rankName,rankInc = num,name,inc
				highest = rankNum
			end
		elseif req[1] == "id" then
			if plr.userId == req[2] and num > highest then
				rankNum,rankName,rankInc = num,name,inc
				highest = rankNum
			end
		elseif req[1] == "level" then
			if level.Value >= req[2] and num > highest then
				rankNum,rankName,rankInc = num,name,inc
				highest = rankNum
			end
		end
	end
	rankName = rankName or "nil"
	rankNum = rankNum or 0
	rankInc = rankInc or 1
	if prevnum == 0 then prevnum = rankNum end
	playerRankNums[plr] = rankNum
	if not (shared.disablesaving or shared.dunces[plr.Name]) then
		if rankNum >= 6 and not hasBadge(plr,1321793400) then awardBadge(plr,1321793400) end
		if rankNum >= 8 and not hasBadge(plr,999273880) then awardBadge(plr,999273880) end
		if rankNum >= 11 and not hasBadge(plr,1038588827) then awardBadge(plr,1038588827) end
		if rankNum >= 12 and not hasBadge(plr,1022459383) then awardBadge(plr,1022459383) end
		if level.Value >= 200 and not hasBadge(plr,1677209431) then awardBadge(plr,1677209431) end
		if level.Value >= 300 and not hasBadge(plr,1677210048) then awardBadge(plr,1677210048) end
	end
	local rankData
	local useRankedRank = plrData.Settings.UseRankedRank.Value
	local rankedData = plrData.Ranked:FindFirstChild(useRankedRank)
	if useRankedRank ~= "" and (os.time()-rankedData.LastPlay.Value < 604800 or rankedData.Wins.Value+rankedData.Losses.Value < 10) then
		--print("using rank",useRankedRank,os.time()-plrData.Ranked[useRankedRank].LastPlay.Value)
		_,rankData = shared.env.getRankFromRankedData(rankedData)
	end
	stats.Rank.Value = rankData and rankData.DisplayName or rankName
	if (prevnum < rankNum) then
		print("rankup")
		local rankupText = "RANK UP ".. script.longdash.Value .." ".. string.upper(rankName)
		if rankNum == 2 then rankupText = rankupText .."\nNEW TIME TRIALS AVAILABLE" end
		if rankNum == 4 then rankupText = rankupText .."\nNEW TIME TRIALS AVAILABLE" end
		if rankNum == 5 then rankupText = rankupText .."\nNEW TUTORIAL AVAILABLE" end
		if rankNum == 6 then rankupText = rankupText .."\nNEW TIME TRIALS AVAILABLE" end
		if rankNum == 8 then rankupText = rankupText .."\nNEW TIME TRIALS AVAILABLE" end
		if rankNum == 9 and level == "60" then rankupText = rankupText .."\nNEW TUTORIAL AVAILABLE" end

		game.ReplicatedStorage.ClientPopup:FireClient(plr,{text=rankupText,colour=Color3.new(.5,.5,1),position=Vector2.new(0,42),fontSize=42,speed=.5})
		game.ReplicatedStorage.SystemMessage:FireAllClients(plr.Name.." has ranked up to "..rankName.."!",Color3.new(0,1,1))
	end
end
shared.prevPlaytimes = {}
function updateLevel(plr,plrData)
	plrData = plrData or (game.ReplicatedStorage:WaitForChild("PlayerData")) and game.ReplicatedStorage.PlayerData:WaitForChild(plr.Name)
	local localGeneric = plrData:WaitForChild("Generic")
	local xp = localGeneric:WaitForChild("Experience")
	local level = localGeneric:WaitForChild("Level")
	local prevxp = xp.Value
	local prevlvl = level.Value
	local req
	local function updateReq() req = shared.env.getXpRequirementFromLevel(level.Value) end
	updateReq()
	if xp and xp.Value >= req then
		local casesToAdd = {Common=0,Uncommon=0,Rare=0,Epic=0,Legendary=0,Resplendent=0}
		local chipsToAdd = 0
		local repeats = 0
		repeat
			repeats = repeats + 1
			updateReq()
			xp.Value = xp.Value - req
			level.Value = level.Value + 1
			if level.Value%5 == 0 and level.Value ~= 0 then
				local toAdd = "Common"
				if level.Value >= 40 then
					toAdd = "Uncommon"
				end
				if level.Value >= 60 then
					toAdd = "Rare"
				end
				if level.Value >= 120 then
					toAdd = "Epic"
				end
				if level.Value >= 160 then
					toAdd = "Legendary"
				end
				casesToAdd[toAdd] = casesToAdd[toAdd] + 1
			end
			if level.Value%5 == 0 and level.Value >= 15 then
				chipsToAdd += 1+math.floor(level.Value/25)
			end
			if level.Value == 300 then casesToAdd.Resplendent = 1 end
		until xp.Value < req or repeats > 100
		for i,v in pairs(casesToAdd) do if v > 0 then for u = 1,v do script.Parent.AddCaseToId:Invoke(plr,i) end end end
		script.Parent.GiveChips:Fire(plr,chipsToAdd)
		updateLeaderstats(plr)
	end
	if prevlvl < level.Value then
		--[[if level.Value >= 1000 then
			plr:Kick("congratulations you reached level 1000, you win. go do something else now")
		end]]
		game.ReplicatedStorage.ClientPopup:FireClient(plr,{text="LEVEL UP ".. script.longdash.Value .." ".. level.Value,colour=Color3.new(.5,.5,1),fontSize=42,speed=.25})
		if (prevlvl < 100 and level.Value >= 100) or (prevlvl < 200 and level.Value >= 200) or (prevlvl < 300 and level.Value >= 300) then
			discord:SubmitMessage("levels",plr.Name.." reached level *"..level.Value.."* from level *"..prevlvl.."*")
		end
		if level.Value-prevlvl > 10 then
			discord:SubmitMessage("levels",plr.Name.." levelled more than 10 times, from *"..prevlvl.."* to *"..level.Value.."*")
		end
		if prevlvl < 15 and level.Value >= 15 then
			game.ReplicatedStorage.BottomMessage:FireClient(plr,{text=("BILLBOARD HACKING UNLOCKED"),strokeTransparency=.8})
		end
		if prevlvl < 20 and level.Value >= 20 then
			game.ReplicatedStorage.BottomMessage:FireClient(plr,{text=("ADVANCED TUTORIAL UNLOCKED"),strokeTransparency=.8})
		end
		if prevlvl < 30 and level.Value >= 30 then
			game.ReplicatedStorage.BottomMessage:FireClient(plr,{text=("RANKED UNLOCKED"),strokeTransparency=.8})
		end
		for i,v in pairs(game.ReplicatedStorage.Gear:GetChildren()) do
			if v:FindFirstChild("ReqLevel") then
				if prevlvl < v.ReqLevel.Value and level.Value >= v.ReqLevel.Value then
					local name = v:FindFirstChild("DisplayName") and v.DisplayName.Value or v.Name
					game.ReplicatedStorage.BottomMessage:FireClient(plr,{text="GEAR UNLOCKED: "..string.upper(name),strokeTransparency=.8,colour=Color3.new(0,1,.2)})
				end
			end
		end
		if game.ReplicatedStorage.PlayerRuntimeData[plr.Name].Gear.rightarm.Value == "EvolutionGlove" then
			local prevEvolution = shared.env.getEvolutionFromLevel(prevlvl)
			local evolution = shared.env.getEvolutionFromLevel(level.Value)
			if prevEvolution < evolution and plr.Character and plr.Character:FindFirstChild("Right Arm") then
				local particle = game.ReplicatedStorage.EvolveParticle:Clone()
				local sound = game.ReplicatedStorage.EvolveSound:Clone()
				particle.Parent = plr.Character["Right Arm"]
				sound.Parent = plr.Character["Right Arm"]
				particle:Emit(50)
				sound:Play()
				game.Debris:AddItem(sound,10)
				game.Debris:AddItem(particle,10)
				equipGear(plr,game.ReplicatedStorage.Gear.EvolutionGlove)
			end
		end
		shared.prevPlaytimes[plr] = plrData.Stats.Playtime.Value
	end
	return prevxp
end
function script.Parent.UpdateLevel.OnInvoke(p,f) return updateLevel(p,f or game.ReplicatedStorage.PlayerData:WaitForChild(p.Name)) end
function getPoints(p)
	local generic = game.ReplicatedStorage.PlayerData:FindFirstChild(p.Name) and game.ReplicatedStorage.PlayerData[p.Name]:WaitForChild("Generic")
	if generic then
		return generic:WaitForChild("Points").Value or 0
	end
end
function calculatePointsToAdd(plr,origPts,origXp)
	local plrData = game.ReplicatedStorage.PlayerData:WaitForChild(plr.Name)
	if plrData then
		local osdate = os.date("!*t")
		local weekday = osdate.wday
		local day = osdate.day
		local isWeekend = weekday == 1 or weekday == 7
		workspace.Weekend.Value = isWeekend
		local inc = 0
		for i,v in pairs(ranks) do
			if v.num == playerRankNums[plr] then
				inc = v.inc
				break
			end
		end
		local multiplier = inc
		
		local mins = game.ReplicatedStorage.Time.Value % 1440
		multiplier += (isWeekend and .2 or 0)
		multiplier += (shared.env.isDay() and 0 or .15)
		multiplier += (game.ReplicatedStorage.IsHalloweenDay.Value and 1 or (game.ReplicatedStorage.IsHalloween.Value and .5 or 0))
		--multiplier += (os.time() < plrData.Bonuses.Expiration.Value and plrData.Bonuses.ActiveMult.Value or 0)
		local pointsToAdd = origPts*multiplier
		pointsToAdd = pointsToAdd * (hasPass(plr,1031483390) and 1.5 or 1)
		local playtimeMultiplier = getPlaytimeMultiplier(plr) or 1
		pointsToAdd = pointsToAdd * playtimeMultiplier
		if game.ReplicatedStorage.HardcoreMode.Value then
			pointsToAdd *= 4
		end
		local xpToAdd = (origXp or ((origPts/2)*(inc/1.5)))
		return pointsToAdd,xpToAdd,multiplier,origPts
	end
	return 0,0,0,0
end
function addPoints(plr,amnt,baseamnt)
	baseamnt = baseamnt or amnt
	if recentinvokes[plr] < 100 then
		local playerData = game.ReplicatedStorage.PlayerData:FindFirstChild(plr.Name)
		local pts = playerData and playerData.Generic.Points
		recentinvokes[plr] = recentinvokes[plr] + 1
		cwrap(function() wait(1) recentinvokes[plr] = recentinvokes[plr] - 1 end)
		if (recentinvokes[plr] >= 12) and amnt > 1 then recentinvokes[plr] = 100 autokick(plr,"stats") end
		if pts then
			pts.Value = math.clamp(pts.Value+amnt,0,999999999999999)
			updateLeaderstats(plr)
			if pts.Value >= 10000 and not playerData.Generic.First10k.Value then
				game.ReplicatedStorage.PopupMessage:FireClient(plr,"You have reached 10,000 points! You can now click and hold the button at the top of your screen to turn in your points for XP and Levels. You will normally want to do this whenever you can get a level up from it, but it doesn't really matter when you do.\nTry to not have an excess amount of points, as you could be wasting potential levels!")
				playerData.Generic.First10k.Value = true
			end
		else
			warn("couldn't find points value for",plr.Name)
		end
	end
end
script.Parent:WaitForChild("AddPoints")
function script.Parent.AddPoints.OnInvoke(plr,amount)
	addPoints(plr,amount)
end
function dunce(todunce,id,reason,remote,sourceplr)
	--[[local plr = game.Players:GetPlayerByUserId(id)
	if sourceplr and type(sourceplr) == "string" then sourceplr = {Name=sourceplr} end
	if plr and shared.dunces[plr.Name] ~= todunce then
		shared.dunces[plr.Name] = todunce
		shared.serverPlayerData[plr].meta.Dunced = todunce
		game.ReplicatedStorage.UpdateDunceList:FireAllClients(shared.dunces)
		plr:LoadCharacter()
		if todunce then
			discord:SubmitMessage("duncefeed",plr.Name.." just got the dunce cap"..(sourceplr and " by the hands of "..sourceplr.Name or "")..(reason and " for "..reason or ""))
			game.ReplicatedStorage.SystemMessage:FireAllClients("Uh oh! Looks like "..plr.Name.." just got the dunce cap"..(reason and " for "..reason or "").."!",Color3.new(1,1,0))
		elseif not todunce then
			discord:SubmitMessage("duncefeed",plr.Name.." just got their dunce cap removed"..(sourceplr and " by the hands of "..sourceplr.Name or ""))
			game.ReplicatedStorage.SystemMessage:FireAllClients(plr.Name.." had their dunce cap removed!",Color3.new(.2,1,.2))
		end
	elseif not plr and not remote then
		warn("publishing")
		messagingService:PublishAsync("dunce",http:JSONEncode({todunce=todunce,id=id,reason=reason,sourceplr=sourceplr and sourceplr.Name}))
		warn("published")
	end]]
end
script.Parent.Dunce.Event:connect(dunce)
game.ReplicatedStorage.Died.OnServerEvent:connect(function(plr)
	local char = plr.Character
	if shared.rankedDeath then
		shared.rankedDeath(plr)
	end
	shared.partyLog(plr,plr.Name.." died")
	local deaths = game.ReplicatedStorage.PlayerData[plr.Name].Stats.Deaths
	deaths.Value = deaths.Value + 1
	if deaths.Value >= 500 and not hasBadge(plr,1084204930) and not (shared.disablesaving or shared.dunces[plr.Name]) then
		awardBadge(plr,1084204930)
	end
	if game.ReplicatedStorage.HardcoreMode.Value then
		game.ReplicatedStorage.HardcoreAnnouncement:FireAllClients(plr.Name.." has been killed")
		shared.donotsave[plr.userId] = "died"
		shared.serverlocklist[tostring(plr.userId)] = {reason = "You died"}
		plr:Kick("You died")
	end
end)
function connectPlayer(plr)
	playerSessionMults[plr] = {mult=0,timer=0}
	recentearned[plr] = 0
	recentmoves[plr] = {}
	recentinvokes[plr] = 0
	playerRankNums[plr] = 0
	plrsResetting[plr] = false
	local spawnloc = Instance.new("SpawnLocation")
	spawnloc.Name = plr.Name.."Spawn"
	spawnloc.Duration = 0
	spawnloc.Transparency = 1
	spawnloc.Size = Vector3.new()
	spawnloc.CFrame = workspace.SpawnLocation.CFrame
	spawnloc.CanCollide = false
	spawnloc.Anchored = true
	spawnloc.Parent = workspace:WaitForChild("RespawnLocations")
	respawnLocations[plr] = spawnloc
	plr.RespawnLocation = spawnloc
	local grappler = Instance.new("Attachment",workspace.Terrain)
	grappler.Name = "GrapplerArmAttach"..plr.Name
	local grappler = Instance.new("Attachment",workspace.Terrain)
	grappler.Name = "GrapplerAttach"..plr.Name
	local data = game.ReplicatedStorage.PlayerData:WaitForChild(plr.Name)
	local runtimeData = game.ReplicatedStorage.PlayerRuntimeData:WaitForChild(plr.Name)
	local hasColaPass
	local hasGliderPass
	local hasStimPass
	--setup spectate data
	local spectateData = Instance.new("Folder",game.ReplicatedStorage.SpectateData)
	spectateData.Name = plr.Name
	local function addValue(valType,name,value)
		local obj = Instance.new(valType.."Value",spectateData)
		obj.Name = name
		if value ~= nil then obj.Value = value end
	end
	addValue("Int","TotalSpectators")
	addValue("Object","Spectating")
	addValue("CFrame","Camera")
	addValue("Vector3","CameraOffset")
	addValue("Bool","DoNotCount",false)
	--
	plr.CharacterAdded:connect(function(char)
		runService.Stepped:wait()
		char.HumanoidRootPart.CFrame = spawnloc.CFrame + Vector3.new(0,2.5,0)
		print("teleported",char,"to their spawn @",spawnloc.CFrame + Vector3.new(0,2.5,0))
		local hum = char:WaitForChild("Humanoid")
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject

		hum.Died:connect(function()
			local st = tick()
			repeat runService.Heartbeat:wait() until tick()-st > 10 or not char.Parent
			if char.Parent or not char then plr:LoadCharacter() end
		end)

		while game.ReplicatedStorage.Capsules:FindFirstChild(plr.Name) do game.ReplicatedStorage.Capsules[plr.Name]:destroy() end
		local capsule = game.ServerStorage:WaitForChild("Capsule"):Clone()
		capsule.Name = plr.Name
		capsule.Parent = game.ReplicatedStorage.Capsules
		
		if shared.playerMetadata[plr] and shared.playerMetadata[plr].loaded then
			for i,v in pairs(runtimeData:WaitForChild("Gear"):GetChildren()) do
				cwrap(function()
					if v.Name ~= "glowing" and v.Value ~= "" and v.data.Value ~= nil then
						equipGear(plr,v.data.Value)
					end
				end)
			end
		end


		local function connectPartCollisionGroup(part)
			if part:IsA("BasePart") then
				local group = game.ReplicatedStorage.IsRanked.Value and "playersInTimeTrial" or (shared.dunces[plr.Name] and "dunces" or "players")
				--print("setting collision group of",part,"to",group)
				physics:SetPartCollisionGroup(part,group)
			end
		end
		char.DescendantAdded:connect(connectPartCollisionGroup)
		for i,v in pairs(char:GetDescendants()) do connectPartCollisionGroup(v) end

		local stimPartOffset = game.ReplicatedStorage.Stim.Base.CFrame:ToObjectSpace(game.ReplicatedStorage.Stim.Part.CFrame)
		local stimLA = game.ReplicatedStorage.Stim:Clone()
		stimLA.Parent = char:WaitForChild("Left Arm")
		if plr.userId == 22402288 then stimLA.Part.Color = Color3.fromRGB(0, 136, 136) end
		stimLA.Base.Anchored = false
		stimLA.Part.Anchored = false
		stimLA.Base.Transparency = 1
		stimLA.Part.Transparency = 1
		local weld = Instance.new("Weld",stimLA.Base)
		weld.Part0 = stimLA.Base
		weld.Part1 = stimLA.Part
		weld.C0 = stimPartOffset
		local weld = Instance.new("Weld",stimLA)
		weld.Part0 = stimLA.Base
		weld.Part1 = char["Left Arm"]
		weld.C1 = CFrame.new(0.239873886,-1.01166534,-0.275385857,0, -1,0, 1,0,0,0,0, 1)

		local stimT = game.ReplicatedStorage.Stim:Clone()
		stimT.Parent = char:WaitForChild("Torso")
		if plr.userId == 22402288 then stimT.Part.Color = Color3.fromRGB(0, 136, 136) end
		stimT.Base.Anchored = false
		stimT.Part.Anchored = false
		stimT.Base.Transparency = 1
		stimT.Part.Transparency = 1
		local weld = Instance.new("Weld",stimT.Base)
		weld.Part0 = stimT.Base
		weld.Part1 = stimT.Part
		weld.C0 = stimPartOffset
		local weld = Instance.new("Weld",stimT)
		weld.Part0 = stimT.Base
		weld.Part1 = char.Torso
		weld.C1 = CFrame.new(-.504314423,.629791021,-.856724977,-.726231933,-.471303403,-.500460804,-.359861821,.880916178,-.307386726,.585735977,-.0431372449,-.809353232)

		local telescope = plr.userId == 22402288 and game.ServerStorage.JustynTelescope:Clone() or game.ServerStorage.Telescope:Clone()
		local joint = Instance.new("Motor6D",telescope)
		joint.Name = "TelescopeJoint"
		joint.Part0 = char:WaitForChild("Right Arm")
		joint.Part1 = telescope.Top
		joint.C0 = CFrame.new( -0.140827179, -1.04076505, -0.347297192, 7.03336476e-15, -2.59230707e-14, -0.999999702, 0.707103133, -0.707101285, -1.99508565e-14, -0.707104087, -0.707102358, -1.00041554e-14)
		for i,v in pairs(telescope:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
		telescope.Name = "Telescope"
		telescope.Parent = char

		spawn(function()
			repeat wait(1)
				if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and shared.playerMetadata[plr] and shared.playerMetadata[plr].loaded then
					if not game.ReplicatedStorage.IsRanked.Value then
						for i,v in pairs(data.Generic:WaitForChild("UnlockedSpawns"):GetChildren()) do
							local sd = altSpawnsData[v.Name]
							if not v.Value then
								local inside = shared.env.isInside(char.HumanoidRootPart.Position,sd.pos1,sd.pos2)
								if inside then
									v.Value = true
									print("unlocked",sd.name)
									game.ReplicatedStorage.BottomMessage:FireClient(plr,{text=("NEW SPAWN DISCOVERED\n"..sd.name),strokeTransparency=.8})
								end
							end
						end
					end
					local closest,closestdist = nil,math.huge
					for i,v in pairs(altSpawnsData) do
						local sp = workspace:FindFirstChild(i)
						if sp then
							local dist = (char.HumanoidRootPart.Position-sp.Position).magnitude
							if dist < closestdist and data.Generic.UnlockedSpawns:FindFirstChild(i) and data.Generic.UnlockedSpawns[i].Value then
								closest = sp
								closestdist = dist
							end
						end
					end
					if closest then data.Generic.LastSpawn.Value = closest.Name end
				end
			until not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0
		end)

		local cola = game.ReplicatedStorage:WaitForChild("Cola"):Clone()
		customizeCola(cola,plr.userId)
		cola.Parent = char
		cola.Anchored = false
		cola.Transparency = 1
		local weld = Instance.new("Weld",cola)
		weld.Part0 = char:WaitForChild("Right Arm")
		weld.Part1 = cola
		weld.C1 = CFrame.new(.4,0,.9)*CFrame.Angles(math.rad(90),0,0)

		local glider = game.ReplicatedStorage:WaitForChild(plr.userId == 22402288 and "GliderWhite" or "Glider"):Clone()
		glider.Parent = char
		glider.TrailLeft.Enabled = false
		glider.TrailRight.Enabled = false
		glider.Anchored = false
		glider.Transparency = 1
		glider.Name = "Glider"
		local weld = Instance.new("Weld",glider)
		weld.Part0 = char:WaitForChild("HumanoidRootPart")
		weld.Part1 = glider
		weld.C0 = CFrame.new(0,3.2999959,-.2,0,0,1,0,1,0,-1,0,0)
		--botw glider (i know the code sucks..)
		if plr.userId == 22402288 then
			local parastole = game.ReplicatedStorage:WaitForChild(plr.userId == 22402288 and "Parastole"):Clone()
			parastole.Parent = char
			parastole.TrailLeft.Enabled = false
			parastole.TrailRight.Enabled = false
			parastole.Anchored = false
			parastole.Transparency = 1
			parastole.Name = "Parastole"
			local weld = Instance.new("Weld",parastole)
			weld.Part0 = char:WaitForChild("HumanoidRootPart")
			weld.Part1 = parastole
			weld.C0 = CFrame.new(0,3.8,-.2,0,0,1,0,1,0,-1,0,0)*CFrame.Angles(math.rad(0),-89.55,0)
		end

		while shared.dunces[plr.Name] == nil do wait() end
		if shared.dunces[plr.Name] then
			local cap = game.ServerStorage.DunceCap:Clone()
			cap.Parent = char
			local weld = Instance.new("Weld",cap)
			weld.Part0 = cap
			weld.Part1 = char:WaitForChild("Head")
			weld.C0 = CFrame.new(0,-1.6,0)
			spawn(function()
				wait(math.random(60,90))
				local char = plr.Character
				local bf = Instance.new("BodyVelocity",char.HumanoidRootPart)
				while wait() do
					bf.Velocity = -(char.Torso.Velocity * ((tick()%10)-5))*((math.random()*10)-5)
					if not char or not char.Parent or not char:FindFirstChild("Humanoid") or char.Humanoid.Health == 0 then return end
				end
			end)
		end
	end)
	repeat wait() until plr.Parent == game:GetService("Players")
	plr:LoadCharacter()
	hasColaPass = hasPass(plr,6992293)
	hasGliderPass = hasPass(plr,9199932)
	hasStimPass = hasPass(plr,8980673)
	--game.ReplicatedStorage.UpdateDunceList:FireAllClients(shared.dunces)
	while not shared.playerMetadata[plr] and not shared.playerMetadata[plr].loaded do wait() end
	--shared.dunces[plr.Name] = shared.serverPlayerData[plr].meta.Dunced
	updateLeaderstats(plr)
	local plrData = game.ReplicatedStorage.PlayerData:WaitForChild(plr.Name)
	local localGeneric = plrData:WaitForChild("Generic")
	localGeneric.Level.Changed:connect(function()

		local function giveSkin(name,gear)
			if not plrData.Inventory.Skins:FindFirstChild(name) then
				local skin = Instance.new("IntValue")
				skin.Name = name
				skin.Value = 1
				skin.Parent = plrData.Inventory.Skins
				game.ReplicatedStorage.PopupMessage:FireClient(plr,"You have recieved the "..name.." skin for unlocking "..gear.." after owning the gamepass!")
			end
		end

		local hasBloxyCola = hasPass(plr,6992293)
		local hasParaglider = hasPass(plr,9199932)
		local hasAdrenalineBelt = hasPass(plr,8980673)
		local hasGrappler = hasPass(plr,6992290)
		if hasBloxyCola and localGeneric.Level.Value >= game.ReplicatedStorage.Gear.BloxyCola.ReqLevel.Value then
			giveSkin("Soda","Bloxy Cola")
		end
		if hasParaglider and localGeneric.Level.Value >= game.ReplicatedStorage.Gear.Paraglider.ReqLevel.Value then
			giveSkin("Kani","Paraglider")
		end
		if hasAdrenalineBelt and localGeneric.Level.Value >= game.ReplicatedStorage.Gear.AdrenalineBelt.ReqLevel.Value then
			giveSkin("Octane","Adrenaline Belt")
		end
		if hasGrappler and localGeneric.Level.Value >= game.ReplicatedStorage.Gear.Grappler.ReqLevel.Value then
			giveSkin("Dark Matter","Grappler")
		end

	end)
end
for i,v in pairs(game.Players:GetPlayers()) do spawn(function() connectPlayer(v) end) end
game.Players.PlayerAdded:connect(function(plr) connectPlayer(plr)
	respawnDebounce[plr.Name] = tick()
end)
game.Players.PlayerRemoving:connect(function(plr)
	if respawnLocations[plr] then respawnLocations[plr]:destroy() end
	if game.ReplicatedStorage.HardcoreMode.Value and shared.donotsave[plr.userId] and shared.donotsave[plr.userId] ~= "died" then
		shared.serverlocklist[tostring(plr.userId)] = {reason = "You fled the server"}
		game.ReplicatedStorage.HardcoreAnnouncement:FireAllClients(plr.Name.." fled the server")
	end
	plrsResetting[plr] = nil
	recentearned[plr] = nil
	recentmoves[plr] = nil
	recentinvokes[plr] = nil
	playerRankNums[plr] = nil
	plrsResetting[plr] = nil
	respawnLocations[plr] = nil
	respawnDebounce[plr.Name] = nil
	shared.lastBagCollections[plr] = nil
	selfbandebounce[plr] = nil
	if game.ReplicatedStorage.SpectateData:FindFirstChild(plr.Name) then game.ReplicatedStorage.SpectateData[plr.Name]:destroy() end
	local grappler = workspace.Terrain:FindFirstChild("GrapplerAttach"..plr.Name)
	local grappler2 = workspace.Terrain:FindFirstChild("GrapplerArmAttach"..plr.Name)
	if grappler then grappler:destroy() end
	if grappler2 then grappler2:destroy() end
end)
function generateZipline(sourceplr,m,fresh,p1,p2)
	local line = game.ReplicatedStorage.ZiplineLine:Clone()
	local model = m
	local top,bottom
	if fresh then
		model = Instance.new("Model",workspace.Ziplines)
		model.Name = "Zipline"
		top = game.ReplicatedStorage.ZiplinePole:Clone()
		top.BrickColor = BrickColor.Black()
		top.CFrame = CFrame.new(p1)
		top.CanCollide = false
		top.Name = "ZiplineTop"
		top.Parent = model
		bottom = game.ReplicatedStorage.ZiplinePole:Clone()
		bottom.BrickColor = BrickColor.Black()
		bottom.CFrame = CFrame.new(p2)
		bottom.CanCollide = false
		bottom.Name = "ZiplineBottom"
		bottom.Parent = model
		local owner = Instance.new("StringValue",model)
		owner.Name = "Owner"
		owner.Value = sourceplr.Name
	end
	local pos1 = model.ZiplineTop.Position + Vector3.new(0,(model.ZiplineTop.Size.Y/2)-.75,0)
	local pos2 = model.ZiplineBottom.Position + Vector3.new(0,(model.ZiplineBottom.Size.Y/2)-.75,0)
	local dist = (pos1-pos2).magnitude
	line.Size = Vector3.new(.1,.1,.1)
	line.CFrame = CFrame.new(pos1,pos2)*CFrame.new(0,0,-dist/2)
	line.Parent = model
	line.Name = "Line"
	local mesh = Instance.new("BlockMesh",line)
	mesh.Scale = Vector3.new(1,1,dist*10)


	--[[christmas lights
	local amount = dist/3
	for i = 1,amount do
		local cd = i%3
		local colour
		if cd == 0 then colour = Color3.new(1,0,0) elseif cd == 1 then colour = Color3.new(0,1,0) elseif cd == 2 then colour = Color3.new(1,1,0) end
		local light = Instance.new("Part",line)
		light.Material = Enum.Material.Neon
		light.Color = colour
		light.Size = Vector3.new(.2,.2,.2)
		light.CanCollide = false
		light.Anchored = true
		light.CFrame = CFrame.new(pos1,pos2)*CFrame.new(0,0,-3*i)
		colour = not colour
	end]]
	--christmas lights "if cd == 0 then colour = Color3.new(1,0,0) elseif cd == 1 then colour = Color3.new(0,1,0) elseif cd == 2 then colour = Color3.new(1,1,0) end"
	--halloween lights  "if cd == 0 then colour = Color3.new(1,.5,0) elseif cd == 1 then colour = Color3.new(0.168627, 0.815686, 0.0666667) elseif cd == 2 then colour = Color3.new(0.619608, 0.121569, 1) end"
	local startp = Instance.new("Part",model)
	startp.Transparency = 1
	startp.Anchored = true
	startp.CanCollide = false
	startp.Size = Vector3.new()
	startp.CFrame = CFrame.new((CFrame.new(pos1,pos2)*CFrame.new(0,0,-5)).p,Vector3.new(pos2.X,pos1.Y,pos2.X))
	startp.Name = "Start"
	local endp = Instance.new("Part",model)
	endp.Transparency = 1
	endp.Anchored = true
	endp.CanCollide = false
	endp.Size = Vector3.new()
	local cf = CFrame.new(pos1,pos2)*CFrame.new(0,0,-(dist-5))
	endp.CFrame = CFrame.new(cf.p,cf.p+startp.CFrame.lookVector)
	endp.Name = "End"

	local lengthVal = Instance.new("NumberValue",model)
	lengthVal.Value = (startp.Position-endp.Position).magnitude
	lengthVal.Name = "Length"

	local linecfVal = Instance.new("CFrameValue",model)
	linecfVal.Value = CFrame.new(startp.Position,endp.Position)*CFrame.new(0,0,-lengthVal.Value/2)
	linecfVal.Name = "LineCFrame"

	local rayVal = Instance.new("RayValue",model)
	rayVal.Value = Ray.new(startp.Position/lengthVal.Value,startp.CFrame.lookVector)
	rayVal.Name = "Ray"

	return model
end
function getSkinData(skin)
	local txcol = (skin:FindFirstChild("Texture") and skin.Texture:FindFirstChild("Colour")) and skin.Texture.Colour.Value or Color3.new(1,1,1)
	local skinData = {
		name=skin.Name,
		colour=skin.Color.Value,
		rarity=skin.Parent.Name,
		material=skin.Material.Value,
		texture=skin:FindFirstChild("Texture") and skin.Texture.Value or "",
		icon=skin:FindFirstChild("Icon") and skin.Icon.Value or "",
		bgcolour=(skin:FindFirstChild("Icon") and skin.Icon:FindFirstChild("BackgroundColour")) and skin.Icon.BackgroundColour.Value or skin.Color.Value,
		texturecolour=txcol,
		iconcolour=(skin:FindFirstChild("Icon") and skin.Icon:FindFirstChild("IconColour")) and skin.Icon.IconColour.Value or txcol,
		animated=(skin:FindFirstChild("Animated") and skin.Animated.Value or nil),
	}
	return skinData
end
function game.ReplicatedStorage.GenerateZipline.OnServerInvoke(sourceplr,m,fresh,p1,p2)
	local total = 0
	for i,v in pairs(workspace.Ziplines:GetChildren()) do if v:FindFirstChild("Owner") and v.Owner.Value == sourceplr.Name then total = total + 1 end end
	if total < 3 then
		return generateZipline(sourceplr,m,fresh,p1,p2)
	end
end
function game.ReplicatedStorage.RemoveZipline.OnServerInvoke(sourceplr,model)
	if (model.Parent == workspace.Ziplines or model.Parent == workspace.Springs) and model:FindFirstChild("Owner") and model.Owner.Value == sourceplr.Name then model:destroy() end
end
game.ReplicatedStorage:WaitForChild("CreateSpring")
function game.ReplicatedStorage.CreateSpring.OnServerInvoke(sourceplr,cf)
	local total = 0
	for i,v in pairs(workspace.Springs:GetChildren()) do if v:FindFirstChild("Owner") and v.Owner.Value == sourceplr.Name then total = total + 1 end end
	if total < 3 then
		local spring = game.ReplicatedStorage.Spring:Clone()
		spring.Name = "NoClimbVault"
		spring.Parent = workspace.Springs
		spring.CFrame = cf
		local owner = Instance.new("StringValue",spring)
		owner.Name = "Owner"
		owner.Value = sourceplr.Name
		return spring
	end
end
function getPlaytimeMultiplier(plr)
	if not (playerSessionMults[plr]) then return end 
	local sm = math.clamp(math.floor((1+playerSessionMults[plr].mult)*2)/2,1,5)
	return sm
end
function dualAdd(plr,rawpts,rawxp,absolute)
	local pointsToAdd,xpToAdd,multiplier = calculatePointsToAdd(plr,rawpts,rawxp)
	if absolute then
		pointsToAdd = rawpts
		xpToAdd = rawxp or xpToAdd
		multiplier = 1
	end
	if game.ReplicatedStorage.PlayerData:FindFirstChild(plr.Name) then
		local xp = game.ReplicatedStorage.PlayerData[plr.Name].Generic.Experience
		xp.Value = xp.Value + xpToAdd
	end
	addPoints(plr,pointsToAdd,rawpts)

	local currentParty = shared.partiesData.playerStatus[plr].party.current
	if currentParty and currentParty ~= "" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		local fractionToAdd,rawFraction = pointsToAdd*.15,rawpts*.15
		local partyMembers = shared.partiesData.parties[currentParty].members
		for _,member in pairs(partyMembers) do
			if member ~= plr and member.Character and member.Character:FindFirstChild("HumanoidRootPart") and (member.Character.HumanoidRootPart.Position-plr.Character.HumanoidRootPart.Position).magnitude < 120 then
				game.ReplicatedStorage.Parkour:FireClient(member,fractionToAdd,0,rawFraction,nil,{pos=Vector2.new(math.random(-20,20),50+math.random(-10,10)),colour=Color3.new(1,0.3,0.3),strokeColour=Color3.new(),strokeTransparency=.8,tweenTime = 1})
				game.ReplicatedStorage.AddCombo:FireClient(member,"partyMemberProximity",.15)
				addPoints(member,fractionToAdd,0)
			end
		end
	end

	updateLeaderstats(plr)
	return pointsToAdd,xpToAdd,multiplier,rawpts
end
function script.Parent.DualAdd.OnInvoke(plr,pts,xp)
	return dualAdd(plr,pts,xp)
end
game.ReplicatedStorage.Parkour.OnServerEvent:connect(function(sourceplr,action,data,metatitleToPassToClient)
	if shared.dunces[sourceplr.Name] then return 0,0,0,0 end
	--print("parkour")
	local function failSanity(valueName,value,saneValue)
		flagPlayer(sourceplr,"causing Parkour remote to fail sanity check for "..valueName.." ("..value.." compared to "..saneValue..")",true)
	end
	data = data or {}
	action = cryptModule.crypt(action,cryptKey,true)
	local newData = {}
	for i,v in pairs(data) do
		local d = cryptModule.crypt(tostring(v),cryptKey,true)
		if tonumber(d) then d = tonumber(d) elseif d == "true" then d = true elseif d == "false" then d = false end
		local targetKey = cryptModule.crypt(i,cryptKey,true)
		newData[targetKey] = d
	end
	data = newData
	local maxValues = {
		combo = 5,
		wallrunDist = 100,
		msBonus = 12,
		fallSpeed = 210,
		exhaustBonus = 4,
		velocity = 260,
	}
	for i,v in pairs(maxValues) do if data[i] and data[i] > v then failSanity(i,data[i],v) end data[i] = data[i] and math.min(data[i],v) or 0 end
	local values = {
		vault = 12,
		slide = 18,
		ledgegrab = 10,
		dropdown = 20,
		longjump = 24,
		walljump = 16*data.msBonus,
		wallrun = .8*data.wallrunDist,
		springboard = 12,
		landing = 0,
		edgejump = 8*(1+(data.velocity/100)^4),
	}
	local comboMultipliers = shared.env.comboMultipliers
	if data.perfectLand and action ~= "landing" then failSanity("perfectLand","action is "..action,"landing") end
	table.insert(recentmoves[sourceplr],action)
	cwrap(function() local st = tick() repeat runService.Heartbeat:wait() until tick()-st > 10 or not recentmoves[sourceplr] if recentmoves[sourceplr] then table.remove(recentmoves[sourceplr],1) end end)
	local points = values[action] or 0
	if action == "landing" then
		data.landingMult = math.max(data.landingMult,0)
		points = ((data.fallSpeed+(data.didDropDown and 30 or 0))/math.max(data.landingMult,.35))/5
		if data.landingMult == 0 then
			if data.perfectLand then
				points = points * 2.5
			else
				points = points * 1.75
			end
		end
		if data.exhaustBonus then
			--print("exhaust")
			points += 3.5^data.exhaustBonus
		end
		if points < 10 then points = 0 end
		if data.cushioned or data.wasDampened then points = points / 3 end
	end
	local xp = points
	local base = points
	points = points * comboMultipliers[data.combo]
	local added,addedxp = dualAdd(sourceplr,math.ceil(points),math.ceil(xp))
	recentearned[sourceplr] = recentearned[sourceplr] + base
	cwrap(function() wait(10) if sourceplr and recentearned[sourceplr] then recentearned[sourceplr] = recentearned[sourceplr] - base end end)
	local currecentearned = recentearned[sourceplr]
	local samemoves = {}
	if currecentearned > 1800 then
		cwrap(function()
			local lowestTime = math.huge
			local movelist = ""
			for i,v in pairs(recentmoves[sourceplr]) do
				movelist = movelist .. v .. ", "
				samemoves[v] = samemoves[v] and samemoves[v]+1 or 1
				if samemoves[v] > 20 then
					flagPlayer(sourceplr,"doing too many of the same move too quickly")
				end
			end
			movelist = string.sub(movelist,1,#movelist-2)
			discord:SubmitMessage("rawpoints",sourceplr.Name.." has earned ".. math.floor(currecentearned) .." raw points in the last 10 seconds! Movelist: ".. movelist)
		end)
	end
	if currecentearned > 10000 then dunce(true,sourceplr.userId,"earning too many points too quickly") end
	playerSessionMults[sourceplr].timer = tick()
	script.Parent.MissionTrigger:Fire(sourceplr,"parkour")
	script.Parent.MissionTrigger:Fire(sourceplr,action)
	game.ReplicatedStorage.Parkour:FireClient(sourceplr,added,addedxp,base,metatitleToPassToClient)
	--print("endparkour")
end)
game.ReplicatedStorage.SetRadioID.OnServerEvent:connect(function(sourceplr,soundobj,text)
	if not hasPass(sourceplr,1031507704) or soundobj.Parent.Name ~= "Radio" or not soundobj:IsDescendantOf(sourceplr.Character) then return end
	local id = text
	local lower = string.lower(text)
	for i,v in pairs(builtInAudio) do for u,c in pairs(v.words) do if lower == c then id = v.id break end end end
	soundobj.SoundId = id and "rbxassetid://"..id or ""
end)
game.ReplicatedStorage.SetRadioPlaying.OnServerEvent:connect(function(sourceplr,soundobj,playing)
	if not hasPass(sourceplr,1031507704) or soundobj.Parent.Name ~= "Radio" or not soundobj:IsDescendantOf(sourceplr.Character) then return end
	if playing then local tp = soundobj.TimePosition soundobj:Play() soundobj.TimePosition = tp else soundobj:Stop() end
end)
game.ReplicatedStorage.PauseRadio.OnServerEvent:connect(function(sourceplr,soundobj)
	if not hasPass(sourceplr,1031507704) or soundobj.Parent.Name ~= "Radio" or not soundobj:IsDescendantOf(sourceplr.Character) then return end
	soundobj:Pause()
end)
game.ReplicatedStorage.Seek.OnServerEvent:connect(function(sourceplr,soundobj,delta)
	if not hasPass(sourceplr,1031507704) or soundobj.Parent.Name ~= "Radio"or not soundobj:IsDescendantOf(sourceplr.Character)  then return end
	soundobj.TimePosition = soundobj.TimeLength*delta
end)
game.ReplicatedStorage.SetVolume.OnServerEvent:connect(function(sourceplr,soundobj,delta)
	if not hasPass(sourceplr,1031507704) or soundobj.Parent.Name ~= "Radio" or not soundobj:IsDescendantOf(sourceplr.Character) then return end
	local adminLevel = getAdminLevel(sourceplr)
	soundobj.Volume = math.clamp(delta,0,adminLevel >= 6 and 10 or 1)
	soundobj.Distortion.Level = adminLevel >= 6 and math.clamp(delta-9,0,1) or 0
end)
game.ReplicatedStorage.SetEffect.OnServerEvent:connect(function(sourceplr,soundobj,effect,val)
	if not hasPass(sourceplr,1031507704) or soundobj.Parent.Name ~= "Radio" or not soundobj:IsDescendantOf(sourceplr.Character) then return end
	if effect == "PlaybackSpeed" then
		soundobj.PlaybackSpeed = val
	elseif effect == "Pitch" then
		soundobj.PitchEffect.Enabled = true
		soundobj.PitchEffect.Octave = val
	elseif effect == "Chorus" then
		soundobj.Chorus.Enabled = true
		soundobj.Chorus.Mix = val
	elseif effect == "Reverb" then
		soundobj.Reverb.Enabled = true
		soundobj.Reverb.DecayTime = val
		if val < .1 then soundobj.Reverb.Enabled = false end
	elseif effect == "Echo" then
		soundobj.Echo.Enabled = true
		soundobj.Echo.Delay = val
		if val < .01 then soundobj.Echo.Enabled = false end
	elseif effect == "Looped" then
		soundobj.Looped = val
	end
end)
game.ReplicatedStorage:WaitForChild("UpdateKeybind").OnServerEvent:connect(function(sourceplr,id,key)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if plrData and plrData:FindFirstChild("Settings") and plrData.Settings:FindFirstChild("Keybinds") then
		local target = ((string.sub(tostring(key),1,18) == "Enum.UserInputType") and string.sub(tostring(key),20) or string.sub(tostring(key),14))
		for i,v in pairs(plrData.Settings.Keybinds:GetChildren()) do
			if v.Value == target and not ((v.Name == "E" or id == "E") and (v.Name == "UseLeftArm" or id == "UseLeftArm")) then
				v.Value = "None"
				game.ReplicatedStorage.PopupMessage:FireClient(sourceplr,"A keybind has been overwritten")
			end
		end
		plrData.Settings.Keybinds[id].Value = target
	end
end)
game.ReplicatedStorage:WaitForChild("ResetKeybinds").OnServerEvent:connect(function(sourceplr)
	--[[local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if plrData and plrData:FindFirstChild("Keybinds") then
		for name,default in pairs(defaultKeybinds) do
			plrData.Keybinds[name].Value = default
		end
	end]]
end)
game.ReplicatedStorage:WaitForChild("CompletedAdvancedTutorial").OnServerEvent:connect(function(sourceplr)
	if not shared.hasBadge(sourceplr.userId,1084213394) and not shared.disablesaving then
		awardBadge(sourceplr,1084213394)
		game.ReplicatedStorage.BottomMessage:FireClient(sourceplr,{text="GEAR UNLOCKED: MASTER GLOVE",strokeTransparency=.8,colour=Color3.new(0,1,.2)})
	end
end)
game.ReplicatedStorage:WaitForChild("SetCrouching").OnServerEvent:connect(function(sourceplr,crouching)
	local char = sourceplr.Character
	if char and char:FindFirstChild("Humanoid") then
		local x = crouching and 0 or origDisplayDistance
		char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
		char.Humanoid.HealthDisplayDistance = x
		char.Humanoid.NameDisplayDistance = x
	end
end)
function game.ReplicatedStorage.Reset.OnServerInvoke(sourceplr)
	local generic = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name):FindFirstChild("Generic")
	if not (generic and generic:FindFirstChild("Level") and generic:FindFirstChild("Experience") and generic:FindFirstChild("Points")) or plrsResetting[sourceplr] or generic.Points.Value < 10000 then return end
	plrsResetting[sourceplr] = true
	local pts = generic.Points
	local xpToGive = shared.env.turnInMath(pts.Value)
	if pts.Value >= 10000000 then discord:SubmitMessage("levels",sourceplr.Name.." turned in *".. commaValue(pts.Value) .."* points") end
	pts.Value = 0
	local level,xp = generic.Level,generic.Experience
	if not (shared.disablesaving or shared.dunces[sourceplr.Name]) then dataStore:SetAsync(sourceplr.userId..".parkour_points",0) end
	if xpToGive < 0 then xpToGive = 999999999999999 end
	xp.Value = xp.Value + xpToGive
	game.ReplicatedStorage.ClientPopup:FireClient(sourceplr,{text="+".. commaValue(xpToGive) .." XP",colour=Color3.new(1,1,1),randompos=true,fontSize=36,strokeColour=Color3.fromRGB(170,255,255),strokeTransparency=.8,speed=.5})
	plrsResetting[sourceplr] = false
	cwrap(function() updateLevel(sourceplr) end)
	cwrap(function() updateLeaderstats(sourceplr) end)
end
game.ReplicatedStorage:WaitForChild("ResetLevel").OnServerEvent:connect(function(sourceplr)
	local localData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	local generic = localData:FindFirstChild("Generic")
	local stats = localData:FindFirstChild("Stats")
	if not generic then return end
	generic.Level.Value = 0
	generic.Experience.Value = 0
	generic.Points.Value = 0
	stats.Resets.Value += 1
	updateLeaderstats(sourceplr)
end)
game.ReplicatedStorage:WaitForChild("TechTRemote").OnServerEvent:connect(function(sourceplr,cf)
	if sourceplr.userId == 8547230 then
		local x = game.ReplicatedStorage.TechT:Clone()
		x.Parent = workspace.RaycastIgnore
		x.CFrame = cf
		game.Debris:AddItem(x,240)
	end
end)
game.ReplicatedStorage.ReplicateDoorBust.OnServerEvent:connect(function(sourceplr,door,direction)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= sourceplr then
			game.ReplicatedStorage.ReplicateDoorBust:FireClient(v,door,direction)
		end
	end
end)
function game.ReplicatedStorage.UpdateHealth.OnServerInvoke(sourceplr,hp)
	local char = sourceplr.Character
	if char then
		if not char:FindFirstChild("ClientHealth") then
			local x = Instance.new("NumberValue",char)
			x.Name = "ClientHealth"
		end
		char.ClientHealth.Value = hp
	end
end
game.ReplicatedStorage.UpdateHeadTilt.OnServerEvent:connect(function(sourceplr,tilt)
	local char = sourceplr.Character
	if char then
		if not char:FindFirstChild("ClientTilt") then
			local x = Instance.new("Vector3Value",char)
			x.Name = "ClientTilt"
		end
		char.ClientTilt.Value = tilt
	end
end)
game.ReplicatedStorage.UpdateGrappler.OnServerEvent:connect(function(sourceplr,...)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= sourceplr then
			game.ReplicatedStorage.UpdateGrappler:FireClient(v,...)
		end
	end
end)
--reworked light script w/ clamping
game.Players.PlayerAdded:Connect(function(p)
	local st = tick()
	local gc = game.ReplicatedStorage.PlayerData:WaitForChild(p.Name):WaitForChild("Settings"):WaitForChild("CustomGloveColour")
	local precol = gc.Value
	repeat wait(1) until precol ~= gc.Value or tick()-st > 5
	local function clampcol(col)
		return Color3.new(math.clamp(col.R,0,1),math.clamp(col.G,0,1),math.clamp(col.B,0,1))
	end
	local function addlight(c)
		local hrp = c:WaitForChild("HumanoidRootPart")
		local l = game.ReplicatedStorage.Light:Clone()
		l.Color = gc.Value
		l.Parent = hrp
	end
	gc.Value = clampcol(gc.Value)
	addlight(p.Character or p.CharacterAdded:Wait())
	p.CharacterAdded:Connect(function(c)
		addlight(c)
	end)
	gc:GetPropertyChangedSignal("Value"):Connect(function()
		gc.Value = clampcol(gc.Value)
		if p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp and hrp:FindFirstChild("Light") then
				hrp.Light.Color = gc.Value
			end
		end
	end)
end)
--[[function game.ReplicatedStorage.UpdateLight.OnServerInvoke(sourceplr,enabled,BANBANBANBANBAN)
	if BANBANBANBANBAN then flagPlayer(sourceplr," trying to change their light colour via exploits",true) end
	local char = sourceplr.Character
	spawn(function()
		local colour = game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name):WaitForChild("Settings"):WaitForChild("CustomGloveColour").Value
		char.HumanoidRootPart.Light.Color = colour]]
game.ServerScriptService.UpdatePlayerMsData.Event:connect(function(plr,data)
	playerMsData[plr] = data
end)
function game.ServerScriptService.GetPlayerMsData.OnInvoke(plr) return playerMsData[plr] end
function game.ReplicatedStorage.InsertTrail.OnServerInvoke(sourceplr)
	local char = sourceplr.Character
	local lta1 = Instance.new("Attachment",char:WaitForChild("Left Arm"))
	local lta2 = Instance.new("Attachment",char:WaitForChild("Left Arm"))
	lta1.Position = Vector3.new(-.1,-.9,0)
	lta2.Position = Vector3.new(.1,-.9,0)
	local leftTrail = script.Trail:Clone()
	leftTrail.Enabled = false
	leftTrail.Parent = char["Left Arm"]
	leftTrail.Attachment0 = lta1
	leftTrail.Attachment1 = lta2
	local rta1 = Instance.new("Attachment",char:WaitForChild("Right Arm"))
	local rta2 = Instance.new("Attachment",char:WaitForChild("Right Arm"))
	rta1.Position = Vector3.new(-.1,-.9,0)
	rta2.Position = Vector3.new(.1,-.9,0)
	local rightTrail = script.Trail:Clone()
	rightTrail.Enabled = false
	rightTrail.Parent = char["Right Arm"]
	rightTrail.Attachment0 = rta1
	rightTrail.Attachment1 = rta2
	local fta1 = Instance.new("Attachment",char:WaitForChild("Torso"))
	local fta2 = Instance.new("Attachment",char:WaitForChild("Torso"))
	fta1.Position = Vector3.new(0,.75,0)
	fta2.Position = Vector3.new(0,-.75,0)
	local flowTrail = script.Flow:Clone()
	flowTrail.Enabled = false
	flowTrail.Parent = char.Torso
	flowTrail.Attachment0 = fta1
	flowTrail.Attachment1 = fta2
	return leftTrail,rightTrail,flowTrail
end
local trails = {
	{colour=Color3.new(1,0,0),light=1,lifetime=.2},
	{colour=Color3.new(0,1,0),light=1,lifetime=.2},
	{colour=Color3.new(0,1,1),light=1,lifetime=.5},
	{colour=Color3.new(1,1,0),light=1,lifetime=1},
}
game.ReplicatedStorage.SetTrail.OnServerEvent:connect(function(sourceplr,isFlow,bool,styleIndex,ban,ban2)
	local char = sourceplr.Character
	if not isFlow then
		if ban or ban2 or typeof(styleIndex) == "Color3" then
			flagPlayer(sourceplr,"unrecognized colour variables",true)
			--dunce(true,sourceplr.userId,"combo wackyness")
		end

		local leftTrail = char:FindFirstChild("Left Arm") and char["Left Arm"]:FindFirstChild("Trail")
		local rightTrail = char:FindFirstChild("Right Arm") and char["Right Arm"]:FindFirstChild("Trail")

		leftTrail.Enabled = bool or false
		rightTrail.Enabled = bool or false

		local data = trails[styleIndex] or {colour=Color3.new(1,1,1),light=0,lifetime=1}

		leftTrail.Color = ColorSequence.new(data.colour)
		rightTrail.Color = ColorSequence.new(data.colour)

		leftTrail.LightEmission = data.light
		rightTrail.LightEmission = data.light

		leftTrail.Lifetime = data.lifetime
		rightTrail.Lifetime = data.lifetime
	else
		local flow = char:FindFirstChild("Torso") and char.Torso:FindFirstChild("Flow")
		flow.Enabled = bool or false
	end
end)
function playOnOtherClients(sourceplr,...)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= sourceplr then
			game.ReplicatedStorage.PlayCharacterSound:FireClient(v,sourceplr,...)
		end
	end
end
function stopOnOtherClients(sourceplr,...)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= sourceplr then
			game.ReplicatedStorage.StopCharacterSound:FireClient(v,sourceplr,...)
		end
	end
end
game.ReplicatedStorage.PlayCharacterSound.OnServerEvent:connect(function(sourceplr,...) playOnOtherClients(sourceplr,...) end)
game.ReplicatedStorage.StopCharacterSound.OnServerEvent:connect(function(sourceplr,...) stopOnOtherClients(sourceplr,...) end)
game.ReplicatedStorage.PlayStepSound.OnServerEvent:connect(function(sourceplr,...) playOnOtherClients(sourceplr,...) end)
game.ReplicatedStorage.GrappleSoundEffect.OnServerEvent:connect(function(sourceplr,position)
	local x = Instance.new("Part",workspace.RaycastIgnore)
	x.Size = Vector3.new()
	x.CFrame = CFrame.new(position)
	x.Transparency = 1
	x.CanCollide = false
	x.Anchored = true
	local sound = game.ReplicatedStorage.SoundEffects["GrappleImpact"..math.random(1,2)]:Clone()
	sound.Parent = x 
	sound:Play()
	game.Debris:AddItem(x,sound.TimeLength)
end)
function game.ReplicatedStorage.GetSkins.OnServerInvoke(sourceplr)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if not plrData then return end
	local pskins = {}
	for i,v in pairs(plrData.Inventory.Skins:GetChildren()) do
		local skin = game.ServerStorage.SkinStorage:FindFirstChild(v.Name,true)
		if skin then
			if not pskins[v.Name] then
				pskins[v.Name] = getSkinData(skin)
			end
			pskins[v.Name].num = v.Value
		else
			warn("Cannot find skin " .. v.Name)
		end
	end
	return pskins
end
function game.ReplicatedStorage.GetCases.OnServerInvoke(sourceplr)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if not plrData then return end
	local cases = plrData:WaitForChild("Inventory"):WaitForChild("Bags")
	local pcases = {}
	for i,v in pairs(cases:GetChildren()) do
		for u = 1,v.Value do
			table.insert(pcases,v.Name)
		end
	end
	return pcases
end
local faces = {Enum.NormalId.Front,Enum.NormalId.Back,Enum.NormalId.Left,Enum.NormalId.Right,Enum.NormalId.Top,Enum.NormalId.Bottom}
function equipSkin(sourceplr,skinName,model,target)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if not plrData then return end
	game.ReplicatedStorage.UpdateEquippedSkin:FireClient(sourceplr,skinName,target)
	local skin = plrData.Inventory.Skins:FindFirstChild(skinName)
	local intSkin = game.ServerStorage.SkinStorage:FindFirstChild(skinName,true)
	if skin and model and intSkin and skin.Value > 0 then
		plrData.Generic.EquippedSkins[target].Value = skinName
		local toApply = model[target]
		toApply.Reflectance = 0
		toApply.Transparency = 0
		for i,v in pairs(toApply:GetChildren()) do if v:IsA("Texture") or v:IsA("Decal") then v:destroy() end end
		for i,v in pairs(intSkin:GetChildren()) do
			pcall(function() toApply[v.Name] = v.Value end)
			local textureSize = (intSkin:FindFirstChild("Texture") and intSkin.Texture:FindFirstChild("Size")) and intSkin.Texture.Size.Value or 2
			if v.Name == "Texture" then
				local colour = v:FindFirstChild("Colour") and v.Colour.Value or Color3.new(1,1,1)
				for u,c in pairs(faces) do
					local tx = Instance.new("Texture",toApply)
					tx.Texture = v.Value
					tx.Face = c
					tx.StudsPerTileU = textureSize
					tx.StudsPerTileV = textureSize
					tx.Color3 = colour
				end
			elseif v.Name == "Decal" then
				local colour = v:FindFirstChild("DecalColour") and v.DecalColour.Value or Color3.new(1,1,1)
				for u,c in pairs(faces) do
					local tx = Instance.new("Decal",toApply)
					tx.Texture = v.Value
					tx.Face = c
					tx.Color3 = colour
				end
			elseif v.Name == "Animated" then
				local animid = v.Value
				local decals = {}
				for u,c in pairs(faces) do
					local tx = Instance.new("Decal",toApply)
					tx.Face = c
					table.insert(decals,tx)
				end
				game.ReplicatedStorage.ReplicateAnimatedSkin:FireAllClients(animid,decals)
			end
		end
	elseif (not skin or skin.Value <= 0) and skinName ~= "" then
		warn(sourceplr,"does not own skin",skinName)
		plrData.Generic.EquippedSkins[target].Value = ""
	end
end
function game.ReplicatedStorage.EquipSkin.OnServerInvoke(...)
	equipSkin(...)
end
function game.ReplicatedStorage.DequipSkins.OnServerInvoke(sourceplr)
	local generic = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name):FindFirstChild("Generic")
	generic.EquippedSkins.Primary.Value = ""
	generic.EquippedSkins.Secondary.Value = ""
	game.ReplicatedStorage.UpdateEquippedSkin:FireClient(sourceplr,"","Primary")
	game.ReplicatedStorage.UpdateEquippedSkin:FireClient(sourceplr,"","Secondary")
	local model,default
	for i,v in pairs(sourceplr.Character["Left Arm"]:GetConnectedParts()) do
		if v.Parent.Parent == sourceplr.Character or v.Parent.Parent == workspace.RaycastIgnore then
			model = v.Parent
			default = game.ReplicatedStorage.Gear[model.Name].GearModel
			break
		end
	end
	if model and default then
		model.Primary.Reflectance = default.Primary.Reflectance
		model.Primary.Transparency = default.Primary.Transparency
		model.Primary:ClearAllChildren()
		model.Primary.Color = default.Primary.Color
		model.Primary.Material = default.Primary.Material
		model.Secondary.Reflectance = default.Secondary.Reflectance
		model.Secondary.Transparency = default.Secondary.Transparency
		model.Secondary:ClearAllChildren()
		model.Secondary.Color = default.Secondary.Color
		model.Secondary.Material = default.Secondary.Material
	end
end
function setBagType(bag,name)
	if name == "Common" then
		bag.Main.Color = Color3.fromRGB(86,36,36)
		bag.Side.Transparency = 1
	elseif name == "Uncommon" then
		bag.Main.Color = Color3.new(0,1,0)
		bag.Side.Transparency = 1
	elseif name == "Rare" then
		bag.Main.Color = Color3.new(.5,0,1)
		bag.Side.Transparency = 1
	elseif name == "Epic" then
		bag.Main.Color = Color3.new(0,1,1)
		bag.Side.Transparency = 1
	elseif name == "Legendary" then
		bag.Main.Color = Color3.new(1,.96,.47)
		bag.Side.Color = Color3.new(1,1,0)
		bag.Side.Transparency = 0
	elseif name == "Ultimate" then
		bag.Main.Color = Color3.new()
		bag.Side.Color = Color3.new(1,0,0)
		bag.Side.Transparency = 0
	elseif name == "Resplendent" then
		bag.Main.Color = Color3.new()
		bag.Side.Color = Color3.new(1,1,1)
		local connection
		local function replicate()
			game.ReplicatedStorage.ReplicateRGBPart:FireAllClients(bag.Side)
			connection:disconnect()
		end
		connection = bag.Changed:connect(function()
			if bag:IsDescendantOf(workspace) then
				replicate()
			end
		end)
		bag.Side.Transparency = 0
	end
	bag.Rarity.Value = name
end
function script.Parent.AddSkinToId.OnInvoke(player,name)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(player.Name)
	if not plrData then return end
	local skin = plrData.Inventory:WaitForChild("Skins"):FindFirstChild(name)
	if not skin then
		skin = Instance.new("IntValue")
		skin.Name = name
		skin.Parent = plrData.Inventory.Skins
	end
	skin.Value += 1
end
function script.Parent.AddCaseToId.OnInvoke(player,name)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(player.Name)
	if not plrData then return end
	local bag = plrData.Inventory:WaitForChild("Bags")[name]
	bag.Value = bag.Value + 1
	game.ReplicatedStorage.GotCase:FireClient(player,name)
end
game.ServerScriptService:WaitForChild("SpawnCase").Event:connect(function(name,cf)
	local bag
	if name == "Halloween" then
		bag = game.ServerStorage.HalloweenBag:Clone()
	elseif name == "Christmas" then
		bag = game.ServerStorage.ChristmasBag:Clone()
	elseif name == "Limited" then
		bag = game.ServerStorage.MilBag:Clone()
	else
		bag = game.ServerStorage.SkinBag:Clone()
		setBagType(bag,name)
	end
	bag.Parent = workspace
	bag:SetPrimaryPartCFrame(cf)
	bag.Dropped.Value = true
	local touchScript = script.BagTouchScript:Clone()
	touchScript.Parent = bag
	touchScript.Disabled = false
	table.insert(shared.skinBags,bag)
end)
script.Parent.GiveChips.Event:connect(function(plr,amount)
	local plrData = game:GetService("ReplicatedStorage"):WaitForChild("PlayerData"):WaitForChild(plr.Name)
	plrData.Generic.HackData.Chips.Value += amount
	if amount > 0 then game.ReplicatedStorage.ClientPopup:FireClient(plr,{text=("+".. amount.." BACKDOOR CHIPS"),colour=Color3.new(0,1,1),fontSize=38,speed=.25,position=Vector2.new(0,80)}) end
end)
function game.ReplicatedStorage.ResetSpawn.OnServerInvoke(sourceplr)
	respawnLocations[sourceplr].CFrame = game.Workspace.SpawnLocation.CFrame+Vector3.new(0,3,0)
end
local code = {}
game.ReplicatedStorage.Keypad.OnServerEvent:connect(function(sourceplr,input)
	--[[local data = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if data and input[1] == code[1] and input[2] == code[2] and input[3] == code[3] and input[4] == code[4] and not data.Skins.Left:FindFirstChild("Gemini") then
		wait(math.random())
		local skin = Instance.new("BoolValue",data.Skins.Left)
		skin.Name = "Gemini"
		skin.Value = true
		game.ReplicatedStorage.ClientPopup:FireClient(sourceplr,{text="SKIN ADDED\nGemini",colour=Color3.new(0,0,0),strokeColour=Color3.new(1,1,1),strokeTransparency=0,fontSize=42,speed=.5})
	end]]
end)
shared.lastRankedRespawn = 0
game.ReplicatedStorage.UpdateRespawnPosition.OnServerEvent:connect(function(sourceplr,cf)
	local generic = game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name):WaitForChild("Generic")
	local spawnPos = generic:WaitForChild("SpawnLocation")
	local spawnPart = workspace.RespawnLocations:FindFirstChild(sourceplr.Name.."Spawn")
	if spawnPart and spawnPos and tick()-shared.lastRankedRespawn > 2 then
		print("updated",sourceplr,"spawn location, last ranked respawn:",tick()-shared.lastRankedRespawn)
		spawnPos.Value = cf
		spawnPart.CFrame = cf
	end
end)
function game.ReplicatedStorage.GetLevel.OnServerInvoke(sourceplr)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if not plrData then return end
	return plrData:WaitForChild("Generic"):WaitForChild("Level").Value
end
game.ReplicatedStorage.UpdateSetting.OnServerEvent:connect(function(sourceplr,setting,value)
	local localSettings = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name):WaitForChild("Settings")
	if not localSettings then return end
	if localSettings:FindFirstChild(setting) then
		localSettings[setting].Value = value
		print(setting,"updated to",value)
	else
		warn("could not find",setting)
	end
end)
game.ReplicatedStorage:WaitForChild("GetPlayerSetting")
function game.ReplicatedStorage.GetPlayerSetting.OnServerInvoke(sourceplr,targetplr,setting)
	print(sourceplr,targetplr,setting)
	local localSettings = game.ReplicatedStorage.PlayerData:FindFirstChild(targetplr.Name):WaitForChild("Settings")
	if not localSettings then return end
	if localSettings:FindFirstChild(setting) then
		return localSettings[setting].Value
	else
		warn("could not find",setting)
	end
end
game.ReplicatedStorage.UpdatePlayerGear.OnServerEvent:connect(function(sourceplr,aType,name)
	local runtime = game.ReplicatedStorage.PlayerRuntimeData:FindFirstChild(sourceplr.Name)
	if not runtime then return end
	local usergear = runtime.Gear
	usergear[aType].Value = name
end)
function game.ReplicatedStorage.GetCourseData.OnServerInvoke(sourceplr,model)
	if model then
		local data = {
			points = model:FindFirstChild("CoursePoints") and model.CoursePoints.Value or 0,
			perfectTime = model:FindFirstChild("PerfectTime") and model.PerfectTime.Value or 0,
		}
		return data
	end
end
local hexStopped = false
function game.ReplicatedStorage.OpenCase.OnServerInvoke(sourceplr,bagname)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	local bag
	local plrBags = plrData.Inventory.Bags
	local plrSkins = plrData.Inventory.Skins

	local function rollHigherTier(n)
		local giveNextTierSkin = math.random(1,40) == 1
		if giveNextTierSkin then
			if n == "Ultimate" then n = "Resplendent" end
			if n == "Legendary" then n = "Ultimate" end
			if n == "Epic" then n = "Legendary" end
			if n == "Rare" then n = "Epic" end
			if n == "Uncommon" then n = "Rare" end
			if n == "Common" then n = "Uncommon" end
		end
		return n
	end

	if plrBags:FindFirstChild(bagname) and plrBags[bagname].Value >= 1 then bag = plrBags[bagname] end

	if bag then
		local hasDoubleSkinPass = hasPass(sourceplr,11812855)
		bag.Value = math.max(0,bag.Value-1)
		local function getSkin(rarity)
			local intSkins = game.ServerStorage.SkinStorage[rarity]:GetChildren()
			local skinGet = intSkins[math.random(math.min(#intSkins,1),#intSkins)]
			if rarity == "Resplendent" then
				local hasAll = true
				for i,v in pairs(intSkins) do if not plrSkins:FindFirstChild(v.Name,true) then hasAll = false break end end
				if not hasAll then
					repeat
						skinGet = intSkins[math.random(math.min(#intSkins,1),#intSkins)]
					until not plrSkins:FindFirstChild(skinGet.Name,true)
				end
			end
			return skinGet
		end
		if hasDoubleSkinPass then
			local skin = getSkin(rollHigherTier(bagname))
			local skin2 = getSkin(rollHigherTier(bagname))
			shared.partyLog(sourceplr,sourceplr.Name.." opened a "..bagname.." case and got "..skin.Name.." and "..skin2.Name)
			script.Parent.AddSkinToId:Invoke(sourceplr,skin.Name)
			script.Parent.AddSkinToId:Invoke(sourceplr,skin2.Name)
			local sd = getSkinData(skin)
			local sd2 = getSkinData(skin2)
			return sd,sd2
		else
			local skin = getSkin(rollHigherTier(bagname))
			shared.partyLog(sourceplr,sourceplr.Name.." opened a "..bagname.." case and got "..skin.Name)
			script.Parent.AddSkinToId:Invoke(sourceplr,skin.Name)
			local sd = getSkinData(skin)
			return sd
		end
	end
end
function game.ReplicatedStorage.TradeInSkins.OnServerInvoke(sourceplr,skinname)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	local targetskin = game.ServerStorage.SkinStorage:FindFirstChild(skinname,true)
	if skinname and targetskin then
		local okay
		local num = 0
		local skinrarity = targetskin.Parent.Name
		for i,v in pairs(plrData.Inventory.Skins:GetChildren()) do
			if v.Name == skinname and v.Value >= 2 then okay = true break end
		end
		if okay and skinrarity ~= "Limited" and skinrarity ~= "Unavailable" then
			plrData.Inventory.Skins[skinname].Value -= 2
			local skins = game.ServerStorage.SkinStorage[skinrarity]:GetChildren()
			local skinGet
			local repeats = 0
			repeat
				repeats = repeats + 1
				skinGet = skins[math.random(math.min(#skins,1),#skins)]
			until skinGet.Name ~= skinname or repeats > 100
			script.Parent.AddSkinToId:Invoke(sourceplr,skinGet.Name)
			local sd = getSkinData(skinGet)
			return sd
		elseif not okay and (skinrarity == "Limited" or skinrarity == "Unavailable") then
			game.ReplicatedStorage.ClientPopup:FireClient(sourceplr,{text="Cannot trade in this skin rarity!",colour=Color3.new(1,0,0)})
		end
	end
end

game.ReplicatedStorage.SybariticRGB.OnServerEvent:connect(function(sourceplr,model,customColour)
	model = sourceplr.Character and (sourceplr.Character:FindFirstChild("SybariticGlove") or sourceplr.Character:FindFirstChild("JustynGlove") or sourceplr.Character:FindFirstChild("JodieGlove"))
	if model then
		model.OriginalCustomColour.Value = customColour
		model.RGB.Value = not model.RGB.Value
		if sourceplr.userId == 22402288 or sourceplr.userId == 18205436 then
			game.ReplicatedStorage.BubbleColours:WaitForChild(sourceplr.Name).RGB.Value = model.RGB.Value
		end
		if model.RGB.Value then
			local breakCheck = Instance.new("Folder",model)
			breakCheck.Name = "BreakCheck"
			game.ReplicatedStorage.SybariticRGB:FireAllClients(model,breakCheck)
		else
			if model:FindFirstChild("BreakCheck") then model.BreakCheck:destroy() end
		end
	end
end)
game.ReplicatedStorage.ArkTransform.OnServerEvent:connect(function(sourceplr,model,bool)
	if (sourceplr.userId == 16871475 or sourceplr.userId == 18205436) and model.Name == "ArkGlove" then
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= sourceplr then
				game.ReplicatedStorage.ArkTransform:FireClient(v,model,bool)
			end
		end
	end
end)
game.ReplicatedStorage.JustynTransform.OnServerEvent:connect(function(sourceplr,model,bool)
	if (sourceplr.userId == 22402288 or sourceplr.userId == 18205436) and model.Name == "JustynGlove" then
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= sourceplr then
				game.ReplicatedStorage.JustynTransform:FireClient(v,model,bool)
				local paragear = sourceplr.Character:FindFirstChild("Paraglider")
				if paragear then
					for i,v in pairs(paragear:GetChildren()) do
						if v.Name ~= "Main" and v:IsA("BasePart") then
							if v.Name == "Sword" then
								v.Transparency = bool and 1 or 0
							end
						end
					end
				end
			end
		end
	end
end)
game.ReplicatedStorage.BluTransform.OnServerEvent:connect(function(sourceplr,model,bool)
	if (sourceplr.userId == 88328415 or sourceplr.userId == 18205436) and model.Name == "BluGlove" then
		local bluparticle1 = game.ReplicatedStorage.BluParticle1:Clone()
		local bluparticle2 = game.ReplicatedStorage.BluParticle2:Clone()
		bluparticle1.Parent = sourceplr.Character["Right Arm"]
		bluparticle1:Emit(30)
		bluparticle2.Parent = sourceplr.Character["Right Arm"]
		bluparticle2:Emit(120)
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= sourceplr then
				game.ReplicatedStorage.BluTransform:FireClient(v,model,bool)
			end
		end
	end
end)
function game.ReplicatedStorage.HasPass.OnServerInvoke(sourceplr,id)
	return hasPass(sourceplr,id)
end
function game.ReplicatedStorage.HasBadge.OnServerInvoke(sourceplr,id)
	return hasBadge(sourceplr,id)
end
function game.ServerScriptService.HasPass.OnInvoke(sourceplr,id)
	return hasPass(sourceplr,id)
end
function game.ServerScriptService.HasBadge.OnInvoke(sourceplr,id)
	return hasBadge(sourceplr,id)
end
game.ReplicatedStorage:WaitForChild("Submit")
function game.ReplicatedStorage.Submit.OnServerInvoke(sourceplr,trialId,runtime,max,replaydata)
	if ((shared.disablesaving or shared.dunces[sourceplr.Name])) then return end
	local function replayToJSONCompatible(r)
		local newReplay = {}
		local function roundNumber(n)
			return math.floor(n*100)
		end
		local function componentsToTable(pos,rX,rY,rZ)
			local t = {
				x=roundNumber(pos.X),
				y=roundNumber(pos.Y),
				z=roundNumber(pos.Z),
				a=roundNumber(rX),
				b=roundNumber(rY),
				c=roundNumber(rZ)
			}
			return t
		end
		for i,v in pairs(r) do
			newReplay[i] = {
				a=componentsToTable(v.cframe.p,v.cframe:ToEulerAnglesXYZ()),
				b=componentsToTable(v.tcf.p,v.tcf:ToEulerAnglesXYZ()),
				c=componentsToTable(v.lacf.p,v.lacf:ToEulerAnglesXYZ()),
				d=componentsToTable(v.racf.p,v.racf:ToEulerAnglesXYZ()),
				e=componentsToTable(v.llcf.p,v.llcf:ToEulerAnglesXYZ()),
				f=componentsToTable(v.rlcf.p,v.rlcf:ToEulerAnglesXYZ()),
				t=roundNumber(v.timedelay*10)
			}
		end
		return newReplay
	end
	local submittedTime = tonumber(cryptModule.crypt(tostring(runtime),cryptKey,true))
	if submittedTime < 3 then dunce(true,sourceplr.userId,"getting under 3 seconds in a time trial") return end
	local trial = nil
	for i,v in pairs(workspace.TimeTrials:GetChildren()) do
		if v.ID.Value == trialId then
			trial = v 
			break
		end
	end
	local replay = replayToJSONCompatible(replaydata)
	local localData = game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name)
	local newCompletion = localData.PersonalBests[trialId].Value == 0
	local newGoldCompletion = (localData.PersonalBests[trialId].Value >= trial.PerfectTime.Value/2 or newCompletion) and submittedTime<trial.PerfectTime.Value/2
	--local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	spawn(function()
		if submittedTime and sourceplr.Character and sourceplr.Character.Humanoid.Health > 0 then
			script.Parent.MissionTrigger:Fire(sourceplr,"completetrial",trialId,submittedTime,trial.PerfectTime.Value)

			local plrId = tostring(sourceplr.userId)

			local formattedTime = math.floor(submittedTime*10000)/10000
			local newRecord = false

			--[[if didGetTop and plrData.Playtime.Value < 172800 then
				dunce(true,sourceplr.userId,"getting a top time on a time trial illegitimately")
			end]]

			local url = shared.getUrl("timeTrials")

			local oldRecord = shared.request(
				url,
				"GET",
				{UID=plrId,TimeTrial=trialId,Replay=0}
			)

			oldRecord = oldRecord and http:JSONDecode(oldRecord)

			if not oldRecord or not oldRecord.Time or oldRecord.Time < formattedTime then
				localData.PersonalBests[trialId].Value = formattedTime
				shared.request(
					url,
					"PUT",
					{UID=plrId,TimeTrial=trialId},
					http:JSONEncode({Time=formattedTime,Replay=replay})
				)
			end


			shared.updateTrialLeaderboard(trialId)
		end
	end)
	local trial
	for i,v in pairs(workspace.TimeTrials:GetChildren()) do if v.ID.Value == trialId then trial = v break end end
	if trial then
		local pts = trial.CoursePoints.Value*(submittedTime<trial.PerfectTime.Value/2 and 2 or 1)
		if newCompletion then
			pts += trial.CoursePoints.Value*25
			warn("new completed")
		end
		if newGoldCompletion then
			pts += trial.CoursePoints.Value*25
			warn("gold completed")
		end
		return dualAdd(sourceplr,pts,pts/2,true)
	end
	return 0,0,0
end

game.ReplicatedStorage:WaitForChild("SubmitCombo").OnServerEvent:connect(function(sourceplr,c,t)
	if (shared.disablesaving or shared.dunces[sourceplr.Name]) then return end
	local stats = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name) and game.ReplicatedStorage.PlayerData[sourceplr.Name]:FindFirstChild("Stats")
	local averageCombo = stats.TotalCombo.Value/stats.ComboBreaks.Value
	if stats then
		stats.MaxCombo.Value = math.max(math.floor(c),stats.MaxCombo.Value)
		stats.LongestCombo.Value = math.max(math.floor(t),stats.LongestCombo.Value)
		local color = shared.env.comboColours[math.floor(c/100)]
		shared.partyLog(sourceplr,sourceplr.Name .. " lost a Level " .. c/100 .. " combo")
		--if in the new update (after db) people are randomly getting dunced for combo wackyness its these two lines below (proly lol)
		--if averageCombo >= 300 then discord:SubmitMessage("possiblecheatdetection",sourceplr.Name .. " is almost definitely exploiting!") end
		--if stats.LongestCombo.Value < 0 or stats.LongestCombo.Value > 172800 then dunce(true,sourceplr.userId,"combo wackyness") end
		if stats.MaxCombo.Value >= 201 and stats.MaxCombo.Value <= 299 then discord:SubmitMessage("possiblecheatdetection",sourceplr.Name .. " could be combo exploiting! (dont trust this, inspect before ban)") end
		if c >= 200 and c <= 299 and t >= 1800 then
			discord:SubmitMessage("possiblecheatdetection",sourceplr.Name .. " just lost a level 2 combo that lasted for over 20 minutes. how.")
		end
		if c >= 300 then
			local last = shared.LostCombo[sourceplr] or 0
			if tick()-last < 10 and c >= 300 then
				if getAdminLevel(sourceplr) <= 0 then
					flagPlayer(sourceplr,"getting atleast two combos VERY fast")
				end
			end
			shared.LostCombo[sourceplr] = tick()
			discord:SubmitMessage("combo",sourceplr.Name .. " finished a **Level " .. c/100 .. "** combo in *".. math.floor(t/6)/10 .."* minutes")
			game.ReplicatedStorage.SystemMessage:FireAllClients(sourceplr.Name .. " just lost a level " .. c/100 .. " combo that lasted ".. math.floor(t/6)/10 .." minutes!",color)
			if c >= 300 and stats.Playtime.Value < 86400 then
				discord:SubmitMessage("altdetection",sourceplr.Name .. " just got atleast a level 3 combo with under 24 hours played!")
			end
			if c > 500 or t > 100000 or (c > 200 and t < 2) or (c >= 400 and t < 30) or (c >= 500 and t < 120) then
				if getAdminLevel(sourceplr) <= 0 then
					flagPlayer(sourceplr,"impossible combo variables",true)
				end
			end
		end
	else warn("cannot find stats for",sourceplr)
	end
end)
game.ReplicatedStorage.FF.OnServerEvent:connect(function(sourceplr)
	if sourceplr.Character and not sourceplr.Character:FindFirstChildOfClass("ForceField") then flagPlayer(sourceplr,"landing with an unpermitted clientside forcefield",true) end
	dunce(true,sourceplr.userId,"forcefield usage")
end)
game.ReplicatedStorage.LowCombo.OnServerEvent:connect(function(sourceplr)
	if getAdminLevel(sourceplr) <= 0 then discord:SubmitMessage("othercheatdetection",sourceplr.Name .. " got atleast a level 3 combo in less than 20 seconds!")
		dunce(true,sourceplr.userId,"i dont like whats happening")
	else
		discord:SubmitMessage("othercheatdetection",sourceplr.Name .. " got atleast a level 3 combo in less than 20 seconds (as an admin)!")
	end
	if getAdminLevel(sourceplr) <= 0 then flagPlayer(sourceplr,"getting atleast a level 3 combo too quickly",true) end
end)
game.ReplicatedStorage.GiveBag.OnServerEvent:connect(function(sourceplr)
	flagPlayer(sourceplr,"attempting to teleport to a bag")
end)
game.ReplicatedStorage.Respawn.OnServerEvent:connect(function(sourceplr)
	if not game.ReplicatedStorage.HardcoreMode.Value then
		sourceplr:LoadCharacter()
	end
end)
function updateSpectatorCounts()
	local folder = game.ReplicatedStorage.SpectateData
	for i,v in pairs(folder:GetChildren()) do
		if v:FindFirstChild("TotalSpectators") then
			v.TotalSpectators.Value = 0
		end
	end
	for i,v in pairs(folder:GetChildren()) do
		if v:FindFirstChild("Spectating") and v.Spectating.Value and v:FindFirstChild("DoNotCount") and not v.DoNotCount.Value and folder:FindFirstChild(v.Spectating.Value.Name) and folder[v.Spectating.Value.Name]:FindFirstChild("TotalSpectators") then
			folder[v.Spectating.Value.Name].TotalSpectators.Value = folder[v.Spectating.Value.Name].TotalSpectators.Value + 1
		end
	end
end
game.ReplicatedStorage.SpectateData.ChildRemoved:connect(updateSpectatorCounts)
game.ReplicatedStorage.UpdateSpectateData.OnServerEvent:connect(function(sourceplr,index,data)
	local folder = game.ReplicatedStorage.SpectateData
	local spectateData = folder:WaitForChild(sourceplr.Name,5)
	if spectateData then
		if index == "Camera" then
			spectateData.Camera.Value = data
		elseif index == "CameraOffset" then
			spectateData.CameraOffset.Value = data
		elseif index == "Spectating" and (not data or game.Players:FindFirstChild(data.Name)) then
			if data == nil then 
				spectateData.Spectating.Value = nil
			else
				spectateData.Spectating.Value = game.Players[data.Name]
			end
			updateSpectatorCounts()
		end
	end
end)
function game.ReplicatedStorage.GetStats.OnServerInvoke(sourceplr)
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if not (shared.playerMetadata[sourceplr] and shared.playerMetadata[sourceplr].loaded) then repeat wait() until shared.playerMetadata[sourceplr] and shared.playerMetadata[sourceplr].loaded end
	if plrData then
		local ms,entries = shared.env.getAverageNumberFromTable(shared.playerMsData[sourceplr],100)
		local stats = {
			level=plrData.Generic.Level.Value,
			xp=plrData.Generic.Experience.Value,
			deaths=plrData.Stats.Deaths.Value,
			distance=plrData.Stats.DistanceTravelled.Value,
			wallrunDistance=plrData.Stats.WallrunDistance.Value,
			damage=plrData.Stats.DamageTaken.Value,
			landings=plrData.Stats.Landings.Value,
			pflandings=plrData.Stats.PerfectLandings.Value,
			boosts=plrData.Stats.Boosts.Value,
			boostms=(entries>0 and ms or nil),
			playtime=plrData.Stats.Playtime.Value,
			sessionMult=(playerSessionMults[sourceplr] and playerSessionMults[sourceplr].mult or 0)+1,
			maxCombo=plrData.Stats.MaxCombo.Value/100,
			longestCombo=plrData.Stats.LongestCombo.Value,
			totalCombo=plrData.Stats.TotalCombo.Value/100,
			comboBreaks=plrData.Stats.ComboBreaks.Value,
		}
		return stats
	end
end
game.ReplicatedStorage.AddStat.OnServerEvent:connect(function(sourceplr,name,num)
	if (shared.disablesaving or shared.dunces[sourceplr.Name]) then return end
	name = tostring(cryptModule.crypt(tostring(name),cryptKey,true))
	num = tonumber(cryptModule.crypt(tostring(num),cryptKey,true))
	local plrData = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	if not plrData or not plrData:FindFirstChild("Stats") or not num or not name then return end
	--sanity statedit check (could false positive but if someone plays that much they deserve tobe dunced.)
	--who needs tables or anything when u can just copy and paste the line 5 times
	if plrData.Stats.Boosts.Value >= 1000000 and plrData.Stats.Playtime.Value < 3600000 then dunce(true,sourceplr.userId,"suspected stat fraud") end
	if plrData.Stats.PerfectLandings.Value >= 1000000 and plrData.Stats.Playtime.Value < 3600000 then dunce(true,sourceplr.userId,"suspected stat fraud") end
	if plrData.Stats.Landings.Value >= 1000000 and plrData.Stats.Playtime.Value < 3600000 then dunce(true,sourceplr.userId,"suspected stat fraud") end
	if plrData.Stats.TotalCombo.Value/100 >= 1000000 and plrData.Stats.Playtime.Value < 3600000 then dunce(true,sourceplr.userId,"suspected stat fraud") end
	if plrData.Stats.ComboBreaks.Value >= 1000000 and plrData.Stats.Playtime.Value < 3600000 then dunce(true,sourceplr.userId,"suspected stat fraud") end
	if (
		(name == "Landings" or name == "PerfectLandings" or name == "Boosts") and num > 1
		) or (
			name == "DistanceTravelled" and num > 2000
		) or (
			name == "WallrunDistance" and num > 210
		) or (
			name == "BoostMs" and (num < 0 or num > 400)
		) or (
			name == "DamageTaken" and (num < 0 or num > 310)
		) then
		flagPlayer(sourceplr,"causing AddStat remote to fail sanity check",true)
		dunce(true,sourceplr.userId,"suspected stat fraud")
	end
	if name == "BoostMs" and num > 0 and num <= 400 then
		if num < 50  then discord:SubmitMessage("boostms",sourceplr.Name.." boosted **"..num.."**") end
		if num < 5 then
			discord:SubmitMessage("othercheatdetection",sourceplr.Name.." boosted **"..num.."**")
			dunce(true,sourceplr.userId,"suspected stat fraud")
		end
		if num < 50 and plrData.Stats.Playtime.Value < 36000 then discord:SubmitMessage("altdetection",sourceplr.Name.." boosted **"..num.."** with under 10 hours played!") end
		table.insert(shared.playerMsData[sourceplr],1,math.ceil(num))
		while #shared.playerMsData[sourceplr] > 100 do table.remove(shared.playerMsData[sourceplr],#shared.playerMsData[sourceplr]) end
	else
		local stat = plrData.Stats[name]
		stat.Value = math.max(0,stat.Value+num)
	end
	if name == "BoostsTotalMs" then flagPlayer(sourceplr,"attempting to edit stats",true) end
end)
function game.ReplicatedStorage.CreateCustomTimeTrial.OnServerInvoke(sourceplr,startcf,endcf)
	local numTrials = 0
	for i,v in pairs(workspace.TimeTrials:GetChildren()) do
		if v.Name == "PlayerTrial" and v.Owner.Value == sourceplr.Name then
			numTrials = numTrials + 1
		end
	end
	if numTrials < 4 then
		local trial = game.ReplicatedStorage.PlayerTrial:Clone()
		trial.Start.Main.CFrame = startcf
		trial.End.CFrame = endcf
		trial.Parent = workspace.TimeTrials
		trial.Owner.Value = sourceplr.Name
		--[[local beam = game.ReplicatedStorage.TrialBeam:Clone()
		beam.CFrame = trial.Start.Main.CFrame+Vector3.new(0,trial.Start.Main.Size.Y/2,0)
		beam.Color = trial.Start.Main.Color
		beam.Transparency = 1
		beam.Parent = trial]]
		return trial
	else return "Too many custom time trials!"
	end
end
game.ReplicatedStorage:WaitForChild("RemoveCustomTimeTrial").OnServerEvent:connect(function(sourceplr,trial)
	if trial.Parent == workspace.TimeTrials and trial.Name == "PlayerTrial" and trial.Owner.Value == sourceplr.Name then
		trial:destroy()
	end
end)
game.ReplicatedStorage:WaitForChild("RenameCustomTimeTrial").OnServerEvent:connect(function(sourceplr,trial,name)
	if trial.Parent == workspace.TimeTrials and trial.Name == "PlayerTrial" and trial.Owner.Value == sourceplr.Name then
		local text = textService:FilterStringAsync(name,sourceplr.userId)
		for i,v in pairs(game.Players:GetPlayers()) do
			cwrap(function()
				game.ReplicatedStorage.RenameCustomTimeTrial:FireClient(v,trial,text:GetNonChatStringForUserAsync(v.userId))
			end)
		end
	end
end)
function setGearVisuals(sourceplr,aType,customColour,secondaryColour)
	repeat wait() until sourceplr.Character.Parent == workspace
	local runtimeData = game.ReplicatedStorage.PlayerRuntimeData:WaitForChild(sourceplr.Name)
	local localSettings = game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name):WaitForChild("Settings")
	local isNeon = runtimeData:WaitForChild("Gear").glowing.Value
	local model = runtimeData.Gear:FindFirstChild(aType) and runtimeData.Gear[aType].model.Value
	local gearData = model and game.ReplicatedStorage.Gear:FindFirstChild(model.Name)
	customColour = customColour or localSettings.CustomGloveColour.Value
	secondaryColour = secondaryColour or localSettings.SecondaryColour.Value
	if model and game.Players:GetPlayerFromCharacter(model.Parent) then
		local isCustom = (gearData and gearData:FindFirstChild("Colourable") and gearData.Colourable.Value)
		for i,v in pairs(model:GetDescendants()) do
			if v.Name == "GlowingParticle" then
				v.Enabled = isNeon
				if isCustom then
					v.Color = ColorSequence.new(customColour)
					if v.Name == "GlowingParticle" then
						v.Color = ColorSequence.new(secondaryColour)
					end
				end
			end
		end
		for i,v in pairs(model:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				if isCustom then
					if v.Name == "Primary" or v.Name == "PrimaryNoGlow" or v.Name == "NoGlowPrimary" then
						v.Color = customColour and customColour or v.Color

					end
				end
				if v.Name ~= "NoGlow" and v.Name ~= "NoGlowSpecific" and v.Name ~= "PrimaryNoGlow" and v.Name ~= "NoGlowPrimary" and v.Name ~= "ForceGlow" then v.Material = isNeon and Enum.Material.Neon or Enum.Material.SmoothPlastic end
			end
		end
		if model.Main:FindFirstChild("PointLight") then
			model.Main.PointLight.Enabled = isNeon
			model.Main.PointLight.Color = customColour
		end
		if model.Main:FindFirstChild("Trail") then
			model.Main.Trail.Enabled = isNeon
		end
	end
end
function game.ReplicatedStorage.SetGearVisuals.OnServerInvoke(sourceplr,model,isNeon,customColour)
	return setGearVisuals(sourceplr,model,isNeon,customColour)
end
function script.Parent.SetGearVisuals.OnInvoke(sourceplr,model,isNeon,customColour)
	return setGearVisuals(sourceplr,model,isNeon,customColour)
end
function dequipGear(sourceplr,aType)
	local toEquip = shared.env.getBodyPartFromCode(aType)
	local runtimeData = game.ReplicatedStorage.PlayerRuntimeData:WaitForChild(sourceplr.Name)
	local localSettings = game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name):WaitForChild("Settings")
	if runtimeData and runtimeData:WaitForChild("Gear",20):FindFirstChild(aType) and toEquip and aType ~= "glowing" then
		local gear = runtimeData.Gear[aType]
		if gear.model.Value then
			gear.model.Value:destroy()
			gear.model.Value = nil
		end
		gear.data.Value = nil
		gear.Value = ""
	elseif runtimeData and aType == "glowing" then
		runtimeData.Gear.glowing.Value = false
		setGearVisuals(sourceplr,"rightarm",localSettings.CustomGloveColour.Value)
	end
end
function equipGear(sourceplr,gear)
	print("equipping",gear,"on",sourceplr)
	local localData = game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name)
	local generic = localData:WaitForChild("Generic")
	local ranked = localData:WaitForChild("Ranked")
	local runtimeData = game.ReplicatedStorage.PlayerRuntimeData:WaitForChild(sourceplr.Name)
	while not (sourceplr.Character and sourceplr.Character.Parent == workspace) do runService.Stepped:wait() end
	if shared.env.playerCanEquipGear(sourceplr,gear) then
		if gear ~= game.ReplicatedStorage.Gear.GlowingGlove then
			local aType = gear.Type.Value
			dequipGear(sourceplr,aType)
			local model
			if gear == game.ReplicatedStorage.Gear.EvolutionGlove then
				local evolution = shared.env.getEvolutionFromLevel(generic.Level.Value)
				model = gear["Evolution"..evolution]:Clone()
				--[[
				if sourceplr.Character:FindFirstChild(gear.Name) then
					sourceplr.Character[gear.Name]:ClearAllChildren()
					for i,v in pairs(model:GetChildren()) do
						v.Parent = sourceplr.Character[gear.Name]
					end
					model = sourceplr.Character[gear.Name]
				end
				]]
			elseif gear == game.ReplicatedStorage.Gear.RewardGlove then
				local elo = math.max(ranked.Grappler.Elo.Value,ranked.MagRail.Elo.Value,ranked.Gearless.Elo.Value)
				if elo >= 3100 then
					model = gear.Elite:Clone()
				elseif elo >= 2500 then
					model = gear.Master:Clone()
				elseif elo >= 2000 then
					model = gear.Diamond:Clone()
				elseif elo >= 1500 then
					model = gear.Platinum:Clone()
				elseif elo >= 1000 then
					model = gear.Gold:Clone()
				end
			else
				model = gear.GearModel:Clone()
			end
			if model then
				if aType == "back" then
					if gear == game.ReplicatedStorage.Gear.AdrenalineBelt and sourceplr.userId == 22402288 then
						model = gear.JustynGearModel:Clone()
					end
					if gear == game.ReplicatedStorage.Gear.Paraglider and sourceplr.userId == 22402288 then
						model = gear.GearModelJustyn:Clone()
					end
				end
				model.Parent = aType == "leftarm" and workspace.RaycastIgnore or sourceplr.Character
				local toEquip = shared.env.getBodyPartFromCode(aType) or "HumanoidRootPart"
				local mainpart = model.PrimaryPart or model:FindFirstChild("Main")
				model.PrimaryPart = mainpart
				if mainpart then
					for i,v in pairs(model:GetChildren()) do
						if v:IsA("BasePart")  then
							if v ~= mainpart then
								local weld = Instance.new("Weld",model)
								weld.C0 = mainpart.CFrame:toObjectSpace(v.CFrame)
								weld.Part0 = mainpart
								weld.Part1 = v
							end
							v.Anchored = false
							v.Massless = true
						end
					end
				else
					error(model:GetFullName().." has no main part!")
				end
				local weld = Instance.new("Weld",model)
				weld.Name = "MainWeld"
				weld.Part0 = mainpart
				weld.Part1 = sourceplr.Character:FindFirstChild(toEquip)
				model.Name = gear.Name
				if runtimeData:WaitForChild("Gear"):FindFirstChild(aType) then
					local a = runtimeData.Gear[aType]
					a.Value = gear.Name
					a.model.Value = model
					a.data.Value = gear
				end
				if aType == "rightarm" then
					setGearVisuals(sourceplr,aType)
				elseif aType == "leftarm" then
					equipSkin(sourceplr,generic.EquippedSkins.Primary.Value,model,"Primary")
					equipSkin(sourceplr,generic.EquippedSkins.Secondary.Value,model,"Secondary")
					if model.Name == "Grappler" and sourceplr.userId == 22402288 then
						model.Union.Color = Color3.new(1,1,1)
					end
				elseif aType == "rightleg" then
					if model.Name == "Binoculars" and sourceplr.userId == 22402288 then
						model.Base.Color = Color3.fromRGB(248, 248, 248)
						model.Rims.Color = Color3.new(0,1,1)
						model.Rims.Material = Enum.Material.Neon
						model.Scope.Color = Color3.fromRGB(27, 42, 53)
						model.Scope.Reflectance = 0
					end
				end
				if model.Name == "BloxyCola" then
					for i,v in pairs(model:GetChildren()) do
						if v.Name == "Cola" then
							customizeCola(v,sourceplr.userId)
						end
					end
				end
				if model.Name == "RobotArm" then local mesh = Instance.new("BlockMesh",sourceplr.Character["Right Arm"]) mesh.Scale = Vector3.new() end
				return model
			end
		else
			runtimeData.Gear.glowing.Value = true
			setGearVisuals(sourceplr,"rightarm")
		end
	else warn(sourceplr,"cannot equip",gear)
	end
end
function game.ReplicatedStorage.EquipGear.OnServerInvoke(sourceplr,gear) --equip
	return equipGear(sourceplr,gear)
end
game.ReplicatedStorage.DequipGear.OnServerEvent:connect(dequipGear)
function game.ReplicatedStorage.GetID.OnServerInvoke(sourceplr)
	return sourceplr.userId
end
function script.Parent.EquipGearOnPlayer.OnInvoke(targetplr,gear)
	return equipGear(targetplr,gear)
end
function script.Parent.EquipSkinOnPlayer.OnInvoke(targetplr,skin,model,target)
	return equipSkin(targetplr,skin,model,target)
end
local lastFlagsUpdate = tick()
local updatingFlags = false
local flagsQueue = {}
local lastReasonTicks = {}
function flagId(id,reason,priority)

	id = tostring(id)

	if not lastReasonTicks[reason] or tick()-lastReasonTicks[reason] < 300 then

		lastReasonTicks[reason] = tick()

		if flagsQueue[id] and not flagsQueue[id].priority then
			flagsQueue[id].reason = reason
			flagsQueue[id].priority = priority
		elseif not flagsQueue[id] then
			flagsQueue[id] = {reason,priority}
		end

		local flagString = shared.env.getNameFromUserId(id) .." just got flagged for "..reason
		if game.PlaceId == 446422432 then
			warn(flagString)
		else
			discord:SubmitMessage("flags",(priority and "**" or "").. flagString ..(priority and "**" or ""))
		end

	end
end
function flagPlayer(plr,reason,priority)
	flagId(plr.userId,reason,priority)
end
shared.flagId = flagId
shared.flagPlayer = flagPlayer

function updateFlags()
	updatingFlags = true

	local q = dupeTable(flagsQueue)
	flagsQueue = {}
	local empty = true
	for _,_ in pairs(q) do empty = false break end

	if not empty then

		print("updating flags")

		playerFlags:UpdateAsync("flags",function(flags)

			flags = flags or {}

			for id,data in pairs(flagsQueue) do

				id = tostring(id)

				local current = flags[id] or {}

				current.total = current.total and current.total+1 or 1
				if not current.priority or data.priority then
					current.reason = data.reason or "Unspecified reason"
					current.priority = data.priority
				end

				flags[id] = current

			end

			return flags

		end)

	end

	updatingFlags = false
end

local updateFlagsLoop = runService.Heartbeat:connect(function(step)
	if updatingFlags then lastFlagsUpdate = tick() end
	if tick()-lastFlagsUpdate > 30 then
		updateFlags()
	end
end)

game:BindToClose(function()
	if not updatingFlags then
		updateFlagsLoop:disconnect()
		updateFlags()
	end
end)

game.ReplicatedStorage:WaitForChild("Flags").OnServerEvent:connect(function(sourceplr,data)
	local adminLevel = getAdminLevel(sourceplr)
	if adminLevel >= 6 and type(data) ~= "string" then

		local stamp = os.date("Wave on %x @ %X")

		playerFlags:UpdateAsync("flags",function(flags)
			for id,v in pairs(data) do
				id = tostring(id)
				if v == 2 then
					flags[id] = nil
				elseif v == 1 then
					flags[id] = nil
					data[id] = nil
				elseif v == 0 then
					data[id] = nil
				end
			end
			return flags
		end)

		for id,v in pairs(data) do
			local name = shared.env.getNameFromUserId(tonumber(id))
			print("banning",name)
			shared.ban(id,stamp)
			discord:SubmitMessage("bans",name .." was banned in a wave handled by "..sourceplr.Name)
		end

	else
		flagPlayer(sourceplr,data or "attempting to use flags remote without permission",true)
	end
end)
function autokick(plr,override)
	if selfbandebounce[plr] then return end
	selfbandebounce[plr] = true
	script.Parent.SavePlayer:Invoke(plr,true,override or true)
end
function banself(plr,reason)
	if selfbandebounce[plr] then return end
	selfbandebounce[plr] = true
	print("uh oh spaghettio")
	shared.ban(plr.userId,"You have been automatically banned")
	discord:SubmitMessage("bans",plr.Name.." managed to ban themselves by "..reason)
end
game.ReplicatedStorage:WaitForChild("LoadPosition").OnServerEvent:connect(function(sourceplr,pos)
	warn(sourceplr,"loaded their position to",pos)
end)
function game.ReplicatedStorage.LoadString.OnServerInvoke(sourceplr) flagPlayer(sourceplr,"trying to trigger the fake LoadString remote",true) end
function game.ReplicatedStorage.FlyRequest.OnServerInvoke(sourceplr) flagPlayer(sourceplr,"trying to trigger the fake fly remote",true) end
function game.ReplicatedStorage.FinishTimeTrial.OnServerInvoke(sourceplr) flagPlayer(sourceplr,"trying to trigger a patched remote with exploits",true) end
game.ReplicatedStorage.FireToDieInstantly.OnServerEvent:connect(function(sourceplr,reason) banself(sourceplr,reason or "firing to die instantly") end)
function game.ReplicatedStorage.ReloadSkin.OnServerInvoke(sourceplr,skinName)
	spawn(function() discord:SubmitMessage("toban",sourceplr.Name.." triggered the ReloadSkin remote") end)
	script.Parent.AddSkinToId:Invoke(sourceplr,skinName)
end
function game.ReplicatedStorage.SavePosition.OnServerInvoke(sourceplr,pos,slot)
	game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name).Generic.SavedPositions["Slot"..slot].Position.Value = pos
end
game.ReplicatedStorage.UpdateSlotName.OnServerEvent:connect(function(sourceplr,slot,name)
	local text = textService:FilterStringAsync(name,sourceplr.userId)
	game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name).Generic:WaitForChild("SavedPositions"):WaitForChild("Slot"..slot):WaitForChild("SlotName").Value = text:GetNonChatStringForUserAsync(sourceplr.userId)
end)
game.ReplicatedStorage.UpdateSelectedSlot.OnServerEvent:connect(function(sourceplr,slot)
	game.ReplicatedStorage.PlayerData:WaitForChild(sourceplr.Name).Generic.SavedPositions:WaitForChild("SelectedSlot").Value = slot
end)
function game.ReplicatedStorage.CheckIfGlow.OnServerInvoke(sourceplr,name)
	local target = game.Players:FindFirstChild(name)
	local toGlow = false
	local data = {}
	if target then
		local hasElite = shared.hasBadge(game.Players[name].userId,1308395290)
		if hasElite then data.isElite = true end
		local adminLevel = getAdminLevel(target)
		if adminLevel > 0 then data.colour = Color3.new(1,1,0) end
	end
	return data
end
game.ReplicatedStorage.UpdateCombo.OnServerEvent:connect(function(sourceplr,combo)
	--anticheat
	local stats = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name) and game.ReplicatedStorage.PlayerData[sourceplr.Name]:FindFirstChild("Stats")
	local averageCombo = stats.TotalCombo.Value/stats.ComboBreaks.Value
	print(averageCombo)
	if stats then
		if stats.MaxCombo.Value >= 201 and stats.MaxCombo.Value <= 299 then discord:SubmitMessage("possiblecheatdetection",sourceplr.Name .. " could be combo exploiting! (dont trust this, inspect before ban)") end
		--DONT ASK WHY THIS IS HERE. ADDSTAT SPAMS.
		local landings,plandings = stats.Landings.Value,stats.PerfectLandings.Value
		local plratio = math.floor(((plandings/landings)*100)+.5)
		if plratio <= 12 and stats.Playtime.Value > 540000 then discord:SubmitMessage("possiblecheatdetection",sourceplr.Name .. " has an odd perfect landing ratio for their time played!") end
	end
	if combo >= 3 then
		local last = shared.LastCombo[sourceplr] or 0
		if tick()-last < 3 and combo >= 3 then
			discord:SubmitMessage("possiblecheatdetection",sourceplr.Name .. " could be combo exploiting! (or they lost a combo very fast)")
			last = tick()
		end
		shared.LastCombo[sourceplr] = tick()
	end
	-- anticheat
	game.ReplicatedStorage.UpdateCombo:FireAllClients(sourceplr,combo)
end)
game.ReplicatedStorage.SetColaTransparency.OnServerEvent:connect(function(sourceplr,transparency)
	local cola = sourceplr.Character and sourceplr.Character:FindFirstChild("Cola")
	if cola then
		cola.Transparency = transparency
	end
end)
game.ReplicatedStorage.Glide.OnServerEvent:connect(function(sourceplr,bool)
	if sourceplr and sourceplr.Character:FindFirstChild("Glider") or sourceplr.userId == 22402288 and sourceplr.Character:FindFirstChild("Parastole") then
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= sourceplr then
				game.ReplicatedStorage.Glide:FireClient(v,sourceplr,bool)
			end
		end
	end
end)
game.ReplicatedStorage.ReplicateStimTransparency.OnServerEvent:connect(function(sourceplr,target,transparency)
	if target and target.Name == "Stim" and sourceplr.Character and target:IsDescendantOf(sourceplr.Character) then
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= sourceplr then
				game.ReplicatedStorage.ReplicateStimTransparency:FireClient(v,target,transparency)
			end
		end
	end
end)
game.ReplicatedStorage.ReplicateStimToss.OnServerEvent:connect(function(sourceplr,cf,vel,rotvel)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= sourceplr then
			game.ReplicatedStorage.ReplicateStimToss:FireClient(v,cf,vel,rotvel)
		end
	end
end)
game.ReplicatedStorage.SetTelescopeVisible.OnServerEvent:connect(function(sourceplr,bool)
	local target = sourceplr.Character and sourceplr.Character:FindFirstChild("Telescope")
	if target then
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= sourceplr then
				game.ReplicatedStorage.SetTelescopeVisible:FireClient(v,target,bool)
			end
		end
	end
end)
local colaSpawns = {}
game.ReplicatedStorage.SpawnColaDebris.OnServerEvent:connect(function(sourceplr,cf,velocity)
	local canSpawn = not colaSpawns[sourceplr] or colaSpawns[sourceplr]+1 < tick()
	if canSpawn then
		colaSpawns[sourceplr] = tick()
		local cola = game.ReplicatedStorage.Cola:Clone()
		physics:SetPartCollisionGroup(cola,"cans")
		if customCola[sourceplr.userId] then
			cola.Mesh.TextureId = customCola[sourceplr.userId].tex or cola.Mesh.TextureId
		end
		cola.Parent = workspace.RaycastIgnore
		cola.OwnerName.Value = sourceplr.Name
		cola.Script.Disabled = false
		if typeof(cf) ~= "CFrame" or typeof(velocity) ~= "Vector3" then
			spawn(function() shared.flagPlayer(sourceplr,"malformed SpawnColaDebris variables") end)
		end
		cola.Anchored = false
		cola.CanCollide = true
		cola.CFrame = cf
		cola.Velocity = velocity
		cola.RotVelocity = Vector3.new((math.random()-.5)*80,(math.random()-.5)*80,(math.random()-.5)*80)
	end
end)
game.ReplicatedStorage.SetInTimeTrial.OnServerEvent:connect(function(sourceplr,bool)
	if not shared.dunces[sourceplr.Name] and sourceplr.Character then
		for i,v in pairs(sourceplr.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				physics:SetPartCollisionGroup(v,bool and "playersInTimeTrial" or "players")
			end
		end
	end
end)



local boardStore = dss:GetDataStore("HackableBillboards")
local storedBoards = boardStore:GetAsync("HackedBillboards") or {}

local boardCooldowns = {}
local boards = workspace.HackableBillboards:GetChildren()
function getBillboardFromId(id)
	for i,v in pairs(boards) do
		if v and v:FindFirstChild("BoardId") and v.BoardId.Value == id then
			return v
		end
	end
end
function setBillboardAvailable(board,bool)
	board.Available.Value = bool
	board.Model.Button.Transparency = bool and 0 or 1
	board.Model.ActivatedButton.Transparency = bool and 1 or 0
end
function updateBillboard(board,data)
	board.Model.Board.Color = Color3.new(data.colour[1],data.colour[2],data.colour[3])
	board.OwnerId.Value = data.playerid
	local ui = board.Model.Board.Gui
	ui.ImageLabel.Image = data.image or ""
	ui.TextLabel.Text = data.text
	ui.TextLabel.BackgroundTransparency = .2
	ui.TextLabel.TextTransparency = 0
	ui.TextLabel.Visible = data.text ~= ""

	ui.TextLabel.Size = data.fill and UDim2.new(1,-90,1,-90) or UDim2.new(1,-90,0,45)
	ui.TextLabel.TextScaled = data.fill
	ui.TextLabel.TextXAlignment = data.fill and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left

	board.Model.UsernameScreen.Gui.Label.Text = data.username or "?"
end
function changeBillboard(board,data,noCooldown)
	print("changing billboard "..board.BoardId.Value)
	setBillboardAvailable(board,false)
	game.ReplicatedStorage.HackBillboard:FireAllClients(board,data)
	boardCooldowns[board] = {lasttick = tick(),cooldown = noCooldown and 0 or 61+math.random()*5}
	wait(5)
	updateBillboard(board,data)
end

local lastHackAttempt = {}
game.ReplicatedStorage.AttemptHack.OnServerEvent:connect(function(sourceplr)
	lastHackAttempt[sourceplr] = tick()
	print("attempt")
end)
game.ReplicatedStorage.HackBillboard.OnServerEvent:connect(function(sourceplr,board,usedChip)
	local plrdata = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	local hackData = plrdata:WaitForChild("Generic"):WaitForChild("HackData")
	local boardId = board.BoardId.Value
	local elapsed = lastHackAttempt[sourceplr] and tick()-lastHackAttempt[sourceplr]
	print(elapsed)
	if elapsed and elapsed >= 1 and plrdata and plrdata.Generic.Level.Value >= 15 and board.Available.Value and board.OwnerId.Value ~= sourceplr.userId and not (usedChip and hackData.Chips.Value <= 0) then
		setBillboardAvailable(board,false)
		print("billboarding")

		local success = false
		local data = {
			playerid = sourceplr.userId,
			username = sourceplr.Name,
			id = board.BoardId.Value,
			image = hackData.Image.Value,
			colour = {hackData.Colour.Value.R,hackData.Colour.Value.G,hackData.Colour.Value.B},
			text = hackData.Text.Value,
			fill = hackData.Fill.Value,
			lasttick = os.time(),
		}

		boardStore:UpdateAsync("HackedBillboards",function(old)
			old = old or {}
			local oldBoardData = old[boardId]
			if not oldBoardData or (oldBoardData.playerid ~= sourceplr.userId and os.time()-oldBoardData.lasttick >= 60) then
				success = true
				local newData = dupeTable(data)
				old[boardId] = newData
				return old
			else
				return nil
			end
		end)

		if success then
			if usedChip then hackData.Chips.Value -= 1 end
			script.Parent.MissionTrigger:Fire(sourceplr,"hackedbillboard",usedChip)
			shared.publish("billboards",data)
			discord:SendMessage("billboards",sourceplr.Name.." hacked ["..boardId.."] in ".. math.ceil(elapsed*100)/100 .." seconds".. (usedChip and " with a chip" or "") .."\n"..data.text.."\n".."https://www.roblox.com/library/"..string.sub(data.image,13))

			--local pointsToAdd = usedChip and 3000 or 12000
			--local added = dualAdd(sourceplr,pointsToAdd,0)
			--game.ReplicatedStorage.ClientPopup:FireClient(sourceplr,{text="+".. commaValue(added),colour=Color3.new(.3,1,1),randompos=true,fontSize=36,strokeColour=Color3.fromRGB(170,255,255),strokeTransparency=.8,speed=.5})
		else
			print("unsuccessful")
		end
	elseif board.Available.Value then
		board.Model.Button.Transparency = 0
		board.Model.ActivatedButton.Transparency = 1
	elseif elapsed and elapsed < 1 then
		flagPlayer(sourceplr,"hacking billboard in less than 1 second")
	end
end)

messagingService:SubscribeAsync("billboards",function(message)
	local data = http:JSONDecode(message.Data)
	changeBillboard(getBillboardFromId(data.id),data,data.noCooldown)
end)
cwrap(function()
	for i,v in pairs(boards) do
		if storedBoards[v.BoardId.Value] then
			local data = dupeTable(storedBoards[v.BoardId.Value])
			updateBillboard(v,data)
			if os.time()-data.lasttick < 60 then
				boardCooldowns[v] = {lasttick = tick()-(os.time()-data.lasttick),cooldown=61+math.random()*5}
				setBillboardAvailable(v,false)
			end
		end
	end
	while wait(1) do
		for i,v in pairs(boardCooldowns) do
			if tick()-v.lasttick > v.cooldown then
				boardCooldowns[i] = nil
				setBillboardAvailable(i,true)
			end
		end
	end
end)
function game.ReplicatedStorage.CanUseChip.OnServerInvoke(sourceplr)
	local plrdata = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name)
	return plrdata.Generic.HackData.Chips.Value > 0
end

game.ReplicatedStorage.UpdateHackSettings.OnServerEvent:connect(function(sourceplr,data)
	local generic = game.ReplicatedStorage.PlayerData:FindFirstChild(sourceplr.Name):WaitForChild("Generic")
	if data.text then
		generic.HackData.Text.Value = textService:FilterStringAsync(data.text,sourceplr.userId):GetNonChatStringForBroadcastAsync()
	end
	if data.colour then
		generic.HackData.Colour.Value = data.colour
	end
	if data.image then
		local numberid = tonumber(data.image)
		local isRawImage = numberid and marketplace:GetProductInfo(numberid,Enum.InfoType.Asset).AssetTypeId == 1
		generic.HackData.Image.Value = isRawImage and "rbxassetid://"..numberid or ""
	end
	if data.fill ~= nil then
		generic.HackData.Fill.Value = data.fill
	end
end)


game.ServerStorage:WaitForChild("ApexBlocker").Parent = workspace
for i,v in pairs(workspace.Ziplines:GetChildren()) do
	generateZipline(nil,v)
end
for i,v in pairs(workspace:GetChildren()) do
	if v.Name == "MagAttach" then
		v.AttachDistance.Value = v.BALL.Size.X*v.BALL.Mesh.Scale.X/2
		v.RopeLength.Value = v.AttachDistance.Value
		v.BALL:destroy()
	end
end
cwrap(function()
	if game.VIPServerId ~= "" then return end
	game.ServerStorage:WaitForChild("BagSpawns")
	local totalBagsSpawned = 0
	wait(5)
	while true do
		pcall(function()
			local function calculatePossible(isUltimate)
				local ps = {}
				for i,v in pairs(game.ServerStorage.BagSpawns:GetChildren()) do
					local pos = v.Position
					local clear = true
					for u,c in pairs(shared.skinBags) do
						if c:FindFirstChild("Main") then
							local dist = (pos-c.Main.Position).magnitude
							if dist < 32 then
								clear = false
								break
							end
						elseif c and c.Parent then
							c:destroy()
						end
					end
					if clear then
						for u,p in pairs(game.Players:GetPlayers()) do
							if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
								if (p.Character.HumanoidRootPart.Position-pos).magnitude < 64 then
									clear = false
									break
								end
							end
						end
					end
					local function insert(x) table.insert(ps,x) end
					if clear then
						if isUltimate and v.Name == "UltimateSpawn" then
							insert(v)
						elseif not isUltimate and v.Name ~= "UltimateSpawn" then
							insert(v)
						end
					end
				end
				return ps
			end
			for i,v in pairs(shared.skinBags) do if v == nil or v.Parent == nil then table.remove(shared.skinBags,i) end end
			if #shared.skinBags >= 60 then repeat wait() until #shared.skinBags < 60 end
			local possibleSpawns = calculatePossible()
			local bSpawn = possibleSpawns[math.random(math.min(1,#possibleSpawns),#possibleSpawns)]
			if bSpawn then
				local bag = game.ServerStorage.SkinBag:Clone()
				local rarityDice = math.random()
				if bSpawn.Name == "UncommonSpawn" then setBagType(bag,"Uncommon") end
				if rarityDice >= .6 then
					setBagType(bag,"Uncommon")
				end
				if bSpawn.Name == "RareSpawn" then setBagType(bag,"Rare") end
				if rarityDice >= .85 then
					setBagType(bag,"Rare")
				end
				if bSpawn.Name == "EpicSpawn" then setBagType(bag,"Epic") end
				if rarityDice >= .96 then
					setBagType(bag,"Epic")
				end
				local legendaryDice = math.random()
				if bag.Rarity.Value == "Epic" then
					if bSpawn.Name == "UncommonSpawn" and legendaryDice > .99 then
						setBagType(bag,"Legendary")
					elseif bSpawn.Name == "RareSpawn" and legendaryDice > .9 then
						setBagType(bag,"Legendary")
					elseif bSpawn.Name == "EpicSpawn" and legendaryDice > .75 then
						setBagType(bag,"Legendary")
					end
				end
				if bag.Rarity.Value == "Legendary" and math.random() > .9 then
					setBagType(bag,"Ultimate")
					local spawns = calculatePossible(true)
					warn("ultimate, "..#spawns)
					bSpawn = spawns[math.random(math.min(1,#spawns),#spawns)]
					if math.random(1,50) == 1 then setBagType(bag,"Resplendent") end 
				end
				if (shared.env.bagNameToTier[bag.Rarity.Value] <= 3) and (math.random() > .7 or runService:IsStudio()) then
					bag = game.ReplicatedStorage.IsHalloween.Value and game.ServerStorage.HalloweenBag:Clone() or (workspace:FindFirstChild("Christmas") ~= nil and game.ServerStorage.ChristmasBag:Clone() or bag)
				end
				--if math.random() > .8 or runService:IsStudio() then bag = game.ServerStorage.MilBag:Clone() end
				bag:SetPrimaryPartCFrame(bSpawn.CFrame)
				bag.Name = math.random(1000000,9999999)
				bag.Parent = workspace
				table.insert(shared.skinBags,bag)
				local touchScript = script.BagTouchScript:Clone()
				touchScript.Parent = bag
				touchScript.Disabled = false
				local txt = bag.Rarity.Value
				txt = (bag.Rarity.Value == "Legendary" or bag.Rarity.Value == "Ultimate") and string.upper(txt) or txt
				totalBagsSpawned += 1
				--print(txt.." Bag spawned at "..bag.Main.CFrame.X,bag.Main.CFrame.Y,bag.Main.CFrame.Z)
			end
		end)
		wait((game.PlaceId == 446422432 or runService:IsStudio()) and (totalBagsSpawned < 50 and 0 or 1) or math.random(15,25))
	end
end)
function kickAllLoop(message)
	spawn(function()
		while wait() do
			local plrs = game.Players:GetPlayers()
			if #plrs > 0 then
				for i,v in pairs(plrs) do
					v:Kick(message)
				end
			end
		end
	end)
end
game.ServerScriptService.SetSessionMult.Event:connect(function(plr,mult,timer)
	playerSessionMults[plr].mult = math.clamp(mult-1,0,4)
	if timer then playerSessionMults[plr].timer = timer end
end)
runService.Heartbeat:connect(function(step)
	for i,v in pairs(game.Players:GetPlayers()) do
		spawn(function()
			if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				local pos = v.Character.HumanoidRootPart.Position
				wait(1)
				shared.pastPlayerPositions[v] = pos
			end
		end)
	end

	for i,v in pairs(playerSessionMults) do
		if tick() < v.timer+5 then
			v.mult = math.min(v.mult+(step/3600),4)
			game.ReplicatedStorage.PlayerData[i.Name].Generic.SessionMultiplier.Value = v.mult
		end
	end
end)
local shutdownTimerActive = false
local toShutdownTick = 0
spawn(function()
	repeat wait(1) until shutdownTimerActive
	print("beginning timed shutdown")
	repeat
		wait()
		shared.serverShuttingDown = true
		workspace.SHUTTINGDOWN.Value = math.max(0,toShutdownTick-os.time())
	until os.time() > toShutdownTick
	wait(1)
	kickAllLoop("Game has been shut down, please rejoin a new server.")
end)
local lastGlobalExecute = 0
--[[messagingService:SubscribeAsync("dunce",function(data)
	data = http:JSONDecode(data.Data)
	local plr = game.Players:GetPlayerByUserId(data.id)
	if plr then
		warn("duncing remotely")
		dunce(data.todunce,data.id,data.reason,true,data.sourceplr)
	end
end)]]
messagingService:SubscribeAsync("kick",function(data)
	data = http:JSONDecode(data.Data)
	local plr = game.Players:GetPlayerByUserId(data.id)
	if plr then
		warn("kicking remotely")
		plr:Kick(data.reason)
	end
end)
cwrap(function()
	while wait(2) do
		for i,v in pairs(game.Players:GetPlayers()) do
			updateLeaderstats(v)
			if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				local pos = v.Character.HumanoidRootPart.Position
				if shared.env.isInside(pos,Vector3.new(-79, 335.309, -220.5),Vector3.new(-130.256, 315.893, -254.858)) and getAdminLevel(v) <= 0 and not v:IsFriendsWith(18205436) then
					shared.serverlocklist[tostring(v.userId)] = {reason = "and stay out"}
					v:Kick("get out")
				end
			end
		end
		game.ReplicatedStorage.UpdateDunceList:FireAllClients(shared.dunces)
	end
end)
cwrap(function()
	while true do
		local gameMessage = dataStore:GetAsync("GAME_MESSAGE")
		game.ReplicatedStorage.GameMessage.Value = gameMessage and gameMessage or "lol"
		game.ReplicatedStorage.LatestVersion.Value = dataStore:GetAsync("latest_version") or 0
		if math.floor(tonumber(game.ReplicatedStorage.LatestVersion.Value)*10)/10 > math.floor(tonumber(game.ReplicatedStorage.ServerVersion.Value)*10)/10 and not shutdownTimerActive then
			shutdownTimerActive = true
			toShutdownTick = os.time()+600
			print("setting up outdated shutdown")
		end
		if not shutdownTimerActive then
			local timedShutdown = dataStore:GetAsync("TIMED_SHUTDOWN_TICK") or {t=0,c=0}
			if timedShutdown.t > os.time() and serverCreationTime < timedShutdown.c then shutdownTimerActive = true toShutdownTick = timedShutdown.t end
		end
		local shutdownVersion = tonumber(dataStore:GetAsync("SHUTDOWN_VERSION") or 0) or 0
		local toShudownManually = dataStore:GetAsync(game.JobId..".shutdown")
		local globalCodeExecution = dataStore:GetAsync("GLOBAL_CODE_EXECUTE") or {s="",t=0}
		if serverCreationTime < globalCodeExecution.t and globalCodeExecution.t > lastGlobalExecute+1 and globalCodeExecution.s ~= "" then pcall(function() lastGlobalExecute = globalCodeExecution.t loadstring(globalCodeExecution.s)() end) end
		if toShudownManually or tonumber(game.ReplicatedStorage.ServerVersion.Value) < shutdownVersion then
			dataStore:RemoveAsync(game.JobId..".shutdown")
			kickAllLoop(toShudownManually and "Server has been remotely shut down" or "Server is outdated, please rejoin a new server.")
		end
		wait(20)
	end
end)
cwrap(function()
	wait(5)
	for i,v in pairs(workspace.Props:GetChildren()) do
		if v:FindFirstChild("Climb") then
			local x = Instance.new("TrussPart",v)
			x.Size = v.Climb.Size
			x.CFrame = v.Climb.CFrame
			x.Anchored = true
			x.Transparency = 1
			v.Climb.CanCollide = false
		end
	end
end)
cwrap(function()
	local billboards = {}
	local lights = {}
	for i,v in pairs(workspace:GetChildren()) do if v:IsA("Model") and v.Name == "Billboard" then table.insert(billboards,v) end end
	for i,v in pairs(workspace.Props:GetChildren()) do if v:IsA("Model") and (v.Name == "GroundLight" or v.Name == "Spotlight") then table.insert(lights,v) end end
	while true do
		local t = game.ReplicatedStorage:WaitForChild("Time").Value%7200
		local enabled = (t < 380 or t > 1100) or game.ReplicatedStorage.IsHalloween.Value
		for i,v in pairs(billboards) do
			if v:FindFirstChild("Main") then
				v.Main:WaitForChild("Light").Enabled = enabled
			else
				warn("could not find Main for Billboard at "..v.Truss.CFrame.X..","..v.Truss.CFrame.Y..","..v.Truss.CFrame.Z)
			end
		end
		for i,v in pairs(lights) do
			v.LightPart.Light.Enabled = enabled
			v.LightPart.Material = enabled and Enum.Material.Neon or Enum.Material.SmoothPlastic
			v.LightPart.Color = enabled and Color3.fromRGB(150,150,150) or BrickColor.Black().Color
		end
		wait(6)
	end
end)
