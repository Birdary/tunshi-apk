#encoding:utf-8
#==============================================================================
# ■ Window_ShopSell
#------------------------------------------------------------------------------
# 　商店画面中，卖出时显示持有物品的窗口。
#==============================================================================

class Window_ShopSell < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.opacity = 0
  end  

  #--------------------------------------------------------------------------
  # ● 获取选择项目的有效状态
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end

  #--------------------------------------------------------------------------
  # ● 查询物品是否可卖
  #--------------------------------------------------------------------------
  def enable?(item)
    item && item.price > 0
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end


  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width - 42
    rect.height = item_height-1
    rect.x = index % col_max * (item_width + spacing) + 32
    rect.y = index/ col_max * item_height
    rect
  end

  def draw_item(index)
    @data && index >= 0 ? @data[index] : nil   
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x-30, rect.y-2, enable?(item))
      _rect = rect.clone
      _rect.y += 0
      draw_item_number(_rect, item)
      draw_text(29, _rect.y ,235,23, sprintf("x%2d", $game_party.item_number(item)), 2) 
    end
  end




  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end

  def item
    @data && index >= 0 ? @data[index] : nil   
  end


  def include?(item)
    case @category
    when :item
       item.is_a?(RPG::Item) && !item.key_item? 
    when :weapon
       item.is_a?(RPG::Weapon) 
    when :armor
       item.is_a?(RPG::Armor)
    when :key_item
       item.is_a?(RPG::Item) && item.key_item? 
    else
      false
    end
  end


  def include?(item)
    case @category
    when :item
       item.is_a?(RPG::Item) && !item.key_item? 
    when :weapon
       item.is_a?(RPG::Weapon) 
    when :armor
       item.is_a?(RPG::Armor)
    when :key_item
       item.is_a?(RPG::Item) && item.key_item? 
    else
      false
    end
  end

  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end

  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN) 
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)    
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT) 
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)  
    cursor_down   (Keys.trigger?(Keys::S))    if Keys.repeat?(Keys::S)
    cursor_up     (Keys.trigger?(Keys::W))    if Keys.repeat?(Keys::W)
    cursor_right  (Keys.trigger?(Keys::D))    if Keys.repeat?(Keys::D)
    cursor_left   (Keys.trigger?(Keys::A))    if Keys.repeat?(Keys::A) 
    Sound.play_cursor if @index != last_index
  end

end
