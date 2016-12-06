util.AddNetworkString("gm.updateHud")
util.AddNetworkString("gm.clearHud")
util.AddNetworkString("gm.sendVoice")

local ending_time = 60
local prep_time   = 30

function gm:setStatus(status)
	self.status = status

	ndoc.table.gm.status = status
end

function gm:updateTime(time)
	self.time_left = time

	ndoc.table.gm.time_left = time
end

function gm:startGame(sName)
	self.gameData = gm.games[ sName ]
	game.CleanUpMap()

	ndoc.table.gm.game = sName

	self.time_left = prep_time
	ndoc.table.gm.time_left = prep_time
	ndoc.table.gm.rounds_left = self.gameData.rounds
	
	self:setStatus(ROUND_PREP)

	self.rounds_left     = self.gameData.rounds
	self.game_timeLimit  = self.gameData.time

	gm:chooseSab()

	net.Start("gm.updateHud")
	net.Broadcast()
end

concommand.Add("startgame", function()
	gm:startGame("Poisoned Watermelon")
end)

--do the updating functions in here, so the game can call this too and kill it whenever.
function gm:endGame()
	gm:updateTime(ending_time)
	gm:setStatus(GAME_ENDING)

	--to prevent tons of endGame getting called 
	gm:updateTime(nil)

	gm:voteForNextGame(20, function(sName)

		gm:startGame(sName)

	end)

	net.Start("gm.clearHud")
	net.Broadcast()
end

function gm:endRound()
	for k,v in pairs(player.GetAll()) do
		v:StripWeapons()
	end

	game.CleanUpMap()

	gm:setStatus(ROUND_PREP)
	gm:updateTime(prep_time)

	local rounds_left = self.rounds_left

	self.rounds_left = rounds_left - 1
	ndoc.table.gm.rounds_left = rounds_left - 1

	for k,v in pairs(self:getSpectators()) do
		v:SetTeam(TEAM_PLAYER)
	end

end

function gm:startRound()
	self.gameData:start()

	for k,v in pairs(self:getPlayers()) do
		for _, wep in pairs(self.gameData.loadout) do
			v:Give(wep)
		end
	end
end

function gm:shouldEnd()
	return self.gameData:shouldEnd()
end

function gm:getWinner()
	return self.gameData:getWinner()
end

function gm:sendVoice(ply)
	net.Start("gm.sendVoice")
		net.WriteString(self.gameData.instructions)
	net.Send(ply)
end

timer.Create("round_handler", 1, 0, function()
	local time_left, rounds_left, cur_status = gm.time_left, gm.rounds_left, gm.status

	if (not time_left) then return end

	if (gm:shouldEnd()) then
		if (rounds_left ~= 0) then
			gm:endRound()
		else
			gm:endGame()
		end
	end

	if (time_left == 0) then
		if (rounds_left == 0) then
			gm:endGame()

			return
		end

		if (cur_status == ROUND_PREP) then
			
			gm:startRound()
			
			gm:updateTime(gm.game_timeLimit)
			gm:setStatus(STATUS_PLAYING)

		elseif (cur_status == STATUS_PLAYING) then
			
			if (rounds_left == 0) then
				gm:endGame()
			else			

				gm:endRound()

				local sab = gm:chooseSab()
				gm:sendVoice(sab)
			end

		elseif (cur_status == GAME_ENDING) then

			local nextGame = gm:getGameMostVoted()
			gm:startGame(nextGame)

		elseif (rounds_left == 0) then

			gm:endGame()

		end
	end

	gm:updateTime((gm.time_left or time_left) - 1 )
end)

hook.Add("PlayerDisconnected", "ShouldEnd", function(ply)
	if (gm.sab and gm.sab == ply and gm.status == STATUS_PLAYING) then
		gm:endGame()
	end
end)