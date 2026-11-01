#encoding:utf-8
#==============================================================================
# ■ Window_KeyItem
#------------------------------------------------------------------------------
# 　此窗口使用于事件指令中的“选择物品”功能。
#==============================================================================

class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0, 250, 24*14+33)
    self.openness = 0
    self.opacity = 0
    self.z = 251
    @x = -1
    @tong = 0
    deactivate
    set_handler(:ok,     method(:on_ok))
    set_handler(:cancel, method(:on_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 开始输入的处理
  #--------------------------------------------------------------------------
  def start
    back_
    self.category = :key_item
    update_placement
    #refresh
    #select(0)
    #open
    activate
  end

  def back_
    Audio.se_play("Audio/SE/book2",100,90) 
    @back = Sprite.new
    @back.bitmap = Bitmap.new("Graphics/System/KeyItem_back")
    @back.z = 250
    @back.y = 24
    @back.x = 1034+200-25
    @tong = 0
    @x = 1
    @back.tone = Tone.new(@tong,@tong,@tong,0) 
  end
    
  def col_max
    return 1
  end

  def draw_item(index)
    item = @data[index]
    if item
      rect = Rect.new
      rect.width = 150
      rect.height = 25
      draw_item_name(item, 5, index*24-1, enable?(item))
      #draw_item_number(rect, item)
    end
  end

  def make_item_list
    @data = $game_party.all_items.select {|item| !item.is_a?(RPG::EquipItem) and item.speed < 90 }
  end  
 

  def item_rect(index)
    rect = Rect.new
    rect.width = 174
    rect.height = 24
    rect.x = 35
    rect.y = index*24
    rect
  end

  def update
    super
    if @x > 0  
       @back.x -= 20 
       if @back.x <= 1034+1-25
          refresh
          select(0)
          open
          activate
          @x = -2
       end  
    end  

    if @x == -2     
      @tong += 40  
      @back.tone.set(@tong,@tong,@tong,0) 
      @x = -3 if @tong >= 255 
    end

    if @x == -3    
      @tong -= 30  
      @back.tone.set(@tong,@tong,@tong,0)
      @x = -4 if @tong <= 0
    end
  end

  #--------------------------------------------------------------------------
  # ● 更新窗口的位置
  #--------------------------------------------------------------------------
  def update_placement
    self.y = 141+24
    self.x = 1050
  end
  #--------------------------------------------------------------------------
  # ● 确定时的处理
  #--------------------------------------------------------------------------
  def on_ok
    @x = -1
    result = item ? item.id : 0
    $game_variables[$game_message.item_choice_variable_id] = result
    if @back
       @back.bitmap.dispose
       @back.dispose
    end
    dispose_back
    close
  end

  def dispose_back
    if @back
       @back.bitmap.dispose
       @back.dispose
    end
  end  
  #--------------------------------------------------------------------------
  # ● 取消时的处理
  #--------------------------------------------------------------------------
  def on_cancel
    @x = -1
    $game_variables[$game_message.item_choice_variable_id] = 0
    dispose_back
    close
  end

  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN) 
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)    
    cursor_pageup    if Input.trigger?(:LEFT) 
    cursor_pagedown  if Input.trigger?(:RIGHT)  
    cursor_down   (Keys.trigger?(Keys::S))    if Keys.repeat?(Keys::S)
    cursor_up     (Keys.trigger?(Keys::W))    if Keys.repeat?(Keys::W)
    cursor_pageup    if Keys.trigger?(Keys::A)
    cursor_pagedown  if Keys.trigger?(Keys::D) 
    Sound.play_cursor if @index != last_index
  end

end
