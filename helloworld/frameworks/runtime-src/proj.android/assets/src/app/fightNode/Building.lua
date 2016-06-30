


local B = class("Building", sgzj.RoleNode)

cc.exports.Building = B

local kAttackHaloR = 107

function B:ctor(cfg, owner, bedSize, ident, halo)
	self:enableNodeEvents()
	self.cfg = cfg
	self.ident = ident
	self.owner = owner
	self.type = kBuildType
	self.halo = halo
	self.canAttackBack = true
	
	self.acceptR = math.min(bedSize.width/2, bedSize.height/2)
	self.bedSize = bedSize

	self.targetList = {}
	local sq2 = math.sqrt(2)/2
	self.siteList = {{id=1,ref=0, dir={x=0,y=-1}}, 
					{id=2,ref=0, dir={x=-sq2, y=-sq2}}, 
					{id=3,ref=0, dir={x=-1, y=0}}, 
					{id=4,ref=0, dir={x=-sq2, y=sq2}}, 
					{id=5,ref=0, dir={x=0, y=1}}, 
					{id=6,ref=0, dir={x=sq2, y=sq2}}, 
					{id=7,ref=0, dir={x=1, y=0}}, 
					{id=8,ref=0, dir={x=sq2, y=-sq2}}}
	
	self.totalDamage = 0

	-- self.FSM = StateMachine:create()
	
	local soldierCfg = soldiers[cfg.soldierId]
	self.soldierCfg = soldierCfg
	
	self:createBuildIcon(cfg, bedSize, ident)
	
	self:createTopLbl(soldierCfg, owner)
	
	self:createFightProxy(ident)

	self:createFSM()
	
	self:createLabelEffect()
	self:createTargetHalo()
	self:updateAppearance()
	
end

function B:onExit()
	self:destroy()
end

function B:destroy()
	self:stopUpdateSoldierNum()
	self:stopAttack()
end

function B:createFSM()

	self.FSM = StateMachine:create()
	self.FSM:bindStateCallback(kRoleStateStand, function() self:actStand() end)
	self.FSM:bindStateCallback(kRoleStateAttack, function() self:actAttack() end)
	self.FSM:bindStateCallback(kRoleStateDead, function() self:actDead() end)

end

function B:createBuildIcon(cfg, bedSize, ident)
	
	local cls = nil
	local offY = 0
	
	local baseScale = 0.3 + cfg.size * 0.05
	if cfg.id == 4 or cfg.id == 5 or cfg.id == 6 then
		cls = GuardTower
		offY = bedSize.height/4
	elseif cfg.id == 7 or cfg.id == 8 or cfg.id == 9 then
		cls = Demolisher
	else
		cls = NormalBuild
		baseScale = 0.4 + cfg.size * 0.2
	end
	self.baseScale = baseScale
	self.halo:setScale(baseScale)
	
	local icon = cls:create(cfg.icon, cfg.size, ident)
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
	proxy:parseBuildingCfg(self.soldierCfg, ident, self.cfg)
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

function B:bindPropCallback(callback)
	self.propCallback = callback
end

function B:bindOwnerCallback(callback)
	self.ownerCallback = callback
end

function B:getStepAndIdx(pos)
	local sp = self.fightProxy.standPos
	local dir = cc.pSub(pos, sp)
	local startIdx = 0
	local angle = cc.pToAngleSelf(dir)

	local r1 = math.pi * 0.125
	local r2 = math.pi * 0.375
	local r3 = math.pi * 0.625
	local r4 = math.pi * 0.875
	
	-- print("dirx-", dir.x, "diry-", dir.y, "angle-", angle)
	local mid = 0
	if angle < r1 and angle >= -r1 then
		startIdx = 7
		mid = 0
	elseif angle < -r1 and angle >= -r2 then
		startIdx = 8
		mid = (-r1-r2)/2
	elseif angle < -r2 and angle >= -r3 then
		startIdx = 1
		mid = (-r2-r3)/2
	elseif angle < -r3 and angle >= -r4 then
		startIdx = 2
		mid  =(-r3-r4)/2
	elseif angle < -r4 or angle >= r4 then
		startIdx = 3
		mid = math.pi
	elseif angle < r4 and angle >= r3 then
		startIdx = 4
		mid = (r4+r3)/2
	elseif angle < r3 and angle >= r2 then
		startIdx = 5
		mid = (r3+r2)/2
	elseif angle < r2 and angle >= r1 then
		startIdx = 6
		mid = (r2+r1)/2
	end

	local startStep = 1
	if startIdx == 3 then
		if angle > 0 then
			startStep = 1
		else
			startStep = -1
		end
	else
		if angle > mid then
			startStep = -1
		else
			startStep = 1
		end
	end
	return startIdx, startStep
end

function B:sortSiteList(pos)
	local startIdx, startStep = self:getStepAndIdx(pos)
	-- for _, v in pairs(self.siteList) do
	-- 	print(v.ref)
	-- end

	table.sort(self.siteList, function(a,b)
		-- if a.ref == b.ref then
			local step1 = a.id-startIdx
			if step1 < -4 then
				step1 = step1 + 8
			end
			if step1 > 4 then
				step1 = step1 - 8
			end
			local step2 = b.id-startIdx
			if step2 < -4 then
				step2 = step2 + 8
			end
			if step2 > 4 then
				step2 = step2 - 8
			end

			local abs1 = math.abs(step1)
			local abs2 = math.abs(step2)
			-- print("a-", a.id, "b-", b.id, "step1-", step1, "step2-", step2)
			if abs1 == abs2 then
				if startStep < 0 then
					-- print("step1 < step2 -", step1 < step2)
					return step1 < step2
				else
					-- print("step1 > step2 -", step1 > step2)
					return step1 > step2
				end
			else
				-- print("-", abs1 < abs2)
				return abs1 < abs2
			end
		-- else
			-- return a.ref < b.ref
		-- end
	end)
	return startIdx, startStep
end

function B:acceptSite(pos, acceptR)
	
	local startIdx, startStep = self:sortSiteList(pos)
	-- print("startIdx-", startIdx, "startStep-", startStep)
	local pl1 = {}
	local pl2 = {}
	local flag1 = true
	local flag2 = true
	local flag = true
	local fidx = 0
	for i, v in ipairs(self.siteList) do
		local p = cc.pAdd(cc.pMul(v.dir, self.acceptR+acceptR), self.fightProxy.standPos)
		if sgzj.RoleNode:isPointCanReach(p) then
			-- print("can reach")
			if v.ref == 0 then
				fidx = v.id

				if not flag1 then
					flag = false
				elseif not flag2 then
					flag = true
				else
					if startStep < 0 then
						flag = i % 2 == 0
					else
						flag = i % 2 == 1
					end
				end

				if startStep < 0 then
					if flag then
						startIdx = self.siteList[2].id
					end
				else
					if not flag then
						startIdx = self.siteList[2].id
					end
				end

				break
			end
		else
			if i % 2 == 0 then
				if startStep < 0 then
					flag1 = false
				else
					flag2 = false
				end
			else
				if startStep < 0 then
					flag2 = false
				else
					flag1 = false
				end
			end
		end
	end

	-- print("fidx-", fidx, "flag1-", flag1, "flag2-", flag2)
	if fidx == 0 then
		return
	end

	if not flag1 and not flag2 then
		return
	end

	table.sort(self.siteList, function(a,b) return a.id < b.id end)
	local fl = {}
	fl[#fl + 1] = cc.pAdd(cc.pMul(self.siteList[startIdx].dir, self.acceptR+acceptR), self.fightProxy.standPos)
	if flag then
		while startIdx ~= fidx do
			startIdx = startIdx - 1
			if startIdx == 0 then
				startIdx = 8
			end
			fl[#fl+1] = cc.pAdd(cc.pMul(self.siteList[startIdx].dir, self.acceptR+acceptR), self.fightProxy.standPos)
		end
	else
		while startIdx ~= fidx do
			startIdx = startIdx + 1
			if startIdx > 8 then
				startIdx = 1
			end
			fl[#fl+1] = cc.pAdd(cc.pMul(self.siteList[startIdx].dir, self.acceptR+acceptR), self.fightProxy.standPos)
		end
	end
	return fl, self.siteList[fidx]
end

function B:siteIndex()

end

function B:setOwner(owner)
	if self.owner == owner then
		return
	end
	
	-- if owner == kOwnerNone then
	-- 	self.status = kBuildStatusInvalid
	-- else
	-- 	self.status = kBuildStatusNormal
	-- end
	local from = self.owner
	self.owner = owner
	self:updateAppearance()
	self:checkAttack(function() self.FSM:setState(kRoleStateAttack) end)
	if self.ownerCallback then
		self.ownerCallback(from, owner)
	end

end

function B:setAttackHalo(halo)
	self.attackHalo = halo
	local r = self.fightProxy:currentUseRange()
	halo:setScale(r/kAttackHaloR)
	self:updateAttackHalo()
end

function B:setStandPos(pos)
	self:setPosition(pos)
	self.fightProxy:setStandPos(cc.p(pos.x, pos.y+self.bedSize.height/2))
end

function B:setSoldierNum(num)
	self.soldierNum = num
	local lblNum = self.fightProxy:displayNumber(num)
	self.topLbl:setSoldierNum(lblNum)
	return lblNum
end

function B:targetInAttackScope(target)
	self.targetList[#self.targetList + 1] = target

	self:checkAttack(function() self.FSM:setState(kRoleStateAttack) end)

	-- print("target in attack scope")
end

function B:targetOutAttackScope(target)
	-- self.targetList[target.ident] = nil
	local list = self.targetList
	for i=#list, 1, -1 do
		if list[i] == target then
			table.remove(list, i)
			break
		end
	end

	-- self:checkAttack(function() self.FSM:setState(kRoleStateAttack) end)

	-- print("target out attack scope")
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

function B:showAttackHalo(show)
	if self.attackHalo then
		-- print("show halo -", show, "r-", self.attackHalo:getScale())
		self.attackHalo:setVisible(show)
	end
end

function B:isDead()
	local state = self.FSM:currentState()
	return state == kRoleStateDead or state == kRoleStateClear
end

function B:isGuardTower(buildId)
	return buildId == 4 or buildId == 5 or buildId == 6
end

function B:select()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureHightLight")
	-- sp:setGLProgram(program)
	if self.selected then
		return
	end

	self.icon:setHighLight()
	self:setScale(1.3)
	self.halo:setScale(1.3 * self.baseScale)
	self.selected = true

end

function B:unselect()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	if not self.selected then
		return
	end

	self.icon:setNormalLight()
	self:setScale(1)
	self.halo:setScale(self.baseScale)
	self.selected = false
	self.targetHalo:setVisible(false)
	self.halo:setVisible(false)
	self:showAttackHalo(false)
end

function B:updateAppearance()

	-- print("building image--", image)
	local size = self.icon:setOwner(self.owner)
	self:setContentSize(size)
	-- print("contentsize, x-", size.width, "h-", size.height)
	self.topLbl:setOwner(self.owner)
	self.topLbl:setPosition(cc.p(size.width/2, size.height))

	if self.owner ~= kOwnerNone then
		self.halo:setTexture("bg/b10_"..self.owner..".png")
	end
	
	self:updateAttackHalo()
	self.targetHalo:setPosition(cc.p(size.width/2, size.height/2))

end

function B:updateAttackHalo()
	if self.owner == kOwnerNone then
		return
	end

	if self.attackHalo then
		self.attackHalo:setTexture("bg/b15_"..self.owner..".png")
	end
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

function B:stopAttack()

	if self.attackEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.attackEntry)
		self.attackEntry = nil
	end

end

function B:checkAttack(callback)
	self:updateTargetList()

	local target = nil
	for i=1, #self.targetList do
		local v = self.targetList[i]
		if v.owner ~= self.owner then
			target = v
			break
		end
	end

	if target then
		if self.owner ~= kOwnerNone then
			callback(target)
		end
	else
		if self.owner ~= kOwnerNone then
			self.FSM:setState(kRoleStateStand)
		end
	end

end

function B:isNeedReinforce()
	return self.soldierNum < self.cfg.capacity / 2
end

function B:isCanDispatch()
	return self.soldierNum >= self.cfg.capacity * 0.75
end

function B:isTargetDead(target)
	if not target then
		return true
	end

	local status, dead = pcall(function() return target:isDead() end)
	if status then
		return dead
	end

	return true
end

function B:updateTargetList()

	local list = self.targetList
	for i=#list, 1, -1 do
		local target = list[i]
		if self:isTargetDead(target) then
			table.remove(list, i)
		end
	end

end

function B:isAttackNeedTarget()
	return self.cfg.id ~= 7 and self.cfg.id ~= 8 and self.cfg.id ~= 9
end

function B:updateAttack(dt)
	-- self.fightProxy:updateAttackSkill(dt)
	-- self.fightProxy:updateTargetStatus()
	self.fightProxy:updateSkillTime(dt)

	-- if self.fightProxy.targetStatus ~= kTargetValid or self.status ~= kBuildStatusNormal then
	-- 	return
	-- end
	-- print("update attack")
	local status, rate = self.fightProxy:checkAttack()

	if status then
		self:checkAttack(function(target1) 
			local tp = target1:reachPos()
			self.icon:updateFace(cc.pSub(tp, self.fightProxy.standPos))
			self.targetPos = tp
			self.icon:actAttack(rate, cc.pSub(tp, self.fightProxy.standPos))
		end)
	end

end

function B:actAttack()

	if not self.attackEntry then
		local scheduler = self:getScheduler()
		self.attackEntry = scheduler:scheduleScriptFunc(function(dt) self:updateAttack(dt) end, 0, false)
	end

end

function B:actStand()

	self:stopAttack()

end

function B:actDead()
	
	self.soldierNum = 0
	self.topLbl:setSoldierNum(0)

	self:stopAttack()
	self:stopUpdateSoldierNum()
	self:setOwner(kOwnerNone)
	
end

function B:updateFace()

end

function B:updateState(dt)
	
	local state = self.FSM:currentState()
	if state == kRoleStatusAttack then
		self:updateAttack(dt)
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

function B:acceptRadius()
	return self.acceptR
end

function B:attackRatio()
	return math.max(self.soldierNum, 0)*0.25
end

function B:reachPos()
	return self.fightProxy.standPos
end

function B:shootPos()
	return cc.pAdd(self.fightProxy.standPos, self.icon.shootPos)
	-- local p = self.fightProxy.standPos
	
	-- return cc.p(p.x-self.bedSize.width/2+self.icon.shootPos.x,
		-- p.y+self.icon.shootPos.y)
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


function B:showDamageEffect(damage)
	self.labelEffect:showEffect(-damage)

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


-- function B:handleDamage()

-- 	-- local last = self.fightProxy:displayNumber(self.soldierNum)
-- 	-- local currNum = self.soldierNum - damage
-- 	-- local curr = self.fightProxy:displayNumber(currNum)
-- 	-- self:showNumEffect(curr - last)

-- 	-- return curr
-- 	if self.totalDamage == 0 then
-- 		return 
-- 	end

-- 	self:showDamageEffect()

-- 	if self.totalDamage >= self.soldierNum then
-- 		self:setOwner(kOwnerNone)
-- 		self.soldierNum = 0
-- 		self.topLbl:setSoldierNum(0)
-- 		self:stopUpdateSoldierNum()
-- 	else
-- 		self:setSoldierNum(self.soldierNum - self.totalDamage)
-- 	end

-- 	self.totalDamage = 0


-- end

function B:handleAttackBack(node)

	local count = 1
	for _, v in pairs(self.siteList) do
		if v.ref > 0 then
			count = count + 1
		end
	end
	
	local l = {1, 0.75, 0.65, 0.55, 0.45, 0.4, 0.35, 0.35}

	self.fightProxy:handleAttackBack(node, self:attackRatio() * l[count])
end

function B:handleGather(owner, num)
	self:setOwner(owner)
	self:setSoldierNum(num + self.soldierNum)
	self:startUpdateSoldierNum()
end

function B:handleBeAttacked(damage, dtype)

	local real = self.fightProxy:getRealDamage(damage, dtype)
	self:showDamageEffect(real)

	if real >= self.soldierNum then
		self.FSM:setState(kRoleStateDead)
	else
		self:setSoldierNum(self.soldierNum - real)
	end

	-- self.totalDamage = self.totalDamage + real

	-- print("build handle be attacked -", real)

end

function B:handleAnimationFrameDisplayed(target, userInfo)
	self.icon:handleAnimationFrameDisplayed(target, userInfo)

	if userInfo.atype == kRoleAttack then
		if self.fightProxy:isAttackNeedTarget() then
			self:checkAttack(function(target)
				if self.propCallback then
					local skill = self.fightProxy:currentSkill()
					local dir = cc.p(-32, 24)
					if self.icon:currentFace() then
						dir = cc.p(32, 24)
					end

					self.propCallback(skill, self:shootPos(), target, self.fightProxy:currentPhyAttack(), self:attackRatio(), nil, dir)
				end
			end)
		else
			if self.propCallback then
				local skill = self.fightProxy:currentSkill()
						-- print("build target-", target)
				self.propCallback(skill, self:shootPos(), nil, self.fightProxy:currentPhyAttack(), self:attackRatio(), self.targetPos)
			end
		end

	end

end

-- function B:handleBeAttackedBySoldier(node, damage, dtype)
-- 	local real = self.fightProxy:getRealDamage(node.type, damage, dtype)
-- 	local curr = self:handleDamage(real)

-- 	if real > self.soldierNum then
-- 		self:setOwner(node.owner)
-- 		self.soldierNum = 0
-- 		self.topLbl:setSoldierNum(0)
-- 		self:startUpdateSoldierNum()
-- 	else
-- 		self.soldierNum = self.soldierNum - real
-- 		self.topLbl:setSoldierNum(curr)
-- 	end

-- 	self.fightProxy:checkAttackBack(node, self.type, self:attackRatio())

-- end

-- function B:handleBeAttackedByGeneral(general, damage, dtype)
-- 	local real = self.fightProxy:getRealDamage(general.type, damage, dtype)

-- 	local curr = self:handleDamage(real)
	
-- 	if real > self.soldierNum then
-- 		self.soldierNum = 0
-- 		self.topLbl:setSoldierNum(0)
-- 	else
-- 		self.soldierNum = self.soldierNum - real
-- 		self.topLbl:setSoldierNum(curr)
-- 	end

-- 	self.fightProxy:checkAttackBack(general, self.type, self:attackRatio())

-- end


return B

