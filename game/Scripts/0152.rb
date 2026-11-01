#encoding:utf-8
#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　地图画面
#==============================================================================

class Scene_Map < Scene_Base
  attr_accessor :message_window
  attr_reader   :minimap

  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    
    #吕布军师
    for i in 0...$game_party.al.size
      if $game_party.al[i].id == $game_variables[100] && $game_party.exist_jm_skill?(613)
        $game_party.al[i].tp = 100
      end
    end

    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    create_spriteset

    create_all_windows
    @menu_calling = false

    @map_status_window = Window_Mapstatus.new
    @map_status_window.z = 200
    hide_status

    #$game_player.add_position_to_minimap_grids    
  end

  # 地图队伍状态是否显示
  def status_show?
    $game_switches[Config::MAP_STATUS_SWITCH]
  end

  def hide_status
    if @map_status_window && !@map_status_window.disposed?
      if status_show?
        @map_status_window.visible = false
        @map_status_window.hide_sprites
      end
    end
  end

  def refresh_status2
      if @map_status_window and !@map_status_window.disposed?
         @map_status_window.refresh
      end
  end  

  def over_100
      if @map_status_window and !@map_status_window.disposed?
         @map_status_window.over_100 
      end
  end  

    def refresh_100
      if @map_status_window and !@map_status_window.disposed?
         @map_status_window.refresh_100
      end
  end  

    def over_200
      if @map_status_window and !@map_status_window.disposed?
         @map_status_window.over_200 
      end
  end  

    def refresh_200
      if @map_status_window and !@map_status_window.disposed?
         @map_status_window.refresh_200
      end
  end  


  def show_status
    # 如果开关1关闭，则能正常显示
    if @map_status_window and !@map_status_window.disposed?
      unless status_show?
        @map_status_window.visible = true
        @map_status_window.show_sprites
      end
    end
  end

  def close_now
    if @map_status_window
      @map_status_window.close_now
    end
  end

  def refresh_map_status
    if @map_status_window and !@map_status_window.disposed?
      @map_status_window.great_100 if $game_variables[123] > 0
      @map_status_window.great_200 if $game_variables[124] > 0
      @map_status_window.refresh
      if status_show?
        hide_status
      end
    end
  end

  def re_cname
    if @map_status_window
      if !@map_status_window.disposed?
        @map_status_window.re_cname
      end
    end
  end

  def re_cname_quick
    if @map_status_window
      if !@map_status_window.disposed?
        @map_status_window.re_cname_quick
        #if status_show?
           #hide_status
        #end
      end
    end
  end

  def show_cname
    if @map_status_window
      if !@map_status_window.disposed?
        @map_status_window.show_cname
      end
    end
  end

  def hide_cname
    if @map_status_window
      if !@map_status_window.disposed?
        @map_status_window.hide_cname
      end
    end
  end

  def re_map_key
    if @map_status_window
      if !@map_status_window.disposed?
          @map_status_window.re_map_key
      end
    end
  end

  def rest_map_status
    if @map_status_window
      if !@map_status_window.disposed?
        if $game_variables[123] > 0 
           @map_status_window.rest_100 
           @map_status_window.great_100 
        end
        if $game_variables[124] > 0 
           @map_status_window.rest_200 
           @map_status_window.great_200 
        end
        @map_status_window.refresh
        if status_show?
           hide_status
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 执行进入场景时的渐变
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0
      Graphics.transition(0)
      fadein(fadein_speed)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取渐变速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 15
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)

    if @message_window
      @message_window.show_message = false
      @message_window.update
    end
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super

    # => 无需手动释放
    # Graphics.freeze
    # if @message_window
    #   @message_window.dispose
    #   @message_window = nil
    # end
    # if @map_status_window
    #   @map_status_window.dispose
    #   @map_status_window = nil
    # end
    # if @minimap
    #   @minimap.dispose 
    #   @minimap = nil
    # end
    # dispose_spriteset


    Sprite_Base.dispose_reference_bitmaps
    # dispose_main_viewport
    # after_dispose
  end
  # perform_battle_transition if SceneManager.scene_is?(Scene_Battle)

  #--------------------------------------------------------------------------
  # ● 释放对象之后
  #--------------------------------------------------------------------------
  def after_dispose
    if SceneManager.scene_is?(Scene_Battle)
      rand_num = ($game_map.interpreter.running? ? ["2","3"] : ["0","1"])[rand(2)]
      Graphics.transition(60, "Graphics/System/BattleStart" + rand_num, 100)
      Graphics.freeze
    end
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.update(true)
    $game_player.update
    $game_timer.update
    @spriteset.update

    if @minimap
      @minimap.update
    end

    update_scene if scene_change_ok?
 
    if $game_switches[487] == true and @map_status_window
      @map_status_window.re_map_key
      unless  @map_status_window.move == 188 
        @map_status_window.move_cname if $hei == 0   
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以切换场景
  #--------------------------------------------------------------------------
  def scene_change_ok?
    !$game_message.busy? && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # ● 更新场景消退时的过渡
  #--------------------------------------------------------------------------
  def update_scene
    #check_gameover
    update_transfer_player unless scene_changing?
    update_encounter unless scene_changing?
    update_call_menu unless scene_changing?
    update_call_debug unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ● 更新画面（消退用）
  #--------------------------------------------------------------------------
  def update_for_fade
    update_basic
    $game_map.update(false)
    @spriteset.update if @spriteset
  end

  def update_spriteset
      $game_map.update(false)
  end
  #--------------------------------------------------------------------------
  # ● 通用的消退处理
  #--------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  #--------------------------------------------------------------------------
  # ● 淡入画面
  #--------------------------------------------------------------------------
  def fadein(duration)
    fade_loop(duration) {|v| Graphics.brightness = v }
  end
  #--------------------------------------------------------------------------
  # ● 淡出画面
  #--------------------------------------------------------------------------
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  #--------------------------------------------------------------------------
  # ● 淡入画面（白）
  #--------------------------------------------------------------------------
  def white_fadein(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, 255 - v) }
  end
  #--------------------------------------------------------------------------
  # ● 淡出画面（白）
  #--------------------------------------------------------------------------
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  #--------------------------------------------------------------------------
  # ● 生成精灵组
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 释放精灵组
  #--------------------------------------------------------------------------
  def dispose_spriteset
    if @spriteset
      @spriteset.dispose
      @spriteset = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    # create_scroll_text_window
    create_location_window
    create_minimap_window
  end
  #--------------------------------------------------------------------------
  # ● 生成迷你地图窗口
  #--------------------------------------------------------------------------
  def create_minimap_window
    @minimap = Window_Minimap.create
  end
  #--------------------------------------------------------------------------
  # ● 生成信息窗口
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # ● 生成滚动文字窗口
  #--------------------------------------------------------------------------
  # def create_scroll_text_window
  #   @scroll_text_window = Window_ScrollText.new
  # end
  #--------------------------------------------------------------------------
  # ● 生成地图名称窗口
  #--------------------------------------------------------------------------
  def create_location_window
    @map_name_window = Window_MapName.new
    @map_name_window.z = 200
  end
  #--------------------------------------------------------------------------
  # ● 监听场所移动指令
  #--------------------------------------------------------------------------
  def update_transfer_player
    perform_transfer if $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # ● 监听遇敌事件
  #--------------------------------------------------------------------------
  def update_encounter
    return if $game_test.no_enemy
    SceneManager.goto(Scene_Battle) if $game_player.encounter
  end
  #--------------------------------------------------------------------------
  # ● 监听取消键的按下。如果菜单可用且地图上没有事件在运行，则打开菜单界面。
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  #--------------------------------------------------------------------------
  # ● 打开菜单画面
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
  end
  #--------------------------------------------------------------------------
  # ● 监听 F9 的按下。如果是游戏测试的情况下，则打开调试界面
  #--------------------------------------------------------------------------
  def update_call_debug
    if $TEST
      if Input.press?(:F9)
        SceneManager.goto(Scene_Debug) 
      end   
      if Input.trigger?(:F8)
        $game_party.cant_join_actors.delete(999)
        $game_player.move_speed = 5 if $game_player.move_speed <= 4
        SceneManager.goto Scene_Actor_House
        $game_switches[1] = false     
      end     
      if Input.trigger?(:F7)
        # $game_player.move_speed = 5 if $game_player.move_speed <= 4
        SceneManager.goto Scene_Jm
        # Sound.levelup          

        # Audio.se_stop
        # Audio.__reset__
      end    
      # if Input.trigger?(:F5)
      #    $game_party.members[0].tp += 100
      #    $game_party.members[1].tp += 100
      #    $game_party.members[4].tp += 100
      #    SceneManager.goto Scene_Expbook
      # end   
      if Input.trigger?(:F5)
        # SceneManager.goto Scene_Forging
        # SceneManager.goto Scene_Expbook
      end       

    end
  end
  #--------------------------------------------------------------------------
  # ● 处理场所移动
  #--------------------------------------------------------------------------
  def perform_transfer
    if @minimap
       @minimap.dispose
       @minimap = nil
    end

    pre_transfer
    $game_player.perform_transfer
    post_transfer

    create_minimap_window
  end
  #--------------------------------------------------------------------------
  # ● 场所移动前的处理
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close if @map_name_window
    case $game_temp.fade_type
    when 0
      fadeout(fadeout_speed)
    when 1
      white_fadeout(fadeout_speed)
    end
  end
  #--------------------------------------------------------------------------
  # ● 场所移动后的处理
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    @map_name_window.open if @map_name_window
  end
  #--------------------------------------------------------------------------
  # ● 切换战斗画面前的处理
  #--------------------------------------------------------------------------
  def pre_battle_scene
    Graphics.update
    Graphics.freeze
    # @spriteset.dispose_characters
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # ● 切换到标题画面前的处理
  #--------------------------------------------------------------------------
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  #--------------------------------------------------------------------------
  # ● 执行战斗前的渐变
  #--------------------------------------------------------------------------
  # def perform_battle_transition
  #   s=(rand(2)).to_s
  #   s=(rand(2)+2).to_s if $game_map.interpreter.running?
  #   Graphics.transition(60, "Graphics/System/BattleStart"+s, 100)
  #   Graphics.freeze
  # end

  #--------------------------------------------------------------------------
  # ● 获取淡出速度
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 获取淡入速度
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 获取切换到标题画面时的淡出速度
  #--------------------------------------------------------------------------
  def fadeout_speed_to_title
    return 60
  end

end