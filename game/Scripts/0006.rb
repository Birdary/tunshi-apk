#encoding:utf-8

module BattleBack
  	# 地形标记 => "战斗背景文件名"
	BACK = {
	  "0" => ["平原","BS_08"],
	  "1" => ["山边","0051-Grassland06"],
	  "2" => ["海边","BS_03"],
	  "3" => ["洞穴","BS_03"],
	  "4" => ["山路","0051-Grassland06"],
	  "5" => ["森林","005-Grassland01"],
	  "6" => ["",],
	  "7" => ["",],
	  "8" => ["",],
	  "9" => ["",]
	}

	def self.set_cant_element
		terrain = $game_map.terrain_tag($game_player.x,$game_player.y)
		elements = []
		case terrain
		when 0
			elements << [:water,:wood]
		when 1
			elements << [:fire,:water]
		when 2
			elements << [:fire,:wood]
		when 3
			elements << [:water]
		when 4
			elements << [:water]
		when 5
			elements << [:water,:wood]
		end
		BattleManager.specfg do |cfg|
			cfg.cant_elements = elements
		end
	end

	def self.background_filename
		terrain = $game_map.terrain_tag($game_player.x,$game_player.y)
		return BACK[terrain.to_s].last
	end
end