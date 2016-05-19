

local M = class("MenuNode", cc.Layer)

cc.exports.MenuNode = M

function M:ctor()
	self:onTouch(function (event) return self:touchesEvent(event) end, false, true)



end

function M:getItemForPos(pos)

	local childs = self:getChildren()

	for _, v in pairs(childs) do
		if v.isTouchEnabled and v:isTouchEnabled() and v:isVisible() then
			
		end
	end

end


function M:handleTouchBegan(event)

end


function M:handleTouchMoved(event)

end


function M:handleTouchEnded(event)

end


function M:touchesEvent(event)
	if event.name == "began" then
		self:handleTouchBegan(event)
	elseif self.name == "moved" then
		self:handleTouchMoved(event)
	else
		self:handleTouchEnded(event)
	end

end


return M


