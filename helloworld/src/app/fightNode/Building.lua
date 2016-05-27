


local B = class("Building", cc.Node)

cc.exports.Building = B


function B:ctor(cfg, owner, bedSize, ident, halo)

	self.cfg = cfg
	self.ident = ident
	self.owner = owner
	self.type = kBuildType

	self.acceptW = bedSize.width/2
	self.acceptH = bedSize.height/2
	self.bedSize = bedSize
	self.halo = halo

	self.totalDamage = 0

	local soldierCfg = soldiers[cfg.soldierId]
	self.soldierCfg = soldierCfg

	self:createBuildIcon(cfg, bedSize)


	self:createTopLbl(soldierCfg, owner)

	self:createFightProxy(ident)

	self:createLabelEffect()
	self:createTargetHalo()
	self:updateAppearance()

end

function B:createBuildIcon(cfg, bedSize)

	local cls = nil
	local offY = 0
	if self:isGuardTower(cfg.id) then
		cls = GuardTower
		offY = bedSize.height/4
	else
		cls = NormalBuild
	end

	local icon = cls:create(cfg.icon, cfg.size)
	icon:setOffY(offY)
	icon:setAnchorPoint(cc.p(0, 0))
	self.icon = icon
	self:addChild(self.icon)	
	
end

function B:createLabelEffect()

	local effect = LabelEffect:create()
	effect:setAnchorPoint(cc.p(0.5, 0))
	effect:setPosition(self.topLbl:topCenter())
	self.topLbl:addChild(effect)
	self.labelEffect = effect

end

function B:createSoldier(target, ident)
	if not target then
		return 
	end
	
		local num = math.floor(self.soldierNum/2)
		if num > 0 then
			self:setSoldierNum(self.soldierNum - num)
			-- return cls:create(scfg, self.owner, 36, target)
			return Soldier:create(self.soldierCfg, self.owner, num, target, ident)
		end
end

function B:createFightProxy(ident)

	local proxy = FightProxy:create(ident)
	proxy:parseBuildingCfg(self.soldierCfg, ident)
	self.fightProxy = proxy

end

function B:createTopLbl(scfg, owner)
	
	local topLbl = CampLabel:create(scfg.typeId, owner)
	topLbl:setAnchorPoint(cc.p(0.5, 0.5))
	self:addChild(topLbl)
	self.topLbl = topLbl
		
end

function B:createFlightProp()
	local prop = FlightProp:create(self.fightProxy.target, self.cfg.skillId)

	return prop
end

function B:createTargetHalo()
	local halo = cc.Sprite:create("bg/b11.png")
	self:addChild(halo)
	halo:setVisible(false)
	self.targetHalo = halo
end


function B:setOwner(owner)
	if self.owner == owner then
		return
	end
	
	if owner == kOwnerNone then
		self.status = kBuildStatusInvalid
	else
		self.status = kBuildStatusNormal
	end

	self.owner = owner
	self:updateAppearance()
	
end

function B:setStandPos(pos)
	self:setPosition(cc.p(pos.x, pos.y-self.bedSize.height/2))
	self.fightProxy:setStandPos(pos)
end

function B:setSoldierNum(num)
	self.soldierNum = num
	local lblNum = self.fightProxy:displayNumber(num)
	self.topLbl:setSoldierNum(lblNum)
	return lblNum
end

function B:showHalo(show)
	if self.owner == kOwnerNone then
		return
	end

	self.halo:setVisible(show)
end

function B:showTargetHalo(show)
	self.targetHalo:setVisible(show)
end

function B:isGuardTower(buildId)
	return buildId == 4 or buildId == 5 or buildId == 6
end

function B:select()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureHightLight")
	-- sp:setGLProgram(program)
	self.icon:setHighLight()
	self:setScale(1.3)
	self.halo:setScale(1.3)
	self.selected = true

end

function B:unselect()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	self.icon:setNormalLight()
	self:setScale(1)
	self.halo:setScale(1)
	self.selected = false
	self.targetHalo:setVisible(false)
	self.halo:setVisible(false)
end

function B:updateAppearance()

	-- print("building image--", image)
	local size = self.icon:setOwner(self.owner)
	self:setContentSize(size)
	-- print("contentsize, x-", s.width, "h-", s.height)
	self.topLbl:setOwner(self.owner)
	self.topLbl:setPosition(cc.p(size.width/2, size.height))

	if owner ~= kOwnerNone then
		self.halo:setTexture("bg/b10_"..self.owner..".png")
	end
	self.targetHalo:setPosition(cc.p(size.width/2, size.height/2))

end



function B:updateSoldierNum()
	local num = math.floor(self.soldierNum)
	local cfg = self.cfg
	if cfg.riseSpeed > 0 and num < cfg.capacity then
		self:setSoldierNum(self.soldierNum + cfg.riseSpeed * self.soldierCfg.riseRate)
	elseif num > cfg.capacity then
		local sub = self.soldierNum/cfg.capacity
		self:setSoldierNum(self.soldierNum - sub)
	end
end

function B:actAttack()

end

function B:updateFace()

end

function B:updateAttack(dt)
	self.fightProxy:updateAttackSkill(dt)
	self.fightProxy:updateTargetStatus()

	if self.fightProxy.targetStatus ~= kTargetValid or self.status ~= kBuildStatusNormal then
		return
	end

	local status, rate = self.fightProxy:checkAttack()

	if status then
		self.status = kBuildStatusAttack
		self:updateFace()
		self:actAttack()
	else
		self.status = kBuildStatusNormal
	end

end

function B:startUpdateSoldierNum()
	if self.owner ~= kOwnerNone and not self.entryId then
		local scheduler = self:getScheduler()
		self.entryId = scheduler:scheduleScriptFunc(function(dt) self:updateSoldierNum() end, 1, false)
	end
end

function B:stopUpdateSoldierNum()
	if self.entryId then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.entryId)
		self.entryId = nil
	end
end


function B:attackRatio()
	return math.max(self.soldierNum, 0)*0.25
end

function B:centerPos()
	return self.fightProxy.standPos
end

function B:fightNode()
	return self.fightProxy.fightNode
end

function B:dispatchPos()
	return self.fightProxy.standPos
end


function B:isTouchEnabled()
	return true
end

function B:isInvalid()
	return self.soldierNum <= 0
end

function B:isAttackBuild()
	return self.cfg.skillId ~= 15
end

function B:aim()

end

function B:fire()

end

function B:battle()

end


function B:showDamageEffect()
	self.labelEffect:showEffect(-self.totalDamage)

	if self.owner == kOwnerNone then
		self.icon:showColor(cc.num2c4b(0xc2c2c2ff))
	elseif self.owner == kOwnerPlayer then
		self.icon:showColor(cc.num2c4b(0x177afdff))
	else
		self.icon:showColor(cc.num2c4b(0xfe252aff))
	end

	local actions = {}
	actions[#actions + 1] = cc.DelayTime:create(0.1)
	actions[#actions + 1] = cc.CallFunc:create(function() self.icon:showColor(cc.c3b(255, 255, 255)) end)
	local seq = cc.Sequence:create(actions)
	seq:setTag(kBeAttackedTag)
	self:stopActionByTag(kBeAttackedTag)
	self:runAction(seq)
end

-- function B:checkAttackBack(node)
-- 	local remote = node:isRemoteDamage()

-- 	if not remote then
-- 		self.fightProxy:handleAttackBack(self.type, node, self:attackRatio())
-- 	end
-- end

function B:addDamage(damage)

end

function B:checkAutoAttack(node)
	
end


function B:handleDamage()

	-- local last = self.fightProxy:displayNumber(self.soldierNum)
	-- local currNum = self.soldierNum - damage
	-- local curr = self.fightProxy:displayNumber(currNum)
	-- self:showNumEffect(curr - last)

	-- return curr
	if self.totalDamage == 0 then
		return 
	end

	self:showDamageEffect()

	if self.totalDamage >= self.soldierNum then
		self:setOwner(kOwnerNone)
		self.soldierNum = 0
		self.topLbl:setSoldierNum(0)
		self:stopUpdateSoldierNum()
	else
		self:setSoldierNum(self.soldierNum - self.totalDamage)
	end

	self.totalDamage = 0


end

function B:handleAttackBack(node)
	self.fightProxy:handleAttackBack(node, self:attackRatio())
end

function B:handleGather(owner, num)
	self:setOwner(owner)
	self:setSoldierNum(num + self.soldierNum)
	self:startUpdateSoldierNum()
end

function B:handleBeAttacked(damage, dtype)
	local real = self.fightProxy:getRealDamage(damage, dtype)
	self.totalDamage = self.totalDamage + real

end

function B:handleBeAttackedBySoldier(node, damage, dtype)
	local real = self.fightProxy:getRealDamage(node.type, damage, dtype)
	local curr = self:handleDamage(real)

	if real > self.soldierNum then
		self:setOwner(node.owner)
		self.soldierNum = 0
		self.topLbl:setSoldierNum(0)
		self:startUpdateSoldierNum()
	else
		self.soldierNum = self.soldierNum - real
		self.topLbl:setSoldierNum(curr)
	end

	self.fightProxy:checkAttackBack(node, self.type, self:attackRatio())

end

function B:handleBeAttackedByGeneral(general, damage, dtype)
	local real = self.fightProxy:getRealDamage(general.type, damage, dtype)

	local curr = self:handleDamage(real)
	
	if real > self.soldierNum then
		self.soldierNum = 0
		self.topLbl:setSoldierNum(0)
	else
		self.soldierNum = self.soldierNum - real
		self.topLbl:setSoldierNum(curr)
	end

	self.fightProxy:checkAttackBack(general, self.type, self:attackRatio())

end


return B

