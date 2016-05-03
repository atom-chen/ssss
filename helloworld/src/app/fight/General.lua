
local General = class("General", cc.Node)


local kFightStatusNotReach = 0
local kFightStatusReach = 1

local kRoleMove = 1

function General:ctor(cfg, owner, id)
	self.cfg = cfg
	self.owner = owner
	self.type = 2
	self.id = id

	local image = self:roleImage()
	self.role = self:createRoleNode(image)
	self.role:setAnchorPoint(cc.p(0, 0))
	self.role:setPosition(cc.p(0, 0))
	self:addChild(self.role)
	self.role:face(owner == 2)

	self:setContentSize(self.role:getContentSize())

	self:createFightNode()
	
end

function General:createRoleNode(name)
	local cls = require("app.fight.RoleNode")
	if cls then
		return cls:create(name)
	else
		print("load app.fight.RoleNode failed")
	end
end

function General:createFightNode()
	local cls = require("app.fight.FightNode")
	if cls then
		local fightNode = cls:create()
		fightNode:parseGeneralCfg(self.cfg)
		self.fightNode = fightNode
	else
		print("load app.fight.RoleNode failed")
	end
end

function General:roleImage()
	return "action/"..self.cfg.icon
end

function General:isTouchEnabled()
	return true
end

function General:setTarget(target)
	self.fightNode:setTarget(target)
end

function General:setTargetPos(pos)
	self.fightNode:setTargetPos(pos)
end

function General:setStandPos(pos)
	self.fightNode:setStandPos(pos)
	self:setPosition(pos)
end

function General:setHighLight()
	-- local sp = self.role

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureHightLight")
	-- sp:setGLProgram(program)
	self.role:setHighLight()

end

function General:setNormalLight()
	-- local sp = self.role

	-- local program = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
	-- sp:setGLProgram(program)
	self.role:setNormalLight()

end

function General:checkReachTarget(pos)

end

function General:reachPos()
	local px, py = self:getPosition()
	return cc.p(px, py+20)
end

function General:updateMove(dt)
	local status, last, face = self.fightNode:checkMove(dt)
	if status == kFightStatusNotReach then
		-- print("general move-x--", last.x, "y--", last.y)
		self.role:face(face)
		self.role:actMove()
		self:setPosition(last)
		
	end

	return status, last
end

function General:updateAttack(dt)
	local status, rate, face = self.fightNode:checkAttack(dt)

	if status == kFightStatusReach then
		if self.fightNode:isTargetPos() or self.fightNode:theSameStamp(self.owner) then
			self.fightNode:setTargetPos(nil)
			self.role:actStand()
		else
			self.role:face(face)
			self.role:actAttack(
				function()  
					self.fightNode:handleFight(self)
					self.role:actStand()
				end, rate)
		end
	end

	return status, rate

end




return General
















