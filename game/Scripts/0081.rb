#encoding:utf-8
#==============================================================================
# ■ Window_EquipStatus
#------------------------------------------------------------------------------
# 　装备画面中，显示角色能力值变化的窗口。
#==============================================================================

class Window_EquipStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y-36, window_width+50, window_height+140+60)
    @actor = nil
    @temp_actor = nil
    @mode = :full
    @ok = 1
    #refresh
    self.opacity = 0

    @nc_05=Sprite.new
    @nc_05.bitmap = Cache.picture("nc_g")
    @nc_05.x = 95+28
    @nc_05.y = 225-40+260-30
    

    @nc_06=Sprite.new
    @nc_06.bitmap =Cache.picture("nc_f")
    @nc_06.x = 95+28
    @nc_06.y = 225-20+260-24
    

    @nc_01=Sprite.new
    @nc_01.bitmap = Cache.picture("nc")
    @nc_01.x = 95+28
    @nc_01.y = 225+260-18
    

    @nc_02=Sprite.new
    @nc_02.bitmap = Cache.picture("nc")
    @nc_02.x = 95+28
    @nc_02.y = 225+20+260-12
    

    @nc_03=Sprite.new
    @nc_03.bitmap = Cache.picture("nc")
    @nc_03.x = 95+28
    @nc_03.y = 225+40+260-6
    

    @nc_04=Sprite.new
    @nc_04.bitmap = Cache.picture("nc")
    @nc_04.x = 95+28
    @nc_04.y = 225+60+260

    #refresh_params_gauge
  end

  def simple_mode
    @mode = :simple
    for i in 5..6
      eval("@nc_0#{i}.visible = false")
    end
    refresh
  end

  def full_mode
    @mode = :full
    for i in 5..6
      eval("@nc_0#{i}.visible = true")
    end
    refresh
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   for i in 1..6
  #     eval("@nc_0#{i}.dispose ; @nc_0#{i}.bitmap.dispose")
  #   end
  # end

  def change_nc_pos(x,y)
    for i in 1..6
      eval("@nc_0#{i}.x += x ; @nc_0#{i}.y += y")
    end
  end


  def refresh_params_gauge
     @ok = 1
    n1=@actor.str ; n2=@actor.ski ; n3=@actor.int
    n4=@actor.agi ; n5=@actor.atk ; n6=@actor.def
    @nc_05.src_rect = Rect.new 0, 0, n5, 6
    @nc_06.src_rect = Rect.new 0, 0, n6, 6
    @nc_01.src_rect = Rect.new 0, 0, n1, 6
    @nc_02.src_rect = Rect.new 0, 0, n2, 6
    @nc_03.src_rect = Rect.new 0, 0, n3, 6
    @nc_04.src_rect = Rect.new 0, 0, n4, 6
  end

  def clear_gauge
    for i in 1..6
      eval("@nc_0#{i}.src_rect = Rect.new 0,0,0,0")
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    return 420+100
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● 获取显示行数
  #--------------------------------------------------------------------------
  def visible_line_number
    return 7
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
     @ok = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    clear_gauge
    return if @actor.nil?
    contents.font.size = 19 + $game_variables[300]

    set_font_01
    6.times {|i| draw_item(0, line_height * (1 + i), 2 + i) }
    
    self.contents.font.color = normal_color
    x = 356 ; y = 72 ; h = 20;
    if @ok == 1
      if @mode == :full
         draw_text(x+18-5, y+30 + h * 1-1, 40, line_height, (@actor.atk).to_i, 2)
         draw_text(x+18-5, y+30+6 + h * 2-1, 40, line_height, (@actor.def).to_i, 2)
      end
      draw_text(x+18-5, y+30+12 + h * 3-1, 40, line_height, @actor.str, 2)
      draw_text(x+18-5, y+30+18 + h * 4-1, 40, line_height, @actor.ski, 2)
      draw_text(x+18-5, y+30+24 + h * 5-1, 40, line_height, @actor.int, 2)
      draw_text(x+18-5, y+30+30 + h * 6-1, 40, line_height, @actor.agi, 2)
    end
    set_font_01

    refresh_params_gauge
    if SceneManager.scene.is_a?(Scene_Equip) 
       draw_text(x+0-210+37,    y+40+180-2, 40, line_height, ($game_party.item_number($data_items[35])).to_i, 0)
       draw_text(x+53-210+37,   y+40+180-2, 40, line_height, ($game_party.item_number($data_items[36])).to_i, 0)
       draw_text(x+53*2-210+37, y+40+180-2, 40, line_height, ($game_party.item_number($data_items[37])).to_i, 0)
       draw_text(x+53*3-210+38, y+40+180-2, 40, line_height, ($game_party.item_number($data_items[38])).to_i, 0)
    end
  end

  #--------------------------------------------------------------------------
  # ● DIY {actor.method => {:x=>0,:y=>0}}
  #--------------------------------------------------------------------------
  def diy(hash)
    hash.each_pair do |k,v|
      draw_text(v[:x], v[:y], 64, line_height, @actor.send(k)) if @actor.respond_to? k
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置更换装备后的临时角色
  #--------------------------------------------------------------------------
  def set_temp_actor(temp_actor)
    return if @temp_actor == temp_actor
    @temp_actor = temp_actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    set_font_01
    contents.font.size = 19 + $game_variables[300]
    #draw_param_name(x + 4, y, param_id)
    # draw_current_param(x + 94, y, param_id) if @actor
    #draw_right_arrow(x + 126, y)
    draw_new_param(x + 150, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # ● 绘制能力值的名字
  #--------------------------------------------------------------------------
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  #--------------------------------------------------------------------------
  # ● 绘制当前能力值
  #--------------------------------------------------------------------------
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 32, line_height, @actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制右方向箭头
  #--------------------------------------------------------------------------
  def draw_right_arrow(x, y)
    change_color(system_color)
    draw_text(x, y, 22, line_height, "→", 1)
  end
  #--------------------------------------------------------------------------
  # ● 绘制更换装备后的能力值
  #--------------------------------------------------------------------------
  def draw_new_param(x, y, param_id)
    case param_id
    when 2
      new_value = @temp_actor.str
      change_color(param_change_color(new_value - @actor.str))
      draw_text(x-53-5, y, 32+285, line_height+298, new_value, 2) 
    when 3
      new_value = @temp_actor.ski
      change_color(param_change_color(new_value - @actor.ski))
      draw_text(x-53-5, y, 32+285, line_height+298+4, new_value, 2) 
    when 4
      new_value = @temp_actor.int
      change_color(param_change_color(new_value - @actor.int))
      draw_text(x-53-5, y, 32+285, line_height+298+8, new_value, 2) 
    when 5
      new_value = @temp_actor.def
      change_color(param_change_color(new_value - @actor.def))
      draw_text(x-53-5, y, 32+285, line_height+298+12-208, new_value, 2) 
    when 6
      new_value = @temp_actor.agi
      change_color(param_change_color(new_value - @actor.agi))
      draw_text(x-53-5, y, 32+285, line_height+298-36, new_value, 2) 
    when 7
      new_value = @temp_actor.atk
      change_color(param_change_color(new_value - @actor.atk))
      draw_text(x-53-5, y-74, 32+285, line_height+298+12-208, new_value, 2) 
    end 
    contents.font.size = 19 + $game_variables[300]
    @ok = 0
  end

end
