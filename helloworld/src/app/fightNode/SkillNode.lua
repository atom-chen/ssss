

local M = class("SkillNode", cc.Node)

cc.exports.SkillNode = M



function M:ctor(skillId)
	self.cfg = skills[skillId]

	local image = self:skillIconImage()
	local norm = cc.Sprite:create(image)
	norm:setAnchorPoint(cc.p(0, 0))
	self:addChild(norm)

	local size = norm:getContentSize()
	self:setContentSize(size)

	local selectIcon = cc.Sprite:create("frame/b2_3.png")
	selectIcon:setAnchorPoint(cc.p(0.5, 0.5))
	selectIcon:setPosition(cc.p(size.width/2, size.height/2))
	self:addChild(selectIcon)
	self.selectIcon = selectIcon
	selectIcon:setVisible(false)

end

function M:skillIconImage()
	return "icon/"..self.cfg.icon..".png"
end

function M:select()
	self.selectIcon:setVisible(true)
end

function M:unselect()
	self.selectIcon:setVisible(false)
end







return M



