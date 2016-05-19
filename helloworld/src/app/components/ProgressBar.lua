

local P = class("ProgressBar", cc.Node)

cc.exports.ProgressBar = P

function P:ctor(bg, bar, total)
	local sp = cc.Sprite:create("progressbar/"..bg)
	sp:setAnchorPoint(cc.p(0, 0))
	self:addChild(sp)
	local size = sp:getContentSize()
	self:setContentSize(size)

	local bsp = cc.Sprite:create("progressbar/"..bar)
	bsp:setAnchorPoint(cc.p(0, 0.5))
	bsp:setPosition(cc.p(0, size.height/2))
	sp:addChild(bsp)
	self.bar = bsp

	local lbl = cc.Label:createWithSystemFont(total.."/"..total, "Arial", 23)
	lbl:setPosition(cc.p(size.width/2, size.height/2))
	sp:addChild(lbl)
	self.lbl = lbl

	self.current = total
	self.total = total

end

function P:setBarNum(num)
	self.current = num
	self.lbl:setString(num.."/"..self.total)
	self.bar:setScaleX(num/self.total)

end


return P




