if (SERVER) then AddCSLuaFile() end

TEAM_PLAYER = 1
TEAM_SPEC   = 2


--don't setup sab team, we don't want them be seen outside of the "players"
team.SetUp(TEAM_PLAYER, "Player", Color(25, 255, 25))
team.SetUp(TEAM_SPEC, "Spectator", Color(255, 255, 255))

--we won't sync sab player over netdoc, to prevent others from knowing who it is.
--only the player who is the sab will have this variable set on them.
local ply = FindMetaTable("Player")
function ply:isSab()
	return SERVER and (gm.Sab == self) or (self:GetNWInt("Sab", 0) == 1)
end

function ply:isSpec()
	return self:getData().team == TEAM_SPEC
end

function ply:isPlaying()
	return not self:isSpec()
end

function gm:getPlayers()
	local tab = {}

	for k,v in pairs(player.GetAll()) do
		if (v:isPlaying()) then
			table.insert(tab, v)
		end
	end

	return tab
end

function gm:getSpectators()
	local tab = {}

	for k,v in pairs(player.GetAll()) do
		if (v:isSpec()) then
			table.insert(tab, v)
		end
	end

	return tab
end

hook.Add("PlayerInitialSpawn", "SetTeams", function(ply)
	if (not gm.status or gm.status == STATUS_PLAYING) then
		ply:SetTeam(TEAM_SPEC)

	elseif (gm.status == ROUND_PREP) then
		ply:SetTeam(TEAM_PLAYER)
	end
end)

if (SERVER) then
	function gm:chooseSab()
		local activePlayers = self:getPlayers()

		local ply = nil

		while ply == nil or self.sab == ply do
			ply = activePlayers[ math.random(1, #activePlayers) ]
		end

		hook.Call("OnSabChosen", self, self.sab, ply)

		--remove old sab
		if (self.sab) then
			self.sab:SetNWInt("Sab", 0)
		end

		self.sab = ply
		ply:SetNWInt("Sab", 1)

		return sab
	end
end