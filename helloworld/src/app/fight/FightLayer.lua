
local FightLayer = class("FightLayer", cc.Layer)

local generalCfg = cc.exports.generals
local kFightStatusNotReach = 0
local kSelfOwner = 2

function FightLayer:ctor(mapInfo, size)

	self:onTouch(function(event) return self:touchesEvent(event) end, false, true)
	self.buildList = {}
	self.generalList = {}
	self.soldierList = {}
	self.attackList = {}
	self.mapSize = size

	self.mapInfo = mapInfo

	self:createActionNode()
	self:createBuildings(mapInfo.buildings)
	self:createGenerals(mapInfo.generals)

end

function FightLayer:createActionNode()
	local cls = require("app.fight.ActionNode")
	if cls then
		self.actionNode = cls:create()
	end
end

function FightLayer:createBuildings(buildings)
	for _, v in pairs(buildings) do
		local build = self:createBuilding(v)
		build:setSoldierNum(v.oriNum)
		build:setAnchorPoint(cc.p(0.5, 0))
		local pos = cc.p(v.pos.x, self.mapSize.height-v.pos.y-build.bed:getContentSize().height/2)
		build:setPosition(pos)
		local z = self:buildZOrder(build:reachPos())
		-- print("pos.y", pos.y, "z-", z)
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

function FightLayer:dispatchTroops(list)
	local target = list:getTroopsTarget()

	target:unselect()

	local dispatch = true
	if list.owner == target.owner and list.type ~= target.type then
		dispatch = false
	end

	for _, v in pairs(list.list) do
		v:unselect()
		if dispatch then
			local soldier = v:createSoldier(target)
			if soldier then
				local pos = v:dispatchPos()
				soldier:setStandPos(pos)
				local z = self:buildZOrder(pos)
				self:addChild(soldier, z)
				self.soldierList[#self.soldierList + 1] = soldier
			end
		end
	end
end

function FightLayer:dispatchGeneral(list, pos)
	local target = list.target
	if target then
		target:unselect()
	end

	for _, v in pairs(list.list) do
		v:unselect()
		if not target then
			v:setTargetPos(self:convertToNodeSpace(pos))
		else
			v:setTarget(target)
		end
	end
end

function FightLayer:handleAction(pos)

	local list = self.actionNode:currentActionList()

	if #list.list then
		if list.type == 1 then
			self:dispatchTroops(list)
		else
			self:dispatchGeneral(list, pos)
		end

		self.actionNode:actionDone()
	end

end

function FightLayer:addActionNode(pos, owner)
	local node = self:getItemForPos(pos)

	if not node or node.selected then
		return false
	end

	if owner ~= -1 then
		if node.owner ~= owner then
			return false
		else
			self.actionNode:addActionList(node.type, owner)
		end
	end

	self.actionNode:addNode(node)

	return true

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

function FightLayer:handleTouchBegan(event)
	return self:addActionNode(cc.p(event.x, event.y), 2)
end

function FightLayer:handleTouchMoved(event)
	self:addActionNode(cc.p(event.x, event.y), -1)
end

function FightLayer:handleTouchEnded(event)
	self:handleAction(cc.p(event.x, event.y))
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

function FightLayer:buildZOrder(pos)
	return math.floor(self.mapSize.height-pos.y)
end

return FightLayer