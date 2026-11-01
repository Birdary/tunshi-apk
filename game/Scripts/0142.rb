#encoding:utf-8
#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 　商店画面
#==============================================================================

class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 准备
  #--------------------------------------------------------------------------
  def prepare(goods, purchase_only)
    @goods = goods
    case $game_temp.shop_type
    when 4
      @goods = @goods.delete_if { |arr| arr.first != 0 }
    when 1
      @goods = @goods.delete_if { |arr| arr.first != 1 }
    when 2
      @goods = @goods.delete_if { |arr| arr.first != 2 }
    end
    @purchase_only = purchase_only
  end
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    team_ac_check
    create_menu_background
    @shop_ms = Sprite.new
    fn = "shop_ms_"+$game_temp.shop_type.to_s+"_r"+rand(3).to_s
    @shop_ms.bitmap = Cache.system(fn)
    @shop_ms.x = 0-250
    @shop_ms.y = 410-15
    @shop_ms.opacity = 0
    #@shop_ms.opacity = 0
    #@shop_ms.opacity = 0

    # @flash_bmp = Sprite.new
    # @flash_bmp.x = 0
    # @flash_bmp.y = 0
    # @flash_bmp.z = 201
    # @flash_bmp.opacity = 0

    create_flash_background Cache.flash("SHOP_F")

    create_help_window
    create_gold_window
    create_command_window
    #create_dummy_window
    create_number_window
    create_status_window
    create_buy_window
    create_category_window
    create_sell_window
    @number_window.z = 210
    @sell_back.z = 205
    @category_window.z = 210
  end

  def create_menu_background
    @sell_back = Sprite.new
    @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_sell")
    @sell_back.opacity = 0
    @sell_back.viewport = @viewport
 
    if $game_temp.shop_type.nil?
      $game_temp.set_shop_bg(:item)
    end
    #$game_temp.background_bitmap = bitmap
    super
  end

  # def dispose_menu_background
  #   super
  #   $game_temp.background_bitmap.dispose
  # end

  def create_help_window
    super
    @help_window.attrset(:x=>490-33,:y=>29+54)
  end

  #--------------------------------------------------------------------------
  # ● 生成金钱窗口
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = 1100
    @gold_window.y = 621
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ShopCommand.new(378, @purchase_only)
    @command_window.x = 800 ; @command_window.y = 558
    @command_window.viewport = @viewport
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
    @command_window.refresh
  end

  def return_scene
    Sound.play_cancel
    SceneManager.return
    $cant_Sound = 0
  end
  #--------------------------------------------------------------------------
  # ● 生成填充窗口
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 生成数值输入窗口
  #--------------------------------------------------------------------------
  def create_number_window
    @number_window = Window_ShopNumber.new(520, 310, 98)
    @number_window.viewport = @viewport
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_ShopStatus.new(875+132, 137, 240, 410)
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 生成买入窗口
  #--------------------------------------------------------------------------
  def create_buy_window
    @buy_window = Window_ShopBuy.new(518, 162+20, 380, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成分类窗口
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = 290
    @category_window.hide.deactivate
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
   # @category_window.opacity = 255
    @category_window.width = 110
    @category_window.x = 406
    @category_window.y = 171
  end
  #--------------------------------------------------------------------------
  # ● 生成卖出窗口
  #--------------------------------------------------------------------------
  def create_sell_window
    @sell_window = Window_ShopSell.new(518, 162+20, 304, 380)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
    @category_window.item_window = @sell_window
  end
  #--------------------------------------------------------------------------
  # ● 启用买入窗口
  #--------------------------------------------------------------------------
  def activate_buy_window
      @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_sell")
    @sell_back.opacity = 0
    @buy_window.money = money
    @buy_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● 启用卖出窗口
  #--------------------------------------------------------------------------
  def activate_sell_window
      @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_sell")
    @sell_back.opacity = 255
    @category_window.show
    @sell_window.refresh
    @sell_window.show.activate
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 指令“买入”
  #--------------------------------------------------------------------------
  def command_buy
    activate_buy_window
    # @flash_bmp.bitmap = Cache.flash("SHOP_F")   
    # @flash_bmp.opacity = 255
  end
  #--------------------------------------------------------------------------
  # ● 指令“卖出”
  #--------------------------------------------------------------------------
  def command_sell
    @category_window.show.activate
    @sell_window.show
    @sell_back.opacity = 255
    @sell_window.deactivate
    @sell_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 买入“确定”
  #--------------------------------------------------------------------------
  def on_buy_ok
    @item = @buy_window.item
    @buy_window.hide
    @number_window.set(@item, max_buy, buying_price, currency_unit)
    @number_window.show.activate
    @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_buy")
    @sell_back.opacity = 255
    @sell_back.z = 205
  end
  #--------------------------------------------------------------------------
  # ● 买入“取消”
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    @buy_window.hide
    @sell_back.opacity = 0
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 分类“确定”
  #--------------------------------------------------------------------------
  def on_category_ok
    activate_sell_window
    @sell_window.unselect
    @sell_window.refresh
    @sell_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 分类“取消”
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @category_window.hide
    @sell_window.hide
    @sell_window.deactivate
    @sell_back.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 卖出“确定”
  #--------------------------------------------------------------------------
  def on_sell_ok
    @item = @sell_window.item
    @status_window.item = @item
    @category_window.hide
    @sell_window.hide
    @sell_back.opacity = 255
    @number_window.set(@item, max_sell, selling_price, currency_unit)
    @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_no")
    @sell_back.z = 205
    @number_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● 卖出“取消”
  #--------------------------------------------------------------------------
  def on_sell_cancel
    @sell_window.unselect
    @category_window.activate
    @sell_window.hide
    @sell_window.deactivate
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 数值输入“确定”
  #--------------------------------------------------------------------------
  def on_number_ok
    @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_sell")
    Sound.play_shop
    Audio.se_play("Audio/SE/005-System05")
    case @command_window.current_symbol
    when :buy
      do_buy(@number_window.number)
    when :sell
      do_sell(@number_window.number)
    end
    end_number_input
    @gold_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 数值输入“取消”
  #--------------------------------------------------------------------------
  def on_number_cancel
    # Sound.play_cancel
      end_number_input
  end
  #--------------------------------------------------------------------------
  # ● 执行买入
  #--------------------------------------------------------------------------
  def do_buy(number)
    $game_party.lose_gold(number * buying_price)
    $game_party.gain_item(@item, number)
    #阵法购买
      if @item.class == RPG::Item and @item.id >= 125 and @item.id <= 141
           a = (@item.id.to_i) - 120 
           for i in 0...150
           if $game_actors[i] != nil and !$game_actors[i].skill_is_learn?(a)
           $game_actors[i].learn_skill(a) 
           end
           end
      end
  end
  #--------------------------------------------------------------------------
  # ● 执行卖出
  #--------------------------------------------------------------------------
  def do_sell(number)
    $game_party.gain_gold(number * selling_price)
    $game_party.lose_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # ● 结束数值输入
  #--------------------------------------------------------------------------
  def end_number_input
    @sell_back.bitmap = Bitmap.new("Graphics/System/shop_back_sell")
      @sell_back.z = 195
    @number_window.hide
    case @command_window.current_symbol
    when :buy
      activate_buy_window
    when :sell
      activate_sell_window
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取可以买入的最大值
  #--------------------------------------------------------------------------
  def max_buy
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    buying_price == 0 ? max : [max, money / buying_price].min
  end
  #--------------------------------------------------------------------------
  # ● 获取可以卖出的最大值
  #--------------------------------------------------------------------------
  def max_sell
    $game_party.item_number(@item)
  end
  #--------------------------------------------------------------------------
  # ● 获取持有金钱
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # ● 获取货币单位
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  #--------------------------------------------------------------------------
  # ● 获取买入价格
  #--------------------------------------------------------------------------
  def buying_price
    @buy_window.price(@item)
  end
  #--------------------------------------------------------------------------
  # ● 获取卖出价格
  #--------------------------------------------------------------------------
  def selling_price
    @item.price / 2
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   @shop_ms.bitmap.dispose
  #   @shop_ms.dispose
  #   @sell_back.bitmap.dispose
  #   @sell_back.dispose
  #   dispose_menu_background
  #   # @flash_bmp.dispose unless @flash_bmp.nil?
  #   # @flash_bmp.bitmap.dispose unless @flash_bmp.bitmap.nil?
  # end


  def update
    super
    if @shop_ms != nil and @shop_ms.x < 0
       @shop_ms.x += 15
       @shop_ms.opacity += 20
    end
    #按取消发出取消的声音，而不是确定的声音
    if @command_window.active == true
      if @command_window.index == 2
        $cant_Sound = 1
      else
        $cant_Sound = 0
      end   
    end


    if Input.repeat?(Input::LEFT) or Input.repeat?(Input::RIGHT) or Keys.repeat?(Keys::A) or Keys.repeat?(Keys::D)
      if @buy_window.active == true
        Sound.play_cancel
        @command_window.activate
        @sell_back.opacity = 0
        @status_window.hide
        @status_window.item = nil
        @help_window.clear
        @command_window.select(1)
        @buy_window.hide
        @buy_window.deactivate
      end
      if @category_window.active == true
        Sound.play_cancel
        @command_window.activate
        @sell_window.hide
        @sell_window.unselect
        @sell_window.deactivate
        @sell_back.opacity = 0
        @category_window.hide
        @category_window.deactivate
      end
      if @sell_window.active == true
        Sound.play_cancel
        @sell_window.unselect
        @sell_window.deactivate
        @sell_window.hide
        @category_window.activate
        @status_window.item = nil
        @help_window.clear
      end
    end
  end
end
