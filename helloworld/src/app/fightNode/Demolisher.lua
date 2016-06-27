local D = class("Demolisher", cc.Node)

cc.exports.Demolisher = D


function D:ctor(baseImage, buildSize, ident)
	self.baseImage = "building/"..baseImage
	self.buildSize = buildSize
	self.ident = ident

	local icon = cc.Sprite:create()
	icon:setAnchorPoint(cc.p(0, 0))
	self:addChild(icon)
	self.icon = icon

	self.shootPos = cc.p(0, 0)

end

function D:createTargetHalo()
	local halo = cc.Sprite:create("bg/b11.png")
	self:addChild(halo)
	self.targetHalo = halo
end

function D:setOffY(offY)
	-- 
end

function D:setOwner(owner)

	local image = self.baseImage.."_"..owner..".png"
	self.icon:setTexture(image)

	local sz = self.icon:getContentSize()
	self:setContentSize(sz)

	return sz

end

function D:showColor(color)
	-- self.sp1:setColor(cc.c3b(color.r, color.g, color.b))
	self.icon:setColor(cc.c3b(color.r, color.g, color.b))
	-- if self.man then
		-- self.man:setColor(cc.c3b(color.r, color.g, color.b))
	-- end
end

function D:setHighLight()
	-- self.sp1:setHighLight()
	self.icon:setHighLight()
	-- if self.man then
		-- self.man:setHighLight()
	-- end
end

function D:setNormalLight()
	-- self.sp1:setNormalLight()
	self.icon:setNormalLight()	
	-- if self.man then
		-- self.man:setNormalLight()
	-- end
end

function D:actStand()
	-- 
	-- print("act stand")
	self.icon:setPosition(cc.p(0, 0))

end

function D:updateFace(dir)
	
	
end

function D:attackPath(dir)
	local angle = cc.pToAngleSelf(dir)
	local flag=0
	local r1 = math.pi * 0.125
	local r2 = math.pi * 0.375
	local r3 = math.pi * 0.625
	local r4 = math.pi * 0.875
	
	-- print("dirx-", dir.x, "diry-", dir.y, "angle-", angle)
	if angle < r1 and angle >= -r1 then
		flag = 7
		
	elseif angle < -r1 and angle >= -r2 then
		flag = 8
		-- if self.buildSize == 1 then
		-- 	self.shootPos = cc.p(0, 100)
		-- elseif self.buildSize == 2 then
		-- 	self.shootPos = cc.p(0, 114)
		-- elseif self.buildSize == 3 then
		-- 	self.shootPos = cc.p(0, 144)
		-- end
	elseif angle < -r2 and angle >= -r3 then
		flag = 1
		-- self.buildSize == 1 then
		-- 	self.shootPos = cc.p(0, 106)
		-- elseif self.buildSize == 2 then
		-- 	self.shootPos = cc.p(0, 120)
		-- elseif self.buildSize == 3 then
		-- 	self.shootPos = cc.p(0, 144)
		-- end
	elseif angle < -r3 and angle >= -r4 then
		flag = 2
		-- self.buildSize == 1 then
		-- 	self.shootPos = cc.p(0, 100)
		-- elseif self.buildSize == 2 then
		-- 	self.shootPos = cc.p(0, 114)
		-- elseif self.buildSize == 3 then
		-- 	self.shootPos = cc.p(0, 144)
		-- end
	elseif angle < -r4 or angle >= r4 then
		flag = 3
		-- self.shootPos = cc.p(44, 108)
	elseif angle < r4 and angle >= r3 then
		flag = 4
		-- self.shootPos = cc.p(40, 120)
	elseif angle < r3 and angle >= r2 then
		flag = 5
		-- self.shootPos = cc.p(48, 124)
	elseif angle < r2 and angle >= r1 then
		flag = 6
		-- self.shootPos = cc.p(60, 116)
	end

	if self.buildSize == 1 then
			self.shootPos = cc.p(5, 100)
	elseif self.buildSize == 2 then
			self.shootPos = cc.p(5, 114)
	elseif self.buildSize == 3 then
			self.shootPos = cc.p(5, 144)
	end

	return "action/1J_"..flag..".plist"
	
end

function D:actAttack(rate, dir)
	-- 
	-- local instance = cc.AnimationCache:getInstance()
	local path = self:attackPath(dir)
	-- local anim = instance:getAnimation(path)
	-- if not anim then
		local anim = cc.Animation:createWithFile(path, rate)
		local delay1 = anim:getDelayPerUnit()
		if delay1 == 0 or delay1 > kSoldierAnimDelay then
			anim:setDelayPerUnit(kSoldierAnimDelay)
		end
		-- anim:setDelayPerUnit(kSoldierAnimDelay)
		anim:setRestoreOriginalFrame(true)
		-- instance:addAnimation(anim,path)
		local frames = anim:getFrames()
		local frame = frames[1]
		local userInfo = {fightId = self.ident, index = 1, atype = kRoleNone}
		frame:setUserInfo(userInfo)
		frame = frames[6]
		userInfo = {fightId = self.ident, index=6, atype = kRoleAttack}
		frame:setUserInfo(userInfo)
	-- end
		
	local animate = cc.Animate:create(anim)
	-- animate:setTag(kRoleActTag)
	local actions = {}
	actions[#actions + 1] = animate
	
	-- if callback then
		actions[#actions + 1] = cc.CallFunc:create(function() self:actStand() end)
	-- end

	self.icon:stopActionByTag(kRoleActTag)
	local seq = cc.Sequence:create(actions)
	seq:setTag(kRoleActTag)
	self.icon:runAction(seq)
	

end

function D:handleAnimationFrameDisplayed(target, userInfo)
	if userInfo.index == 1 then
		if self.buildSize == 1 then
			self.icon:setPosition(cc.p(-110, -53))
		elseif self.buildSize == 2 then
			self.icon:setPosition(cc.p(-100,-112))
		elseif self.buildSize == 3 then
			self.icon:setPosition(cc.p(-76, -107))
		end
	-- elseif userInfo.index ==  then
	end
end

















