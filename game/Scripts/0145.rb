#encoding:utf-8
#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　物品画面
#==============================================================================

class Jm_Party_Window < Window_Selectable

  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.opacity = 0
    self.index = 0
    self.activate
    self.refresh
    self.create_arrow
  end

  def item_max ; $game_party.members.size end
  def col_max ; $game_party.members.size end
  def refresh 
    self.contents.clear
    @sprites.nil? ? @sprites = [] : dispose_sprites
    $game_party.members.each_with_index do |actor,index| 
      @sprites << Sprite.create do |sp|
        sp.attrset :x=>index * 58 + 160+276, :y=>507-25+115
        sp.bitmap = Bitmap.new("Graphics/Faces/sface/#{actor.face_name}")
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
          sp.bitmap = Bitmap.new("Graphics/hp/mapstatusmask_dead") 
        else
          sp.bitmap = Bitmap.new("Graphics/hp/mapstatusmask")
        end
        sp.z = 99
      end
      if $game_party.jm_actor.include? actor.id 
          @sprites << Sprite.create do |sp|
          sp.attrset :x=>index * 58 + 185-45+276, :y=>530-20-45+115
          sp.bitmap = Bitmap.new("Graphics/system/JM")
          sp.z = 102
        end
      end
    end
  end
  def create_arrow
      @size_back = Sprite.new
      @size_back.x = 108
      @size_back.y = 116
      @size_back.z = 21
      
     @arrow = Sprite.create do |sp|
      sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Bitmap.new("Graphics/System/Arrow_ccc")
      sp.z = 101
    end
    update_cursor
  end
  def actor ; $game_party.members[self.index]; end  
  
  def update_cursor
    unless @arrow.nil?
      @arrow.x = self.index%19*58 + 190+276-38
      @arrow.y = self.index/19*62 + 507-15+115-19
      @arrow.visible = self.active
      if $game_variables[100] == $game_party.members[self.index].id
         @size_back.bitmap = Bitmap.new("Graphics/hp/jm_size")
      else
         @size_back.bitmap = Bitmap.new("Graphics/hp/jm_size_no")
      end
    end
  end

  def dispose_sprites
    if @sprites && @sprites.size > 0
      @sprites.each{|n|n.bitmap.dispose;n.dispose} ; @sprites.clear
    end
  end

  # 无需手动释放
  # def dispose
  #   super
  #   dispose_sprites
  #   @arrow.bitmap.dispose
  #   @arrow.dispose 
  #   @size_back.bitmap.dispose
  #   @size_back.dispose
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
     if Input.repeat?(:RIGHT) or Keys.repeat?(Keys::D)
        cursor_right(Input.trigger?(:RIGHT))
        call_handler(:right)
     end   
    if Input.repeat?(:LEFT)  or Keys.repeat?(Keys::A)
       cursor_left (Input.trigger?(:LEFT))  
       call_handler(:left)
     end  
    Sound.play_cursor if @index != last_index
  end

end

class Scene_Jm < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    team_ac_check
    @nx = 0
    @junshi_and_jiang = Sprite.new
    @junshi_and_jiang.bitmap = Bitmap.new("Graphics/hp/jm_jiang")
    @junshi_and_jiang.z = 900
    actor = $game_party.members[0]
    create_background
    create_party_window
    create_now_actor
    create_confirmation_window
    create_help_window
    create_skill_window(actor)
    refresh_actor(actor)
  end

  def create_confirmation_window
    @confirmation_window = Window_jm_Confirmation.new(0,559+10)
    @confirmation_window.viewport = @viewport
    @confirmation_window.set_handler(:command_yes,  method(:clear_jm_size))
    @confirmation_window.set_handler(:command_no, method(:command_no))
  end

  def create_help_window
    @help_window = Window_Help.new
    @help_window.attrset(:x=>261-120,:y=>164+374)
  end

 def create_skill_window(actor)
    @skill_window = Window_JmList.new(200,200,900,400)
    @skill_window.actor = actor
    @skill_window.instance_eval do 
    self.create_icon_back ; self.refresh ; self.index = 0 ; self.deactivate ; self.create_arrow 
    end
    @skill_window.set_handler(:ok,     method(:on_skill_ok))
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
    @skill_window.deactivate
  end

  def create_now_actor
    @now_actor = Sprite.create do |sp|
      #sp.attrset :x=>0,:y=>Graphics.height-208,:z=>101
      sp.attrset :x=>563,:y=>80-120,:z=>101
    end

    def @now_actor.set(actor)
      if actor.nil?
         self.bitmap = Bitmap.new("Graphics/Faces/000")
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
        self.bitmap = Bitmap.new("Graphics/Faces/#{s}")
        self.src_rect = Rect.new(b, c, 160, 224)
      end
    end
  end

  def refresh_actor(actor)
    $game_player.refresh
    @now_actor.set(actor)
    return if actor.nil?
    @skill_window.actor = actor
    if actor.id == $game_variables[100]
     # @skill_window.activate
      @junshi_and_jiang.bitmap = Bitmap.new("Graphics/hp/jm_junshi")
      @junshi_and_jiang.x = 598+4
      @junshi_and_jiang.y = 269-150
    else
     # @skill_window.deactivate
      @junshi_and_jiang.bitmap = Bitmap.new("Graphics/hp/jm_jiang")
      @junshi_and_jiang.x = 598+4
      @junshi_and_jiang.y = 269-150
    end
  
    @back_sprite_name.bitmap.font.name = "Noto"
    @back_sprite_name.bitmap.font.size = 19 + $game_variables[300]+1
    @back_sprite_name.bitmap.clear
    @back_sprite_name.bitmap.draw_text(0,0,100,55,"#{(actor).name}" + " Lv " + "#{(actor).level}",1)
    @skill_window.refresh
  end

  def create_party_window
    @party_window = Jm_Party_Window.new(484,436,480-318,640)

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
    #       if $game_party.jm_actor.include? actor.id 
    #           @sprites << Sprite.create do |sp|
    #           sp.attrset :x=>index * 58 + 185-45+276, :y=>530-20-45+115
    #           sp.bitmap = Cache.system("JM")
    #           sp.z = 102
    #         end
    #       end
    #     end
    #   end
    #   def create_arrow
    #       @size_back = Sprite.new
    #       @size_back.x = 108
    #       @size_back.y = 116
    #       @size_back.z = 21
          
    #      @arrow = Sprite.create do |sp|
    #       sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
    #       sp.z = 101
    #     end
    #     update_cursor
    #   end
    #   def actor ; $game_party.members[self.index]; end  
      
    #   def update_cursor
    #     unless @arrow.nil?
    #       @arrow.x = self.index%19*58 + 190+276-38
    #       @arrow.y = self.index/19*62 + 507-15+115-19
    #       @arrow.visible = self.active
    #       if $game_variables[100] == $game_party.members[self.index].id
    #          @size_back.bitmap = Cache.hp("jm_size")
    #       else
    #          @size_back.bitmap = Cache.hp("jm_size_no")
    #       end
    #     end
    #   end


    #   def dispose_sprites
    #     @sprites.each{|n|n.bitmap.dispose;n.dispose} ; @sprites.clear
    #   end
    #   def dispose
    #     super ; dispose_sprites ;  @arrow.bitmap.dispose ; @arrow.dispose 
    #     @size_back.bitmap.dispose ; @size_back.dispose
    #   end
    #   def process_handling
    #     super
    #     if self.active
    #       if Input.repeat?(:LEFT) && handle?(:left)
    #          call_handler(:left)
    #       end
    #       if Input.repeat?(:RIGHT) && handle?(:right)
    #          call_handler(:right)
    #       end
    #     end
    #   end

    #      def process_cursor_move
    #         return unless cursor_movable?
    #         last_index = @index
    #          if Input.repeat?(:RIGHT) or Keys.repeat?(Keys::D)
    #             cursor_right(Input.trigger?(:RIGHT))
    #             call_handler(:right)
    #          end   
    #         if Input.repeat?(:LEFT)  or Keys.repeat?(Keys::A)
    #            cursor_left (Input.trigger?(:LEFT))  
    #            call_handler(:left)
    #          end  
    #         Sound.play_cursor if @index != last_index
    #      end
    # end
    # @party_window.instance_eval do 
    #   self.opacity = 0 ; self.index = 0 ; self.activate ; self.refresh ;  self.create_arrow
    # end
    @party_window.set_handler(:ok,     method(:on_party_ok))
    @party_window.set_handler(:cancel, method(:on_party_cancel))
    @party_window.set_handler(:left, method(:on_party_left))
    @party_window.set_handler(:right, method(:on_party_right))
  end

  def on_party_cancel
    @party_window.activate
    SceneManager.goto(Scene_Map)
  end

  def command_no
    @party_window.activate
    @confirmation_window.deactivate
    @skill_window.deactivate
    @skill_window.visible = false
    @help_window.visible = false
    @party_window.refresh
  end

  def make_command_list
    add_command("是", :command_yes)
    add_command("否", :command_no)
  end

  def command_yes
    Audio.se_play("Audio/SE/skill3",75)
    @tt = 255
    @now_actor.tone = Tone.new(255,255,255,255)
    if @party_window.actor != nil and $game_switches[S::CV] == true
    if $game_switches[632] == false 
       Audio.se_play("Audio/SE/Actor_first/#{@party_window.actor.id}"+"-"+"#{1+rand(2)}") 
       else
       Audio.se_play("Music/CV/#{@party_window.actor.id}"+"-"+"#{1+rand(2)}") 
    end
    end
    $game_party.jm_actor = [@party_window.actor.id]
    $game_variables[100] = @party_window.actor.id
    master_skills_del
    @party_window.deactivate
    @party_window.refresh
    refresh_actor(@party_window.actor)
    @skill_window.activate
    @skill_window.refresh
    @skill_window.update_cursor
    @help_window.visible = true
    @skill_window.visible = true
    @skill_window.show_arrow
    @skill_window.update_cursor
    @skill_window.help_window = @help_window 
  end

  def clear_jm_size
      @skill_window.forget_all_skills 
      command_yes
  end  

  #按下确定时，设置当前武将为军师
  def on_party_ok
      if @party_window.actor != nil && $game_party.jm_actor.include?(@party_window.actor.id) #or @party_window.actor.dead?
         command_yes
      else
         @confirmation_window.refresh
         @confirmation_window.activate
         @skill_window.deactivate
         @help_window.visible = false
         @party_window.refresh
      end
  end

  def on_party_left
    refresh_actor(@party_window.actor)
  end

  def on_party_right
    refresh_actor(@party_window.actor)
  end

  def on_skill_cancel
      @party_window.activate
      @skill_window.deactivate
      @skill_window.visible = false
      @help_window.visible = false
      @skill_window.hide_arrow
      @party_window.refresh
  end


  def on_skill_ok
      @skill_window.add_skill
      @skill_window.activate
  end

  # def dispose_menu_background
  #   super
  #    $game_temp.background_bitmap.dispose
  # end


  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Bitmap.new("Graphics/System/jm_back")
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
      if @nx == 250
        @now_actor.tone.set(0,0,0,0)
        @tt = 0
        @nx = 0
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   dispose_menu_background
  #   if @now_actor
  #     @now_actor.dispose
  #     @now_actor.bitmap.dispose
  #   end
  #   if @menuback_sprite
  #      @menuback_sprite.bitmap.dispose  if @menuback_sprite.bitmap
  #      @menuback_sprite.dispose
  #   end

  #   if @back_sprite_name
  #     @back_sprite_name.bitmap.dispose
  #     @back_sprite_name.dispose
  #   end
  #   if @junshi_and_jiang
  #     @junshi_and_jiang.bitmap.dispose
  #     @junshi_and_jiang.dispose
  #   end
  # end

  def master_skills_del
    for i in 0...250
      if $game_actors[i] != nil and i != $game_variables[100] and i != 208 and i != 207
         $game_actors[i].forget_skill(190) 
         $game_actors[i].forget_skill(189)
         $game_actors[i].forget_skill(188) 
         $game_actors[i].forget_skill(113)  
         for c in 598...700
           if $data_skills[c].speed == 90
              $game_actors[i].forget_skill(c)
           end
         end
      end

    end
  end

end


#encoding:utf-8
#==============================================================================
# ■ Window_Forge_Confirmation
#------------------------------------------------------------------------------
# 　锻造画面中，确认锻造的窗口。选择  【锻造】 或者 【取消】
#==============================================================================

class Window_jm_Confirmation < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x-150, y-29, Graphics.width, 48)
    self.opacity = 0
    @back = Sprite.new
    @back.bitmap = Bitmap.new("Graphics/System/jm_yes_no")
    @back.y = 410
    @back.visible = false
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

  # def draw_item(index)
  #   contents.font.size = 18 + $game_variables[300]
  #   super(index)
  # end

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
      # contents.color = Color.new(255,0,0,255)
       draw_text(256 + 240,-2,200,32,"是否确认进化")
      # draw_item_name(@item, 400, 0, true, 172)
      draw_item_name(@item[:equipment], 400 + 240, 0-3, true, 172)
    end
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

