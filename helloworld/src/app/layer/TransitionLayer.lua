

local M = class("TransitionLayer", cc.Layer)

cc.exports.TransitionLayer = M

function M:ctor()
	self.winSize = cc.Director:getInstance():getWinSize()

	self:onTouch(function(event) return self:touchesEvent(event) end, false, true)

	local node = cc.DrawNode:create()
	self:addChild(node)
	self.drawNode = node

end

function M:createSkills(list)
	list = list or {}
	local winSize = self.winSize
	local skillBg = cc.Sprite:create("orn/b3.png")

	local skillList = {}

	skillBg:setAnchorPoint(cc.p(0.5, 0))
	skillBg:setPosition(winSize.width/2, 0)
	self:addChild(skillBg)

	for i=1, 5 do
		local x = 28 + 134 * i
		local sp = cc.Sprite:create("frame/b2_1.png")
		sp:setAnchorPoint(cc.p(0.5, 0))
		sp:setPosition(cc.p(x, -10))
		skillBg:addChild(sp)

		local idx = #list

		if idx > 0 then
			local skill = list[idx]
			list[idx] = nil
			
			local item = SkillNode:create(skill)
			
			item:setAnchorPoint(cc.p(0.5, 0.5))
			item:setPosition(cc.p(x, 76))
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

	local scene = cc.Director:getInstance():getRunningScene()
	if scene.sceneType == kFightScene then
		local skill = self.currentSkill.cfg
		scene:handleManualSkill(skill, pos)
	end

	self.currentSkill:unselect()
	self.currentSkill = nil

end

function M:getItemForPos(pos)
	local childs = self.skillList
	-- print("item pos ,x-", pos.x, "y-", pos.y)
	for _, v in pairs(childs) do
		-- print("childen v-", v, "class-", v.__cname)

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

function M:handleTouchBegan(event)
	local pos = cc.p(event.x, event.y)
	local item = self:getItemForPos(pos)
	if item then
		item:select()
		self.currentSkill = item
		self.drawNode:setPosition(pos)

		local radius = self:skillRadius(item)
		if radius > 0 then
			self.drawNode:drawCircle(cc.p(0, 0), radius, 0, 50, false, cc.c4f(0, 1.0, 0, 1.0))
		end

		self:createSummonNode(pos)

		return true
	end

	return false
end


function M:handleTouchMoved(event)
	self.drawNode:setPosition(cc.p(event.x, event.y))
	if self.summonNode then
		self.summonNode:setPosition(cc.p(event.x, event.y))
	end
end

function M:handleTouchEnded(event)
	if self.currentSkill then
		if self.summonNode then
			self.summonNode:removeFromParent(true)
			self.summonNode = nil
		end

		self.drawNode:clear()
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


