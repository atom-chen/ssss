

local S = class("Soldier", sgzj.RoleNode)

cc.exports.Soldier = S

function S:ctor(cfg, owner, num, target, ident)
	-- print("soldier create-", ident)
	self:enableNodeEvents()
	self.cfg = cfg
	self.pcfg = soldierPos[cfg.id]
	self.owner = owner
	self.ident = ident
	self.roles = {}
	-- self.deadRoles = {}
	self.type = 3
	-- self.workDone = false
	self.disList = {}
	self.count = 0
	self.status = kSoldierStatusNormal

	local container = cc.Node:create()
	container:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(container)
	self.container = container

	self.canAttackBack = true

	self.totalDamage = 0
	self:initFormationPos()
	self:createFightProxy(target, ident)
	self:createFSM()

	self:createMoveProxy()
	self:setSoldierNum(num)
	self:createLabelEffect()

	self:createBuffNode()
	
end

function S:onExit()
	self:destroy()
	if self.acceptSite then
		self.acceptSite.ref = self.acceptSite.ref - 1
	end
end

function S:destroy()

	self.buffNode:stopUpdate()
	self:stopMove()
	self:stopAttack()
	-- self:removeFromParent(true)

end

function S:createFSM()
	local fsm = StateMachine:create()
	fsm:bindStateCallback(kRoleStateStand, function() self:actStand() end)
	fsm:bindStateCallback(kRoleStateMove, function() self:actMove() end)
	fsm:bindStateCallback(kRoleStateAttack, function() self:actAttack() end)
	-- fsm:bindStateCallback(kRoleStateDead, function() self:actDead() end)
	fsm:bindStateCallback(kRoleStateGather, function() self:handleGather() end)
	self.FSM = fsm

end

function S:createFightProxy(target, ident)

	local fightProxy = FightProxy:create()
	fightProxy:setTarget(target)
	fightProxy:parseSoldierCfg(self.cfg, ident)
	self.fightProxy = fightProxy

end

function S:createMoveProxy()
	local proxy = MoveProxy:create()
	proxy:bindMoveDoneCallback(function() self:moveDone() end)
	proxy:setMoveSpeed(self.fightProxy.moveSpeed)
	self.moveProxy = proxy

end

function S:createBuffNode()

	local buff = BuffNode:create()

	buff:setAnchorPoint(cc.p(0.5, 0))
	buff:setPosition(self:topCenter())
	self:addChild(buff)
	self.buffNode = buff

end

function S:bindPathCallback(callback)
	self.pathCallback = callback
end

function S:setStandPos(pos)
	self:setPosition(pos)
	self.moveProxy:setPos(pos)
	self:setLocalZOrder(math.floor(1546-pos.y))
end

function S:setSoldierNum(num)
	num = math.max(num, 0)
	self.soldierNum = num
	local rn = self:roleNum(num)
	local cur = #self.roles
	-- print("ident-", self.ident, "num---", num, "rn--", rn, "cur--", cur)
	if rn > cur then
		self:addSoldier(rn-cur)
	elseif rn < cur then
		self:deleteSoldier(cur-rn)
	end

	if not self.topLbl then
		self:createTopLbl()
	end

	local lblNum = self.fightProxy:displayNumber(num)
	self.topLbl:setSoldierNum(lblNum)

end

function S:setTarget(target)
	if target then
		-- self.workDone = false
		self.fightProxy:setTarget(target)
		self.status = kSoldierStatusNormal
	end
end

function S:setPathTargetList(list)
	self.disList = list
end

function S:roleNum(num)
	if num <= 0 then
		return 0
	elseif num <= 1 then
		return 1
	elseif num > 256 then
		return 9
	else
		return math.floor(math.log(num - 1)/math.log(2)) + 1
	end
end

function S:createLabelEffect()

	local effect = LabelEffect:create()
	effect:setAnchorPoint(cc.p(0.5, 0))
	effect:setPosition(self.topLbl:topCenter())
	self.topLbl:addChild(effect)
	self.labelEffect = effect

end

function S:createTopLbl()

	local topLbl = CampLabel:create(self.cfg.typeId, self.owner)
	topLbl:setAnchorPoint(cc.p(0.5, 0.5))
		-- local p = self:topCenter()
		-- print(p.x, "y-", p.y)
	topLbl:setPosition(self:topCenter())
	self:addChild(topLbl)
	self.topLbl = topLbl
		
end

function S:addSoldier(num)
	-- print("add---", num)
	local base = self:roleBaseName()
	local size = nil
	local rowH = 0
	local colW = 0
	local flag = #self.roles
	-- print("flag---", flag)
	local cfg = formations[self.cfg.id]
	local b1 = cfg.off 
	for i=1, num do

		local role = RoleNode:create(base, self.pcfg.fy)
		role:actStand(kSoldierAnimDelay)
		local count = #self.roles
		local row = count / 4
		local col = count % 4

		if not size then
			size = role:getContentSize()
			rowH = size.height/2
			colW = size.width * 0.7
			-- print("rowH--", rowH, "colW--", colW)
		end
		
		role:setAnchorPoint(cc.p(0.5, 0))

		local pos = self.formationPos[i]
		
		if flag == 0 then
			-- print("last-", last.x, "y-", last.y)
			pos = cc.pMul(pos, 15)
		else
			pos = cc.pMul(pos, b1)
		end

		role:setPosition(pos)
		-- role:setPosition(cc.p(colW * col, rowH * (2 - row)))
		-- print("rolex--", colW*col, "rolwy--", rowH*(2-row))
		self.container:addChild(role)
		self.roles[count+1] = role
	end

	self.count = self.count + num
	if flag == 0 then
		-- print("setcoententsize--w--", colW * 3+size.width, "h--", rowH * 2 + size.height)
		local h = size.height + self.formSize.height
		local sz = cc.size(self.formSize.width, h)
		self.container:setPosition(sz.width/2,sz.height/2)
		self.container:setContentSize(sz)
		self:setContentSize(sz)
		-- print("sz-w", sz.width, "sz-h", sz.height)
		
	end
	
end

function S:deleteSoldier(num)
	-- print("delete---", num)
	local count = num
	local userInfo = {fightId = self.ident, index=-1, atype=kRoleDie}
	while count > 0 do
		local idx = #self.roles
		local role = self.roles[idx]
		-- self.deadRoles[idx] = role
		role:actDie(0, kSoldierAnimDelay, nil, function()
				role:removeFromParent(true)
				-- self.deadRoles[idx] = nil
				self.count = self.count - 1
				if self.count == 0 then
					-- self.workDone = true
					-- self:removeFromParent(true)
					-- print("set clear state-")
					self.FSM:setState(kRoleStateClear)
				end
			end)
		
		self.roles[#self.roles] = nil
		count = count - 1
	end

	if #self.roles == 0 then
		-- self.status = kSoldierStatusDead
		self.FSM:setState(kRoleStateDead)
	end

end

function S:initFormationPos()

	local cfg = formations[self.cfg.id]
	local base = cfg.off 
	local formationPos = {}
	formationPos[1] = cc.p(1.732, 1.75)
	formationPos[2] = cc.p(0.866, 1.25)
	formationPos[3] = cc.p(2.598, 1.25)
	formationPos[4] = cc.p(0, 0.75)
	formationPos[5] = cc.p(3.464, 0.75)
	formationPos[6] = cc.p(1.299, 0.5)
	formationPos[7] = cc.p(2.165, 0.5)
	formationPos[8] = cc.p(0.433, 0)
	formationPos[9] = cc.p(3.031, 0)
	self.formationPos = formationPos
	local size = cc.size(base * 3.464, base * 1.75)
	self.formSize = size
	
	-- self.acceptW = size.width / 2
	-- self.acceptH = size.height / 2
	self.acceptR = math.min(size.width/2, size.height/2)

end

function S:acceptRadius()
	return self.acceptR
end

function S:roleBaseName()
	return "action/"..self.cfg.icon.."_"..self.owner
end

function S:fightNode()
	return self.fightProxy.fightNode
end

function S:updateFace(face)
	if self.face == face then
		return 
	end

	-- print("face-", face, "sface-", self.face)
	self.face = face
	for _, v in pairs(self.roles) do
		v:face(face)
	end
end

function S:updateStatus()
	
	-- local targetStatus = self.fightProxy.targetStatus

end

function S:updateBuffAdd()
	local fightProxy = self.fightProxy

	fightProxy:setPhyAttackAdd(self.buffNode.phyAttAdd)
	fightProxy:setPhyDefAdd(self.buffNode.phyDefAdd)
	fightProxy:setMagicAttackAdd(self.buffNode.magicAttAdd)
	fightProxy:setMagicDefAdd(self.buffNode.magicDefAdd)

end


-- function S:updateAttack(dt)
-- 	-- print("fightProxy status--", self.fightProxy.status)
-- 	if self.fightProxy:isTargetDead() then
-- 		self:handleTargetDead()
-- 		return
-- 	end

-- 	self.fightProxy:updateSkillTime(dt)

-- 	-- if self.fightProxy.status ~= kFightStatusReach or self.status ~= kSoldierStatusNormal then
-- 	-- 	return
-- 	-- end

-- 	local status, rate = self.fightProxy:checkAttack()

-- 	if status then
		
-- 	-- 	-- if self.fightNode:isTargetGeneral() then
			
-- 	-- 	self:actAttack(
-- 	-- 		function()  
-- 	-- 			if self.status ~= kSoldierStatusDead then
-- 	-- 				self:handleAttack()
-- 	-- 				self:actStand()
-- 	-- 			end
-- 	-- 		end, rate, kSoldierAnimDelay)
			
-- 	-- 	-- else
-- 	-- 	-- self.workDone = true

-- 	-- elseif self.roleStatus == kRoleMove then
-- 	-- 	self:actStand()
-- 	end

-- 	-- return status, rate
-- end

function S:updateStand(dt)

	if self.roleStatus == kRoleStatusStand then
		return
	end

end

function S:updateDead(dt)
	if self.roleStatus == kRoleStatusDead then
		return
	end

end

function S:updateRoleStatus(dt)
	if self.nextRoleStatus == kRoleStatusStand then
		self:updateStand(dt)
	elseif self.nextRoleStatus == kRoleStatusMove then
		self:updateMove(dt)
	elseif self.nextRoleStatus == kRoleStatusAttack then
		self:updateAttack(dt)
	elseif self.nextRoleStatus == kRoleStatusDead then
		self:updateDead(dt)
	end
end

function S:isRemoteDamage()
	return self.fightProxy:isRemoteDamage()
end

function S:isInvalid()
	return #self.roles <= 0
end

function S:isTargetInvalid()
	return self.fightProxy:isTargetInvalid()
end

function S:isDead()
	local state = self.FSM:currentState()
	return state == kRoleStateDead or state == kRoleStateClear
end

function S:isTheSameOwnerWithTarget()
	return self.fightProxy:theSameOwner(self.owner)
end

function S:handleTargetDead()
	-- print("handle target dead-", self.ident)
	local targetType = self.fightProxy.targetType
	if targetType and targetType == kBuildType then
		self.FSM:setState(kRoleStateGather)
	else
		self.FSM:setState(kRoleStateNoTarget)
	end

end

function S:handleDamage()
	if self.totalDamage == 0 then
		return
	end

	self:showDamageEffect()
	self:setSoldierNum(self.soldierNum - self.totalDamage)

	self.totalDamage = 0

end

function S:handleAttack()
	self.fightProxy:handleAttack(self, self:attackRatio())
end

function S:handleAttackBack(node)
	
	self.fightProxy:handleAttackBack(node, self:attackRatio())
end

-- function S:handleWorkDone()
-- 	if not self:isInvalid() then
-- 		self:handleGather()
-- 	end
-- end

function S:attackRatio()
	local ratio = 1
	if self.owner ~= kOwnerPlayer then
		ratio = MapData:currentMapRank()/100.0
	end
	-- print("map rank-", ratio)
	local aratio = math.max(self.soldierNum, 0)*0.25 * ratio
	-- print("soldierNum-", self.soldierNum, "soldier ratio-", aratio)
	return  aratio
end

function S:reachPos()
	return self.moveProxy.pos
end

function S:roleActStand()
	for _, v in pairs(self.roles) do
		v:actStand(kSoldierAnimDelay, true)
	end
end

function S:actStand()
	-- if self.roleStatus == kRoleStand then
	-- 	return
	-- end

	-- self.roleStatus = kRoleStand
	self:stopMove()
	self:stopAttack()
	self:roleActStand()
	
end

function S:stopMove()
	-- print("move Entry-", self.moveEntry)
	-- print("movedis-", self.moveProxy.moveDis)
	if self.moveEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.moveEntry)
		self.moveEntry = nil
	end

end

function S:setMovePath(path)
	-- self.moveProxy:setMovePath(path, self.fightProxy:targetRadius() + self.fightProxy:currentUseRange() + self.acceptR)
	local proxy = self.moveProxy
	proxy:setMovePath(path, self.fightProxy:targetRadius() + self.fightProxy:currentUseRange() + self.acceptR)
	if self.pathCallback then
		self.pathCallback(proxy.path, self)
	end

	local distance = proxy.maxMove-100
	-- print("distance-", distance)
	proxy:addMoveCallback({dis=distance, callback=function() 
						-- self:gatherRole()
						local final = self:finalPos(1)
						for i, v in pairs(self.roles) do

							if v.delay == -1 then
								local rf = cc.p(final.x, final.y)
								if i > 5 then
									rf.y = rf.y - kSoldierRowOff
								end

								self:gatherRole(v, rf)
							end

						end

					 end})

end

function S:updateRotation(dir)
	if not dir then
		return
	end

	local rotation = 90-cc.pToAngleSelf(dir) * 180 / math.pi
	self.container:setRotation(rotation)
	local children = self.container:getChildren()
	for _, v in pairs(children) do
		v:setRotation(-rotation)
	end
	-- local sz = self.container:getContentSize()
	
	-- local p1 = self.container:convertToWorldSpace(cc.p(0, 0))
	-- local p2 = self.container:convertToWorldSpace(cc.p(0, sz.height))
	-- local p3 = self.container:convertToWorldSpace(cc.p(sz.width, sz.height))
	-- local p4 = self.container:convertToWorldSpace(cc.p(sz.width, 0))

	-- self:drawNodeRect(p1, p2, p3, p4)
	-- for _, v in pairs(self.roles) do
	-- 	v:setRotation(-rotation)
	-- end
	-- for _, v in pairs(self.deadRoles) do
	-- 	v:setRotation(-rotation)
	-- end

end

function S:updateMove(dt)
	-- self.fightProxy:updateTargetStatus()
	-- local targetStatus = self.fightProxy.targetStatus
	-- -- print("target status--", targetStatus)

	-- if targetStatus == kTargetDestroyed then
	-- 	self.workDone = true
	-- 	self.status = kSoldierStatusNextTarget
	-- 	self.fightProxy.status = kFightStatusNoTargetPos
	-- 	return 
	-- end
	-- local status = self.buffNode:updateDuration(dt)
	-- local fightProxy = self.fightProxy

	-- if status then
	-- 	self:updateBuffAdd()
	-- end
	if self:isDead() then
		return
	end

	local proxy = self.moveProxy
	if proxy:isInMove() then

		local dir = proxy:step(dt)
		-- print("x-", proxy.pos.x, "y-", proxy.pos.y)
		if dir then
			self:updateRotation(dir)
			self:setPosition(proxy.pos)
			self:setLocalZOrder(math.floor(1546-proxy.pos.y))
			self:updateFace(proxy:currentFace())
		end
	else
		if self:isFindDone() then
			local path = self:currentPath()
			if #path == 0 then
				self.FSM:setState(kRoleStateStand)
			else
				self:setMovePath(path)
			end
		end
	end
	
	-- fightProxy:updateTargetStatus()
	-- local targetStatus = fightProxy.targetStatus
	
	-- if not fightProxy:isTargetBuildType() and targetStatus == kTargetInvalid then
	-- 	self.status = kSoldierStatusNextTarget
	-- 	return
	-- end
	
	-- local status, last, nor = fightProxy:checkMove(dt, self)
	
	-- if status == kFightStatusNotReach then
	-- 	self:updateFace(nor)
	-- 	self:actMove()
	-- 	self:setPosition(last)

	-- elseif status == kFightStatusReach then
	-- 	-- self.workDone = true
	-- 	self:updateFace(last)
	-- 	if fightProxy:isTargetBuildType() then
	-- 		if targetStatus == kTargetInvalid or fightProxy:theSameOwner(self.owner) then
	-- 			self.status = kSoldierStatusGather
	-- 		end
	-- 	end

	-- end

	-- return status, last
end

function S:roleActMove()
	for _, v in pairs(self.roles) do
		v:actMove(kSoldierAnimDelay, true)
	end
end

function S:actMove()
	-- if self.roleStatus== kRoleMove then
	-- 	return
	-- end

	-- self.roleStatus = kRoleMove
	self:stopAttack()
	self.moveProxy:resetPath()
	self:roleActMove()
	if not self.moveEntry then
		local scheduler = self:getScheduler()
		self.moveEntry = scheduler:scheduleScriptFunc(function(dt) self:updateMove(dt) end, 0, false)
	end

end

function S:moveDone()
	-- print("move done")
	-- local target = self.fightProxy.target
	if self.fightProxy:isTargetDead() then
		self:handleTargetDead()
	else

		self:checkAttack(function()
			self.FSM:setState(kRoleStateAttack)
			end)
	end
end

function S:nextAction()

end

function S:checkAttack(callback)
	
	local target = self.fightProxy.target
	if target.owner == self.owner then
		self.FSM:setState(kRoleStateGather)
		return 
	end

	local moveProxy = self.moveProxy
	local p = moveProxy.pos

	if target.type == kBuildType and not self.acceptSite then

		local fl, site = target:acceptSite(p, self.acceptR)
		-- print("fl", fl)
		if fl then
			self.acceptSite = site
			moveProxy:addMovePath(fl)
			self.acceptSite.ref = self.acceptSite.ref + 1
			-- print("add move path")
			return
		end

	end

	if self.fightProxy:attackStatus(p, self.acceptR) then
		callback()
	else
			-- print("reset")
		self.FSM:setState(kRoleStateMove)
		self:setStartPoint(p)
		self:findRoute(target:reachPos())
	end


end

function S:stopAttack()

	if self.attackEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.attackEntry)
		self.attackEntry = nil
	end

end

function S:updateAttack(dt)
	-- print("fightProxy status--", self.fightProxy.status)
	if self:isDead() then
		return
	end

	self.fightProxy:updateSkillTime(dt)

	-- if self.fightProxy.status ~= kFightStatusReach or self.status ~= kSoldierStatusNormal then
		-- return
	-- end

	local status, rate = self.fightProxy:checkAttack()

	if status then
		-- print("attack-", self.ident)
		if self.fightProxy:isTargetDead() then
			self:handleTargetDead()
			return
		end

		self:checkAttack(function()
			local target = self.fightProxy.target
			local tp = target:reachPos()
			self:updateFace(tp.x > self.moveProxy.pos.x)
			self:updateRotation(cc.pSub(tp, self.moveProxy.pos))
			self:roleActAttack( rate, kSoldierAnimDelay)

			end)
	end

end

function S:actAttack()

	self:stopMove()
	if not self.attackEntry then
		local scheduler = self:getScheduler()
		self.attackEntry = scheduler:scheduleScriptFunc(function(dt) self:updateAttack(dt) end, 0, false)
	end

end

function S:roleActAttack(time, delay)
	-- if self.roleStatus == kRoleAttack then
	-- 	return
	-- end
	
	-- self.roleStatus = kRoleAttack
	-- self.inAttack = true
	-- local final = nil
	-- local flag = 0
	-- local off = 0
	-- if self.face then
	-- 	final = self:finalPos(5)
	-- 	flag = 0
	-- 	off = -kSoldierRowOff
	-- else
	-- 	final = self:finalPos(4)
	-- 	flag = 1
	-- 	off = kSoldierRowOff
	-- end
	-- local info = soldierAttack[self.cfg.id]


	for i, v in pairs(self.roles) do
		-- print("delay-", v.delay)
		local actions = {}
		

		actions[#actions + 1] = cc.DelayTime:create(v.delay)
		-- if i == 1 then
			-- actions[#actions + 1] = cc.CallFunc:create(function () if v.status ~= kRoleDie then v:actAttack(function() 
			-- 	callback() 
			-- 	if v.status ~= kRoleDie then
			-- 		v:actStand() 
			-- 	end
			-- 	end, time, delay) end end)
		local userInfos = nil
		if i == 1 then
			local userInfo = {}
			for k, v in pairs(soldierAttack[self.cfg.id]) do
				userInfo[k] = v
			end
			userInfo.fightId = self.ident
			userInfos = {userInfo}
		end

		actions[#actions + 1] = cc.CallFunc:create(
			function () 
				if v.status ~= kRoleDie then 
					v:actAttack(time, delay, userInfos, function() v:actStand(kSoldierAnimDelay) end) 
				end 
			end)
		-- else
		-- 	actions[#actions + 1] = cc.CallFunc:create(function () if v.status ~= kRoleDie then v:actAttack(function() 
		-- 		if v.status ~= kRoleDie then
		-- 			v:actStand() 
		-- 		end
		-- 		end, time, delay) end end)
		-- end
		local seq = cc.Sequence:create(actions)
		v:runAction(seq)

	end

end


function S:showColor(color)
	for _, v in pairs(self.roles) do
		v:showColor(color)
		local actions = {}
		actions[#actions + 1] = cc.DelayTime:create(0.1)
		actions[#actions + 1] = cc.CallFunc:create(function() v:showColor(cc.c3b(255, 255, 255)) end)
		local seq = cc.Sequence:create(actions)
		seq:setTag(kBeAttackedTag)
		v:stopActionByTag(kBeAttackedTag)
		v:runAction(seq)

	end
end

function S:showDamageEffect(damage)
	self.labelEffect:showEffect(-damage)

	local color = nil
	if self.owner == kOwnerNone then
		color = cc.num2c4b(0xc2c2c2ff)
	elseif self.owner == kOwnerPlayer then
		color = cc.num2c4b(0x177afdff)
	else
		color = cc.num2c4b(0xfe252aff)
	end

	self:showColor(color)

	
end

function S:checkAutoAttack(node)
	
end

function S:finalPos(idx)
	local cfg = formations[self.cfg.id]
	local b1 = cfg.off
	local pos = self.formationPos[idx]

	return cc.pMul(pos, b1)
end

function S:dispersal()

	for i, role in pairs(self.roles) do
		-- if role.status ~= kRoleDie then
			local last = self:finalPos(i)
			role.delay = -1
			local move = cc.MoveTo:create(kSoldierDispersal, last)
			move:setTag(kRoleGatherTag)
			role:stopActionByTag(kRoleGatherTag)
			role:runAction(move)
		-- end

	end

end

-- function S:gatherTop(callback)

-- 	local final = self:finalPos(1)

-- 	for i, role in pairs(self.roles) do
-- 		if role.status ~= kRoleDie then
-- 			local pos = role:getPosition()
-- 			local sec = (final.y-pos.y)/kGatherSpeed

-- 			local move = cc.MoveTo:create(sec, cc.p(pos.x, final.y))
-- 			role:stopActionByTag(kRoleGatherTag)
-- 			role:runAction(move)

-- 		end
-- 	end
-- end

-- function S:gatherLeft()
-- 	local final = self:finalPos(4)

-- 	for i, role in pairs(self.roles) do
-- 		if role.status ~= kRoleDie then
-- 			local pos = role:getPosition()
-- 			local sec = (pos.x-final.x)/kGatherSpeed

-- 			local move = cc.MoveTo:create(sec, cc.p(final.x, pos.y))
-- 			role:stopActionByTag(kRoleGatherTag)
-- 			role:runAction(move)

-- 		end
-- 	end
-- end

-- function S:gatherBottom()
-- 	local final = self:finalPos(8)

-- 	for i, role in pairs(self.roles) do
-- 		if role.status ~= kRoleDie then
-- 			local pos = role:getPosition()
-- 			local sec = (pos.y-final.y)/kGatherSpeed

-- 			local move = cc.MoveTo:create(sec, cc.p(pos.x, final.y))
-- 			role:stopActionByTag(kRoleGatherTag)
-- 			role:runAction(move)

-- 		end
-- 	end
-- end

function S:gatherRole(role, final)

	-- for i, role in pairs(self.roles) do
		-- if role.status ~= kRoleDie then
	local px, py = role:getPosition()

	if math.abs(py - final.y) < 0.01 then
		role.delay = 0
		return 
	end

	local sec = math.abs(final.y-py)/kGatherSpeed
	-- print("sec-", sec)

	local move = cc.MoveTo:create(sec, cc.p(px, final.y))
	move:setTag(kRoleGatherTag)
	
	role:stopActionByTag(kRoleGatherTag)
	role:runAction(move)

	role.delay = sec

end

function S:handleGather()
	-- print("handle gather-", self.ident)
	self.fightProxy:handleGather(self.owner, self.soldierNum)
	self.FSM:setState(kRoleStateClear)
end

function S:handleBeAttacked(damage, dtype)
	-- local real = self.fightProxy:getRealDamage(ntype, damage, dtype)
	-- -- print("last num -", self.soldierNum)
	-- local last = self.fightProxy:displayNumber(self.soldierNum)
	-- local currNum = self.soldierNum - real
	-- local curr = self.fightProxy:displayNumber(currNum)
	-- -- print("current num -", currNum)

	-- self:showNumEffect(curr - last)
	-- -- print("soldier set num ", currNum, "damage", real)

	-- self:setSoldierNum(currNum)
	-- print("damage--", damage, "dtype--", dtype)
	print("soldier Be Attacked- soldierId", self.cfg.id, "ident-", self.ident)
	local real = self.fightProxy:getRealDamage(damage, dtype)

	self:showDamageEffect(real)
	
	self:setSoldierNum(self.soldierNum - real)
	-- self.totalDamage = self.totalDamage + real
	-- print("real-", real)
	-- print("soldier totalDamage--", self.totalDamage)

end

function S:handleBuff(buff)
	self.buffNode:addBuff(buff)
	self:updateBuffAdd()
end

function S:handleAnimationFrameDisplayed(target, userInfo)
	-- if userInfo.atype == kRoleDie then
	-- 	-- self.FSM:setState(kRoleStateClear)
	-- 	-- function()
	-- 			role:removeFromParent(true)
	-- 			-- self.deadRoles[idx] = nil
	-- 			self.count = self.count - 1
	-- 			if self.count == 0 then
	-- 				-- self.workDone = true
	-- 				-- self:removeFromParent(true)
	-- 				self.FSM:setState(kRoleStateClear)
	-- 			end
	-- 		-- end, 0, kSoldierAnimDelay


	-- else
	-- if userInfo.isHead then
	if target == self.roles[1].role then
		if self.fightProxy:isTargetDead() then
			self:handleTargetDead()
		else
			local target = self.fightProxy.target
			if target.owner == self.owner then
				self.FSM:setState(kRoleStateGather)
			else
				self:handleAttack()
			end
			-- print("ident-", self.ident, "handle attack")
			-- self.role:actStand(kGeneralAnimDelay)
		end
	end
	-- end
	-- end
end

-- function S:handleAttackBack(ntype, damage, dtype)
-- 	print("soldier handle attack back")
-- 	self:handleBeAttacked(ntype, damage, dtype)

-- end

-- function S:handleBeAttackedBySoldier(node, damage, dtype)
-- 	self:handleBeAttacked(node.type, damage, dtype)

-- 	self.fightProxy:checkAttackBack(node, self.type, self:attackRatio())

-- end

-- function S:handleBeAttackedByGeneral(general, damage, dtype)
-- 	print("soldier handle be attacked by general")
-- 	self:handleBeAttacked(general.type, damage, dtype)

-- 	self.fightProxy:checkAttackBack(general, self.type, self:attackRatio())

-- end


return S


