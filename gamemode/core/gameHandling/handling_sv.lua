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
	
	self:setStatus(ROUND_PREP)

	self.rounds_left     = self.gameData.rounds
	self.game_timeLimit  = self.gameData.time

	gm:chooseSab()

	net.Start("gm.updateHud")
	net.Broadcast()
end

--do the updating functions in here, so the game can call this too and kill it whenever.
function gm:endGame()
	gm:updateTime(ending_time)
	gm:setStatus(GAME_ENDING)

	for k,v in pairs(self:getSpectators()) do
		v:SetTeam(TEAM_PLAYER)
	end

	for k,v in pairs(self:getPlayers()) do
		v:Freeze(true)
	end

	gm:voteForNextGame(function(sName)

		gm:startGame(sName)

	end)

	net.Start("gm.clearHud")
	net.Broadcast()
end

function gm:endRound()
	game.CleanUpMap()

	gm:setStatus(ROUND_ENDING)
end

function gm:startRound()
	self.gameData:start()

	for k,v in pairs(self:getPlayers()) do
		v:Freeze(false)
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
		if (cur_status == ROUND_PREP) then
			
			gm:startRound()
			
			gm:updateTime(gm.game_timeLimit)
			gm:setStatus(STATUS_PLAYING)

		elseif (cur_status == GAME_ENDING) then

			local nextGame = gm:getGameMostVoted()
			gm:startGame(nextGame)

		elseif (cur_status == STATUS_PLAYING and rounds_left == 0) then

			gm:endGame()

		elseif (cur_status == ROUND_ENDING)

			gm:startRound()

			gm:updateTime(gm.game_timeLimit)
			gm:setStats(STATUS_PLAYING)

		else

			gm:endRound()

			gm.rounds_left = rounds_left - 1
			ndoc.table.gm.rounds_left = rounds_left - 1

			gm:updateTime(prep_time)
			gm:setStatus(ROUND_PREP)

			local sab = gm:chooseSab()
			gm:sendVoice(sab)
		end
	end

	gm:updateTime(gm.time_left - 1)
end)

hook.Add("PlayerDisconnected", "ShouldEnd", function(ply)
	if (ply:isSab() and gm.status == STATUS_PLAYING) then
		gm:endGame()
	end
end)