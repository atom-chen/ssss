


local R = class("RouteFinder")

cc.exports.RouteFinder = R

local instance = nil

function R:ctor()

end

function R:test()

end

function R:setkk(kk)

end


function R:getInstance()
	if not instance then
		instance = R:create()
	end

	return instance

end





return R


