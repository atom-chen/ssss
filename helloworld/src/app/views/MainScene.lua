

local mi = class("mi", cc.MenuItemImage)

function mi:ctor()
    local sp = cc.Sprite:create("btn/c6.png")
    self:setNormalImage(sp)
    self:onClicked(mi.onCl)
end

function mi:onCl(tag, sender)
    print("mi")
end


local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

        local menu = cc.Menu:create()
        menu:setAnchorPoint(cc.p(0, 0))
        menu:setPosition(cc.p(0, 0))
        self:addChild(menu)

        local item = mi:create()
        item:setPosition(cc.p(100, 100))
        menu:addChild(item)


end

return MainScene
