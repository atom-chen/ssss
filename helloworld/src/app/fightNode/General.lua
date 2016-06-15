


local B = class("GeneralHealthBar", cc.Node)


function B:ctor(owner, health)
	local sp = cc.Sprite:create("orn/b13.png")
	sp:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(sp)	
	local s1 = sp:getContentSize()

	local bar = ProgressBar:create("b14_0.png", "b14_"..owner..".png", health)
	bar:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(bar)
	self.bar = bar

	local s2 = bar:getContentSize()
	local size = cc.size(s1.width + s2.width - 2, math.max(s1.height, s2.height))
	self:setContentSize(size)

	-- print("s1", s1.width, "h", s1.height)
	-- print("s2", s2.width,"h", s2.height)
	-- print("size", size.width, "h", size.height)
	sp:setPosition(cc.p(0, size.height/2))
	bar:setPosition(cc.p(s1.width - 2 , size.height/2))

end

function B:setHealth(health)
	self.bar:setBarNum(health)
end









local G = class("General", sgzj.RoleNode)

cc.exports.General = G

math.randomseed(os.time())

function G:ctor(cfg, owner, ident)
	self.cfg = cfg
	self.pcfg = generalPos[cfg.id]
	self.owner = owner
	self.type = kGeneralType
	self.isDead = false
	self.ident = ident
	self.status = kGeneralStatusNormal

	-- self.roleStatus = kRoleStatusStand
	-- self.nextRoleStatus = kRoleStatusStand
	

	self.inAttBuildTime = 0

	self.totalDamage = 0

	local image = self:roleImage()
	self.role = RoleNode:create(image, self.pcfg.fy)
	self.role:actStand(kGeneralAnimDelay)
	self.role:setAnchorPoint(cc.p(0, 0))
	self.role:setPosition(cc.p(0, 0))
	self:addChild(self.role)
	

	local size = self.role:getContentSize()
	self:setContentSize(size)
	-- self.acceptW = size.width / 2
	-- self.acceptH = size.height / 2
	self.acceptR = math.min(size.width/2, size.height/2)
	self.size = size

	self:createFightProxy(cfg, ident)

	self:createFSM()

	self:createMoveProxy()

	self:createBuffNode()

	self:createLabelEffect()

	local image = self:haloImage()
	
	local halo = cc.Sprite:create(image)
	halo:setAnchorPoint(cc.p(0.5, 0.4))
	self:addChild(halo, -1)
	self.halo = halo

	self:face(owner == kOwnerPlayer)

	self:createHealthBar()
	
end

function G:createMoveProxy()
	self.moveProxy = MoveProxy:create()
	self.moveProxy:bindMoveDoneCallback(function() self:moveDone() end)
	self.moveProxy:setMoveSpeed(self.fightProxy.moveSpeed)
end

function G:createHealthBar()
	local bar = B:create(self.owner, self.fightProxy.health)
	bar:setAnchorPoint(cc.p(0.5, 0))
	bar:setPosition(self:topCenter())
	self:addChild(bar)
	self.bar = bar
end

function G:updateHalo(face)
	local px = self.pcfg.fx
	if face then
		px = self.size.width - px
	end
	-- print("px-", px, "id-", self.cfg.id)
	self.halo:setPosition(cc.p(px, 0))
end

function G:createLabelEffect()

	local effect = LabelEffect:create()
	effect:setAnchorPoint(cc.p(0.5, 0))
	effect:setPosition(self:topCenter())
	self:addChild(effect, 1)
	self.labelEffect = effect

end

function G:createBuffNode()

	local buff = BuffNode:create()

	buff:setAnchorPoint(cc.p(0.5, 0))
	buff:setPosition(self.role:topCenter())
	self.role:addChild(buff)
	buff:bindUpdateCallback(function() self:updateBuffAdd() end)

	self.buffNode = buff

end

function G:createFightProxy(cfg ,ident)

	local fightProxy = FightProxy:create()
	fightProxy:parseGeneralCfg(cfg, ident)
	self.fightProxy = fightProxy

end

function G:createFSM()

	local fsm = StateMachine:create()
	fsm:bindStateCallback(kRoleStateStand, function() self:actStand() end)
	fsm:bindStateCallback(kRoleStateMove, function() self:actMove() end)
	fsm:bindStateCallback(kRoleStateAttack, function() self:actAttack() end)
	fsm:bindStateCallback(kRoleStateDead, function() self:actDead() end)
	self.FSM = fsm

end

function G:actStand()

	self:stopMove()
	self:stopAttack()
	self.role:actStand(kGeneralAnimDelay)

end

function G:stopMove()

	if self.moveEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.moveEntry)
		self.moveEntry = nil
	end

end

function G:updateMove(dt)
	-- local status = self.buffNode:updateDuration(dt)
	-- local fightProxy = self.fightProxy

	-- fightProxy:updateTargetStatus()
	-- local targetStatus = fightProxy.targetStatus

	-- print("target status -- ", targetStatus)
	-- if targetStatus == kTargetInvalid then
	-- 	self.status = kGeneralStatusReset
	-- 	-- self.fightProxy:setTarget(nil)
	-- 	-- self.fightProxy.status = kFightStatusNoTargetPos
	-- 	-- self.role:actStand()
	-- 	return
	-- end
	-- if not fightProxy:isTargetBuildType() and targetStatus == kTargetInvalid then
	-- 	self.status = kGeneralStatusReset
	-- 	return
	-- end
	
	local proxy = self.moveProxy
	if proxy:isInMove() then
		proxy:step(dt)
		print("x-", proxy.pos.x, "y-", proxy.pos.y)
		self:setPosition(proxy.pos)
	else
		local path = self:currentPath()
		proxy:setMovePath(path, self.fightProxy:targetRadius()+self.fightProxy:currentUseRange())
	end

	-- local status, last, nor = fightProxy:checkMove(dt, self)
	-- if status == kFightStatusNotReach then
	-- 	-- print("general move-x--", last.x, "y--", last.y)
	-- 	self:face(nor)
	-- 	self.role:actMove(kGeneralAnimDelay)
	-- 	self:setPosition(last)
	-- 	-- print("not reach")
	-- elseif status == kFightStatusReach then
	-- 	self:face(last)
	-- 	if targetStatus == kTargetInvalid or targetStatus == kTargetNone or fightProxy:theSameOwner(self.owner) then
	-- 		self.status = kGeneralStatusReset
	-- 	end
	-- end

	-- return status, last
end

function G:actMove()

	self:stopAttack()
	self.moveProxy:resetPath()
	self.role:actMove(kGeneralAnimDelay)
	local scheduler = self:getScheduler()
	self.moveEntry = scheduler:scheduleScriptFunc(function(dt) self:updateMove(dt) end, 0, false)

end

function G:moveDone()
	print("moveDone")
	if self.fightProxy.target ~= nil then
		self.FSM:setState(kRoleStateAttack)
	else
		self.FSM:setState(kRoleStateStand)
	end

end

function G:stopAttack()

	if self.attackEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.attackEntry)
		self.attackEntry = nil
	end

end

function G:updateAttack(dt)
	self.fightProxy:updateAttackSkill(dt)

	local status, rate = self.fightProxy:checkAttack()

	if status then

		self:doAttack(function()
			-- self:handleFight()
			if self.FSM:currentState() ~= kRoleStateDead then
				self:handleAttack()
				self.role:actStand(kGeneralAnimDelay)
			end
			end, rate)
	-- elseif self.role.status == kRoleMove then
	-- 	self.role:actStand(kGeneralAnimDelay)
	end

end

function G:actAttack()

	self:stopMove()
	local scheduler = self:getScheduler()
	self.attackEntry = scheduler:scheduleScriptFunc(function(dt) self:updateAttack(dt) end, 0, false)

end

function G:actDead()

	self:stopMove()
	self:stopAttack()
	self.role:actDie(function() self.FSM:setState(kRoleStateClear) end, 0, kGeneralAnimDelay)

end

function G:haloImage()
	return "bg/b12_"..self.owner..".png"
end

function G:roleImage()
	return "action/"..self.cfg.icon
end

function G:isTouchEnabled()
	return true
end

function G:isInvalid()
	-- return self.status == kGeneralStatusDead
	return self.FSM:currentState() == kRoleStateDead
end

function G:setTarget(target)
	self.fightProxy:setTarget(target)
end

function G:setTargetPos(pos)
	self.fightProxy:setTargetPos(pos)
end

function G:setStandPos(pos)
	-- self.fightProxy:setStandPos(cc.p(pos.x ,pos.y))
	self.moveProxy:setPos(pos)
	self:setPosition(pos)
end

function G:select()
	-- local sp = self.role

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureHightLight")
	-- sp:setGLProgram(program)
	self.role:setHighLight()
	self:setScale(1.3)
	self.selected = true

end

function G:unselect()
	-- local sp = self.role

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	self.role:setNormalLight()
	self:setScale(1)
	self.selected = false

end

function G:checkReachTarget(pos)

end

function G:acceptRadius()
	return self.acceptR
end

function G:isRemoteDamage()
	return self.fightProxy:isRemoteDamage()
end

function G:reachPos()
	return self.moveProxy.pos
end


function G:face(left)
	if self.faceLeft == left then
		return
	end
	self.faceLeft = left
	self.role:face(left)
	self:updateHalo(left)
end

function G:updateBuff()

end

function G:updateBuffAdd()
	local fightProxy = self.fightProxy

	fightProxy:setPhyAttackAdd(self.buffNode.phyAttAdd)
	fightProxy:setPhyDefAdd(self.buffNode.phyDefAdd)
	fightProxy:setMagicAttackAdd(self.buffNode.magicAttAdd)
	fightProxy:setMagicDefAdd(self.buffNode.magicDefAdd)

end





function G:updateStand(dt)

end

function G:updateDead(dt)

end

-- function G:updateRoleStatus(dt)

-- 	if self.nextRoleStatus == kRoleStatusStand then
-- 		self:updateStand(dt)
-- 	elseif self.nextRoleStatus == kRoleStatusMove then
-- 		self:updateMove(dt)
-- 	elseif self.nextRoleStatus == kRoleStatusAttack then
-- 		self:updateAttack(dt)
-- 	elseif self.nextRoleStatus == kRoleStatusDead then
-- 		self:updateDead(dt)
-- 	end

-- end

function G:resetGeneral()
	self.status = kGeneralStatusNormal
	self.fightProxy:setTarget(nil)
	self.role:actStand(kGeneralAnimDelay)
end

function G:attackRatio()
	return math.random(75, 125)/100.0
end

function G:doAttack(callback, rate)
	local atype = self.fightProxy:currentAction()
	if atype == kNormalAttack then
		self.role:actAttack(callback, rate, kGeneralAnimDelay)
	elseif atype == kSkill1 then
		self.role:actSkill1(callback, rate, kGeneralAnimDelay)
	elseif atype == kSkill2 then
		self.role:actSkill2(callback, rate, kGeneralAnimDelay)
	end

end

function G:checkAutoAttack(node)
	if self.fightProxy.targetStatus == kTargetNone then
		self.fightProxy:setTarget(node)
	end
	-- print("chek auto attack status ", self.fightProxy.targetStatus)
end

function G:handleDamage()

	-- local alive, num = self.fightProxy:handleHurt(damage)

	-- self:showNumEffect(num)

	-- return alive

	if self.totalDamage == 0 then
		return 
	end

	self:showDamageEffect()
	self.fightProxy:handleDamage(self.totalDamage)
	self.bar:setHealth(self.fightProxy.health)

	if self.fightProxy.health <= 0 then
		-- self.fightProxy.status = kFightStatusNoTargetPos
		self.status = kGeneralStatusDead
		self.role:actDie(function() 
			-- self.isDead = true
			self:removeFromParent(true)
			end, 0, kGeneralAnimDelay)
	end

	self.totalDamage = 0

end

function G:showDamageEffect()
	self.labelEffect:showEffect(-self.totalDamage)

	if self.owner == kOwnerNone then
		self.role:showColor(cc.num2c4b(0xc2c2c2ff))
	elseif self.owner == kOwnerPlayer then
		self.role:showColor(cc.num2c4b(0x177afdff))
	else
		self.role:showColor(cc.num2c4b(0xfe252aff))
	end

	local actions = {}
	actions[#actions + 1] = cc.DelayTime:create(0.1)
	actions[#actions + 1] = cc.CallFunc:create(function() self.role:showColor(cc.c3b(255, 255, 255)) end)
	local seq = cc.Sequence:create(actions)
	seq:setTag(kBeAttackedTag)
	self:stopActionByTag(kBeAttackedTag)
	self:runAction(seq)

end

function G:handleAttack()
	self.fightProxy:handleAttack(self, self:attackRatio())
end

function G:handleBeAttacked(damage, dtype)
	-- local real = self.fightProxy:getRealDamage(ntype, damage, dtype)
	-- print("general handle be attacked")
	-- local alive = self:handleDamage(real)

	-- if not alive then
	-- 	self.role:actDie(
	-- 			function()
	-- 				self.isDead = true
	-- 			end)
	-- end

	local real = self.fightProxy:getRealDamage(damage, dtype)
	self.totalDamage = self.totalDamage + real

	-- self.fightProxy:setTarget()


end

function G:handleBuff(buff)

	self.buffNode:addBuff(buff)

end

-- function G:handleAttackBack(ntype, damage, dtype)
-- 	print("general handle attack back")
-- 	self:handleBeAttacked(ntype, damage, dtype)

-- end

-- function General:checkAttackBack(node)
-- 	local remote = node:isRemoteDamage()

-- 	if not remote then
-- 		self.fightNode:handleAttackBack(self.type, node, self:attackRatio())
-- 	end
-- end

-- function G:handleBeAttackedBySoldier(node, damage, dtype)
-- 	print("general attacked by soldier")
-- 	self:handleBeAttacked(node.type, damage, dtype)

-- 	-- self.fightNode:checkAttackBack(node, self.type, self:attackRatio())

-- 	self.fightProxy:checkAutoFight(node)

-- end

-- function G:handleBeAttackedByGeneral(general, damage, dtype)
-- 	self:handleBeAttacked(general.type, damage, dtype)

-- 	-- self.fightNode:checkAttackBack(general, self.type, self:attackRatio())

-- 	self.fightProxy:checkAutoFight(general)

-- end



return G
















