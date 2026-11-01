#encoding:utf-8

# 拥有材料列表
class Window_ForgeMaterialState < Window_Base
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.opacity = 0
    refresh
  end

  def refresh
    _index = 0
    contents.clear
    materials.each_pair do |id,_num|      
      _item = $data_items[id]
      y = 32 * _index
      draw_item_name(_item, 24, y, enabled = true, width = 172)
      draw_text(124,y-2,128,32,"x #{_num}")
      _index += 1
    end
  end

  def materials
    $game_party.forge_materials
  end
end

#--------------------------------------------------------------------------
# ● 下一级锻造名字，所需材料，说明，价格窗口
#--------------------------------------------------------------------------
class Window_ForgeRequirmentMaterial < Window_Base
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.opacity = 0
    refresh
  end

  def item=(item)
    @item = item
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 获取下一级锻造装备
  #--------------------------------------------------------------------------
  def next_equipment(_item)
    _equipment = equipment(_item)
    if _equipment.is_a?(RPG::Weapon)
      return $data_weapons[_equipment.id+1]
    end
    if _equipment.is_a?(RPG::Armor)
      return $data_armors[_equipment.id+1]
    end
  end

    def next_equipment_2(_item)
    _equipment = equipment(_item)
    if _equipment.is_a?(RPG::Weapon)
      return $data_weapons[_equipment.id]
    end
    if _equipment.is_a?(RPG::Armor)
      return $data_armors[_equipment.id]
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取锻造装备
  #--------------------------------------------------------------------------
  def equipment(_item)
    _item[:equipment]
  end

  def refresh
    return unless @item
    contents.clear

    _equipment = @item

    #描写物品图标和名字 LV1
    draw_item_name(next_equipment_2(_equipment), 24+308-314+5, 0+110+20-100, true, 172)
    draw_text(9+308-314+5+172,0+110+20-100-2,700,32,next_equipment_2(_equipment).description)
    
    unless _equipment[:equipment].can_forge?
      contents.font.size = 18 + $game_variables[300]+2
      draw_text(24+308+100+41,32+110+26,128,32,"无法锻造")
      draw_text(24+16+100+40,68,128,32,"一一一一一")
      draw_text(24,68,128,32,"一一一")
      return
    end
    
    _next_equipment = next_equipment(_equipment)

    #描写物品图标和名字 LV2
    draw_item_name(_next_equipment, 24+308-314+5, 0+110-40, true, 172)
    draw_text(9+308-314+5+172, 0+110-41-1,700,32,_next_equipment.description)


    str = _next_equipment.description
    _c = str.size / 100

    _next_y = 64 + str.size / 12 * 32

    #draw_text(24+308+100+40,_next_y+110-7,128,32,"需要金钱: #{_equipment[:price]}")

    #draw_text(24+308+100+40,110+28+30,128,32,"需要魂石:")

    _equipment[:requirement].each_with_index do |hash,_index|
      item_id = hash[:item_id]
      num = hash[:num]
      _material = $data_items[item_id]
      y  = _next_y + 64 + _index * 32
      y1 = _index * 32
      #描写物品进化所需材料
      draw_item_name(_material, 24+308+100+40, y1+110-5+97-32, true, 172)
      draw_text(108+16+308+100+40,y1+110-5+97-32-2,128,32,"x #{num}")
    end
end

      def refresh_for_comm
    return unless @item
    contents.clear

    _equipment = @item

    #描写物品图标和名字 LV1
    draw_item_name(next_equipment_2(_equipment), 24+308-314+5, 0+110+20-100, true, 172)
    draw_text(9+308-314+5+172,0+110+20-100-2,700,32,next_equipment_2(_equipment).description)
    
    unless _equipment[:equipment].can_forge?
      contents.font.size = 18 + $game_variables[300]+2
      draw_text(24+308+100+41,32+110+26,128,32,"无法锻造")
      draw_text(24+16+100+40,68,128,32,"一一一一一")
      draw_text(24,68,128,32,"一一一")
      return
    end
    
    _next_equipment = next_equipment(_equipment)

    #描写物品图标和名字 LV2
    draw_item_name(_next_equipment, 24+308-314+5, 0+110-40, true, 172)
    draw_text(9+308-314+5+172, 0+110-41-1,700,32,_next_equipment.description)


    str = _next_equipment.description
    _c = str.size / 100

    _next_y = 64 + str.size / 12 * 32

    #draw_text(24+308+100+40,_next_y+110-7,128,32,"需要金钱: #{_equipment[:price]}")

    #draw_text(24+308+100+40,110+28+30,128,32,"需要魂石:")

    _equipment[:requirement].each_with_index do |hash,_index|
      item_id = hash[:item_id]
      num = hash[:num]
      _material = $data_items[item_id]
      y  = _next_y + 64 + _index * 32
      y1 = _index * 32
      #描写物品进化所需材料
      #draw_item_name(_material, 24+308+100+40-310, y1+110-5+97-32+374, true, 172)
      #draw_text(108+16+308+100+40-310,y1+110-5+97-32+374,128,32,"x #{num}")
    end

end
  def materials
    $game_party.forge_materials
  end
end


#==============================================================================
# ■ Window_ForgeCommand
#------------------------------------------------------------------------------
# 　打造画面中 主选项
#==============================================================================

class Window_ForgeCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
    self.opacity = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的宽度
  #--------------------------------------------------------------------------
  def item_width
    80
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    case index
    when 0
      rect.x = 0
    when 1
      rect.x = 125
    end
    rect.y = index/ col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("打造",    :forge)
    add_command("取消", :cancel)
  end
  def refresh
    contents.clear
  end
end


#encoding:utf-8
#==============================================================================
# ■ Window_Forge_Confirmation
#------------------------------------------------------------------------------
# 　锻造画面中，确认锻造的窗口。选择  【锻造】 或者 【取消】
#==============================================================================

class Window_Forge_Confirmation < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, Graphics.width, 200)
    self.opacity = 0
    self.visible = false
    # @item = $data_weapons[554]
    self.active = false
    deactivate
    # select(0)
    # refresh
  end

  def item=(_item)
    @item = _item
  end

  def col_max
    return 2
  end

  def item_max
    return 2
  end

  def item_width
    60
  end

  def contents_width
    Graphics.width - 200
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    case index
    when 0
      rect.x = 600 + 240
    when 1
      rect.x = 660 + 240
    end
    rect.y = (index / col_max * item_height)
    rect
  end

  def make_command_list
    add_command("是", :command_yes)
    add_command("否", :command_no)
  end

  def draw_item(index)
    change_color(normal_color, command_enabled?(index))

    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    rect.y += 2
    contents.font.size = 18 + $game_variables[300]
    draw_text(rect, command_name(index), alignment)
  end


  def refresh
    contents.clear
    super
    if @item
      draw_item_name(@item[:equipment], 400+240, -1, true, 172+10)
    end
  end

  def yes?
    index == 0
  end

  def dispose
    super
   # @back.dispose
    #@back.bitmap.dispose
  end

  def update
    super
    self.visible = self.active
    #@back.visible = self.active
  end

  def process_cursor_move
      return unless cursor_movable?
      last_index = @index
      cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT) 
      cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT) 
      cursor_right  (Keys.trigger?(Keys::D))    if Keys.repeat?(Keys::D)
      cursor_left   (Keys.trigger?(Keys::A))    if Keys.repeat?(Keys::A) 
      Sound.play_cursor if @index != last_index
  end
  
end



#encoding:utf-8
#==============================================================================
# ■ Window_Forge
#------------------------------------------------------------------------------
# 　锻造画面中，可锻造的武器窗口。【武器列表】
#==============================================================================

class Window_Forge < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # 状态窗口
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    @money = 0
    # self.opacity = 0
    self.opacity = 0
    refresh
    # select(0)
  end

  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    return 180+80
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● 获取商品
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end

  def item_star
    @data[0]
  end
  #--------------------------------------------------------------------------
  # ● 设置持有金钱
  #--------------------------------------------------------------------------
  def money=(money)
    @money = money
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取选择项目的有效状态
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ● 获取锻造装备
  #--------------------------------------------------------------------------
  def equipment(_item)
    _item[:equipment]
  end
  #--------------------------------------------------------------------------
  # ● 获取下一级锻造装备
  #--------------------------------------------------------------------------
  def next_equipment(_item)
    _equipment = equipment(_item)
    if _equipment.is_a?(RPG::Weapon)
      return $data_weapons[_equipment.id+1]
    end
    if _equipment.is_a?(RPG::Armor)
      return $data_armors[_equipment.id+1]
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取锻造装备所需材料
  #--------------------------------------------------------------------------
  def requirement(_item)
    _item[:requirement]
  end
  #--------------------------------------------------------------------------
  # ● 获取锻造价格
  #--------------------------------------------------------------------------
  def price(_item)
    _item[:price]
  end
  #--------------------------------------------------------------------------
  # ● 查询商品是否可买
  #--------------------------------------------------------------------------
  def enable?(_item)
    return false unless _item
    _equipment = equipment(_item)

    return false unless _equipment.can_forge?

    _next_equipment = next_equipment(_item)

    can_forge = true
    party_items = $game_party.item_container(RPG::Item)

    # 判断材料是否足够
    requirement(_item).each do |hash|
      item_id = hash[:item_id]
      num = hash[:num]
      material_num = party_items[item_id]
      if !material_num || material_num < num
        can_forge = false
        break
      end
    end

    price(_item) <= @money && !$game_party.item_max?(_next_equipment) && can_forge
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● 可锻造装备列表
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    weapons = $game_party.weapons
    armors =  $game_party.armors
    _equipments = $game_party.equip_items

    _equipments.each do |e|
      if e != nil 
      unless e.is_a?(RPG::Armor) and e.atype_id == 4 
             @data << e.forge_requirement   if e.price != 10001 and e.id != 5 and e.id != 6 and e.id != 7
      end   
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width - 25 - 26
    rect.height = item_height-1
    rect.x = index % col_max * (item_width + spacing) + 30
    rect.y = index/ col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    _item = @data[index]
    _equipment = equipment(_item)
    rect = item_rect(index)

    _enable = enable?(_item)
    rect.y-=2

 

    num = $game_party.item_container(_equipment.class)[_equipment.id]
       draw_item_name(_equipment, rect.x+1-30, rect.y, _enable )
       draw_text(109,rect.y-2,100,32,"x #{num}",2) 
    rect.width -= 4
  end
  #--------------------------------------------------------------------------
  # ● 设置状态窗口
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助内容
  #--------------------------------------------------------------------------
  def update_help
    _item = @data[index]
    if _item
      _equipment = equipment(_item)
      #_equipment = $data_weapons[_equipment.id+1]
      @help_window.set_item(_equipment) if @help_window
      @status_window.item = item if @status_window
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



#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 　商店画面
#==============================================================================
#sssssssssss
class Scene_Forging < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @a = 0
    @evo_start = 0
    @back = Sprite.new
    @back.bitmap = Bitmap.new("Graphics/System/evo_back")
    @back.y = 0#400
    @back.tone = Tone.new(0,0,0,0)
    @back.opacity = 0

    @evo_xian = Sprite.new
    @evo_xian.bitmap = Bitmap.new("Graphics/System/evo_xian")
    @evo_xian.x = 524
    @evo_xian.y = 522
    #@evo_xian.opacity = 255
    @evo_xian.z = 499
    @evo_xian.src_rect = Rect.new(0,0,0,8)

    @evo_gua = Sprite.new
    @evo_gua.bitmap = Bitmap.new("Graphics/System/evo_gua")
    @evo_gua.x = 470
    @evo_gua.y = 500
    @evo_gua.opacity = 0
    @evo_gua.z = 500

    @evo_shine = Sprite.new
    @evo_shine.bitmap = Bitmap.new("Graphics/Pictures/FF03")
    @evo_shine.x = 520
    @evo_shine.y = 522
    @evo_shine.opacity = 0
    @evo_shine.z = 501


    @shop_ms = Sprite.new
    fn = "shop_ms_"+$game_temp.shop_type.to_s+"_r"+rand(3).to_s
    @shop_ms.bitmap = Bitmap.new("Graphics/System/#{fn}")
    @shop_ms.x = 0-250
    @shop_ms.y = 410-15
    @shop_ms.opacity = 0

    # create_help_window
    equip_down
    create_gold_window
    create_command_window
    create_status_window
    create_requirements_window
    create_confirmation_window
    create_forge_window
    item = @forge_window.item_star
    @status_window.item = item
  end

  def equip_down
      @el = []
      $game_party.members.each_with_index do |actor,index|
        @el[index] = []
        @el[index][0] = actor.equips[0]
        @el[index][1] = actor.equips[1]
        @el[index][2] = actor.equips[2]
        @el[index][3] = actor.equips[3]
        actor.change_equip(0, nil) 
        actor.change_equip(1, nil)  
        actor.change_equip(2, nil)  
        actor.change_equip(3, nil)  
      end
  end

  def equip_up
      @el.each_with_index do |equip,index|
        if @el[index] != [] and @el[index] != nil
           $game_party.members[index].change_equip(0, @el[index][0])
           $game_party.members[index].change_equip(1, @el[index][1])
           $game_party.members[index].change_equip(2, @el[index][2])
           $game_party.members[index].change_equip(3, @el[index][3])
        end
      end
  end

  def create_confirmation_window
    @confirmation_window = Window_Forge_Confirmation.new(0,559)
    @confirmation_window.viewport = @viewport
    @confirmation_window.y -= 5-3
    @confirmation_window.set_handler(:command_yes,  method(:command_yes))
    @confirmation_window.set_handler(:command_no, method(:command_no))
  end

  def hide_c
      @back.opacity = 255
      @status_window.visible = false
      @status_forge_window.visible = false
      @forge_window.visible = false
      @status_window.visible = true
      @status_window.refresh_for_comm
  end 

  def show_c
      @back.opacity = 0
      @status_window.visible = true
      @status_forge_window.visible = true
      @forge_window.visible = true
      @status_window.visible = true  
      @status_window.refresh
  end

  def command_yes
    Sound.play_ok
    @evo_start = 1
    Audio.se_play("Audio/SE/156-Support14",95,60)
    #@confirmation_window.visible = false
    #@confirmation_window.deactivate
    @command_window.visible = false
    item = @forge_window.item
    next_item = @forge_window.next_equipment(item)
    item[:requirement].each do |hash|
      item_id,num = hash[:item_id], hash[:num]
      $game_party.lose_item($data_items[item_id], num, false)
    end
    $game_party.lose_gold item[:price]
    $game_party.lose_item(item[:equipment], 1, true)
    $game_party.gain_item(next_item, 1, true)
    @forge_window.refresh
  end

  def shine
      @back.tone.set(255,200,255,0)
      @back.z = 999
      @status_window.visible = true
      @status_forge_window.visible = true
      @forge_window.visible = true
      @status_window.visible = true  
      @status_window.refresh
      @a = 255
  end

  def command_no
      Sound.play_cancel
      $cant_Sound = 0
      @forge_window.activate
      @confirmation_window.deactivate
      show_c
      @command_window.select(0)
  end

  def create_menu_background
    if $game_temp.shop_type.nil?
       $game_temp.set_shop_bg(:forging)
    end
    super
  end

  # def dispose_menu_background
  #   super
  #   # $game_temp.background_bitmap.dispose
  # end

  #--------------------------------------------------------------------------
  # ● 生成金钱窗口
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = 1100
    @gold_window.y = 620
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ForgeCommand.new(378)
    @command_window.x = 813-2 ; @command_window.y = 558-1
    @command_window.z = 999
    @command_window.viewport = @viewport
    @command_window.set_handler(:forge,  method(:command_forge))
    @command_window.set_handler(:cancel, method(:return_scene))
    @command_window.refresh
  end


  #--------------------------------------------------------------------------
  # ● 生成锻造所需材料窗口
  #--------------------------------------------------------------------------
  def create_requirements_window
    @status_window = Window_ForgeRequirmentMaterial.new(780-400-40, 162-150, 600+300 ,600)
    @status_window.viewport = @viewport
    @status_window.hide
  end

  #--------------------------------------------------------------------------
  # ● 生成拥有材料列表窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_forge_window = Window_ForgeMaterialState.new(875+132, 162+20, 240, 300)
    @status_forge_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 生成锻造列表窗口
  #--------------------------------------------------------------------------
  def create_forge_window
    @forge_window = Window_Forge.new(518, 162+20, 300+80)
    @forge_window.viewport = @viewport
    @forge_window.help_window = @help_window
    @forge_window.status_window = @status_window
    @forge_window.set_handler(:ok,     method(:on_forge_ok))
    @forge_window.set_handler(:cancel, method(:on_forge_cancel))
    @forge_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 启用锻造窗口
  #--------------------------------------------------------------------------
  def activate_forge_window
    @forge_window.money = money
    @forge_window.show.activate
    @forge_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 指令“打造”
  #--------------------------------------------------------------------------
  def command_forge
    # Audio.se_play("Audio/SE/Decision3")
    activate_forge_window
    @command_window.deactivate
    @status_window.show
    @forge_window.visible = true
    create_flash_background Bitmap.new("Graphics/flash/EVO_F")
    @status_window.item = @forge_window.item_star
  end
  #--------------------------------------------------------------------------
  # ● 指令“取消”
  #--------------------------------------------------------------------------
  def return_scene
       Sound.play_cancel
       equip_up
    SceneManager.goto(Scene_Map)
        $cant_Sound = 0
  end
  #--------------------------------------------------------------------------
  # ● 锻造“确定”
  #--------------------------------------------------------------------------
  def on_forge_ok
    item = @forge_window.item
    @forge_window.deactivate
    hide_c
    @confirmation_window.item = item
    @confirmation_window.refresh
    @confirmation_window.activate
    @command_window.select(-1)
    $cant_Sound = 1
  end
  #--------------------------------------------------------------------------
  # ● 锻造“取消”
  #--------------------------------------------------------------------------
  def on_forge_cancel
    @command_window.activate
    @forge_window.unselect
    @status_window.item = nil
    @command_window.select(0)
    @command_window.visible = true
    @status_window.hide
    @flash_background.bitmap = Bitmap.new("Graphics/flash/0")
    @forge_window.visible = false
    $cant_Sound = 0
  end

  #--------------------------------------------------------------------------
  # ● 获取持有金钱
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   @shop_ms.bitmap.dispose
  #   @shop_ms.dispose
  #   @back.bitmap.dispose
  #   @back.dispose
  #   @evo_xian.bitmap.dispose
  #   @evo_xian.dispose
  #   @evo_gua.bitmap.dispose
  #   @evo_gua.dispose
  #   @evo_shine.bitmap.dispose
  #   @evo_shine.dispose
  #   dispose_menu_background
  #   @forge_window.dispose
  #   @status_window.dispose
  #   @status_forge_window.dispose
  #   @command_window.dispose
  #   @gold_window.dispose

  #   @shop_ms = nil
  #   @forge_window = nil
  #   @status_window = nil
  #   @status_forge_window = nil
  #   @command_window = nil
  #   @gold_window = nil
  # end

  def update
    super
      if @command_window.active 
         if @command_window.index == 1
            $cant_Sound = 1
         else
            $cant_Sound = 0
         end   
      end

  if @evo_start >= 1
     @confirmation_window.show
     @evo_shine.opacity = 255
     @evo_gua.opacity = 255
     @evo_start += 3
     @evo_xian.src_rect = Rect.new(0,0,@evo_start,8)
     @evo_shine.x += 3 if @evo_shine.x < 926
      if @evo_start >= 416 
        item = @forge_window.item
        item_name = @forge_window.next_equipment(item).name
         if item_name == nil #include?("真")
            Audio.se_play("Audio/SE/Evolution",95,75)
         else
            Sound.play_forge
         end
         @evo_xian.src_rect = Rect.new(0,0,0,8)
         @evo_shine.opacity = 0
         @evo_gua.opacity = 0
         shine
         @evo_start = 0
         @evo_shine.x = 520
         @status_forge_window.refresh
         @status_window.refresh
         @forge_window.update_help
         $cant_Sound = 0
         #@command_window.select(0)
      end
  end

    if @shop_ms != nil and @shop_ms.x < 0
       @shop_ms.x += 15
       @shop_ms.opacity += 20
    end

         if @a < 0
            @forge_window.show.activate
            item = @forge_window.item
            @a = 0 
            @back.z = 0
            @back.opacity = 0 
            @back.tone.set(0,0,0,0)
         end
      if @a > 0
         @a -= 6
         @back.tone.set(0,@a-15,@a,0)
         @back.opacity -= 6
      end

    if Input.repeat?(Input::UP) or Keys.repeat?(Keys::W)
      if @forge_window.active
        item = @forge_window.item
        @status_window.item = item
      end
    end

    if Input.repeat?(Input::DOWN) or Keys.repeat?(Keys::S)
      if @forge_window.active
        item = @forge_window.item
        @status_window.item = item
      end
    end



      if Input.repeat?(Input::LEFT) or Input.repeat?(Input::RIGHT) or Keys.repeat?(Keys::A) or Keys.repeat?(Keys::D)
      if @forge_window.active
         Sound.play_cancel
         @forge_window.visible = false
         @forge_window.deactivate
         @command_window.activate
         @command_window.show
         @forge_window.unselect
         @status_window.item = nil
         @command_window.select(1)
         @status_window.hide
         @flash_background.bitmap = Bitmap.new("Graphics/flash/0")
      end
      end


  end


end
