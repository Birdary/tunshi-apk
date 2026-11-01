#encoding:utf-8
module Config
	DEFAULT_GRAPH_POINT = 30        # => 默认天赋点数
  FORMATION_NEED_MEMBER_COUNT = 4 # => 阵型需要队员数量

  MAP_STATUS_SWITCH = 1           # => 地图窗口显示开关编号

  # 服务器
  # SERVER_NAME = $TEST ? "http://twk2nd.com:8081" : "http://192.168.2.102:3000"

  SCENE_FREEZE = true            # => 场景转换冻结

  MAP_SCENE_USE_CACHE = true     # => 地图场景使用缓存

end



class GameTest

  # 章节主城 坐标格式 地图id,x,y,
  CHAPTER_MAP = {
    "01" => [881, 17, 8],
    "02" => [71, 40, 55],
    "03" => [77, 68, 68],
    "09" => [22, 10, 10]
  }

  attr_accessor :battle_escape       # => 测试战斗逃跑(逃跑奔溃测试)
  attr_accessor :skip_battle         # => 跳过战斗
  attr_accessor :faster_run          # => 加速行走
  attr_accessor :no_enemy            # => 不遇敌
  attr_accessor :through_wall        # => 穿墙
  # attr_accessor :all_items           # => 全道具
  # attr_accessor :transfer_map        # => 地图跳转

  def initialize
    @battle_escape = false
    @skip_battle = false           # => 为了加速测试剧情默认开启
    @faster_run = false
    @no_enemy = false              # => 为了加速测试剧情默认开启
    @through_wall = false
  end

  def make_test_list
    [
      ["保存存档1", :save1, ""],
      ["战斗自动逃跑(用于测试奔溃)",:battle_escape,@battle_escape ? "on" : "off"],
      ["跳过剧情战斗",:skip_battle,@skip_battle ? "on" : "off"],
      ["全体升1级",:leveup_one,""],
      ["增加10000G",:gain_gold,""],
      ["加速行走",:faster_run,@faster_run ? "on" : "off"],
      ["不遇敌",:no_enemy,@no_enemy ? "on" : "off"],
      ["穿墙",:through_wall,@through_wall ? "on" : "off"],
      ["全道具",:all_items,""],
      ["全武器",:all_weapons,""],
      ["全防具",:all_armors,""],
      ["武将编程",:house,""],
      ["军师设定",:jm,""],
      ["跳到第一章",:transfer_01, ""],
      ["跳到第二章",:transfer_02, ""],
      ["跳到第三章",:transfer_03, ""],
      ["跳到第四章",:transfer_04, ""],
      ["跳到第五章",:transfer_05, ""],
      ["跳到第六章",:transfer_06, ""],
      ["跳到第七章",:transfer_07, ""],
      ["跳到第八章",:transfer_08, ""],
      ["跳到测试图",:transfer_09, ""]
    ]
  end

  def toggle_battle_escape
    @battle_escape = @battle_escape ? false : true
  end
  def toggle_skip_battle
    @skip_battle = @skip_battle ? false : true
  end
  def toggle_faster_run
    @faster_run = @faster_run ? false : true
  end
  def toggle_no_enemy
    @no_enemy = @no_enemy ? false : true
  end
  def toggle_through_wall
    @through_wall = @through_wall ? false : true
  end
end


