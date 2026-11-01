#encoding:utf-8
#==============================================================================
# ■ Window_Item
#------------------------------------------------------------------------------
# 　物品画面、战斗画面、显示浏览物品的窗口。
#==============================================================================

class Window_Item < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口 X 座标
  #     y      : 窗口 Y 座标
  #     width  : 窗口宽度
  #     height : 窗口高度
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.index = 0
    @data = []
    refresh
    self.opacity = 0
    self.contents.font.size = 12 + $game_variables[300]
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 光标向下移动
  #--------------------------------------------------------------------------
  #def cursor_down(wrap = false)
    #msgbox 123
    #if index < item_max - col_max || (wrap && col_max == 1)
      #select((index + 1) % item_max)
    #end
    #self.index += 1
    #msgbox self.index
  #  return
  #end
  #--------------------------------------------------------------------------
  # ● 光标向上移动
  #--------------------------------------------------------------------------
  #def cursor_up(wrap = false)
    #self.index -= 1
    #if index >= col_max || (wrap && col_max == 1)
    #  select((index - 1 + item_max) % item_max)
    #end
  #  return
  #end
  #--------------------------------------------------------------------------
  # ● 判断是否为物品
  #     item : 项目
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    if $game_party.in_battle
      return false unless item.is_a?(RPG::Item)  
    end

if item.is_a?(RPG::Item)
    if SceneManager.scene.is_a?(Scene_Cj) and item.speed >= 90 
       return true  
    elsif SceneManager.scene.is_a?(Scene_Item) and item.speed < 90 
       return true
    end
else
     return false if SceneManager.scene.is_a?(Scene_Cj) 
     return true if SceneManager.scene.is_a?(Scene_Item) 
end



  end


  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
=begin
  def refresh
    @data.clear
    for item in $game_party.items
      next unless include?(item)
      @data.push(item)
      last_item = $game_party.last_item.object
      if item.is_a?(RPG::Item) and !last_item.nil? and item.id == last_item.id
        self.index = @data.size - 1
      end
    end
    @data.push(nil) if include?(nil)
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
=end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width - 25 - 5
    rect.height = item_height-1
    rect.x = index % col_max * (item_width + spacing) + 30
    rect.y = index/ col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
=begin
    rect = item_rect(index)
    rect.y += 2
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_party.item_number(item)
      enabled = enable?(item)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, sprintf("x%2d", number), 2)
    end
=end
    if SceneManager.scene.is_a?(Scene_Item)
      item = @data[index]
      number = $game_party.item_number(item)
      rect = item_rect(index)
      rect.y -= 2 
      draw_item_name(item, rect.x-30, rect.y, enable?(item))  
      rect.width -= 4
      _rect = rect.clone
      _rect.y += 2

     # _rect.x += 10
      #draw_text(_rect, "x")
      _rect.x -= 2
      draw_text(_rect, "x" + "#{$game_party.item_number(item)}",2)

    else

      item = @data[index]
      number = $game_party.item_number(item)
      rect = item_rect(index)
      rect.y = 0
      if index == 0
        draw_item_name(item, rect.x, rect.y+1, enable?(item))  
      else
        draw_item_name(item, rect.x+48, rect.y+1, enable?(item))  
      end

      rect.width -= 4
      _rect = rect.clone
      _rect.y += 4
      draw_item_number(_rect, item)   

    end
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助窗口文字
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end



end

#==============================================================================
# ■ Window_Item
#------------------------------------------------------------------------------
# 　物品画面、战斗画面、显示浏览物品的窗口。
#==============================================================================

class Window_Cj < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口 X 座标
  #     y      : 窗口 Y 座标
  #     width  : 窗口宽度
  #     height : 窗口高度
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.index = 0
    @data = []
    g_data
    create_icon
    refresh
    self.opacity = 0
    self.contents.font.size = 12 + $game_variables[300]
    refresh_icon
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 15
  end
 
  def include?(item)
    return false if item == nil
    if $game_party.in_battle
      return false unless item.is_a?(RPG::Item)  
    end

    if item.is_a?(RPG::Item)
        if SceneManager.scene.is_a?(Scene_Cj) and item.id >= 304 and item.speed >= 90 and item.id != 300
           return true  
        elsif SceneManager.scene.is_a?(Scene_Item) and item.speed < 90 
           return true
        end
    else
         return false if SceneManager.scene.is_a?(Scene_Cj) 
         return true if SceneManager.scene.is_a?(Scene_Item) 
    end

  end


  def g_data
      @data_ = []
      for i in 304...481
         @data_ << $data_items[i] if $data_items[i].speed == 91
      end   
  end    
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)

    item = @data_[index]
    number = $game_party.item_number(item)
    rect = item_rect(index)
    
    if item != nil 
      name = "zzz" + "#{item.price}"
      #@back.bitmap.blt(rect.x ,rect.y,Cache.picture(name),Rect.new(30,11,42,42))
      if item.repeats == 1
        # @back.bitmap.blt(rect.x-4+2 ,rect.y-4+2,Cache.system("cj_quan"),Rect.new(0,0,50,50))
      elsif item.repeats == 2
         #@back.bitmap.blt(rect.x-4+2 ,rect.y-4+2,Cache.system("cj_quan"),Rect.new(50,0,50,50))
      else
         #@back.bitmap.blt(rect.x-4+2 ,rect.y-4+2,Cache.system("cj_quan"),Rect.new(100,0,50,50))
      end
    end

  end

 def item_rect(index)
    rect = Rect.new
    rect.width = 50
    rect.height = 50
    rect.x = index % col_max * 54
    rect.y = index/ col_max * 54
    rect
  end


  def create_icon
      @icon = Sprite.new
      @icon.bitmap = Bitmap.new(65,65)
      @icon.x = 288+112-109-50-4
      @icon.y = 77
      @icon.z = 999 
      
      @back = Sprite.new
      @back.bitmap = Bitmap.new(1000,600)
      @back.x = 50+16+20
      @back.y = 190+16
      @back.z = 800

  end   

  def refresh_icon
      item = @data[index]
         if item != nil 
      name = "zzz" + "#{item.price}"
      @icon.bitmap.clear
      @icon.bitmap.blt(0,0,Cache.picture(name),Rect.new(19,0,64,64))
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助窗口文字
  #--------------------------------------------------------------------------
  def update_help
      @help_window.set_text(item == nil ? "" : item.description)
     # refresh_icon
  end

  # => 无需手动释放
  def dispose
    if @icon
      @icon.bitmap.dispose
      @icon.dispose
    end 
    if @back
      @back.bitmap.dispose
      @back.dispose
    end 
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

class WindowCJSelectItem < Window_Selectable
  def initialize(x, y, width, height,data)
    @data = data
    super(x, y, width, height)
    self.opacity = 0
    self.select(0)
    self.activate
    @cache_icon_back_exist = Bitmap.new("Graphics/System/jm_icon_back")
    @cache_icon_back_non = Bitmap.new("Graphics/System/no_jm_icon_back")
    @cache_icon = Bitmap.new("Graphics/System/jm_icon")
    refresh
  end

  def item_width
    return 303 -61
  end

  def item_height
    return 54
  end

  def col_max
    return 3
  end

  def item_max
    return @data.size
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height - 4
    rect.x = index % col_max * (item_width)# + spacing)
    rect.y = index / col_max * item_height
    rect
  end

  def draw_item(index)
    item = @data[index]
    exist_item =  $game_party.has_item?(item)
    x = 0+3 + index % col_max * (item_width)
    y = 3 + index / col_max * item_height
    rect = Rect.new(0,0,303,54)
    src_bitmap = exist_item ? @cache_icon_back_exist : @cache_icon_back_non
    self.contents.blt(x,y,src_bitmap,rect,255)

    if exist_item
      offset_x = 12
      icon_x = index % 10 * 64
      icon_y = (index / 10).to_i * 64
      rect = Rect.new(icon_x+10,icon_y+10,44,44)
      self.contents.blt(x + offset_x,y,@cache_icon,rect,255)
      self.contents.draw_text(x+105,y+7,200,32,"#{item.name}")
    end

  end

  def refresh
    # create_contents

    # draw_all_items
    super
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @cache_icon_back_exist.dispose
  #   @cache_icon_back_non.dispose
  #   @cache_icon.dispose
  # end

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
    SceneManager.scene.refresh_current_item(@index)
  end

end
