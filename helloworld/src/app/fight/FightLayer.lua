
local FightLayer = class("FightLayer", cc.Layer)

local generalCfg = cc.exports.generals
local kFightStatusNotReach = 0
local kSelfOwner = 2

function FightLayer:ctor(mapInfo, size)

	self:onTouch(function(event) return self:touchesEvent(event) end, false, true)
	self.activeList = {}
	self.buildList = {}
	self.generalList = {}
	self.soldierList = {}
	self.attackList = {}
	self.mapSize = size

	self.currentTarget = nil
	self.currentType = -1

	self.mapInfo = mapInfo

	self:createBuildings(mapInfo.buildings)

	self:createGenerals(mapInfo.generals)

end

function FightLayer:createBuildings(buildings)
	for _, v in pairs(buildings) do
		local build = self:createBuilding(v)
		build:setSoldierNum(v.oriNum)
		build:setAnchorPoint(cc.p(0.5, 0))
		local pos = cc.p(v.pos.x, self.mapSize.height-v.pos.y-build.bed:getContentSize().height/2)
		build:setPosition(pos)
		local z = self:buildZOrder(build:reachPos())
		print("pos.y", pos.y, "z-", z)
		self:addChild(build, z)
		self.buildList[build.id] = build
	end
end

function FightLayer:createGenerals(generals)
	for _, v in pairs(generals) do
		local gcfg = generalCfg[1]

		local general = self:createGeneral(gcfg, 2, v.id)
		general:setAnchorPoint(cc.p(0.5, 0))
		general:setStandPos(v.pos)
		local z = self:buildZOrder(general:reachPos())
		self:addChild(general, z)
		self.generalList[general.id] = general
	end
end

function FightLayer:createBuilding(cfg)
	local cls = require("app.fight.Building")
	if cls then
		return cls:create(cfg, 2)
	else
		print("load app.fight.Building failed")
	end
end

function FightLayer:createGeneral(cfg, owner, id)
	local cls = require("app.fight.General")
	if cls then
		return cls:create(cfg, 2, id)
	else
		print("load app.fight.General failed!")
	end
end

function FightLayer:getItemForPos(pos)
	local childs = self:getChildren()
	-- print("item pos ,x-", pos.x, "y-", pos.y)
	for _, v in pairs(childs) do
		-- print("childen v-", v, "class-", v.__cname)
		if v.isTouchEnabled and v:isTouchEnabled() and v:isVisible() then

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


function FightLayer:addBuilding(pos, owner)

end

function FightLayer:addActiveObj1(pos, owner)
	local build = self:getItemForPos(pos)

	if not build then
		return false
	end

	if build.owner == owner then
		build:setHighLight()
	elseif owner == -1 then

	end

	if owner == -1 then
		if build.owner ~= kSelfOwner then
			if self.currentTarget then
				self.currentTarget:setNormalLight()
			end
			self.currentTarget = build
		elseif build.type == last.type then
			self.activeList[build.id] = build
		else
			return false
		end
		build:setHighLight()
		return true
	elseif build.owner == owner then
		self.activeList[build.id] = build
		build:setHighLight()
		return true
	end

	return false

end

function FightLayer:addActiveObj(pos, owner)
	local build = self:getItemForPos(pos)
	local c = #self.activeList
	local last = self.activeList[c]

	if not build then
		return false
	end

	for _, v in pairs(self.activeList) do
		if v == build then
			return false
		end
	end

	local first = self.activeList[1]
	if first and first.owner == build.owner and first.type ~= build.type then
		return false
	end

	if owner == -1 or build.owner == owner then

		if last and last.owner ~= 2 then
			if build.owner ~= 2 then
				last:setNormalLight()
				self.activeList[c] = build
			else
				self.activeList[c + 1] = last
				self.activeList[c] = build
			end
		else
			self.activeList[#self.activeList + 1] = build
		end

		build:setHighLight()
		-- print("add true")
		return true
	end
	-- print("add false")
	return false
end

function FightLayer:updateMoveList(list, dt)

	for _, v in pairs(list) do
		local status, pos = v:updateMove(dt)
		if status == kFightStatusNotReach then
			local z = self:buildZOrder(pos)
			v:setLocalZOrder(z)
		end
	end

end

function FightLayer:updateMoveEvent(dt)

	self:updateMoveList(self.soldierList, dt)
	self:updateMoveList(self.generalList, dt)

end

function FightLayer:updateAttackList(list, dt)
	for _, v in pairs(list) do
		
	end
end

function FightLayer:updateAttackEvent(dt)
	local doneList = {}
	for i, v in pairs(self.soldierList) do
		v:updateAttack(dt)
		if v.workDone then
			doneList[#doneList + 1] = i
		end
	end

	for _, i in pairs(doneList) do
		local v = self.soldierList[i]
		v:handleFight()
		v:removeFromParent(true)
		self.soldierList[i] = nil
	end

	for _, v in pairs(self.generalList) do
		v:updateAttack(dt)
	end

end

function FightLayer:updateEvent(dt)
	-- print("update event", dt)
	self:updateMoveEvent(dt)

	self:updateAttackEvent(dt)

end

function FightLayer:startFight()
	for _, v in pairs(self.buildList) do
		v:startUpdateSoldierNum()
	end

	local scheduler = self:getScheduler()
	scheduler:scheduleScriptFunc(function(dt) self:updateEvent(dt) end, 0.01, false)
end

function FightLayer:dispatchTroops1()

	if self.currentTarget then
		self.currentTarget:setNormalLight()
	end

	-- print("count--", #self.activeList)
	for _, v in pairs(self.activeList) do
		-- print("nnnn")
		v:setNormalLight()

		local soldier = v:createSoldier(self.currentTarget)
		if soldier then
			local vx, vy = v:getPosition()
			local pos = cc.pSub(cc.p(vx, vy), cc.p(0, 10))
			soldier:setAnchorPoint(cc.p(0.5, 0.5))
			soldier:setStandPos(pos)
			self:addChild(soldier)
			self.soldierList[#self.soldierList + 1] = soldier
		end

	end

end

function FightLayer:dispatchTroops()
	local target = self.activeList[#self.activeList]
	target:setNormalLight()
	
	if #self.activeList == 1 then
		return
	end

	local first = self.activeList[1]
	local dispatch = true
	if first.owner == target.owner and target.type == 2 then
		dispatch = false
	end

	self.activeList[#self.activeList] = nil
	-- print("count--", #self.activeList)
	for _, v in pairs(self.activeList) do
		-- print("nnnn")
		v:setNormalLight()
		if dispatch then
			local soldier = v:createSoldier(target)
			if soldier then
				local vx, vy = v:getPosition()
				local pos = cc.pSub(cc.p(vx, vy), cc.p(0, 10))
				soldier:setAnchorPoint(cc.p(0.5, 0.5))
				soldier:setStandPos(pos)
				self:addChild(soldier)
				self.soldierList[#self.soldierList + 1] = soldier
			end
		end
	end
end

function FightLayer:dispatchGeneral(pos)

	if self.currentTarget then
		self.currentTarget:setNormalLight()
	end

	for _, v in pairs(self.activeList) do
		v:setNormalLight()
		if not self.currentTarget then
			v:setTargetPos(self:convertToNodeSpace(pos))
		else
			v:setTarget(self.currentTarget)
		end
	end
end

function FightLayer:buildZOrder(pos)
	return math.floor(self.mapSize.height-pos.y)
end

function FightLayer:handleFight1(pos)

	local last = self.activeList[#self.activeList]
	if not last then
		return 
	end

	if last.type == 1 then
		self:dispatchTroops1()
	elseif last.type == 2 then
		self:dispatchGeneral(pos)
	end

	self.activeList = {}
	self.currentTarget = nil

end

function FightLayer:handleFight(pos)

	if #self.activeList then
		local first = self.activeList[1]
		if first.type == 1 then
			self:dispatchTroops()
		else
			self:dispatchGeneral(pos)
		end

		self.activeList = {}
	end

end

function FightLayer:handleTouchBegan(event)
	return self:addActiveObj(cc.p(event.x, event.y), 2)
end

function FightLayer:handleTouchMoved(event)
	self:addActiveObj(cc.p(event.x, event.y), -1)
end

function FightLayer:handleTouchEnded(event)
	self:handleFight(cc.p(event.x, event.y))
end

function FightLayer:touchesEvent(event)
	if event.name == "began" then
		return self:handleTouchBegan(event)
	elseif event.name == "moved" then
		self:handleTouchMoved(event)
	else
		self:handleTouchEnded(event)
	end
end


return FightLayer