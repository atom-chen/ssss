
local E = class("LabelEffect", cc.Node)

cc.exports.LabelEffect = E

local maxLblNum = 3
local lblOff = 25

function E:ctor()
	
	local list = {}
	for i=0,maxLblNum-1 do
		local lbl = cc.Label:createWithSystemFont("", "Arial", 23)
		lbl:setAnchorPoint(cc.p(0.5, 0))
		lbl:setPosition(cc.p(0, i*lblOff))
		self:addChild(lbl)
		list[i + 1]  = lbl
	end

	self.lblList = list
	self.currentIdx = 1

end

function E:showEffect(num)
	local lbl = self.lblList[self.currentIdx]
	for i=1,maxLblNum do
		local label = self.lblList[i]
		local offIdx = i - self.currentIdx

		if offIdx < 0 then
			offIdx = offIdx + maxLblNum
		end

		label:setPosition(cc.p(0, offIdx * lblOff))
	end

	if num > 0 then
		lbl:setTextColor(cc.c4b(0, 255, 0, 255))
	else
		lbl:setTextColor(cc.c4b(255, 0, 0, 255))
	end

	lbl:setString(string.format("%d", num))

	local actions = {}
	actions[#actions + 1] = cc.Show:create()
	actions[#actions + 1] = cc.FadeOut:create(3)
	actions[#actions + 1] = cc.Hide:create()

	lbl:stopAllActions()
	lbl:setOpacity(255)
	lbl:runAction(cc.Sequence:create(actions))

	self.currentIdx = self.currentIdx - 1
	if self.currentIdx == 0 then
		self.currentIdx = maxLblNum
	end

end




return E