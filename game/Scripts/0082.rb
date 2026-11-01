#encoding:utf-8
#==============================================================================
# ■ Window_BattleItem
#------------------------------------------------------------------------------
# 　战斗画面中，选择“使用物品”的窗口。
#==============================================================================

class Window_BattleItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     info_viewport : 信息显示用的显示端口
  #--------------------------------------------------------------------------
  def initialize(help_window, info_viewport)
    super(1076, 160-22, 200, 277)
    self.visible = false
    @help_window = help_window
    @show_back = false
    self.opacity = 0
    self.z = 200
    create_background
    create_flash
  end

  def create_background
    @back = Sprite.new(@info_viewport)
    @back.bitmap = Cache.system("skill_back_kong")
    @back.visible = false
    @back.x = 0
    @back.y = 460-359
    @back.z = 100

    @back_tag = Sprite.new(@info_viewport)
    @back_tag.bitmap = Cache.system("select_tag")
    @back_tag.visible = false
    @back_tag.x = 1004
    @back_tag.z = 101
  end

  def create_flash
    @flash = Sprite_Flash.new(@info_viewport)
    @flash.bitmap = Cache.flash("Battlecomm2_kong")
    @flash.visible = false
    @flash.x = 76
    @flash.y = 460-359
    @flash.z = 150
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   [@back,@flash,@back_tag].each do |sp|
  #     sp.dispose
  #     sp.bitmap.dispose if sp.bitmap
  #   end
  #   @help_window.dispose
  # end

  def set_background
    @back.bitmap = Cache.system("skill_back_kong")
    @back.bitmap.clear
    @flash.bitmap.clear
    h = 0
    h = @data.size 
    h = 1 if h < 1 
    if h < 10
      hi = (10 - h) * 24
      self.height == 277 - hi
      @back.bitmap.blt(0,0,Cache.system("skill_back_item"),Rect.new(0,0,311,290-hi)) 
      @flash.bitmap.blt(0,0,Cache.flash("Battlecomm22"),Rect.new(0,0,251,61)) 
      @flash.bitmap.blt(0,61,Cache.flash("Battlecomm22"),Rect.new(0,61+hi,251,250)) 
    else
      @back.bitmap.blt(0,0,Cache.system("skill_back_item"),Rect.new(0,0,311,290)) 
      @flash.bitmap.blt(0,0,Cache.flash("Battlecomm2"),Rect.new(0,0,251,320)) 
    end   
  end

  def back_opacity=(n)
    @back.opacity = @flash.opacity = n
  end

  def init_back(dir)
    if dir == 4
      @back.x = 600+370 ; @flash.x = 600+370+76 ; self.x = 1076-52 ; @back_tag.x = 1004 
    end
    if dir == 6
      @back.x = 700+370 ; @flash.x = 700+370+76 ; self.x = 1176-52  ; @back_tag.x = 1104 
    end
  end

  def change_back_x(x,dir)
    if dir == 4
      @back.x -= x ; @flash.x -= x ; self.x -= x ; @back_tag.x -= x
      @back_tag.y = 125+24
    end
    if dir == 6
      @back.x += x ; @flash.x += x ; self.x += x ; @back_tag.x += x
    end
  end

  def change_back_opacity(x,flag)
    if flag == "+"
      @back.opacity += x ; @flash.opacity += x ; self.contents_opacity += x  ; @back_tag.opacity += x 
    end
    if flag == "-"
      @back.opacity -= x ; @flash.opacity -= x ; self.contents_opacity -= x  ; @back_tag.opacity -= x 
      cursor_rect.x = 1300
    end
  end

  #--------------------------------------------------------------------------
  # ● 光标向右移动
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if top_row + page_row_max < row_max
      self.top_row += page_row_max
      select([@index + page_item_max, item_max - 1].min)
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标向左移动
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if top_row > 0
      self.top_row -= page_row_max
      select([@index - page_item_max, 0].max)
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 查询使用列表中是否含有此物品
  #--------------------------------------------------------------------------
  def include?(item)
    $game_party.usable?(item)
  end
  #--------------------------------------------------------------------------
  # ● 显示窗口
  #--------------------------------------------------------------------------
  def show
    select_last
    @help_window.show
    show_back_tag
    super
  end
  #--------------------------------------------------------------------------
  # ● 隐藏窗口
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide
    super
  end
  def show_back
    @show_back = true
  end
  def hide_back
    @show_back = false
  end

  def hide_back_tag
      @back_tag.opacity = 255
  end

  def show_back_tag
      @back_tag.opacity = 255
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的高度
  #--------------------------------------------------------------------------
  def item_height
    return 24
  end


  def update
    super
    @back.visible = @flash.visible = @show_back #self.active
    @back_tag.visible = @flash.visible
    update_flash if @flash.visible
    #if self.active
       #if Input.repeat?(:DOWN) or Input.repeat?(:UP) or Input.repeat?(:L) or Input.repeat?(:R) or Input.repeat?(:LETF) or Input.repeat?(:RIGHT)     
         # back_tag_y
       #end
    #end
  end

  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    if Input.repeat?(:RIGHT) 
      cursor_right(Input.trigger?(:RIGHT)) if self.active
      back_tag_y if self.active
    end   
    if Input.repeat?(:LEFT) 
      cursor_left (Input.trigger?(:LEFT)) if self.active 
      back_tag_y if self.active
    end  
    if Input.repeat?(:DOWN) 
      cursor_down (Input.trigger?(:DOWN)) if self.active
      back_tag_y if self.active
    end
    if Input.repeat?(:UP)  
      cursor_up   (Input.trigger?(:UP)) if self.active
      back_tag_y if self.active
    end
    if Keys.repeat?(Keys::D)
      cursor_right(Keys.trigger?(Keys::D)) if self.active
      back_tag_y if self.active
    end   
    if Keys.repeat?(Keys::A)
      cursor_left (Keys.trigger?(Keys::A)) if self.active 
      back_tag_y if self.active
    end  
    if Keys.repeat?(Keys::S)
      cursor_down (Keys.trigger?(Keys::S)) if self.active
      back_tag_y if self.active
    end
    if Keys.repeat?(Keys::W)
      cursor_up   (Keys.trigger?(Keys::W)) if self.active
      back_tag_y if self.active
    end
     Sound.play_cursor if @index != last_index
  end

  def back_tag_y
      use_y = item_rect(index).y - self.oy + 125+24
      @back_tag.y = use_y
  end

  def update_flash
    @flash.update
  end

  def draw_item(index)
    item = @data[index]
    if item
      _x = 0
      _y = index * 24
      draw_item_name(item, _x, _y, enable?(item))
      rect_2 = Rect.new(_x+116+22, _y-10, 50, 50)
      contents.font.color = Color.new(165,234,75,255)
      draw_text(rect_2, "x")
      rect_2.x += 10
      draw_text(rect_2, $game_party.item_number(item))
      contents.font.color = normal_color
    end
  end

 def item_rect(index) #自带的外框
    rect = Rect.new
    #rect.width = 0
    #rect.height =24
    rect.width = item_width - 6-30
    rect.height = item_height

    rect.x = index % col_max * (item_width + spacing) + 30
    rect.y = index/ col_max * item_height + 1
    rect
  end

  
end
