

local F = class("FlightProp", cc.Node)

cc.exports.FlightProp = F

function F:ctor(target, skillId)

	-- self.targetPos = pos
	self.type = kPropType
	self.status = kPropStatusNormal

	self:createFightProxy(target, skillId)

	local image = self:propImage()
	self.icon = cc.Sprite:create(image)
	self:addChild(self.icon)
	local size = self.icon:getContentSize()
	self:setContentSize(size)

end

function F:createFightProxy(target, skillId)
	local fightProxy = FightProxy:create()
	fightProxy:setTarget(target)
	fightProxy:parsePropCfg(kPropMoveSpeed, skillId)

	self.fightProxy = fightProxy

end

function F:propImage()
	local skill = self.fightProxy:currentSkill()
	return "effect/"..skill.flyEffect..".png"
end

function F:updateMove(dt)
	self.fightProxy:updateTargetStatus()
	if self.fightProxy.targetStatus ~= kTargetValid then
		self.status = kPropStatusNoTarget
		return
	end

	local status, pos, nor = self.fightProxy:checkMove(dt)

	if status == kFightStatusNotReach then
		-- self.icon:setFlippedX(nor.x < 0)
		self.icon:setRotation(cc.pToAngleSelf(nor))
		self:setPosition(pos)
	elseif status == kFightStatusReach then
		self.status = kPropStatusHit
	end

	return status
end

function F:updateAttack(dt)
	if self.status ~= kPropStatusHit then
		return
	end

	self.fightProxy:handleAttack(self, 1)

end

return F






