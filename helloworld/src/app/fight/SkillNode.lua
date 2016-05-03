

local skillCfg = cc.exports.skills


local SkillNode = class("SkillNode")

function SkillNode:ctor(list)
	if #list == 0 then
		print("warning skillList is empty")
	end

	self.skillList = list
	self.currentIdx = 0

end

function SkillNode:currentUseRange()
	local idx = self.skillList[self.currentIdx + 1]
	local skill = skillCfg[idx]
	if not skill then
		print("load skill failed! idx:", idx)
	end
	return skill.useRange
end

function SkillNode:next()
	self.currentIdx = (self.currentIdx + 1) % (#self.skillList)
end




return SkillNode





