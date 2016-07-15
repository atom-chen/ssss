

local M = class("SkillLayer", cc.Layer)

cc.exports.SkillLayer = M

function M:ctor()
	self.winSize = cc.Director:getInstance():getWinSize()

	self:onTouch(function(event) return self:touchesEvent(event) end, false, true)

	local node = cc.Sprite:create("bg/b15_2.png")
	node:setVisible(false)
	self:addChild(node)
	self.drawNode = node
	local sz = node:getContentSize()
	self.defaultR = sz.width/2
	self.skillPoint = 0
	self.totalTime = 0
end

function M:createSkillBg()
	local skillBg = cc.Sprite:create("progressbar/b18_0.png")

	skillBg:setAnchorPoint(cc.p(0.5, 0))
	skillBg:setPosition(self.winSize.width/2, 0)
	self:addChild(skillBg)

	local pb = cc.Sprite:create("frame/a48.png")
	pb:setAnchorPoint(cc.p(0, 0))
	pb:setPosition(cc.p(646, 0))
	skillBg:addChild(pb)

	local point = cc.Label:createWithSystemFont("0", "Arial", 22)
	point:setTextColor(cc.num2c4b(0xfbf300ff))
	point:enableOutline(cc.num2c4b(0x401700ff), 2)
	point:setPosition(pb:centerPos())
	pb:addChild(point)
	self.pointLbl = point

	local pl = {}
	for i=1, 10 do
		local p = cc.Sprite:create("progressbar/b18_1.png")
		p:setVisible(false)
		
		if i>=7 then
			p:setPosition(cc.p(60 * i-3, 10))
		else
			p:setPosition(cc.p(60 * i, 10))
		end
		skillBg:addChild(p)
		pl[#pl + 1] = p
	end
	self.pointList = pl

	local shadow = cc.Sprite:create("progressbar/b18_1.png")
	shadow:setGray()
	shadow:setOpacity(150)
	shadow:setAnchorPoint(cc.p(0, 0.5))
	shadow:setPosition(cc.p(30, 10))
	skillBg:addChild(shadow)
	self.shadow = shadow

	return skillBg
end

function M:createSkills(list)
	list = list or {}
	local winSize = self.winSize
	
	local skillBg = self:createSkillBg()
	local skillList = {}

	for i=1, 5 do
		local x = 118 * i - 25
		local sp = cc.Sprite:create("frame/b2_0.png")
		sp:setAnchorPoint(cc.p(0.5, 0))
		sp:setPosition(cc.p(x, 2))
		skillBg:addChild(sp, -1)

		local idx = #list

		if idx > 0 then
			local skill = list[idx]
			list[idx] = nil
			
			local item = SkillNode:create(skill)
			item:setAnchorPoint(cc.p(0.5, 0.5))
			item:setPosition(cc.p(x, 70))
			skillBg:addChild(item)
			skillList[#skillList + 1] = item
			
		end
		
	end
		
	self.skillList = skillList

end

function M:createSummonNode(pos)
	local cfg = self.currentSkill.cfg
	
	for _, i in pairs(cfg.summonList) do
		if self.summonNode then
			return
		end

		local v = summonSkills[i]
		local scfg = soldiers[v.soldierId]
		local soldier = Soldier:create(scfg, kOwnerPlayer, v.num, nil, 0)
		-- soldier:setScale(self.sceneScale)
		soldier:setAnchorPoint(cc.p(0.5, 0.5))
		soldier:setPosition(pos)
		self:addChild(soldier)
		self.summonNode = soldier
	end

end

function M:setFightSceneScale(scale)
	self.sceneScale = scale
end

function M:handleSkill(pos)
	if not self.currentSkill then
		return
	end

	local item = self:getItemForPos(pos)
	if not item then

		local scene = cc.Director:getInstance():getRunningScene()
		if scene.sceneType == kFightScene then
			local skill = self.currentSkill.cfg
			self:addSkillPoint(-skill.skillcost)
			self.currentSkill:setCDTime(kSkillCDTime)
			scene:handleManualSkill(skill, pos)
		end
	end

	self.currentSkill:unselect()
	self.currentSkill = nil

end

function M:getItemForPos(pos)
	local childs = self.skillList
	-- print("item pos ,x-", pos.x, "y-", pos.y)
	for _, v in pairs(childs) do
		-- print("childen v-", v, "class-", v.__cname)
		if v:isSkillEnabled() then
			local p = v:convertToWorldSpace(cc.p(0, 0))
			local s = v:getRealContentSize()
			local box = cc.rect(p.x, p.y, s.width, s.height)
			-- print("box-x", box.x ,"y-", box.y, "w-", box.width, "h-", box.height)
			-- if v.type == 2 then
				 -- print("general---")
			-- end
			if cc.rectContainsPoint(box, pos) then
				return v
			end
		end
	end

end

function M:skillRadius(skillNode)
	local cfg = skillNode.cfg
	local radius = 0
	for _, i in pairs(cfg.damageList) do
		local v = damageSkills[i]
		radius = math.max(radius, v.damageRange)
	end
	for _, i in pairs(cfg.buffList) do
		local v = buffSkills[i]
		radius = math.max(radius, v.damageRange)
	end
	for _, i in pairs(cfg.cureList) do
		local v = cureSkills[i]
		radius = math.max(radius, v.cureRange)
	end

	return radius * self.sceneScale
end

function M:addSkillPoint(point)
	if self.skillPoint >= kMaxSkillPoint and point > 0 then
		return
	end

	self.skillPoint = math.min(self.skillPoint + point, 10)
	self.pointLbl:setString(self.skillPoint.."")


	for i, v in pairs(self.pointList) do
		v:setVisible(i <= self.skillPoint)
	end

	self.shadow:setPosition(cc.p(self.skillPoint * 60 + 30, 10))

end

function M:updateSkillPoint(dt)
	if self.skillPoint >= kMaxSkillPoint then
		return
	end
	
	self.totalTime = self.totalTime + dt
	if self.totalTime >= kSkillPointSpeed then
		self:addSkillPoint(1)
		self.totalTime = self.totalTime - kSkillPointSpeed
	end

	
	-- print("scalex", self.totalTime/kSkillPointSpeed)
	self.shadow:setScaleX(self.totalTime/kSkillPointSpeed)
end

function M:updateTime(dt)
	for _, v in pairs(self.skillList) do
		v:updateCDTime(dt, self.totalTime, self.skillPoint)
	end

	self:updateSkillPoint(dt)

end

function M:stopFight()

	if self.skillEntry then

		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.skillEntry)
		self.skillEntry = nil

	end

end

function M:startFight()
	if not self.skillEntry then
		local scheduler = self:getScheduler()
		self.skillEntry = scheduler:scheduleScriptFunc(function(dt) self:updateTime(dt) end, 1.0/30, false)
	end

end

function M:handleTouchBegan(event)
	local pos = cc.p(event.x, event.y)
	local item = self:getItemForPos(pos)
	if item then
		item:select()
		self.currentSkill = item
		
		local radius = self:skillRadius(item)
		if radius > 0 then
			-- self.drawNode:drawCircle(cc.p(0, 0), radius, 0, 50, false, cc.c4f(0, 1.0, 0, 1.0))
			self.drawNode:setVisible(true)
			self.drawNode:setPosition(pos)
			self.drawNode:setScale(radius / self.defaultR)
		end

		self:createSummonNode(pos)

		return true
	end

	return false
end


function M:handleTouchMoved(event)
	
	if self.summonNode then
		self.summonNode:setPosition(cc.p(event.x, event.y))
	else
		self.drawNode:setPosition(cc.p(event.x, event.y))
	end
end

function M:handleTouchEnded(event)
	
	if self.currentSkill then
		
		if self.summonNode then
			self.summonNode:removeFromParent(true)
			self.summonNode = nil
		else
			self.drawNode:setVisible(false)
		end

		
		self:handleSkill(cc.p(event.x, event.y))

	end

end

function M:touchesEvent(event)
	if event.name == "began" then
		return self:handleTouchBegan(event)
	elseif event.name == "moved" then
		self:handleTouchMoved(event)
	else
		self:handleTouchEnded(event)
	end
end



return M


