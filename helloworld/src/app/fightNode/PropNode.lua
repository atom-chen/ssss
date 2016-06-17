
local P = class("PropNode", cc.Node)

cc.exports.PropNode = P


function P:ctor(cfg, target, attack, ratio)
	self:enableNodeEvents()
	self.cfg = cfg
	self.ratio = ratio
	self.type = kPropType

	self:createFightProxy(cfg.id, target, attack)
	self:createFSM()
	self:createIcon()

end

function P:onExit()
	self:stopMove()
end

function P:setStandPos(pos)
	self.pos = pos
	self:setPosition(pos)
end

function P:propImage()
	return "flyprop/"..self.cfg.flyEffect..".png"
end

function P:createIcon()
	local image = self:propImage()
	local icon = cc.Sprite:create(image)
	self:addChild(icon)
	self.icon = icon

end

function P:createFightProxy(skillId, target, attack)

	local fightProxy = FightProxy:create()
	-- fightProxy:parseGeneralCfg(cfg, ident)
	fightProxy:parsePropCfg(skillId, attack)
	-- print("target", target)
	fightProxy:setTarget(target)
	self.fightProxy = fightProxy

end

function P:createFSM()
	local fsm = StateMachine:create()

	fsm:bindStateCallback(kRoleStateMove, function() self:actMove() end)

	self.FSM = fsm
end

function P:updateMove(dt)
	local proxy = self.fightProxy
	-- print("prop move")
	if proxy:isTargetDead() then
		self.FSM:setState(kRoleStateClear)
		return
	end

	local tp = proxy.target:reachPos()
	local dir = cc.pNormalize(cc.pSub(tp, self.pos))
	local m = kPropMoveSpeed *dt
	local dis = cc.pGetDistance(tp, self.pos)
	self.icon:setFlippedX(dir.x < 0)
	if dis <= m then
		self:handleAttack()
	else
		self:setStandPos(cc.pAdd(self.pos, cc.pMul(dir, m)))
	end

end

function P:stopMove()
	if self.moveEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.moveEntry)
		self.moveEntry = nil
	end
end

function P:actMove()
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





