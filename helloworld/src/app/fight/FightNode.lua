


local FightNode = class("FightNode")


function FightNode:ctor()

	self.attackRate = 0
	self.attackTime = 0
	self.phyAtt = 0
	self.phyDef = 0
	self.phyRatio = 0
	self.magicAtt = 0
	self.magicDef = 0
	self.magitRatio = 0
	self.moveSpeed = 0
	self.attackSpeed = 0
	self.skillNode = nil
	self.health = 0

end

function FightNode:createSkillNode(list)
	local cls = require("app.fight.SkillNode")
	if cls then
		self.skillNode = cls:create(list)
	else
		print("load app.fight.SkillNode failed")
	end
end

function FightNode:setStandPos(pos)
	self.standPos = pos
end

function FightNode:setTarget(target)
	self.target = target
	self.targetPos = nil
end

function FightNode:setTargetPos(pos)
	self.targetPos = pos
	self.target = nil
end

function FightNode:parseSoldierCfg(cfg)
	self.phyAtt = cfg.physicalAtt
	self.phyDef = cfg.physicalDef
	self.phyRatio = (1-(cfg.physicalDef*0.01/(1+cfg.physicalDef*0.5*0.01)))/4
	self.magicDef = cfg.magicDef
	self.magicRatio = (1-(cfg.magicDef*0.01/(1+cfg.magicDef*0.5*0.01)))/4
	self.moveSpeed = cfg.moveSpeed
	self.attackSpeed = cfg.attackSpeed
	self:createSkillNode(cfg.skillList)
end

function FightNode:parseGeneralCfg(cfg)
	self.phyAtt = cfg.strength * 0.75
	self.phyDef = cfg.strength * 0.5
	self.phyRatio = (1-(cfg.strength * 0.5 *0.01/(1+cfg.strength*0.5*0.01)))/4
	self.magicAtt = cfg.intellect * 0.85
	self.magicDef = cfg.intellect * 0.5
	self.magicRatio = (1-(cfg.intellect*0.5*0.01/(1+cfg.intellect*0.5*0.01)))/4
	self.moveSpeed = math.min(50+cfg.lead/3, 500)
	self.attackSpeed = cfg.attackSpeed
	self.health = cfg.lead
	self:createSkillNode(cfg.skillList)
end

function FightNode:checkAttack(dt)
	local status, tpos = self:attackStatus()
	if status ~= 1 then
		return status
	end

	self.attackTime = self.attackTime + dt
	if self.attackTime >= self.attackRate then
		self.attackTime = self.attackTime - self.attackRate
		return status, self.attackRate, self.standPos.x < tpos.x
	end

	return status
end

function FightNode:attackStatus()
	local tpos = nil
	local radius = self.skillNode:currentUseRange()
	if self.target then
		local tx, ty = self.target:reachPos()
		tpos = cc.p(tx, ty)
		radius = self.target:acceptRadius() + radius
	elseif self.targetPos then
		tpos = self.targetPos
	end

	if not tpos then
		return -1
	end

	if cc.pGetDistance(self.standPos, tpos) < radius then
		return 1, tpos
	end

	return 0, tpos

end

function FightNode:checkMove(dt)
	local status, tpos = self:attackStatus()

	if status ~= 0 then
		return status
	end

	local p = cc.pSub(tpos, self.standPos)
	local m = cc.pMul(cc.pNormalize(p), dt * self.moveSpeed)
		-- print("mmm", m.x, m.y)
	local last = cc.pAdd(self.standPos, m)
	self.standPos = last

	return status, last, last.x < tpos.x

end

function FightNode:isTargetGeneral()
	return self.target.type == 2
end

function FightNode:isTargetPos()
	return self.targetPos ~= nil
end

function FightNode:theSameStamp(owner)
	if self.target then
		return self.target.owner == owner
	end

	return false
end

function FightNode:handleFight(node)
	if node.type == 3 then
		self.target:handleBeAttackedBySoldier(node)
	end
end





return FightNode


