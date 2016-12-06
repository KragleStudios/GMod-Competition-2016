if (SERVER) then 
	AddCSLuaFile()

	ndoc.table.gm = ndoc.table.gm or {}
	ndoc.table.gm.games = ndoc.table.gm.games or {}
end

gm.dep("teams")

gm.games = gm.games or {}

ROUND_PREP = 1
GAME_ENDING = 2
ROUND_ENDING = 3
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
		objectives = data.objectives
	}

	if (SERVER) then ndoc.table.gm.games[ data.name ] = {data.desc, data.logo} end
end

local basePath = gm.FolderName .. "/gamemode/core/gameHandling/games"
local files = file.Find(basePath .. "/*.lua", "LUA")

for _,file in pairs(files) do
	--[[local G = table.Copy(_G)

	-- Track all hooks that are added so they are correctly cleaned up at the end of rounds.
	function G.hook.Add(_hook, name, func)
		if not gm.tempHooks[_hook] then
			gm.tempHooks[_hook] = {}
		end
		gm.tempHooks[_hook][name] = func

		hook.Add(_hook, name, func)
	end

	function G.hook.Remove(_hook, name)
		gm.tempHooks[_hook][name] = nil
		hook.Remove(_hook, name)
	end

	setfenv(function() ]] include_sh(basePath .. "/" .. file) --[[end, G)]] -- Someone fix this please

	print("Including game: ".. file)
end

include_sv("handling_sv.lua")
include_cl("handling_cl.lua")