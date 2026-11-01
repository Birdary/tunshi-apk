#encoding:utf-8
#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　菜单画面中显示指令的窗口
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化指令选择位置（类方法）
  #--------------------------------------------------------------------------
  def self.init_command_position
    @@last_command_symbol = nil
  end
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(740, 118)
    self.height = 480+200
    select_last
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    return 660
  end
  #--------------------------------------------------------------------------
  # ● 获取显示行数
  #--------------------------------------------------------------------------
  def visible_line_number
    item_max
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_commands
    #add_formation_command
    #add_original_commands
    #add_save_command
    #add_game_end_command
  end
  #--------------------------------------------------------------------------
  # ● 向指令列表添加主要的指令
  #--------------------------------------------------------------------------
  def add_main_commands
    add_command(Vocab::BLANK,   :status, main_commands_enabled)
    add_command(Vocab::BLANK,   :item,   main_commands_enabled)
    add_command(Vocab::BLANK,   :marv,   main_commands_enabled)
    add_command(Vocab::BLANK,   :skill,  main_commands_enabled)
    add_command(Vocab::BLANK,   :equip,  main_commands_enabled)
    add_command(Vocab::BLANK,   :dl,     main_commands_enabled)
    # add_command(Vocab::BLANK,   :formation, main_commands_enabled)
    add_command(Vocab::BLANK,   :formation, formation_enabled)
    add_command(Vocab::BLANK,   :cj,     main_commands_enabled)
    add_command(Vocab::BLANK,   :system, main_commands_enabled)
    add_command(Vocab::BLANK,   :save,   save_enabled)
    add_command(Vocab::BLANK,   :exit,   true)
    
  end
  #--------------------------------------------------------------------------
  # ● 添加整队指令
  #--------------------------------------------------------------------------
  def add_formation_command
    add_command(Vocab::BLANK, :formation, formation_enabled)
  end
  #--------------------------------------------------------------------------
  # ● 独自添加指令用
  #--------------------------------------------------------------------------
  def add_original_commands
  end
  #--------------------------------------------------------------------------
  # ● 添加存档指令
  #--------------------------------------------------------------------------
  #def save_enabled

 # end

  #--------------------------------------------------------------------------
  # ● 添加游戏结束指令
  #--------------------------------------------------------------------------
  def add_game_end_command
    add_command(Vocab::BLANK, :game_end)
  end
  #--------------------------------------------------------------------------
  # ● 获取主要指令的有效状态
  #--------------------------------------------------------------------------
  def main_commands_enabled
    $game_party.exists
  end
  #--------------------------------------------------------------------------
  # ● 获取是否禁用菜单阵型
  #--------------------------------------------------------------------------
  def formation_enabled
    !$game_switches[539]
  end
  # #--------------------------------------------------------------------------
  # # ● 获取整队的有效状态
  # #--------------------------------------------------------------------------
  # def formation_enabled
  #   $game_party.members.size >= 2 && !$game_system.formation_disabled
  # end
  #--------------------------------------------------------------------------
  # ● 获取存档的有效状态
  #--------------------------------------------------------------------------
  def save_enabled
    !$game_system.save_disabled
  end
  #--------------------------------------------------------------------------
  # ● 按下确定键时的处理
  #--------------------------------------------------------------------------
  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
  #--------------------------------------------------------------------------
  # ● 返回最后一个选项的位置
  #--------------------------------------------------------------------------
  def select_last
    select_symbol(@@last_command_symbol)
  end
  #--------------------------------------------------------------------------
  # ● 获取行高
  #--------------------------------------------------------------------------
  def line_height
    return 33
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = 200#+55#item_width
    rect.height = item_height - 4
    case index
    when 0; x = 188; when 1; x = 188;
    when 2; x = 188; when 3; x = 188;
    when 4; x = 188; when 5; x = 188;      
    when 6; x = 188; when 7; x = 188;
    when 8; x = 188; when 9; x = 188; when 10; x = 188+160; end;
    rect.x = x #index % col_max * (item_width + spacing) + 276 - index * 32
    rect.y = index / col_max * 45 + index * 8 + 22

    # fixed
    if index == 10
      rect.y -= 4
      rect.width -= 95
    end

    rect
  end
end

class Window_MenuCommandYesno < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x,y)
    super(x, y)
    
    @back = Sprite.new
    @back.bitmap = Bitmap.new("Graphics/System/over_yes_no")
    @back.x = 0
    @back.y = y
    @back.z = 10001
    @back.visible = false

    @mesk = Sprite.new
    @mesk.bitmap = Bitmap.new(1280,704)
    @mesk.bitmap.fill_rect(0, 0, 1280, 704, Color.new(0,0,0,255)) 
    @mesk.x = 0
    @mesk.y = 0
    @mesk.z = 10000
    @mesk.opacity = 192
    @mesk.visible = false

    self.z = 10002
    self.visible = false
    self.opacity = 0
    self.width = @back.bitmap.width
    self.height = @back.bitmap.height

    self.hide

  end
  def visible_line_number
    item_max
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_commands
  end
  def show
    @back.visible = true
    @mesk.visible = true
    # self.opacity = 255
    self.visible = true
    self.activate
    select(0)
  end
  def hide
    @back.visible = false
    @mesk.visible = false
    # self.opacity = 0
    self.visible = false
    self.deactivate
  end
  def add_main_commands
    add_command(Vocab::BLANK,   :yes, true)
    add_command(Vocab::BLANK,   :no,   true)
  end
  def line_height
    return 33
  end
  def item_rect(index)
    rect = Rect.new
    rect.width = 64
    rect.height = item_height - 4


    rect.x = 730 + index * 64
    rect.y = 130

    rect
  end

  #--------------------------------------------------------------------------
  # ● 按下取消键时的处理
  #--------------------------------------------------------------------------
  # def process_cancel
  #   hide
  # end
  #--------------------------------------------------------------------------
  # ● 调用“取消”的处理方法
  #--------------------------------------------------------------------------
  # def call_cancel_handler
  #   call_handler(:no)
  # end

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose
  #   @back.dispose
  #   @mesk.bitmap.dispose
  #   @mesk.dispose
  # end

end
