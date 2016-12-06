if (SERVER) then AddCSLuaFile() end

TEAM_PLAYER = 1
TEAM_SAB = 2
TEAM_SPEC   = 1000


--don't setup sab team, we don't want them be seen outside of the "players"
team.SetUp(TEAM_PLAYER, "Player", Color(25, 255, 25))
team.SetUp(TEAM_SPEC, "Spectator", Color(255, 255, 255))

local ply = FindMetaTable("Player")

function ply:isSpec()
	return self:Team() == TEAM_SPEC
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


if (SERVER) then
	function gm:chooseSab()
		local activePlayers = self:getPlayers()

		local ply = nil

		while not IsValid(ply) or self.sab == ply do
			ply = activePlayers[ math.random(1, #activePlayers) ]
		end

		hook.Call("OnSabChosen", self, self.sab, ply)

		self.sab = ply
		ply:SetNWInt("Sab", 1)

		net.Start("sab.verified")
			net.WriteBool(false)
		net.Broadcast()

		net.Start("sab.verified")
			net.WriteBool(true)
		net.Send(ply)

		return sab
	end

	util.AddNetworkString("sab.verified")

	hook.Add("PlayerInitialSpawn", "SetTeams", function(ply)
		if (not gm.status or gm.status == STATUS_PLAYING) then
			ply:SetTeam(TEAM_SPEC)

		elseif (gm.status == ROUND_PREP) then
			ply:SetTeam(TEAM_PLAYER)
		end
	end)

end