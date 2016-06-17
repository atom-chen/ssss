

local D = class("DispatchList")

function D:ctor(type, owner)
	self.list = {}
	self.type = type
	self.owner = owner
end

function D:addNode(node)
	if node.owner == self.owner and 
		((self.type == kGeneralType and node.type == kBuildType) or 
			(self.type == kBuildType and node.type == kGeneralType)) then
		return
	end
	
	-- if self.target then
	-- 	self.target:unselect()
	-- end
	if node.owner == self.owner then
		self.list[#self.list + 1] = node
	end

	-- if self.owner ~= node.owner or node.type ~= self.type then
	-- 	self.target = node
	-- else
	-- 	self.list[#self.list + 1] = node
	-- 	self.target = nil
	-- end

	node:select()
	node:setStartPoint(node:reachPos())
	if node.type == kBuildType then
		node:showHalo(true)
		node:showAttackHalo(true)
	end
	-- print("nodetype", node.type, "owner", node.owner, "selfO", self.owner)
	-- if node.type == kBuildType then
	-- 	if node.owner == self.owner then
	-- 		node:showHalo(true)
	-- 	else
	-- 		node:showTargetHalo(true)
	-- 	end
	-- end

end

function D:setTarget(target)
	if self.target and self.target.owner ~= self.owner then
		self.target:unselect()
	end

	self.target = target

	if target then
		target:select()
		if target.type == kBuildType then
			if target.owner ~= self.owner then
				target:showTargetHalo(true)
			end

			if target.owner ~= kOwnerNone then
				target:showAttackHalo(true)
			end
		end
	end
end

function D:getTroopsTarget()
	if not self.target then
		self.target = self.list[#self.list]
		self.list[#self.list] = nil
	end
	
	return self.target
end


local M = class("DispatchManager")

cc.exports.DispatchManager = M

function M:ctor()
	-- self.dispatchList = DispatchList:create(type, owner)
	-- self.activeIdx = 0
	-- self.maxIdx = 0

end

function M:addDispatchList(type, owner)
	self.dispatchList = D:create(type, owner)
	-- self.maxIdx = self.maxIdx + 1
	-- self.dispatchList[self.maxIdx] = DispatchList:create(type, owner)

	-- if self.activeIdx == 0 then
		-- self.activeIdx = 1
	-- end

end

function M:currentDispatchList()
	-- return self.dispatchList[self.activeIdx]
	return self.dispatchList
end

function M:dispatchDone()

	-- self.dispatchList[self.activeIdx] = nil
	self.dispatchList = nil

	-- if self.activeidx == self.maxIdx then
		-- self.activeIdx = 0
		-- self.maxIdx = 0
	-- else
		-- self.activeIdx = self.activeIdx + 1
	-- end
end

function M:addDispatchNode(node)
	-- local list = self.dispatchList[self.maxIdx]
	-- list:addNode(node)
	self.dispatchList:addNode(node)

end

function M:setTarget(node)
	self.dispatchList:setTarget(node)
end


return M