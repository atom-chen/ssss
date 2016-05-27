
-- -------------------- DeployTopBar -----------------

local DeployTopBar = class("DeployTopBar", cc.Node)

function DeployTopBar:ctor()
	local size = cc.Director:getInstance():getWinSize()
	self:setContentSize(size)

	local bar = cc.Sprite:create("orn/a4.png")
	bar:setAnchorPoint(cc.p(0.5, 1))
	bar:setPosition(cc.p(size.width/2, size.height))
	self:addChild(bar)

	local titlebg = cc.Sprite:create("orn/a5.png")
	titlebg:setAnchorPoint(cc.p(0.5, 1))
	titlebg:setPosition(cc.pSub(bar.topCenter(), cc.p(0, 2)))
	bar:addChild(titlebg)

	self.titleLabel = cc.LabelTTF:create("", "Arial", 34)
	self.titleLabel:setTextColor(cc.num2c4b(0xfee8b7ff))
	self.titleLabel:enableOutline(cc.num2c4b(0x401700ff), 2)
	self.titleLabel:setPosition(titlebg:centerPos())
	titlebg:addChild(self.titleLabel)

	local resbg = cc.Sprite:create("orn/a24.png")
	resbg:setAnchorPoint(cc.p(1, 1))
	resbg:setPosition(cc.pSub(bar.rightTop(), cc.p(0, 12))
	bar:addChild(resbg)

	local reslbl = cc.LabelTTF:create("资源产出:", "Arial", 24)
	reslbl:setTextColor(cc.num2c4b(0x853f21ff))
	reslbl:setAnchorPoint(cc.p(0, 0.5))
	reslbl:setPosition(cc.pAdd(cc.p(30, 0), resbg:leftCenter()))
	resbg:addChild(reslbl)

	local silvP = cc.p(93, resbg:getContentSize().height/2)
	local silver = cc.Sprite:create("icon/b6_2.png")
	silver:setScale(0.8)
	silver:setPosition(silvP)
	resbg:addChild(silver)

	self.silverNum = cc.LabelTTF:create("", "Arial",22)
	self.silverNum:setTextColor(cc.num2c4b(0x49ffa6ff))
	self.silverNum:enableOutline(cc.num2c4b(0x5d2201ff))
	self.silverNum:setAnchorPoint(cc.p(0, 0.5))
	self.silverNum:setPosition(cc.p(silvP.x + silver:getRealWidth()/2, resbg:getContentSize().height/2))
	resbg:addChild(self.silverNum)

	local goldP = cc.p(158, resbg:getContentSize().height/2)
	local gold = cc.Sprite:create("icon/b6_1.png")
	gold:setScale(0.8)
	gold:setPosition(goldP)
	resbg:addChild(gold)

	self.goldNum = cc.LabelTTF:create("", "Arial", 22)
	self.goldNum:setTextColor(cc.num2c4b(0x49ffa6ff))
	self.goldNum:enableOutline(cc.num2c4b(0x5d2201ff))
	self.goldNum:setAnchorPoint(cc.p(0, 0.5))
	self.goldNum:setPosition(cc.p(goldP.x + gold:getRealWidth()/2, resbg:getContentSize().height/2))
	resbg:addChild(self.goldNum)

end

function DeployTopBar:setTitle(title)
	self.titleLabel:setString(title)
end



--	-------------- DeployScene ---------------


local DeployScene = class("DeployScene", cc.Scene)

function DeployScene:ctor()
	self:enableNodeEvents()

	self:createButtonLayer()

	self:createBarLayer()

	self:createMainLayer()

end

function DeployScene:createButtonLayer ()
	self.buttonLayer = cc.Layer:create()
	self:addChild(self.buttonLayer, 100)

	local menu = cc.Menu:create()
	self.buttonLayer:addChild(menu)

	local norm = cc.Sprite:create(btn_circle1)
	local start = cc.MenuItem:create(norm)
	start:onClicked(function(tag, sender) DeployScene:startFight() end)
	start:setAnchorPoint(cc.p(1, 0))
	local size = cc.Director:getInstance():getWinSize()
	start:setPosition(cc.p(size.width - 10, 0))

	menu:addChild(start)

	local sp = cc.Sprite:create(txt_start1)
	sp:setPosition(cc.p(start:getContentSize().width/2, start:getContentSize().height/2))
	start:addChild(sp)

end

function DeployLayer:createBarLayer()
	self.barLayer = cc.Layer:create()
	self:addChild(self.barLayer, 50)

	local top = 
	local bottom = DeployBottomBar()

end

function DeployLayer:createMainLayer()
	self.mainLayer = cc.Layer:create()
	self:addChild(self.mainLayer, 10)

end

function DeployScene:startFight()

end








return DeployScene
