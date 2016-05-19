


local M = class("FightProxy")


cc.exports.FightProxy = M


function M:ctor()

	self.attackTime = 0
	
	self.moveSpeed = 0
	self.attackSpeed = 0

	self.skillNode = nil

	self.phyAttAdd = 0
	self.phyDefAdd = 0
	self.magicAttAdd = 0
	self.magicDefAdd = 0

end

function M:currentPhyAttack()
	return self.phyAtt + self.phyAttAdd
end

function M:currentPhyDefence()
	return self.phyDef + self.phyDefAdd
end

function M:currentMagicAttack()
	return self.magicAtt + self.magicAttAdd
end

function M:currentMagicDefence()
	return self.magicDef + self.magicDefAdd
end

function M:updatePhyDefRatio()
	local def = self:currentPhyDefence() * 0.01
	self.phyRatio = (1-(def/(1+def*0.5)))/4
end

function M:updateMagicDefRatio()
	local def = self:currentMagicDefence() * 0.01
	self.magicRatio = (1-(def/(1+def*0.5)))/4
end

function M:setStandPos(pos)
	self.standPos = pos
	-- self.fightNode:setStandPos(pos)
end

-- function M:setFightPos(pos)
-- 	self.fightPos = pos
-- 	self.fightNode:setStandPos(pos)
-- end

-- function M:mergePos()
-- 	if self.standPos.x ~= self.fightPos.x or self.standPos.y ~= self.fightPos.y then
-- 		self:setFightPos(self.standPos)
-- 	end
-- end

function M:setPhyAttackAdd(add)
	self.phyAttAdd = add
end

function M:setPhyDefAdd(add)
	self.phyDefAdd = add
	self:updatePhyDefRatio()
end

function M:setMagicAttackAdd(add)
	self.magicAttAdd = add
end

function M:setMagicDefAdd(add)
	self.magicDefAdd = add
	self:updateMagicDefRatio()
end

function M:setTarget(target)
	self.target = target
	self.targetPos = nil
end

function M:setTargetPos(pos)
	self.targetPos = pos
	self.target = nil
end

function M:parseSoldierCfg(cfg, ident)
	self.phyAtt = cfg.physicalAtt
	self.phyDef = cfg.physicalDef
	self.phyRatio = (1-(cfg.physicalDef*0.01/(1+cfg.physicalDef*0.5*0.01)))/4
	self.magicDef = cfg.magicDef
	self.magicRatio = (1-(cfg.magicDef*0.01/(1+cfg.magicDef*0.5*0.01)))/4

	self.moveSpeed = cfg.moveSpeed
	self.attackSpeed = cfg.attackSpeed

	-- local fightNode = sgzj.FightNode:create(ident, phyAtt, phyDef, phyRatio, 0, magicDef, magicRatio)
	-- sgzj.FightManager:getInstance():addFightNode(fightNode)

	-- self.fightNode = fightNode
	self.skillNode = SkillManager:create(cfg.skillList)
end

function M:parseBuildingCfg(cfg, ident)
	self.phyAtt = cfg.physicalAtt
	self.phyDef = cfg.physicalDef * 1.25
	self.phyRatio = (1-(cfg.physicalDef*0.01/(1+cfg.physicalDef*0.5*0.01)))/4
	self.magicDef = cfg.magicDef * 1.25
	self.magicRatio = (1-(cfg.magicDef*0.01/(1+cfg.magicDef*0.5*0.01)))/4

	self.moveSpeed = cfg.moveSpeed
	self.attackSpeed = cfg.attackSpeed

	-- local fightNode = sgzj.FightNode:create(ident, phyAtt, phyDef, phyRatio, 0, magicDef, magicRatio)
	-- sgzj.FightManager:getInstance():addFightNode(fightNode)

	-- self.fightNode = fightNode

	self.skillNode = SkillManager:create(cfg.skillList)

end

function M:parseGeneralCfg(cfg, ident)
	self.phyAtt = cfg.strength * 0.6
	self.phyDef = cfg.strength * 0.5
	self.phyRatio = (1-(cfg.strength * 0.5 *0.01/(1+cfg.strength*0.5*0.01)))/4
	self.magicAtt = cfg.intellect * 0.65
	self.magicDef = cfg.intellect * 0.5
	self.magicRatio = (1-(cfg.intellect*0.5*0.01/(1+cfg.intellect*0.5*0.01)))/4
	self.health = cfg.lead

	self.moveSpeed = math.min(cfg.moveSpeed+cfg.lead/3, kMaxMoveSpeed)
	self.attackSpeed = cfg.attackSpeed
	
	-- local fightNode = sgzj.FightNode:create(ident, phyAtt, phyDef, phyRatio, magicAtt, magicDef, magicRatio, health)
	-- sgzj.FightManager:getInstance():addFightNode(fightNode)

	-- self.fightNode = fightNode

	self.skillNode = SkillManager:create(cfg.skillList, cfg.actionList)
end

function M:parsePropCfg(speed, skillId)
	self.moveSpeed = speed
	self.skillNode = SkillManager:create({skillId})

end

function M:updateMoveCoefficients(coeX, coeY)
	self.coeX = coeX
	self.coeY = coeY
end

function M:setStartTime(t)
	self.startTime = t
end

function M:reachPos(node)
	local target = self.target
	local pos = self.standPos
	local cp = target:centerPos()
	local minx = cp.x - target.acceptW
	local maxx = cp.x + target.acceptW
	-- local miny = cp.y - target.acceptH
	-- local maxy = cp.y + target.acceptH

	-- print("minx", minx, "miny", miny, "maxx", maxx, "maxy", maxy, "px", pos.x, "py", pos.y)

	if cp.x >= pos.x then
		return cc.p(minx - node.acceptW/2 + target.acceptW/4, cp.y)
	else
		return cc.p(maxx + node.acceptW/2 - target.acceptW/4, cp.y)
	end

end


function M:checkFightStatus(node)
	local tpos = nil
	-- local radius = self.skillNode:currentUseRange()
	if self.target then
		-- local tx, ty = self.target:centerPos()
		-- tpos = cc.p(tx, ty)
		-- radius = self.target:acceptRadius() + radius

		tpos = self:reachPos(node)


	elseif self.targetPos then
		tpos = self.targetPos
	end

	if not tpos then
		if not self.target then
			return kFightStatusNoTargetPos
		else
			return kFightStatusReach, self.target:centerPos()
		end
	end

	-- if not tpos then
	-- 	return kFightStatusNoTargetPos
	-- end

	local dis = cc.pGetDistance(self.standPos, tpos)
	if dis <= 1 then
		return kFightStatusReach, tpos, dis
	end

	return kFightStatusNotReach, tpos, dis

end

function M:fightStatus()
	return self.status
end

function M:setFightStatus(status)
	self.status = status
end

function M:resetAttackTime()
	self.attackTime = 0
end

function M:updateAttackSkill(dt)
	-- local status, tpos = self:attackStatus()
	-- if status ~= 1 then
	-- 	return status
	-- end
	if self.attackTime <= 0 then
		return
	end

	self.attackTime = self.attackTime - dt

end

function M:checkAttack()
	if self.attackTime <= 0 then
		self.attackTime = self.attackSpeed + self.attackTime
		return true, self.attackSpeed
	end

	return false

end

function M:checkMove(dt, node)
	
	local status, tpos, dis = self:checkFightStatus(node)
	self.status = status

	local tc = nil
	if self.target then
		tc = self.target:centerPos()
	else
		tc = tpos
	end

	if status ~= kFightStatusNotReach then
		if status == kFightStatusReach then
			return status, self.standPos.x < tc.x
		else
			return status
		end
	end
-- 使用当前路径的下一个移动点，如果目标位置移动，则重新计算。
	local p = cc.pSub(tpos, self.standPos)

	local nor = cc.pNormalize(p)
	local m = cc.pMul(nor, math.min(dt * self.moveSpeed, dis))
		-- print("mmm", m.x, m.y)
	local last = cc.pAdd(self.standPos, m)
	self:setStandPos(last)
	-- print("tpos --", tpos.x, tpos.y)
	-- print("last --", last.x, last.y)

	return status, last, self.standPos.x < tc.x

end

function M:checkAttackBack(target, ntype, ratio)
	-- local radius = self.skillNode:currentUseRange()
	-- local tx, ty = target:centerPos()
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


function M:isTargetGeneral()
	return self.target.type == kGeneralType
end

function M:isTargetBuildType()
	if not self.target then
		return false
	end
	
	return self.target.type == kBuildType

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

function M:updateTargetStatus()
	if not self.target then
		self.targetStatus = kTargetNone
		return
	end

	local status, invalid = pcall(function() return self.target:isInvalid() end)
	if status then
		if invalid then
			self.targetStatus = kTargetInvalid
		else
			self.targetStatus = kTargetValid
		end
	else
		self.targetStatus = kTargetDestroyed
	end

end

function M:isTargetGatherBuild()
	
end

function M:theSameOwner(owner)
	if self.target then
		return self.target.owner == owner
	end

	return false
end

-- function M:isRemoteDamage()
-- 	local skill = self.skillNode:currentSkill()
-- 	return skill.useRange > 1 or skill.damageRange > 0
-- end

function M:currentSkill()
	return self.skillNode:currentSkill()
end

function M:currentAction()
	return self.skillNode:currentAction()
end

function M:currentAttack(skill)

	if skill.damageType == kPhysicalType then
		return self:currentPhyAttack() * skill.value
	else
		return self:currentMagicAttack() * skill.value
	end

end

function M:handleDamageList(damageList, useRange, ratio, node)
	if #damageList == 0 then
		return
	end

	for _, v in pairs(damageList) do
		local skill = damageSkills[v]
		local range = skill.damageRange
		if range > 0 then
			-- sgzj.FightManager:getInstance():handleAOE(node:fightNode(), skill.damageType, self:currentAttack() * ratio, range)
			local scene = cc.Director:getInstance():getRunningScene()
			if scene.sceneType == kFightScene then
				if useRange > 1 then
					scene:handleAOE(node.owner, self.target:centerPos(), range, self:currentAttack(skill) * ratio, skill.damageType)
				else
					scene:handleAOE(node.owner, self.standPos, range, self:currentAttack(skill) * ratio, skill.damageType)
				end
			end
		else
			-- sgzj.FightManager:getInstance():handleFight(node:fightNode(), self.target:fightNode(), skill.damageType, self.currentAttack() * ratio, false)
			self.target:handleBeAttacked(self:currentAttack(skill) * ratio, skill.damageType)
			self.target:checkAutoAttack(node)
			if useRange <= 1 and self.target.type ~= kGeneralType then
				self.target:handleAttackBack(node)
			end
		end		
	end

end

function M:handleBuffList(buffList, node)
	if #buffList == 0 then
		return
	end

	for _, v in pairs(buffList) do
		local buff = buffSkills[v]
		local range = buff.damageRange

		if range > 0 then
			-- sgzj.FightManager:getInstance():handleAOE(node:fightNode(), skill.damageType, self:currentAttack() * ratio, range)
			local scene = cc.Director:getInstance():getRunningScene()
			if scene.sceneType == kFightScene then
				if buff.effectType == 5 then
					scene:handleAreaBuff(buff, self.standPos, range, node.owner)
				elseif buff.effectType == 2 then
					scene:handleAreaBuff(buff, self.target:centerPos(), range, node.owner)
				end
			end
		else
			-- sgzj.FightManager:getInstance():handleFight(node:fightNode(), self.target:fightNode(), skill.damageType, self.currentAttack() * ratio, false)
			if buff.effectType == 4 then
				node:handleBuff(buff)
			elseif buff.effectType == 1 then
				self.target:handleBuff(buff)
			end

		end		

	end

end

function M:handleAttack(node, ratio)
	-- if node.type == 3 then
		-- self.target:handleBeAttackedBySoldier(node)
	-- end
	if self.targetStatus ~= kTargetValid then
		return
	end

	local skill = self.skillNode:currentSkill()

	self:handleDamageList(skill.damageList, skill.useRange, ratio, node)

	self:handleBuffList(skill.buffList, node)

	self.skillNode:next()

end

function M:nextSkill()
	self.skillNode:next()
end

function M:handleGather(owner, num)
	self.target:handleGather(owner, num)
end

function M:getRealDamage(damage, dtype)
	local ratio = 1

	if dtype == kPhysicalType then
		ratio = self.phyRatio
	else
		ratio = self.magicRatio
	end

	local real = damage * ratio
	-- if ntype == kGeneralType then
		real = math.round(real)
	-- end

	return math.max(real, 1)

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

function M:handleDamage(damage)
	self.health = math.max(self.health - damage, 0)

end

function M:handleAttackBack(target, ratio)
	-- local skill = self.skillNode:currentSkill()
	-- sgzj.FightManager:getInstance():handleFight(node:fightNode(), target:fightNode(), skill.damageType, self.currentAttack() * ratio, true)
	-- 反伤 直接取物理伤害
	target:handleBeAttacked(self:currentPhyAttack() * ratio, 1)	
end


return M



