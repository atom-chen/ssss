

local skillCfg = cc.exports.skills


local SkillNode = class("SkillNode")

function SkillNode:ctor(skillList, actionList)
	if #skillList == 0 then
		print("warning skillList is empty")
	end

	self.skillList = skillList
	self.actionList = actionList
	self.currentIdx = 0

end

function SkillNode:currentSkill()
	local idx = self.skillList[self.currentIdx + 1]
	return skillCfg[idx]
end

function SkillNode:currentAction()
	if not self.actionList then
		return 1
	end
	return self.actionList[self.currentIdx + 1]
end

function SkillNode:currentUseRange()
	local skill = self:currentSkill()
	if not skill then
		print("load skill failed! idx:", idx)
	end
	return skill.useRange
end

function SkillNode:currentType()
	local skill = self:currentSkill()
	if not skill then
		print("load skill failed! idx:", idx)
	end

	return skill.damageType()

end

function SkillNode:next()
	self.currentIdx = (self.currentIdx + 1) % (#self.skillList)
end



return SkillNode





