if (SERVER) then
	AddCSLuaFile()

	ndoc.table.gmVotes = ndoc.table.gmVotes or {}
	ndoc.table.gmGameVotes = ndoc.table.gmGameVotes or {}
end

gm.dep("gameHandling")

include_cl("voting_cl.lua")
include_sv("voting_sv.lua")