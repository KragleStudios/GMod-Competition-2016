if (SERVER) then
	AddCSLuaFile()

	return
end

--todo: record whenever a player votes and what they voted for: key = game, value = {ply1, ply2, ..., plyn}
local votedFor = {}

--top 20% of panel is reserved for a header.
local function createGameVoteMenu()
	local base = vgui.Create("DFrame")
	base:SetWide(ScrW() * .7)
	base:SetTall(ScrH() * .7)
	base:MakePopup()
	base:Center()
	base:SetTitle("")

	local voteScroller = vgui.Create("DScrollPanel", base)
	voteScroller:SetWide(base:GetWide() - 20)
	voteScroller:SetTall(base:GetTall() * .8)
	voteScroller:SetPos(10, base:GetTall() * .2)

	local itemList = vgui.Create("DIconLayout", voteScroller)
	itemList:SetWide(voteScroller:GetWide())
	itemList:SetTall(voteScroller:GetTall())
	itemList:SetPos(0, 0)
	itemList:SetSpaceY(2)
	itemList:SetSpaceX(2)

	for k,v in ndoc.pairs(ndoc.table.gm.games) do
		local img = vgui.Create("DImageButton", itemList)
		img:SetSize(150, 300)
		img:SetImage( "scripted/breen_fakemonitor_1" )--v[ 2 ])

		local imgx, imgy = img:GetPos()
		img.info = vgui.Create("DPanel", img)
		img.info:SetSize(150, 200)
		img.info:SetPos(imgx, imgy + 300)

		local voteFor = vgui.Create("DButton", img.info)
		voteFor:SetPos(10, img.info:GetTall() - 45)
		voteFor:SetSize(img.info:GetWide() - 20, 35)
		voteFor:SetText("Vote For")
		
		function img.info:OnCursorExited()
			if (not img:IsHovered() and not voteFor:IsHovered()) then
				self:MoveTo(imgx, imgy + 300, 1)
			end
		end
		function img:OnCursorEntered()
			self.info:MoveTo(imgx, imgy + 100, 1)
		end
		function img:OnCursorExited()
			if (self.info and not self.info:IsHovered() and not voteFor:IsHovered()) then
				self.info:MoveTo(imgx, imgy + 300, 1)
			end
		end
		function voteFor:OnCursorExited()
			if (img.info and not img.info:IsHovered() and not self:IsHovered()) then
				img.info:MoveTo(imgx, imgy + 300, 1)
			end
		end


		local title = vgui.Create("DLabel", img.info)
		title:SetText(k)
		title:SetPos(10, 10)
		title:SizeToContents()

		local desc = vgui.Create("DLabel", img.info)
		desc:SetText(v[ 1 ])
		desc:SetPos(10, 30)
		desc:SetSize(img:GetWide() - 20, 20)
		desc:SetWrap(true)
		--desc:SizeToContents()
		desc:SetAutoStretchVertical(true)

		

	end
end
concommand.Add("vote", createGameVoteMenu)