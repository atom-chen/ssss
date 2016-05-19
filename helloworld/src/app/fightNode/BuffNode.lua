
local M = class("Buff", cc.Node)

local kBuffTag = 100
local kBuffWidth = 40
local kBuffHeight = 40

function M:ctor(buff, delay)
	self.buff = buff

	local effect = cc.Sprite:create()
	effect:setAnchorPoint(cc.p(0.5, 0))
	effect:setPosition(cc.p(kBuffWidth/2, 0))
	self:addChild(effect)

	local path = self:buffPath(buff.SkillEffect)
	effect:playAnimate(path, kBuffTag, true, delay or kBuffAnimDelay)

	self.effect = effect
	-- local size = effect:getContentSize()
	self:setContentSize(cc.size(kBuffWidth, kBuffHeight))


	self.phyAttAdd = 0
	self.phyDefAdd = 0
	self.magicAttAdd = 0
	self.magicDefAdd = 0

	self:updateBuffNum(buff, 1)
	self.duration = buff.time
	-- self.addList = {}
	-- self.count = 0
	-- for _, v in pairs(buff.buffList) do
	-- 	self:updateBuffNum(v, 1)
	-- 	self.addList[#self.addList + 1] = clone(v)

	-- end

end

function M:buffPath(name)
	return "effect/"..name..".plist"
end

function M:updateDuration(dt)

	-- local last = {phyAttAdd = self.phyAttAdd, 
	-- 			  phyDefAdd = self.phyDefAdd, 
	-- 			  magicAttAdd = self.magicAttAdd, 
	-- 			  magicDefAdd = self.magicDefAdd}

	-- local pup = false

	if self.duration <= dt then
		return false
	end

	self.duration = self.duration - dt
	return true
	-- for i, v in pairs(self.addList) do
	-- 	if v.time <= dt then
	-- 		pup = true
	-- 		self:updateBuffNum(v, -1)
	-- 		self.addList[i] = nil
	-- 	else
	-- 		v.time = v.time - dt
	-- 	end
	-- end

end

-- ratio == 1 or -1   add or delete
function M:updateBuffNum(buff, ratio)

	if buff.buffType == 1 then
		self.phyAttAdd = self.phyAttAdd + buff.value * ratio
	elseif buff.buffType == 2 then
		self.phyDefAdd = self.phyDefAdd + buff.value * ratio
	end
	-- self.count = self.count + ratio
end


local B = class("BuffNode", cc.Node)

cc.exports.BuffNode = B

local kBuffColNum = 4


function B:ctor()
	self.buffList = {}
	self:setContentSize(cc.size(kBuffWidth * kBuffColNum, kBuffHeight))

	self.phyAttAdd = 0
	self.phyDefAdd = 0
	self.magicAttAdd = 0
	self.magicDefAdd = 0
	self.count = 0

end

function B:updateDuration(dt)

	local dup = false

	for i, v in pairs(self.buffList) do
		local last = v:updateDuration(dt)
		if not last then
			dup = true
			self:updateBuffNum(v, -1)
			
			v:removeFromParent(true)
			self.buffList[i] = nil
		end
	end

	if dup then
		self:updateBuffList()
	end

	return dup
end

function B:updateBuffNum(buff, ratio)

	-- if last then
	-- 	self.phyAttAdd = self.phyAttAdd - last.phyAttAdd
	-- 	self.phyDefAdd = self.phyDefAdd - last.phyDefAdd
	-- 	self.magicAttAdd = self.magicAttAdd - last.magicAttAdd
	-- 	self.magicDefAdd = self.magicDefAdd - last.magicDefAdd
	-- end

	self.phyAttAdd = self.phyAttAdd + buff.phyAttAdd * ratio
	self.phyDefAdd = self.phyDefAdd + buff.phyDefAdd * ratio
	self.magicAttAdd = self.magicAttAdd + buff.magicAttAdd * ratio
	self.magicDefAdd = self.magicDefAdd + buff.magicDefAdd * ratio
	self.count = self.count + ratio 
end

function B:updateBuffList()

	local count = 0
	local leftc = self.count
	local mc = math.min(kBuffColNum, leftc)
	local row = 0
	local sc = (kBuffColNum - mc) / 2

	for _, v in pairs(self.buffList) do
		if count >= kBuffColNum then
			count = 0
			leftc = leftc - kBuffColNum
			mc = math.min(kBuffColNum, leftc)
			row = row + 1
		end

		local col = count + sc

		v:setPosition(cc.p(col * kBuffWidth, row * kBuffHeight))

		count = count + 1
	end

end

function B:addBuff(buff, delay)
	-- print("add buff--", buff.id)
	local node = self.buffList[buff.id]
	if not node then
		node = M:create(buff, delay)
		node:setAnchorPoint(cc.p(0.5, 0))
		self:addChild(node)
		self:updateBuffNum(node, 1)
		self.buffList[buff.id] = node
		self:updateBuffList()
	else
		node.duration = buff.time
	end
	
	
	

end


return B




