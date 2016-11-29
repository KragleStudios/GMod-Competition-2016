DeriveGamemode("sandbox")

GM.Name = ""
GM.SmallName = ""
GM.Author = "Mikey Howell, meharryrp, crazyscouter"
GM.Email = ""
GM.Website = "http://www.kraglestudios.com"

function include_sv(path)
	if (SERVER) then include(path) end
end

function include_cl(path)
	if (SERVER) then AddCSLuaFile(path) end
	if (CLIENT) then include(path) end
end
	
function include_sh(path)
	if (SERVER) then AddCSLuaFile(path) end
	
	include(path)
end

GM.mod_sources = {}
GM.loaded      = {}

GM.config = {}

include_sv("configs/server.lua")
include_sh("configs/shared.lua")
include_cl("configs/client.lua")

function GM.dep(condition, name)
	if (not name) then return end
	if (not GM.mod_sources) then error("No such module: " .. name) end
	if (GM.loaded[ name ]) then return GM[ name ] end
	
	local fileData = include(GM.mod_sources[ name ])
	if (fileData) then GM[ name ] = fileData end

	GM.loaded[ name ] = true

	print("Loaded module: " .. name)

	return GM[ name ]
end

local modPath = GM.FolderName .. "/gamemode/core"
local _, folders = file.Find(modPath .. "/*", "LUA")
for k,dir in pairs(folders) do
	GM.mod_sources[ dir ] = modPath .. "/" .. dir .. "/module.lua"
end

for k,v in pairs(GM.mod_sources) do
	if not (GM[ k ]) then GM.dep(SHARED, k) end
end