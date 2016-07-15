local D = {}

cc.exports.MapData = D


function D:loadMapIndex()
	local cfg = require("configs.xmlToLua.CityFightCfg")
	self.mapIndex = {}
	for _, v in pairs(cfg.valueList) do
		local camp = v.Campaign
		local tmp = {}
		for key, value in pairs(camp) do
			if key == "valueList" then
				for k1, v1 in pairs(value) do
					for k2, v2 in pairs(v1) do
						tmp[k2] = v2
					end
				end
			else
				tmp[key] = value
			end
		end

		self.mapIndex[camp.mapId] = tmp

	end

end

function D:loadMap(mapId)
	local camp = self.mapIndex[mapId]
	if not camp then
		print("no map -", mapId)
		return
	end

	local path = "configs.map."..camp.name
	print("path-", path)
	local data = require(path)
	self.mapData = data
	return data
end

function D:currentMapRank()
	local mapId = self.mapData.id
	return self:mapRank(mapId)
end

function D:mapRank(mapId)
	local camp = self.mapIndex[mapId]

	return camp.Reward.rank
end


D:loadMapIndex()

return D