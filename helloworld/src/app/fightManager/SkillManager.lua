


local S = class("SkillManager")

cc.exports.SkillManager = S


function S:ctor(skillList, actionList)
	if #skillList == 0 then
		print("warning skillList is empty")
	end

	self.skillList = skillList
	self.actionList = actionList
	self.currentIdx = 0

end

function S:currentSkill()
	local idx = self.skillList[self.currentIdx + 1]
	return skills[idx]
end

function S:currentAction()
	if not self.actionList then
		return 1
	end
	return self.actionList[self.currentIdx + 1]
end

function S:currentUseRange()
	local skill = self:currentSkill()
	if not skill then
		print("load skill failed! idx:", idx)
	end
	return skill.useRange
end

function S:currentType()
	local skill = self:currentSkill()
	if not skill then
		print("load skill failed! idx:", idx)
	end

	return skill.damageType()

end

function S:next()
	self.currentIdx = (self.currentIdx + 1) % (#self.skillList)
end



return S





