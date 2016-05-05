
local General = class("General", cc.Node)


local kFightStatusNotReach = 0
local kFightStatusReach = 1
local kRolwDie = 4
local kNormalAttack = 1
local kSkill1 = 2
local kSkill2 = 3
local kRoleMove = 1

function General:ctor(cfg, owner, id)
	self.cfg = cfg
	self.owner = owner
	self.type = 2
	self.id = id
	self.isDead = false

	local image = self:roleImage()
	self.role = self:createRoleNode(image)
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

function General:createLabelEffect()
	local cls = require("app.fight.LabelEffect")
	if cls then
		local effect = cls:create()
		effect:setAnchorPoint(cc.p(0.5, 0))
		effect:setPosition(self.role:topCenter())
		self.role:addChild(effect)
		self.labelEffect = effect
	else
		print("load app.fight.Soldier failed")
	end
end

function General:createRoleNode(name)
	local cls = require("app.fight.RoleNode")
	if cls then
		return cls:create(name)
	else
		print("load app.fight.RoleNode failed")
	end
end

function General:createFightNode()
	local cls = require("app.fight.FightNode")
	if cls then
		local fightNode = cls:create()
		fightNode:parseGeneralCfg(self.cfg)
		self.fightNode = fightNode
	else
		print("load app.fight.RoleNode failed")
	end
end

function General:roleImage()
	return "action/"..self.cfg.icon
end

function General:isTouchEnabled()
	return true
end

function General:isInvalid()
	return self.role.status == kRoleDie
end

function General:setTarget(target)
	self.fightNode:setTarget(target)
end

function General:setTargetPos(pos)
	self.fightNode:setTargetPos(pos)
end

function General:setStandPos(pos)
	self.fightNode:setStandPos(pos)
	self:setPosition(pos)
end

function General:select()
	-- local sp = self.role

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureHightLight")
	-- sp:setGLProgram(program)
	self.role:setHighLight()
	self:setScale(1.3)
	self.selected = true

end

function General:unselect()
	-- local sp = self.role

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	self.role:setNormalLight()
	self:setScale(1)
	self.selected = false

end

function General:checkReachTarget(pos)

end

function General:isRemoteDamage()
	return self.fightNode:isRemoteDamage()
end

function General:reachPos()
	local px, py = self:getPosition()
	return cc.p(px, py+20)
end

function General:acceptRadius()
	return self.acceptR
end

function General:updateMove(dt)
	local status, last, face = self.fightNode:checkMove(dt)
	if status == kFightStatusNotReach then
		-- print("general move-x--", last.x, "y--", last.y)
		self.role:face(face)
		self.role:actMove()
		self:setPosition(last)
		
	end

	return status, last
end

function General:updateAttack(dt)
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

function General:attackRatio()
	math.randomseed(os.time())
	return math.random(75, 125)/100.0
end

function General:actAttack(callback, rate)
	local atype = self.fightNode:currentAction()
	if atype == kNormalAttack then
		self.role:actAttack(callback, rate)
	elseif atype == kSkill1 then
		self.role:actSkill1(callback, rate)
	elseif atype == kSkill2 then
		self.role:actSkill2(callback, rate)
	end

end

function General:handleDamage(damage)

	local alive, num = self.fightNode:handleHurt(damage)

	self:showNumEffect(num)

	return alive
end

function General:showNumEffect(num)
	self.labelEffect:showEffect(num)
end

function General:handleFight()
	self.fightNode:handleFight(self, self:attackRatio())
end

function General:handleBeAttacked(ntype, damage, dtype)
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

function General:handleAttackBack(ntype, damage, dtype)
	print("general handle attack back")
	self:handleBeAttacked(ntype, damage, dtype)

end

-- function General:checkAttackBack(node)
-- 	local remote = node:isRemoteDamage()

-- 	if not remote then
-- 		self.fightNode:handleAttackBack(self.type, node, self:attackRatio())
-- 	end
-- end

function General:handleBeAttackedBySoldier(node, damage, dtype)
	print("general attacked by soldier")
	self:handleBeAttacked(node.type, damage, dtype)

	-- self.fightNode:checkAttackBack(node, self.type, self:attackRatio())

	self.fightNode:checkAutoFight(node)

end

function General:handleBeAttackedByGeneral(general, damage, dtype)
	self:handleBeAttacked(general.type, damage, dtype)

	-- self.fightNode:checkAttackBack(general, self.type, self:attackRatio())

	self.fightNode:checkAutoFight(general)

end



return General
















