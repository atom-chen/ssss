
local A = class("SimpleAI")

cc.exports.SimpleAI = A


function A:ctor(layer, owner)
	self.fightLayer = layer
	self.owner = owner

end

function A:stopDecision()
	if self.decisionEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.decisionEntry)
		self.decisionEntry = nil
	end
end

function A:startFight()
	if not self.decisionEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.decisionEntry = scheduler:scheduleScriptFunc(function(dt) self:makeDecision(dt) end, 2, false)
	end
end

function A:buildDesition()
	local builds = self.fightLayer:allAliveFightNodes(self.owner, kBuildType)

	local dispatchs = {}
	local reinforces = {}
	for _, v in pairs(builds) do
		if v:isCanDispatch() then
			dispatchs[#dispatchs + 1] = v
		end
		if v:isNeedReinforce() then
			reinforces[#reinforces + 1] = v
		end
	end

	for _, v in pairs(reinforces) do
		if #dispatchs == 0 then
			break
		end

		local last = dispatchs[#dispatchs]
		self.fightLayer:dispatchBuild(last, v)
		dispatchs[#dispatchs] = nil
	end

	for _, v in pairs(dispatchs) do
		local target = self.fightLayer:findNearestTarget(self.owner, v:reachPos())
		self.fightLayer:dispatchBuild(v, target)
	end

end

function A:generalDesition()
	local generals = self.fightLayer:allAliveFightNodes(self.owner, kGeneralType)
	local builds = self.fightLayer:allAttackBuilds(self.owner)
	for _, v in pairs(generals) do
		if v.fightProxy:isTargetDead() then
			-- if v:isLowHealth() then
			-- 	if #builds > 0 then
			-- 		v:setStartPoint(v:reachPos())
			-- 		v:findRoute()
			-- 	end
			-- else
				local rand = math.random()
				if rand > 0.5 then
					local p = v:reachPos()
					local target = self.fightLayer:findNearestTarget(self.owner, p, true)
					if target then
						v:setTarget(target)
						v.FSM:setState(kRoleStateMove)
						v:setStartPoint(p)
						v:findRoute(target:reachPos())
					end
				end
			-- end
		end
	end

end

function A:makeDecision(dt)
	self:buildDesition()
	self:generalDesition()

end