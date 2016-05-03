

local Building = class("Building", cc.Node)

local buildCfg = cc.exports.buildings
local soldierCfg = cc.exports.soldiers

function Building:ctor(cfg)
	print("build ",cfg ," name " , cfg.name)
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

	self.icon = cc.Sprite:create()
	self.icon:setAnchorPoint(cc.p(0, 0))
	self.icon:setPosition(cc.p(0, 0))
	self:addChild(self.icon)

	self:createTopLbl()

	self:updateAppearance()

end

function Building:bedImage()
	return "fightbg/FB002_"..self.cfg.size..".png"
end

function Building:createTopLbl()
	local cls = require("app.fight.SoldierTopLbl")
	if cls then
		local scfg = soldierCfg[self.cfg.soldierId]
		local topLbl = cls:create(scfg.typeId)
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
	self.icon:setTexture(image)
	self:setContentSize(self.icon:getContentSize())
	local s = self:getContentSize()
	-- print("contentsize, x-", s.width, "h-", s.height)
	self.bed:setPosition(self:bottomCenter())
	self.topLbl:setPosition(self:topCenter())

end

function Building:setSoldierNum(num)
	self.soldierNum = num
	self.topLbl:setSoldierNum(self.soldierNum)
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

function Building:startUpdateSoldierNum()
	if self.cfg.riseSpeed > 0 and self.owner > 0 and not self.isScheduled then
		self.isScheduled = true
		local scheduler = self:getScheduler()
		scheduler:scheduleScriptFunc(function(dt) self:updateSoldierNum() end, 1, false)
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
			return cls:create(scfg, self.owner, num, target)
		end
	else
		print("load app.fight.Soldier failed")
	end
end

function Building:reachPos()
	local px, py = self:getPosition()
	local bs = self.bed:getContentSize()
	py = py + bs.height/2
	return cc.p(px, py)
end

function Building:dispatchPos()
	local px, py = self:getPosition()
	return cc.pSub(cc.p(px, py), cc.p(0, 10))
end

function Building:acceptRadius()
	return self.acceptR
end

function Building:handleBeAttackedBySoldier(soldier)

	local num = soldier.soldierNum
	if self.owner == soldier.owner then
		self:setSoldierNum(num + self.soldierNum)
	elseif num > self.soldierNum then
		self:setOwner(soldier.owner)
		self:setSoldierNum(num - self.soldierNum)
		self:startUpdateSoldierNum()
	else
		self:setSoldierNum(self.soldierNum - num)
	end

end

function Building:isTouchEnabled()
	return true
end

function Building:aim()

end

function Building:fire()

end

function Building:battle()

end


return Building

