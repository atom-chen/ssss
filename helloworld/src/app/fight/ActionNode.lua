

local ActionList = class("ActionList")

function ActionList:ctor(type, owner)
	self.list = {}
	self.type = type
	self.owner = owner
end

function ActionList:addNode(node)

	if self.owner ~= node.owner or node.type ~= self.type then
		if self.target then
			self.target:unselect()
		end

		self.target = node

	else
		self.list[#self.list + 1] = node
	end

	node:select()

end

function ActionList:getTroopsTarget()
	if not self.target then
		self.target = self.list[#self.list]
		self.list[#self.list] = nil
	end
	return self.target
end


local ActionNode = class("ActionNode")

function ActionNode:ctor()
	self.actionList = {}
	self.activeIdx = 0
	self.maxIdx = 0

end

function ActionNode:addActionList(type, owner)
	self.maxIdx = self.maxIdx + 1
	self.actionList[self.maxIdx] = ActionList:create(type, owner)

	if self.activeIdx == 0 then
		self.activeIdx = 1
	end

end

function ActionNode:currentActionList()
	return self.actionList[self.activeIdx]
end

function ActionNode:actionDone()

	self.actionList[self.activeIdx] = nil

	if self.activeidx == self.maxIdx then
		self.activeIdx = 0
		self.maxIdx = 0
	else
		self.activeIdx = self.activeIdx + 1
	end
end

function ActionNode:addNode(node)
	local list = self.actionList[self.maxIdx]
	list:addNode(node)

end


return ActionNode