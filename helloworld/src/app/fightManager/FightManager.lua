


local M = class("FightManager")


cc.exports.FightManager = M


function M:ctor()

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

function M:createSkillNode(skillList, actionList)

	
	
end

function M:setStandPos(pos)
	self.standPos = pos
end

function M:setTarget(target)
	self.target = target
	self.targetPos = nil
end

function M:setTargetPos(pos)
	self.targetPos = pos
	self.target = nil
end

function M:parseSoldierCfg(cfg)
	self.phyAtt = cfg.physicalAtt
	self.phyDef = cfg.physicalDef
	self.phyRatio = (1-(cfg.physicalDef*0.01/(1+cfg.physicalDef*0.5*0.01)))/4
	self.magicDef = cfg.magicDef
	self.magicRatio = (1-(cfg.magicDef*0.01/(1+cfg.magicDef*0.5*0.01)))/4
	self.moveSpeed = cfg.moveSpeed
	self.attackSpeed = cfg.attackSpeed

	self.skillNode = SkillManager:create(cfg.skillList)
end

function M:parseBuildingCfg(cfg)
	self.phyAtt = cfg.physicalAtt
	self.phyDef = cfg.physicalDef * 1.25
	self.phyRatio = (1-(cfg.physicalDef*0.01/(1+cfg.physicalDef*0.5*0.01)))/4
	self.magicDef = cfg.magicDef * 1.25
	self.magicRatio = (1-(cfg.magicDef*0.01/(1+cfg.magicDef*0.5*0.01)))/4
	self.moveSpeed = cfg.moveSpeed
	self.attackSpeed = cfg.attackSpeed
	self.skillNode = SkillManager:create(cfg.skillList)

end

function M:parseGeneralCfg(cfg)
	self.phyAtt = cfg.strength * 0.75
	self.phyDef = cfg.strength * 0.5
	self.phyRatio = (1-(cfg.strength * 0.5 *0.01/(1+cfg.strength*0.5*0.01)))/4
	self.magicAtt = cfg.intellect * 0.85
	self.magicDef = cfg.intellect * 0.5
	self.magicRatio = (1-(cfg.intellect*0.5*0.01/(1+cfg.intellect*0.5*0.01)))/4
	self.moveSpeed = math.min(cfg.moveSpeed+cfg.lead/3, 500)
	self.attackSpeed = cfg.attackSpeed
	self.health = cfg.lead
	self.skillNode = SkillManager:create(cfg.skillList, cfg.actionList)
end

function M:checkAttack(dt)
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

function M:checkMove(dt)
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

function M:checkAttackBack(target, ntype, ratio)
	-- local radius = self.skillNode:currentUseRange()
	-- local tx, ty = target:reachPos()
	-- local tpos = cc.p(tx, ty)
	-- radius = target:acceptRadius() + radius

	-- if cc.pGetDistance(self.standPos, tpos) < radius then
	-- 	return true
	-- end

	-- return false

	local remote = target:isRemoteDamage()

	if not remote and not target:isInvalid() then
		self:handleAttackBack(ntype, target, ratio)
	end

end

function M:checkAutoFight(node)
	if self.target == nil then
		self:setTarget(node)
	end

end

function M:attackStatus()
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


function M:isTargetGeneral()
	return self.target.type == 2
end

function M:isTargetInvalid()
	-- return self.target == nil or self.target:isInvalid()
	if not self.target then
		return true
	end

	local status, invalid = pcall(function() return self.target:isInvalid() end)
	if status then
		return invalid
	end
	
	return true
end

function M:theSameOwner(owner)
	if self.target then
		return self.target.owner == owner
	end

	return false
end

function M:isRemoteDamage()
	local skill = self.skillNode:currentSkill()
	return skill.useRange > 1 or skill.damageRange > 0
end

function M:currentAction()
	return self.skillNode:currentAction()
end

function M:currentAttack()
	local skill = self.skillNode:currentSkill()
	if skill.damageType == kPhysicalType then
		return self.phyAtt * skill.value
	else 
		return self.magicAtt * skill.value
	end

end

function M:handleFight(node, ratio)
	-- if node.type == 3 then
		-- self.target:handleBeAttackedBySoldier(node)
	-- end
	local skill = self.skillNode:currentSkill()
	local range = skill.damageRange
	if range > 0 then
		local scene = cc.Director:getInstance():getRunningScene()
		if scene.sceneType ~= kFightScene then
			return
		end

		scene:handleAOE(node, self.standPos, range, self:currentAttack() * ratio, skill.damageType)

	elseif node.type == kSoldierType then
		self.target:handleBeAttackedBySoldier(node, self:currentAttack() * ratio, skill.damageType)
	elseif node.type == kGeneralType then
		self.target:handleBeAttackedByGeneral(node, self:currentAttack() * ratio, skill.damageType)
	end
	
	self.skillNode:next()

end

function M:handleGather(num)
	self.target:handleGather(num)
end

function M:getRealDamage(ntype, damage, dtype)
	local ratio = 1

	if dtype == kPhysicalType then
		ratio = self.phyRatio
	else
		ratio = self.magicRatio
	end

	local real = damage * ratio
	if ntype == kGeneralType then
		real = math.round(real)
	end

	return real

end

function M:displayNumber(num)
	if num <= 0 then
		return 0
	elseif num <= 1 then
		return 1
	else
		return math.floor(num)
	end
end

function M:handleHurt(damage)
	local last = math.floor(self.health)
	self.health = self.health - damage
	local curr = math.floor(self.health)
	return self.health > 0, curr - last
end

function M:handleAttackBack(ntype, target, ratio)
	local skill = self.skillNode:currentSkill()
	target:handleAttackBack(ntype, self:currentAttack() * ratio, skill.damageType)

end


return M



