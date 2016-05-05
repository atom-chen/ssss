

local BuildIcon = class("BuildIcon", cc.Sprite)

function BuildIcon:ctor(baseImage, buildSize)
	self.baseImage = baseImage
	self.buildSize = buidSize
end

function BuildIcon:setOffY(offY)
	--
end

function BuildIcon:setOwner(owner)
	local image = self.baseImage.."_"..owner..".png"
	self:setTexture(image)
end


return BuildIcon