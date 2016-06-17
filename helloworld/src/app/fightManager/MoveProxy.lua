
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

	-- print("ssx-", ss.x, "ssy-", ss.y)
	-- print("sex-", se.x, "sey-", se.y)
	-- print("epx-", ep.x, "epy-", ep.y)
	-- print("dirx-", dir.x, "diry-", dir.y, "r-", r, "xx-", xx, "yy-", yy)
	if math.abs(xx) < 0.001 and math.abs(yy) < 0.001 then
		p = cc.pAdd(cc.pMul(dir, r), ep)
		-- print("px-", p.x, "py-", p.y)
	else
		local b = 2*xx*dir.x + 2*yy*dir.y
		local c = xx * xx + yy * yy - r * r
		local delta = math.sqrt(b * b - 4 * c)
		local s = (-b + delta) / 2
		-- print("b-", b)
		-- print("c-", c)
		-- print("delta-", delta)
		-- print("s-", s)
		p = cc.pAdd(cc.pMul(dir, s), se)
	end

	self.path[#self.path + 1] = p
	-- print("px-", p.x, "py-", p.y)
	for i=idx + 1, #path do
		local l = path[i]
		local pos = l:endPoint()
		self.path[#self.path + 1] = pos
	end

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

end






