

local ProgressBar = class("ProgressBar", cc.Node)

function ProgressBar:ctor(bg, bar)
	local sp = cc.Sprite:create(bg)
	self:addChild(sp)
	local size = sp:getContentSize()
	self:setContentSize(size)

	local bsp = cc.Sprite:create(bar)
	bsp:setAnchorPoint(cc.p(0, 0.5))
	bsp:setPosition(cc.p(0, size.width/2))
	sp:addChild(bsp)
	self.bar = bsp

	local lbl = cc.Label:createWithSystemFont("", "Arial", 23)
	lbl:setAnchorPoint(cc.p(0.5, 0.5))
	lbl:setPosition(cc.p(size.width/2, size.height/2))
	sp:addChild(lbl)
	self.lbl = lbl


end

function ProgressBar:setPercent(percent)
	self.bar:setScaleX(percent)

end


return ProgressBar




