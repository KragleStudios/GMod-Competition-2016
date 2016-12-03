--Default ndoc tables

ndoc.table.gm = ndoc.table.gm or {}
ndoc.table.gm.Players = ndoc.table.gm.Players or {}

AddCSLuaFile("sh_init.lua")
AddCSLuaFile("player_extension.lua")
AddCSLuaFile("cl_init.lua")
include("player_extension.lua")
include("sh_init.lua")