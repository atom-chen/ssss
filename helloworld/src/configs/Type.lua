cc.exports.soldierType = {
	{id=1, icon="b1",name="步兵"},
	{id=2, icon="b1",name="枪兵"},
    {id=3, icon="b1",name="骑兵"},
    {id=4, icon="b1",name="弓兵"},
}
-- 伤害类型
cc.exports.damageType ={
	{id=1, name="物理普通攻击"},
    {id=2, name="法术攻击"},  --士兵没有法术攻击，只有法术防御
}
-- 技能作用单位类型 如单体攻击 范围攻击等
cc.exports.effectType ={
    {id=1, name="单体敌方目标"},
    {id=2, name="范围内的敌方目标"},
    {id=3, name="多个敌方目标"},
    {id=4, name="己方单体"},
    {id=5, name="范围内的己方目标"},
    {id=6, name="多个己方目标"},

}
--阵营类型
cc.exports.ownerType ={
    {id=0, name="中立灰色"},
    {id=1, name="蓝色玩家"},
    {id=2, name="红色方"},
    {id=3, name="黄色方"},
    {id=4, name="紫色方"},

}