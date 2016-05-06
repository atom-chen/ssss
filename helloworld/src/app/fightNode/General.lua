
local G = class("General", cc.Node)

cc.exports.General = G

function G:ctor(cfg, owner)
	self.cfg = cfg
	self.owner = owner
	self.type = 2
	self.isDead = false

	local image = self:roleImage()
	self.role = RoleNode:create(image)
	self.role:setAnchorPoint(cc.p(0, 0))
	self.role:setPosition(cc.p(0, 0))
	self:addChild(self.role)
	self.role:face(owner == 2)

	local size = self.role:getContentSize()
	self:setContentSize(size)
	self.acceptR = size.width / 2

	self:createFightNode()

	self:createLabelEffect()
	
end

function G:createLabelEffect()

		local effect = LabelEffect:create()
		effect:setAnchorPoint(cc.p(0.5, 0))
		effect:setPosition(self.role:topCenter())
		self.role:addChild(effect)
		self.labelEffect = effect

end


function G:createFightNode()


		local fightNode = FightManager:create()
		fightNode:parseGeneralCfg(self.cfg)
		self.fightNode = fightNode

end

function G:roleImage()
	return "action/"..self.cfg.icon
end

function G:isTouchEnabled()
	return true
end

function G:isInvalid()
	return self.role.status == kRoleDie
end

function G:setTarget(target)
	self.fightNode:setTarget(target)
end

function G:setTargetPos(pos)
	self.fightNode:setTargetPos(pos)
end

function G:setStandPos(pos)
	self.fightNode:setStandPos(cc.p(pos.x ,pos.y+20))
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

function G:isRemoteDamage()
	return self.fightNode:isRemoteDamage()
end

function G:reachPos()
	return self.fightNode.standPos
end

function G:acceptRadius()
	return self.acceptR
end

function G:updateMove(dt)
	local status, last, face = self.fightNode:checkMove(dt)
	if status == kFightStatusNotReach then
		-- print("general move-x--", last.x, "y--", last.y)
		self.role:face(face)
		self.role:actMove()
		self:setPosition(last)
		
	end

	return status, last
end

function G:updateAttack(dt)
	if self.role.status == kRoleDie then
		return
	end

	local status, rate, face = self.fightNode:checkAttack(dt)

	if status == kFightStatusReach then
		-- print("isinvalid", self.fightNode:isTargetInvalid())
		if self.fightNode:isTargetInvalid() or self.fightNode:theSameOwner(self.owner) then
			self.fightNode:setTargetPos(nil)
			self.role:actStand()
		else
			self.role:face(face)
			self:actAttack(function()
				self:handleFight()
				self.role:actStand()
				end, rate)
		end
	end

	return status, rate

end

function G:attackRatio()
	math.randomseed(os.time())
	return math.random(75, 125)/100.0
end

function G:actAttack(callback, rate)
	local atype = self.fightNode:currentAction()
	if atype == kNormalAttack then
		self.role:actAttack(callback, rate)
	elseif atype == kSkill1 then
		self.role:actSkill1(callback, rate)
	elseif atype == kSkill2 then
		self.role:actSkill2(callback, rate)
	end

end

function G:handleDamage(damage)

	local alive, num = self.fightNode:handleHurt(damage)

	self:showNumEffect(num)

	return alive
end

function G:showNumEffect(num)
	self.labelEffect:showEffect(num)
end

function G:handleFight()
	self.fightNode:handleFight(self, self:attackRatio())
end

function G:handleBeAttacked(ntype, damage, dtype)
	local real = self.fightNode:getRealDamage(ntype, damage, dtype)
	print("general handle be attacked")
	local alive = self:handleDamage(real)

	if not alive then
		self.role:actDie(
				function()
					self.isDead = true
				end)
	end
end

function G:handleAttackBack(ntype, damage, dtype)
	print("general handle attack back")
	self:handleBeAttacked(ntype, damage, dtype)

end

-- function General:checkAttackBack(node)
-- 	local remote = node:isRemoteDamage()

-- 	if not remote then
-- 		self.fightNode:handleAttackBack(self.type, node, self:attackRatio())
-- 	end
-- end

function G:handleBeAttackedBySoldier(node, damage, dtype)
	print("general attacked by soldier")
	self:handleBeAttacked(node.type, damage, dtype)

	-- self.fightNode:checkAttackBack(node, self.type, self:attackRatio())

	self.fightNode:checkAutoFight(node)

end

function G:handleBeAttackedByGeneral(general, damage, dtype)
	self:handleBeAttacked(general.type, damage, dtype)

	-- self.fightNode:checkAttackBack(general, self.type, self:attackRatio())

	self.fightNode:checkAutoFight(general)

end



return G
















