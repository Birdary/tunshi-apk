#encoding:utf-8
#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　处理系统附属数据的类。保存存档和菜单的禁止状态之类的数据。
#   本类的实例请参考 $game_system 。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :save_disabled            # 禁用存档
  attr_accessor :menu_disabled            # 禁用菜单
  attr_accessor :encounter_disabled       # 禁用遇敌
  attr_accessor :formation_disabled       # 禁用整队
  attr_accessor :battle_count             # 战斗回数
  attr_reader   :save_count               # 存档回数
  attr_reader   :version_id               # 游戏版本ID
  attr_accessor :sk_graph                 # 天赋
  attr_accessor :system_menu_config       # 系统菜单设置（音量，等)
  attr_accessor :game_clear               # 通关设置等
  attr_accessor :minimap_grids            # 小地图同行格子
  attr_accessor :wegame_push_achievement  # wegame 成就推送
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @formation_disabled = false
    @battle_count = 0
    @save_count = 0
    @version_id = 0
    @window_tone = nil
    @battle_bgm = nil
    @battle_end_me = nil
    @saved_bgm = nil
    @system_menu_config = {}
    @game_clear = {}
    @minimap_grids = {}
    @wegame_push_achievement = {}
  end

  def load_custom_config
    @system_menu_config ||= {}
    unless @game_clear
      @game_clear = {
        :clear_times => 0,
        :exp15 => false,
        :graph => false,
        :level_limit => 50
      }
    end
  end

  #--------------------------------------------------------------------------
  # ● 判定是否日语模式
  #--------------------------------------------------------------------------
  def japanese?
    $data_system.japanese
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口色调
  #--------------------------------------------------------------------------
  def window_tone
    @window_tone || $data_system.window_tone
  end
  #--------------------------------------------------------------------------
  # ● 设置窗口色调
  #--------------------------------------------------------------------------
  def window_tone=(window_tone)
    @window_tone = window_tone
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗 BGM
  #--------------------------------------------------------------------------
  def battle_bgm
    @battle_bgm || $data_system.battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗 BGM
  #--------------------------------------------------------------------------
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗结束 ME
  #--------------------------------------------------------------------------
  def battle_end_me
    @battle_end_me || $data_system.battle_end_me
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗结束 ME 
  #--------------------------------------------------------------------------
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #--------------------------------------------------------------------------
  # ● 存档前的处理
  #--------------------------------------------------------------------------
  def on_before_save
    @save_count += 1
    @version_id = $data_system.version_id
    @frames_on_save = Graphics.frame_count
    @bgm_on_save = RPG::BGM.last
    @bgs_on_save = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # ● 读档后的处理
  #--------------------------------------------------------------------------
  def on_after_load
    Graphics.frame_count = @frames_on_save
    @bgm_on_save.play
    @bgs_on_save.play
  end
  #--------------------------------------------------------------------------
  # ● 获取游戏时间的秒数
  #--------------------------------------------------------------------------
  def playtime
    Graphics.frame_count / Graphics.frame_rate
  end
  #--------------------------------------------------------------------------
  # ● 获取游戏时间的字符串
  #--------------------------------------------------------------------------
  def playtime_s
    hour = playtime / 60 / 60
    min = playtime / 60 % 60
    sec = playtime % 60
    sprintf("%02d:%02d:%02d", hour, min, sec)
  end
  #--------------------------------------------------------------------------
  # ● 保存 BGM 
  #--------------------------------------------------------------------------
  def save_bgm
    @saved_bgm = RPG::BGM.last
  end
  #--------------------------------------------------------------------------
  # ● 重播 BGM 
  #--------------------------------------------------------------------------
  def replay_bgm
    @saved_bgm.replay if @saved_bgm
  end
end
