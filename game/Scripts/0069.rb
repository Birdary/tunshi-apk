#encoding:utf-8
#==============================================================================
# ■ Window_SkillStatus
#------------------------------------------------------------------------------
# 　技能画面中，显示技能使用者状态的窗口。
#==============================================================================

class Window_SkillStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, fitting_height(4))
    self.opacity = 0
    @actor = nil
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 160
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor
    #draw_actor_face(@actor, 0, 0)
    #draw_actor_simple_status(@actor, 108, line_height / 2)
    #self.contents.clear
    draw_actor_name(@actor, 174, 122)
    #draw_actor_face(@actor, 70+2, 72+2)
    #draw_basic_info(128, 32)
    #draw_exp_info(288+40, 32+42+24)
    #draw_equipments(90, 345+121+24)
    #draw_actor_exp0_gauge(@actor, x+76, y+228+24 )
    #draw_parameters(228, 223+78+24)
  end

  def draw_basic_info(x, y)
    draw_actor_level(@actor, x+114, y + WLH * 0+90)
    draw_actor_state(@actor, x+46, y + WLH * 1+40)
    draw_actor_hp(@actor, x+59, y + WLH * 2+56)
    draw_actor_mp(@actor, x+59, y + WLH * 3+56)
    draw_actor_ap(@actor, x+2+46, y + WLH * 2+56)
  end
end
