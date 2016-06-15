

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
	
	if self.target then
		self.target:unselect()
	end

	if self.owner ~= node.owner or node.type ~= self.type then
		self.target = node
	else
		self.list[#self.list + 1] = node
		self.target = nil
	end

	node:select()
	-- print("nodetype", node.type, "owner", node.owner, "selfO", self.owner)
	if node.type == kBuildType then
		if node.owner == self.owner then
			node:showHalo(true)
		else
			node:showTargetHalo(true)
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


return M