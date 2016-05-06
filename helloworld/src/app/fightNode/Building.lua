


local B = class("Building", cc.Node)

cc.exports.Building = B


function B:ctor(cfg, owner, bedSize)

	self.cfg = cfg

	self.owner = owner
	self.type = kBuildType
	self.updating = false

	self.acceptR = bedSize.width/2
	self.bedSize = bedSize

	local soldierCfg = soldiers[cfg.soldierId]
	self.soldierCfg = soldierCfg

	self:createBuildIcon(cfg, bedSize)


	self:createTopLbl(soldierCfg, owner)
	self:createFightManager()

	self:createLabelEffect()

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

function B:createSoldier(target)
	if not target then
		return 
	end
	
		local num = math.floor(self.soldierNum/2)
		if num > 0 then
			self:setSoldierNum(self.soldierNum - num)
			-- return cls:create(scfg, self.owner, 36, target)
			return Soldier:create(self.soldierCfg, self.owner, num, target)
		end
end

function B:createFightManager(target)

	local manager = FightManager:create()
	manager:parseBuildingCfg(self.soldierCfg)
	self.fightManager = manager

end

function B:createTopLbl(scfg, owner)
	
	local topLbl = CampLabel:create(scfg.typeId, owner)
	topLbl:setAnchorPoint(cc.p(0.5, 0.5))
	self:addChild(topLbl)
	self.topLbl = topLbl
		
end



function B:setOwner(owner)
	self.owner = owner
	self:updateAppearance()
end

function B:setStandPos(pos)
	self:setPosition(cc.p(pos.x, pos.y-self.bedSize.height/2))
	self.fightManager:setStandPos(pos)
end

function B:setSoldierNum(num)
	self.soldierNum = num
	local lblNum = self.fightManager:displayNumber(num)
	self.topLbl:setSoldierNum(lblNum)
	return lblNum
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
	self.selected = true

end

function B:unselect()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	self.icon:setNormalLight()
	self:setScale(1)
	self.selected = false

end

function B:updateAppearance()

	-- print("building image--", image)
	local size = self.icon:setOwner(self.owner)
	self:setContentSize(size)
	-- print("contentsize, x-", s.width, "h-", s.height)
	self.topLbl:setOwner(self.owner)
	self.topLbl:setPosition(cc.p(size.width/2, size.height))

end



function B:updateSoldierNum()
	local num = math.floor(self.soldierNum)
	local cfg = self.cfg
	if num < cfg.capacity then
		self:setSoldierNum(self.soldierNum + cfg.riseSpeed * self.soldierCfg.riseRate)
	elseif num > cfg.capacity then
		local sub = self.soldierNum/cfg.capacity
		self:setSoldierNum(self.soldierNum - sub)
	end
end

function B:updateAttack(dt)
	

end

function B:startUpdateSoldierNum()
	if self.cfg.riseSpeed > 0 and self.owner ~= kOwnerNone and not self.updating then
		self.updating = true
		local scheduler = self:getScheduler()
		scheduler:scheduleScriptFunc(function(dt) self:updateSoldierNum() end, 1, false)
	end
end



function B:attackRatio()
	return math.max(self.soldierNum, 0)/25.0
end

function B:reachPos()
	return self.fightManager.standPos
end

function B:dispatchPos()
	return self.fightManager.standPos
end

function B:acceptRadius()
	return self.acceptR
end


function B:isTouchEnabled()
	return true
end

function B:isInvalid()
	return false
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


function B:showNumEffect(num)
	self.labelEffect:showEffect(num)
end

function B:checkAttackBack(node)
	local remote = node:isRemoteDamage()

	if not remote then
		self.fightManager:handleAttackBack(self.type, node, self:attackRatio())
	end
end

function B:handleDamage(damage)

	local last = self.fightManager:displayNumber(self.soldierNum)
	local currNum = self.soldierNum - damage
	local curr = self.fightManager:displayNumber(currNum)
	self:showNumEffect(curr - last)

	return curr
end

function B:handleGather(num)
	self:setSoldierNum(num + self.soldierNum)
end


function B:handleBeAttackedBySoldier(node, damage, dtype)
	local real = self.fightManager:getRealDamage(node.type, damage, dtype)
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

	self.fightManager:checkAttackBack(node, self.type, self:attackRatio())

end

function B:handleBeAttackedByGeneral(general, damage, dtype)
	local real = self.fightManager:getRealDamage(general.type, damage, dtype)

	local curr = self:handleDamage(real)
	
	if real > self.soldierNum then
		self.soldierNum = 0
		self.topLbl:setSoldierNum(0)
	else
		self.soldierNum = self.soldierNum - real
		self.topLbl:setSoldierNum(curr)
	end

	self.fightManager:checkAttackBack(general, self.type, self:attackRatio())

end


return B

