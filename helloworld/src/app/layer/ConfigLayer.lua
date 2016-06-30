
local C = class("ConfigLayer", cc.Layer)

cc.exports.ConfigLayer = C


function C:ctor(mapId)
	self.winSize = cc.Director:getInstance():getWinSize()

	-- local node = cc.Sprite:create("bg/b15_2.png")
	-- node:setVisible(false)
	-- self:addChild(node)
	-- self.drawNode = node
	-- local sz = node:getContentSize()
	-- self.defaultR = sz.width/2
	-- self.skillPoint = 0
	-- self.totalTime = 0
	self.mapId = mapId

	self:createMenu()



end

function C:createMenu()

	local menu = cc.Menu:create()
	self:addChild(menu)
	menu:setPosition(cc.p(0, 0))
	self.menu = menu

	local item = cc.MenuItemImage:create("btn/c6.png", "")
	item:onClicked(function() self:nextFight() end)
	item:setPosition(cc.p(self.winSize.width/2, self.winSize.height/2))
	-- print("px-", self.winSize.width/2, "py-", self.winSize.height/2)
	menu:addChild(item)
	item:setVisible(false)
	self.nextItem = item

	local txt = cc.Sprite:create("txt/d1.png")
	item:addChild(txt)
	txt:setPosition(item:centerPos())

end

function C:nextFight()
	local nextmap = self.mapId
	if self.success then
		nextmap = nextmap + 1
	end

	local scene = FightScene:create(nextmap)
    display.runScene(scene)
    -- scene:startFight()
end

function C:showNext(success)
	-- print("show next")
	self.success = success
	self.nextItem:setVisible(true)

end