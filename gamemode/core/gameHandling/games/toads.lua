GAME = {}

GAME.name = "Exploading Toads"
GAME.desc = "Find three holes with the correct items before selecting three bad ones!"
GAME.time = 300
GAME.rounds = 1
GAME.instruction_link = ""
GAME.objectives = {
	["sab"] = {"Prevent the players from selecting the correct holes!"},
	["players"] = {"Find which holes have the items! Make sure you talk with your team!", "Select 3 good holes before selecing 3 bad ones!", "Be careful, some holes have exploading Toads in them!"}
}
GAME.logo = ""

if (SERVER) then
	util.AddNetworkString("toads.sendSabData")
end

--called everytime a new round starts!
function GAME:start( )
	-- Cup game test
	if SERVER then
		self.wins = self.wins or 0
		
	else
		chat.AddText( "Client game loaded." ) -- todo: hud
	end
end

net.Receive("cup.sendSabData", function()
	local ent = net.ReadEntity()

	hook.Add( "PreDrawHalos", "ShowCorrectBarrel", function()
		halo.Add( { ent }, Color( 0, 255, 0 ) )
	end )
	chat.AddText( "Prevent the players for chosing the highlighted barrel, but don't act too suspicous." )
end)

function GAME:createHud()

end

function GAME:getWinner()
	if self.wins > 1 then
		return TEAM_PLAYER
	else
		return TEAM_SAB
	end
end

function GAME:shouldEnd()
	return self.endNow
end

gm:registerGame(GAME)