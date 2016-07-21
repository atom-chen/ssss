

local FightScene = class("FightScene", cc.Scene)
cc.exports.FightScene = FightScene

function FightScene:ctor(mapId)
	self:enableNodeEvents()
	self.touchDistance = -1
	self.points = {}

	self.sceneType = kFightScene

	local layer = cc.Layer:create()

	layer:onTouch(function(event) self:touchesEvent(event) end, true, true)

	layer:setAnchorPoint(cc.p(0, 0))
	layer:setPosition(cc.p(0, 0))
	self:addChild(layer, -1)

	-- local mapInfo = maps[mapId]
	-- local mapInfo=_G["mapConfig"..mapId]
	local mapInfo = MapData:loadMap(mapId)

	if not mapInfo then
		print("map not found! id:", mapId)
	end

	local image = self:backgroundImage(mapInfo)
	-- print("fightbg image--", image)
	self.bg = cc.Sprite:create(image)
	self.bg:setScale(0.5)
	self.bg:setPosition(display.center)
	self:addChild(self.bg)

	local path = self:movePath(mapId)
	sgzj.RouteData:getInstance():loadRouteData(path)

	self:createFightLayer(mapInfo, self.bg:getContentSize())

	local skillLayer = SkillLayer:create()
	skillLayer:setAnchorPoint(cc.p(0, 0))
	skillLayer:setPosition(cc.p(0, 0))
	self:addChild(skillLayer)

	skillLayer:createSkills({22,23,24,25,26})
	skillLayer:setFightSceneScale(0.5)
	self.skillLayer = skillLayer

	-- skillLayer:startUpdate()
	self.enemy1 = SimpleAI:create(self.fightLayer, 2)

	local configLayer = ConfigLayer:create(mapId)
	self:addChild(configLayer)

	-- self.fightLayer:setConfigLayer(configLayer)
	self.configLayer = configLayer


end

function FightScene:onExit()
	self:stopFight()
end

function FightScene:onEnterTransitionFinish()
	self:startFight()
end

function FightScene:movePath(mapId)
	return "configs/map/move/"..mapId..".xml"
end

function FightScene:backgroundImage(mapInfo)
	return "fightbg/"..mapInfo.mapPic..".png"
end

function FightScene:createFightLayer(mapInfo, size)

	local layer = SituationLayer:create(kOwnerPlayer, kOwnerRed)

	self:addChild(layer)
	-- local sz = layer.label:getContentSize()

	-- local p = layer.label:convertToWorldSpace(cc.p(sz.width, 0))
	-- local p1 = layer.label:convertToWorldSpace(cc.p(sz.width, sz.height))

	local fightLayer = FightLayer:create(mapInfo, size, layer)

	fightLayer:setAnchorPoint(cc.p(0, 0))
	fightLayer:setPosition(cc.p(0, 0))
	self.bg:addChild(fightLayer)
	self.fightLayer = fightLayer

	fightLayer:createGenerals({1,2,3})
	-- layer:debugShow()
	

end

function FightScene:setBackGroundPos(ep)
	local size = self.bg:getRealContentSize()
	ep.x = math.max(math.min(size.width/2, ep.x), display.width-size.width/2)
	ep.y = math.max(math.min(size.height/2, ep.y), display.height-size.height/2)
	self.bg:setPosition(ep)
end

function FightScene:stopFight()
	self.fightLayer:stopFight()
	self.skillLayer:stopFight()
	self.enemy1:stopDecision()
end

function FightScene:startFight()
	self.fightLayer:startFight()
	self.skillLayer:startFight()
	self.enemy1:startFight()


end

function FightScene:moveBackGround(point)
	-- if not point then
	-- 	print("no point")
	-- 	return
	-- end
	
	local p2 = cc.p(self.points[0].x, self.points[0].y)
	local px, py = self.bg:getPosition()
	local p = cc.p(px, py)
	-- print("px-", p.x, "py-", p.y)
	-- print("pointx-", point.x, "pointy-", point.y)
	-- print("p2x-", p2.x, "p2y-", p2.y)
	local ep = cc.pAdd(p, cc.pSub(point, p2))

	self:setBackGroundPos(ep)

end

function FightScene:handleAOE(owner, pos, damage, skill)
	self.fightLayer:handleAOE(owner, pos, damage, skill)
end

function FightScene:handleAreaBuff(buff, pos, range, owner)
	self.fightLayer:handleAreaBuff(buff, pos, range, owner)
end

function FightScene:handleManualSkill(skill, pos)
	self.fightLayer:handleManualSkill(skill, pos)
end

function FightScene:handleTouchesBegan(points)
	-- local flag = 1
	-- for i, v in pairs(points) do
	-- 	-- self.points[i] = v
	-- 	print("begin px-", v.x, "py-", v.y, "flag-", flag, "i-", i)
	-- 	flag = flag + 1
	-- end
	-- self.points[0] = points[0]
	-- self.points[1] = points[1]
	if points[0] then
		self.points[0] = points[0]
	end

	if points[1] then
		self.points[1] = points[1]
	end

	-- if self.touchDistance < 0 and self.points[0] and self.points[1] then
	-- 	self.touchDistance = cc.pDistanceSQ(self.points[0], self.points[1])
	-- 	self.baseScale = self.bg:getScale()
	-- end

end

function FightScene:handleTouchesMoved(points)
	-- print("moved -", points[0], points[1])
	-- print("p1-", self.points[1], "dis-", self.touchDistance)
	if self.points[0] and self.points[1] then
		if points[0] then
			self.points[0] = points[0]
		end

		if points[1] then
			self.points[1] = points[1]
		end

		local distance = cc.pDistanceSQ(self.points[0], self.points[1])
		if self.touchDistance < 0 then
			self.touchDistance = distance
			self.baseScale = self.bg:getScale()
			return
		end
		-- print("p0x-", p0.x, "p0y-", p0.y)
		-- print("p1x-", p1.x, "p1y-", p1.y)

		local scale = self.baseScale * math.sqrt(distance / self.touchDistance)
		-- print("scale -", scale)

		scale =  math.max(math.min(1, scale), 0.5)

		self.touchDistance = distance
		self.baseScale = scale
		-- print( "scale - ", scale)
		self.bg:setScale(scale)
		self.skillLayer:setFightSceneScale(scale)
		local px, py = self.bg:getPosition()
		self:setBackGroundPos(cc.p(px, py))

	else
		local delta = nil
		if points[0] then
			delta = cc.pSub(points[0], self.points[0])
			self.points[0] = points[0]
		elseif points[1] then
			delta = cc.pSub(points[1], self.points[1])
			self.points[1] = points[1]
		else
			return
		end
		-- print("deltax-", delta.x, "deltay-", delta.y)
		local px, py = self.bg:getPosition()
		self:setBackGroundPos(cc.pAdd(cc.p(px, py), delta))
		-- self:moveBackGround(points[0] or points[1])
	end

	-- for i, v in pairs(points) do
		-- self.points[i] = v
		-- print("moved px-", v.x, "py-", v.y)
	-- end

end

function FightScene:handleTouchesEnded(points)
	-- for i, v in pairs(points) do
		-- self.points[i] = nil
		-- print("end px-", v.x, "py-", v.y, "i-", i)
	-- end
	if points[0] then
		self.points[0] = nil
	end
	if points[1] then
		self.points[1] = nil
	end

	if self.points[0] == nil or self.points[1] == nil then
		self.touchDistance = -1
	end
end

function FightScene:touchesEvent(event)
	if event.name == "began" then
		self:handleTouchesBegan(event.points)
	elseif event.name == "moved" then
		self:handleTouchesMoved(event.points)
	else
		self:handleTouchesEnded(event.points)
	end
end

return FightScene



