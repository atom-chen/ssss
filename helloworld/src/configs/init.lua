

require("configs.buildings")
require("configs.generals")
require("configs.maps")
require("configs.soldiers")
require("configs.Type")
require("configs.skills")


cc.exports.kFightScene = 1

cc.exports.kFightStatusReach = 1
cc.exports.kFightStatusNotReach = 0
cc.exports.kFightStatusNoTarget = -1

cc.exports.kRoleNone = -1
cc.exports.kRoleStand = 0
cc.exports.kRoleMove = 1
cc.exports.kRoleWin = 2
cc.exports.kRoleAttack = 3
cc.exports.kRolwDie = 4
cc.exports.kRoleSkill1 = 5
cc.exports.kRoleSkill2 = 6

cc.exports.kNormalAttack = 1
cc.exports.kSkill1 = 2
cc.exports.kSkill2 = 3

cc.exports.kPhysicalType = 1
cc.exports.kMagicType = 2

cc.exports.kSoldierType = 3
cc.exports.kGeneralType = 2
cc.exports.kBuildType = 1

cc.exports.kOwnerNone = 0
cc.exports.kOwnerPlayer = 1
