#encoding:utf-8
#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　状态画面
#==============================================================================
class Scene_Status < Scene_MenuBase
  def initialize(actor_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    @actorrr = Array.new 
    for i in 0...$game_party.members.size
    @actorrr[i] = $game_party.members[i].id 

    end
    @nx = 0
    @xbit = 0

    @status_window = Window_Status.new(@actor)
    battler_picture

    @status_window.set_handler(:cancel,   method(:return_scene))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))

    @status_window.z= 20

    @di2 = Sprite.new
    @di2.bitmap = Cache.system("d02")

    create_flash_background Cache.flash("d02f")


    n1=@actor.str
    n2=@actor.ski
    n3=@actor.int
    n4=@actor.agi
    n5=@actor.atk 
    n6=@actor.def

    @nc_05=Sprite.new
    @nc_05.bitmap = Bitmap.new("Graphics/pictures/nc_g")
    @nc_05.x = 110+12
    @nc_05.y = 390-40-53+2-1
    @nc_05.bitmap.clear_rect(n5, 0, 256-n5, 6)

    @nc_06=Sprite.new
    @nc_06.bitmap = Bitmap.new("Graphics/pictures/nc_f")
    @nc_06.x = 110+12
    @nc_06.y = 390-20-53+9-2
    @nc_06.bitmap.clear_rect(n6, 0, 256-n6, 6)

    @nc_01=Sprite.new
    @nc_01.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_01.x = 110+12
    @nc_01.y = 390-53+14-2+1
    @nc_01.bitmap.clear_rect(n1, 0, 256-n1, 6)

    @nc_02=Sprite.new
    @nc_02.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_02.x = 110+12
    @nc_02.y = 390+20-53+19
    @nc_02.bitmap.clear_rect(n2, 0, 256-n2, 6)

    @nc_03=Sprite.new
    @nc_03.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_03.x = 110+12
    @nc_03.y = 390+40-53+24+1
    @nc_03.bitmap.clear_rect(n3, 0, 256-n3, 6)

    @nc_04=Sprite.new
    @nc_04.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_04.x = 110+12
    @nc_04.y = 390+60-53+31
    @nc_04.bitmap.clear_rect(n4, 0, 256-n4, 6)

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

  end



  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    @status_window.activate
    battler_picture_change
    n1=@actor.param_base(2)
    n2=@actor.param_base(3)
    n3=@actor.param_base(4)
    n4=@actor.param_base(6)
    n5=@actor.atk
    n6=@actor.def
    @nc_05.bitmap = Bitmap.new("Graphics/pictures/nc_g")
    @nc_05.bitmap.clear_rect(n5, 0, 256-n5, 6)
    @nc_06.bitmap = Bitmap.new("Graphics/pictures/nc_f")
    @nc_06.bitmap.clear_rect(n6, 0, 256-n6, 6)
    @nc_01.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_01.bitmap.clear_rect(n1, 0, 256-n1, 6)
    @nc_02.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_02.bitmap.clear_rect(n2, 0, 256-n2, 6)
    @nc_03.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_03.bitmap.clear_rect(n3, 0, 256-n3, 6)
    @nc_04.bitmap = Bitmap.new("Graphics/pictures/nc")
    @nc_04.bitmap.clear_rect(n4, 0, 256-n4, 6)
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   @nc_01.bitmap.dispose 
  #   @nc_01.dispose 
  #   @nc_02.bitmap.dispose
  #   @nc_02.dispose 
  #   @nc_03.bitmap.dispose
  #   @nc_03.dispose 
  #   @nc_04.bitmap.dispose
  #   @nc_04.dispose 
  #   @nc_05.bitmap.dispose
  #   @nc_05.dispose 
  #   @nc_06.bitmap.dispose
  #   @nc_06.dispose 
  #   @fa.bitmap.dispose
  #   @fa.dispose
  #   @di2.bitmap.dispose
  #   @di2.dispose
  #   @status_window.dispose
  #   battler_sprite_over
  # end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_menu_background

    #循环战斗图
       battler_update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif  Input.trigger?(Input::RIGHT) or  Keys.trigger?(Keys::D)
      Sound.play_cursor
      next_actor
      #@status_window.refresh
    elsif  Input.trigger?(Input::LEFT) or  Keys.trigger?(Keys::A)
      Sound.play_cursor
      prev_actor
    end

    super
  end


  #--------------------------------------------------------------------------
  # ● 生成角色战斗图
  #--------------------------------------------------------------------------
  def battler_picture  

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
  end

  def  battler_update
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



  def cursor_left_roght
    if Input.repeat?(:RIGHT)
      if @actor_index == $game_party.members.size-1
        @actor_index = 0
      else
        @actor_index += 1 
      end
      @actor = $game_party.members[@actor_index]
      on_actor_change
    end

    if Input.repeat?(:LEFT)
      if @actor_index == 0
        @actor_index = $game_party.members.size-1
      else
        @actor_index -= 1 
      end
      @actor = $game_party.members[@actor_index]
      on_actor_change
    end
  end



end







