

local B = class("NormalBuild", cc.Sprite)

cc.exports.NormalBuild = B

function B:ctor(baseImage, buildSize)
	self.baseImage = "building/"..baseImage
	self.buildSize = buidSize
	-- self:createTargetHalo()
end

function B:createTargetHalo()
	local halo = cc.Sprite:create("bg/b11.png")
	self:addChild(halo)
	self.targetHalo = halo
end

function B:setOffY(offY)
	--
end

function B:showColor(color)
	self:setColor(cc.c3b(color.r, color.g, color.b))
end

function B:setOwner(owner)
	local image = self.baseImage.."_"..owner..".png"
	self:setTexture(image)
	local size = self:getContentSize()
	-- self.targetHalo:setPosition(cc.p(size.width/2, size.height/2))
	
	return size
end


return B