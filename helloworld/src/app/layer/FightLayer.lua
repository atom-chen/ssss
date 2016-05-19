

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


end

function FightLayer:createBuildings(builds, size)
	local attackBuild = {}
	local buildList = {}
	for _, v in pairs(builds) do
		local cfg = buildings[v.buildId]
		
		local bedImage = "fightbg/FB002_"..cfg.size..".png"
		local bed = cc.Sprite:create(bedImage)
		bed:setAnchorPoint(cc.p(0.5, 0.5))
		local bedPos = cc.p(v.pos.x, size.height - v.pos.y)
		-- print("posx", bedPos.x, "poxy", bedPos.y)
		bed:setPosition(bedPos)
		self:addChild(bed)

		local halo = cc.Sprite:create()
			halo:setPosition(bedPos)
			halo:setVisible(false)
			self:addChild(halo)
		
		local bedSize = bed:getContentSize()
		local ident = self:currentFightId()
		local build = Building:create(cfg, v.owner, bedSize, ident, halo)

		build:setSoldierNum(v.oriNum)
		build:setAnchorPoint(cc.p(0.5, 0))
		build:setStandPos(bedPos)
		local z = self:buildZOrder(build:centerPos())
		-- print("pos.y", pos.y, "z-", z)
		self:addChild(build, z)
		buildList[ident] = build
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
			generalId = v.generalId
		end

		if generalId ~= 0 then
			local gcfg = generals[generalId]

			local ident = self:currentFightId()
			local general = General:create(gcfg, v.owner, ident)
			general:setAnchorPoint(cc.p(0.5, 0))
			general:setStandPos(v.pos)
			local z = self:buildZOrder(general:centerPos())
			self:addChild(general, z)
			-- self.fightList[ident] = general
			-- self.moveList[ident] = general
			-- moveList[#moveList + 1] = general
			generalList[ident] = general
		end
	end

	-- self.moveList = moveList
	self.generalList = generalList
end

function FightLayer:findNearestBuild(owner, pos)
	local mindis = 0
	local build = nil
	-- local pos = node:centerPos()
	for _, v in pairs(self.buildList) do
		if v.owner == owner then
			local dis = cc.pGetDistance(v:centerPos(), pos)
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
			local dis = cc.pGetDistance(v:centerPos(), pos)
			if target == nil or mindis > dis then
				mindis = dis
				target = v
			end
		end
	end

	for _, v in pairs(self.generalList) do
		if v.owner ~= owner then
			local dis = cc.pGetDistance(v:centerPos(), pos)
			if mindis > dis then
				mindis = dis
				target = v
			end
		end
	end

	return target
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
			local target = self:findNearestBuild(v.owner, v:centerPos())
			v:setTarget(target)
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

function FightLayer:updateEvent(dt)
	-- print("update event", dt)

	-- self:updateBuildAttack(dt)
	-- self.fightTime = self.fightTime + dt
	
	self:updateMoveEvent(dt)

	self:updateAttackEvent(dt)

	self:updateDamage()

	self:updateStatus()

end

function FightLayer:startFight()
	for _, v in pairs(self.buildList) do
		v:startUpdateSoldierNum()
	end

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
	local target = list:getTroopsTarget()

	target:unselect()

	local dispatch = true
	if list.owner == target.owner and list.type ~= target.type then
		dispatch = false
	end

	for _, v in pairs(list.list) do
		v:unselect()
		if dispatch then
			local ident = self:currentFightId()
			local soldier = v:createSoldier(target, ident)
			if soldier then
				local pos = v:dispatchPos()
				soldier:setStandPos(pos)
				soldier:setAnchorPoint(cc.p(0.5, 0.5))
				local z = self:buildZOrder(pos)
				self:addChild(soldier, z)

				

				-- self.fightList[ident] = soldier
				-- self.moveList[ident] = general
				self.soldierList[ident] = soldier
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

function FightLayer:addInfluenceNode(owner, list, pos, range, influenceList, same)
	
	for _, v in pairs(list) do

		if (not same and v.owner ~= owner) or (same and v.owner == owner) then
			local reachPos = v:centerPos()
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

	soldier:setStandPos(pos)
	soldier:setAnchorPoint(cc.p(0.5, 0.5))
	local z = self:buildZOrder(pos)
	self:addChild(soldier, z)

				-- self.fightList[ident] = soldier
				-- self.moveList[ident] = general
	self.soldierList[ident] = soldier

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
		if list.type == 1 then
			self:dispatchTroops(list)
		else
			self:dispatchGeneral(list, pos)
		end

		self.dispatchManager:dispatchDone()
	end

end

function FightLayer:addDispatchNode(pos, owner)
	local node = self:getItemForPos(pos)

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

	self.dispatchManager:addDispatchNode(node)

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
	return self:addDispatchNode(cc.p(event.x, event.y), kOwnerPlayer)
end


function FightLayer:handleTouchMoved(event)
	self:addDispatchNode(cc.p(event.x, event.y), -1)
	
end

function FightLayer:handleTouchEnded(event)
	self:handleDispatch(cc.p(event.x, event.y))
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


function FightLayer:currentFightId()
	self.fightId = self.fightId + 1
	return self.fightId
end

return FightLayer