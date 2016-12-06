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
		self:SetModel("models/props_interiors/BathTub01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self:SetTrigger(true)
	end

	function ENT:Touch(wm)
		if (wm:GetClass() ~= "sab_watermelon") then return end

		if (wm.poisoned) then
			self:SetPoisoned(true)
		else
			self:SetPoisoned(false)
		end
	end

	function ENT:EndTouch(ent)
		if (ent:GetClass() ~= "sab_watermelon") then return end

		self:SetPoisoned(false)
	end

	function ENT:Think()
		self:SetVelocity(Vector(0, 0, 0))
	end


else

	function ENT:Draw()
		self:DrawModel()

		self:SetColor(self:GetPoisoned() and Color(0, 255, 0) or Color(255, 0, 0))
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Poisoned")
end