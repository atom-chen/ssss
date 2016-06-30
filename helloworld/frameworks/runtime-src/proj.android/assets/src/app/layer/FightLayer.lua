

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

	self:createEventListener()

end

function FightLayer:getFightNode(fightId)
	return self.buildList[fightId] or self.soldierList[fightId] or self.generalList[fightId]
end

function FightLayer:createEventListener()
	local listener = cc.EventListenerCustom:create(cc.ANIMATION_FRAME_DISPLAYED_NOTIFICATION, function(event, target, userInfo)
		local parent = target:getParent():getParent():getParent()
		-- print("parentId-", parent.ident)
		-- print("fightId-", userInfo.fightId)
		local handler = self:getFightNode(userInfo.fightId)
		handler:handleAnimationFrameDisplayed(target, userInfo)
	 end)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
	
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
	build:bindOwnerCallback(function(from, to) 
		self:updateBuildDispatch(build)
		self:updateBuildLayout(from, to) 
		end)
	
	if build:isAttackBuild() then
		local attackHalo = cc.Sprite:create()
		attackHalo:setVisible(false)
		self:addChild(attackHalo, 2)
		build:setAttackHalo(attackHalo)
		attackHalo:setPosition(hpos)

		build:bindPropCallback(function(cfg, pos, target, attack, ratio, tp, dir) 
			self:createFlyingProp(cfg, pos, target, attack, ratio, tp, dir) 
			end)
		-- print("hposx-", hpos.x, "hposy-", hpos.y)
	end

	return build

end

function FightLayer:createBuildings(builds, size)
	local attackBuild = {}
	local buildList = {}
	local c1=0
	local c2=0
	local c3=0
	for _, v in pairs(builds) do
		local cfg = {}
		for key, value in pairs(buildings[v.buildID]) do
			cfg[key] = value
		end

		cfg.soldierId = v.soldierID
		if v.type == kOwnerNone then
			c1 = c1+1
		elseif v.type == kOwnerPlayer then
			c2 = c2+1
		else
			c3 = c3+1
		end
		
		local build = self:createBuild(cfg, v.type, v.pos, v.Num)
		-- build:acceptSite(cc.p(100, 100, 100))

		local z = self:buildZOrder(build:reachPos())
		-- print("posx", v.pos.x, "posy", v.pos.y, "buildz-", z)
		self:addChild(build, z)
		buildList[build.ident] = build
		
		-- self.fightList[ident] = build
		if build:isAttackBuild() then
			attackBuild[#attackBuild + 1] = build
		end
	end

	self.buildList = buildList
	self.attackBuild = attackBuild
	self.buildNone = c1
	self.buildPlayer = c2
	self.buildEnemy = c3

end

function FightLayer:createGenerals(list)
	local gls = self.mapInfo.generals
	local generalList = {}

	local generalId = 0
	local c1 = 0
	local c2 = 0
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
			-- print("general ident-", ident, "gid-", generalId)
			if v.type == kOwnerPlayer then
				c1 = c1 + 1
			else
				c2 = c2 + 1
			end

			local general = General:create(gcfg, v.type, ident)
			general:setAnchorPoint(cc.p(0.5, 0))
			
			local drawNode = cc.DrawNode:create()
			self:addChild(drawNode)
			general:setDrawNode(drawNode);
			-- local z = self:buildZOrder(general:reachPos())
			self:addChild(general)
			general:setStandPos(v.pos)
			-- self.fightList[ident] = general
			-- self.moveList[ident] = general
			-- moveList[#moveList + 1] = general
			generalList[ident] = general
			general.FSM:bindStateCallback(kRoleStateClear, function() 
				if general.owner == kOwnerPlayer then
					self.generalPlayer = self.generalPlayer - 1
				else
					self.generalEnemy = self.generalEnemy - 1
				end

				self:updateGeneralDispatch(general)
				drawNode:removeFromParent(true)
				general:removeFromParent(true)
				generalList[ident] = nil
				
				self:checkFightEnd()
				end)
			general:bindPathCallback(function(path, node) self:checkPath(path, node) end)

			self:checkNode(general, v.pos)

		end
	end

	-- self.moveList = moveList
	self.generalList = generalList
	self.generalPlayer = c1
	self.generalEnemy = c2
end

function FightLayer:createFlyingProp(cfg, pos, target, attack, ratio, tp, dir)
	-- print("create fly prop")
	local prop = PropNode:create(cfg, target, attack, ratio, tp, dir or cc.p(0,0))
	prop:setStandPos(pos)
	-- local z = self:buildZOrder(pos)
	self:addChild(prop, 3000)
	-- if not self.prop1 then
	-- self.prop1 = PropNode:create(cfg, target, attack, ratio, tp, dir or cc.p(0,0))
	-- self.prop1:setStandPos(pos)
	-- self:addChild(self.prop1, 1024)
	-- end

	prop.FSM:bindStateCallback(kRoleStateClear, function()
			prop:removeFromParent(true)
		end)

	prop.FSM:setState(kRoleStateMove)

end

function FightLayer:checkFightEnd()
	-- print("buildPlayer-", self.buildPlayer, "generalPlayer-", self.generalPlayer)
	-- print("buildenemy-", self.buildEnemy, "generalEnemy-", self.generalEnemy)
	if self.buildPlayer == 0 and self.generalPlayer == 0 then
		-- self.configLayer:fightEnd(true)
		local scene = cc.Director:getInstance():getRunningScene()
		if scene.sceneType == kFightScene then
			scene:stopFight()
			scene.configLayer:showNext(false)
		end

		return
	end

	if self.buildEnemy == 0 and self.generalEnemy == 0 then
		-- self.configLayer:fightEnd(false)
		local scene = cc.Director:getInstance():getRunningScene()
		if scene.sceneType == kFightScene then
			scene:stopFight()
			scene.configLayer:showNext(true)
		end
	end
end

function FightLayer:allAliveFightNodes(owner, ftype)
	local builds = {}

	local list = {}
	if ftype == kBuildType then
		list = self.buildList
	elseif ftype == kGeneralType then
		list = self.generalList
	end

	for _, v in pairs(list) do
		if v.owner == owner and not v:isDead() then
			builds[#builds + 1] = v
		end
	end

	return builds
end

function FightLayer:allAttackBuilds(owner)
	local builds = {}

	for _, v in pairs(self.attackBuild) do
		if v.owner == owner then
			builds[#builds + 1] = v
		end
	end

	return builds
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

function FightLayer:findNearestTarget(owner, pos, alive)
	local mindis = 0
	local target = nil
	for _, v in pairs(self.buildList) do
		if v.owner ~= owner then
			local dis = cc.pGetDistance(v:reachPos(), pos)
			if target == nil or mindis > dis then
				if (alive and not v:isDead()) or not alive then
					mindis = dis
					target = v
				end
			end
		end
	end

	for _, v in pairs(self.generalList) do
		if v.owner ~= owner then
			local dis = cc.pGetDistance(v:reachPos(), pos)
			if target == nil or mindis > dis then
				if (alive and not v:isDead()) or not alive then
					mindis = dis
					target = v
				end
			end
		end
	end

	return target
end

function FightLayer:checkNode(node, pos)

	for _, v in pairs(self.attackBuild) do
		local vp = v:reachPos()
		local proxy = v.fightProxy
		local range = proxy:currentUseRange()
		local r2 = range * range

		if cc.pDistanceSQ(vp, pos) < r2 then
			v:targetInAttackScope(node)
		end

	end

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
			-- print(ss, ",", point, ",", vp)
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

function FightLayer:updateBuildDispatch(build)
	-- print("updateBuildDispatch")
	local list = self.dispatchManager:currentDispatchList()
	if not list then
		-- print("no list")
		return
	end

	if list.target and list.target == build then
		build:showAttackHalo(build.owner ~= kOwnerNone)
		build:showTargetHalo(build.owner ~= kOwnerPlayer)
		build:showHalo(build.owner == kOwnerPlayer)
		if build.owner == kOwnerPlayer then
			list:addNode(build)
			-- list.list[build.ident] = build
		end
	end
	-- print("type", list.type)
	if list.type == kBuildType and build.owner ~= kOwnerPlayer then
		-- print("unselect")
		build:clearPath()
		build:unselect()
		list.list[build.ident] = nil

		local none = true
		for _, v in pairs(list.list) do
			none = false
			break
		end

		if none then
			list:setTarget(nil)
			self.dispatchManager:dispatchDone()
		end
	end

end

function FightLayer:updateGeneralDispatch(general)
	local list = self.dispatchManager:currentDispatchList()
	if not list then
		return
	end

	if list.target and list.target == general then
		list.target = nil
		return
	end

	list.list[general.ident] = nil
	-- for i, v in pairs(list.list) do
	-- 	if v == general then
	-- 		list.list[i] = nil
	-- 		break
	-- 	end
	-- end

end

function FightLayer:updateBuildLayout(from, to)
	if from == kOwnerNone then
		self.buildNone = self.buildNone - 1
	elseif from == kOwnerPlayer then
		self.buildPlayer = self.buildPlayer - 1
	else
		self.buildEnemy = self.buildEnemy - 1
	end

	if to == kOwnerNone then
		self.buildNone = self.buildNone + 1
	elseif to == kOwnerPlayer then
		self.buildPlayer = self.buildPlayer + 1
	else
		self.buildEnemy = self.buildEnemy + 1
	end

	self:checkFightEnd()

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
			-- print("dispersal")
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

function FightLayer:stopFight()
	if self.eventEntry then
		local scheduler = self:getScheduler()
		scheduler:unscheduleScriptEntry(self.eventEntry)
		self.eventEntry = nil
	end

	for _, v in pairs(self.buildList) do
		v:stopUpdateSoldierNum()
	end
end

function FightLayer:startFight()
	for _, v in pairs(self.buildList) do
		v:startUpdateSoldierNum()
	end
	-- sgzj.RouteData:getInstance():debugDraw(self.drawNode)
	if not self.eventEntry then
		local scheduler = self:getScheduler()
		self.eventEntry = scheduler:scheduleScriptFunc(function(dt) self:updateEvent(dt) end, 0, false)
	end
end

function FightLayer:attackBuildListOnRoute(node)
	local list = {}
	for _, v in pairs(self.attackBuild) do
		
	end

	return list
end

function FightLayer:dispatchBuild(v, target, hasGot)
	if target and v ~= target then
		local ident = self:currentFightId()
		local soldier = v:createSoldier(target, ident)
		-- print("soldier ident-", ident, "cfgId-", v.cfg.soldierId)
		if soldier then
			soldier:dispersal()
			local pos = v:dispatchPos()
			
			soldier:setAnchorPoint(cc.p(0.5, 0.5))
			-- local z = self:buildZOrder(pos)
			self:addChild(soldier)
			soldier:setStandPos(pos)

			self.soldierList[ident] = soldier

			soldier.FSM:bindStateCallback(kRoleStateNoTarget, function() 
				-- print("state no target")
				local t = self:findNearestBuild(soldier.owner, soldier:reachPos())
				-- print("build-", t)
				soldier:setTarget(t)
				soldier.FSM:setState(kRoleStateMove)
				soldier:setStartPoint(soldier:reachPos())
				soldier:findRoute(t:reachPos())
			 end)
			soldier.FSM:bindStateCallback(kRoleStateClear, function() 
				-- print("remove soldier-", ident)
				soldier:removeFromParent(true)
				self.soldierList[ident] = nil
				end)
			soldier:bindPathCallback(function(path, node) self:checkPath(path, node) end)
			self:checkNode(soldier, pos)
			soldier.FSM:setState(kRoleStateMove)
			if hasGot then
				local path = v:currentPath()
				-- print("set path")
				soldier:setMovePath(path)
			else
				-- print("set px-", pos.x, "set py-", pos.y)
				soldier:setStartPoint(pos)
				soldier:findRoute(target:reachPos())
			end

		end
	end
end

function FightLayer:dispatchTroops(list)
	local target = list.target
	-- print("dispatch troops-", target)
	
	if target then
		-- print("target unselect")
		target:unselect()
	end

	for _, v in pairs(list.list) do
		v:unselect()
		v:clearPath()
		self:dispatchBuild(v, target, true)
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

function FightLayer:handleAOE(owner, pos, damage, skill)
	self:handleAOEEffect(skill.SkillEffect, pos)
	local range = skill.damageRange
	local dtype = skill.damageType
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
	if not sgzj.RoleNode:isPointCanReach(pos) then
		return
	end

	local ident = self:currentFightId()
	local scfg = soldiers[summon.soldierId]
	local target = self:findNearestTarget(owner, pos)
	if not target then
		target = self:findNearestBuild(owner, pos)
	end

	local soldier = Soldier:create(scfg, kOwnerPlayer, summon.num, target, ident)
	soldier:dispersal()

	
	soldier:setAnchorPoint(cc.p(0.5, 0.5))
	-- local z = self:buildZOrder(pos)
	self:addChild(soldier)
	soldier:setStandPos(pos)

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
					-- print("remove soldier-", ident)
					soldier:removeFromParent(true)
					self.soldierList[ident] = nil
					end)
	soldier:bindPathCallback(function(path, node) self:checkPath(path, node) end)

	-- soldier.FSM:setState(kRoleStateNoTarget)
	self:checkNode(soldier, pos)
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
	local cpos = effectCPos[name]
	effect.role:setPosition(cpos)

	effect:setPosition(pos)
	self:addChild(effect)
	-- print("aoeeffect", name)
	effect:actOnceAction("effect/"..name..".plist", function() effect:removeFromParent(true) end, kEffectAnimDelay)
	-- effect:playAnimate("effect/"..name..".plist", kEffectTag, false, kEffectAnimDelay)

end

function FightLayer:handleManualDamageList(list, pos)

	for _, i in pairs(list) do
		local v = damageSkills[i]
		local range = v.damageRange
		if range > 0 then
			
			self:handleAOE(kOwnerPlayer, pos, v.value, v)
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

		-- if node.owner ~= kOwnerPlayer or node.type == list.type then
			self.dispatchManager:setTarget(node)
		-- end

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
	-- print("current fightId-", self.fightId)
	return self.fightId
end

return FightLayer