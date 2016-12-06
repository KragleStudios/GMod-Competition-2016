local hud = nil
local objectives = nil
net.Receive("gm.updateHud", function()
	local game = ndoc.table.gm.game

	hud = gm.games[ game ].cHud
	objectives = gm.games[ game ].objectives

	if (daddyHud) then
		daddyHud:Remove()

		daddyHud = nil
	end
end)

local daddyHud
net.Receive("gm.clearHud", function()
	hud = nil
end)

local issab = false
net.Receive("sab.verified", function()
	issab = net.ReadBool()

	if (daddyHud) then 
		daddyHud:Remove()

		daddyHud = nil
	end
end)

local function createDaddy()
	local ourjectives = issab and objectives[ "sab" ] or objectives[ "players" ]
end

hook.Add("HUDPaint", "DrawGMHud", function()
	if (hud ~= nil) then
		hud()
	end
	
	if (not daddyHud and objectives) then
		createDaddy()
	end
end)



net.Receive("gm.sendVoice", function()
	--todo play sab instruction voice
end)