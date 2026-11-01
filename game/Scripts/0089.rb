#encoding:utf-8
#==============================================================================
# ■ Window_ChoiceList
#------------------------------------------------------------------------------
# 　此窗口使用于事件指令中的“显示选项”的功能。
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0)
    self.openness = 0
    self.opacity = 0
     @x = -1
     @tong = 0
    deactivate
    self.z = 200
  end
  #--------------------------------------------------------------------------
  # ● 开始输入的处理
  #--------------------------------------------------------------------------
  def start
    @y = 0
    @y = -26 #if $game_party.in_battle
    @map_select = Sprite.new
    @map_select.x = 718
    @map_select.y = 0+@y
    @map_select.z = 100
    @map_select.bitmap = Cache.system("map_select")  
    @map_select.visible = false
    @map_select.z = 199
    @tong = 0
    @map_select.tone = Tone.new(@tong,@tong,@tong,0) 
    update_placement
  
    activate
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置
  #--------------------------------------------------------------------------
  def update_placement
    Audio.se_play("Audio/SE/book2",100,90) 
    self.width = [max_choice_width+12+30 , 96].max + padding * 2
    self.width = [width, Graphics.width].min
    self.height = 300 #fitting_height($game_message.choices.size)
    self.x = Graphics.width - width
    #if @message_window.y >= Graphics.height / 2
      case $game_message.choices.size
      when 4
         self.y = 406 + @y#@message_window.y - height - 15
      when 3
         self.y = 406+36+ @y
      when 2
         self.y = 406+72+ @y
      when 1
         self.y = 406+108+ @y
      end  
    #else
     # self.y = @message_window.y + @message_window.height 
    #end
    @map_select.bitmap = Cache.system("map_select_"+$game_message.choices.size.to_s) 
    @x = 718-self.width

    @map_select.visible = true

  end
  #--------------------------------------------------------------------------
  # ● 获取选项的最大宽度
  #--------------------------------------------------------------------------
  def max_choice_width
    $game_message.choices.collect {|s| text_size(s).width }.max
  end
  #--------------------------------------------------------------------------
  # ● 计算窗口内容的高度
  #--------------------------------------------------------------------------
  def contents_height
    item_max * item_height + 200
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    $game_message.choices.each do |choice|
      add_command(choice, :choice)
    end
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width 
    rect.height = item_height
    #rect.x = index % col_max * (item_width + spacing) #+ 30
    rect.y = (36 * index)
    rect
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    draw_text_choice(rect.x+2, 36 * index-1, command_name(index))
  end
  #--------------------------------------------------------------------------
  # ● 获取“取消处理”的有效状态
  #--------------------------------------------------------------------------
  def cancel_enabled?
    $game_message.choice_cancel_type > 0
  end
  #--------------------------------------------------------------------------
  # ● 调用“确定”的处理方法
  #--------------------------------------------------------------------------
  def call_ok_handler
    $game_message.choice_proc.call(index)
    @x = -1
    close
    @map_select.visible = false
    @map_select.bitmap.dispose
    @map_select.dispose

  end
  #--------------------------------------------------------------------------
  # ● 调用“取消”的处理方法
  #--------------------------------------------------------------------------
  def call_cancel_handler
    $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
    @x = -1
    close
    @map_select.visible = false
    @map_select.bitmap.dispose
    @map_select.dispose
  end

  def update
    super

    if @x > 0 
      @map_select.x -= 20  
      if @map_select.x <= @x
        # Audio.se_play("Audio/SE/J_qian",100) 
        @x = -2
        refresh
        select(0)
        open
      end  
    end  

    if @x == -2       
      @tong += 40  
      @map_select.tone.set(@tong,@tong,@tong,0)
      @x = -3 if @tong >= 255 
    end

    if @x == -3       
      @tong -= 30  
      @map_select.tone.set(@tong,@tong,@tong,0)
      @x = -4 if @tong <= 0
    end
  end

end
