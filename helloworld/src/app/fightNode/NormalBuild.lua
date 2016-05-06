

local B = class("NormalBuild", cc.Sprite)

cc.exports.NormalBuild = B

function B:ctor(baseImage, buildSize)
	self.baseImage = "building/"..baseImage
	self.buildSize = buidSize
end

function B:setOffY(offY)
	--
end

function B:setOwner(owner)
	local image = self.baseImage.."_"..owner..".png"
	self:setTexture(image)
	
	return self:getContentSize()
end


return B