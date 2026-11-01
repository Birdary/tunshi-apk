#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　战斗画面
#==============================================================================
class Scene_Battle < Scene_Base
  attr_accessor :play_fullscreen_animation_unique_id
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗背景
  #--------------------------------------------------------------------------
  def get_battle_back_filename
    a = $game_variables[136]
    fname = a
    #靠近水边的坐标
    if a.to_s[2,2] == "01" and $game_map.region_id($game_player.x , $game_player.y) >= 60 
    fname = (a.to_s[0,3] + "0").to_s
    end
    fname = "1_01" if fname.nil?
    fname
  end
  #--------------------------------------------------------------------------
  # ● 开始后处理
  #--------------------------------------------------------------------------
  def post_start
    super

    # => 全屏动画播放中的动画
    @play_fullscreen_animation_unique_id = nil

    # 野外遇敌加强
    enemy_hero_team
    # 难度调整
    hard_easy_mode

    # 盗贼的被动技能的设置
    bskill_6_7
    # 战斗开始前 如果有人变身 判断重复武将
    process_event_int
    # 清除护身烟效果
    #if $game_switches[399]
    #$game_variables[123] = 0
    #$game_switches[399] = false
    #end
    # 行动回数
    @turn_size = 0
    @members_0 = 0
    @members_1 = 0
    @members_2 = 0
    @members_3 = 0
    @members_4 = 0

    #伤害触发士气允许标记
    $turn_damage = 0
    @km_c = 0

    #记录集火目标
    @make_target_most = []

    # => 状态提示开关
    $game_switches[S::STATUS_TIP] = true

    #对话嘟嘟嘟声音打开开关
    $game_switches[S::DIALOG_HONK] = true

    #自动战斗AI初始化，默认关闭
    $game_switches[S::AUTO_BATTLE_AI] = false

    # 行动菜单是否播放过CV语音, 当前行动者 index + 1
    @talk = 0

    @cache_animation_bitmap = CacheBattleBitmap.new

    $game_party.on_battle_start
    $game_troop.on_battle_start

    create_spriteset

    create_fiber_sprits
    create_all_windows


    for a in 0...$game_party.members.size
      $game_party.members[a].over_damage =0
      $game_party.members[a].over_sup = 0
      $game_party.members[a].kill_size = 0
      $game_party.members[a].dead_size = 0
      @make_target_most[a] = -1
    end
     for a in 0...$game_troop.members.size
      $game_troop.members[a].over_damage = 0
      $game_troop.members[a].over_sup = 0
      $game_troop.members[a].target_most = 0
     end

    #进入战斗前设置阵型
    if $game_variables[108] != nil and $game_variables[108] > 4 and $game_party.alive_members.size > 4
       for i in 0...$game_party.alive_members.size
           $game_party.alive_members[i].change_x -= $data_skills[$game_variables[108]].pos_start[i] * 24
           $game_party.alive_members[i].formation_pos += $data_skills[$game_variables[108]].pos_start[i]
       end
       $game_party.set_formation($game_variables[108])
    end

    $game_party.set_formation(4) if $game_party.alive_members.size < 5 
    $game_troop.set_formation(4) 

    v = Viewport.new
    v.z = 601
    @tip = Sprite_Battle_Tip.new v
    if @spriteset
       @spriteset.show_boost
       @spriteset.create_actor_status_sp
       @spriteset.allload!
       #my_hide
       @spriteset.all_show if @spriteset
       @status_window.visible = true
       @status_window.show_all_face
    end


    
    # 直接终止
    if $TEST_ST
      BattleManager.process_abort
      return
    end

    start_an

    # Todo remove
    # BattleManager.process_abort
    # return

    BattleManager.method_wait_for_message = method(:wait_for_message)
    battle_start





    # 直接终止
    # if $TEST_ST
    #   BattleManager.process_abort
    #   return
    # end

    # 测试奔溃 直接撤退
    # $game_test.battle_escape = true

    # if $TEST_ST
    #   BattleManager.process_victory
    #   return
    # end
    # if $TEST_ST
    #   command_escape
    #   return
    # end

    BattleManager.process_escape if $game_test.battle_escape
  end

  def cache_animation_bitmap
    @cache_animation_bitmap
  end

  def my_hide
    if @status_window.visible == true
       @spriteset.all_hide if @spriteset
       @status_window.visible = false
       @status_window.hide_all_face
       #@party_command_window.deactivate 
       #@party_command_window.visible = false
    end
  end  

  def enemy_hide
    #if @status_window.visible == true
    @spriteset.all_hide_enemy if @spriteset
    @status_enemy_window.visible = false
    #end
  end  

  def my_show
    if @status_window.visible == false
       @spriteset.all_show if @spriteset
       @status_window.visible = true
       @status_window.show_all_face
       #@party_command_window.activate 
       #@party_command_window.visible = true
    end
  end 
  #--------------------------------------------------------------------------
  # ● 进入战斗特效
  #--------------------------------------------------------------------------
   def start_an
    op = false
    base = 0
    size = 6
    if $game_map.interpreter.running?
      base = 1
      size = 25
    end
    if $game_troop.alive_members.size == 6
      size = 25
      base = 1
    end    
    Audio.se_play("Audio/SE/bell1",100,75)
    if base > 0
      start_logo = Sprite.new
      start_logo.bitmap = Bitmap.new("Graphics/zdbg/turn_s")
      start_logo.attrset :opacity=>0,:x=>492,:y=>215+30,:z=>1000
      start_2 = Sprite.new
      start_2.bitmap = Bitmap.new("Graphics/zdbg/turn_end02")
      start_2.attrset :opacity=>0,:x=>492+50+87,:y=>215+30+46+88,:z=>1001
      start_3 = Sprite.new
      start_3.bitmap = Bitmap.new("Graphics/zdbg/turn_end03")
      start_3.attrset :opacity=>0,:x=>492-50+62,:y=>215+30+10+82,:z=>1001
    end

    for i in 0...6
      if $game_party.alive_members.size > i
        a = $game_party.alive_members[i]
        if base == 0
           a.animation_id = 360
        else
           a.animation_id = 343
        end
      end
      if $game_troop.alive_members.size > i
        b = $game_troop.alive_members[i]
        if base == 0
           b.animation_id = 360
        else
           b.animation_id = 344 if i != 5
        end
      end
      if i != 5 
        if base == 1
          wait(17) if i < $game_party.alive_members.size or i < $game_troop.alive_members.size
          a.change_btm_st :normal
          b.change_btm_st :normal 
        end
      end

      if i == 5 and $game_troop.alive_members.size > 5
        if b.element_rate(45) != 1
          b.animation1_name = "DM#{(b.element_rate(45)*100).round}" + "-q"
        else
          b.animation1_name = "DM" + b.id.to_s + "-q"
        end
        b.animation_id = 345
        wait(2)
        b.change_btm_st :normal
      end

      if base == 1  
        for c in 0...10
          wait(1)
          if op == false
            start_logo.opacity += 30
            start_2.opacity += 30
            start_3.opacity += 30
            start_2.x -= 5
            start_3.x += 5
          end
          op = true if start_logo.opacity >= 255
        end
      end
    end

    if base == 0
      wait(20)
      for i in 0...$game_party.alive_members.size
        a = $game_party.alive_members[i]
        a.change_btm_st :normal
      end
      for i in 0...$game_troop.alive_members.size
        b = $game_troop.alive_members[i]
        b.change_btm_st :normal
      end
    else
      for i in 0...15
        wait(1)
        start_logo.opacity -= 18
        start_2.opacity -= 18
        start_3.opacity -= 18
        start_2.x -= 5
        start_3.x += 5
      end

      start_logo.bitmap.dispose
      start_logo.dispose
      start_2.bitmap.dispose
      start_2.dispose
      start_3.bitmap.dispose
      start_3.dispose
      start_logo = nil
      start_2 = nil
      start_3 = nil

    end
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    Graphics.fadeout(30) if SceneManager.scene_is?(Scene_Map)
    Graphics.fadeout(60) if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super

  #   dispose_exp
  #   dispose_spriteset

  #   @info_viewport.dispose
  #   @info_viewport2.dispose
  #   @info_viewport3.dispose
  #   @info_viewport4.dispose
  #   @info_viewport5.dispose

  #   @info_viewport = nil
  #   @info_viewport2 = nil
  #   @info_viewport3 = nil
  #   @info_viewport4 = nil
  #   @info_viewport5 = nil

  #   @cache_animation_bitmap.dispose
  #   @cache_animation_bitmap = nil

  #   @tip.dispose
    
  # end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    BattleFiber.dispose_sprites
    BattleManager.dispose_escape_back
    Sprite_Base.dispose_reference_bitmaps
    super
  end

  #--------------------------------------------------------------------------
  # ● 释放对象之后
  #--------------------------------------------------------------------------
  def after_dispose
    RPG::ME.stop
    GC.start
  end

  def update_speed_key #菜单快捷键
    if Keys.trigger?(Keys::N1)
      if @party_command_window.active == true and !BattleManager.in_turn?
        @party_command_window.select(0)
        @party_command_window.process_ok
        return
      end
      if @actor_command_window.active == true and !BattleManager.in_turn?
        @actor_command_window.select(0)
        @actor_command_window.process_ok
        return
      end   
    end 

    if Keys.trigger?(Keys::N2)
      if @party_command_window.active == true and !BattleManager.in_turn?
        @party_command_window.select(1)
        @party_command_window.process_ok
        return
      end
      if @actor_command_window.active == true and !BattleManager.in_turn?
        @actor_command_window.select(1)
        @actor_command_window.process_ok
        return
      end 
    end

    if Keys.trigger?(Keys::N3)
      if @party_command_window.active == true and !BattleManager.in_turn?
        @party_command_window.select(2)
        @party_command_window.process_ok
        return
      end
      if @actor_command_window.active == true and !BattleManager.in_turn?
        @actor_command_window.select(2)
        @actor_command_window.process_ok
        return
      end 
    end 

    if Keys.trigger?(Keys::N4)
      if @actor_command_window.active == true and !BattleManager.in_turn?
        @actor_command_window.select(3)
        @actor_command_window.process_ok
        return
      end 
    end

    if Keys.trigger?(Keys::N5)
      if @actor_command_window.active == true and !BattleManager.in_turn?
        @actor_command_window.select(4)
        @actor_command_window.process_ok
        return
      end 
    end

    if Keys.trigger?(Keys::N6)
      if @actor_command_window.active == true and !BattleManager.in_turn?
        @actor_command_window.select(5)
        @actor_command_window.process_ok
        return
      end 
    end
  end  
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if BattleManager.in_turn?
       update_basic
       process_event
       process_action
    end
    update_speed_key

    if $TEST 
      if Input.trigger?(:F9)
         BattleManager.judge_win_loss 
         $game_party.members.each do |actor|
         actor.hp = 1
         end
      end

      if Input.trigger?(:F8)
         #BattleManager.judge_win_loss
         rand_damage = 0
         rand_sup = 0
         #@party_command_window.deactivate 
        # @party_command_window.visible = false
         for a in 0...$game_troop.members.size
             rand_damage += $game_troop.members[a].mhp
         end
         rand_damage = (rand_damage / ($game_troop.members.size) ).to_i 
         for a in 0...$game_party.members.size
             $game_party.members[a].over_damage += rand_damage
             $game_party.members[a].kill_size += 1
             if $game_map.interpreter.running?
                $game_party.members[a].over_sup += rand(1200) 
             else
                $game_party.members[a].over_sup += rand(120) 
             end
         end
         $game_troop.members.each do |actor|
         actor.hp -= (actor.mhp-1)
         BattleManager.judge_win_loss
         end
     end

     if  Input.trigger?(:F5)
         a = 10  if 5 > nil
         for i in 0...5
             $game_party.members[i].tp -= rand(50)
             if rand > 0.5
                $game_party.members[i].add_state_must(3)
             else 
                $game_party.members[i].remove_state(3)
             end
         end
     end

     if Input.trigger?(:F6)
        for i in 0...5
            $game_party.members[i].tp += rand(50)
        end
     end
    end


  end
  #--------------------------------------------------------------------------
  # ● 更新画面（基础）
  #--------------------------------------------------------------------------
  def update_basic   
    super
    BattleFiber.update_wave if BattleFiber.is_animation?
    $game_timer.update
    $game_troop.update
    @spriteset.update if @spriteset
    update_message_open
    update_info_viewport
    @tip.update
    if Input.trigger?(:B) && BattleManager.all_atk == :start
       BattleManager.set_all_atk :cancel
    end
  end

  def update_basic_except_input
    Graphics.update
    update_all_windows
    $game_timer.update
    $game_troop.update
    @spriteset.update if @spriteset
    @tip.update
    update_info_viewport
  end

  #def update_bar
    # @spriteset.update_bar
  #end

  #--------------------------------------------------------------------------
  # ● 提示动画是否显示中?
  #--------------------------------------------------------------------------
  def tip_animation?
    @tip.animation?
  end

  #--------------------------------------------------------------------------
  # ● 更新画面（等待用）
  #--------------------------------------------------------------------------
  def update_for_wait
      update_basic
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times {|i| update_for_wait if i < duration / 2 || !show_fast? }
  end
  #--------------------------------------------------------------------------
  # ● 快进判定
  #--------------------------------------------------------------------------
  def show_fast?
    Input.press?(:A) || Input.press?(:C)
  end
  #--------------------------------------------------------------------------
  # ● 等待（快进无效）
  #--------------------------------------------------------------------------
  def abs_wait(duration)
    duration.times {|i| update_for_wait }
  end
  #--------------------------------------------------------------------------
  # ● 短时间等待（快进无效）
  #--------------------------------------------------------------------------
  def abs_wait_short
    abs_wait(15)
  end
  #--------------------------------------------------------------------------
  # ● 等待信息显示的结束
  #--------------------------------------------------------------------------
  def wait_for_message
    @message_window.update if @message_window
    update_for_wait while $game_message.visible
  end

  def wait_for_ok
    while $game_message.visible
      Graphics.update
      Input.update
      @message_window.update if @message_window
    end
  end

  #--------------------------------------------------------------------------
  # ● 等待动画显示的结束
  #--------------------------------------------------------------------------
  def wait_for_animation
    update_for_wait
    if @spriteset && !scene_changing?
      while @spriteset.animation?
        update_for_wait
        #BattleFiber.update_wave if BattleFiber.is_animation?
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待效果执行的结束
  #--------------------------------------------------------------------------
  def wait_for_effect
    update_for_wait
    if @spriteset
      update_for_wait while @spriteset.effect?
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新信息显示的显示端口
  #--------------------------------------------------------------------------
  def update_info_viewport
    #move_info_viewport(0)   if @party_command_window.active
    #move_info_viewport(128) if @actor_command_window.active
    # move_info_viewport(64)  if BattleManager.in_turn?
  end
  #--------------------------------------------------------------------------
  # ● 移动信息显示的显示端口
  #--------------------------------------------------------------------------
  def move_info_viewport(ox)
    current_ox = @info_viewport.ox
    @info_viewport.ox = [ox, current_ox + 16].min if current_ox < ox
    @info_viewport.ox = [ox, current_ox - 16].max if current_ox > ox
  end
  #--------------------------------------------------------------------------
  # ● 信息窗口打开时的更新
  #    在状态窗口关闭完成前，信息窗口的打开度设置为 0 。
  #--------------------------------------------------------------------------
  def update_message_open
    if $game_message.busy? && !@status_window.close?
       my_hide 
    end
    #  @message_window.openness = 0
    #  @status_window.close
     # @party_command_window.close
     # @actor_command_window.close
    #end
  end
  #--------------------------------------------------------------------------
  # ● 生成精灵组
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● 生成Fiber精灵
  #--------------------------------------------------------------------------
  def create_fiber_sprits
    BattleFiber.create_sprites
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
  # ● 获取战斗精灵
  #--------------------------------------------------------------------------
  def spriteset
    @spriteset
  end
  #--------------------------------------------------------------------------
  # ● 刷新敌人状态
  #--------------------------------------------------------------------------
  def refresh_enemy_state(enemy_id)
    @spriteset.refresh_enemy_status(enemy_id) if @spriteset
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    # create_scroll_text_window
    create_status_window
    create_status_enemy_window
    create_info_viewport
    create_party_command_window
    create_actor_command_window
    create_help_window
    create_skill_window
    create_item_window
    create_actor_window
    create_enemy_window
  end
  #--------------------------------------------------------------------------
  # ● 生成信息窗口
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
    @message_window.z = 999
    #@message_window.x = -300
    #@message_window.y = 0
  end
  #--------------------------------------------------------------------------
  # ● 生成滚动文字窗口
  #--------------------------------------------------------------------------
  # def create_scroll_text_window
  #   @scroll_text_window = Window_ScrollText.new
  # end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BattleStatus.new
    @status_window.x = 880-94-96#+64
    @status_window.y = 0
   # @status_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 生成敌人窗口
  #--------------------------------------------------------------------------
  def create_status_enemy_window
    @status_enemy_window = Window_BattleStatusEnemy.new
    #@status_enemy_window.x = 0
    #@status_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 生成信息显示的显示端口
  #--------------------------------------------------------------------------
  def create_info_viewport

    @info_viewport = Viewport.new
    @info_viewport.rect.y = Graphics.height - @status_window.height
    @info_viewport.rect.height = @status_window.height
    @info_viewport.z = 90
   # @info_viewport.visible = false
  

    # 用于显示敌方状态
    @info_viewport2 = Viewport.new
    @info_viewport2.rect.x = 0
    @info_viewport2.rect.y = 60
    @info_viewport2.rect.width = 840
    @info_viewport2.rect.height = 190+50
    @info_viewport2.z = 200

    # 用于显示队伍指令菜单
    @info_viewport3 = Viewport.new
    @info_viewport3.rect.x = 946
    @info_viewport3.rect.y = 111
    @info_viewport3.rect.width = 340
    @info_viewport3.rect.height = 340
    @info_viewport3.z = 200

    # 用于显示敌人状态
    @info_viewport4 = Viewport.new
    @info_viewport4.rect.x = 0
    @info_viewport4.rect.y = 90
    @info_viewport4.rect.width = 950
    @info_viewport4.rect.height = 250
    @info_viewport4.z = 200


    # 用于显示道具技能阵型等窗口
    @info_viewport5 = Viewport.new
    @info_viewport5.rect.x = 980
    @info_viewport5.rect.y = 290
    @info_viewport5.rect.width = 300
    @info_viewport5.rect.height = 200
    @info_viewport5.z = 200
    @info_viewport5.visible = false

    @status_window.viewport = @info_viewport
    @status_enemy_window.viewport = @info_viewport2
  end
  #--------------------------------------------------------------------------
  # ● 生成队伍指令窗口
  #--------------------------------------------------------------------------
  def create_party_command_window
    @party_command_window = Window_PartyCommand.new
    @party_command_window.x-=10 
    #@party_command_window.y-=1
    @party_command_window.viewport = @info_viewport3
    @party_command_window.set_handler(:fight,  method(:command_fight))
    @party_command_window.set_handler(:allattack,method(:command_allattack))
    @party_command_window.set_handler(:escape, method(:command_escape))
    @party_command_window.unselect
    #@party_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 生成角色指令窗口
  #--------------------------------------------------------------------------
  def create_actor_command_window
    @actor_command_window = Window_ActorCommand.new
    @actor_command_window.x -= 10
    @actor_command_window.viewport = @info_viewport3
    @actor_command_window.set_handler(:attack, method(:command_attack))
    @actor_command_window.set_handler(:marv, method(:command_marv))
    @actor_command_window.set_handler(:skill,  method(:command_skill))
    @actor_command_window.set_handler(:guard,  method(:command_guard))
    @actor_command_window.set_handler(:item,   method(:command_item))
    @actor_command_window.set_handler(:formation,   method(:command_formation))
    @actor_command_window.set_handler(:cancel, method(:prior_command))
    #@actor_command_window.x = Graphics.width
    #@actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 生成帮助窗口
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.visible = false
    @help_window.x = 10
    @help_window.y = 650
    @help_window.font_size = 17
  end
  #--------------------------------------------------------------------------
  # ● 生成技能窗口
  #--------------------------------------------------------------------------
  def create_skill_window
    @skill_window = Window_BattleSkill.new(@help_window, @info_viewport5)
    @skill_window.set_handler(:ok,     method(:on_skill_ok))
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成物品窗口
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_BattleItem.new(@help_window, @info_viewport5)
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成角色窗口
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_BattleActor.new(@info_viewport4)
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
    @actor_window.visible
  end
  #--------------------------------------------------------------------------
  # ● 生成敌人窗口
  #--------------------------------------------------------------------------
  def create_enemy_window
    @enemy_window = Window_BattleEnemy.new(@info_viewport4)
    @enemy_window.set_handler(:ok,     method(:on_enemy_ok))
    @enemy_window.set_handler(:cancel, method(:on_enemy_cancel))
  end

  def get_enemy_window
      @enemy_window
  end

  def message_window
      @message_window
  end
  #--------------------------------------------------------------------------
  # ● 更新状态窗口的信息
  #--------------------------------------------------------------------------
  def refresh_status
    @status_window.refresh
    @status_enemy_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 状态窗口闪烁头像
  #--------------------------------------------------------------------------
  def flash_face(subject)
    if subject.actor?
      @status_window.flash_face(subject.id)
    else
      @spriteset.flash_enemy_face(subject) if @spriteset
    end
  end

  def dead_face(subject)
    @status_window.dead_face(subject.id)
  end

  def alive_face(subject)
    @status_window.alive_face(subject.id)
  end

  #--------------------------------------------------------------------------
  # ● 进行下一个指令输入
  #--------------------------------------------------------------------------
  def next_command(from_cmd=false)
    if BattleManager.next_command
       start_actor_command_selection(cmd=from_cmd)
    else
       turn_start
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个指令输入
  #--------------------------------------------------------------------------
  def prior_command
    if BattleManager.prior_command
       #取消集火目标仇恨数
       most = @make_target_most[BattleManager.actor.index]
       if most > -1
          $game_troop.members[most].target_most -= 1
          @make_target_most[BattleManager.actor.index] = -1 
       end
       start_actor_command_selection
    else
       start_party_command_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始队伍指令的选择
  #--------------------------------------------------------------------------
  def start_party_command_selection(battle_start=false)
    unless scene_changing?
            my_show  #事件结束正式开始战斗显示我军数据show_all_face
      refresh_status
      @status_window.unselect
      @status_window.open
      if BattleManager.input_start
        @actor_command_window.close ; @actor_command_window.hide
        @party_command_window.setup
        if block_given?
          yield
        else
          if battle_start
            BattleFiber.cmd_menu_move(@party_command_window,:appear){ update_basic_except_input }
          else
            @actor_command_window.show()
            BattleFiber.cmd_menu_move_toggle(@actor_command_window,@party_command_window){ update_basic_except_input }
            @actor_command_window.hide()
          end
        end
      else
        @party_command_window.deactivate
        turn_start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令“战斗”
  #--------------------------------------------------------------------------
  def command_fight
      $game_switches[400] = false
     # if $game_party.members[i].movable? and !$game_party.members[i].confusion? 
      next_command(true)
      return
  end
  #--------------------------------------------------------------------------
  # ● 指令“总攻”
  #--------------------------------------------------------------------------
  def command_allattack
    wait_for_animation if tip_animation?
    BattleFiber.cmd_menu_move(@party_command_window,:disappear){ update_basic_except_input }
    @party_command_window.opacity = 0
    @party_command_window.close
    Audio.se_play("Audio/SE/fcmove")
    BattleFiber.all_atk(){update_basic}
    BattleManager.set_all_atk :start
    @party_command_window.deactivate    
    $game_party.set_atk_cmd
    #$game_troop.set_atk_cmd
    turn_start
    wait(25)
  end

  def command_allattack_cancel
     Audio.se_play("Audio/SE/fcmove")
    BattleFiber.all_atk(cancel=true){update_basic}
    BattleManager.set_all_atk :over
  end

  #--------------------------------------------------------------------------
  # ● 指令“撤退”
  #--------------------------------------------------------------------------
  def command_escape
      $game_switches[400] = true
      Audio.se_play("Audio/SE/wind1",100,100)
      if  BattleManager.process_escape
          wait_for_animation if tip_animation?
      else
          turn_start
      end
  end
  #--------------------------------------------------------------------------
  # ● 开始角色指令的选择
  #--------------------------------------------------------------------------
  def start_actor_command_selection(from_cmd=false)
    #@status_window.select(BattleManager.actor.index)
    @actor_command_window.setup(BattleManager.actor)
    if from_cmd
       BattleFiber.cmd_menu_move_toggle(@party_command_window,@actor_command_window){ update_basic_except_input }
    end
    @actor_command_window.visible = true
    @party_command_window.close
  end
  #--------------------------------------------------------------------------
  # ● 指令“攻击”
  #--------------------------------------------------------------------------
  def command_attack
    BattleManager.actor.input.set_attack
    select_enemy_selection
  end
  #--------------------------------------------------------------------------
  # ● 指令“计策”
  #--------------------------------------------------------------------------
  def command_marv
    command_skill_base
    @skill_window.set_type(:marv)
    @skill_window.set_background("skill_back")
    menu_move_in(@skill_window,@actor_command_window)
  end
  #--------------------------------------------------------------------------
  # ● 指令“技能”
  #--------------------------------------------------------------------------
  def command_skill
    command_skill_base
    @skill_window.set_type(:skill)
    @skill_window.set_background("skill_back_jn")
    menu_move_in(@skill_window,@actor_command_window)
  end
  #--------------------------------------------------------------------------
  # ● 指令“阵型”
  #--------------------------------------------------------------------------
  def command_formation
    command_skill_base
    @skill_window.set_type(:formation)
    @skill_window.set_background("skill_back_fc")
    menu_move_in(@skill_window,@actor_command_window)
  end

  def menu_move_in(w1,w2)
    BattleFiber.menu_move_in(w1,w2) { update_basic_except_input }
  end

  def menu_move_out(w1,w2)
    BattleFiber.menu_move_out(w1,w2) { update_basic_except_input }
  end

  def menu_move_out_self(w1)
    BattleFiber.menu_move_out_self(w1) { update_basic_except_input }
  end

  def command_skill_base
    @skill_window.actor = BattleManager.actor
    @skill_window.stype_id = @actor_command_window.current_ext
    @skill_window.show.activate
    @skill_window.show_back
    @help_window.show_back
  end
  #--------------------------------------------------------------------------
  # ● 指令“防御”
  #--------------------------------------------------------------------------
  def command_guard
    BattleManager.actor.input.set_guard
    next_command
  end
  #--------------------------------------------------------------------------
  # ● 指令“物品”
  #--------------------------------------------------------------------------
  def command_item
    @item_window.refresh
    @item_window.set_background
    @item_window.show.activate
    @item_window.index = 0
    @item_window.show_back
    @help_window.show_back
    menu_move_in(@item_window,@actor_command_window)
  end
  #--------------------------------------------------------------------------
  # ● 开始选择队友
  #--------------------------------------------------------------------------
  def select_actor_selection
    @actor_window.show.activate
    @actor_window.show_one_arrow
    @actor_window.flash_index
    @help_window.hide_back
    @help_window.hide
    #if @actor_command_window.current_symbol == :formation && @skill.id == 13
      #set_text("请选择\\c[10]生门武将\\c[0]")
    #end
  end

  #--------------------------------------------------------------------------
  # ● 当前光标选择的 物品  道具
  #--------------------------------------------------------------------------
  def current_selected_last_skill
    BattleManager.actor.last_skill
  end

  def set_text text,color=nil
    @help_window.show_back
    @help_window.show
    @help_window.set_text(text,color)
  end

  def tip text,color
    @tip.add text,color
  end

  #--------------------------------------------------------------------------
  # ● 角色“确定”
  #--------------------------------------------------------------------------
  def on_actor_ok(state)
    if state == :all
      @skill = $data_skills[current_selected_last_skill.object.id + 1]
      current_selected_last_skill.object = @skill
      BattleManager.actor.current_action.set_skill(@skill.id)
    end
      @actor_window.hide_all_arrow
    BattleManager.actor.input.target_index = @actor_window.index
      
      @skill_window.hide_back_tag
      @item_window.hide_back_tag

    if [:skill,:marv,:formation].include? @actor_command_window.current_symbol
       if BattleManager.actor == $game_party.movable_members.last
          menu_move_out_self(@skill_window)
       else
          menu_move_out(@skill_window,@actor_command_window)
       end
    end
    if @actor_command_window.current_symbol == :item
       if BattleManager.actor == $game_party.movable_members.last
          menu_move_out_self(@item_window)
       else
          menu_move_out(@item_window,@actor_command_window)
       end
    end

    @actor_window.hide
    @skill_window.hide
    @item_window.hide
    @item_window.hide_back
    @help_window.hide_back
    next_command
  end
  #--------------------------------------------------------------------------
  # ● 角色“取消”
  #--------------------------------------------------------------------------
  def on_actor_cancel
    @actor_window.hide
    case @actor_command_window.current_symbol
    when :skill,:marv,:formation
      @skill_window.activate
      BattleManager.actor.current_action.clear
      current_selected_last_skill.object = nil
    when :item
      @item_window.activate
    end
    @help_window.show_back
    @help_window.show
  end
  #--------------------------------------------------------------------------
  # ● 开始选择敌人
  #--------------------------------------------------------------------------
  def select_enemy_selection
    if @actor_command_window.current_symbol == :marv
    #  p BattleManager.actor
    #  p $data_skills[current_selected_last_skill.object.id + 1]
      #@enemy_window.refresh_success_rate(BattleManager.actor,$data_skills[current_selected_last_skill.object.id + 1])
    end
    @enemy_window.refresh
    @enemy_window.show.activate
    @enemy_window.show_one_arrow
    @help_window.hide
    @help_window.hide_back
    @enemy_window.flash_index
  end
  #--------------------------------------------------------------------------
  # ● 敌人“确定”
  #--------------------------------------------------------------------------
  def on_enemy_ok(state)
    if state == :all
      @skill = $data_skills[current_selected_last_skill.object.id + 1]
      current_selected_last_skill.object = @skill
      BattleManager.actor.current_action.set_skill(@skill.id) 
    end
    #庞统主动技能豪风随机2345
    if @skill != nil and @skill.id == 292
    if BattleManager.actor.state?(87)
       BattleManager.actor.current_action.set_skill(406) 
    elsif  BattleManager.actor.state?(88)
       BattleManager.actor.current_action.set_skill(407) 
    elsif  BattleManager.actor.state?(89)
       BattleManager.actor.current_action.set_skill(408) 
    end
    end
    BattleManager.actor.input.target_index = @enemy_window.enemy.index

   
    #增加集火目标仇恨
    if @actor_command_window.current_symbol == :marv or @actor_command_window.current_symbol == :skill
       skill = $data_skills[current_selected_last_skill.object.id]
    end
    if @actor_command_window.current_symbol == :attack 
       skill = $data_skills[1]
    end
    if skill != nil and skill.damage.to_hp? and skill.for_one?
       most = BattleManager.actor.index
       b = @enemy_window.enemy.index
       $game_troop.members[b].target_most += 1
       @make_target_most[most] = b
    end

    @enemy_window.hide
    @enemy_window.hide_arrow
    @skill_window.hide_back_tag
    @item_window.hide_back_tag


    if [:skill,:marv,:formation].include? @actor_command_window.current_symbol
        if BattleManager.actor == $game_party.movable_members.last
           menu_move_out_self(@skill_window)
           else
           menu_move_out(@skill_window,@actor_command_window)
        end
    end

    if @actor_command_window.current_symbol == :item
       if BattleManager.actor == $game_party.movable_members.last
          menu_move_out_self(@item_window)
          else
          menu_move_out(@item_window,@actor_command_window)  
       end     
    end

    @skill_window.hide
    @item_window.hide
    @item_window.hide_back
    @help_window.hide_back
    next_command
  end

  #--------------------------------------------------------------------------
  # ● 敌人“取消”
  #--------------------------------------------------------------------------
  def on_enemy_cancel
    @enemy_window.hide
    case @actor_command_window.current_symbol
    when :attack
         @actor_command_window.activate
    when :skill,:marv,:formation
         @help_window.show_back
         @help_window.show
         @skill_window.activate
         BattleManager.actor.current_action.clear
         current_selected_last_skill.object = nil
    when :item
         @item_window.activate
         @help_window.show_back
         @help_window.show
    end
    #@help_window.hide_back
  end
  #--------------------------------------------------------------------------
  # ● 技能“确定”
  #--------------------------------------------------------------------------
  def on_skill_ok
    @skill = @skill_window.item
    return if @skill.nil?
    BattleManager.actor.input.set_skill(@skill.id)
    current_selected_last_skill.object = @skill
    if !@skill.need_selection?
        @skill_window.hide_back_tag
        if BattleManager.actor == $game_party.movable_members.last
           menu_move_out_self(@skill_window)
        else
           menu_move_out(@skill_window,@actor_command_window)
        end
      @skill_window.hide
      @help_window.hide_back
      @help_window.hide
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能“取消”
  #--------------------------------------------------------------------------
  def on_skill_cancel
    @skill_window.hide_back_tag
    menu_move_out(@skill_window,@actor_command_window)
    @skill_window.hide
    @actor_command_window.activate
    @help_window.hide_back
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  def on_item_ok
    @item = @item_window.item
    return if @item.nil?
    BattleManager.actor.input.set_item(@item.id)
   # BattleManager.actor.input.set_skill(127)
    current_selected_last_skill.object = @item

    if !@item.need_selection?
      @item_window.hide_back_tag
      if BattleManager.actor == $game_party.movable_members.last
         menu_move_out_self(@item_window)
      else
         menu_move_out(@item_window,@actor_command_window)
      end    
      @item_window.hide
      @item_window.hide_back
      @help_window.hide_back
      next_command
    elsif @item.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
    $game_party.last_item.object = @item
    @help_window.hide_back
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.hide_back_tag
    menu_move_out(@item_window,@actor_command_window)
    @item_window.hide
    @item_window.hide_back
    @actor_command_window.activate
    @help_window.hide_back
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始
  #--------------------------------------------------------------------------
  def battle_start
    update_basic
    # 初始化战斗开始数据
    BattleManager.battle_start
    full_hp_mp
    # 处理事件
    bskill_end_91
    bskill_end_bm
    bskill_end_2_63
    bskill_end_52s
    process_event
    bskill_end_60
    #暗杀标记
    bskill_assassin
    # wait_for_toum
    # @spriteset.create_actor_status_sp
    # @spriteset.allload!
    start_party_command_selection(true)
    wait_for_animation
    # @status_window.show_all_face
    # @spriteset.show_boost
  end
  #--------------------------------------------------------------------------
  # ● 回合开始
  #--------------------------------------------------------------------------
  def turn_start
   # all_battle_members.each do |battler|
   # battler.on_turn_end_3
    #end
    $game_switches[S::DIALOG_HONK] = true
    update_basic
    @party_command_window.close
    @actor_command_window.close
    @status_window.unselect
    @subject = nil
    unless BattleManager.all_atk == :start
           if @actor_command_window.visible == true
              BattleFiber.cmd_menu_move(@actor_command_window,:disappear){ update_basic_except_input }
           end
    end
    BattleManager.turn_start
    #@log_window.wait
   # @log_window.clear
    jing_star
  end
  #--------------------------------------------------------------------------
  # ● 回合结束
  #--------------------------------------------------------------------------
  def turn_end
    $game_switches[S::DIALOG_HONK] = false
    $game_switches[S::AUTO_BATTLE_AI] = false
    for a in 0...$game_troop.members.size
        $game_troop.members[a].target_most = 0
    end
    for a in 0...$game_troop.members.size
        @make_target_most[a] = -1
    end
    @talk = 0
    @move_up = 0

    unless BattleManager.all_atk == :start
      update_basic #总攻加速
      BattleFiber.turn_end { update_basic } if $game_troop.alive_members.size > 0 and $game_party.alive_members.size > 0
      jing_turn
    end

    #turn_end_formation

    #回合结束被动及效果---------------------------------
    bskill_end_duyu
    bskill_end_26
    bskill_end_50
    bskill_end_91s
    bskill_end_60
    bskill_end_39
    bskill_end_17
    bskill_end_bagua
    bskill_end_bm
    bskill_end_23_hh
    fire_turn_end
    bskill_end_QNS
    wuhu_skill_turn_end
    #---------------------------------------------------

    all_battle_members.each do |battler|
      unless BattleManager.all_atk == :start
      update_basic #总攻加速
      end
      if @spriteset && @spriteset.animation?
         battler.on_turn_end_2
      else
         battler.on_turn_end
      end
      refresh_status
      #@log_window.display_auto_affected_status(battler)
      #@log_window.wait_and_clear
    end
    sima_over
    bskill_end_23_over
    # 移除特殊效果
    $game_party.remove_spe_item_effect
    $game_troop.remove_spe_item_effect


    BattleManager.turn_end
    process_event

    if $game_troop.alive_members.size != 0 and $game_party.alive_members.size != 0
        bskill_assassin
    case BattleManager.all_atk
    when :start
      $game_party.make_actions
      $game_troop.make_actions
      #BattleManager.clear_actor
      $game_party.set_atk_cmd
      turn_start
    when :cancel
      command_allattack_cancel
      #BattleManager.set_all_atk :over
      #@actor_command_window.show
      #BattleFiber.cmd_menu_move(@actor_command_window,:appear){ update_basic_except_input }
      start_party_command_selection(true)
    when :over
      #@actor_command_window.show
      #BattleFiber.cmd_menu_move(@actor_command_window,:appear){ update_basic_except_input }
      start_party_command_selection(true)
      #start_actor_command_selection
    end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取敌我双方的全部参战角色
  #--------------------------------------------------------------------------
  def all_battle_members
    update_basic
    $game_party.members + $game_troop.members
  end
  #--------------------------------------------------------------------------
  # ● 处理事件
  #--------------------------------------------------------------------------
  def process_event
    #总攻加速
    unless BattleManager.all_atk == :start
    update_basic
    end 
    # 场景未跳转的情况下 - 循环处理事件
    while !scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      BattleManager.judge_win_loss
      break unless $game_troop.interpreter.running?
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理强制战斗行动
  #--------------------------------------------------------------------------
  def process_forced_action
    if BattleManager.action_forced?
       my_show
       last_subject = @subject
       @subject = BattleManager.action_forced_battler
       BattleManager.clear_action_force
       process_action
       @subject = last_subject
    end
  end

  #--------------------------------------------------------------------------
  # ● 处理战斗行动
  #--------------------------------------------------------------------------
  def process_action

    update_basic
    return if scene_changing?

    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end

    return turn_end unless @subject

    if @subject.current_action
           my_show
      @subject.current_action.prepare
      if @subject.current_action.valid?
        # 行动有效的情况下
        # 处理行动
        if ( @subject.state?(27) or @subject.state?(117) ) and @subject.actor?  #我方疑心计50%行动
          if 50 >= rand(100) 
            @status_window.open
            execute_action 
          else
            unless [:start,:cancel].include?(BattleManager.all_atk)
              BattleFiber.action_invalid(@subject){ update_basic_except_input }
            end
          end
        else
        @status_window.open
        execute_action
        end
      else
        unless [:start,:cancel].include?(BattleManager.all_atk)
          # 行动无效的情况下 做退回动作
          BattleFiber.action_invalid(@subject){ update_basic_except_input }
        end
      end
      # 清除行动前，触发的被动
      bskill_end_wawa
      # 清除行动
      @subject.remove_current_action
    end
    process_action_end unless @subject.current_action
  end
  #--------------------------------------------------------------------------
  # ● 战斗行动结束时的处理
  #--------------------------------------------------------------------------
  def process_action_end
    @move_up = 0 #可以上前一步
    update_basic

    # 清除行动  @result 的清除, buff以及 自动状态的清除
    @subject.on_action_end
    refresh_status
    BattleManager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # ● 执行战斗行动
  #--------------------------------------------------------------------------
  def execute_action
      update_basic
      use_item
    # @subject.sprite_effect_type = :whiten
  end
  #--------------------------------------------------------------------------
  # ● 使用技能／物品
  #--------------------------------------------------------------------------
  def use_item
    update_basic

    # 获取行动者的道具/技能
    item = @subject.current_action.item

    # 辅助丹在战斗中使用，和计策全体一样的方法，【去除，改成回合延长】
    # if item.is_a?(RPG::Item) and item.speed == 3
      #item = $data_items[@subject.current_action.item.id+61]
    #end

    # 加入行动列表 新增-用于被动技能
    @subject.action_list << item if @subject.actor?

    # 行动者使用道具/技能(技能消费sp, 道具减少数量, 设置item公共事件ID)
    @subject.use_item(item)

    # 生成目标数组
    return if @subject.current_action.nil?
    targets = @subject.current_action.make_targets.compact 

    #50%几率再攻击一次，诸葛连弩效果 #混乱时不会触发，防止攻击自己人出错，出错情况，当第一下打死自己人以后，第二下如果打自己，就出错。
    if @subject.atk_times_add >= 1 and !@subject.confusion?
        r = @subject.atk_states_rate(130)
        r = 0.5 if @subject.actor? and r > 0.5
       if rand < r
       @two_atk = (@subject.atk_times_add).to_i
       else
       @two_atk = 0
       end
    else
       @two_atk = 0
    end

     # 计算行动次数
    @nn = 0 #觉醒次数
    if @subject.equip_wtype_ok?(5)
       @nn = -1 
       @nn =  0 if @subject.equip_wtype_ok?(16) and !@subject.state?(221) 
    end   
    if @subject.state?(114)
       @nn = -2 
       @nn = -1 if @subject.equip_wtype_ok?(16) and !@subject.state?(221)  
    end   
    _times = item.repeats
    if _times != nil 
       _times = 1  if _times < 1
    else
      _times = 1  
    end
    if item.is_atk?
      if @subject.actor?
        weapon = @subject.weapon
        _times = 2 if @subject.equip_wtype_ok?(5) #weapon && weapon.is_bow?
        _times = 1 if @subject.equip_wtype_ok?(16) and !@subject.state?(221)
                   if @subject.state?(114) #马岱攻击三次
                      _times = 3 
                      _times = 2 if @subject.equip_wtype_ok?(16) and !@subject.state?(221)  
                   end      
        _times += @two_atk
      else
        _times = 2 if @subject.equip_wtype_ok?(5)
        _times = 1 if @subject.equip_wtype_ok?(16) and !@subject.state?(221)
        _times += @two_atk
      end
    end
    return if @subject.current_action.nil?

    _times.times do |n|
      # 多次攻击同一个目标 但已经死亡的情况下 重新生成目标表
      if n > 0
        # 全灭中断
        break if @subject.opponent_unit.all_dead? || @subject.dead? || @subject.current_action.nil?
        @nn += 1 
        if item.is_atk? && targets.first.dead? && @subject.opponents_unit.alive_members.size > 0
           targets = @subject.current_action.make_targets.compact
        end

      end
      bskill_end_bls(targets) #步练师每次行动前
      return if $game_party.alive_members.size == 0 or $game_troop.alive_members.size == 0 #步练师处理后，胜利的话要跳出
      show_animation(targets, item.animation_id,[:start,:cancel].include?(BattleManager.all_atk) ? true : false, item)
      wait_for_animation

      p "Party 八卦阵 -> #{$game_party.alive_gate ? $game_party.alive_gate.index : '无'}"
      p "Troop八卦阵 -> #{$game_troop.alive_gate ? $game_troop.alive_gate.index : '无'}"
      @kill_audio = true #允许播放击杀语音，用于多目标计策，同时击杀多个武将后，重复说击破敌将，只说一次。
      # 处理伤害
      targets.each do |target|
        # 死亡动画
        show_dead_and_alive_animation target,item
        bskill_end_CH(target)
        over_damge_add(targets,target,item)
        return if @subject.dead?
      end
        akt_remove_state(targets,item)
        bskill_end_cnj(targets,item)
        bskill_end_93(item)
        #糜竺
        bskill_end_46(targets,item)
        bskill_end_48(targets)
        process_event_in_time(targets,item)
    end

 
 #if  @actor_2nd == @subject and @subject.actions.size > 0
  #msgbox "觉醒"
#end
         #步练
          # bskill_end_bls

  end

  def show_dead_and_alive_animation target,item
    # if target.dead?
    #   msgbox "#{target.name} -> 死亡了, bitmap状态：#{target.bitmap_state}"
    # end
    if target.dead? && ( target.bitmap_state == :normal or target.bitmap_state == :jing )
       dead_face(target) if target.actor?
       target.set_animation(:dead)
       target.animation_id = RPG::Animation::DEAD_ID
       target.change_btm_st :dead
       wait_for_animation
    end
    
      #阴魂娃娃
    if target.dead? and target.actor?#&& ( target.bitmap_state == :normal or target.bitmap_state == :jing )
         if target.equips.include?($data_armors[389])
            alive_face(target) if target.actor?
            target.result.critical = false
            target.result.hp_damage = (target.mhp*(target.element_rate(30)-1)).to_i
            target.mp += (target.mmp*(target.element_rate(30)-1)).to_i
            target.animation_id = 268
            wait_for_animation
            target.set_animation(:alive)
            #target.animation_id = RPG::Animation::ALIVE_ID
            target.change_btm_st :alive
            wait_for_animation
            target.discard_equip($data_armors[389])
            return
          end
           #傀儡娃娃
           if target.equips.include?($data_armors[388])
              target.discard_equip($data_armors[388])
              @wawa = true
           end
     end
   

    if !item.nil? && item.damage.element_id == 9 && target.bitmap_state == :dead
      alive_face(target) if target.actor?
      target.set_animation(:alive)
      target.animation_id = RPG::Animation::ALIVE_ID
      target.change_btm_st :alive
      wait_for_animation
      return
    end

    # 死亡时阵型候散开
    #p "行动者#{@subject.name}是否死亡 -> #{@subject.dead? ? '是' : '否'}"
    #p "目标#{target.name}是否死亡 -> #{target.dead? ? '是' : '否'}"
    [@subject,target].each do |_battler|
      if _battler.dead? 
        _unit = _battler.unit

        if _unit.formation?
          if _unit.is_bagua
            if _unit.alive_gate.eql?(_battler)
              formation_sankai!(_unit)
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          else
            formation_sankai!(_unit) if !_unit.can_use_formation?
          end
        end

      end
    end #do end
  end #def end

  # 阵型散开
  def formation_sankai!(_unit)
    jing_over(_unit)
    BattleFiber.fast_create_formation _unit, RPG::Skill::DEFAULT_FORMATION_ID
    wait_for_animation
    wait(30) #速速太快阵法解散后上前一步会错位
    # show_formation_animation(_battler.unit.members, 4, [:start,:cancel].include?(BattleManager.all_atk) ? true : false, item)
  end
  #--------------------------------------------------------------------------
  # ● 发动技能／物品
  #--------------------------------------------------------------------------
  def invoke_item(target, item)
    update_basic
    
    if rand < target.item_cnt(@subject, item) and !@subject.equip_wtype_ok?(37) and item.id != 177 and item.id != 188
      # 普通攻击反击
      invoke_counter_attack(target, item)
      r = "counter_attack"
    elsif 1.0 < target.item_mrf(@subject, item) and !item.is_hp_recover_marv? and !item.is_buff_marv?
      if item.is_hp_damage_marv? 
         invoke_magic_reflection(target, item)
      else
         apply_item_effects(apply_substitute(target, item), item) 
      end
    elsif 1.0 == target.item_mrf(@subject, item) and item.is_hp_damage_marv? and !item.is_hp_recover_marv? and !item.is_buff_marv?
      # 技能反射
      invoke_magic_reflection(target, item)
    elsif 1.0 > target.item_mrf(@subject, item) and  0.01 <= target.item_mrf(@subject, item) and !item.is_hp_recover_marv? and !item.is_buff_marv?
      # 技能免疫
      invoke_magic_reflection(target, item)  
    else
      # 应用物品效果  apply_substitute 为保护弱者（存在弱者返回弱者，否则返回原 target）
      apply_item_effects(apply_substitute(target, item), item)
      r = "normal"
    end
    @subject.last_target_index = target.index
    r
  end
  #--------------------------------------------------------------------------
  # ● 应用技能／物品效果
  #--------------------------------------------------------------------------
  def apply_item_effects(target, item)
    update_basic
    # 计算物品技能是否有效,是否命中 和 伤害值 是否暴击等等
    target.item_apply1(@subject, item)
    refresh_status
    # @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # ● 发动反击
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    update_basic
    # @log_window.display_counter(target, item)
    attack_skill = $data_skills[target.attack_skill_id]
    @subject.item_apply(target, attack_skill)
    refresh_status
    # @log_window.display_action_results(@subject, attack_skill)
  end
  #--------------------------------------------------------------------------
  # ● 发动反射魔法攻击
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    update_basic
    # @log_window.display_reflection(target, item)
      apply_item_effects(@subject, item)
  end
  #--------------------------------------------------------------------------
  # ● 应用保护弱者
  #--------------------------------------------------------------------------
  def apply_substitute(target, item)
    update_basic
    if check_substitute(target, item)
      substitute = target.friends_unit.substitute_battler
      if substitute && target != substitute
        # @log_window.display_substitute(substitute, target)
        return substitute
      end
    end
    target
  end
  #--------------------------------------------------------------------------
  # ● 检查是否能使用保护弱者
  #--------------------------------------------------------------------------
  def check_substitute(target, item)
    update_basic
    # hp 小于 1/4 的情况下为弱者
    target.hp < target.mhp / 4 && (!item || !item.certain?)
  end


  #--------------------------------------------------------------------------
  # ● 显示动画
  #     targets      : 目标的数组
  #     animation_id : 动画 ID（-1: 与普通攻击一样）
  #--------------------------------------------------------------------------
  def show_animation(targets, animation_id,allatk=false,item=nil)
    item = @subject.current_action.item if item.nil?
    # 普通攻击
    if animation_id == RPG::Animation::ACTOR_ATK_ID
      p "当前行动 -> 攻击"
      show_attack_animation(targets,allatk,item)
    # 防御
    elsif animation_id == RPG::Animation::GUARD_ID
      p "当前行动 -> 防御"
      show_guard_animation(targets,allatk,item)
    else

      # 道具 - 后退 - 等待 - 使用道具公共动画 - 使用道具动画 - 等待动画 - 对象动画 
      if item.is_a?(RPG::Item)
        p "当前行动 -> 道具"
        show_item_animation(targets, animation_id, allatk, item)
      end

      if item.is_a?(RPG::Skill)
        # 技能 - 上前 - 等待 - 使用技能公共动画 - 显示技能动画 - 显示技能特殊动画 - 对象动画
        if item.is_skill?
          p "当前行动 -> 技能"
          show_skill_animation(targets, animation_id, allatk, item)
        end

        # 计策 - 上前 - 等待 - 显示计策公共动画 - 显示计策动画 - 对象动画
        if item.is_marv?
          p "当前行动 -> 计策"
          show_marv_animation(targets, animation_id, allatk, item)
        end

        # 阵型 - 显示阵型公共动画 - 等待 - 显示阵型特殊动画 - 设置动画ID - 设置新阵型ID - 处理特殊阵型
        if item.is_formation?

          p "当前行动 -> 阵型"
          #移除八卦所有状态
          if @subject.actor?
            for i in 0...$game_party.alive_members.size
              for state_id in [14,15,288,289,290,291,292,293,294,295]
                $game_party.alive_members[i].remove_state(state_id) 
              end 
            end
          else
            for i in 0...$game_troop.alive_members.size
              for state_id in [14,15,288,289,290,291,292,293,294,295]
                $game_troop.alive_members[i].remove_state(state_id)
              end
            end
          end

          show_formation_animation(@subject.unit.battle_members, animation_id, allatk, item)
          @subject.unit.clear_bagua!
          @subject.unit.formation_id = item.id

          party_spc_effect(@subject, item, targets)
        end
        wait_for_animation
      end

      # if item.is_a?(RPG::Skill) 
      #   if item.is_skill?
      #     # if allatk
      #     #   show_normal_animation(targets,RPG::Animation::ALL_ATK_ID,false,false)
      #     # else
      #     #   show_normal_animation([@subject], animation_id,false,false)
      #     #   show_normal_animation(targets, animation_id+1,false,false)
      #     # end
      #   elsif item.is_marv?
      #     # targets.each do |target|
      #     #   update_basic
      #     #   if target.result.missed
      #     #     if !item.damage.recover?
      #     #       target.set_animation(:marv_miss,@subject)
      #     #     end
      #     #   end
      #     # end
      #     # if allatk
      #     #   show_normal_animation(targets,RPG::Animation::ALL_ATK_ID,false,true,@subject)
      #     # else
      #     #   show_normal_animation(targets, animation_id,false,true,@subject)
      #     # end
      #   else
      #     show_normal_animation(targets, animation_id)
      #   end
      # else
      #   show_normal_animation(targets, animation_id)
      # end
    end
    # @log_window.wait

    wait_for_animation
    if item.is_a?(RPG::Item) || (item.is_a?(RPG::Skill) && !item.is_formation? && !item.is_atk?) && !allatk
      wait 8

      @subject.animation(:back) if @subject.animation_tag == :forward

      wait 24
    end
  end

  

  
  #--------------------------------------------------------------------------
  # ● 显示攻击动画
  #     targets : 目标的数组
  #    是角色的时候考虑双持武器的效果（反转动画显示左手武器）。
  #    是敌人的时候，在那一瞬间，播放“敌人普通攻击”的声效。
  #--------------------------------------------------------------------------
  def show_attack_animation(targets, allatk=false, item=nil)
    item = @subject.current_action.item if item.nil?
    target = targets.first
    opponent_unit = target.unit

    id1 = @subject.atk_animation_id
    id2 = @subject.atk_animation_id + 1

    # 普通攻击
    unless allatk
      # 处理普通攻击正常
      @subject.set_animation(:atk)
      if  targets[0].cnt >= 1  and ( @subject.actor? && targets[0].actor? ) == false and ( @subject.enemy? && targets[0].enemy? ) == false && !@subject.equip_wtype_ok?(37)
        #if target.eql?(opponent_unit.alive_gate) and !targets[0].state?(24) and !targets[0].state?(25)
          # msgbox "攻击了生门 -> #{target.name}"
        #else
          # msgbox "攻击了死门 -> #{target.name}"
           animation_1212
           show_subject_animation(@subject,   id1 , :atk ,false, false, item)

           if @subject.equip_wtype_ok?(5)
                 if targets[0].state?(290) or targets[0].state?(291) 
                    show_state_animation(targets, 83, mirror = false)
                 else
                    show_state_animation(targets, 75, mirror = false)
                 end   
           else
              if @subject.actor?
                 targets[0].animation1_name =  "#{@subject.id}" 
              else
                 if @subject.element_rate(45) != 1
                    targets[0].animation1_name = "DM#{(@subject.element_rate(45)*100).round}" 
                 else
                    targets[0].animation1_name = "DM#{@subject.id}"
                 end
                    targets[0].animation1_name = targets[0].animation1_name + "-q" if @subject.equip_wtype_ok?(31)  
              end
              

              if @subject.actor?
                 if targets[0].state?(290) or targets[0].state?(291) 
                    show_state_animation(targets, 81, mirror = false)
                 else
                    show_state_animation(targets, 74, mirror = false)
                 end   
              else
                 if targets[0].state?(290) or targets[0].state?(291) 
                    show_state_animation(targets, 82, mirror = false)
                 else
                    show_state_animation(targets, 76, mirror = false)
                 end  
              end
           end
           target.result.missed = false
           target.result.evaded = false

          #target.animation_id = 74#476

          wait_for_animation

          @subject.animation1_name = "#{@subject.id}"
          @subject.animation2_name = "#{@subject.id}"
          show_normal_animation([@subject],   59, :atk, false, true, item)
          target.over_damage += @subject.result.hp_damage #伤害统计计算，反向
          return
      end 

      #击免
      if targets[0].cnt >= 0.01 and targets[0].cnt <= 0.5 and ( @subject.actor? && targets[0].actor? ) == false and ( @subject.enemy? && targets[0].enemy? ) == false && !@subject.equip_wtype_ok?(37)
        animation_1212
        show_subject_animation(@subject,   id1 , :atk ,false, false, item)

        if @subject.equip_wtype_ok?(5)  
           if targets[0].state?(290) or targets[0].state?(291) 
              show_state_animation(targets, 83, mirror = false)
           else
              show_state_animation(targets, 78, mirror = false)
           end   
        else 
          if @subject.actor?
            targets[0].animation1_name =  "#{@subject.id}" 
          else
            if @subject.element_rate(45) != 1
              targets[0].animation1_name = "DM#{(@subject.element_rate(45)*100).round}" 
            else
              targets[0].animation1_name = "DM#{@subject.id}"
            end
              targets[0].animation1_name = targets[0].animation1_name + "-q" if @subject.equip_wtype_ok?(31)  
          end

          if @subject.actor?
              if targets[0].state?(290) or targets[0].state?(291) 
                 show_state_animation(targets, 81, mirror = false)
              else
                 show_state_animation(targets, 77, mirror = false)
              end   
          else
              if targets[0].state?(290) or targets[0].state?(291) 
                 show_state_animation(targets, 82, mirror = false)
              else
                 show_state_animation(targets, 79, mirror = false)
              end   
          end
        end
        target.result.missed = false
        target.result.evaded = false
        wait_for_animation
        return
      end


      if @subject.actor? && target.actor?
        ## 我方自己攻击自己 - 只需显示target动画，动画ID为 ID + 50
        if @subject.eql?(target)
          # 自己攻击自己本人的情况
          @subject.animation1_name = "#{@subject.id}"
          @subject.animation2_name = "#{@subject.id}"
          show_subject_animation(@subject,   id1+50 , :atk ,false, true, item)

          # targets.each { |t| t.animation1_name = "SKL06"; t.animation2_name = nil }
          show_normal_animation(targets,   59, :atk, false, false, item)
        else
          # 攻击自己队友的情况
          @subject.animation1_name = "#{@subject.id}"
          @subject.animation2_name = "#{@subject.id}"
          show_subject_animation(@subject,   id1+50, :atk, false, false, item)

          # targets.each { |t| t.animation1_name = "SKL06"; t.animation2_name = nil }
          show_normal_animation(targets,   59, :atk, false, false, item)
        end
      elsif @subject.enemy? && target.enemy?

        ## 敌方自己攻击自己 - 只需显示target动画，动画ID为 ID + 50
        if @subject.eql?(target)
          # 自己攻击自己本人的情况
          if @subject.element_rate(45) != 1
             @subject.animation1_name = "DM#{(@subject.element_rate(45)*100).round}" 
             @subject.animation2_name = "DM#{(@subject.element_rate(45)*100).round}" 
          else
             @subject.animation1_name = "DM#{@subject.id}"
             @subject.animation2_name = "DM#{@subject.id}"
          end
             @subject.animation1_name = @subject.animation1_name + "-q" if @subject.equip_wtype_ok?(31) 
             @subject.animation2_name = @subject.animation2_name + "-q" if @subject.equip_wtype_ok?(31)   
          show_subject_animation(@subject,   id1+50, :atk, false, true, item)

          # targets.each { |t| t.animation1_name = "SKL06"; t.animation2_name = nil }
          show_normal_animation(targets,   59, :atk, false, false, item)
        else
          # 攻击自己队友的情况
          if @subject.element_rate(45) != 1
             @subject.animation1_name = "DM#{(@subject.element_rate(45)*100).round}" 
             @subject.animation2_name = "DM#{(@subject.element_rate(45)*100).round}" 
          else
             @subject.animation1_name = "DM#{@subject.id}"
             @subject.animation2_name = "DM#{@subject.id}"
          end
             @subject.animation1_name = @subject.animation1_name + "-q" if @subject.equip_wtype_ok?(31) 
             @subject.animation2_name = @subject.animation2_name + "-q" if @subject.equip_wtype_ok?(31)  
          show_subject_animation(@subject,   id1+50, :atk, false, false, item)

          # targets.each { |t| t.animation1_name = "SKL06"; t.animation2_name = nil }
          show_normal_animation(targets,   59, :atk, false, false, item)
        end

      else

        if @subject.state?(149) # 甘宁 水攻击
            if @subject.actor? 
               co_skill = Array.new(@subject.skills)
               co_skill = ( co_skill.delete_if { |item| item.damage.element_id != 2 } ).last
               co_mp = @subject.skill_mp_cost(co_skill) 
               if @subject.mp > co_mp
                  targets[0].make_damage_value(@subject, co_skill)
                  $game_variables[179] = targets[0].result.hp_damage
                  @subject.mp -= co_mp
                  show_subject_animation(@subject, 656, :atk, false, false, item)
                  show_normal_animation(targets,  657, :atk, false, false, item)
                else
                  show_subject_animation(@subject, id1, :atk, false, false, item)
                  show_normal_animation(targets,   id2, :atk, false, false, item)
               end
            else
               if @subject.mp > 100
                  $game_variables[179] = 300+rand(350)
                  @subject.mp -= 100
                  show_subject_animation(@subject, 674, :atk, false, false, item)
                  show_normal_animation(targets,  675, :atk, false, false, item)
               end
            end
        elsif @subject.id == 13 and rand(100) < 25 # 关兴 被动x2
          @subject.add_state_must(119) #攻击提升125% 伤害100/25
          show_subject_animation(@subject, 26, :atk, false, false, item)
          show_normal_animation(targets,   27, :atk, false, false, item)
          @subject.remove_state(119)
        elsif target.actor? and target.id == 64 and rand(100) < 12 and !@subject.equip_wtype_ok?(5) and target.movable? #张辽被动招架
          show_subject_animation(@subject, id1, :atk, false, false, item)
          show_normal_animation(targets,   28, :atk, false, false, item)
        elsif !target.actor? and targets[0].equip_wtype_ok?(10) and rand(100) < 15 and !@subject.equip_wtype_ok?(5) and target.movable? #张辽被动招架-敌人 10为张辽标记
          show_subject_animation(@subject, id1, :atk, false, false, item)
          show_normal_animation(targets,   29, :atk, false, false, item)
        else
          # 正常显示行动方动画 和 对象方动画
          show_subject_animation(@subject, id1, :atk, false, false, item)
          show_normal_animation(targets,   id2, :atk, false, false, item)
        end

      end

    end

    # 总攻处理
    if allatk
      if targets[0].cnt >= 1.0 and ( @subject.actor? && target.actor? ) == false and ( @subject.enemy? && target.enemy? ) == false && !@subject.equip_wtype_ok?(37)
        # 处理总攻八卦阵
        @subject.animation1_name = "#{@subject.id}"
        @subject.animation2_name = "#{@subject.id}"
        show_normal_animation([@subject],   59, :atk, false, true, item)
        target.over_damage += @subject.result.hp_damage #伤害统计计算，反向
        return
      end

      #总攻击免计
      if targets[0].cnt >= 0.01 and targets[0].cnt <= 0.5 and ( @subject.actor? && target.actor? ) == false and ( @subject.enemy? && target.enemy? ) == false && !@subject.equip_wtype_ok?(37)
        show_state_animation(targets, 61, mirror = false) #无闪烁伤害动画
        return
      end
  
      # 处理普通攻击总攻
      @subject.add_state_must(119) if @subject.id == 13 and rand(100) < 25 #关兴被动总攻
      targets[0].add_state_must(126) if targets[0].equip_wtype_ok?(10) and rand(100) < 12 and !@subject.equip_wtype_ok?(5) and target.movable?  #张辽被动总攻

      show_all_atk_normal_animation(targets, :atk, false, item)

      targets[0].remove_state(126) if targets[0].id == 64 #张辽被动总攻
      @subject.remove_state(119) if @subject.id == 13 #关兴被动总攻
      
      bskill_end_yanyu_allatk(target,targets)
      bskill_end_90_allatk(target,targets)
      bskill_end_57_allatk(target,targets)
      bskill_end_215_allatk(target,targets)
      bskill_end_211_allatk(target,targets)
      bskill_end_28_allatk(target,targets)
      bskill_end_10_allatk(target,targets)
      bskill_end_552_b_allatk(target,targets)
      bskill_end_two_atk_allatk(target,targets)#觉醒 最后

    end




    # if @subject.actor?
    #   #p @subject.atk_animation_id1
    #   show_normal_animation([@subject], RPG::Animation::ACTOR_ATK_ID, false, false)
    #   show_normal_animation(targets, RPG::Animation::ACTOR_ATK_HIT_ID, false, false)
    #   #show_normal_animation(targets, @subject.atk_animation_id1, false)
    #   #how_normal_animation(targets, @subject.atk_animation_id2, true)
    # else
    #   show_normal_animation([@subject], RPG::Animation::ENEMY_ATK_ID, false, false)
    #   show_normal_animation(targets, RPG::Animation::ENEMY_ATK_HIT_ID, false, false)
    #   #Sound.play_enemy_attack
    #   #abs_wait_short
    # end
  end
  #--------------------------------------------------------------------------
  # ● 显示防御动画
  #     targets : 目标的数组
  #     animation_id : 动画ID
  #--------------------------------------------------------------------------
  def show_guard_animation(targets,allatk=false,item=nil)
    item = @subject.current_action.item if item.nil?
    invoke_item(@subject, item)
    if allatk
       Audio.se_play("Audio/SE/J_qian",90,75)
       targets[0].sprite_battler.flash(Color.new(255,210,0,255),80)
    else
       show_subject_animation(@subject, RPG::Animation::GUARD_ID, :guard, false, true, item)
    end
    @subject.item_apply2(@subject, item)
    # show_normal_animation(targets, RPG::Animation::GUARD_ID, :guard, false, true, item)
  end
  #--------------------------------------------------------------------------
  # ● 显示使用道具动画
  #     targets : 目标的数组
  #     animation_id : 动画ID
  #--------------------------------------------------------------------------
  def show_item_animation(targets, animation_id, allatk = false,item=nil)
    item = @subject.current_action.item if item.nil?
    @subject.tp -= 100  if item.is_a?(RPG::Item) and item.id == 25 and @subject.actor? #无双印
    unless allatk
      if @subject.id == 45 and @subject.actor? and rand(100) > 60 and !item.key_item?
        # 陈登使用道具的动画不同 = 25
         show_subject_animation(@subject, 25, :item, false, true, item)
         $game_party.gain_item(item, 1) if item.nil?
      else
         show_subject_animation(@subject, RPG::Animation::USE_ITEM_ID, :item, false, true, item)
      end
      if item.id == 29 and item.is_item? 
         show_state_animation_quick(targets, animation_id, false)
         #Audio.se_play("Audio/SE/FC_SQ")
         wait_for_animation
         a = $game_party.boost
           if a >= 100 
              if $game_variables[309] <= 0 and $game_variables[743] == false
                 $game_party.incr_boost 30  
              else
                 if a > 150
                    $game_party.incr_boost (10+rand(10))
                 else
                    $game_party.incr_boost (15+rand(15))
                 end
              end            
           elsif a > 50
              $game_party.incr_boost (((100-a)/100.0)*30+30).to_i  #定军计士气100以下是x2 系数变化
           else
              $game_party.incr_boost (((100-a)/100.0)*35+30+rand(5)).to_i
           end
      else
         show_normal_animation(targets, animation_id, :item, false, false, item)
      end
    else
         show_all_atk_normal_animation(targets, :item, false, item)
    end
  end

  #--------------------------------------------------------------------------
  # ● 显示使用技能动画
  #     targets : 目标的数组
  #     animation_id : 动画ID
  #--------------------------------------------------------------------------
  def show_skill_animation(targets, animation_id, allatk = false, item=nil)
    item = @subject.current_action.item if item.nil?

    unless allatk
      @subject.animation :forward
      wait(20)

      skill_animation1 = lambda do
        @subject.set_animation(:use_skill)
        show_subject_animation(@subject, @subject.actor? ? RPG::Animation::ACTOR_USE_SKILL_ID : RPG::Animation::ENEMY_USE_SKILL_ID, :skill, false, true, item)
      end
      skill_animation2 = lambda do
        show_subject_animation(@subject, animation_id,:skill,false, false, item)
        if targets.map(&:id).include? @subject.id
          wait_for_animation
        end
        @subject.change_btm_st :hid if @subject.element_rate(37) > 1 #杨秋特殊
        show_normal_animation(targets, animation_id+1, :skill, false, false, item)
        bskill_end_yq(targets,item)
      end
      BattleFiber.create_skill :subject=>@subject,:skill_animation1 => skill_animation1,:skill_animation2 => skill_animation2, :wait_for_animation => method(:wait_for_animation) do 
        update_basic
      end
    else
      Audio.se_play("Audio/SE/Skill3",100,75) #总攻敌人使用技能时播放提示音效
      show_normal_animation(targets, RPG::Animation::ALL_ATK_ID, :skill, false, true, item)
      
    end
  end

  #--------------------------------------------------------------------------
  # ● 显示使用计策动画
  #     targets : 目标的数组
  #     animation_id : 动画ID
  #--------------------------------------------------------------------------
  def show_marv_animation(targets, animation_id, allatk = false, item=nil)
    item = @subject.current_action.item if item.nil?
    if item.is_marv? and @subject.actor? and item.id == 231 
       @subject.tp = 99 if @subject.tp == 100
       #@spriteset.refresh_apmask(@subject.index,@subject)
    end

    # 处理计策 miss 特殊动画
    # targets.each do |target|
    #   if target.result.missed && !item.damage.recover?
    #     target.set_animation(:marv_miss,@subject)
    #   end
    # end

    _wait_animation = !RPG::Skill::PARTY_SKILL_IDS.include?(item.id)
    #回复性全体计策不等待。同时播放
    _wait_animation = false if item.is_marv? and item.for_all? and item.for_friend?
    _wait_animation = false if @move_up == 1
    if allatk
      show_all_atk_normal_animation(targets, :marv, _wait_animation, item)
      # show_normal_animation(targets,RPG::Animation::ALL_ATK_ID,:marv,false,true,item)
    else
      if item != nil and item.speed == 55
        @subject.animation :forward 
        wait(20)

        @subject.set_animation(:use_skill)
        show_subject_animation(@subject, @subject.actor? ? RPG::Animation::ACTOR_USE_SKILL_ID : RPG::Animation::ENEMY_USE_SKILL_ID, :skill, false, true, item)
      else 
        show_subject_animation(@subject, @subject.actor? ? RPG::Animation::ACTOR_USE_MARV_ID : RPG::Animation::ENEMY_USE_MARV_ID, :marv,false, true, item) if item.speed != 7 and @move_up != 1
        p "动画ID#{animation_id}是否等待 -> #{_wait_animation}"
      end

      #if item.id == 214 and item.is_marv? 
        #show_state_animation_quick(targets, animation_id, false)
        #wait_for_animation
        #a = $game_party.boost
        #if    a >= 200
              #$game_party.incr_boost (5+rand(5))
        #elsif a >= 150
              #$game_party.incr_boost (10+rand(10))
        #elsif a >= 100
              #$game_party.incr_boost (15+rand(15))  #定军计 
        #else  #定军计士气100以下是x2 系数变化
              #$game_party.incr_boost (((100-a)/100.0)*30+30).to_i
        #end
      if item.id == 215 and item.is_marv? 
        show_state_animation_quick(targets, animation_id, false)
        wait_for_animation
        $game_party.cost_boost (20+rand(10))   #逆军计-35士气  
      elsif item.id == 190 and item.is_marv?   #暗杀计特殊动画处理
        targets_as = []
        targets_as[0] = @subject
        show_state_animation_quick(targets, 448, false)
      for i in 0...70
        wait(1)
      end
        show_normal_animation(targets, animation_id,:marv, false,_wait_animation,item)
      else
        show_normal_animation(targets, animation_id,:marv, false,_wait_animation,item)
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 显示使用阵型动画
  #     targets : 目标的数组
  #     animation_id : 动画ID
  #--------------------------------------------------------------------------
  def show_formation_animation(targets, animation_id, allatk = false, item=nil)
    item = @subject.current_action.item if item.nil?
    unless allatk

      show_formation_obj_animation2 = lambda do
        if @subject.actor? #八卦前置动画。
           show_normal_animation(@subject.unit.alive_members, 475, :formation, false, false, item)  
           wait_for_animation
        else
          a = []
          for i in 0...$game_troop.alive_members.size
            a[i] = $game_troop.alive_members[i] if $game_troop.alive_members[i].index != 5 
          end 
          show_normal_animation(a, 475, :formation, false, false, item)  
        end
          
        wait_for_animation
        #八卦施展后立即添加随机状态
        if item.id == 13
          if @subject.actor?
            $game_party.alive_gate = $game_party.alive_members[rand($game_party.alive_members.size)]
            for i in 0...$game_party.alive_members.size
              if $game_party.alive_members[i].index != $game_party.alive_gate.index
                 $game_party.alive_members[i].add_state_must(rand(8)+288) 
               else
                 $game_party.alive_members[i].add_state_must(14)
               end
            end
                #@actor_window.actor.add_state_must(17)
          else 
            if  $game_troop.alive_members.size == 6
              op = rand(5)
            else
              op = rand($game_troop.alive_members.size)
            end
            for i in 0...$game_troop.alive_members.size
              $game_troop.alive_members[i].add_state_must(rand(10)+288) if i != op and $game_troop.alive_members[i].index != 5 #if $game_troop.alive_members[i].index != $game_troop.alive_gate.index
              $game_troop.set_bagua $game_troop.alive_members[op]
            end
            if $game_switches[446] == true #可以看见敌人生门   
              $game_troop.alive_members[op].add_state_must(14)
            else
              $game_troop.alive_members[op].add_state_must(15)
            end
          end
        end
      end

      show_subject_animation(@subject, RPG::Animation::USE_FORMATION_ID, :formation, false, true, item)
      wait(24)
      jing_clear(@subject.opponent_unit) 
      BattleFiber.create_formation :subject=>@subject,:num=>item.message1,:show_formation_obj_ani=>lambda { show_formation_obj_animation(@subject,targets) }, :show_formation_obj_animation2 => show_formation_obj_animation2 do 
        update_basic
      end
    else
      BattleFiber.create_formation_for_all_atk :subject=>@subject,:num=>item.message1,:show_formation_obj_ani=>lambda { show_formation_obj_animation(@subject,targets) } do 
        update_basic
      end
    end

    if item.id == 19 #云龙启动
      if @subject.actor?
        a = $game_party.alive_members
      else
        a = $game_troop.alive_members
      end
      show_state_animation_quick(a,361,mirror = false) unless BattleManager.all_atk == :start
      wait_for_animation
      if @subject.actor?
        if $game_party.boost < 150
          a = 150 - $game_party.boost
          $game_party.incr_boost a 
        end   
      else
        $game_party.cost_boost 50 
      end
    end

    #寂静阵启动
    if item.id == 12
      a=[]
      w=0
      if @subject.actor?
        wait_for_animation
        for i in 0...$game_party.alive_members.size
          if !$game_party.alive_members[i].state?(5300)
            $game_party.alive_members[i].change_btm_st :normal 
            $game_party.alive_members[i].add_state_must(16)
            a[w] = $game_party.alive_members[i]
            w+=1
          end
        end
        show_state_animation_quick(a,476,mirror = false) unless BattleManager.all_atk == :start
        wait_for_animation
        for i in 0...$game_party.alive_members.size
          if !$game_party.alive_members[i].state?(5300)
            $game_party.alive_members[i].change_btm_st :jing 
          end
        end
      else
        wait_for_animation
        for i in 0...$game_troop.alive_members.size
          if !$game_troop.alive_members[i].state?(5300) and $game_troop.alive_members[i].index != 5
            $game_troop.alive_members[i].change_btm_st :normal 
            $game_troop.alive_members[i].add_state_must(16)
            a[w] = $game_troop.alive_members[i]
            w+=1
          end   
        end
        show_state_animation_quick($game_troop.alive_members,476,mirror = false) unless BattleManager.all_atk == :start
        wait_for_animation
        for i in 0...$game_troop.alive_members.size
          if !$game_troop.alive_members[i].state?(5300) and $game_troop.alive_members[i].index != 5 
            $game_troop.alive_members[i].change_btm_st :jing 
          end
        end
      end
    end
   

    if item.id == 15 #虎伍阵启动
      wait_for_animation
      a=[]
      w=0
      for i in 0...$game_party.alive_members.size
        if !$game_party.alive_members[i].state?(5300)
          $game_party.alive_members[i].add_state_must(13)
          a[w] = $game_party.alive_members[i]
          w+=1
        end
      end
      show_state_animation_quick(a,364,mirror = false) unless BattleManager.all_atk == :start
      wait_for_animation
    end

    # show_normal_animation(targets, animation_id, :formation, false, true, item)
  end

  #--------------------------------------------------------------------------
  # ● 显示行动方动画
  #     subject      : 目标的数组
  #     animation_id : 动画ID
  #     mirror       : 左右反转
  #     wait_ani     : 等待动画播放结束
  #--------------------------------------------------------------------------

  def show_subject_animation(subject,animation_id, type, mirror = false, wait_ani = true, item=nil)
    item = @subject.current_action.item if item.nil?
    if type == :guard
      # targets.first.set_animation(:guard)
      subject.animation :forward
      wait(24)
      subject.set_animation(:guard)
    end
    if type == :item
      subject.animation :forward
      wait(24)
      subject.set_animation(:use_item)
    end
    if type == :marv
       if item.speed != 7 and @move_up != 1
          subject.animation :forward 
       end
      wait(24) 
      subject.set_animation(:use_marv)
    end
    if type == :formation
      subject.animation :forward
      wait(24)

      subject.set_animation(:use_formation)
      # 处理特殊阵型效果(静寂,八卦) 添加队伍状态等
      # subject.spe_formation_effect_apply(item)
      # wait_for_animation
    end

    subject.animation_id = animation_id
    subject.animation_mirror = mirror
            #骑乘技能规则
            if @subject.equip_wtype_ok?(31)  
               an = $data_animations[animation_id].name
               if an.include?("Q-")
                  an = (an.split("Q-").last).to_i
                  subject.animation_id = an
               end
            end
    if wait_ani
       wait_for_animation
    end
    if type == :formation
       subject.animation :back
       wait(24)
    end
  end

  def show_all_atk_normal_animation(targets, type, wait_ani = true, item=nil)
    all_atk_id = RPG::Animation::ALL_ATK_ID
    item = @subject.current_action.item if item.nil?

    targets.each_with_index do |target,index|
      # 发动技能／物品 计算命中率等
      r = invoke_item(target, item)

      if type == :marv
        # 处理计策反弹效果 带有反弹状态 并且 攻击性计策
        if  target.mrf >= 1.0 && item.is_hp_damage_marv? and !item.is_hp_recover_marv? and !item.is_buff_marv? and item.id != 190
          p "总攻策反 -> #{item.name}"
          # subject 身上显示攻击计策动画
          @subject.animation_id = all_atk_id
          target.over_damage += @subject.result.hp_damage #伤害统计计算，反向
          wait_for_animation
          show_dead_and_alive_animation(@subject,item)
          if @subject.dead?
            return
          else
            next
          end
        elsif target.mrf >= 1.0 and target.mrf <= 0.5 && !item.is_hp_damage_marv? and !item.is_hp_recover_marv? and !item.is_buff_marv? and item.id != 190
          @subject.animation_id = 61
          wait_for_animation
          if @subject.dead?
            return
          else
            next
          end
        end
        #总攻策免计
        if target.mrf >= 0.01 and target.mrf <= 0.5 && !item.is_hp_recover_marv? and !item.is_buff_marv? and item.id != 190
          @subject.animation_id = 61
          wait_for_animation
          if @subject.dead?
            return
          else
            next
          end
        end
      end

      if target.result.missed 
        p "总攻MISS -> #{item.name}"
        target.animation_id = 0
        target.sprite_battler.damage("Evaded",false)
        Sound.play_miss
      else
        if item.damage.recover?
          p "【总攻】回复 -> #{item.name}"
          Sound.play_recover
          target.sprite_battler.flash(Color.new(166,252,64,255),80)
          target.hp += target.result.hp_damage
        elsif item.is_atk?
          p "【总攻】攻击 -> #{item.name}"
          target.animation1_name = "SKL06"
          target.animation2_name = nil
          target.animation_id = all_atk_id
        elsif item.is_marv?
          p "【总攻】策略 -> #{item.name}"
                #邓艾被动总攻
                if target.equip_wtype_ok?(29) and target.hp > 0
                if !item.nil? && item.is_a?(RPG::Skill) && item.is_marv? && !item.damage.recover? && item.for_opponent?
                if target.actor?
                   if ((100-target.hp.to_f/target.mhp*100)*0.35).round(0) > rand(100) 
                      target.animation_id = 0
                      target.sprite_battler.damage("Evaded",false)
                      Sound.play_miss
                      return
                   end
                else
                   if ((100-target.hp.to_f/target.mhp*100)*0.50).round(0) > rand(100) 
                      target.animation_id = 0
                      target.sprite_battler.damage("Evaded",false)
                      Sound.play_miss
                      return
                   end
               end
               end
               end
           if item.damage.type == 1
              target.animation1_name = "SKL06"
              target.animation2_name = nil
              target.animation_id = all_atk_id
           elsif item.for_friend?
              target.sprite_battler.flash(Color.new(255,237,38,255),80)
           else
              target.sprite_battler.flash(Color.new(163,97,253,255),80)   
           end
          Sound.play_marv
        elsif item.is_formation?
          p "【总攻】阵型 -> #{item.name}"
          #target.sprite_battler.flash(Color.new(253,97,193,255),80)
          #Audio.se_play("Audio/SE/fcmove")
        else
          p "【总攻】剩余 -> #{item.name}"
          target.sprite_battler.flash(Color.new(200,0,0,255),80)
          # 全队计策的情况下 只播放一次音效
          Sound.play_marv if !wait_ani && index == 0
          # wait(22) if wait_ani
        end
      end

      if wait_ani
        wait_for_animation 
        # 如果死亡或复活 则显示动画
        show_dead_and_alive_animation(target,item)
        p "等待"
      else
        p "不等待"
      end
      # 扣除TP,MP等
      target.item_apply2(@subject, item)

    end

    # 特殊全队计策使用后效果
    party_spc_effect(@subject, item, targets)

  end

  #--------------------------------------------------------------------------
  # ● 显示对象方动画
  #     targets      : 目标的数组
  #     animation_id : 动画ID
  #     mirror       : 左右反转
  #     wait_ani     : 等待动画播放结束
  #--------------------------------------------------------------------------
  def show_normal_animation(targets, animation_id, type, mirror = false, wait_ani = true, item=nil)
    item = @subject.current_action.item if item.nil?
    animation = $data_animations[animation_id]
 
    #黄盖和貂蝉武将技，重置刷新，避免无限使用时，控制所有敌军，导致无敌。
    if @subject.id == 70 and item.id == 380 and item.is_skill?  
       @subject.opponents_unit.alive_members.each do |u|
          u.remove_state(117)
       end
    end
    if @subject.id == 92 or @subject.id == 595 or @subject.id == 315 and item.is_skill?  
       @subject.add_state_must(118)  
       @subject.opponents_unit.alive_members.each do |u|
          u.remove_state(232)
       end
    end  

    if animation
      targets.each_with_index do |target,index|

        # 发动技能／物品 计算命中率等
        r = invoke_item(target, item)
        
        if type == :marv
          # 处理计策反弹效果 带有反弹状态 并且 攻击性计策
         if target.mrf >= 1.0 && item.is_hp_damage_marv? and !item.is_hp_recover_marv? and !item.is_buff_marv? and item.id != 190
            # 对象身上显示反弹动画
              if  target.state?(288) or target.state?(289) 
                  target.animation_id = 123
              else
                  target.animation_id = 121
              end   
            target.over_damage += @subject.result.hp_damage #伤害统计计算，反向
            wait_for_animation
            # subject 身上显示攻击计策动画
            @subject.animation_id = animation_id
            wait_for_animation
            show_dead_and_alive_animation(@subject,item)
            if @subject.dead?
              return
            else
              next
            end
          elsif target.mrf >= 1.0 and target.mrf <= 0.5 && !item.is_hp_damage_marv? and !item.is_hp_recover_marv? and !item.is_buff_marv? and item.id != 190
              if  target.state?(288) or target.state?(289) 
                  target.animation_id = 123
              else
                  target.animation_id = 122
              end 
             wait_for_animation
              if @subject.dead?
              return
            else
              next
            end
          end

          #策免
          if target.mrf >= 0.01 and target.mrf <= 0.5 && !item.is_hp_recover_marv? and !item.is_buff_marv? and item.id != 190
              if  target.state?(288) or target.state?(289) 
                  target.animation_id = 123
              else
                  target.animation_id = 122
              end 
             wait_for_animation
              if @subject.dead?
              return
            else
              next
            end
          end  

          if target.result.missed && !item.damage.recover?
             target.set_animation(:marv_miss,@subject)
          end

        end

        if type == :atk
          # 攻击本人判断
          if (target.actor? && @subject.actor?) || (target.enemy? && @subject.enemy?)
            target.animation1_name = "SKL06"
            target.animation2_name = nil
          else
            target.set_animation(target.result.missed ? :miss : :hit ,@subject)
          end
        end

        if type == :skill
        end
        if type == :item
        end
        if type == :formation
        end
        if type == :guard
        end

        target.animation_id = animation_id
           #骑乘技能规则
           if @subject.equip_wtype_ok?(31)  
               an = $data_animations[animation_id].name
               if an.include?("Q-")
                  an = (an.split("Q-").last).to_i
                  target.animation_id = an
               end
            end
            #邓艾被动
            if target.equip_wtype_ok?(29) and target.hp > 0
            if !item.nil? && item.is_a?(RPG::Skill) && item.is_marv? && !item.damage.recover? && item.for_opponent?
               if target.actor?
                  if ((100-target.hp.to_f/target.mhp*100)*0.35).round(0) > rand(100) 
                     target.animation_id = 973 
                  end
               else
                  if ((100-target.hp.to_f/target.mhp*100)*0.50).round(0)  > rand(100) 
                     target.animation_id = 974
                     target.animation_id = 975 if target.equip_wtype_ok?(31)  #骑乘邓艾
                  end
               end
            end
            end


        if target.result.missed
          # 对象显示攻击miss动画为 击中动画 id + 1
          if animation.is_atk_target_ids?
            target.animation_id += 1
          end
          # 计策MISS的情况下 并且 不是回复性计策
          if !item.nil? && item.is_a?(RPG::Skill) && item.is_marv? && !item.damage.recover?
            #if item.is_hp_damage_marv?
              # 攻击性计策的情况 - 显示回避动作
              target.animation_id = RPG::Animation::ACTOR_MISS_ID if target.actor?
              target.animation_id = RPG::Animation::ENEMY_MISS_ID if !target.actor?
            #else
              # 非攻击性计策的情况显示MISS字样
              #target.animation_id = 0
              #target.animation_id = RPG::Animation::ACTOR_MISS_ID if target.actor?
              #target.animation_id = RPG::Animation::ENEMY_MISS_ID if !target.actor?
              #target.sprite_battler.damage("Evaded",false)
              #Sound.play_miss
            #end
          end
        end
        target.animation_mirror = mirror
        if wait_ani
          wait_for_animation unless animation.to_screen?
          # 如果死亡或复活 则显示动画
          show_dead_and_alive_animation(target,item)
        end

        if item.for_one?
           wait_for_animation unless BattleManager.all_atk == :start
        end
        # 扣除TP,MP等
        target.item_apply2(@subject, item)
        
         # 最后一个动画强制等待
        if index == targets.size - 1
           wait_for_animation unless BattleManager.all_atk == :start
        end
        #周瑜被动，计策灼伤
        bskill_end_58(target,type,item)
        #郭嘉被动，计策冰玉
        bskill_end_29(target,type,item)
        #张苞50%晕眩
        bskill_end_15(target,type,item)
        bskill_end_16(target,type,item)
        bskill_end_59(target,type,item)
        #星彩速度提升最大
        bskill_end_18(target,type,item)
        #庞统被动，计策后状态
        bskill_end_24(target,type,item)
        #黄浩
        bskill_end_552(target,type,item)
        #书
        bskill_end_book(target,type,item)
        #盗贼抢夺
        bskill_end_52(target,type,item)
        #天罡杖
        bskill_end_tgz(target,item)
      end

      #周瑜被动，技能灼伤
      if ( @subject.id == 58 or @subject.id == 312 ) and type == :skill
        wait(105)
        targets.each_with_index do |target,index|
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0 
          target.result.critical = false
          targets2 = []
          targets2[0] = target
          targets2[0].result.hp_damage = target.result.hp_damage/10
          if BattleManager.all_atk == :start
            show_state_animation(targets2, 58, mirror = false)
          else
            show_state_animation(targets2, 307, mirror = false)
          end
            wait(25)
          end
        end
      end


      #吕布晕眩35%
      if ( item.id == 377 or item.id == 463 ) and type == :skill
        wait(35)
        targets.each_with_index do |target,index|
          if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0 
            targets2 = []
            targets2[0] = target
            if targets2[0].state?(116)
              show_state_animation(targets2, 313, mirror = false) unless BattleManager.all_atk == :start
            end
          end
        end
      end

      #晕锤
      bskill_end_8(@subject,targets,type)
      #马谡麻痹
      bskill_end_57(@subject,targets,type)
      #文鸯
      bskill_end_215(targets,type)
      #甘宁被动水
      bskill_end_93_marv(targets,item)
      #司马昭
      bskill_end_211(targets,type)
      #吸血
      bskill_end_90(targets,type,item)
      #吸收黄浩
      bskill_end_552_b(targets,type)
      #解阵计for寂静
      bskill_end_jz_jing(targets,type,item)
      #回射
      bskill_end_10(targets,type)
      #再动
      bskill_end_two_atk(@subject,targets,type)
      #钟会
      bskill_end_540(targets,type,item)

      abs_wait_short if animation.to_screen?

      # 特殊全队计策使用后效果
      party_spc_effect(@subject, item, targets)

      #玉石效果
      bskill_end_yushi_buff(@subject,targets,type)
      #左慈
      bskill_end_28(@subject,targets,type)

      #司马懿昼夜
      sima_open(type,item)
      #孔明天变
      bskill_end_23(type,item)

    end

     #if item.id == 344 and item.is_skill?
     #wait_for_animation
     #$game_party.incr_boost 50  #法正主动技能效果
     #end

  end

  def party_spc_effect(subject, item, targets)
    if item.is_marv?
      # 解阵计  3个人以上命中，解开，可累计。
      if item.id == 198
        opponent_unit = subject.opponent_unit
        bj = 0

        if subject.actor? 
          for i in 0...$game_troop.alive_members.size
            bj += 1 if $game_troop.alive_members[i].state?(53)
          end
        else
          for i in 0...$game_party.alive_members.size
            bj += 1 if $game_party.alive_members[i].state?(53)
          end
        end

        if opponent_unit.formation? and bj >= 3
          if subject.actor?
            for i in 0...$game_troop.alive_members.size
              $game_troop.alive_members[i].add_state_must(53)
            end
          else
            for i in 0...$game_party.alive_members.size
              $game_party.alive_members[i].add_state_must(53)
            end
          end

          wait_for_animation
          formation_sankai!(opponent_unit)
        end
      end
      # 解策计
      if item.id == 199
        subject.unit.clear_jc_states!
      end
    end
  end

  def show_formation_obj_animation(subject,targets)
    update_basic
    targets.each_with_index do |target,index|
      next if target.dead?
      target.set_animation(:formation_object)
      target.animation_id = RPG::Animation::FORMATION_OBJECT_ID + index
      #wait 22
    end
  end
end



