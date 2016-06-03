

local S = class("Soldier", cc.Node)

cc.exports.Soldier = S

function S:ctor(cfg, owner, num, target, ident)
	self.cfg = cfg
	self.pcfg = soldierPos[cfg.id]
	self.owner = owner
	self.ident = ident
	self.roles = {}
	self.type = 3
	-- self.workDone = false

	self.count = 0
	self.status = kSoldierStatusNormal

	self.totalDamage = 0

	self:initFormationPos()

	self:createFightProxy(target, ident)

	self:setSoldierNum(num)
	self:createLabelEffect()

	self:createBuffNode()
	
end

function S:createFightProxy(target, ident)

	local fightProxy = FightProxy:create()
	fightProxy:setTarget(target)
	fightProxy:parseSoldierCfg(self.cfg, ident)
	self.fightProxy = fightProxy

end

function S:createBuffNode()

	local buff = BuffNode:create()

	buff:setAnchorPoint(cc.p(0.5, 0))
	buff:setPosition(self:topCenter())
	self:addChild(buff)
	self.buffNode = buff

end

function S:setStandPos(pos)
	self:setPosition(pos)
	self.fightProxy:setStandPos(pos)
end

function S:setSoldierNum(num)
	num = math.max(num, 0)
	self.soldierNum = num
	local rn = self:roleNum(num)
	local cur = #self.roles
	-- print("num---", num, "rn--", rn, "cur--", cur)
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
		self:addChild(role)
		self.roles[count+1] = role
	end

	self.count = self.count + num
	if flag == 0 then
		-- print("setcoententsize--w--", colW * 3+size.width, "h--", rowH * 2 + size.height)
		local h = size.height + self.formSize.height
		self:setContentSize(cc.size(self.formSize.width, h))
		
	end
	
end

function S:deleteSoldier(num)
	-- print("delete---", num)
	local count = num
	while count > 0 do
		local role = self.roles[#self.roles]
		role:actDie(function()
				role:removeFromParent(true)
				self.count = self.count - 1
				if self.count == 0 then
					-- self.workDone = true
					self:removeFromParent(true)
				end
			end, 0, kSoldierAnimDelay)
		
		self.roles[#self.roles] = nil
		count = count - 1
	end

	if #self.roles == 0 then
		self.status = kSoldierStatusDead
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
	
	self.acceptW = size.width / 2
	self.acceptH = size.height / 2

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
	local status = self.buffNode:updateDuration(dt)
	local fightProxy = self.fightProxy

	if status then
		self:updateBuffAdd()
	end

	fightProxy:updateTargetStatus()
	local targetStatus = fightProxy.targetStatus

	if not fightProxy:isTargetBuildType() and targetStatus == kTargetInvalid then
		self.status = kSoldierStatusNextTarget
		return
	end

	local status, last, nor = fightProxy:checkMove(dt, self)

	if status == kFightStatusNotReach then
		self:updateFace(nor)
		self:actMove()
		self:setPosition(last)

	elseif status == kFightStatusReach then
		-- self.workDone = true
		self:updateFace(last)
		if fightProxy:isTargetBuildType() then
			if targetStatus == kTargetInvalid or fightProxy:theSameOwner(self.owner) then
				self.status = kSoldierStatusGather
			end
		end

	end

	return status, last
end

function S:updateAttack(dt)
	-- print("fightProxy status--", self.fightProxy.status)
	self.fightProxy:updateAttackSkill(dt)

	if self.fightProxy.status ~= kFightStatusReach or self.status ~= kSoldierStatusNormal then
		return
	end

	local status, rate = self.fightProxy:checkAttack()

	if status then
		
		-- if self.fightNode:isTargetGeneral() then
			
		self:actAttack(
			function()  
				if self.status ~= kSoldierStatusDead then
					self:handleAttack()
					self:actStand()
				end
			end, rate, kSoldierAnimDelay)
			
		-- else
		-- self.workDone = true

	elseif self.roleStatus == kRoleMove then
		self:actStand()
	end

	-- return status, rate
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

function S:isTheSameOwnerWithTarget()
	return self.fightProxy:theSameOwner(self.owner)
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
	return math.max(self.soldierNum, 0)*0.25
end

function S:centerPos()
	return self.fightProxy.standPos
end

function S:actStand()
	if self.roleStatus == kRoleStand then
		return
	end

	self.roleStatus = kRoleStand

	for _, v in pairs(self.roles) do
		v:actStand(kSoldierAnimDelay, true)
	end
end

function S:actAttack(callback, time, delay)
	if self.roleStatus == kRoleAttack then
		return
	end
	
	self.roleStatus = kRoleAttack
	-- self.inAttack = true
	local final = nil
	local flag = 0
	local off = 0
	if self.face then
		final = self:finalPos(5)
		flag = 0
		off = -kSoldierRowOff
	else
		final = self:finalPos(4)
		flag = 1
		off = kSoldierRowOff
	end

	for i, v in pairs(self.roles) do
		-- local actions = {}
		-- actions[#actions + 1] = cc.Delay:create(v.randDelay)
		-- local seq = cc.Sequence:create(action)

		if v.delay == -1 then
			local rf = cc.p(final.x, final.y)
			if i~=1 and i%2 == flag then
				rf.x = rf.x + off
			end
			self:gatherRole(v, rf)
		end

		local actions = {}
		actions[#actions + 1] = cc.DelayTime:create(v.delay)
		if i == 1 then
			actions[#actions + 1] = cc.CallFunc:create(function () if v.status ~= kRoleDie then v:actAttack(callback, time, delay) end end)
		else
			actions[#actions + 1] = cc.CallFunc:create(function () if v.status ~= kRoleDie then v:actAttack(nil, time, delay) end end)
		end
		local seq = cc.Sequence:create(actions)
		self:runAction(seq)

	end

end

function S:actMove()
	if self.roleStatus== kRoleMove then
		return
	end

	self.roleStatus = kRoleMove

	for _, v in pairs(self.roles) do
		v:actMove(kSoldierAnimDelay, true)
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

function S:showDamageEffect()
	self.labelEffect:showEffect(-self.totalDamage)

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

	if math.abs(px - final.x) < 0.01 then
		role.delay = 0
		return 
	end

	local sec = math.abs(final.x-px)/kGatherSpeed

	local move = cc.MoveTo:create(sec, cc.p(final.x, py))
	move:setTag(kRoleGatherTag)
	
	role:stopActionByTag(kRoleGatherTag)
	role:runAction(move)

	role.delay = sec

		-- end
	-- end
end

function S:handleGather()
	self.fightProxy:handleGather(self.owner, self.soldierNum)
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
	local real = self.fightProxy:getRealDamage(damage, dtype)
	self.totalDamage = self.totalDamage + real
	-- print("real-", real)
	-- print("soldier totalDamage--", self.totalDamage)

end

function S:handleBuff(buff)
	self.buffNode:addBuff(buff)
	self:updateBuffAdd()
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


