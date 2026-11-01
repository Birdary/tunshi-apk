#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　显示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
  attr_accessor :show_message
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    $game_switches[395] = false #显示文字时TIP状态提示关闭
    $game_switches[400] = true  #显示文字时播放嘟嘟声
    self.z = 200
    self.openness = 0
    create_all_windows
    create_back_sprite_and_bitmap
    clear_instance_variables
    self.arrows_visible = false
    self.windowskin = Cache.system("Window_no3")
    self.opacity = 0
    self.back_opacity = 0
    @tap_count = 0
    @c = 0
    @flash = 0
    @body = Sprite.create do |sp|
      sp.bitmap = Bitmap.new(160,224)
      sp.x = 268+17; sp.y = 480
      sp.z = 300
    end
    @show_message = false
  end

  #--------------------------------------------------------------------------
  # ● 生成背景活动块
  #--------------------------------------------------------------------------
  def create_back_sprite_and_bitmap
    @back_sprite = Sprite.new
    @back_sprite.visible = (@background == 1)
    @back_sprite.z = self.z - 10

    @back_sprite_name = Sprite.new
    @back_sprite_name.x = 439
    @back_sprite_name.y = 492
    @back_sprite_name.z = self.z
    @back_sprite_name.bitmap = Bitmap.new(300,100)

    @back_flash = Sprite_Flash.new
    @back_flash.bitmap = Bitmap.new("Graphics/flash/mc")  
    @back_flash.x = 540
    @back_flash.z = 999
    if SceneManager.scene.is_a?(Scene_Expbook)
       @back_flash.x = 80
    end
    @back_flash.visible = false
    $game_switches[395] = true #显示文字时TIP状态提示关闭
    $game_switches[400] = false  #显示文字时播放嘟嘟声

  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    if  $game_switches[492] == true
      Graphics.width
    else
      Graphics.width
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    #fitting_height(visible_line_number)
    if $game_switches[492] == true
      return 400
    else
      return 160
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除实例变量
  #--------------------------------------------------------------------------
  def clear_instance_variables
    @fiber = nil                # 纤程
    @background = 0             # 背景类型
    @position = 2               # 显示位置
    clear_flags
  end
  #--------------------------------------------------------------------------
  # ● 清除的标志
  #--------------------------------------------------------------------------
  def clear_flags
    @show_fast = false          # 快进的标志
    @line_show_fast = false     # 行单位快进的标志
    @pause_skip = false         # “不等待输入”的标志
  end
  #--------------------------------------------------------------------------
  # ● 获取显示行数
  #--------------------------------------------------------------------------
  def visible_line_number
      return 4
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_all_windows
    # dispose_back_sprite
    # if @body.bitmap
    #   @body.bitmap.dispose
    #   @body.dispose
    #   @body = nil
    # end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_all_windows
    update_fiber
    flash_update
  end

  def flash_update
    @back_flash.update
  end
  #--------------------------------------------------------------------------
  # ● 更新纤程
  #--------------------------------------------------------------------------
  def update_fiber
    if @fiber
       @fiber.resume
    elsif $game_message.busy? && !$game_message.scroll_mode
       @fiber = Fiber.new { fiber_main }
       @fiber.resume
    else
       $game_message.visible = false
    end
    @back_sprite.visible = @show_message
    @back_flash.visible = @show_message
    @back_sprite_name.visible = @show_message
    # if $game_message.has_text?
    #   @back_sprite.visible = true
    # else
    #   @back_sprite.visible = false
    # end
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    #@gold_window = Window_Gold.new
    #@gold_window.x = Graphics.width - @gold_window.width
    #@gold_window.y = 0
    #@gold_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取背景色 1
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 160)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景色 2
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
  #--------------------------------------------------------------------------
  # ● 释放所有窗口
  #--------------------------------------------------------------------------
  def dispose_all_windows
    #@gold_window.dispose
    if @choice_window
      @choice_window.dispose
      @choice_window = nil
    end
    if @number_window
      @number_window.dispose
      @number_window = nil
    end
    if @item_window
      @item_window.dispose
      @item_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放背景位图
  #--------------------------------------------------------------------------
  def dispose_back_bitmap
    if @back_bitmap
      @back_bitmap.dispose
      @back_bitmap = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放背景精灵
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    if @back_sprite_name
       @back_sprite_name.bitmap.dispose if @back_sprite_name.bitmap
       @back_sprite_name.dispose
       @back_sprite_name = nil
    end
    if @back_sprite
       @back_sprite.bitmap.dispose if @back_sprite.bitmap
       @back_sprite.dispose
       @back_sprite = nil
    end
    if @back_flash
       @back_flash.bitmap.dispose if @back_flash.bitmap
       @back_flash.dispose
       @back_flash = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新所有窗口
  #--------------------------------------------------------------------------
  def update_all_windows
    #@gold_window.update
    @choice_window.update if @choice_window
    @number_window.update if @number_window
    @item_window.update   if @item_window
  end
  #--------------------------------------------------------------------------
  # ● 建立对话框背景位图
  #--------------------------------------------------------------------------
  def back_bitmap
    po = $game_message.background
    if $game_party.in_battle
       @back_sprite.bitmap = Cache.zdbg( @text_name != "" ? "8_22_f" : "8_22_z")
    else
      if  $hei != 1
          @back_sprite.bitmap = Cache.system( po == 0 ? "xia_name" : "xia")
      else
          Cache.system( po == 0 ? "xia_hei" : "xia")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理纤程的主逻辑
  #--------------------------------------------------------------------------
  def fiber_main
    @background = $game_message.background
    @back_sprite_name.bitmap.clear 
    $game_message.visible = true
    update_placement
    v = Viewport.new
    v.z = 900
    #@background = 1
    po = $game_message.background
    @show_message = true
    case @position
    when 0
    when 1
      self.x = 3
      @back_flash.y = 670 - 278 + 4
      @back_sprite.y = 279-100-26
      @back_sprite_name.y = 489-275+9
      if $hei != 1
                 if @text_name != ""
                    @back_sprite.bitmap = Cache.system( po == 0 ? "zhong_name" : "zhong")
                 else
                    @back_sprite.bitmap = Cache.system("zhong")
                 end
      else
      @back_sprite.bitmap = Cache.system( po == 0 ? "zhong_hei" : "zhong")
      end
      @body.y = 196-86+7
    when 2
      @back_flash.y = 670 -3
      @back_flash.y = 550   if $game_switches[492] == true  #如果是战斗结算画面，改变位置！
      # @back_sprite.bitmap.clear unless @back_sprite.bitmap.nil?
      if $game_party.in_battle
         @back_sprite.bitmap = Cache.zdbg( @text_name != "" ? "8_22_f" : "8_22_z")
      else
          if $hei != 1
             if @text_name != ""
                @back_sprite.bitmap = Cache.system( po == 0 ? "xia_name" : "xia")
             else
                @back_sprite.bitmap = Cache.system("xia")
             end
          else
             @back_sprite.bitmap = Cache.system( po == 0 ? "xia_hei" : "xia")
          end
      end
      if !$game_party.in_battle
         @back_sprite.bitmap = back_bitmap
         @back_sprite.y = 495 - 26 
         @back_sprite_name.y = 492
         @body.y = 480-94
      end
      if $game_party.in_battle
         @back_sprite.y = 479-100
         self.y = 520+15
         self.x = -250+85+15+7
         @back_sprite_name.x = 292
         @back_sprite.bitmap = back_bitmap
        # 由于战斗中对话时间有延迟 头像会显示闪烁 所以头像画在背景上
        face_name = $game_message.face_name
        if face_name != ""
           face_index = $game_message.face_index
           bitmap = Cache.face(face_name)
          if bitmap.width == 640
             rect = Rect.new(0, 0, 0, 0)
             rect.x = face_index % 4 * 160
             rect.y = face_index / 4 * 224
             rect.width = 160
             rect.height = 224
             @back_sprite.bitmap.clear_rect(0,0,257,231)
             @back_sprite.bitmap.blt(0, 0, Cache.zdbg("8_22_f2") , Rect.new(0,0,257,231)) 
             @back_sprite.bitmap = back_bitmap
             @back_sprite.bitmap.blt(0+115, 1-72+100-22, bitmap, rect)
          end
          bitmap.dispose
        end

      else
        @back_sprite.z = self.z - 10
        @back_sprite_name.z = self.z
      end
    end


    loop do
      process_all_text if $game_message.has_text?
      process_input
      # if $game_party.in_battle
      #   wait(80)
      # else
      #   process_input
      # end
      $game_message.clear
      #@gold_window.close
      Fiber.yield
      break unless text_continue?
    end
    #msgbox 123
    #@back_sprite.visible = false
    # @background = 0
    @body.visible = false  if $game_switches[999] == false #防止对话时获得物品头像消失
      

    # @back_flash.dispose
    # @back_flash.bitmap.dispose
    close_and_wait

    $game_message.visible = false
    @show_message = false
    @body.visible = false  #if $game_switches[999] == false

    # 临时测试贝奔溃
    # unless $game_party.in_battle
    #   SceneManager.scene.show_status
    # end

    @fiber = nil
  end

  def hide_back
      @back_sprite.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置
  #--------------------------------------------------------------------------
  def update_placement
    open_and_wait if !$game_party.in_battle #战斗中对话闪烁
    text = convert_escape_characters($game_message.all_text)
    if $game_message.face_name != "" and text.include?("：")
      @text_name =  text.split("：").first + "："
      text = text.split("：").last
    elsif text.index("：" [0]) == 2 or text.index("：" [0]) == 3 or text.index("：" [0]) == 4
      @text_name =  text.split("：").first + "："
      text = text.split("：").last
    else
      @text_name = ""
    end
    if $game_switches[492] == true #如果在战斗中。名字就不单独一行
      text = convert_escape_characters($game_message.all_text)
      @text_name = ""
    end   

    @position = $game_message.position
    self.y = @position * (Graphics.height - height) / 2
    #@gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
    po = $game_message.background
    case @position
    when 1
      self.x = 3
      @body.x = 265
      self.y = @position * (Graphics.height - height) / 2 - 8
      if $hei != 1
        if @text_name != ""
          @back_sprite.bitmap = Cache.system( po == 0 ? "zhong_name" : "zhong")
        else
          @back_sprite.bitmap = Cache.system("zhong")
        end
      else
        if @text_name != ""
          @back_sprite.bitmap = Cache.system( po == 0 ? "zhong_hei" : "zhong")
        else
          @back_sprite.bitmap = Cache.system( po == 0 ? "zhong" : "zhong")
        end
      end
    when 2
      if $game_party.in_battle or SceneManager.scene.is_a?(Scene_Expbook)
        if $game_switches[492] == true  #如果是战斗结算画面，改变位置！
          @back_sprite.y = 479-100
          self.y = 205-12
          self.x = 90
          #@back_flash.x = 85
          @back_flash.y = 550
          if SceneManager.scene.is_a?(Scene_Expbook)
            @back_flash.bitmap = Cache.flash("mc2") 
            self.y = 205-12
            self.x = 90-460
          end
        else
          self.y = @position * (Graphics.height - height) / 2 - 8
          @back_sprite.z = self.z - 10
          @back_sprite_name.z = self.z
        end

      else
        self.y = @position * (Graphics.height - height) / 2 - 8
        self.x = 3
        @body.x = 265
        if $hei != 1
          if @text_name != ""
            @back_sprite.bitmap = Cache.system( po == 0 ? "xia_name" : "xia")
          else
            @back_sprite.bitmap = Cache.system("xia")
          end
        else
          @back_sprite.bitmap = Cache.system( po == 0 ? "xia_hei" : "xia")
        end
      end
    end      
  end
  #--------------------------------------------------------------------------
  # ● 处理所有内容
  #--------------------------------------------------------------------------
  def process_all_text
    open_and_wait 
    text = convert_escape_characters($game_message.all_text)
    #名字上抬处理
    if $game_message.face_name != "" and text.include?("：")
    @text_name =  text.split("：").first + "："
    text = text.split("：").last
    elsif text.index("：" [0]) == 2 or text.index("：" [0]) == 3 or text.index("：" [0]) == 4
    @text_name =  text.split("：").first + "："
    text = text.split("：").last
    else
    @text_name = ""
    end
    if $game_switches[492] == true #如果在战斗中。名字就不单独一行
      text = convert_escape_characters($game_message.all_text)
      @text_name = ""
    end   
    pos = {}
    new_page(text, pos)
    while !text.empty?
      process_character(text.slice!(0, 1), text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 输入处理
  #--------------------------------------------------------------------------
  def process_input
    if $game_message.choice?
      input_choice
    elsif $game_message.num_input?
      input_number
    elsif $game_message.item_choice?
      input_item
    else
      input_pause unless @pause_skip
    end
  end
  #--------------------------------------------------------------------------
  # ● 打开窗口并等待窗口开启完成
  #--------------------------------------------------------------------------
  def open_and_wait
    open
    @back_flash.visible = true
    @back_sprite.visible = true
    $game_switches[395] = false #显示文字时TIP状态提示关闭
    $game_switches[400] = true  #显示文字时播放嘟嘟声
    Fiber.yield until open?
  end
  #--------------------------------------------------------------------------
  # ● 关闭窗口并等待窗口关闭完成
  #--------------------------------------------------------------------------
  def close_and_wait
    close
    if @back_flash && !@back_flash.disposed?
       @back_flash.visible = false
       $game_switches[395] = true 
       $game_switches[400] = false  

    end
    if @back_sprite && !@back_sprite.disposed?
       @back_sprite.visible = false
       $game_switches[395] = true 
       $game_switches[400] = false  
    end
    Fiber.yield until all_close?
    dispose_all_windows until all_close?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否所有窗口已全部关闭
  #--------------------------------------------------------------------------
  def all_close?
    if @number_window 
       close? && @number_window.close?  
    elsif @item_window
       close? && @item_window.close?   
    elsif @choice_window 
       close? && @choice_window.close?
    else 
       close? 
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定文字是否继续显示
  #--------------------------------------------------------------------------
  def text_continue?
    $game_message.has_text? && !settings_changed?
  end
  #--------------------------------------------------------------------------
  # ● 判定背景和位置是否被更改
  #--------------------------------------------------------------------------
  def settings_changed? #对话框切换位置造成闪烁
   # @background != $game_message.background ||
    @position != $game_message.position
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
      duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # ● 监听“确定”键的按下，更新快进的标志
  #--------------------------------------------------------------------------
  def update_show_fast
      @show_fast = true if Input.trigger?(:C)
  end
  #--------------------------------------------------------------------------
  # ● 输出一个字符后的等待
  #--------------------------------------------------------------------------
  def wait_for_one_character
      update_show_fast
      Fiber.yield unless @show_fast || @line_show_fast
  end
  #--------------------------------------------------------------------------
  # ● 翻页处理
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    contents.clear
    btm = Cache.face($game_message.face_name)
    update_placement
    @back_sprite_name.bitmap.clear
    @back_sprite_name.bitmap.font.size = 23 + $game_variables[300]+1
    @back_sprite_name.bitmap.draw_text(0,0,150,100, @text_name)
    if btm.width == 640
      unless $game_party.in_battle
        x = $game_message.face_index % 4 * 160
        y = $game_message.face_index / 4 * 224
        @body.bitmap = btm
        @body.src_rect = Rect.new(x,y,160,224) 
        @body.visible = true
      end
    else
      @body.visible = false
      unless $game_party.in_battle
        y = @position == 0 ? 10 : 25
        draw_face($game_message.face_name, $game_message.face_index, 294, y)
      end
    end
    # reset_font_settings
    if SceneManager.scene.is_a?(Scene_Expbook) or $game_switches[492] == true
       contents.font.size = 20 + $game_variables[300]+1
    else
       contents.font.size = 20 + $game_variables[300]+3
    end
    pos[:x] = new_line_x
    pos[:y] = 24-2
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
  #--------------------------------------------------------------------------
  # ● 获取换行位置
  #--------------------------------------------------------------------------
  def new_line_x
    return 424
    # $game_message.face_name.empty? ? 0 : 112
  end
  #--------------------------------------------------------------------------
  # ● 普通文字的处理
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    super
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 换行文字的处理
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    @line_show_fast = false
    super
    if need_new_page?(text, pos)
       input_pause
       new_page(text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否需要翻页
  #--------------------------------------------------------------------------
  def need_new_page?(text, pos)
      pos[:y] + pos[:height] > contents.height && !text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 翻页文字的处理
  #--------------------------------------------------------------------------
  def process_new_page(text, pos)
    text.slice!(/^\n/)
    input_pause
    new_page(text, pos)
  end
  #--------------------------------------------------------------------------
  # ● 处理控制符指定的图标绘制
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    super
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 控制符的处理
  #     code : 控制符的实际形式（比如“\C[1]”是“C”）
  #     text : 绘制处理中的字符串缓存（字符串可能会被修改）
  #     pos  : 绘制位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when '$'
      #@gold_window.open
    when '.'
      wait(15)
    when '|'
      wait(60)
    when '!'
      input_pause
    when '>'
      @line_show_fast = true
    when '<'
      @line_show_fast = false
    when '^'
      @pause_skip = true
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理输入等待
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)
    Input.update
    self.pause = false
  end
  #--------------------------------------------------------------------------
  # ● 处理选项的输入
  #--------------------------------------------------------------------------
  def input_choice
    unless @choice_window
      @choice_window = Window_ChoiceList.new(self)
      @choice_window.z = 550
      @choice_window.y = 100
    end

    if @choice_window
       @choice_window.start
       Fiber.yield while @choice_window.active
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理数值的输入
  #--------------------------------------------------------------------------
  def input_number

       @number_window = Window_NumberInput.new(self)  unless @number_window
    if @number_window
       @number_window.start
       Fiber.yield while @number_window.active
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理物品的选择
  #--------------------------------------------------------------------------
  def input_item
      @item_window = Window_KeyItem.new(self) unless @item_window
     if @item_window
        @item_window.start
        Fiber.yield while @item_window.active
     end   
  end
end
