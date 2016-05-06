

local R = class("RoleNode", cc.Node)

cc.exports.RoleNode = R

local kRoleOffY = -146

local kRoleActTag = 100

function R:ctor(base)
	self.baseName = base
	self.role = cc.Sprite:create()
	self.role:setAnchorPoint(cc.p(0.5, 0))
	self.status = kRoleNone
	self:addChild(self.role)
	self:actStand()
end

function R:setBaseName(base)
	self.baseName = base
end

function R:face(left)
	self.role:setFlippedX(left)
end

function R:setHighLight()
	self.role:setHighLight()
end

function R:setNormalLight()
	self.role:setNormalLight()
end

function R:actStand()
	if self.status == kRoleStand then
		return
	end

	self.status = kRoleStand
	local path = self.baseName.."_1.plist"
	self.role:playAnimate(path, kRoleActTag, true, 1.0/60)
	local frame = self.role:getSpriteFrame()
	local rect = frame:getRect()
	local size = cc.size(rect.width, rect.height)
	-- local size = self.role:getContentSize()
	self:setContentSize(size)
	-- print("rolesize w--", size.width, "h--", size.height)
	self.role:setPosition(cc.p(size.width/2, kRoleOffY))
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actMove()
	if self.status == kRoleMove then
		return
	end

	self.status = kRoleMove
	local path = self.baseName.."_2.plist"
	self.role:playAnimate(path, kRoleActTag, true, 1.0/60)
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actWin()
	if self.status == kRoleWin then
		return
	end
	
	self.status = kRoleWin
	local path = self.baseName.."_4.plist"
	self.role:playAnimate(path, kRoleActTag, true, 1.0/60)
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actOnceAction(path, callback, time)
	local actions = {}
	local anim = cc.Animation:createWithFile(path, time or 0)
	anim:setDelayPerUnit(1.0/60)
	local animate = cc.Animate:create(anim)
	animate:setTag(kRoleActTag)
	actions[#actions + 1] = animate
	
	if callback then
		actions[#actions + 1] = cc.CallFunc:create(callback)
	end

	self.role:stopActionByTag(kRoleActTag)
	local seq = cc.Sequence:create(actions)
	seq:setTag(kRoleActTag)
	self.role:runAction(seq)
end

function R:actAttack(callback, time)
	if self.status == kRoleAttack then
		return
	end
	
	self.status = kRoleAttack
	local path = self.baseName.."_3.plist"
	self:actOnceAction(path, callback, time)
	
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actDie(callback, time)
	if self.status == kRoleDie then
		return
	end
	
	self.status = kRoleDie
	local path = self.baseName.."_5.plist"
	self:actOnceAction(path, callback, time)
	-- self.role:playAnimate(path, SRoleActTag, true)

end

function R:actSkill1(callback, time)
	if self.status == kRoleSkill1 then
		return
	end
	
	self.status = kRoleSkill1
	local path = self.baseName.."_6.plist"
	self:actOnceAction(path, callback, time)
	-- self.role:playAnimate(path, SRoleActTag, true)
end

function R:actSkill2(callback, time)
	if self.status == kRoleSkill2 then
		return
	end
	
	self.status = kRoleSkill2
	local path = self.baseName.."_7.plist"
	self:actOnceAction(path, callback, time)
	-- self.role:playAnimate(path, SRoleActTag, true)
end

function R:reset()
	self.status = kRoleNone
	self:actStand()
end

return R