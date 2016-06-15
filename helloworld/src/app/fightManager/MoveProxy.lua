
local M = class("MoveProxy")


cc.exports.MoveProxy = M


function M:ctor()
	self.path = {}
	self.pos = cc.p(0, 0)
	self.speed = 0
	self.speedAdd = 0
	self.inMove = false
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
	self.path = {}
end

function M:isInMove()
	return self.inMove
end

function M:setMovePath(path, r)
	if #path == 0 then
		return 
	end

	self.inMove = true
	local line = path[1]
	local sp = line:startPoint()
	local ep = line:endPoint()
	-- print("ex-", ep.x, "ey-", ep.y, "sx-", sp.x, "sy-", sp.y)
	-- local dis = cc.pGetDistance(sp, ep)
	local ss = cc.p(sp.x, sp.y)
	local se = cc.p(ep.x, ep.y)
	local rq = r * r
	local disq = cc.pDistanceSQ(ss, ep)

	local flag = disq < rq
	local idx = #path
	while flag do
		idx = idx + 1
		local l = path[idx]
		se = ss
		ss = l:startPint()
		flag = cc.pDistanceSQ(ss, ep) < rq
	end

	local dir = cc.pNormalize(cc.p(ss.x-se.x, ss.y-se.y))
	local aa = 2
	local b = 2*dir.x*(se.x-ep.x)+2*dir.y*(se.y-ep.y)
	local c = cc.pDistanceSQ(se, ep)

	local delta = math.sqrt(b*b - 2*aa*c)
	local s = (-b + delta)/aa

	local p = cc.pAdd(cc.pMul(dir, s), ep)

	-- print("idx", idx)
	-- for i, v in pairs(path) do
	-- 	local l = path[i]
	-- 	print("rx-", l:startPoint().x, "ry-", l:startPoint().y)
	-- end

	self.path[#self.path + 1] = p

	for i=2, #path do
		local l = path[i]
		self.path[#self.path + 1] = l:endPoint()
	end

	for _, v in pairs(self.path) do
		print("px-", v.x, "py-", v.y)
	end

end

function M:callback()
	if self.callback then
				self.callback()
	end
end

function M:step(dt)
	local idx = #self.path
	if idx == 0 then
		self:callback()
		return
	end

	local p = self.path[idx]
	local dir = cc.pNormalize(cc.pSub(p, self.pos))

	local dis = cc.pGetDistance(p, self.pos)
	local m = self:currentSpeed() * dt

	if dis < m then
		self.pos = p
		self.path[idx] = nil
	else
		self.pos = cc.pAdd(self.pos, cc.pMul(dir, m))
	end

end






