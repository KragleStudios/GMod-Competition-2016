if (SERVER) then
	AddCSLuaFile()

	function meta:addMoney(amt)
		ndoc.table.pData[ self ].money = ndoc.table.pData[ self ].money + math.abs(amt)

		self:SetPData("money", ndoc.table.pData[ self ].money)
	end

	function meta:takeMoney(amt)
		ndoc.table.pData[ self ].money = ndoc.table.pData[ self ].money - math.abs(amt)

		self:SetPData("money", ndoc.table.pData[ self ].money)
	end

	function meta:setMoney(amt)
		ndoc.table.pData[ self ].money = math.abs(amt)

		self:SetPData("money", math.abs(amt))
	end
end

local meta = FindMetaTable("Player")
function meta:canAfford(amt)
	amt = math.abs(amt)

	return (ndoc.table.pData[ self ].money - amt) >= 0
end

function meta:getMoney()
	return ndoc.table.pData[ self ].money
end