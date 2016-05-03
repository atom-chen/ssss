

local Soldier = class("Soldier", cc.Node)

local kFightStatusReach = 1
local kFightStatusNotReach = 0
local kFightStatusNoTarget = -1

function Soldier:ctor(cfg, owner, num, target)
	self.cfg = cfg
	self.owner = owner
	self.roles = {}
	self.type = 3
	self.workDone = false
	print("target --", target)
	self:createFightNode(target)

	self:setSoldierNum(num)
	
end

function Soldier:createFightNode(target)
	local cls = require("app.fight.FightNode")
	if cls then
		local fightNode = cls:create()
		fightNode:setTarget(target)
		fightNode:parseSoldierCfg(self.cfg)
		self.fightNode = fightNode
	else
		print("load app.fight.RoleNode failed")
	end
end

function Soldier:setStandPos(pos)
	self:setPosition(pos)
	self.fightNode:setStandPos(pos)
end

function Soldier:setSoldierNum(num)
	self.soldierNum = num
	local rn = self:roleNum(num)
	local cur = #self.roles
	-- print("num---", num, "rn--", rn, "cur--", cur)
	if rn > cur then
		self:addSoldier(rn-cur)
	elseif rn < cur then
		self:deleteSoldier(cur-rn)
	end

	if not self.topLbl then
		self:createTopLbl()
	end

	self.topLbl:setSoldierNum(num)

end

function Soldier:roleNum(num)
	return math.min(math.floor(math.log(math.pow(2, num) - 1 ) + 1), 8)
end

function Soldier:createTopLbl()
	local cls = require("app.fight.SoldierTopLbl")
	if cls then
		local topLbl = cls:create(self.cfg.typeId)
		topLbl:setAnchorPoint(cc.p(0.5, 0.5))
		topLbl:setPosition(self:topCenter())
		self:addChild(topLbl)
		self.topLbl = topLbl
		
	else
		print("load app.fight.SoldierTopLbl failed")
	end
end

function Soldier:createRoleNode(name)
	local cls = require("app.fight.RoleNode")
	if cls then
		return cls:create(name)
	else
		print("load app.fight.RoleNode failed")
	end
end

function Soldier:addSoldier(num)
	-- print("add---", num)
	local base = self:roleBaseName()
	local size = nil
	local rowH = 0
	local colW = 0
	local flag = #self.roles
	-- print("flag---", flag)
	for i=1, num do
		local role = self:createRoleNode(base)
		local count = #self.roles
		local row = count / 4
		local col = count % 4

		if not size then
			size = role:getContentSize()
			rowH = size.height/2
			colW = size.width * 0.7
			-- print("rowH--", rowH, "colW--", colW)
		end
		
		role:setAnchorPoint(cc.p(0, 0))
		role:setPosition(cc.p(colW * col, rowH * (2 - row)))
		-- print("rolex--", colW*col, "rolwy--", rowH*(2-row))
		self:addChild(role)
		self.roles[count+1] = role
	end

	if flag == 0 then
		-- print("setcoententsize--w--", colW * 3+size.width, "h--", rowH * 2 + size.height)
		self:setContentSize(cc.size(colW * 3 + size.width, rowH * 2 + size.height))
	end

	-- local role = SRole:create(base)
	-- role:setAnchorPoint(cc.p(0, 0))
	-- role:setPosition(0,0)
	-- self:addChild(role)
	-- self.roles[#self.roles] = role

	-- self:setContentSize(role:getContentSize())
	
end

function Soldier:deleteSoldier(num)
	-- print("delete---", num)
	local count = num
	while count > 0 do
		local role = self.roles[#self.roles]
		role:removeFromParent(true)
		self.roles[#self.roles] = nil
		count = count - 1
	end

end

function Soldier:roleBaseName()
	return "action/"..self.cfg.icon.."_"..self.owner
end

function Soldier:updateFace(face)
	if self.face == face then
		return 
	end

	self.face = face
	for _, v in pairs(self.roles) do
		v:face(face)
	end
end

function Soldier:updateMove(dt)
	local status, last, face = self.fightNode:checkMove(dt)
	if status == kFightStatusNotReach then
		self:updateFace(face)
		self:actMove()
		self:setPosition(last)
	end

	return status, last
end

function Soldier:updateAttack(dt)
	local status, rate, face = self.fightNode:checkAttack(dt)

	if status == kFightStatusReach then
		if self.fightNode:isTargetGeneral() then
			self:updateFace(face)
			self:actAttack(
				function()  
					self:handleFight()
					self:actStand()
				end, rate)
			
		else
			self.workDone = true
		end
	end

	return status, rate
end

function Soldier:handleFight()
	self.fightNode:handleFight(self)
end

function Soldier:updateBeAttacked(target, att)

end

function Soldier:checkReatchTarget(pos)
	local reachPos = self.target:reachPos()
	-- print("check, px--", px, "py--", py)
	if cc.pGetDistance(pos, cc.p(px, py)) < 50 then
		return true
	end

	return false
end

function Soldier:actStand()
	for _, v in pairs(self.roles) do
		v:actStand()
	end
end

function Soldier:actMove()
	for _, v in pairs(self.roles) do
		v:actMove()
	end
end


return Soldier


