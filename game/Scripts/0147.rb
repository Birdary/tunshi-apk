#encoding:utf-8
#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　物品画面
#==============================================================================

class Scene_Cj < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    @data = []
    @exist_datas_count = 0

    create_help_window

    set_datas
    set_variables
    create_item_window
    create_sprites

    create_flash_background Cache.flash("cj")
    set_menu_background Cache.system("cj")
    
  end

  def create_help_window
    super
    @help_window = Window_Help.new
    @help_window.attrset(:x=>100,:y=>250)
    @help_window.width =  500
    @help_window.z = 99999
  end

  def set_datas
    for i in 304...481
      data_item = $data_items[i]
      next if data_item.itype_id != 2
      if $game_party.has_item?(data_item)
        @exist_datas_count += 1
      end
      @data.push(data_item)
    end
  end

  def set_variables
    $game_variables[222] = @exist_datas_count
  end

  def create_sprites
    create_op
    create_item_info
  end

  def create_op
    @op = Sprite.new
    @op.bitmap = Bitmap.new(200,120)
    @op.bitmap.clear

    points = @exist_datas_count
    number_array =  points.to_s.split("")
    start_x = 78 - points.to_s.size * 16
    for char in number_array
      number = char.to_i
      if points > 9
        @op.bitmap.blt(start_x, 0, Cache.zdbg("turn_size2"), Rect.new(number * 54, 0, 44, 100))
      else
        @op.bitmap.blt(start_x-7, 0, Cache.zdbg("turn_size2"), Rect.new(number * 54, 0, 44, 100))  
      end
      start_x += 20
    end

    points = $game_variables[137]
    number_array =  points.to_s.split("")
    start_x = 134 - points.to_s.size * 16
    for char in number_array
      number = char.to_i
      if points > 99
         @op.bitmap.blt(start_x, 60, Cache.zdbg("turn_size3"), Rect.new(number * 44, 0, 44, 100))
      elsif points > 9
         @op.bitmap.blt(start_x-7, 60, Cache.zdbg("turn_size3"), Rect.new(number * 44, 0, 44, 100))
      else
         @op.bitmap.blt(start_x-14, 60, Cache.zdbg("turn_size3"), Rect.new(number * 44, 0, 44, 100))
      end 
      start_x += 18
    end

    @op.x = 7
    @op.y = 59
    @op.z = 9999

  end

  def create_item_info
    @cache_bitmap_icon = Bitmap.new("Graphics/System/jm_icon")
    @cache_bitmap_icon2 = Bitmap.new("Graphics/System/IconSet")

    @sp_icon1 = Sprite.new
    @sp_icon1.x = 237
    @sp_icon1.y = 77
    @sp_icon1.bitmap = Bitmap.new(64,64)

    @sp_icon2 = Sprite.new
    @sp_icon2.x = 314+4
    @sp_icon2.y = 99
    @sp_icon2.bitmap = Bitmap.new(24,24)

    @sp_name = Sprite.new
    @sp_name.x = 345
    @sp_name.y = 99-13
    @sp_name.bitmap = Bitmap.new(120,50)
    @sp_name.bitmap.font.size = 23

    @sp_desc = Sprite.new
    @sp_desc.x = 345 - 32  # => REMARK 为何要 - 32
    @sp_desc.y = 124
    @sp_desc.bitmap = Bitmap.new(600,85)
    @sp_desc.bitmap.font.size = 23
  end


  def refresh_current_item(index)
    item = @data[index]

    @sp_icon1.bitmap.clear
    @sp_icon2.bitmap.clear
    @sp_name.bitmap.clear
    @sp_desc.bitmap.clear


    if $game_party.has_item?(item)
      x = index % 10 * 64
      y = (index / 10).to_i * 64
      @sp_icon1.bitmap.blt(0,0,@cache_bitmap_icon,Rect.new(x,y,64,64),255)

      item_icon_index = item.icon_index
      x = item_icon_index % 16 * 24
      y = (item_icon_index / 16).to_i * 24
      @sp_icon2.bitmap.blt(0,0,@cache_bitmap_icon2,Rect.new(x,y,24,24),255)
      
      if item.repeats == 3
        @sp_name.bitmap.font.color = Color.new(255,202,39)
      elsif item.repeats == 2
        @sp_name.bitmap.font.color = Color.new(155,120,255)
      else
        @sp_name.bitmap.font.color = Color.new(40,180,245)
      end    

       @sp_name.bitmap.draw_text(0,0,120,50,item.name.split("|")[0],0)

      arr = item.description.split("\r\n")
      arr.shift
      arr.each_with_index do |str,i|
        @sp_desc.bitmap.draw_text(0,i * 24,600,24,str.gsub(" ",""),0)
      end
    else
      @sp_name.bitmap.font.color = Color.new(255,255,255)
      @sp_name.bitmap.draw_text(4,0,120,50,"？？？？",0)
    end 
  end

  def create_item_window
    @item_window = WindowCJSelectItem.new(82, 200, 950, 500,@data)    
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   @op.bitmap.dispose
  #   @op.dispose
  #   @cache_bitmap_icon.dispose
  #   @cache_bitmap_icon2.dispose
  #   @sp_icon1.bitmap.dispose
  #   @sp_icon1.dispose
  #   @sp_icon2.bitmap.dispose
  #   @sp_icon2.dispose
  #   @sp_name.bitmap.dispose
  #   @sp_name.dispose
  #   @sp_desc.bitmap.dispose
  #   @sp_desc.dispose
  # end
end
