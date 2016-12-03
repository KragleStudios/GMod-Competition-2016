local hud = nil
net.Receive("gm.updateHud", function()
	local game = ndoc.table.gm.game

	hud = gm.games[ game ].cHud
end)

net.Receive("gm.clearHud", function()
	hud = nil
end)

hook.Add("HUDPaint", "DrawGMHud", function()
	if (hud ~= nil) then
		hud()
	end
end)

net.Receive("gm.sendVoice", function()
	--todo play sab instruction voice
end)