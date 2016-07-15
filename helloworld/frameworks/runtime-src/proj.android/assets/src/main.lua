
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "app.init"
require "configs.init"


local function main()
    -- require("app.MyApp"):create():run()

    local scene = FightScene:create(2)
    display.runScene(scene)
    -- scene:startFight()

end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
