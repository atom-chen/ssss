

local Soldier = class("Soldier", cc.Node)

local kFightStatusReach = 1
local kFightStatusNotReach = 0
local kFightStatusNoTarget = -1

local kSoldierType = 3
local kGeneralType = 2

function Soldier:ctor(cfg, owner, num, target)
	self.cfg = cfg
	self.owner = owner
	self.roles = {}
	self.type = 3
	self.workDone = false
	self.acceptR = 1
	self.count = 0

	self:createFightNode(target)

	self:setSoldierNum(num)
	self:createLabelEffect()
	
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
	num = math.max(num, 0)
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

	local lblNum = self.fightNode:displayNumber(num)
	self.topLbl:setSoldierNum(lblNum)

end

function Soldier:setTarget(target)
	if target then
		self.workDone = false
		self.fightNode:setTarget(target)
	end
end


function Soldier:roleNum(num)
	if num <= 0 then
		return 0
	elseif num <= 1 then
		return 1
	else
		return math.min(math.floor(math.log(num - 1)/math.log(2)) + 1, 8)
	end
end

function Soldier:createLabelEffect()
	local cls = require("app.fight.LabelEffect")
	if cls then
		local effect = cls:create()
		effect:setAnchorPoint(cc.p(0.5, 0))
		effect:setPosition(self.topLbl:topCenter())
		self.topLbl:addChild(effect)
		self.labelEffect = effect
	else
		print("load app.fight.Soldier failed")
	end
end

function Soldier:createTopLbl()
	local cls = require("app.fight.SoldierTopLbl")
	if cls then
		local topLbl = cls:create(self.cfg.typeId, self.owner)
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

	self.count = self.count + num
	if flag == 0 then
		-- print("setcoententsize--w--", colW * 3+size.width, "h--", rowH * 2 + size.height)
		local w = colW * 3 + size.width
		self:setContentSize(cc.size(w, rowH * 2 + size.height))

		self.acceptR = w / 2

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
		role:actDie(function()
				role:removeFromParent(true)
				self.count = self.count - 1
				if self.count == 0 then
					self.workDone = true
				end
			end)
		
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
	if self.fightNode:isTargetInvalid() then
		self.workDone = true
		return 
	end

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
		if self.fightNode:theSameOwner(self.owner) then
			self.workDone = true
		else
		-- if self.fightNode:isTargetGeneral() then
			self:updateFace(face)
			self:actAttack(
				function()  
					self:handleFight()
					self:actStand()
				end, rate)
			
		-- else
			-- self.workDone = true
		end
	end

	return status, rate
end

function Soldier:isRemoteDamage()
	return self.fightNode:isRemoteDamage()
end

function Soldier:isInvalid()
	return #self.roles <= 0
end

function Soldier:isTargetInvalid()
	return self.fightNode:isTargetInvalid()
end

function Soldier:isTheSameOwnerWithTarget()
	return self.fightNode:theSameOwner(self.owner)
end


function Soldier:handleFight()
	self.fightNode:handleFight(self, self:attackRatio())
end

function Soldier:handleWorkDone()
	if not self:isInvalid() then
		self:handleGather()
	end
end

function Soldier:attackRatio()
	return math.max(self.soldierNum, 0)/25.0
end

function Soldier:reachPos()
	local px, py = self:getPosition()
	return cc.p(px, py)
end

function Soldier:acceptRadius()
	return self.acceptR
end

function Soldier:actStand()
	for _, v in pairs(self.roles) do
		v:actStand()
	end
end

function Soldier:actAttack(callback, time)
	for _, v in pairs(self.roles) do
		v:actAttack(callback, time)
		callback = nil
	end

end

function Soldier:actMove()
	for _, v in pairs(self.roles) do
		v:actMove()
	end
end

function Soldier:showNumEffect(num)
	self.labelEffect:showEffect(num)
end

function Soldier:handleGather()
	self.fightNode:handleGather(self.soldierNum)
end

function Soldier:handleBeAttacked(ntype, damage, dtype)
	local real = self.fightNode:getRealDamage(ntype, damage, dtype)
	-- print("last num -", self.soldierNum)
	local last = self.fightNode:displayNumber(self.soldierNum)
	local currNum = self.soldierNum - real
	local curr = self.fightNode:displayNumber(currNum)
	-- print("current num -", currNum)

	self:showNumEffect(curr - last)
	-- print("soldier set num ", currNum, "damage", real)

	self:setSoldierNum(currNum)
end

function Soldier:handleAttackBack(ntype, damage, dtype)
	print("soldier handle attack back")
	self:handleBeAttacked(ntype, damage, dtype)

end

function Soldier:handleBeAttackedBySoldier(node, damage, dtype)
	self:handleBeAttacked(node.type, damage, dtype)

	self.fightNode:checkAttackBack(node, self.type, self:attackRatio())

end

function Soldier:handleBeAttackedByGeneral(general, damage, dtype)
	print("soldier handle be attacked by general")
	self:handleBeAttacked(general.type, damage, dtype)

	self.fightNode:checkAttackBack(general, self.type, self:attackRatio())

end


return Soldier


