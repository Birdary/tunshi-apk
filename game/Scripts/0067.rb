#encoding:utf-8
#==============================================================================
# ■ Window_Expbooks
#------------------------------------------------------------------------------
# 　训练所的能力窗口
#==============================================================================

class Window_Expbook < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, Graphics.width, Graphics.height)
    @actor = actor
    self.opacity = 0
    refresh
    activate

    @flash = Sprite_Flash.new
    @flash.bitmap = Cache.flash("flash_expbook")
    @flash.x = 453
    @flash.y = 171
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @flash.bitmap.dispose
  #   @flash.dispose
  # end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    actor = @actor
    return if actor.nil?
    contents.font.name = "Noto"
    contents.font.size = 19 + $game_variables[300]
    s1 = @actor.max_level? ? "——" : @actor.exp
    s2 = @actor.max_level? ? "——" : @actor.next_level_exp - @actor.exp
    s3 = $game_party.expbook
    draw_text(550, 278-55-1, 100, line_height, "#{@actor.kill_size_all}", 0)
    draw_text(550, 333-55-1, 100, line_height, "#{@actor.dead_size_all}", 0)
    draw_text(550+178, 278-55-1, 100, line_height, "#{@actor.over_damage_all}", 0)
    draw_text(550+178, 333-55-1, 100, line_height, "#{@actor.over_sup_all}", 0)
    draw_text(550, 388-55-1, 100, line_height, "#{s2}", 0)
    draw_actor_exp0_gauge(@actor, 506, 367) #if !@actor.max_level?
    contents.font.color = Color.new(255,0,0,255) if  s3.to_i < s2.to_i 
    draw_text(550, 388+43-1, 200, line_height, "#{s3.to_i}", 0)
    contents.font.color = normal_color
    contents.font.color = Color.new(255,0,0,255) if @actor.max_x_level? 
    draw_text(550+178, 388-55-1, 100, line_height, "#{$game_variables[223]}", 0)
    contents.font.color = normal_color
    draw_expbook_gauge(@actor,506, 463)
  end


  def update
    super
    @flash.update
  end

  #--------------------------------------------------------------------------
  # ● 绘制区域 1 
  #--------------------------------------------------------------------------
  def draw_block1(y)
    draw_actor_name(@actor, 4, y)
    draw_actor_class(@actor, 128, y)
    draw_actor_nickname(@actor, 288, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 2 
  #--------------------------------------------------------------------------
  def draw_block2(y)
    draw_actor_face(@actor, 8, y)
    draw_basic_info(136, y)
    draw_exp_info(304, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制水平线
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # ● 获取水平线的颜色
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ● 绘制基本信息
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + line_height * 0)
    draw_actor_hp(@actor, x, y + line_height * 2)
    draw_actor_mp(@actor, x, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ● 绘制经验值信息
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.max_level? ? "-------" : @actor.exp
    s2 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 180, line_height, Vocab::ExpTotal)
    draw_text(x, y + line_height * 2, 180, line_height, s_next)
    change_color(normal_color)
    draw_text(x, y + line_height * 1, 180, line_height, s1, 2)
    draw_text(x, y + line_height * 3, 180, line_height, s2, 2)
  end

end