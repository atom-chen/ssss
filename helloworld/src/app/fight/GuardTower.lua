

local GuardTower = class("GuardTower", cc.Node)

function GuardTower:ctor(baseImage, buildSize)
	self.baseImage = baseImage
	self.buildSize = buildSize
	local sp1 = cc.Sprite:create()
	sp1:setAnchorPoint(cc.p(0, 0))
	self:addChild(sp1, -1)
	self.sp1 = sp1

	local sp2 = cc.Sprite:create()
	sp2:setAnchorPoint(cc.p(0, 0))
	self:addChild(sp2, 1)
	self.sp2 = sp2

end

function GuardTower:createMan(owner)
	local cls = require("app.fight.RoleNode")
	if cls then
		local man = cls:create("action/wj1010_"..owner)
		man:setAnchorPoint(cc.p(0.5, 1))
		self:addChild(man)
		self.man = man
	else
		print("load app.fight.rolenode failed")
	end
end

function GuardTower:setOffY(offY)
	self.offY = offY
	self.sp1:setPosition(cc.p(0, offY))
	self.sp2:setPosition(cc.p(0, offY))
end

function GuardTower:setOwner(owner)
	local image = self.baseImage.."_"..owner.."1.png"
	self.sp1:setTexture(image)

	image = self.baseImage.."_"..owner.."2.png"
	self.sp2:setTexture(image)
	local size = self.sp1:getContentSize()
	self:setContentSize(cc.size(size.width, size.height + self.offY))

	if owner ~= 0 and self.man == nil then
		self:createMan(owner)
	end

	if self.man then
		local base = "action/wj1010_"..owner
		self.man:setBaseName(base)
		self.man:reset()
		local offys = {30, 36, 80}

		self.man:setPosition(cc.pSub(self:topCenter(), cc.p(0, offys[self.buildSize])))
	end
	
end

function GuardTower:setHighLight()
	self.sp1:setHighLight()
	self.sp2:setHighLight()
	if self.man then
		self.man:setHighLight()
	end
end

function GuardTower:setNormalLight()
	self.sp1:setNormalLight()
	self.sp2:setNormalLight()
	if self.man then
		self.man:setNormalLight()
	end

end


return GuardTower 

