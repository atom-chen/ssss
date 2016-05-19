

local R = class("RoleNode", cc.Node)

cc.exports.RoleNode = R

local kRoleOffY = -146


function R:ctor(base, fy, rand)
	self.baseName = base
	self.role = cc.Sprite:create()
	self.role:setAnchorPoint(cc.p(0.5, 0))
	self.status = kRoleNone
	self:addChild(self.role)
	self.fy = fy

	-- self:actStand(1.0/8)
end

function R:setBaseName(base)
	self.baseName = base
end

function R:face(left)
	if self.faceLeft == left then
		return
	end
	self.faceLeft = left
	self.role:setFlippedX(left)

	local px = -self.colorRect.x + self.oriSize.width/2

	if left then
		px = self.colorRect.x+self.colorRect.width-self.oriSize.width/2
	end
	self.role:setPosition(cc.p(px, -self.fy))

end

function R:setHighLight()
	self.role:setHighLight()
end

function R:setNormalLight()
	self.role:setNormalLight()
end

function R:actStand(delay, rand)
	if self.status == kRoleStand then
		return
	end

	self.status = kRoleStand
	local path = self.baseName.."_1.plist"
	-- print("delay-", delay)
	self.role:playAnimate(path, kRoleActTag, true, delay or 1.0/60, rand or false)

	if self.hasinit then
		return
	end
	
	self.hasinit = true
	local frame = self.role:getSpriteFrame()
	local rect = frame:getColorRect()
	local size = cc.size(rect.width, rect.height)
	self.colorRect = rect
	self:setContentSize(size)

	local oriSize = frame:getOriginalSizeInPixels()
	self.oriSize = oriSize

	-- print("rectx", rect.x, "w", rect.width)

	-- print("rolesize w--", size.width, "h--", size.height)
	self.role:setPosition(cc.p(-rect.x+oriSize.width/2, -self.fy))
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actMove(delay, rand)
	if self.status == kRoleMove then
		return
	end

	self.status = kRoleMove
	local path = self.baseName.."_2.plist"
	self.role:playAnimate(path, kRoleActTag, true, delay or 1.0/60, rand or false)
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actWin(delay, rand)
	if self.status == kRoleWin then
		return
	end
	
	self.status = kRoleWin
	local path = self.baseName.."_4.plist"
	self.role:playAnimate(path, kRoleActTag, true, delay or 1.0/60, rand or false)
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actOnceAction(path, callback, time, delay)

	-- print("path--", path)
	local actions = {}
	local instance = cc.AnimationCache:getInstance()
	local anim = instance:getAnimation(path)
	if not anim then
		anim = cc.Animation:createWithFile(path)
		anim:setDelayPerUnit(delay or 1.0/60)
		instance:addAnimation(anim,path)
	end
		
	local animate = cc.Animate:create(anim)

	actions[#actions + 1] = animate
	
	if callback then
		actions[#actions + 1] = cc.CallFunc:create(callback)
	end

	self.role:stopActionByTag(kRoleActTag)
	local seq = cc.Sequence:create(actions)
	seq:setTag(kRoleActTag)
	self.role:runAction(seq)
end

function R:actAttack(callback, time, delay)
	if self.status == kRoleAttack then
		return
	end
	
	self.status = kRoleAttack
	local path = self.baseName.."_3.plist"
	self:actOnceAction(path, callback, time, delay)
	
	-- self.role:setTexture("icon/wj1001_1001.png")
end

function R:actDie(callback, time, delay)
	if self.status == kRoleDie then
		return
	end
	
	self.status = kRoleDie
	local path = self.baseName.."_5.plist"
	self:actOnceAction(path, callback, time, delay)
	-- self.role:playAnimate(path, SRoleActTag, true)

end

function R:actSkill1(callback, time, delay)
	if self.status == kRoleSkill1 then
		return
	end
	
	self.status = kRoleSkill1
	local path = self.baseName.."_6.plist"
	self:actOnceAction(path, callback, time, delay)
	-- self.role:playAnimate(path, SRoleActTag, true)
end

function R:actSkill2(callback, time, delay)
	if self.status == kRoleSkill2 then
		return
	end
	
	self.status = kRoleSkill2
	local path = self.baseName.."_7.plist"
	self:actOnceAction(path, callback, time, delay)
	-- self.role:playAnimate(path, SRoleActTag, true)
end

function R:reset()
	self.status = kRoleNone
	self:actStand()
end

return R