ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Watermelon"
ENT.Author			= "crazyscouter"
ENT.Category        = gm.Name

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self.poisoned = false
		self:SetTrigger(true)
	end

	function ENT:Use(_, caller)
		if (caller:IsPlayer()) then

			hook.Call("sab_wmused", GAMEMODE, self, caller)
		end
	end

else
	function ENT:Draw()
		self:DrawModel()
	end
end
