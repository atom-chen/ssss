

local Building = class("Building", cc.Node)

local buildCfg = cc.exports.buildings
local soldierCfg = cc.exports.soldiers


function Building:ctor(cfg)

	self.cfg = buildCfg[cfg.buildId]

	if not self.cfg then
		print("load build config failed! buildId: ", cfg.buildId)
	end

	self.owner = cfg.owner
	self.type = 1
	self.isScheduled = false
	self.id = cfg.id

	local image = self:bedImage()
	self.bed = cc.Sprite:create(image)
	self.bed:setAnchorPoint(cc.p(0.5, 0))
	self:addChild(self.bed, -1)

	self.acceptR = self.bed:getContentSize().width/2

	self:createBuildIcon()

	self:createTopLbl()
	self:createFightNode()

	self:createLabelEffect()

	self:updateAppearance()

end

function Building:bedImage()
	return "fightbg/FB002_"..self.cfg.size..".png"
end

function Building:createBuildIcon()

	local cls = nil
	local offY = 0
	if self.cfg.id == 4 or self.cfg.id == 5 or self.cfg.id == 6 then
		cls = require("app.fight.GuardTower")
		offY = self.bed:getContentSize().height/4
	else
		cls = require("app.fight.BuildIcon")
	end

	if cls then
		local icon = cls:create("building/"..self.cfg.icon, self.cfg.size)
		icon:setOffY(offY)
		icon:setAnchorPoint(cc.p(0, 0))
		self.icon = icon
		self:addChild(self.icon)	
	else
			print("load app.fight.buildicon failed")
	end
	
end

function Building:createLabelEffect()
	local cls = require("app.fight.LabelEffect")
	if cls then
		local effect = cls:create()
		effect:setAnchorPoint(cc.p(0.5, 0))
		effect:setPosition(self.topLbl:topCenter())
		self.topLbl:addChild(effect)
		self.labelEffect = effect
	else
		print("load app.fight.Soldier failed")
	end
end

function Building:createSoldier(target)
	if not target then
		return 
	end
	
	local cls = require("app.fight.Soldier")
	if cls then
		local num = math.floor(self.soldierNum/2)
		if num > 0 then
			local scfg = self:getCurrentSoldierCfg()
			self:setSoldierNum(self.soldierNum - num)
			-- return cls:create(scfg, self.owner, 36, target)
			return cls:create(scfg, self.owner, num, target)
		end
	else
		print("load app.fight.Soldier failed")
	end
end

function Building:createFightNode(target)
	local cls = require("app.fight.FightNode")
	if cls then
		local fightNode = cls:create()
		local scfg = self:getCurrentSoldierCfg()
		fightNode:parseBuildingCfg(scfg)
		fightNode:setStandPos(pos)
		self.fightNode = fightNode
	else
		print("load app.fight.RoleNode failed")
	end
end

function Building:createTopLbl()
	local cls = require("app.fight.SoldierTopLbl")
	if cls then
		local scfg = soldierCfg[self.cfg.soldierId]
		local topLbl = cls:create(scfg.typeId, self.owner)
		topLbl:setAnchorPoint(cc.p(0.5, 0.5))
		self:addChild(topLbl)
		self.topLbl = topLbl
		
	else
		print("load app.fight.SoldierTopLbl failed")
	end
end

function Building:setOwner(owner)
	self.owner = owner
	self:updateAppearance()
end

function Building:setStandPos(pos)
	self:setPosition(pos)
	self.fightNode:setStandPos(pos)
end

function Building:select()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureHightLight")
	-- sp:setGLProgram(program)
	self.icon:setHighLight()
	self:setScale(1.3)
	self.selected = true

end

function Building:unselect()
	-- local sp = self.icon

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	self.icon:setNormalLight()
	self:setScale(1)
	self.selected = false

end

function Building:buildImage()
	return "building/"..self.cfg.icon.."_"..self.owner..".png"
end

function Building:updateAppearance()
	local image = self:buildImage()

	-- print("building image--", image)
	self.icon:setOwner(self.owner)
	self:setContentSize(self.icon:getContentSize())
	local s = self:getContentSize()
	-- print("contentsize, x-", s.width, "h-", s.height)
	self.bed:setPosition(self:bottomCenter())
	self.topLbl:setOwner(self.owner)
	self.topLbl:setPosition(self:topCenter())

end

function Building:setSoldierNum(num)
	self.soldierNum = num
	local lblNum = self.fightNode:displayNumber(num)
	self.topLbl:setSoldierNum(lblNum)
	return lblNum
end

function Building:getCurrentSoldierCfg()
	local scfg = soldierCfg[self.cfg.soldierId]
	if not scfg then
		print("load soldier cfg failed! soldier id: ", self.cfg.soldierId)
	end
	return scfg
end

function Building:updateSoldierNum()
	local num = math.floor(self.soldierNum)
	if num < self.cfg.capacity then
		local scfg = self:getCurrentSoldierCfg()
		self:setSoldierNum(self.soldierNum + self.cfg.riseSpeed * scfg.riseRate)
	elseif num > self.cfg.capacity then
		local sub = self.soldierNum/self.cfg.capacity
		self:setSoldierNum(self.soldierNum - sub)
	end
end

function Building:updateAttack(dt)


end

function Building:startUpdateSoldierNum()
	if self.cfg.riseSpeed > 0 and self.owner > 0 and not self.isScheduled then
		self.isScheduled = true
		local scheduler = self:getScheduler()
		scheduler:scheduleScriptFunc(function(dt) self:updateSoldierNum() end, 1, false)
	end
end

function Building:reachPos()
	local px, py = self:getPosition()
	local bs = self.bed:getContentSize()
	py = py + bs.height/2
	return cc.p(px, py)
end

function Building:dispatchPos()
	return self:reachPos()
end

function Building:acceptRadius()
	return self.acceptR
end


function Building:handleDamage(damage)

	local last = self.fightNode:displayNumber(self.soldierNum)
	local currNum = self.soldierNum - damage
	local curr = self.fightNode:displayNumber(currNum)
	self:showNumEffect(curr - last)

	return curr
end

function Building:isTouchEnabled()
	return true
end

function Building:isInvalid()
	return self.soldierNum <= 0
end

function Building:isAttackBuild()
	return self.cfg.skillId ~= 15
end

function Building:aim()

end

function Building:fire()

end

function Building:battle()

end

function Building:attackRatio()
	return math.max(self.soldierNum, 0)/25.0
end

function Building:showNumEffect(num)
	self.labelEffect:showEffect(num)
end

function Building:handleGather(num)
	self:setSoldierNum(num + self.soldierNum)
end

function Building:checkAttackBack(node)
	local remote = node:isRemoteDamage()

	if not remote then
		self.fightNode:handleAttackBack(self.type, node, self:attackRatio())
	end
end

function Building:handleBeAttackedBySoldier(node, damage, dtype)
	local real = self.fightNode:getRealDamage(node.type, damage, dtype)
	local curr = self:handleDamage(real)

	if real > self.soldierNum then
		self:setOwner(node.owner)
		self.soldierNum = 0
		self.topLbl:setSoldierNum(0)
		self:startUpdateSoldierNum()
	else
		self.soldierNum = self.soldierNum - real
		self.topLbl:setSoldierNum(curr)
	end

	self.fightNode:checkAttackBack(node, self.type, self:attackRatio())

end

function Building:handleBeAttackedByGeneral(general, damage, dtype)
	local real = self.fightNode:getRealDamage(general.type, damage, dtype)

	local curr = self:handleDamage(real)
	
	if real > self.soldierNum then
		self.soldierNum = 0
		self.topLbl:setSoldierNum(0)
	else
		self.soldierNum = self.soldierNum - real
		self.topLbl:setSoldierNum(curr)
	end

	self.fightNode:checkAttackBack(general, self.type, self:attackRatio())

end


return Building

