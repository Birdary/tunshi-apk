#encoding:utf-8
#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装备画面
#==============================================================================

class Scene_Equip < Scene_MenuBase
  EQUIP_TYPE_MAX = 5                      # 最大装备数
  WLH = 26
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    # flash
    @actorrr = Array.new 
    for i in 0...$game_party.members.size
    @actorrr[i] = $game_party.members[i].id 
    end

    @nx = 0
    @xbit = 0
    @item_window_flash = 0

    @status_window = Window_EquipStatus.new(0, 146-36+200)
    @status_window.actor = @actor
    @status_window.refresh
    battler_picture

    create_help_window
    #create_status_window
    #create_command_window
    create_slot_window
    create_item_window
    create_actor_status_window

    create_flash_background Cache.flash("equip_flash")
    set_menu_background Cache.system("equip_big_back")
    
  end


   def create_actor_status_window
    @actor_status_window = Window_Status.new(@actor,:simple)
  end

  def create_help_window
    super
   # @help_window.attrset(:x=>490-103,:y=>60+87)
     @help_window.attrset(:x=>30,:y=>640)
  end

  #def change_battler(actor)
  #  @battler_sprite.bitmap = Cache.battler("#{actor.battler_name.split(/★/)[0]}",0)
  #end

  #--------------------------------------------------------------------------
  # ● 生成装备物品窗口
  #--------------------------------------------------------------------------
 #def create_item_windows
   # @item_windows = []
    #for i in 0...EQUIP_TYPE_MAX
     # @item_windows[i] = Window_EquipItem.new(0, 208, 544, 208)
     # @item_windows[i].help_window = @help_window
     # @item_windows[i].visible = (@equip_index == i)
     # @item_windows[i].y = 488
     # @item_windows[i].height = 208-32
     # @item_windows[i].active = false
     # @item_windows[i].index = -1
   # end
  #end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_EquipStatus.new(0, @help_window.height)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    wx = @status_window.width
    wy = @help_window.height
    ww = Graphics.width - @status_window.width
    @command_window = Window_EquipCommand.new(wx, wy, ww)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.set_handler(:equip,    method(:command_equip))
    @command_window.set_handler(:optimize, method(:command_optimize))
    @command_window.set_handler(:clear,    method(:command_clear))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● 生成装备栏窗口
  #--------------------------------------------------------------------------
  def create_slot_window
    wx = 96+11
    wy = 330-134+5 #@command_window.y + @command_window.height
    ww = 420 #Graphics.width - @status_window.width
    @slot_window = Window_EquipSlot.new(wx+4, wy, ww)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.status_window = @status_window
    @slot_window.actor = @actor
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
    @slot_window.set_handler(:pagedown, method(:next_actor))
    @slot_window.set_handler(:pageup,   method(:prev_actor))
    @slot_window.index = 0
    @slot_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 生成物品窗口 物品道具上下箭头和左右宽度+++++
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 60+390+55
    wy = 492-297+6 #@slot_window.y + @slot_window.height
    ww = 205+100 #Graphics.width
    wh = 410 #Graphics.height - wy
    @item_window = Window_EquipItem.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ● 指令“更换装备”
  #--------------------------------------------------------------------------
  def command_equip
    @slot_window.activate
    @slot_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 指令“最强装备”
  #--------------------------------------------------------------------------
  def command_optimize
    Sound.play_equip
    @actor.optimize_equipments
    @status_window.refresh
    @slot_window.refresh
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 指令“全部卸下”
  #--------------------------------------------------------------------------
  def command_clear
    Sound.play_equip
    @actor.clear_equipments
    @status_window.refresh
    @slot_window.refresh
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 装备栏“确定”
  #--------------------------------------------------------------------------
  def on_slot_ok
  if ( @slot_window.index == 1 and @actor.id == 12 )  or  ( @actor.id == 52 and ( @slot_window.index == 1 or @slot_window.index == 2 or @slot_window.index == 3 ))
     Sound.play_buzzer
     @slot_window.activate
     @item_window.unselect
     @item_window_flash = 0
     else
     @item_window.activate
     @item_window.select(0)
     @item_window_flash = 1
  end   
  end
  #--------------------------------------------------------------------------
  # ● 装备栏“取消”
  #--------------------------------------------------------------------------
  def on_slot_cancel
    @slot_window.unselect
    Sound.play_cancel
    return_scene
    #@command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  def on_item_ok
    Sound.play_equip
    @actor.change_equip(@slot_window.index, @item_window.item)
    @slot_window.activate
    @slot_window.refresh
    @item_window.unselect
    @item_window_flash = 0
    @item_window.refresh
    @status_window.refresh
    @actor_status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  def on_item_cancel
    @slot_window.activate
    @item_window.unselect
    @item_window_flash = 0
  end
  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  def on_actor_change
    @actor_status_window.actor = @actor
    @status_window.actor = @actor
    @slot_window.actor = @actor
    @item_window.actor = @actor
    @slot_window.activate
    battler_picture_change
   # change_battler(@actor)
    #@command_window.activate
  end

  def update
    super
   battler_update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::RIGHT) or Keys.trigger?(Keys::D)
      if @item_window_flash == 0
      Sound.play_cursor
      next_actor
      end
    elsif Input.trigger?(Input::LEFT) or Keys.trigger?(Keys::A)
      if @item_window_flash == 0
      Sound.play_cursor
      prev_actor
      end
    end

  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   #@battler_sprite.dispose
  #   #@battler_sprite.bitmap.dispose
  #   battler_sprite_over
  # end

  #--------------------------------------------------------------------------
  # ● 生成角色战斗图
  #--------------------------------------------------------------------------
  def battler_picture  
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

    for i in 0...$game_party.members.size
      if $game_party.members[i].id ==  $game_variables[100]
        @master_char = Sprite.new
        @master_char.bitmap = Bitmap.new("Graphics/jm/master_char")
        @master_char.x = 472 + $game_party.members[i].index * 50
        @master_char.y = 41
        @master_char.z = 220
        @master_char.opacity = 255
        @master_char.opacity = 120  if @actor.id != $game_variables[100]
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
      @battler_sprite_0.opacity = 255
      @battler_sprite_0.opacity = 120  if @actor.id != $game_party.members[0].id
    end

    if $game_party.members[1] != nil
      @battler_sprite_1 = Sprite.new         
      @battler_sprite_1.bitmap = Cache.battler("#{@actorrr[1]}",0)
      @battler_sprite_1.bitmap = Cache.battler("00",0)  if $game_party.members[1].dead?
      @battler_sprite_1.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_1.x=390+50+40
      @battler_sprite_1.y=41
      @battler_sprite_1.z=100
      @battler_sprite_1.opacity = 255
      @battler_sprite_1.opacity = 120  if @actor.id != $game_party.members[1].id
    end

    if $game_party.members[2] != nil
      @battler_sprite_2 = Sprite.new         
      @battler_sprite_2.bitmap = Cache.battler("#{@actorrr[2]}",0)
      @battler_sprite_2.bitmap = Cache.battler("00",0)  if $game_party.members[2].dead?
      @battler_sprite_2.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_2.x=390+50+50+40
      @battler_sprite_2.y=41
      @battler_sprite_2.z=100
      @battler_sprite_2.opacity = 255
      @battler_sprite_2.opacity = 120  if @actor.id != $game_party.members[2].id
    end

    if $game_party.members[3] != nil
      @battler_sprite_3 = Sprite.new         
      @battler_sprite_3.bitmap = Cache.battler("#{@actorrr[3]}",0)
      @battler_sprite_3.bitmap = Cache.battler("00",0)  if $game_party.members[3].dead?
      @battler_sprite_3.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_3.x=390+50+50+50+40
      @battler_sprite_3.y=41
      @battler_sprite_3.z=100
      @battler_sprite_3.opacity = 255
      @battler_sprite_3.opacity = 120  if @actor.id != $game_party.members[3].id
    end

    if $game_party.members[4] != nil
      @battler_sprite_4 = Sprite.new         
      @battler_sprite_4.bitmap = Cache.battler("#{@actorrr[4]}",0)
      @battler_sprite_4.bitmap = Cache.battler("00",0)  if $game_party.members[4].dead?
      @battler_sprite_4.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_4.x=390+50+50+50+50+40
      @battler_sprite_4.y=41
      @battler_sprite_4.z=100
      @battler_sprite_4.opacity = 255
      @battler_sprite_4.opacity = 120  if @actor.id != $game_party.members[4].id
    end

    if $game_party.members[5] != nil
      @battler_sprite_5 = Sprite.new         
      @battler_sprite_5.bitmap = Cache.battler("#{@actorrr[5]}",0)
      @battler_sprite_5.bitmap = Cache.battler("00",0)  if $game_party.members[5].dead? 
      @battler_sprite_5.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_5.x=390+50+50+50+50+50+40
      @battler_sprite_5.y=41
      @battler_sprite_5.z=100
      @battler_sprite_5.opacity = 255
      @battler_sprite_5.opacity = 120  if @actor.id != $game_party.members[5].id
    end

    if $game_party.members[6] != nil
      @battler_sprite_6 = Sprite.new         
      @battler_sprite_6.bitmap = Cache.battler("#{@actorrr[6]}",0)
      @battler_sprite_6.bitmap = Cache.battler("00",0)  if $game_party.members[6].dead?
      @battler_sprite_6.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_6.x=390+50+50+50+50+50+50+40
      @battler_sprite_6.y=41
      @battler_sprite_6.z=100
      @battler_sprite_6.opacity = 255
      @battler_sprite_6.opacity = 120  if @actor.id != $game_party.members[6].id
    end
    @battler_sprite_acc = Sprite.new         
    @battler_sprite_acc.bitmap = Cache.system("acc") 
    @battler_sprite_acc.bitmap = Cache.system("acc_dead")  if $game_party.members[(@actor.index).to_i].dead?
    @battler_sprite_acc.x= (@battler_sprite_0.x + 42) + 50 * (@actor.index).to_f
    @battler_sprite_acc.y=4
    @battler_sprite_acc.z=99
    @battler_sprite_acc.opacity = 255
  end


  def battler_picture_change     
    if $game_party.members[0] != nil      
      @battler_sprite_0.bitmap =  Cache.battler("#{@actorrr[0]}",0)
      @battler_sprite_0.bitmap = Cache.battler("00",0)  if $game_party.members[0].dead? 
      @battler_sprite_0.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_0.x=390+40
      @battler_sprite_0.y=41
      @battler_sprite_0.z=100
      @battler_sprite_0.opacity = 255
      @battler_sprite_0.opacity = 120  if @actor.id != $game_party.members[0].id
    end

    if $game_party.members[1] != nil       
      @battler_sprite_1.bitmap =  Cache.battler("#{@actorrr[1]}",0)
      @battler_sprite_1.bitmap = Cache.battler("00",0)  if $game_party.members[1].dead? 
      @battler_sprite_1.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_1.x=390+50+40
      @battler_sprite_1.y=41
      @battler_sprite_1.z=100
      @battler_sprite_1.opacity = 255
      @battler_sprite_1.opacity = 120  if @actor.id != $game_party.members[1].id
    end

    if $game_party.members[2] != nil        
      @battler_sprite_2.bitmap =  Cache.battler("#{@actorrr[2]}",0)
      @battler_sprite_2.bitmap = Cache.battler("00",0)  if $game_party.members[2].dead? 
      @battler_sprite_2.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_2.x=390+50+50+40
      @battler_sprite_2.y=41
      @battler_sprite_2.z=100
      @battler_sprite_2.opacity = 255
      @battler_sprite_2.opacity = 120  if @actor.id != $game_party.members[2].id
    end

    if $game_party.members[3] != nil        
      @battler_sprite_3.bitmap =  Cache.battler("#{@actorrr[3]}",0)
      @battler_sprite_3.bitmap = Cache.battler("00",0)  if $game_party.members[3].dead? 
      @battler_sprite_3.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_3.x=390+50+50+50+40
      @battler_sprite_3.y=41
      @battler_sprite_3.z=100
      @battler_sprite_3.opacity = 255
      @battler_sprite_3.opacity = 120  if @actor.id != $game_party.members[3].id
    end

    if $game_party.members[4] != nil        
      @battler_sprite_4.bitmap =  Cache.battler("#{@actorrr[4]}",0)
      @battler_sprite_4.bitmap = Cache.battler("00",0)  if $game_party.members[4].dead? 
      @battler_sprite_4.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_4.x=390+50+50+50+50+40
      @battler_sprite_4.y=41
      @battler_sprite_4.z=100
      @battler_sprite_4.opacity = 255
      @battler_sprite_4.opacity = 120  if @actor.id != $game_party.members[4].id
    end

    if $game_party.members[5] != nil        
      @battler_sprite_5.bitmap =  Cache.battler("#{@actorrr[5]}",0)
      @battler_sprite_5.bitmap = Cache.battler("00",0)  if $game_party.members[5].dead?
      @battler_sprite_5.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_5.x=390+50+50+50+50+50+40
      @battler_sprite_5.y=41
      @battler_sprite_5.z=100
      @battler_sprite_5.opacity = 255
      @battler_sprite_5.opacity = 120  if @actor.id != $game_party.members[5].id
    end

    if $game_party.members[6] != nil      
      @battler_sprite_6.bitmap =  Cache.battler("#{@actorrr[6]}",0)
      @battler_sprite_6.bitmap = Cache.battler("00",0)  if $game_party.members[6].dead?
      @battler_sprite_6.src_rect = Rect.new(0,0,192,192)
      @battler_sprite_6.x=390+50+50+50+50+50+50+40
      @battler_sprite_6.y=41
      @battler_sprite_6.z=100
      @battler_sprite_6.opacity = 255
      @battler_sprite_6.opacity = 120  if @actor.id != $game_party.members[6].id
    end       
    @battler_sprite_acc.bitmap = Cache.system("acc")
    @battler_sprite_acc.bitmap = Cache.system("acc_dead") if $game_party.members[(@actor.index).to_i].dead?
    @battler_sprite_acc.x= (@battler_sprite_0.x + 42) + 50 * (@actor.index).to_f
    @battler_sprite_acc.y=4
    @battler_sprite_acc.z=99
    @battler_sprite_acc.opacity = 255
  end

  def battler_sprite_over
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
    if @master_char != nil
      @master_char.bitmap.dispose
      @master_char.dispose
      @master_char = nil
    end
    if @battler_sprite_acc != nil
      @battler_sprite_acc.bitmap.dispose
      @battler_sprite_acc.dispose
      @battler_sprite_acc = nil
    end
    if @fa != nil
       @fa.bitmap.dispose
       @fa.dispose
    end
  end

  def battler_update
    @nx += 1 
    @nx %= 60 #每帧+1，60帧一个循环

    if @actorrr[0] != nil  and  @battler_sprite_0 != nil 
      @xbit = @nx / 15 * @battler_sprite_0.bitmap.width/4   
      @battler_sprite_0.src_rect.set(@xbit, 0, @battler_sprite_0.bitmap.width/4, @battler_sprite_0.bitmap.height)
    end
    if @actorrr[1] != nil  and  @battler_sprite_1 != nil 
      @xbit = @nx / 15 * @battler_sprite_1.bitmap.width/4   
      @battler_sprite_1.src_rect.set(@xbit, 0, @battler_sprite_1.bitmap.width/4, @battler_sprite_1.bitmap.height)
    end
    if @actorrr[2] != nil  and  @battler_sprite_2 != nil 
      @xbit = @nx / 15 * @battler_sprite_2.bitmap.width/4   
      @battler_sprite_2.src_rect.set(@xbit, 0, @battler_sprite_2.bitmap.width/4, @battler_sprite_2.bitmap.height)
    end
    if @actorrr[3] != nil  and  @battler_sprite_3 != nil 
      @xbit = @nx / 15 * @battler_sprite_3.bitmap.width/4   
      @battler_sprite_3.src_rect.set(@xbit, 0, @battler_sprite_3.bitmap.width/4, @battler_sprite_3.bitmap.height)
    end
    if @actorrr[4] != nil  and  @battler_sprite_4 != nil 
      @xbit = @nx / 15 * @battler_sprite_4.bitmap.width/4   
      @battler_sprite_4.src_rect.set(@xbit, 0, @battler_sprite_4.bitmap.width/4, @battler_sprite_4.bitmap.height)
    end
    if @actorrr[5] != nil  and  @battler_sprite_5 != nil 
      @xbit = @nx / 15 * @battler_sprite_5.bitmap.width/4   
      @battler_sprite_5.src_rect.set(@xbit, 0, @battler_sprite_5.bitmap.width/4, @battler_sprite_5.bitmap.height)
    end
    if @actorrr[6] != nil  and  @battler_sprite_6 != nil 
      @xbit = @nx / 15 * @battler_sprite_6.bitmap.width/4   
      @battler_sprite_6.src_rect.set(@xbit, 0, @battler_sprite_6.bitmap.width/4, @battler_sprite_6.bitmap.height)
    end
  end

end
