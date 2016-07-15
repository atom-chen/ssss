

local M = class("SkillNode", cc.Node)

cc.exports.SkillNode = M


function M:ctor(skillId)
	self.cfg = skills[skillId]

	local image = self:skillIconImage()
	local mask = cc.Sprite:create(image)
	mask:setGray()
	mask:setAnchorPoint(cc.p(0, 0))
	self:addChild(mask)

	local norm = cc.Sprite:create(image)
	local progress = cc.ProgressTimer:create(norm)
	progress:setAnchorPoint(cc.p(0, 0))
	self:addChild(progress)
	self.progress = progress

	self.cdTime = 0
	self.currentPercent = 100

	local size = mask:getContentSize()
	self:setContentSize(size)

	local selectIcon = cc.Sprite:create("frame/b2_3.png")
	-- selectIcon:setAnchorPoint(cc.p(0.5, 0.5))
	selectIcon:setPosition(cc.p(size.width/2, size.height/2))
	self:addChild(selectIcon)
	self.selectIcon = selectIcon
	selectIcon:setVisible(false)


	self:createCostIcon(self.cfg.skillcost, size)

end

function M:createCostIcon(num, size)
	local icon = cc.Sprite:create("frame/a47.png")
	local sz = icon:getContentSize()
	icon:setAnchorPoint(cc.p(0.5, 0))
	icon:setPosition(cc.p(size.width, -12))
	self:addChild(icon)
	local lbl = cc.Label:createWithSystemFont(""..num, "Arial", 18)
	lbl:enableOutline(cc.num2c4b(0x401700ff), 2)
	lbl:setAnchorPoint(cc.p(0.5, 0.5))
	lbl:setPosition(cc.p(sz.width/2, sz.height/2))
	icon:addChild(lbl)
end

function M:skillIconImage()
	return "icon/"..self.cfg.icon..".png"
end

function M:isSkillEnabled()
	return self.currentPercent >= 100
end

function M:skillCost()
	return self.cfg.skillcost
end

function M:select()
	self.selectIcon:setVisible(true)
end

function M:unselect()
	self.selectIcon:setVisible(false)
end

function M:setCDTime(cd)
	self.cdTime = cd
end

function M:updateCDTime(dt, totalTime, currentPoint)
	local cost = self.cfg.skillcost

	local cdp = 100
	local spp = 100
	if self.cdTime > 0 then
		self.cdTime = math.max(self.cdTime - dt, 0)
		cdp = (kSkillCDTime - self.cdTime) / kSkillCDTime * 100
	end

	if currentPoint < cost then
		-- print("current", currentPoint, "total", totalTime, "cost", cost)
		local maxTime = kSkillPointSpeed * cost
		local needTime = maxTime - currentPoint * kSkillPointSpeed - totalTime
		-- print("needTime", needTime, "maxTime", maxTime)
		spp = (maxTime - needTime) / maxTime * 100
	end
	
	-- print("cdp", cdp, "spp", spp)
	if cdp < 100 or spp < 100 then
		self.currentPercent = math.min(cdp, spp)
		self.progress:setPercentage(self.currentPercent)
	elseif self.currentPercent < 100 then
		self.currentPercent = 100
		self.progress:setPercentage(100)
	end




	-- print("draw-", self.cdTime)
	-- self.mask:clear()
	-- print("angle", self.cdTime/self.totalCD * 2 * math.pi)
	-- self.mask:drawSolidCircle(cc.p(0, 0), 45,  math.pi, 100, cc.c4f(0.3, 0.3, 0.3, 0.1))
	-- print("percent", (self.totalCD - self.cdTime) / self.totalCD)
	

end




return M



