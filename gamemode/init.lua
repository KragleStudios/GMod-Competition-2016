--Default ndoc tables

ndoc.table.gm = ndoc.table.gm or {}
ndoc.table.gm.Players = ndoc.table.gm.Players or {}
ndoc.table.pData = ndoc.table.pData or {}

AddCSLuaFile("sh_init.lua")
AddCSLuaFile("cl_init.lua")
include("sh_init.lua")

hook.Add("PlayerInitialSpawn", "SetupNdocTables", function(ply)
	ndoc.table.pData[ ply ] = {}
	ndoc.table.pData[ ply ].money = ply:GetPData("money") or gm.config.defaultMoney
end)

hook.Add("PlayerDisconnected", "RemoveNdocTables", function(ply)
	ndoc.table.pData[ ply ] = nil
end)