GAME = {}

GAME.name = "Poisoned Watermelon"
GAME.desc = "Eat 5 good watermelons before time runs out! Beware, eating 5 poisoned watermelons will make you lose!"
GAME.time = 300
GAME.rounds = 1
GAME.instruction_link = ""
GAME.objectives = {
	["sab"] = {"Prevent the players from eating the good watermelon!"},
	["players"] = {"Eat the good watermelon before time runs out! "}
}
GAME.logo = ""
GAME.loadout = {"weapon_physcannon"}


if (SERVER) then
	util.AddNetworkString("wm.sendSabData")
end

--called everytime a new round starts!
function GAME:start()
	-- Cup game test
	if SERVER then
		self.good = self.good or 0
		self.bad = self.bad or 0
		
		hook.Add("sab_wmused", "sab_gameHook", function(watermelon, ply)
			if (watermelon.poisoned) then
				self.bad = self.bad + 1

				if (self.bad == 5) then
					self.endNow = true
				end
			else
				self.good = self.good + 1

				if (self.good == 5) then
					self.endNow = true
				end
			end
		end)

		for i = 1, 30 do
			local wm = ents.Create("sab_watermelon")
			wm:SetPos(Vector(math.random(1, 50), math.random(1, 50), 100))
			wm:Spawn()
			wm:Activate()

			local chance = math.random(0, 100)
			if (chance <= 50) then
				wm.poisoned = true
			end
		end

		local tester = ents.Create("sab_watermelon_tester")
		tester:SetPos(Vector(240, -400, 128))
		tester:Spawn()
		tester:Activate()
	else
		chat.AddText( "Client game loaded." ) -- todo: hud
	end
end

net.Receive("cup.sendSabData", function()
	local ent = net.ReadEntity()

	hook.Add("PreDrawHalos", "ShowCorrectBarrel", function()
		halo.Add( { ent }, Color( 0, 255, 0 ) )
	end)
end)

function GAME:createHud()

end

function GAME:getWinner()
	return self.good > self.bad and TEAM_PLAYERS or TEAM_SAB
end

function GAME:shouldEnd()
	return self.endNow
end

gm:registerGame(GAME)