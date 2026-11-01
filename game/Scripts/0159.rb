#encoding:utf-8

class Exbook_Party_Window < Window_Selectable

  def initialize(x, y, width, height)
    super(x, y, width, height)

    self.opacity = 0
    self.index = 0
    self.activate
    self.create_arrow
    self.refresh 

  end  

  def item_max ; $game_party.members.size end
  def col_max ; $game_party.members.size end
  def refresh 
    self.contents.clear
    @sprites.nil? ? @sprites = [] : dispose_sprites
    $game_party.members.each_with_index do |actor,index| 
      @sprites << Sprite.create do |sp|
        sp.attrset :x=>index * 58 + 160+276, :y=>507-25+115
        sp.bitmap = Cache.sface(actor.face_name)
        sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
        sp.tone = Tone.new(0,0,0,255) if actor.dead?
        sp.opacity = 100 if actor.dead?
        if self.active
          sp.opacity = 255
         else
          if actor.index == self.index
            sp.opacity = 255
          else
            sp.opacity = 100
          end
        end
        sp.z = 100
      end
      @sprites << Sprite.create do |sp|
        sp.attrset :x=>index * 58 + 160+276, :y=>498-25+115
        if actor.dead?
          sp.bitmap = Cache.hp("mapstatusmask_dead") 
        else
          sp.bitmap = Cache.hp("mapstatusmask")
        end
        sp.z = 99
      end
    end
  end

  def create_arrow
    @arrow = Sprite.create do |sp|
      sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
    end
    update_cursor
  end
  def actor ; $game_party.members[self.index]; end  
  def update_cursor
    unless @arrow.nil?
      @arrow.x = self.index%19*58 + 190+276-38
      @arrow.y = self.index/19*62 + 507-15+115-19
      @arrow.visible = self.active
    end
  end
  def dispose_sprites
    if @sprites && @sprites.size > 0
      @sprites.each{|n|n.bitmap.dispose;n.dispose} ; @sprites.clear
    end
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   dispose_sprites
  #   @arrow.dispose
  #   @arrow.bitmap.dispose
  # end
  def process_handling
    super
    if self.active
      if Input.repeat?(:LEFT) && handle?(:left)
        call_handler(:left)
      end
      if Input.repeat?(:RIGHT) && handle?(:right)
        call_handler(:right)
      end
    end
  end
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
     if Input.repeat?(:RIGHT) or Keys.trigger?(Keys::D)
        cursor_right(Input.trigger?(:RIGHT))
        call_handler(:right)
     end   
    if Input.repeat?(:LEFT)  or Keys.trigger?(Keys::A)
       cursor_left (Input.trigger?(:LEFT))  
       call_handler(:left)
     end  
    Sound.play_cursor if @index != last_index
  end
end

#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　物品画面
#==============================================================================
class Scene_Expbook < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
      super
      team_ac_check
      @nx = 0
      actor = $game_party.members[0]
      create_background
      create_message_window
      create_party_window
      create_now_actor
      create_confirmation_window
      create_status_window(actor)
      refresh_actor(actor)
      $game_switches[492] = true
      @message_window.hide_back
  end

  def real_exp_book
      if $game_variables[252] != ($game_party.expbook + 850912) * 55
      if $game_variables[253] != $game_party.expbook.to_s[0,3] + "realexpbook"
         $game_party.expbook = rand(255)
      end
      end
  end

  def create_status_window(actor)
      @window_status = Window_Expbook.new(actor)
      @window_status.actor = actor
  end

  def create_confirmation_window
      @confirmation_window = Window_expbook_Confirmation.new(0,559)
      @confirmation_window.viewport = @viewport
      @confirmation_window.set_handler(:command_yes,  method(:command_yes))
      @confirmation_window.set_handler(:command_no, method(:command_no))
  end


  def create_now_actor
      @now_actor = Sprite.create do |sp|
      sp.attrset :x=>563,:y=>80-120,:z=>101
    end
    def @now_actor.set(actor)
      if actor.nil?
         self.bitmap = Cache.face("000")
      else
        s = actor.actor.note.split("\r\n")[0].split(" = ").last
        s = s.to_s
        b = actor.actor.note.split("\r\n")[1].split(" = ").last
        b = b.to_i

        if b > 3 
          b = b-4
          c = 224
        else
          c = 0
        end
        b = b*160
        self.bitmap = Cache.face("#{s}")
        self.src_rect = Rect.new(b, c, 160, 224)
      end
    end
  end

  def refresh_actor(actor)
    $game_player.refresh
    @now_actor.set(actor)
    return if actor.nil?
    @window_status.actor = actor ; @window_status.contents.clear_rect(80, 30,120,40)


    @back_sprite_name.bitmap.font.name = "Noto"
    @back_sprite_name.bitmap.font.size = 19 + $game_variables[300]+1
    @back_sprite_name.bitmap.clear
    @back_sprite_name.bitmap.draw_text(0,0,100,55,"#{(actor).name}" + " Lv " + "#{(actor).level}",1)
    @lvup.opacity = 0
    @lvup.opacity = 255 if $game_party.expbook > (actor.next_level_exp - actor.exp)
  end

  def create_party_window
    @party_window = Exbook_Party_Window.new(484,436,480-318,640)


    # class << @party_window
    #   def item_max ; $game_party.members.size end
    #   def col_max ; $game_party.members.size end
    #   def refresh 
    #     self.contents.clear
    #     @sprites.nil? ? @sprites = [] : dispose_sprites
    #     $game_party.members.each_with_index do |actor,index| 
    #       @sprites << Sprite.create do |sp|
    #         sp.attrset :x=>index * 58 + 160+276, :y=>507-25+115
    #         sp.bitmap = Cache.sface(actor.face_name)
    #         sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
    #         sp.tone = Tone.new(0,0,0,255) if actor.dead?
    #         sp.opacity = 100 if actor.dead?
    #         if self.active
    #            sp.opacity = 255
    #          else
    #            if actor.index == self.index
    #               sp.opacity = 255
    #            else
    #               sp.opacity = 100
    #            end
    #         end
    #         sp.z = 100
    #       end
    #       @sprites << Sprite.create do |sp|
    #         sp.attrset :x=>index * 58 + 160+276, :y=>498-25+115
    #         if actor.dead?
    #           sp.bitmap = Cache.hp("mapstatusmask_dead") 
    #         else
    #           sp.bitmap = Cache.hp("mapstatusmask")
    #         end
    #         sp.z = 99
    #       end
    #     end
    #   end
    #   def create_arrow
    #     @arrow = Sprite.create do |sp|
    #       sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
    #     end
    #     update_cursor
    #   end
    #   def actor ; $game_party.members[self.index]; end  
    #   def update_cursor
    #     unless @arrow.nil?
    #       @arrow.x = self.index%19*58 + 190+276-38
    #       @arrow.y = self.index/19*62 + 507-15+115-19
    #       @arrow.visible = self.active
    #     end
    #   end
    #   def dispose_sprites
    #     @sprites.each{|n|n.bitmap.dispose;n.dispose} ; @sprites.clear
    #   end
    #   def dispose
    #     super ; dispose_sprites ; @arrow.dispose ; @arrow.bitmap.dispose
    #   end
    #   def process_handling
    #     super
    #     if self.active
    #       if Input.repeat?(:LEFT) && handle?(:left)
    #         call_handler(:left)
    #       end
    #       if Input.repeat?(:RIGHT) && handle?(:right)
    #         call_handler(:right)
    #       end
    #     end
    #   end
    #      def process_cursor_move
    #         return unless cursor_movable?
    #         last_index = @index
    #          if Input.repeat?(:RIGHT) or Keys.trigger?(Keys::D)
    #             cursor_right(Input.trigger?(:RIGHT))
    #             call_handler(:right)
    #          end   
    #         if Input.repeat?(:LEFT)  or Keys.trigger?(Keys::A)
    #            cursor_left (Input.trigger?(:LEFT))  
    #            call_handler(:left)
    #          end  
    #         Sound.play_cursor if @index != last_index
    #      end
    # end
    # @party_window.instance_eval do 
    #   self.opacity = 0 ; self.index = 0 ; self.activate ; self.create_arrow ; self.refresh 
    # end
    
    @party_window.set_handler(:ok,     method(:on_party_ok))
    @party_window.set_handler(:cancel, method(:on_party_cancel))
    @party_window.set_handler(:left, method(:on_party_left))
    @party_window.set_handler(:right, method(:on_party_right))
  end

  def on_party_cancel
    @party_window.activate
    SceneManager.call(Scene_Map)
  end

  def command_no
    @party_window.activate
    @confirmation_window.deactivate
    @party_window.refresh
  end

  def make_command_list
    add_command("是", :command_yes)
    add_command("否", :command_no)
  end

  def command_yes
      real_exp_book
      actor = @party_window.actor
      exp = actor.next_level_exp - actor.exp
      if $game_party.expbook > exp and !actor.max_x_level?
         Audio.se_play("Audio/SE/156-Support14",95,60)
         @party_window.refresh
         @window_status.refresh
         @party_window.deactivate
         add_exp
         @tt = 255
         @now_actor.tone = Tone.new(255,255,255,255)
         if @party_window.actor != nil and $game_switches[S::CV] == true
         if $game_switches[632] == false 
            Audio.se_play("Audio/SE/Actor_first/#{@party_window.actor.id}"+"-kill")
         else
            Audio.se_play("Music/CV/#{@party_window.actor.id}"+"-kill")
         end
         end
         refresh_actor(@party_window.actor)
      else
         Sound.play_buzzer
         @party_window.activate
         refresh_actor(@party_window.actor)
         @party_window.refresh if !@party_window.actor.dead?
      end 
  end




  def add_exp
      actor = @party_window.actor
      exp = actor.next_level_exp - actor.exp
      bai = 100
      bai = exp if exp < 100
      exp_ = exp%bai
      exp -= exp_ 
      for i in 0...bai
      $game_party.expbook -= exp/bai
      actor.gain_exp(exp/bai)
      @window_status.refresh
      aa = actor.exp - actor.current_level_exp
      bb = actor.next_level_exp - actor.current_level_exp
      cc = aa/bb.to_f
      gw = (245 * cc).to_i
      @shine.x = 515 + gw
      @shine.opacity = 255
      wait(1)
      end
      @shine.opacity = 0
      if exp_ > 0 
      actor.gain_exp(exp_) 
      @window_status.refresh
      end
      c = $game_variables[252]
      $game_party.expbook = $game_party.expbook.to_i
      $game_variables[252] = ($game_party.expbook + 850912) * 55
      $game_variables[253] = $game_party.expbook.to_s[0,3] + "realexpbook"
      $game_party.expbook = rand(250) if $game_variables[252] == c 
      Audio.se_play("Audio/SE/Evolution",95)
  end
  #--------------------------------------------------------------------------
  # ● 生成信息窗口
  #--------------------------------------------------------------------------
  def create_message_window
      @message_window = Window_Message.new
      @expbook_back_list = Sprite.new
      @expbook_back_list.bitmap = Cache.system("expbook_back_list")
      @expbook_back_list.x = -500
      @expbook_back_list.y = 0
      @expbook_back_list.opacity = 0
      @expbook_back_list.z = 10

      @shine = Sprite.new
      @shine.bitmap = Cache.picture("FF03")
      @shine.x = 515
      @shine.y = 400
      @shine.opacity = 0
      @shine.z = 500


      @lvup = Sprite.new
      @lvup.bitmap = Cache.system("upup")
      @lvup.x = 800-31
      @lvup.y = 490-96
      @lvup.z = 100
      actor = $game_party.members[0]
      book = $game_party.expbook 
      bb = actor.next_level_exp - actor.exp
      @lvup.opacity = 0
      @lvup.opacity = 255 if book > bb
  end
  #--------------------------------------------------------------------------
  # ● 等待信息显示的结束
  #--------------------------------------------------------------------------
  def wait_for_message
      @message_window.update if @message_window
      update_basic while $game_message.visible
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times {|i| update_basic if i < duration }
  end

  #按下确定时，设置当前武将为军师
  def on_party_ok
    if @party_window.actor == nil or @party_window.actor.dead?
      Sound.play_buzzer
      @party_window.activate
      refresh_actor(@party_window.actor)
      @party_window.refresh 
    else
      @confirmation_window.refresh
      @confirmation_window.activate
      @party_window.refresh
    end
  end

  def on_party_left
    refresh_actor(@party_window.actor)
  end

  def on_party_right
    refresh_actor(@party_window.actor)
  end

  # def dispose_menu_background
  #   super
  #   $game_temp.background_bitmap.dispose
  # end


  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("expbook_back")
    @back_sprite_name = Sprite.new
    @back_sprite_name.x = 708
    @back_sprite_name.y = 105
    @back_sprite_name.z = 200
    @back_sprite_name.bitmap = Bitmap.new(300,100)
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if  @tt == 255
        @nx += 5
        @now_actor.tone.set(255-@nx,255-@nx,255-@nx,255)
        @expbook_back_list.x += 20 if @expbook_back_list.x < 0
        @expbook_back_list.opacity += 20 if @expbook_back_list.opacity < 255 
        if @nx == 250
           @now_actor.tone.set(0,0,0,0)
           @tt = 0
           @nx = 0
           wait_for_message
           for i in 0...13
                @expbook_back_list.opacity -= 20 
                wait(1)
           end
           @expbook_back_list.x = -500
           @party_window.activate
           @party_window.refresh
           @lvup.opacity = 0
           @lvup.opacity = 255 if $game_party.expbook > (@party_window.actor.next_level_exp - @party_window.actor.exp)
      end
    end

  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # 无需手动释放
  # def terminate
  #   super
  #   dispose_menu_background
  #   @now_actor.dispose ; @now_actor.bitmap.dispose
  #   @back_sprite_name.bitmap.dispose ; @back_sprite_name.dispose
  #   if @menuback_sprite
  #      @menuback_sprite.bitmap.dispose  if @menuback_sprite.bitmap
  #      @menuback_sprite.dispose
  #   end
  #   if @expbook_back_list ; @expbook_back_list.bitmap.dispose ; @expbook_back_list.dispose ; end
  #   if @lvup ; @lvup.bitmap.dispose ; @lvup.dispose ; end
  #   @shine.bitmap.dispose ; @shine.dispose
  # end

  def after_dispose
    $game_switches[492] = false
  end

end


#encoding:utf-8
#==============================================================================
# ■ Window_Forge_Confirmation
#------------------------------------------------------------------------------
# 　锻造画面中，确认锻造的窗口。选择  【锻造】 或者 【取消】
#==============================================================================

class Window_expbook_Confirmation < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x-150, y-29, Graphics.width, 48)
    self.opacity = 0
    @back = Sprite.new
    @back.bitmap = Cache.system("book_yes_no")
    @back.y = 400
    @back.visible = false
    self.visible = false
    self.active = false
    deactivate
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

  def yes?
    index == 0
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose
  #   @back.dispose
  # end

  def update
    super
    self.visible = self.active
    @back.visible = self.active
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

