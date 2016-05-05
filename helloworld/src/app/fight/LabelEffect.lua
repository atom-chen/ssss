
local LabelEffect = class("LabelEffect", cc.Node)

function LabelEffect:ctor()
	local lbl = cc.Label:createWithSystemFont("", "Arial", 23)
	lbl:setAnchorPoint(cc.p(0.5, 0))
	lbl:setPosition(cc.p(0, 0))
	self:addChild(lbl)
	self.lbl = lbl

end

function LabelEffect:showEffect(num)
	
	if num > 0 then
		self.lbl:setTextColor(cc.c4b(0, 255, 0, 255))
	else
		self.lbl:setTextColor(cc.c4b(255, 0, 0, 255))
	end

	self.lbl:setString(string.format("%d", num))

	self.lbl:setOpacity(255)

	local actions = {}
	actions[#actions + 1] = cc.Show:create()
	actions[#actions + 1] = cc.FadeOut:create(1)
	actions[#actions + 1] = cc.Hide:create()

	self.lbl:stopAllActions()
	self.lbl:runAction(cc.Sequence:create(actions))

end




return LabelEffect