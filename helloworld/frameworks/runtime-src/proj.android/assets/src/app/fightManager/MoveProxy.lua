
local M = class("MoveProxy")


cc.exports.MoveProxy = M


function M:ctor()
	self.path = {}
	self.pos = cc.p(0, 0)
	self.speed = 0
	self.speedAdd = 0
	self.inMove = false
	self.face = false
	self.moveDis = 0
	self.moveCallbackList = {}
	self.maxMove = 0
end

function M:bindMoveDoneCallback(callback)
	self.callback = callback
end

function M:setPos(pos)
	self.pos = pos
end

function M:setMoveSpeed(speed)
	self.speed = speed
end

function M:setSpeedAdd(add)
	self.speedAdd = add
end

function M:currentSpeed()
	return self.speed + self.speedAdd
end

function M:resetPath()
	self.inMove = false
	self.moveDis = 0
	self.maxMove = 0
	self.path = {}
	self.moveCallbackLit = {}
end

function M:isInMove()
	return self.inMove
end

function M:setMoveCallbackList(list)
	table.sort(list, function(a,b) return a.dis < b.dis end)
	self.moveCallbackList = list
end

function M:addMoveCallback(node)
	local idx = 1
	for i, v in pairs(self.moveCallbackList) do
		if v.dis < node.dis then
			idx = i
			break
		end
	end
	
	table.insert(self.moveCallbackList, idx, node)
end

function M:addMovePath(path)
	for _, v in pairs(path) do
		table.insert(self.path, 1, v)
	end
end

function M:setMovePath(path, r)
	
	if #path == 0 then
		return 
	end

	self.inMove = true

	local line = path[1]
	local sp = line:startPoint()
	local ep = line:endPoint()
	local ss = cc.p(sp.x, sp.y)
	local se = cc.p(ep.x, ep.y)
	local rq = r * r
	local disq = cc.pDistanceSQ(ss, ep)

	local flag = disq < rq
	local idx = 1
	local maxIdx = #path
	while flag and idx < maxIdx do
		idx = idx + 1
		local l = path[idx]
		se = ss
		ss = l:startPoint()
		flag = cc.pDistanceSQ(ss, ep) < rq
	end

	if flag then
		return
	end

	local dir = cc.pNormalize(cc.p(ss.x-se.x, ss.y-se.y))
	local xx = se.x - ep.x
	local yy = se.y - ep.y

	local p = {}
	
	if math.abs(xx) < 0.001 and math.abs(yy) < 0.001 then
		p = cc.pAdd(cc.pMul(dir, r), ep)
		-- print("px-", p.x, "py-", p.y)
	else
		local b = 2*xx*dir.x + 2*yy*dir.y
		local c = xx * xx + yy * yy - r * r
		local delta = math.sqrt(b * b - 4 * c)
		local s = (-b + delta) / 2
		p = cc.pAdd(cc.pMul(dir, s), se)
	end

	self.path[#self.path + 1] = p
	-- print("px-", p.x, "py-", p.y)
	local dis = 0
	ep = p
	for i=idx + 1, #path do
		local l = path[i]
		local pos = l:endPoint()
		self.path[#self.path + 1] = pos
		dis = dis + cc.pGetDistance(ep, pos)
		ep = pos
	end
	dis = dis + cc.pGetDistance(ep, self.pos)
	self.maxMove = dis

end

function M:moveDoneCallback()
	-- self.inMove = false
	if self.callback then
		self.callback()
	end
end

function M:currentFace()
	return self.face
end

function M:step(dt)
	local idx = #self.path
	if idx == 0 then
		self:moveDoneCallback()
		return
	end

	local p = self.path[idx]
	local dir = cc.pNormalize(cc.pSub(p, self.pos))
	self.face = dir.x > 0
	-- print("face-", dir.x > 0)

	local dis = cc.pGetDistance(p, self.pos)
	local m = self:currentSpeed() * dt

	if dis <= m then
		self.pos = p
		self.path[idx] = nil
		self.moveDis = self.moveDis + dis
	else
		self.pos = cc.pAdd(self.pos, cc.pMul(dir, m))
		self.moveDis = self.moveDis + m
	end

	for i=#self.moveCallbackList, 1, -1 do
		local tmp = self.moveCallbackList[i]
		if tmp.dis <= self.moveDis then
			tmp.callback()
			table.remove(self.moveCallbackList, i)
		else
			break
		end
	end

	return dir

end






