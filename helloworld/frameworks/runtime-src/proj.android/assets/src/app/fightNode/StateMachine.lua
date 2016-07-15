local S = class("StateMachine")

cc.exports.StateMachine = S


function S:ctor()

	-- self.currentState = kRoleStateStand
	-- self.nextState = kRoleStateStand
	self.state = kRoleStateStand
	self.callbacks = {}

end

function S:bindStateCallback(state, callback)
	self.callbacks[state] = callback
end

function S:currentState()
	return self.state
end

function S:setState(state)
	-- self.nextState = state
	-- if self.state == state then
	-- 	return
	-- end

	self.state = state
	if self.callbacks[state] then
		self.callbacks[state]()
	end

end


