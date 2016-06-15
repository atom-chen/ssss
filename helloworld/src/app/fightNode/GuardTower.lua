

local G = class("GuardTower", cc.Node)

cc.exports.GuardTower = G

function G:ctor(baseImage, buildSize)
	self.baseImage = "building/"..baseImage
	self.buildSize = buildSize
	local sp1 = cc.Sprite:create()
	sp1:setAnchorPoint(cc.p(0, 0))
	self:addChild(sp1, -1)
	self.sp1 = sp1

	local sp2 = cc.Sprite:create()
	sp2:setAnchorPoint(cc.p(0, 0))
	self:addChild(sp2, 1)
	self.sp2 = sp2

	-- self:createTargetHalo()

end

function G:createMan(owner)

	local man = RoleNode:create("action/wj1010_"..owner, 162)
	man:setAnchorPoint(cc.p(0.5, 1))
	self:addChild(man)
	self.man = man

end

function G:createTargetHalo()
	local halo = cc.Sprite:create("bg/b11.png")
	self:addChild(halo)
	self.targetHalo = halo
end

function G:setOffY(offY)
	self.offY = offY
	self.sp1:setPosition(cc.p(0, offY))
	self.sp2:setPosition(cc.p(0, offY))
end

function G:setOwner(owner)
	local image = self.baseImage.."_"..owner.."1.png"
	self.sp1:setTexture(image)

	image = self.baseImage.."_"..owner.."2.png"
	self.sp2:setTexture(image)
	local size = self.sp1:getContentSize()
	local final = cc.size(size.width, size.height + self.offY)
	self:setContentSize(final)
	

	if owner ~= kOwnerNone then
		if self.man == nil then
			self:createMan(owner)
		end

		self.man:setVisible(true)
		local base = "action/wj1010_"..owner
		self.man:setBaseName(base)
		self.man:reset()
		local offys = {14, 20, 64}

		self.man:setPosition(cc.pSub(self:topCenter(), cc.p(0, offys[self.buildSize])))
	else
		if self.man then
			self.man:setVisible(false)
		end
	end

	return final
end

function G:showColor(color)
	self.sp1:setColor(cc.c3b(color.r, color.g, color.b))
	self.sp2:setColor(cc.c3b(color.r, color.g, color.b))
	if self.man then
		self.man:setColor(cc.c3b(color.r, color.g, color.b))
	end
end

function G:setHighLight()
	self.sp1:setHighLight()
	self.sp2:setHighLight()
	if self.man then
		self.man:setHighLight()
	end
end

function G:setNormalLight()
	self.sp1:setNormalLight()
	self.sp2:setNormalLight()
	if self.man then
		self.man:setNormalLight()
	end

end

function G:actStand()

end

function G:actAttack()

end


return G 

