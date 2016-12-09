if (SERVER) then
	AddCSLuaFile()
	
else

	hook.Add("OnPlayerChat", "PlayerChatting", function(ply, text, teamOnly, dead)
		local tag, color, pColor = hook.Call("PlayerChatTags", GAMEMODE, ply)

		if (LocalPlayer():Team() ~= ply:Team()) then return true end
		
		local tab = {}

		if (dead) then
			table.insert(tab, Color(255, 25, 25))
			table.insert(tab, "*DEAD* ")
		end

		if (tags and colors) then
			table.insert(tab, color)
			table.insert(tab, tag)
		end

		if (teamOnly) then
			table.insert(tab, Color(25, 255, 25))
			table.insert(tab, "[TEAM] ")
		end
		if (IsValid(ply)) then
			table.insert(tab, pColor or team.GetColor(ply:Team()))
			table.insert(tab, ply:Nick())
		else
			table.insert(tab, Color(0, 0, 0))
			table.insert(tab, "Console")
		end

		table.insert(tab, Color(255, 255, 255))
		table.insert(tab, ": " .. text)

		chat.AddText(unpack(tab))

		return true
	end)

end