if (SERVER) then 
	AddCSLuaFile()

	ndoc.table.gm = ndoc.table.gm or {}
	ndoc.table.gm.games = ndoc.table.gm.games or {}
end

gm.dep("teams")

gm.games = gm.games or {}

ROUND_PREP = 1
GAME_ENDING = 2
--ROUND_ENDING = 3
STATUS_PLAYING = 4

function gm:registerGame(data)
	gm.games[ data.name ] = {
		time   = data.time,
		rounds = data.rounds or 0,
		cHud   = data.createHud,
		start  = data.start,
		getWin = data.getWinner,
		shouldEnd = data.shouldEnd,
		instructions = data.instruction_link,
	}

	if (SERVER) then ndoc.table.gm.games[ data.name ] = {data.desc, data.logo} end
end

local basePath = gm.FolderName .. "/gamemode/core/gameHandling/games"
local files = file.Find(basePath .. "/*.lua", "LUA")

for _,file in pairs(files) do
	
	include_sh(basePath .. "/" .. file)

	print("Including game: ".. file)
end

include_sv("handling_sv.lua")
include_cl("handling_cl.lua")