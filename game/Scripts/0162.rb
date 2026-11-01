#encoding:utf-8
#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　计策画面
#   为了方便共通化处理，这里把计策也称为“物品”。
#==============================================================================

class Scene_Formation < Scene_ItemBase
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
    
    #create_help_window
    create_item_window
    create_actor_status_window

    create_flash_background Cache.flash("ff_flash")
    set_menu_background Cache.system("ff_big_back")
    battler_picture

  end

  def create_help_window
    super
    #@help_window.attrset(:x=>490-75,:y=>60+210)
    @help_window.attrset(:x=>30,:y=>640)
  end

  def create_actor_status_window
    @actor_status_window = Window_Status.new(@actor,:simple)
  end

  def command_yes
    $game_variables[108] = item.id
    Audio.se_play("Audio/SE/0decide1")
    @item_window.active
    @yes_no_window.deactivate
    @yes_no_window.visible = false
    @item_window.activate
    #@item_window.refresh
    use_item_map
  end

  def command_no
    @item_window.activate
    @yes_no_window.deactivate
    @yes_no_window.visible = false
    @item_window.set_skill_p
  end

  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_SkillStatus.new(0, 0)
    @status_window.actor = @actor
    @status_window.viewport = @viewport
  end

  #--------------------------------------------------------------------------
  # ● 生成计策窗口
  #--------------------------------------------------------------------------
  def create_item_window
    @yes_no_window = Window_Item_Confirmation_2.new(-148,312)
    @yes_no_window.z = 300
    @yes_no_window.visible = false
    @yes_no_window.set_handler(:command_yes,  method(:command_yes))
    @yes_no_window.set_handler(:command_no, method(:command_no))

    @item_window = Window_SkillList.new(56+30, 312-121, 348, 330+132,:formation)
    @item_window.actor = @actor
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    #我修改了，阵法在菜单中使用会出错，暂时去除按确定功能。
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.set_handler(:pagedown, method(:next_actor))
    @item_window.set_handler(:pageup,   method(:prev_actor))
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 获取技能的使用者
  #--------------------------------------------------------------------------
  def user
    @actor
  end
  #--------------------------------------------------------------------------
  # ● 指令“技能”
  #--------------------------------------------------------------------------
  def command_skill
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● 角色“取消”
  #--------------------------------------------------------------------------
  def on_actor_cancel
    super
    @actor_status_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  def on_item_ok
    @actor.last_skill.object = item
   if item.id > 3 and item.id < 22
      @yes_no_window.visible = true
      @yes_no_window.item = item
      @yes_no_window.refresh
      @yes_no_window.activate
      @yes_no_window.z = 300
      @item_window.set_skill_p_opacity
      return
   end
    determine_item
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    Sound.play_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 播放物品使用声效
  #--------------------------------------------------------------------------
  def play_se_for_item
    Sound.play_use_skill
  end
  #--------------------------------------------------------------------------
  # ● 使用物品
  #--------------------------------------------------------------------------
  def use_item
    super
    @item_window.refresh
    @actor_status_window.refresh
    @actor_window.refresh_mask
  end
  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  def on_actor_change
    @actor_status_window.actor = @actor
    @item_window.activate
    @item_window.actor = @actor
    battler_picture_change
  end

  def update
    super
    battler_update

    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @yes_no_window.visible == false
        return_scene
      else
        command_no  
      end
    elsif Input.trigger?(Input::RIGHT) or Keys.trigger?(Keys::D)
      Sound.play_cursor
      next_actor if @yes_no_window.visible == false
    elsif Input.trigger?(Input::LEFT) or Keys.trigger?(Keys::A)
      Sound.play_cursor
      prev_actor if @yes_no_window.visible == false
    end
    
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
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


class Window_Item_Confirmation_2 < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, Graphics.width, 48)
    self.opacity = 0
    @back = Sprite.new
    @back.bitmap = Cache.system("yes_no_back_f")
    @back.y = 267
    @back.z = 250
    @back.visible = false
    self.visible = false
    self.active = false
    deactivate
  end


  def item=(_item)
    @item = _item
  end

  def col_max
    return 2
  end

  def item_max
    return 2
  end

  def item_width
    60
  end

  def contents_width
    Graphics.width - 200
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    case index
    when 0
      rect.x = 600 + 240
    when 1
      rect.x = 660 + 240
    end
    rect.y = (index / col_max * item_height)
    rect
  end

  def make_command_list
    add_command("是", :command_yes)
    add_command("否", :command_no)
  end


  def draw_item(index)
    change_color(normal_color, command_enabled?(index))

    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    rect.y += 2
    contents.font.size = 18 + $game_variables[300]
    draw_text(rect, command_name(index), alignment)
  end


  def refresh
    contents.clear
    super
    if @item
      draw_item_name(@item, 400 + 330, 0-1, true, 172)
    end
  end

  def yes?
    index == 0
  end

  # 无需手动释放
  # def dispose
  #   super
  #   @back.dispose
  #   @back.bitmap.dispose
  # end

  def update
    super
    self.visible = self.active
    @back.visible = self.active
  end

  def process_cursor_move
      return unless cursor_movable?
      last_index = @index
      cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
      cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT) 
      cursor_right  (Keys.trigger?(Keys::D))    if Keys.repeat?(Keys::D)
      cursor_left   (Keys.trigger?(Keys::A))    if Keys.repeat?(Keys::A) 
      Sound.play_cursor if @index != last_index
  end
  
end