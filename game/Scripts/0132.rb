#encoding:utf-8
#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　菜单画面
#==============================================================================
class Scene_Menu < Scene_MenuBase 
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    team_ac_check
    super
    @ok = 0
    @status_window_open = 0
    @effect = 0
    @actorrr = Array.new 
    for i in 0...$game_party.members.size
      @actorrr[i] = $game_party.members[i].id 
    end

    @flash = 0 ; @c = 0
    @nx = 0
    @xbit = 0
    @scene_map_calling = false
    create_gold_window
    create_command_window
    create_yesno_window
    create_status_window
    battler_picture

    @di = Sprite.new
    @di.bitmap = Cache.system("d01")

    @come = Sprite.new
    @come.bitmap = Cache.system("come"+"#{$game_variables[99]}")
    @come.x = 557
    @come.y = 115

    @expbook_s_back = Sprite.new
    @expbook_s_back.bitmap = Cache.system("expbook_s_back")
    @expbook_s_back.x = 446
    @expbook_s_back.y = 158

    @expbook_s = Sprite.new
    @expbook_s.bitmap = Cache.system("expbook_s")
    @expbook_s.x = 456+43
    @expbook_s.y = 158+7
    a =  $game_variables[230]+1
    a =  a * a * 10000.0
    expbook = ($game_party.expbook / a * 344.0).to_i
    expbook = 344 if $game_party.expbook > a
    @expbook_s.src_rect = Rect.new(0,0,expbook,6)

    @expbook_text = Sprite.new
    @expbook_text.bitmap = Bitmap.new(100,40)
    @expbook_text.x = 456+43+237
    @expbook_text.y = 157
    @expbook_text.bitmap.font.size = 17 + $game_variables[300]
    @expbook_text.bitmap.font.name  = (["Noto"])
    @expbook_text.bitmap.draw_text(0,0,100,20,"#{($game_party.expbook).to_i}",2)
    @expbook_text.z = 500

    @fa = Sprite.new
    @fa.bitmap = Bitmap.new(37,50)
    @fa.x = 451 ; @fa.y = 103 ; @fa.z = 500
    case $game_variables[108]
    when 4  ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(0, 0,37,50))
    when 5  ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37,0,37,50))
    when 6  ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*2,0,37,50))
    when 7  ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*3,0,37,50))
    when 8  ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*4,0,37,50))
    when 9  ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*5,0,37,50))
    when 10 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*6,0,37,50))
    when 11 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*7,0,37,50))
    when 14 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*8,0,37,50))
    when 16 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*9,0,37,50))
    when 17 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*10,0,37,50))
    when 18 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*11,0,37,50))
    when 21 ; @fa.bitmap.blt(0,0,Cache.hp("fa"),Rect.new(37*12,0,37,50))
    end

    @flash_bmp = Sprite.new
    @flash_bmp.attrset(:x=>0,:y=>0,:z=>98,:opacity=>0,:bitmap=>Cache.flash("d00"))

    @temp_members = []
  end

  def hide_expbook
    @expbook_s_back.opacity = 0
    @expbook_s.opacity = 0
    @expbook_text.opacity = 0
  end

  def show_expbook
    @expbook_s_back.opacity = 255
    @expbook_s.opacity = 255
    @expbook_text.opacity = 255
  end

  def create_yesno_window
    @cmd_yesno = Window_MenuCommandYesno.new(0,200)
    @cmd_yesno.set_handler(:yes,   method(:command_exit_yes))
    @cmd_yesno.set_handler(:no,   method(:command_exit_no))
  end

  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.y -= 33
    @command_window.set_handler(:status,   method(:command_personal))
    @command_window.set_handler(:item,     method(:command_item))
    @command_window.set_handler(:marv,     method(:command_personal))
    @command_window.set_handler(:skill,    method(:command_personal))
    @command_window.set_handler(:equip,    method(:command_personal))
    @command_window.set_handler(:dl,       method(:command_personal))
    @command_window.set_handler(:formation,method(:command_personal))
    @command_window.set_handler(:cj,       method(:command_cj))
    @command_window.set_handler(:system,   method(:command_system))
    @command_window.set_handler(:save,       method(:command_save))
    @command_window.set_handler(:exit,       method(:command_game_end))
   # @command_window.set_handler(:system,   method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● 激活状态窗口
  #--------------------------------------------------------------------------
  def activate_status_window(index = 0)
    command_personal
    #@status_window.index = index
  end
  #--------------------------------------------------------------------------
  # ● 生成金钱窗口
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.x = 454
    @gold_window.y = 170 #Graphics.height - @gold_window.height
    @gold_window.contents.font.size = 17 + $game_variables[300]
    @gold_window.contents.clear 
    @gold_window.draw_text(0+32,0-4, 90, @gold_window.line_height, $game_party.gold, 0)
  end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_MenuStatus.new(0, 0)
    @status_window.refresh_jm_icon
  end
  #--------------------------------------------------------------------------
  # ● 指令“物品”
  #--------------------------------------------------------------------------
  def command_item
    SceneManager.call(Scene_Item)
  end
  #--------------------------------------------------------------------------
  # ● 指令“造诣”告诉玩家当前的事件
  #--------------------------------------------------------------------------
   def command_cj
    SceneManager.call(Scene_Cj)
  end

  #--------------------------------------------------------------------------
  # ● 指令“系统”
  #--------------------------------------------------------------------------
   def command_system
    SceneManager.call(Scene_System)
  end

  #--------------------------------------------------------------------------
  # ● 指令“技能”“装备”“状态”
  #--------------------------------------------------------------------------
  def command_personal
    @gold_window.visible = false
    @status_window.index = 0
    if @ok == 1

    else
      @command_window.set_handler(:dl,       method(:command_personal))

      if @command_window.current_symbol == :dl && $game_party.actors.size <= 1
        @status_window.unselect
        @status_window_open = 0
        @command_window.activate
        # @gold_window.visible = true
        return
      end

      @status_window.select_last
      @status_window.activate
      @status_window_open = 1
      @status_window.set_handler(:ok,     method(:on_personal_ok))
      @status_window.set_handler(:cancel, method(:on_personal_cancel)) 


      if @command_window.current_symbol == :dl
        @flash_bmp.bitmap = Cache.flash("new_team")
      end
      @status_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令“阵型”
  #--------------------------------------------------------------------------
  def command_formation
    @battler_sprite_acc.opacity = 255
    @status_window.select_last
    @status_window.activate
    @status_window_open = 1
    @status_window.set_handler(:ok,     method(:on_formation_ok))
    @status_window.set_handler(:cancel, method(:on_formation_cancel))
    @status_window.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 指令“存档”
  #--------------------------------------------------------------------------
  def command_save
    if $TEST
      SceneManager.call(Scene_Save)
    else
      SceneManager.call(Scene_Load)
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令“结束游戏”
  #--------------------------------------------------------------------------
  def command_game_end
    @command_window.deactivate
    @cmd_yesno.show
  end
  
  def command_exit_yes
    RPG::BGM.fade(60)
    RPG::BGS.fade(60)
    RPG::ME.fade(60)
    Graphics.fadeout(60)
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
    terminate
    exit
  end

  def command_exit_no
    @cmd_yesno.hide
    @command_window.activate
  end



  #--------------------------------------------------------------------------
  # ● 个人指令“确定”
  #--------------------------------------------------------------------------
  def on_personal_ok
    if @ok == 1
      SceneManager.call(Scene_Menu) 
    else
      case @command_window.current_symbol
      when :marv
        SceneManager.call(Scene_Marv)
      when :skill
        SceneManager.call(Scene_Skill)
      when :equip
        SceneManager.call(Scene_Equip)
      when :status
        SceneManager.call(Scene_Status)
      when :dl
        @ci = $game_party.members.size - 1
        refresh_dl_status_window
      when :formation
        SceneManager.call(Scene_Formation)
      when :cj
        SceneManager.call(Scene_Cj)
      when :system
        SceneManager.call(Scene_Cj)
      when :save
        #SceneManager.call(Scene_Load)
         SceneManager.call($TEST ? Scene_Load : Scene_Save)
      end
    end   
  end

  #----------------------------------------------------------------------
  # 队列菜单
  #----------------------------------------------------------------------
  def refresh_dl_status_window
    index = @status_window.index 
    case @ci 
    when 6
      if @actorrr[6] != nil     
        @battler_sprite_6.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
        @battler_sprite_6.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
        @battler_sprite_6.src_rect = Rect.new(0,0,192,192)
        @battler_sprite_6.x=390+40
        @battler_sprite_6.y=41+82
      end
    when 5
      if @actorrr[5] != nil 
        @battler_sprite_5.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
        @battler_sprite_5.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
        @battler_sprite_5.src_rect = Rect.new(0,0,192,192)
        @battler_sprite_5.x=430+50
        @battler_sprite_5.y=41+82
      end
    when 4
      if @actorrr[4] != nil 
        @battler_sprite_4.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
        @battler_sprite_4.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
        @battler_sprite_4.src_rect = Rect.new(0,0,192,192)
        @battler_sprite_4.x=430+100
        @battler_sprite_4.y=41+82
      end
    when 3
      if @actorrr[3] != nil 
        @battler_sprite_3.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
        @battler_sprite_3.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
        @battler_sprite_3.src_rect = Rect.new(0,0,192,192)
        @battler_sprite_3.x=430+150
        @battler_sprite_3.y=41+82
      end    
    when 2
      if @actorrr[2] != nil 
        @battler_sprite_2.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
        @battler_sprite_2.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
        @battler_sprite_2.src_rect = Rect.new(0,0,192,192)
        @battler_sprite_2.x=430+200
        @battler_sprite_2.y=41+82
      end
    when 1
      if @actorrr[1] != nil 
        @battler_sprite_1.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
        @battler_sprite_1.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
        @battler_sprite_1.src_rect = Rect.new(0,0,192,192)
        @battler_sprite_1.x=430+250
        @battler_sprite_1.y=41+82
      end
    end

    @ci -= 1             
    @temp_members << $game_party.actors[index]
    $game_party.actors.delete_at(index)

    if @status_window.index >= $game_party.actors.size
      @status_window.index = $game_party.actors.size-1
    end

    if $game_party.actors.size == 0
      @temp_members.reverse.each do |m|
        $game_party.actors.unshift(@temp_members.delete(m)) 
        if @actorrr[0] != nil 
          @battler_sprite_0.bitmap = Cache.battler("#{ $game_party.actors[index]}",0)
          @battler_sprite_0.bitmap = Cache.battler("00",0) if $game_party.members[index].dead?
          @battler_sprite_0.src_rect = Rect.new(0,0,192,192)
          @battler_sprite_0.x=430+300
          @battler_sprite_0.y=41+82
        end
        Audio.se_play("Audio/SE/fcmove",100,95)
        @ok = 1
        @command_window.unselect
      end

      @effect = 1
      @new_team = Sprite.new
      @new_team.bitmap = Cache.flash("new01")
      @new_team.x=780
      @new_team.y=153
      @new_team.z=999
      @new_team.blend_type = 1
      @status_window.deactivate.unselect
      @status_window.refresh
      @status_window.s101.opacity = 0
      @battler_sprite_acc.opacity = 0
      @flash_bmp.bitmap = Cache.flash("d00")
      @status_window.reset_guage
      @status_window.refresh_jm_icon
      return
    end
    @status_window.index = 0
    @status_window.reset_guage
    #@status_window.dispose_item(index)
    @status_window.refresh
    @status_window.refresh_jm_icon
    #@status_window.refresh_gauge
    #@status_window.refresh_mask
    @status_window.activate
    @status_window_open = 1
    battler_picture_clear

  end

  #--------------------------------------------------------------------------
  # ● 个人指令“取消”
  #--------------------------------------------------------------------------
  def on_personal_cancel

    @status_window.index = 0
    if @command_window.current_symbol == :dl
      @temp_members.each do |m|
        $game_party.actors.push(m)
      end
      @temp_members.clear
      @status_window.reset_guage
      @status_window.refresh
    end
    @status_window.unselect
    @status_window_open = 0
    @command_window.activate
    @status_window.s101.opacity = 0
    @battler_sprite_acc.opacity = 0
    show_expbook
    battler_picture_refresh
    @flash_bmp.bitmap = Cache.flash("d00")
    @gold_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 阵型“确定”
  #--------------------------------------------------------------------------
  def on_formation_ok
    @status_window.index = 0
    if @status_window.pending_index >= 0
      $game_party.swap_order(@status_window.index,
                             @status_window.pending_index)
      @status_window.pending_index = -1
      @status_window.redraw_item(@status_window.index)
    else
      @status_window.pending_index = @status_window.index
    end
    @status_window.activate
    @status_window_open = 1
  end
  #--------------------------------------------------------------------------
  # ● 阵型“取消”
  #--------------------------------------------------------------------------
  def on_formation_cancel
    @status_window.index = 0
    if @status_window.pending_index >= 0
      @status_window.pending_index = -1
      @status_window.activate
      @status_window_open = 1
    else
      @status_window.unselect
      @status_window_open = 0
      @command_window.activate
    end
  end
  
  def call_Scene_Map
    Sound.play_cancel
    $game_player.refresh
    $game_map.need_refresh = true
    SceneManager.call(Scene_Map) 
    Window_MenuCommand::init_command_position
    battler_sprite_over
  end
  def update_call_scene_map
    return if @cmd_yesno.active == true
    @scene_map_calling ||= Input.trigger?(:B)
    call_Scene_Map if @scene_map_calling and @ok == 0
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # def terminate
  #   super
  #   => 无需手动释放
  #   @di.bitmap.dispose
  #   @di.dispose
  #   @flash_bmp.bitmap.dispose
  #   @flash_bmp.dispose
  #   @come.bitmap.dispose
  #   @come.dispose
  #   battler_sprite_over
  # end

  #--------------------------------------------------------------------------
  # ● 释放对象之后
  #--------------------------------------------------------------------------
  def after_dispose
    # 掩盖菜单退出时，清除内存所造成的卡顿
    # if SceneManager.scene_is?(Scene_Map)
    #   Graphics.transition(30, "Graphics/Pictures/0000", 100)
    #   Graphics.freeze
    # end
  end

  #--------------------------------------------------------------------------
  # ● 删除战斗图
  #--------------------------------------------------------------------------
  def  battler_sprite_over
    if @battler_sprite_0 != nil 
      @battler_sprite_0.bitmap.dispose
      @battler_sprite_0.dispose
      @battler_sprite_0 = nil
    end
    if @battler_sprite_1 != nil 
      @battler_sprite_1.bitmap.dispose
      @battler_sprite_1.dispose
      @battler_sprite_1 = nil
    end
    if @battler_sprite_2 != nil 
      @battler_sprite_2.bitmap.dispose
      @battler_sprite_2.dispose
      @battler_sprite_2 = nil
    end
    if @battler_sprite_3 != nil 
      @battler_sprite_3.bitmap.dispose
      @battler_sprite_3.dispose
      @battler_sprite_3 = nil
    end
    if @battler_sprite_4 != nil 
      @battler_sprite_4.bitmap.dispose
      @battler_sprite_4.dispose
      @battler_sprite_4 = nil
    end
    if @battler_sprite_5 != nil 
      @battler_sprite_5.bitmap.dispose
      @battler_sprite_5.dispose
      @battler_sprite_5 = nil
    end
    if @battler_sprite_6 != nil 
      @battler_sprite_6.bitmap.dispose
      @battler_sprite_6.dispose
      @battler_sprite_6 = nil
    end
    if  @new_team != nil
      @new_team.bitmap.dispose
      @new_team.dispose
      @new_team = nil
    end 
    if  @battler_sprite_acc != nil
      @battler_sprite_acc.bitmap.dispose
      @battler_sprite_acc.dispose
      @battler_sprite_acc = nil
    end   
    if  @master_char != nil
      @master_char.bitmap.dispose
      @master_char.dispose
      @master_char = nil
    end

    if @fa != nil
       @fa.bitmap.dispose
       @fa.dispose
    end

      @expbook_s_back.bitmap.dispose
      @expbook_s.bitmap.dispose
      @expbook_text.bitmap.dispose
      @expbook_s_back.dispose
      @expbook_s.dispose
      @expbook_text.dispose
  end

  #菜单快捷键
  def update_speed_key 
    if Keys.trigger?(Keys::N1)
      if @command_window.active == true
         #@command_window.select(0)
         #@command_window.process_ok
         #@command_window.deactivate
         #@status_window.activate
         SceneManager.call(Scene_Status)
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N2)
      if @command_window.active == true
         @command_window.select(1)
         @command_window.call_ok_handler
         @command_window.deactivate
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N3)
      if @command_window.active == true
         #@command_window.select(2)
         #@command_window.call_ok_handler
         #@command_window.deactivate
         SceneManager.call(Scene_Marv)
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N4)
      if @command_window.active == true
         #@command_window.select(3)
         #@command_window.call_ok_handler
         #@command_window.deactivate
         SceneManager.call(Scene_Skill)
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N5)
      if @command_window.active == true
         #@command_window.select(4)
         #@command_window.call_ok_handler
         #@command_window.deactivate
         SceneManager.call(Scene_Equip)
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N6)
      if @command_window.active == true
         @command_window.select(5)
         @command_window.call_ok_handler
         @command_window.deactivate
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N7)
      if @command_window.active == true
         #@command_window.select(6)
         #@command_window.call_ok_handler
         #@command_window.deactivate
         SceneManager.call(Scene_Formation)
         Sound.play_ok
      end
    end  
    if Keys.trigger?(Keys::N8)
      if @command_window.active == true
         @command_window.select(7)
         @command_window.call_ok_handler
         @command_window.deactivate
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N9)
      if @command_window.active == true
         @command_window.select(8)
         @command_window.call_ok_handler
         @command_window.deactivate
         Sound.play_ok
      end
    end 
    if Keys.trigger?(Keys::N0)
      if @command_window.active == true
         @command_window.select(9)
         @command_window.call_ok_handler
         @command_window.deactivate
         Sound.play_ok
      end
    end 
  end
  #--------------------------------------------------------------------------
  # ● 更新画面（基础）
  #--------------------------------------------------------------------------
  def update
    super
     if @status_window.s101.opacity != 0 
        @battler_sprite_acc.opacity = 255
        hide_expbook
     end
    update_call_scene_map unless scene_changing?
    if @c == 0
      @flash +=2
      @flash_bmp.opacity = @flash   
      if @flash >= 255
        @c = 1
      end  
    else
      @flash -=2
      @flash_bmp.opacity = @flash
      if @flash <= 10
        @c = 0
      end
    end

    @effect += 1 if @effect >0 


    if @effect >0 
      case @effect
      when 5
        if $game_party.actors[0] != nil  and  @battler_sprite_0 != nil   
          @battler_sprite_0.bitmap = Cache.battler("#{ $game_party.actors[0]}",0)
          @battler_sprite_0.bitmap = Cache.battler("00",0) if $game_party.members[0].dead?
          @battler_sprite_0.opacity = 0
        end
      when 10
        if $game_party.actors[1] != nil   and  @battler_sprite_1 != nil 
          @battler_sprite_1.bitmap = Cache.battler("#{ $game_party.actors[1]}",0)
          @battler_sprite_1.bitmap = Cache.battler("00",0) if $game_party.members[1].dead?
          @battler_sprite_1.opacity = 0
        end
      when 15
        if $game_party.actors[2] != nil  and  @battler_sprite_2 != nil     
          @battler_sprite_2.bitmap = Cache.battler("#{ $game_party.actors[2]}",0)
          @battler_sprite_2.bitmap = Cache.battler("00",0) if $game_party.members[2].dead?
          @battler_sprite_2.opacity = 0
        end
      when 20
        if $game_party.actors[3] != nil  and  @battler_sprite_3 != nil 
          @battler_sprite_3.bitmap = Cache.battler("#{ $game_party.actors[3]}",0)
          @battler_sprite_3.bitmap = Cache.battler("00",0) if $game_party.members[3].dead?
          @battler_sprite_3.opacity = 0
        end
      when 25
        if $game_party.actors[4] != nil   and  @battler_sprite_4 != nil    
          @battler_sprite_4.bitmap = Cache.battler("#{ $game_party.actors[4]}",0)
          @battler_sprite_4.bitmap = Cache.battler("00",0) if $game_party.members[4].dead?
          @battler_sprite_4.opacity = 0
        end
      when 30
        if $game_party.actors[5] != nil   and  @battler_sprite_5 != nil   
          @battler_sprite_5.bitmap = Cache.battler("#{ $game_party.actors[5]}",0)
          @battler_sprite_5.bitmap = Cache.battler("00",0) if $game_party.members[5].dead?
          @battler_sprite_5.opacity = 0
        end
      when 35
        if $game_party.actors[6] != nil    and  @battler_sprite_6 != nil   
          @battler_sprite_6.bitmap = Cache.battler("#{ $game_party.actors[6]}",0)
          @battler_sprite_6.bitmap = Cache.battler("00",0) if $game_party.members[6].dead?
          @battler_sprite_6.opacity = 0
        end
      end
    end

    if @effect%1 == 0 and @new_team != nil 
      @new_team.x -= 8
      case @effect
      when 4
        @new_team.bitmap = Cache.flash("new02")
      when 8
        @new_team.bitmap = Cache.flash("new03")
      when 12
        @new_team.bitmap = Cache.flash("new04")
      when 16
        @new_team.bitmap = Cache.flash("new05")
      when 20
        @new_team.bitmap = Cache.flash("new06")
      when 24
        @new_team.bitmap = Cache.flash("new07")
      when 28
        @new_team.bitmap = Cache.flash("new08")
      when 32
        @new_team.bitmap = Cache.flash("new09")
      when 36
        @new_team.bitmap = Cache.flash("new10")
      when 40
        @new_team.bitmap = Cache.flash("new11")
      when 44
        @new_team.bitmap = Cache.flash("new12")
      when 48
        @new_team.opacity = 0 
        @new_team.bitmap.dispose
        @new_team.dispose
        @new_team = nil
      end
    end


    if @effect == ($game_party.members.size).to_i * 7 - 2  and  @new_team != nil
      @new_team.opacity = 0 
      @new_team.bitmap.dispose
      @new_team.dispose
      @new_team = nil
      battler_picture_refresh
      @ok = 0
      @command_window.activate
      show_expbook
      @effect = 0
      @gold_window.visible = true
    end

    #循环战斗图
    @nx += 1 
    @nx %= 60 #每帧+1，60帧一个循环

    if  @actorrr[0] != nil  and  @battler_sprite_0 != nil 
      @xbit = @nx / 15 * @battler_sprite_0.bitmap.width/4   
      @battler_sprite_0.src_rect.set(@xbit, 0, @battler_sprite_0.bitmap.width/4, @battler_sprite_0.bitmap.height)
    end
    if  @actorrr[1] != nil  and  @battler_sprite_1 != nil 
      @xbit = @nx / 15 * @battler_sprite_1.bitmap.width/4   
      @battler_sprite_1.src_rect.set(@xbit, 0, @battler_sprite_1.bitmap.width/4, @battler_sprite_1.bitmap.height)
    end
    if  @actorrr[2] != nil  and  @battler_sprite_2 != nil 
      @xbit = @nx / 15 * @battler_sprite_2.bitmap.width/4   
      @battler_sprite_2.src_rect.set(@xbit, 0, @battler_sprite_2.bitmap.width/4, @battler_sprite_2.bitmap.height)
    end
    if  @actorrr[3] != nil  and  @battler_sprite_3 != nil 
      @xbit = @nx / 15 * @battler_sprite_3.bitmap.width/4   
      @battler_sprite_3.src_rect.set(@xbit, 0, @battler_sprite_3.bitmap.width/4, @battler_sprite_3.bitmap.height)
    end
    if  @actorrr[4] != nil  and  @battler_sprite_4 != nil 
      @xbit = @nx / 15 * @battler_sprite_4.bitmap.width/4   
      @battler_sprite_4.src_rect.set(@xbit, 0, @battler_sprite_4.bitmap.width/4, @battler_sprite_4.bitmap.height)
    end
    if  @actorrr[5] != nil  and  @battler_sprite_5 != nil 
      @xbit = @nx / 15 * @battler_sprite_5.bitmap.width/4   
      @battler_sprite_5.src_rect.set(@xbit, 0, @battler_sprite_5.bitmap.width/4, @battler_sprite_5.bitmap.height)
    end
    if  @actorrr[6] != nil  and  @battler_sprite_6 != nil 
      @xbit = @nx / 15 * @battler_sprite_6.bitmap.width/4   
      @battler_sprite_6.src_rect.set(@xbit, 0, @battler_sprite_6.bitmap.width/4, @battler_sprite_6.bitmap.height)
    end

    case  @status_window.index
    when  0
      @battler_sprite_acc.x = @battler_sprite_0.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    when  1
      @battler_sprite_acc.x = @battler_sprite_1.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    when  2
      @battler_sprite_acc.x = @battler_sprite_2.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    when  3
      @battler_sprite_acc.x = @battler_sprite_3.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    when  4
      @battler_sprite_acc.x = @battler_sprite_4.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    when  5
      @battler_sprite_acc.x = @battler_sprite_5.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    when  6
      @battler_sprite_acc.x = @battler_sprite_6.x + 42
      @battler_sprite_acc.bitmap = Cache.system("acc")
      @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[@status_window.index].dead?
    end
      update_speed_key
  end

  #--------------------------------------------------------------------------
  # ● 生成角色战斗图
  #--------------------------------------------------------------------------
  def battler_picture  
    for i in 0...$game_party.members.size
      if $game_party.members[i].id == $game_variables[100]
        @master_char = Sprite.new
        @master_char.bitmap = Bitmap.new("Graphics/jm/master_char")
        @master_char.x = 472 + $game_party.members[i].index * 50
        @master_char.y = 41
        @master_char.z = 220
      end
    end

    if $game_party.members[0] != nil
      @battler_sprite_0 = Sprite.new         
      @battler_sprite_0.bitmap = Cache.battler("#{@actorrr[0]}",0)
      @battler_sprite_0.bitmap = Cache.battler("00",0) if $game_party.members[0].dead?
      @battler_sprite_0.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_0.x=390+40
      @battler_sprite_0.y=41
      @battler_sprite_0.z=100
    end

    if $game_party.members[1] != nil
      @battler_sprite_1 = Sprite.new         
      @battler_sprite_1.bitmap = Cache.battler("#{@actorrr[1]}",0)
      @battler_sprite_1.bitmap = Cache.battler("00",0) if $game_party.members[1].dead?
      @battler_sprite_1.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_1.x=390+50+40
      @battler_sprite_1.y=41
      @battler_sprite_1.z=100
    end

    if $game_party.members[2] != nil
      @battler_sprite_2 = Sprite.new         
      @battler_sprite_2.bitmap = Cache.battler("#{@actorrr[2]}",0)
      @battler_sprite_2.bitmap = Cache.battler("00",0) if $game_party.members[2].dead?
      @battler_sprite_2.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_2.x=390+50+50+40
      @battler_sprite_2.y=41
      @battler_sprite_2.z=100
    end

    if $game_party.members[3] != nil
      @battler_sprite_3 = Sprite.new         
      @battler_sprite_3.bitmap = Cache.battler("#{@actorrr[3]}",0)
      @battler_sprite_3.bitmap = Cache.battler("00",0) if $game_party.members[3].dead?
      @battler_sprite_3.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_3.x=390+50+50+50+40
      @battler_sprite_3.y=41
      @battler_sprite_3.z=100
    end

    if $game_party.members[4] != nil
      @battler_sprite_4 = Sprite.new         
      @battler_sprite_4.bitmap = Cache.battler("#{@actorrr[4]}",0)
      @battler_sprite_4.bitmap = Cache.battler("00",0) if $game_party.members[4].dead?
      @battler_sprite_4.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_4.x=390+50+50+50+50+40
      @battler_sprite_4.y=41
      @battler_sprite_4.z=100
    end

    if $game_party.members[5] != nil
      @battler_sprite_5 = Sprite.new         
      @battler_sprite_5.bitmap = Cache.battler("#{@actorrr[5]}",0)
      @battler_sprite_5.bitmap = Cache.battler("00",0) if $game_party.members[5].dead?
      @battler_sprite_5.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_5.x=390+50+50+50+50+50+40
      @battler_sprite_5.y=41
      @battler_sprite_5.z=100
    end

    if $game_party.members[6] != nil
      @battler_sprite_6 = Sprite.new         
      @battler_sprite_6.bitmap = Cache.battler("#{@actorrr[6]}",0)
      @battler_sprite_6.bitmap = Cache.battler("00",0) if $game_party.members[6].dead?
      @battler_sprite_6.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_6.x=390+50+50+50+50+50+50+40
      @battler_sprite_6.y=41
      @battler_sprite_6.z=100
    end
    @battler_sprite_acc = Sprite.new         
    @battler_sprite_acc.bitmap = Cache.system("acc")
    @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[(@actor.index).to_i].dead?
    @battler_sprite_acc.src_rect = Rect.new(0,0,192,192)
    @battler_sprite_acc.x= @battler_sprite_0.x + 42
    @battler_sprite_acc.y=4
    @battler_sprite_acc.z=99
    @battler_sprite_acc.opacity = 0
  end


  def battler_picture_refresh
    if  $game_party.members[0] != nil     
      @battler_sprite_0.bitmap = Cache.battler("#{$game_party.members[0].id}",0)
      @battler_sprite_0.bitmap = Cache.battler("00",0) if $game_party.members[0].dead?
      @battler_sprite_0.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_0.x=390+40
      @battler_sprite_0.y=41
      @battler_sprite_0.z=100
      @battler_sprite_0.opacity = 255
    end

    if  $game_party.members[1] != nil      
      @battler_sprite_1.bitmap = Cache.battler("#{$game_party.members[1].id}",0)
      @battler_sprite_1.bitmap = Cache.battler("00",0) if $game_party.members[1].dead?
      @battler_sprite_1.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_1.x=390+50+40
      @battler_sprite_1.y=41
      @battler_sprite_1.z=100
      @battler_sprite_1.opacity = 255
    end

    if  $game_party.members[2] != nil       
      @battler_sprite_2.bitmap = Cache.battler("#{$game_party.members[2].id}",0)
      @battler_sprite_2.bitmap = Cache.battler("00",0) if $game_party.members[2].dead?
      @battler_sprite_2.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_2.x=390+50+50+40
      @battler_sprite_2.y=41
      @battler_sprite_2.z=100
      @battler_sprite_2.opacity = 255
    end

    if  $game_party.members[3] != nil        
      @battler_sprite_3.bitmap = Cache.battler("#{$game_party.members[3].id}",0)
      @battler_sprite_3.bitmap = Cache.battler("00",0) if $game_party.members[3].dead?
      @battler_sprite_3.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_3.x=390+50+50+50+40
      @battler_sprite_3.y=41
      @battler_sprite_3.z=100
      @battler_sprite_3.opacity = 255
    end

    if  $game_party.members[4] != nil       
      @battler_sprite_4.bitmap = Cache.battler("#{$game_party.members[4].id}",0)
      @battler_sprite_4.bitmap = Cache.battler("00",0)if $game_party.members[4].dead?
      @battler_sprite_4.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_4.x=390+50+50+50+50+40
      @battler_sprite_4.y=41
      @battler_sprite_4.z=100
      @battler_sprite_4.opacity = 255
    end

    if  $game_party.members[5] != nil       
      @battler_sprite_5.bitmap = Cache.battler("#{$game_party.members[5].id}",0)
      @battler_sprite_5.bitmap = Cache.battler("00",0) if $game_party.members[5].dead?
      @battler_sprite_5.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_5.x=390+50+50+50+50+50+40
      @battler_sprite_5.y=41
      @battler_sprite_5.z=100
      @battler_sprite_5.opacity = 255
    end

    if  $game_party.members[6] != nil      
      @battler_sprite_6.bitmap = Cache.battler("#{$game_party.members[6].id}",0)
      @battler_sprite_6.bitmap = Cache.battler("00",0) if $game_party.members[6].dead?
      @battler_sprite_6.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_6.x=390+50+50+50+50+50+50+40
      @battler_sprite_6.y=41
      @battler_sprite_6.z=100
      @battler_sprite_6.opacity = 255
    end

    @battler_sprite_acc.bitmap = Cache.system("acc")
    @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[(@actor.index).to_i].dead?
    @battler_sprite_acc.src_rect = Rect.new(0,0,192,192)
    @battler_sprite_acc.x= @battler_sprite_0.x + 42
    @battler_sprite_acc.y=4
    @battler_sprite_acc.z=99
    @battler_sprite_acc.opacity = 0

    for i in 0...$game_party.members.size
      if $game_party.members[i].id == $game_variables[100]
        @master_char.bitmap = Bitmap.new("Graphics/jm/master_char")
        @master_char.x = 472 + $game_party.members[i].index * 50
        @master_char.y = 41
        @master_char.z = 220
        @master_char.opacity = 255
      end
    end
  end


  def battler_picture_clear
    @master_char.opacity = 0 if @master_char != nil 
    for i in 0...$game_party.members.size
      if $game_party.members[i].id == $game_variables[100]
        @master_char.x = 472 + i * 50
        @master_char.y = 41
        @master_char.z = 220
        @master_char.opacity = 255
      end
    end

    if  $game_party.members[0] != nil     
      @battler_sprite_0.bitmap = Cache.battler("#{$game_party.members[0].id}",0)
      @battler_sprite_0.bitmap = Cache.battler("00",0) if $game_party.members[0].dead?
      @battler_sprite_0.src_rect = Rect.new(0,0,192,192)
    end

    if  $game_party.members[1] != nil      
      @battler_sprite_1.bitmap = Cache.battler("#{$game_party.members[1].id}",0)
      @battler_sprite_1.bitmap = Cache.battler("00",0) if $game_party.members[1].dead?
      @battler_sprite_1.src_rect = Rect.new(0,0,192,192)
    end

    if  $game_party.members[2] != nil       
      @battler_sprite_2.bitmap = Cache.battler("#{$game_party.members[2].id}",0)
      @battler_sprite_2.bitmap = Cache.battler("00",0) if $game_party.members[2].dead?
      @battler_sprite_2.src_rect = Rect.new(0,0,192,192)
    end

    if  $game_party.members[3] != nil        
      @battler_sprite_3.bitmap = Cache.battler("#{$game_party.members[3].id}",0)
      @battler_sprite_3.bitmap = Cache.battler("00",0) if $game_party.members[3].dead?
      @battler_sprite_3.src_rect = Rect.new(0,0,192,192)
    end

    if  $game_party.members[4] != nil       
      @battler_sprite_4.bitmap = Cache.battler("#{$game_party.members[4].id}",0)
      @battler_sprite_4.bitmap = Cache.battler("00",0) if $game_party.members[4].dead?
      @battler_sprite_4.src_rect = Rect.new(0,0,192,192)
    end

    if  $game_party.members[5] != nil       
      @battler_sprite_5.bitmap = Cache.battler("#{$game_party.members[5].id}",0)
      @battler_sprite_5.bitmap = Bitmap.new("Graphics/Battlers/00") if $game_party.members[5].dead?
      @battler_sprite_5.src_rect = Rect.new(0,0,192,192)
    end

    if  $game_party.members[6] != nil      
      @battler_sprite_6.bitmap = Cache.battler("#{$game_party.members[6].id}",0)
      @battler_sprite_6.bitmap = Cache.battler("00",0) if $game_party.members[6].dead?
      @battler_sprite_6.src_rect = Rect.new(0,0,192,192)
    end
  end
end
