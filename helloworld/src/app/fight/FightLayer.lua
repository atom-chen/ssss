
local FightLayer = class("FightLayer", cc.Layer)

local generalCfg = cc.exports.generals
local kFightStatusNotReach = 0
local kPlayerOwner = 1

function FightLayer:ctor(mapInfo, size)

	self:onTouch(function(event) return self:touchesEvent(event) end, false, true)
	self.buildList = {}
	self.attackBuild = {}
	self.generalList = {}
	self.soldierList = {}
	self.attackList = {}
	self.mapSize = size

	self.mapInfo = mapInfo

	self:createActionNode()
	self:createBuildings(mapInfo.buildings)

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
		build:setStandPos(pos)
		local z = self:buildZOrder(build:reachPos())
		-- print("pos.y", pos.y, "z-", z)
		self:addChild(build, z)
		self.buildList[build.id] = build
		if build:isAttackBuild() then
			self.attackBuild[#self.attackBuild + 1] = build
		end
	end
end

function FightLayer:createGenerals(list)
	local generals = self.mapInfo.generals

	local generalId = 0
	for _, v in pairs(generals) do
		if v.generalId == 0 then
			if #list > 0 then
				generalId = list[#list]
				list[#list] = nil
			end
		else
			generalId = v.generalId
		end

		local gcfg = generalCfg[generalId]

		local general = self:createGeneral(gcfg, v.owner, v.id)
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
		return cls:create(cfg)
	else
		print("load app.fight.Building failed")
	end
end

function FightLayer:createGeneral(cfg, owner, id)
	local cls = require("app.fight.General")
	if cls then
		return cls:create(cfg, owner, id)
	else
		print("load app.fight.General failed!")
	end
end

function FightLayer:findNearestBuild(node)
	local mindis = 0
	local build = nil
	local pos = node:reachPos()
	for _, v in pairs(self.buildList) do
		if v.owner == node.owner then
			local dis = cc.pGetDistance(v:reachPos(), pos)
			if build == nil or mindis > dis then
				mindis = dis
				build = v
			end

		end
	end
	
	return build
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

function FightLayer:updateAttackEvent(dt)
	-- print("attack event")
	local sdoneList = {}
	for i, v in pairs(self.soldierList) do
		v:updateAttack(dt)
		if v.workDone then
			sdoneList[#sdoneList + 1] = i
		end
	end

	local gdoneList = {}
	for i, v in pairs(self.generalList) do
		v:updateAttack(dt)
		if v.isDead then
			gdoneList[#gdoneList + 1] = i
		end
	end

	for _, i in pairs(sdoneList) do
		local v = self.soldierList[i]
		if not v:isInvalid() then
			if v:isTargetInvalid() and not v:isTheSameOwnerWithTarget() then
				local target = self:findNearestBuild(v)
				v:setTarget(target)
			else
				v:handleGather()
				v:removeFromParent(true)
				self.soldierList[i] = nil
			end
		else
			v:removeFromParent(true)
			self.soldierList[i] = nil
		end
		
	end

	for _, i in pairs(gdoneList) do
		local v = self.generalList[i]
		v:removeFromParent(true)
		self.generalList[i] = nil
	end

end

function FightLayer:updateEvent(dt)
	-- print("update event", dt)

	self:updateBuildAttack(dt)

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
				soldier:setAnchorPoint(cc.p(0.5, 0.5))
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

function FightLayer:addInfluenceNode(owner, list, pos, range, influenceList)
	
	for _, v in pairs(list) do
		if v.owner ~= owner then
			local reachPos = v:reachPos()
			local radius = v:acceptRadius()
			if cc.pGetDistance(pos, reachPos) < radius + range then
				influenceList[#influenceList + 1] = v
			end
		end
	end

end

function FightLayer:handleAOE(node, pos, range, damage, dtype)
	local influenceList = {}
	self:addInfluenceNode(node.owner, self.buildList, pos, range, influenceList)
	self:addInfluenceNode(node.owner, self.generalList, pos, range, influenceList)
	self:addInfluenceNode(node.owner, self.soldierList, pos, range, influenceList)

	for _, v in pairs(influenceList) do
		v:handleBeAttackedByGeneral(node, damage, dtype)
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
	return self:addActionNode(cc.p(event.x, event.y), kPlayerOwner)
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