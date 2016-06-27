
local P = class("PropNode", cc.Node)

cc.exports.PropNode = P

function P:ctor(cfg, target, attack, ratio, tp, dir)
	self:enableNodeEvents()
	self.cfg = cfg
	self.ratio = ratio
	self.type = kPropType
	-- self.targetPos = tp
	self.dir = cc.pNormalize(dir)
	self.currentSpeed = kPropMoveSpeed
	self:createFightProxy(cfg.id, target, attack, tp)
	self:createFSM()
	self:createIcon()

end

function P:onExit()
	self:stopMove()
end

function P:setStandPos(pos)
	self.pos = pos
	self:setPosition(pos)
	self:updateRotation()
end

function P:propImage()
	return "flyprop/"..self.cfg.flyEffect..".png"
end

function P:createIcon()

	local image = self:propImage()
	local icon = cc.Sprite:create(image)
	self:addChild(icon)
	
	self.icon = icon
	-- self.icon:setRotation(360-cc.pToAngleSelf(self.dir) * 180 / math.pi)

end

function P:createFightProxy(skillId, target, attack, tp)

	local fightProxy = FightProxy:create()
	-- fightProxy:parseGeneralCfg(cfg, ident)
	fightProxy:parsePropCfg(skillId, attack)
	-- print("target", target)
	if target then
		fightProxy:setTarget(target)
	elseif tp then
		fightProxy:setTargetPos(tp)
	end

	self.fightProxy = fightProxy

end

function P:createFSM()
	local fsm = StateMachine:create()

	fsm:bindStateCallback(kRoleStateMove, function() self:actMove() end)

	self.FSM = fsm
end

function P:updateRotation()
	
	-- if true then
	-- 	return 
	-- end

	local proxy = self.fightProxy
	if not proxy.target then
		return
	end

	local rp = proxy.target:reachPos()
	local sz = proxy.target:getContentSize()
	local tp = cc.p(rp.x, rp.y+sz.height/2)
	-- local tp = proxy.target:reachPos()

	local dir = cc.pSub(tp, self.pos)
	-- local cross = cc.pCross(self.dir, dir)
	local angle = cc.pGetAngle(self.dir, dir)
	angle = math.max(angle, -0.06)
	angle = math.min(angle, 0.06)
	-- if angle > 0.06 then
	-- 	angle = 0.06
	-- elseif angle < -0.06 then
	-- 	angle = -0.06
	-- end

	local rotate = cc.pForAngle(angle)
	self.dir = cc.pRotate(self.dir, rotate)
	self.dir = cc.pNormalize(self.dir)
	-- self.icon:setFlippedX(dir.x < 0)
	-- print("rotation", cc.pToAngleSelf(dir))
	self.icon:setRotation(360-cc.pToAngleSelf(self.dir) * 180 / math.pi)
end

function P:updateMove(dt)
	local proxy = self.fightProxy
	-- print("prop move")
	if proxy:isTargetDead() then
		self.FSM:setState(kRoleStateClear)
		return
	end

	local rp = proxy.target:reachPos()
	local sz = proxy.target:getContentSize()
	local tp = cc.p(rp.x, rp.y+sz.height/2)
	-- local tp = proxy.target:reachPos()

	local m = self.currentSpeed *dt
	local dis = cc.pGetDistance(tp, self.pos)
	-- self.icon:setFlippedX(dir.x < 0)
	-- print("rotation", cc.pToAngleSelf(dir))
	if dis <= m then
		self:handleAttack()
	else
		-- local dir = cc.pForAngle(self.angle)
		local cpos = cc.pAdd(self.pos, cc.pMul(self.dir, m))
		local cdis = cc.pGetDistance(tp, cpos)
		local dir = cc.pSub(tp, cpos)
		local rotate1 = cc.pForAngle(-0.06)
		local rotate2 = cc.pForAngle(0.06)
		local dir1 = cc.pRotate(self.dir, rotate1)
		local dir2 = cc.pRotate(self.dir, rotate2)

		local c1 = cc.pCross(dir1, dir)
		local c2 = cc.pCross(dir2, dir)
		local flag = (c1 > 0 and c2 < 0) 

		if dis - cdis < m * 0.1 then
			if not flag then
				self.currentSpeed = self.currentSpeed * 0.8
			end
		else
			if self.currentSpeed < kPropMoveSpeed and flag then
				self.currentSpeed = math.min(self.currentSpeed * 1.25, kPropMoveSpeed)
			end
		end

		self:setStandPos(cpos)
	end

end

function P:actBezierMove()
	-- local target = self.fightProxy.target
	local tp = self.fightProxy.targetPos
	local dir = cc.p(tp.x-self.pos.x, tp.y-self.pos.y)
	local len = cc.pGetLength(dir)
	local mid = cc.pMidpoint(tp, self.pos)
	local vp = cc.p(dir.y/len, -dir.x/len)
	local angle = cc.pToAngleSelf(dir)

	if angle < math.pi*0.625 and angle > -math.pi*0.375 then
		vp.x = -vp.x
		vp.y = -vp.y
	end
	local s = math.abs(math.abs(angle) - math.pi/2) * 15

	local cp = cc.pAdd(mid, cc.pMul(vp, len * 0.1+s))
	local data = {
		self.pos,
		cp,
		tp
	}
	local actions = {}
	actions[#actions + 1] = cc.BezierTo:create(len/kPropMoveSpeed, data)
	actions[#actions + 1] = cc.CallFunc:create(function() self:handleAttack() end)
	local seq = cc.Sequence:create(actions)
	self:runAction(seq)

end

function P:stopMove()
	if self.moveEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.moveEntry)
		self.moveEntry = nil
	end
end

function P:actMove()
	local skillId = self.cfg.id
	if skillId == 19 or skillId == 20 or skillId == 21 then
		self:actBezierMove()
		return
	end

	if not self.moveEntry then
		local scheduler = self:getScheduler()
		self.moveEntry = scheduler:scheduleScriptFunc(function(dt) self:updateMove(dt) end, 0, false)
	end
end

function P:handleAttack()
	-- print("prop attack")
	self.fightProxy:handleAttack(self, self.ratio)
	self.FSM:setState(kRoleStateClear)

end






