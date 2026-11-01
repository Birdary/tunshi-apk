#encoding:utf-8
#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　显示特技和物品等的说明、以及角色状态的窗口
#==============================================================================

class Window_Help < Window_Base
  DEFAULT_COLOR = Color.new(255,255,255,255)
  RED_COLOR = Color.new(255,0,0,255)
  GREEN_COLOR = Color.new(0,255,0,2555)
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(line_number = 10)
    super(0, 0, 1100, fitting_height(line_number))
   line_number = 5

    self.opacity = 0
    @font_size = 18
    @color = DEFAULT_COLOR
    @show_back = false
    create_background
  end
  def create_background
    @back = Sprite.new
    @back.bitmap = Cache.system("skill_picture_back")
    @back.visible = false
    @back.x = 0
    @back.y = 0
    @back.z = 1
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose if @back.bitmap
  #   @back.dispose
  # end

  #--------------------------------------------------------------------------
  # ● 设置内容
  #--------------------------------------------------------------------------
  def set_text(text,color=nil)
    if text != @text
      @text = text
      @color = case color
        when "red"; RED_COLOR
        when "green"; GREEN_COLOR
        when Color; color
        else
          DEFAULT_COLOR
      end
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    set_text("")
    @back.dispose
  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #     item : 技能、物品等
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text(item ? item.description : "")
    if $game_party.in_battle
      @back.x = self.x 
      @back.y = 630 
    end
  end

  def font_size=(size)
    @font_size = size
  end
  def show_back
    @show_back = true
  end
  def hide_back
    @show_back = false
  end
  def update
    super
    if $game_party.in_battle
      @back.visible = @show_back
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.name = (["Noto"])
    contents.font.size = @font_size
    contents.font.color = @color
    draw_text_ex(63, 0, @text)
    @color = DEFAULT_COLOR
    
    if $game_party.in_battle
      @show_back = true
      @back.visible = true
      @back.x = self.x 
      @back.y = 630
    end
    update
  end
end
