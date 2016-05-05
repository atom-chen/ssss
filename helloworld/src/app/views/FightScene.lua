

local FightScene = class("FightScene", cc.Scene)

local maps = cc.exports.maps
local kFightScene = 1

function FightScene:ctor(mapId)
	self.touchDistance = -1
	self.points = {}

	self.sceneType = kFightScene

	local layer = cc.Layer:create()

	layer:onTouch(function(event) self:touchesEvent(event) end, true, true)

	layer:setAnchorPoint(cc.p(0, 0))
	layer:setPosition(cc.p(0, 0))
	self:addChild(layer, -1)

	local mapInfo = maps[mapId]

	if not mapInfo then
		print("map not found! id:", mapId)
	end

	local image = self:backgroundImage(mapInfo)
	print("fightbg image--", image)
	self.bg = cc.Sprite:create(image)
	self.bg:setScale(0.5)
	self.bg:setPosition(display.center)
	self:addChild(self.bg)

	local fightLayer = self:createFightLayer(mapInfo, self.bg:getContentSize())

	fightLayer:setAnchorPoint(cc.p(0, 0))
	fightLayer:setPosition(cc.p(0, 0))
	self.bg:addChild(fightLayer)
	self.fightLayer = fightLayer

	fightLayer:createGenerals({1,2,3})

end

function FightScene:backgroundImage(mapInfo)
	return "fightbg/"..mapInfo.mapPic..".png"
end

function FightScene:createFightLayer(mapInfo, size)
	local cls = require("app.fight.FightLayer")
	if cls then
		return cls:create(mapInfo, size)
	else
		print("load app.fight.FightLayer failed")
	end
end

function FightScene:setBackGroundPos(ep)
	local size = self.bg:getRealContentSize()
	ep.x = math.max(math.min(size.width/2, ep.x), display.width-size.width/2)
	ep.y = math.max(math.min(size.height/2, ep.y), display.height-size.height/2)

	self.bg:setPosition(ep)
end

function FightScene:startFight()
	self.fightLayer:startFight()

end

function FightScene:handleAOE(node, pos, range, damage, dtype)
	self.fightLayer:handleAOE(node, pos, range, damage, dtype)
end

function FightScene:moveBackGround(point)
	
	local p2 = cc.p(self.points[0].x, self.points[0].y)
	local px, py = self.bg:getPosition()
	local p = cc.p(px, py)
	local ep = cc.pAdd(p, cc.pSub(point, p2))

	self:setBackGroundPos(ep)

end

function FightScene:handleTouchesBegan(points)
	
	for i, v in pairs(points) do
		self.points[i] = v
	end

	if self.points[0] and self.points[1] and self.touchDistance == -1 then
		self.touchDistance = cc.pGetDistance(self.points[0], self.points[1])
	end
end

function FightScene:handleTouchesMoved(points)

	if self.points[0] and self.points[1] then
		local p0 = self.points[0]
		local p1 = self.points[1]

		if points[0] then
			p0 = points[0]
		end
		if points[1] then
			p1 = points[1]
		end

		local distance = cc.pGetDistance(p0, p1)
		local delta = distance - self.touchDistance

		local scale = 1

		scale =  math.max(math.min(1, self.bg:getScale() + delta/4096.0*0.5), 0.5)

		self.bg:setScale(scale)
		local px, py = self.bg:getPosition()
		self:setBackGroundPos(cc.p(px, py))

	elseif self.points[0] then
		self:moveBackGround(points[0])

	end

	for i, v in pairs(points) do
		self.points[i] = v
	end

end

function FightScene:handleTouchesEnded(points)
	for i, v in pairs(points) do
		self.points[i] = nil
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



