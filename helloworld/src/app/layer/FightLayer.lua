

local FightLayer = class("FightLayer", cc.Layer)

cc.exports.FightLayer = FightLayer


function FightLayer:ctor(mapInfo, size)

	self:onTouch(function(event) return self:touchesEvent(event) end, false, true)
	self.soldierList = {}
	self.propList = {}

	self.mapSize = size

	self.mapInfo = mapInfo
	self.fightId = 0
	self.fightTime = 0

	self.dispatchManager = DispatchManager:create()

	self:createBuildings(mapInfo.buildings, size)

	local drawNode = cc.DrawNode:create()
	-- drawNode:setAnchorPoint(cc.p(0, 0))
	-- drawNode:setLineWidth(5)
	self:addChild(drawNode, 1)
	self.drawNode = drawNode

	

end

function FightLayer:createBuild(cfg, owner, pos, num)
	local bedImage = "fightbg/FB002_"..cfg.size..".png"
	local bed = cc.Sprite:create(bedImage)
	self:addChild(bed)

	local halo = cc.Sprite:create()
	halo:setVisible(false)
	self:addChild(halo, 3)

	local bedSize = bed:getContentSize()
	local ident = self:currentFightId()

	local build = Building:create(cfg, kOwnerPlayer, bedSize, ident, halo)

	local drawNode = cc.DrawNode:create()
	self:addChild(drawNode, 1)
	build:setDrawNode(drawNode)

	build:setSoldierNum(num)
	build:setAnchorPoint(cc.p(0.5, 0))
	local bs=build:getContentSize()
	local bpos=cc.p(pos.x+bs.width/2, pos.y-bs.height)
	-- print("bpos.x", bpos.x, "bpox.y", bpos.y)
	build:setStandPos(bpos) 
	local hpos=cc.p(bpos.x, bpos.y+bedSize.height/2)
	bed:setPosition(hpos)
	halo:setPosition(hpos)

	build:setOwner(owner)

	if build:isAttackBuild() then
		local attackHalo = cc.Sprite:create()
		attackHalo:setVisible(false)
		self:addChild(attackHalo, 2)
		build:setAttackHalo(attackHalo)
		attackHalo:setPosition(hpos)

		build:bindPropCallback(function(cfg, pos, target, attack, ratio) self:createFlyingProp(cfg, pos, target, attack, ratio) end)
		-- print("hposx-", hpos.x, "hposy-", hpos.y)
	end

	return build

end

function FightLayer:createBuildings(builds, size)
	local attackBuild = {}
	local buildList = {}
	for _, v in pairs(builds) do
		local cfg = buildings[v.buildID]
		
		local build = self:createBuild(cfg, v.type, v.pos, v.Num)

		local z = self:buildZOrder(build:reachPos())
		-- print("pos.y", pos.y, "z-", z)
		self:addChild(build, z)
		buildList[build.ident] = build
		
		-- self.fightList[ident] = build
		if build:isAttackBuild() then
			attackBuild[#attackBuild + 1] = build
		end
	end
	self.buildList = buildList
	self.attackBuild = attackBuild
end

function FightLayer:createGenerals(list)
	local gls = self.mapInfo.generals
	local generalList = {}

	local generalId = 0
	for _, v in pairs(gls) do
		generalId = 0
		if v.generalId == 0 then
			if #list > 0 then
				generalId = list[#list]
				list[#list] = nil
			end
		else
			generalId = v.generalID
		end

		if generalId ~= 0 then
			local gcfg = generals[generalId]

			local ident = self:currentFightId()
			local general = General:create(gcfg, v.type, ident)
			general:setAnchorPoint(cc.p(0.5, 0))
			general:setStandPos(v.pos)
			local drawNode = cc.DrawNode:create()
			self:addChild(drawNode)
			general:setDrawNode(drawNode);
			local z = self:buildZOrder(general:reachPos())
			self:addChild(general, z)
			-- self.fightList[ident] = general
			-- self.moveList[ident] = general
			-- moveList[#moveList + 1] = general
			generalList[ident] = general
			general.FSM:bindStateCallback(kRoleStateClear, function() 
				general:removeFromParent(true)
				generalList[ident] = nil
				end)
			general:bindPathCallback(function(path, node) self:checkPath(path, node) end)

		end
	end

	-- self.moveList = moveList
	self.generalList = generalList
end

function FightLayer:createFlyingProp(cfg, pos, target, attack, ratio)
	-- print("create fly prop")
	local prop = PropNode:create(cfg, target, attack, ratio)
	prop:setStandPos(pos)
	local z = self:buildZOrder(pos)
	self:addChild(prop, z)

	prop.FSM:bindStateCallback(kRoleStateClear, function()
			prop:removeFromParent(true)
		end)

	prop.FSM:setState(kRoleStateMove)

end

function FightLayer:findNearestBuild(owner, pos)
	local mindis = 0
	local build = nil
	-- local pos = node:centerPos()
	for _, v in pairs(self.buildList) do
		if v.owner == owner then
			local dis = cc.pGetDistance(v:reachPos(), pos)
			if build == nil or mindis > dis then
				mindis = dis
				build = v
			end

		end
	end
	
	return build
end

function FightLayer:findNearestTarget(owner, pos)
	local mindis = 0
	local target = nil
	for _, v in pairs(self.buildList) do
		if v.owner ~= owner then
			local dis = cc.pGetDistance(v:reachPos(), pos)
			if target == nil or mindis > dis then
				mindis = dis
				target = v
			end
		end
	end

	for _, v in pairs(self.generalList) do
		if v.owner ~= owner then
			local dis = cc.pGetDistance(v:reachPos(), pos)
			if mindis > dis then
				mindis = dis
				target = v
			end
		end
	end

	return target
end

function FightLayer:checkPath(path, node)
	local maxIdx = #path
	if maxIdx == 0 then
		return
	end

	local p = node:reachPos()
	local list = {}
	for _, v in pairs(self.attackBuild) do

		local vp = v:reachPos()
		local proxy = v.fightProxy
		local range = proxy:currentUseRange()
		local r2 = range * range
		local startOut = cc.pDistanceSQ(vp, p) > r2
		local moveDis = 0
		local ss = p

		for i = #path, 1, -1 do
			local point = path[i]
			local intersect = cc.pGetsegmentIntersectWithCircle(ss, point, vp, range)
			if intersect.x ~= 0 or intersect.y ~= 0 then
				local secDis = cc.pGetDistance(ss, intersect) + moveDis
				if startOut then
					list[#list+1] = {dis=secDis, callback=function() 
						v:targetInAttackScope(node)
					 end}
					startOut = false
				else
					list[#list+1] = {dis=secDis, callback=function()
						v:targetOutAttackScope(node)
					end}
					startOut = true
				end
			end
			moveDis = moveDis + cc.pGetDistance(ss, point)
			ss = point
		end
	end

	node.moveProxy:setMoveCallbackList(list)

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
	-- self:updateMoveList(self.propList, dt)
	-- for _, v in pairs(self.moveList) do
		
	-- 	local status, pos = v:updateMove(dt)
	-- 	if status == kFightStatusNotReach then
	-- 		local z = self:buildZOrder(pos)
	-- 		v:setLocalZOrder(z)
	-- 	end
	-- end

end

function FightLayer:updateAttackEvent(dt)
	-- print("attack event")
	-- for _, v in pairs(self.attackBuild) do
	-- 	v:updateAttack(dt)
	-- end

	-- local sdoneList = {}
	for i, v in pairs(self.soldierList) do
		v:updateAttack(dt)
		-- if v.workDone then
		-- 	sdoneList[#sdoneList + 1] = i
		-- end
	end

	-- local gdoneList = {}
	for i, v in pairs(self.generalList) do
		v:updateAttack(dt)
		-- if v.isDead then
		-- 	gdoneList[#gdoneList + 1] = i
		-- end
	end

	-- for i, v in pairs(self.propList) do
	-- 	v:updateAttack(dt)
	-- end

	-- for _, i in pairs(sdoneList) do
	-- 	local v = self.soldierList[i]

	-- 	if v.status == kSoldierStatusNextTarget then
	-- 		local target = self:findNearestBuild(v)
	-- 		v:setTarget(target)
	-- 	elseif v.status == kSoldierStatusGather then
	-- 		v:handleGather()
	-- 		v:removeFromParent(true)
	-- 		self.soldierList[i] = nil
	-- 	else
	-- 		v:removeFromParent(true)
	-- 		self.soldierList[i] = nil
	-- 	end
		
	-- end

	-- for _, i in pairs(gdoneList) do
	-- 	local v = self.generalList[i]
	-- 	v:removeFromParent(true)
	-- 	self.generalList[i] = nil
	-- end

end

function FightLayer:updateDamage()
	for i, v in pairs(self.buildList) do
		v:handleDamage()
	end

	for i, v in pairs(self.soldierList) do
		v:handleDamage()
	end

	for i, v in pairs(self.generalList) do
		v:handleDamage()
	end

end

function FightLayer:updateBuildStatus()
	for i, v in pairs(self.attackBuild) do
		-- v:updateStatus()
		if v.status == kBuildStatusAttack then

		end
	end
end

function FightLayer:updateSoldierStatus()
	local sdoneList = {}
	for i, v in pairs(self.soldierList) do
		-- v:updateStatus()

		if v.status == kSoldierStatusNextTarget then
			local target = self:findNearestBuild(v.owner, v:reachPos())
			v:setTarget(target)
			v:dispersal()
			print("dispersal")
		elseif v.status == kSoldierStatusGather then
			v:handleGather()
			-- v:removeFromParent(true)
			-- self.soldierList[i] = nil
			v:removeFromParent(true)
			sdoneList[#sdoneList + 1] = i
		elseif v.status == kSoldierStatusDead then
			sdoneList[#sdoneList + 1] = i
		end

	end

	for _, i in pairs(sdoneList) do
		self.soldierList[i] = nil
	end

end

function FightLayer:updateGeneralStatus()
	local gdoneList = {}
	for i, v in pairs(self.generalList) do
		-- v:updateStatus()
		if v.status == kGeneralStatusReset then
			v:resetGeneral()
		elseif v.status == kGeneralStatusDead then
			gdoneList[#gdoneList + 1] = i
		end

	end

	for _, i in pairs(gdoneList) do
		self.generalList[i] = nil
	end
end

function FightLayer:updatePropStatus()

	local pdoneList = {}
	for i, v in pairs(self.propList) do
		if v.status == kPropStatusDone then
			-- local effect = v:createEffect() 击中效果
			v:removeFromParent(true)
			pdoneList[#pdoneList + 1] = i
		end
	end

	for _, i in pairs(pdoneList) do
		self.propList[i] = nil
	end

end

function FightLayer:updateStatus()

	self:updateBuildStatus()

	self:updateSoldierStatus()

	self:updateGeneralStatus()	

	-- self:updatePropStatus()

end

function FightLayer:updateRoutePath()
	if not self.shouldDraw then
		return
	end

	-- for _, v in pairs(self.buildList) do
	-- 	v:drawRoutePath()
	-- end

	-- for _, v in pairs(self.generalList) do
	-- 	v:drawRoutePath()
	-- end

	-- for _, v in pairs(self.soldierList) do
	-- 	v:drawRoutePath()
	-- end

	local list = self.dispatchManager:currentDispatchList()
	local target = list.target
	for _, v in pairs(list.list) do
		if v ~= target then
			v:drawRoutePath()
		end
	end


end

function FightLayer:updateStateWithList(list, dt)

	for i, v in pairs(list) do

		v:updateState(dt)

	end

end

function FightLayer:updateState(dt)
	
	self:updateStateWithList(self.buildList, dt)
	self:updateStateWithList(self.generalList, dt)
	self:updateStateWithList(self.soldierList, dt)

end

function FightLayer:updateEvent(dt)
	
	-- self:updateState(dt)
	
	-- self:updateMoveEvent(dt)

	-- self:updateAttackEvent(dt)

	-- self:updateDamage()

	-- self:updateStatus()

	self:updateRoutePath()

end

function FightLayer:startFight()
	for _, v in pairs(self.buildList) do
		v:startUpdateSoldierNum()
	end
	-- sgzj.RouteData:getInstance():debugDraw(self.drawNode)
	local scheduler = self:getScheduler()
	scheduler:scheduleScriptFunc(function(dt) self:updateEvent(dt) end, 0, false)
end

function FightLayer:attackBuildListOnRoute(node)
	local list = {}
	for _, v in pairs(self.attackBuild) do
		
	end

	return list
end

function FightLayer:dispatchTroops(list)
	local target = list.target

	
	if target then
		target:unselect()
	end

	for _, v in pairs(list.list) do
		v:unselect()
		v:clearPath()
		if target and v ~= target then
			local ident = self:currentFightId()
			local soldier = v:createSoldier(target, ident)
			if soldier then
				soldier:dispersal()
				local pos = v:dispatchPos()
				soldier:setStandPos(pos)
				soldier:setAnchorPoint(cc.p(0.5, 0.5))
				local z = self:buildZOrder(pos)
				self:addChild(soldier, z)
				self.soldierList[ident] = soldier

				soldier.FSM:bindStateCallback(kRoleStateNoTarget, function() 
					local t = self:findNearestBuild(soldier.owner, soldier:reachPos())
					soldier:setTarget(t)
					soldier.FSM:setState(kRoleStateMove)
					soldier:setStartPoint(soldier:reachPos())
					soldier:findRoute(t:reachPos())
				 end)
				soldier.FSM:bindStateCallback(kRoleStateClear, function() 
					soldier:removeFromParent(true)
					self.soldierList[ident] = nil
					end)
				soldier:bindPathCallback(function(path, node) self:checkPath(path, node) end)

				soldier.FSM:setState(kRoleStateMove)
				soldier:setMovePath(v:currentPath())
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
		v:clearPath()
		-- print("posx-", pos.x, "posy-", pos.y)
		-- print("rx-", v:reachPos().x, "ry-", v:reachPos().y)
		-- local r = v:acceptRadius()
		-- if cc.pDistanceSQ(v:reachPos(), pos) > r * then
		if self.touchMoved then
			v:setTarget(target)
			local fsm = v.FSM
			fsm:setState(kRoleStateMove)
		end
		-- end
	end
end

function FightLayer:addInfluenceNode(owner, list, pos, range, influenceList, same)
	
	for _, v in pairs(list) do

		if (not same and v.owner ~= owner) or (same and v.owner == owner) then
			local reachPos = v:reachPos()
			-- local radius = v:acceptRadius()
			if cc.pGetDistance(pos, reachPos) < range then
				influenceList[#influenceList + 1] = v
			end
		end
	end

end

function FightLayer:handleAOE(owner, pos, range, damage, dtype)

	local influenceList = {}
	self:addInfluenceNode(owner, self.buildList, pos, range, influenceList, false)
	self:addInfluenceNode(owner, self.generalList, pos, range, influenceList, false)
	self:addInfluenceNode(owner, self.soldierList, pos, range, influenceList, false)

	for _, v in pairs(influenceList) do
		v:handleBeAttacked(damage, dtype)
	end

end

function FightLayer:handleAreaBuff(buff, pos, range, owner)
	-- self.fightLayer:handleAreaBuff(buff, pos, owner)
	local influenceList = {}
	-- self:addInfluenceNode(owner, self.buildList, pos, range, influenceList)
	local same = buff.effectType == 5
	self:addInfluenceNode(owner, self.generalList, pos, range, influenceList, same)
	self:addInfluenceNode(owner, self.soldierList, pos, range, influenceList, same)
	-- print("handle buff owner", owner)
	for _, v in pairs(influenceList) do
		-- print("count")
		v:handleBuff(buff)
	end

end

function FightLayer:handleSummon(summon, pos, owner)
	local ident = self:currentFightId()
	local scfg = soldiers[summon.soldierId]
	local target = self:findNearestTarget(owner, pos)
	if not target then
		target = self:findNearestBuild(owner, pos)
	end

	local soldier = Soldier:create(scfg, kOwnerPlayer, summon.num, target, ident)
	soldier:dispersal()

	soldier:setStandPos(pos)
	soldier:setAnchorPoint(cc.p(0.5, 0.5))
	local z = self:buildZOrder(pos)
	self:addChild(soldier, z)

				-- self.fightList[ident] = soldier
				-- self.moveList[ident] = general
	self.soldierList[ident] = soldier

	soldier.FSM:bindStateCallback(kRoleStateNoTarget, function() 
					local t = self:findNearestBuild(soldier.owner, soldier:reachPos())
					soldier:setTarget(t)
					soldier.FSM:setState(kRoleStateMove)
					soldier:setStartPoint(soldier:reachPos())
					soldier:findRoute(t:reachPos())
				 end)
	soldier.FSM:bindStateCallback(kRoleStateClear, function() 
					soldier:removeFromParent(true)
					self.soldierList[ident] = nil
					end)
	soldier:bindPathCallback(function(path, node) self:checkPath(path, node) end)

	-- soldier.FSM:setState(kRoleStateNoTarget)
	soldier.FSM:setState(kRoleStateMove)
	soldier:setStartPoint(pos)
	soldier:findRoute(target:reachPos())
	-- soldier:setMovePath(v:currentPath())

end

function FightLayer:handleAOEEffect(name, pos)
	if name == "" then
		return
	end

	local effect = RoleNode:create()
	effect.role:setPosition(cc.p(0, -136))

	effect:setPosition(pos)
	self:addChild(effect)

	effect:actOnceAction("effect/"..name..".plist", function() effect:removeFromParent(true) end, 0, kEffectAnimDelay)
	-- effect:playAnimate("effect/"..name..".plist", kEffectTag, false, kEffectAnimDelay)

end

function FightLayer:handleManualDamageList(list, pos)

	for _, i in pairs(list) do
		local v = damageSkills[i]
		local range = v.damageRange
		if range > 0 then
			self:handleAOEEffect(v.SkillEffect, pos)
			self:handleAOE(kOwnerPlayer, pos, range, v.value, v.damageType)
		end

	end

end

function FightLayer:handleManualBuffList(list, pos)
	for _, i in pairs(list) do
		local v = buffSkills[i]
		local range = v.damageRange
		if range > 0 then
			self:handleAreaBuff(v, pos, range, kOwnerPlayer)
		end
	end

end

function FightLayer:handleManualSummonList(list, pos)
	for _, i in pairs(list) do
		local v = summonSkills[i]
		self:handleSummon(v, pos, kOwnerPlayer)
	end
end

function FightLayer:handleManualSkill(skill, pos)

	local npos = self:convertToNodeSpace(pos)

	self:handleManualDamageList(skill.damageList, npos)
	self:handleManualBuffList(skill.buffList, npos)
	self:handleManualSummonList(skill.summonList, npos)

end

function FightLayer:handleDispatch(pos)

	local list = self.dispatchManager:currentDispatchList()

	if #list.list then
		if list.type == kBuildType then
			self:dispatchTroops(list)
		else
			self:dispatchGeneral(list, self:convertToNodeSpace(pos))
		end

		self.dispatchManager:dispatchDone()
	end

end

function FightLayer:addDispatchNode(pos, owner)

	local node = self:getItemForPos(pos, owner)

	if not node or node.selected then
		return false
	end

	if owner ~= -1 then
		if node.owner ~= owner then
			return false
		else
			self.dispatchManager:addDispatchList(node.type, owner)
		end
	end

	node:setStartPoint(node:reachPos())

	return true, node

end

function FightLayer:getItemForPos(pos, owner)
	local childs = self:getChildren()

	for _, v in pairs(childs) do

		if v.isTouchEnabled and v:isTouchEnabled() and v:isVisible() and (owner == -1 or v.owner == owner) then

			local p = v:convertToWorldSpace(cc.p(0, 0))
			local s = v:getRealContentSize()
			local box = cc.rect(p.x, p.y, s.width, s.height)

			if cc.rectContainsPoint(box, pos) then
				return v
			end
		end
	end

end

function FightLayer:updateFindPath(pos)
	local list = self.dispatchManager:currentDispatchList()
	if list.target then
		for _, v in pairs(list.list) do
			if list.target ~= v then
				v:findRoute(list.target:reachPos())
			end
		end
	else
		for _, v in pairs(list.list) do
			v:findRoute(self:convertToNodeSpace(pos))
		end
	end
end

function FightLayer:handleTouchBegan(event)
	local p = cc.p(event.x, event.y)
	local node = self:getItemForPos(p, kOwnerPlayer)
	if node then
		node.FSM:setState(kRoleStateStand)
		self.dispatchManager:addDispatchList(node.type, kOwnerPlayer)
		self.dispatchManager:addDispatchNode(node)
		self.shouldDraw = true
	end
	return node ~= nil
end

function FightLayer:handleTouchMoved(event)
	local p = cc.p(event.x, event.y)
	local node = self:getItemForPos(p, -1)

	if node then
		if node.selected then
			return
		end

		local list = self.dispatchManager:currentDispatchList()
		if node.owner == kOwnerPlayer and node.type == list.type then
			self.dispatchManager:addDispatchNode(node)
		end

		if node.owner ~= kOwnerPlayer or node.type == list.type then
			self.dispatchManager:setTarget(node)
		end

	else
		self.dispatchManager:setTarget(nil)
	end
	
	self.touchMoved = true

	self:updateFindPath(p)

end

function FightLayer:handleTouchEnded(event)

		local p = cc.p(event.x, event.y)
	-- self:updateFindPath(p)
		self:handleDispatch(p)

	self.shouldDraw = false
	-- self.drawNode:clear()
	self.touchMoved = false
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
	return math.floor(self.mapSize.height-pos.y+10)
end


function FightLayer:currentFightId()
	self.fightId = self.fightId + 1
	return self.fightId
end

return FightLayer