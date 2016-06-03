

require("configs.buildings")
require("configs.generals")
-- require("configs.maps")
require("configs.map.init")
require("configs.soldiers")
require("configs.Type")
require("configs.skills")
require("configs.formations")


cc.exports.kFightScene = 1

cc.exports.kFightStatusDead = 3
cc.exports.kFightStatusReach = 2
cc.exports.kFightStatusNotReach = 1
cc.exports.kFightStatusNoTargetPos = 0

cc.exports.kRoleNone = -1
cc.exports.kRoleStand = 0
cc.exports.kRoleMove = 1
cc.exports.kRoleWin = 2
cc.exports.kRoleAttack = 3
cc.exports.kRoleDie = 4
cc.exports.kRoleSkill1 = 5
cc.exports.kRoleSkill2 = 6

cc.exports.kNormalAttack = 1
cc.exports.kSkill1 = 2
cc.exports.kSkill2 = 3

cc.exports.kPhysicalType = 1
cc.exports.kMagicType = 2

cc.exports.kPropType = 4
cc.exports.kSoldierType = 3
cc.exports.kGeneralType = 2
cc.exports.kBuildType = 1

cc.exports.kOwnerNone = 0
cc.exports.kOwnerPlayer = 1

cc.exports.kMaxMoveSpeed = 500

cc.exports.kTargetNone = 0
cc.exports.kTargetDestroyed = 1
cc.exports.kTargetInvalid = 2
cc.exports.kTargetValid = 3

cc.exports.kBuildStatusInvalid = 0
cc.exports.kBuildStatusNormal = 1
cc.exports.kBuildStatusAttack = 2

cc.exports.kSoldierStatusNextTarget = 0
cc.exports.kSoldierStatusGather = 1
cc.exports.kSoldierStatusNormal = 2
cc.exports.kSoldierStatusDead = 3

cc.exports.kSoldierRowOff = 25

cc.exports.kGeneralStatusNormal = 0
cc.exports.kGeneralStatusReset = 1
cc.exports.kGeneralStatusDead = 2

cc.exports.kPropStatusHit = 0
cc.exports.kPropStatusNoTarget = 1
cc.exports.kPropStatusNormal = 2


cc.exports.kGeneralAnimDelay = 1.0/8
cc.exports.kSoldierAnimDelay = 1.0/8
cc.exports.kBuffAnimDelay = 1.0/8
cc.exports.kEffectAnimDelay = 1.0/8

cc.exports.kPropMoveSpeed = 100

cc.exports.kEffectTag = 100
cc.exports.kRoleActTag = 101
cc.exports.kRoleGatherTag = 102
cc.exports.kBeAttackedTag = 103

cc.exports.kGatherSpeed = 100

cc.exports.kSkillPointSpeed = 5
cc.exports.kMaxSkillPoint = 10
cc.exports.kSkillCDTime = 3

cc.exports.kSoldierDispersal=2.5


