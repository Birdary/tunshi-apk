#encoding:utf-8
#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　物品画面
#==============================================================================

class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_item_window

    create_flash_background Cache.flash("ditem")
    set_menu_background Cache.system("ditem")
  end

  def create_help_window
    super
    @help_window.attrset(:x=>30,:y=>640)
  end

  #--------------------------------------------------------------------------
  # ● 生成物品窗口
  #--------------------------------------------------------------------------
  def create_item_window
    @yes_no_window = Window_Item_Confirmation.new(-148,312)
    @yes_no_window.z = 300
    @yes_no_window.visible = false
    @yes_no_window.set_handler(:command_yes,  method(:command_yes))
    @yes_no_window.set_handler(:command_no, method(:command_no))

    @item_window = Window_Item.new(56+60-30, 90+120-30-29, 348-75+75+214, 330+132+36)
    @item_window.attrset(:viewport=>@viewport,:active=>true)
    @item_window.help_window = @help_window

    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
  end

  def command_yes
    if item.id == 22 or item.id == 23
      Audio.se_play("Audio/SE/0decide1")
    elsif item.id == 24
      if $game_variables[125] == 0
        Audio.se_play("Audio/SE/Buzzer1")
      else
        Audio.se_play("Audio/SE/0decide1")
      end 
    end
    use_item_map
    @item_window.active
    @yes_no_window.deactivate
    @yes_no_window.visible = false
  end

  def command_no
    @item_window.activate
    @yes_no_window.deactivate
    @yes_no_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  def on_item_ok
    $game_party.last_item.object = item

    if item.note[0,2] == "ks"
      @yes_no_window.visible = true
      @yes_no_window.item = item
      @yes_no_window.refresh
      @yes_no_window.activate
      @yes_no_window.z = 300
      return
    end

    @menuback_sprite.bitmap = Cache.system("ditem_2")
    case $game_party.members.size
    when 1
      @flash_background.bitmap = Cache.flash("ditem_1")
    when 2
      @flash_background.bitmap = Cache.flash("ditem_2")
    when 3
      @flash_background.bitmap = Cache.flash("ditem_3")
    when 4
      @flash_background.bitmap = Cache.flash("ditem_4")
    when 5
      @flash_background.bitmap = Cache.flash("ditem_5")
    when 6
      @flash_background.bitmap = Cache.flash("ditem_5")    
    when 7
      @flash_background.bitmap = Cache.flash("ditem_5")
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
  # ● 角色“取消”
  #--------------------------------------------------------------------------
  def on_actor_cancel
    super
    @flash_background.bitmap = Cache.flash("ditem")
    @menuback_sprite.bitmap = Cache.system("ditem")
  end
  #--------------------------------------------------------------------------
  # ● 播放使用物品声效
  #--------------------------------------------------------------------------
  def play_se_for_item
    # Sound.play_use_item
    if item.for_dead_friend?
      Audio.se_play("Audio/SE/Starlight")
      Audio.se_play("Audio/SE/heal3")
      Audio.se_play("Audio/SE/Saint7")
    elsif item.speed == 3 
      Audio.se_play("Audio/SE/J_qian") 
    else
      Audio.se_play("Audio/SE/Saint6")
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用物品
  #--------------------------------------------------------------------------
  def use_item
    a = true
    # 赤心单
    if item.damage.element_id == 5 and item.id != 30 
      if $game_party.target_actor.hp == 0 or $game_party.target_actor.hp == $game_party.target_actor.mhp
        a = false
      end
    end
    # 招魂丹
    if item.damage.element_id == 9 
      if $game_party.target_actor.hp != 0 
        a = false
      end 
    end
    # 智复丹
    if item.damage.type == 4 
      if $game_party.target_actor.mp == $game_party.target_actor.mmp 
        a = false
      end
    end
    # 辅助丹
    if item.for_friend? and item.damage.type == 0 and item.speed == 3
      if $game_party.target_actor.element_rate(36) >= 4.0
        a = false
      end
      a = false if $game_party.target_actor.state?(72) and item.id == 53
      a = false if $game_party.target_actor.state?(73) and item.id == 54
      a = false if $game_party.target_actor.state?(74) and item.id == 55
      a = false if $game_party.target_actor.state?(75) and item.id == 56
      a = false if $game_party.target_actor.state?(77) and item.id == 57
      a = false if $game_party.target_actor.state?(76) and item.id == 58
      a = false if $game_party.target_actor.state?(78) and item.id == 59
      a = false if $game_party.target_actor.state?(80) and item.id == 60
    end

    if a
      super
      @item_window.redraw_current_item
      @actor_window.refresh_mask
      @actor_window.refresh_actor_tp100
      return 
    else
      Sound.play_buzzer
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 隐藏目标窗口
  #--------------------------------------------------------------------------
  def hide_target_window
    @item_window.active = true
    @target_window.visible = false
    @target_window.active = false
    @viewport.rect.set(0, 0, 1280, 720)
    @viewport.ox = 0
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @yes_no_window.visible == false
        return_scene
      else
        command_no  
      end
    end      
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   dispose_flash_background
  #   dispose_menu_background
  #   if @flash_background
  #     @flash_background.bitmap.dispose 
  #     @flash_background.dispose 
  #   end
  #   if @menuback_sprite
  #     @menuback_sprite.bitmap.dispose
  #     @menuback_sprite.dispose 
  #   end
  # end
end



class Window_Item_Confirmation < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, Graphics.width, 48)
    self.opacity = 0
    @back = Sprite.new
    @back.bitmap = Cache.system("yes_no_back")
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

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose
  #   @back.dispose
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