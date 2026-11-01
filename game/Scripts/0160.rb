#encoding:utf-8
#==============================================================================
# ■ Scene_Debug
#------------------------------------------------------------------------------
# 　调试画面
#==============================================================================

#encoding:utf-8
#==============================================================================
# ■ Window_DebugLeft
#------------------------------------------------------------------------------
# 　调试画面中，显示开关和变量编号的窗口。
#==============================================================================

class Window_CheatDebug < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @list = nil
    self.contents = Bitmap.new(window_width,window_height)
    # p contents.width
    # p contents.height
    # p "================="
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    @list.size || 0
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
  end

  def auto_cheat!
    now_cheat = @list[self.index]
    # symbol = now_cheat[1]
    flag = now_cheat[1]
    case flag
    when :save1
      # 处理存档
      DataManager.make_filename(0)
      Sound.levelup
    when :leveup_one
      # 处理全体升级
      $game_party.level_up
      # Audio.bgm_fade(300)
      Sound.levelup
      # RPG::BGM.last.replay
    when :gain_gold
      $game_party.gain_gold(10000)
      Sound.levelup
    when :all_items
      $game_party.setup_battle_test_items
      Sound.levelup
    when :all_weapons
      $game_party.setup_battle_test_weapons
      Sound.levelup
    when :all_armors
      $game_party.setup_battle_test_armors
      Sound.levelup
    when :house
      $game_player.move_speed = 5 if $game_player.move_speed <= 4
      SceneManager.call Scene_Actor_House
      Sound.levelup
    when :jm
      SceneManager.goto Scene_Jm
      Sound.levelup
    when /^transfer_(.*)$/
      $game_player.reserve_transfer(*GameTest::CHAPTER_MAP[$1], 2)
      # 返回地图场景标记
      return "transfer"
    else
      $game_test.send "toggle_#{flag}"
    end
    refresh
  end

  def create_contents
    @list = $game_test.make_test_list
  end

  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    create_contents
    item_max.times {|i|
      draw_item(i) 
    }
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @list[index]
    self.contents.draw_text(0,24*index, window_width,24,item.first + "(" + item.last + ")")
  end
end




class Scene_Debug < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_all_window
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # def terminate
  #   super
  #   #$game_map.refresh
  # end

  def create_all_window
    create_main_menu
    create_var_and_switch_windows
    create_cheat_debug_window

    @left_window.hide
    @right_window.hide
    @debug_help_window.hide
    @cheat_debug_window.hide

    @cheat_debug_window.active = false
    @left_window.active = false
    @main_window.activate
    @main_window.select(0)
  end

  def create_main_menu
    @main_window = Window_Command.new(0,0,320,160)
    @main_window.instance_eval do
      def create_contents
        add_command("作弊调试类", :cheat_debug, true)
        add_command("开关变量类", :var, true)
        add_command("退出", :exit, true)
      end
    end
    @main_window.refresh

    @main_window.set_handler(:ok,     method(:on_main_ok))
    @main_window.set_handler(:cancel, method(:return_scene))
  end

  def return_scene_map
    SceneManager.goto(Scene_Map)
  end

  def on_main_ok
    case @main_window.index
    when 0
      @main_window.unselect
      @main_window.hide
      @main_window.active = false
      @left_window.active = false
      @right_window.active = false

      @cheat_debug_window.activate
      @cheat_debug_window.select(0)
      @cheat_debug_window.show      
    when 1
      @main_window.unselect
      @main_window.hide
      @left_window.show
      @left_window.activate
      @left_window.select(0)
      @right_window.show
      @debug_help_window.show
    when 2
      return_scene_map
    end
    return
  end

  def create_var_and_switch_windows
    create_left_window
    create_right_window
    create_debug_help_window
  end

  def create_cheat_debug_window
    @cheat_debug_window = Window_CheatDebug.new(0,0)
    @cheat_debug_window.select(0)
    @cheat_debug_window.set_handler(:ok,     method(:on_cheat_debug_window_ok))
    @cheat_debug_window.set_handler(:cancel, method(:return_main_window))
  end

  def on_cheat_debug_window_ok
    r = @cheat_debug_window.auto_cheat!
    if r == "transfer"
      # return_scene
      return_scene_map
    else
      @cheat_debug_window.activate
    end
  end

  def return_main_window
    @left_window.unselect
    @left_window.hide
    @right_window.unselect
    @right_window.hide
    @cheat_debug_window.unselect
    @cheat_debug_window.hide

    @debug_help_window.hide

    @main_window.activate
    @main_window.index = 0
    @main_window.show
  end

  #--------------------------------------------------------------------------
  # ● 生成左窗口
  #--------------------------------------------------------------------------
  def create_left_window
    @left_window = Window_DebugLeft.new(0, 0)
    @left_window.set_handler(:ok,     method(:on_left_ok))
    @left_window.set_handler(:cancel, method(:return_main_window))
  end
  #--------------------------------------------------------------------------
  # ● 生成右窗口
  #--------------------------------------------------------------------------
  def create_right_window
    wx = @left_window.width
    ww = Graphics.width - wx
    @right_window = Window_DebugRight.new(wx, 0, ww)
    @right_window.set_handler(:cancel, method(:on_right_cancel))
    @left_window.right_window = @right_window
  end
  #--------------------------------------------------------------------------
  # ● 生成帮助窗口
  #--------------------------------------------------------------------------
  def create_debug_help_window
    wx = @right_window.x
    wy = @right_window.height
    ww = @right_window.width
    wh = Graphics.height - wy
    @debug_help_window = Window_Base.new(wx, wy, ww, wh)
  end
  #--------------------------------------------------------------------------
  # ● 左“确定”
  #--------------------------------------------------------------------------
  def on_left_ok
    refresh_help_window
    @right_window.activate
    @right_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 右“取消”
  #--------------------------------------------------------------------------
  def on_right_cancel
    @left_window.activate
    @right_window.unselect
    @debug_help_window.contents.clear
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助窗口
  #--------------------------------------------------------------------------
  def refresh_help_window
    @debug_help_window.draw_text_ex(4, 0, help_text)
  end
  #--------------------------------------------------------------------------
  # ● 获取帮助字符串
  #--------------------------------------------------------------------------
  def help_text
    if @left_window.mode == :switch
      "C (Enter) : ON / OFF"
    else
      "← (Left)    :  -1\n" +
      "→ (Right)   :  +1\n" +
      "L (Pageup)   : -10\n" +
      "R (Pagedown) : +10"
    end
  end
end
