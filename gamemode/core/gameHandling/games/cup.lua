GAME = {}

GAME.name = "Find the ball"
GAME.desc = "Follow the cup the ball is under, then select the correct cup to win!"
GAME.time = 300
GAME.rounds = 1
GAME.instruction_link = ""
GAME.objectives = {
	["sab"] = {"Prevent the players from selecting the correct barrel!"},
	["players"] = {"Select the correct barrel! Make sure you talk with your team!"}
}
GAME.logo = ""
GAME.winnerMoney = nil --optional, default is 300

if (SERVER) then
	util.AddNetworkString("cup.sendSabData")
end

--called everytime a new round starts!
function GAME:start( )
	-- Cup game test
	if SERVER then
		self.wins = self.wins or 0
		local props = {}
		print("y")

		local function MoveTheBarrels()
			for k,v in pairs( player.GetAll() ) do
				v:StripWeapons()
			end

			for i = 1, 3 do
				props[ i ] = ents.Create( "prop_physics" )
				props[ i ]:SetModel( "models/props_borealis/bluebarrel001.mdl" )
				props[ i ]:SetPos( Vector( 253.5 + ( i * 75 ), -336, 96 ) )
				-- props[ i ]:DropToFloor()
				props[ i ]:Spawn()
				props[ i ]:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
				props[ i ]:GetPhysicsObject():EnableMotion( false ) -- Prevent people from knocking over barrels while they're moving
			end

			local ballProp = math.random( 1, 3 )

			net.Start("cup.sendSabData")
				net.WriteEntity(props[ballProp])
			net.Send(gm.sab)

			local ball = ents.Create( "prop_physics" )
			ball:SetModel( "models/maxofs2d/hover_classic.mdl" )
			ball:SetPos( props[ ballProp ]:GetPos() + Vector( 0, 0, 50 ) )
			ball:Spawn()
			ball:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			ball:GetPhysicsObject():EnableMotion( false )

			timer.Simple( 2, function()
				hook.Add( "Think", "LowerTheBall", function()
					ball:SetPos( Vector( ball:GetPos().x, ball:GetPos().y, math.Approach( ball:GetPos().z, props[ ballProp ]:GetPos().z, 0.2 ) ) )
				end )
			end )

			timer.Simple( 5, function()
				hook.Remove( "Think", "LowerTheBall" )
				ball:Remove()

				timer.Create( "MoveBarrels", 0.4, 60, function()
					local move1 = math.random( 2, 3 )
					props[ 1 ].MoveTo = props[ move1 ]:GetPos().x
					props[ move1 ].MoveTo = props[ 1 ]:GetPos().x
				end )

				hook.Add( "Think", "MoveBarrels", function()
					for k,v in pairs( props ) do
						if v.MoveTo then
							v:SetPos( Vector( math.Approach( v:GetPos().x, v.MoveTo, 6.75 ), v:GetPos().y, v:GetPos().z ) )
						end
					end
				end )

				timer.Simple( 0.4 * 61, function()
					for k,v in pairs( player.GetAll() ) do
						v:Give( "weapon_crowbar" )
					end
					PrintMessage( HUD_PRINTTALK, "Hit the correct barrel with your crowbar!" )
					hook.Remove( "Think", "MoveBarrels" )
					for k,v in pairs( props ) do
						v:GetPhysicsObject():EnableMotion( true )
					end
					hook.Add( "EntityTakeDamage", "SelectBarrel", function( ent, dmg )
						if IsValid( ent ) and ent:GetClass() == "prop_physics" and ent:GetModel() == "models/props_borealis/bluebarrel001.mdl" then
							local pNum

							for k,v in pairs( props ) do
								if v == ent then
									pNum = k
									break
								end
							end

							if pNum == ballProp then
								PrintMessage( HUD_PRINTTALK, "You win!" )
								hook.Remove( "EntityTakeDamage", "SelectBarrel" )

								local ball = ents.Create( "prop_physics" )
								ball:SetModel( "models/maxofs2d/hover_classic.mdl" )
								ball:SetPos( props[ ballProp ]:GetPos() )
								ball:Spawn()
								ball:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
								ball:GetPhysicsObject():SetVelocity( Vector( math.random( 100, 500 ), math.random( 100, 500 ), math.random( 100, 500 ) ) )

								self.wins = self.wins + 1
							else
								PrintMessage( HUD_PRINTTALK, "You lose!" )
								hook.Remove( "EntityTakeDamage", "SelectBarrel" )
							end

							timer.Simple( 5, function()
								for k,v in pairs( props ) do
									v:Remove()
								end
								gm:endRound()
							end )

						end

					end )

				end )
			end )
		end

		MoveTheBarrels()
	else
		chat.AddText( "Client game loaded." ) -- todo: hud
	end
end

net.Receive("cup.sendSabData", function()
	local ent = net.ReadEntity()
	print(ent)
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