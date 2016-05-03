local SoldierTopLbl = class("SoldierTopLbl", cc.Node)

local typeCfg = cc.exports.soldierType

function SoldierTopLbl:ctor(type)
	self.cfg = typeCfg[type]
	if not self.cfg then
		print("load soldier type failed! type id: ", type)
	end

	local image = self:typeImage()
	local sp = cc.Sprite:create(image)
	sp:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(sp)

	local lblbg = cc.Sprite:create("bg/b1_2.png")
	lblbg:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(lblbg)

	local sps = sp:getContentSize()
	local lbls = lblbg:getContentSize()
	local size = cc.size(sps.width + lbls.width, math.max(sps.height, lbls.height))
	self:setContentSize(size)

	sp:setPosition(cc.p(0, size.height/2))
	lblbg:setPosition(cc.p(sps.width, size.height/2))

	local numLbl = cc.Label:createWithSystemFont("", "Arial", 23)
	numLbl:setTextColor(cc.num2c4b(0xfffbf3))
	numLbl:enableOutline(cc.num2c4b(0x40f700), 2)
	numLbl:setPosition(lblbg:centerPos())
	lblbg:addChild(numLbl)
	self.numLbl = numLbl

	-- print("topLblsizex--", size.width, "y--", size.height)

end

function SoldierTopLbl:typeImage()
	return "icon/"..self.cfg.icon..".png"
end

function SoldierTopLbl:setSoldierNum(num)
	self.numLbl:setString(string.format("%d", num))
end


return SoldierTopLbl