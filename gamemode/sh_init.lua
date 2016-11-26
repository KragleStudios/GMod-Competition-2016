DeriveGamemode("sandbox")

GAMEMODE.Name = ""
GAMEMODE.SmallName = ""
GAMEMODE.Author = "Mikey Howell, meharryrp, crazyscouter"
GAMEMODE.Email = ""
GAMEMODE.Website = "http://www.kraglestudios.com"

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

GAMEMODE.mod_sources = {}
GAMEMODE.loaded      = {}

GAMEMODE.config = {}

include_sv("configs/server.lua")
include_sh("configs/shared.lua")
include_cl("configs/client.lua")

function GAMEMODE.dep(condition, name)
	if (not name) then return end
	if (not GAMEMODE.mod_sources) then error("No such module: " .. name) end
	if (GAMEMODE.loaded[ name ]) then return GAMEMODE[ name ] end
	
	local fileData = include(GAMEMODE.mod_sources)
	if (fileData) then GAMEMODE[ name ] = fileData end

	GAMEMODE.loaded[ name ] = true

	print("Loaded module: " .. name)

	return GAMEMODE[ name ]
end

local modPath = GAMEMODE.FolderName .. "/gamemode/core"
for k,v in pairs(modPath) do
	local _, folders = file.Find(v .. "/*", "LUA")

	for k, dir in pairs(folders) do
		GAMEMODE.mod_sources[ dir ] = modPath .. "/" .. dir .. "/module.lua"
	end
end

for k,v in pairs(GAMEMODE.mod_sources) do
	if not (GAMEMODE[ k ]) then GAMEMODE.dep(SHARED, k) end
end