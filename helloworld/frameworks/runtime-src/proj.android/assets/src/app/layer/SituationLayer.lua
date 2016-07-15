

local F = class("FlagNode", cc.Node)


function F:ctor(left, owner)
	self.num = 0
	self:setContentSize(cc.size(180, 40))

	local frame1 = cc.Sprite:create("frame/a50.png")
	self:addChild(frame1)
	local frame2 = cc.Sprite:create("frame/a49.png")
	self:addChild(frame2)

	if left then
		frame1:setAnchorPoint(cc.p(1, 0))
		frame1:setPosition(cc.p(180, 0))
		frame2:setAnchorPoint(cc.p(0, 0))
	else
		frame1:setAnchorPoint(cc.p(0, 0))
		frame2:setAnchorPoint(cc.p(1, 0))
		frame2:setPosition(cc.p(180, 0))
	end

	local lbl = cc.Label:createWithSystemFont("0", "Arial", 22, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	lbl:setTextColor(self:labelColor(owner))
	lbl:enableOutline(cc.num2c4b(0x401700ff), 2)
	
	lbl:setPosition(frame2:centerPos())
	frame2:addChild(lbl)
	self.label = lbl

	local image = "orn/b16_"..owner..".png"
	local flags = {}
	for i=1,5 do
		local flag = cc.Sprite:create(image)
		flag:setAnchorPoint(cc.p(0, 0.5))
		flag:setPosition(cc.p(16+(i-1)*25, 20))
		frame1:addChild(flag)
		flags[i] = flag
	end

	self.flags = flags

end

function F:labelColor(owner)
	if owner == kOnwerBlue then
		return cc.num2c4b(0x00e3ffff)
	else
		return cc.num2c4b(0xf70501ff)
	end

end

function F:setFlagNum(num)
	if self.num == num then
		return
	end
	
	self.num = num
	self.label:setString(num.."")
	for i=1,5 do
		self.flags[i]:setVisible(i <= num)
	end
end

local S = class("SituationLayer", cc.Layer)

cc.exports.SituationLayer = S

function S:ctor(left, right)
	self.leftOwner = left
	self.rightOwner = right
	local size = cc.Director:getInstance():getWinSize()
	self.leftGenerals = {}
	self.rightGenerals = {}

	self:createBar(size)

	self:createFlags(size)

end

function S:createBar(size)
	
	local bg = cc.Sprite:create("progressbar/b19_0.png")
	bg:setAnchorPoint(cc.p(1,1))
	bg:setPosition(cc.p(size.width, size.height))
	self:addChild(bg, 1)

	local red = cc.Sprite:create("progressbar/b19_"..self.rightOwner..".png")
	red:setAnchorPoint(cc.p(0, 0))
	red:setPosition(cc.p(27, 11))
	bg:addChild(red)

	local blue = cc.Sprite:create("progressbar/b19_"..self.leftOwner..".png")
	blue:setAnchorPoint(cc.p(0, 0))
	blue:setPosition(cc.p(27, 11))
	bg:addChild(blue)
	self.blueBar = blue

end

function S:createFlags(size)

	local pos = cc.p(size.width-192, size.height-25)
	local blue = F:create(true, kOwnerBlue)
	blue:setAnchorPoint(cc.p(1, 1))
	blue:setPosition(pos)
	self:addChild(blue)
	self.blueFlag = blue

	local red = F:create(false, kOwnerRed)
	red:setAnchorPoint(cc.p(0, 1))
	red:setPosition(pos)
	self:addChild(red)
	self.redFlag = red

end

function S:setFlagNum(left, right)
	self.blueFlag:setFlagNum(left)
	self.redFlag:setFlagNum(right)
	self.blueBar:setScaleX(left/(left+right))

end

function S:setGeneralNum(left, right)

	local size = cc.Director:getInstance():getWinSize()
	local w = 30
	local start1 = size.width - 282 - w / 2 * left

	local c1 = #self.leftGenerals

	for i=1, left-c1 do
		local general = cc.Sprite:create("b17_"..self.leftOwner..".png")
		general:setAnchorPoint(cc.p(0.5, 1))
		general:setPosition(cc.p(start1 + (i-0.5)*w, size.height-65))
		self:addChild(general)
		self.leftGenerals[c1+i] = general
	end

	local start2 = size.width - 102 - w / 2 * right
	local c2 = #self.rightGenerals
	for i=1, right-c2 do
		local general = cc.Sprite:create("b17_"..self.rightOwner..".png")
		general:setAnchorPoint(cc.p(0.5, 1))
		general:setPosition(cc.p(start2 + (i-0.5)*w, size.height-65))
		self:addChild(general)
		self.rightGenerals[c2+i] = general
	end

end

function S:generalDead(owner)

	if owner == self.leftOwner then
		local last = self.leftGenerals[#self.leftGenerals]
		last:removeFromParent(true)
		self.leftGenerals[#self.leftGenerals] = nil
	else
		local last = self.rightGenerals[#self.rightGenerals]
		last:removeFromParent(true)
		self.rightGenerals[#self.rightGenerals] = nil
	end

end

return S



