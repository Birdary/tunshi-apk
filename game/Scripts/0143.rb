#encoding:utf-8
#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　物品画面
#==============================================================================

class Actor_House_Party_Window < Window_Selectable

  def initialize(x, y, width, height)
    super(x, y, width, height)

    self.opacity = 0
    self.refresh
    self.index = 0
    self.activate
    self.create_arrow
  end  

  def item_max ; $game_variables[99] end
  def col_max ; $game_variables[99] end
  def refresh 
    add_x = 276
    self.contents.clear
    @sprites.nil? ? @sprites = [] : dispose_sprites
    $game_party.members.each_with_index {|actor,index| 
      @sprites << Sprite.create do |sp|
        sp.attrset :x=>index * 58 + 160+add_x, :y=>507-25-58-20
        sp.bitmap = Cache.sface(actor.face_name)
        sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
        sp.z = 100
        sp.tone = Tone.new(0,0,0,255) if actor.dead?
        if self.visible == true
           sp.opacity = 255
        else
           sp.opacity = 75
        end
        sp.opacity = 120 if actor.dead?
        sp.opacity = 255 if  self.actor != nil and self.actor.id == $game_party.members[index].id 
      end
      @sprites << Sprite.create do |sp|
        sp.attrset :x=>index * 58 + 160+add_x, :y=>498-25-60-20
        sp.bitmap = Cache.hp("mapstatusmask2")
        sp.bitmap = Cache.hp("mapstatusmask_dead") if actor.dead?
        sp.z = 99
      end
      if $game_party.cant_remove_actors.include? actor.id or actor.id == $game_variables[100]
          @sprites << Sprite.create do |sp|
          sp.attrset :x=>index * 58 + 185-45+275, :y=>530-20-45-58-20
          if actor.id == $game_variables[100] and !$game_party.cant_remove_actors.include?(actor.id)
             sp.bitmap = Cache.system("JM")
          else
             sp.bitmap = Cache.system("Locked")
          end  
          if self.visible == true
             sp.opacity = 255
             @junshi.opacity = 255 if @junshi != nil
          else
             sp.opacity = 0
             @junshi.opacity = 0  if @junshi != nil
          end
          sp.z = 999
        end
      end
    }
  end
  def create_arrow
    @arrow = Sprite.create do |sp|
      sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
    end
    update_cursor
  end
  def actor ; $game_party.members[self.index]; end  
  def update_cursor
    # self.active ? cursor_rect.set(self.index*48, 0 , 32, 24) : cursor_rect.empty
    unless @arrow.nil?
      @arrow.x = self.index%22*58 + 190 +276-38
      @arrow.y = self.index/22*62 + 507-15-59-19-20
      @arrow.visible = self.active
    end
  end
  def dispose_sprites
    if @sprites && @sprites.size > 0
      @sprites.each_with_index do |sp,index|
        sp.bitmap.dispose
        sp.dispose
        @sprites[index] = nil
      end
      @sprites.clear
    end
  end

  # => 无需手动释放
  # def dispose
  #   super ; dispose_sprites ; @arrow.dispose ; @arrow.bitmap.dispose
  # end
  
  def process_handling
    super
    if self.active

      if Input.repeat?(:LEFT) and handle?(:left)
         call_handler(:left)
      end
      if Input.repeat?(:RIGHT) and handle?(:right)
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

class Actor_House_House_Window < Window_Selectable

  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.opacity = 0
    self.refresh
    self.index = 0
    self.deactivate
    self.create_arrow
    @arrow.visible = false
  end  



  def item_max ; 60 end
  def col_max ; 20 end

  def refresh

    self.contents.clear
    @sprites.nil? ? @sprites = [] : dispose_sprites
    $game_party.house_members.each_with_index do |actor,index|
      @sprites << Sprite.create do |sp|
        sp.attrset :x=>index % 20 * 58 + 160-156+56, :y=>index/20*62 + 587 -5-62-20
        sp.bitmap = Cache.sface(actor.face_name)
        sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
        sp.z = 100
        sp.tone = Tone.new(0,0,0,255) if actor.dead?
        if self.visible == true
           sp.opacity = 120
        else
           #if self.actor != nil and self.actor.id == $game_party.house_members[index].id 
               if $game_party.cant_join_actors.include? actor.id
                   sp.opacity = 120
                 else
                   sp.opacity = 255 
                end
           #else
           #sp.opacity = 255
           #end
        end
      end
      if $game_party.cant_join_actors.include? actor.id 
         @sprites << Sprite.create do |sp|
         sp.attrset :x=>index % 20 * 58 + 160-156+8+56, :y=>index/20*62 + 587-5+10-62-20
         sp.bitmap = Cache.system("Locked_2")
         sp.z = 500
      end
      end

    end
  end
  def actor ; $game_party.house_members[self.index]; end
  def create_arrow
    @arrow = Sprite.create do |sp|
      sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
      sp.z = 490
    end
  end
  def update_cursor
    # self.active ? cursor_rect.set(self.index*48, 0 , 32, 24) : cursor_rect.empty
    unless @arrow.nil?
      @arrow.x = self.index%20*58 + 190-156+57-38
      @arrow.y = self.index/20*62 + 587-62-14-20
      @arrow.visible = self.active
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
      if Input.repeat?(:UP) && handle?(:up)
         call_handler(:left)
      end
      if Input.repeat?(:DOWN) && handle?(:down)
         call_handler(:right)
      end
    end
  end
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
     if Input.repeat?(:RIGHT) or Keys.repeat?(Keys::D)
        cursor_right(Input.trigger?(:RIGHT))
        call_handler(:left)
     end   
     if Input.repeat?(:LEFT)  or Keys.repeat?(Keys::A)
        cursor_left (Input.trigger?(:LEFT))  
        call_handler(:right)
     end  
     if Input.repeat?(:DOWN)  or Keys.repeat?(Keys::S)
        cursor_down (Input.trigger?(:DOWN)) 
        call_handler(:right)
     end
     if Input.repeat?(:UP)  or Keys.repeat?(Keys::W)
        cursor_up   (Input.trigger?(:UP)) 
        call_handler(:left) 
     end
     Sound.play_cursor if @index != last_index
  end

end


class Scene_Actor_House < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    team_ac_check
    for i in 1...999
      if $data_actors[i] != nil
        if $data_actors[i].class_id == 1
           $game_party.remove_actor_ace(i)
        end
      end
    end
    $game_party.remove_actor(1)

    unless $game_variables[230] >= 8
    if $game_switches[700] == true and $game_switches[697] == false
       $game_party.cant_join_actors = []  if $game_switches[696] == false 
       $game_party.cant_remove_actors = []
       $game_variables[261].uniq! if $game_variables[261] != 0
       for i in 0...$game_variables[261].size
           unless $game_party.members.include?($game_actors[$game_variables[261][i]])
                  $game_party.add_actor($game_variables[261][i],:house)
           end
       end 
    end    
    $game_party.cant_remove_actors = [] if $game_switches[700] == true
    end

    @kai = 0
    actor = $game_party.members[0]
    @kong = Sprite.new
    @kong.bitmap = Bitmap.new("Graphics/Faces/kong")
    @kong.z = 900
    @kong.opacity = 0
    create_background
    # create_menu_background
    # create_help_window
    create_party_window
    create_house_window
    create_now_actor
    create_status_window(actor)
    create_equip_window(actor)
    refresh_actor(actor)
  end

  def create_equip_window(actor)
    @window_equip_status = Window_EquipStatus.new(-70+444+7-404,41+57-55-13)
    @window_equip_status.actor = actor
    @window_equip_status.full_mode
    @window_equip_status.instance_eval do
    change_nc_pos(-74+444+7-404,-266-13) ; refresh ; contents.clear_rect(80, 30,120,40)
    end
    @window_equip_slot = Window_EquipSlot.new 33+55,324+2,320
    @window_equip_slot.actor = actor
  end


  def create_status_window(actor)
      @status_window = Window_Over_Status.new(actor)
      @status_window.attrset :x=>-62,:y=>-70+3
      @status_window.refresh
  end

  def create_now_actor
    # body
    @now_actor = Sprite.create do |sp|
      sp.attrset :x=>562,:y=>80-120,:z=>101
    end

    def @now_actor.set(actor)
      return if actor.nil? or actor.id == 1

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

      self.src_rect = Rect.new(b, c, 160, 224)
      self.bitmap = Cache.face("#{s}")
      self.src_rect = Rect.new(b, c, 160, 224)

    end
 

    # character
    @now_character = Sprite.create do |sp|
      sp.attrset :x=>621,:y=>343+30-65-63,:z=>101
    end
    @now_character.instance_eval do
      @pattern = 0 ; @count = 0 ; @actor = nil
    end

    def @now_character.set(actor)
      return if actor.nil?
      self.bitmap = Cache.character(actor.character_name)
      @actor = actor
      update
    end
    def @now_character.update
      return if @actor.nil?
      @pattern = case @count
        when 0..15 ; 1
        when 16..31 ; 0
        when 32..47 ; 1
        when 48..64 ; 2
      end
      @count = 0 if @count >= 64
      @count += 1
      x = @actor.character_index % 4 * 111 + @pattern * 37 
      y = @actor.character_index / 4 * 208
      self.src_rect = Rect.new(x,y,37,52)
    end
  end

  def refresh_actor(actor)
    if actor.nil?
      @kong.opacity = 255
    return
    else
    @kong.opacity = 0
    end
    @now_actor.set(actor)
    @now_character.set(actor)
    @window_equip_status.actor = actor ; @window_equip_status.contents.clear_rect(80, 30,120,40)

    @back_sprite_name.bitmap.font.name = "Noto"
    @back_sprite_name.bitmap.font.size = 19 + $game_variables[300]+1
    @back_sprite_name.bitmap.clear
    @back_sprite_name.bitmap.draw_text(0,0,100,55,"#{(actor).name}" + " Lv " + "#{(actor).level}",1)
    @window_equip_slot.actor = actor
    @status_window.actor = actor
  end

  def create_party_window
    $game_variables[99] = 7 if $game_variables[99] == 0 or $game_variables[99] > 7 
    @party_window = Actor_House_Party_Window.new(484,436-20,480-318,640)

    # class << @party_window
    #   $game_variables[99] = 7 if $game_variables[99] == 0 or $game_variables[99] > 7 
    #   def item_max ; $game_variables[99] end
    #   def col_max ; $game_variables[99] end
    #   def refresh 
    #     add_x = 276
    #     self.contents.clear
    #     @sprites.nil? ? @sprites = [] : dispose_sprites
    #     $game_party.members.each_with_index {|actor,index| 
    #       @sprites << Sprite.create do |sp|
    #         sp.attrset :x=>index * 58 + 160+add_x, :y=>507-25-58-20
    #         sp.bitmap = Cache.sface(actor.face_name)
    #         sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
    #         sp.z = 100
    #         sp.tone = Tone.new(0,0,0,255) if actor.dead?
    #         if self.visible == true
    #            sp.opacity = 255
    #         else
    #            sp.opacity = 75
    #         end
    #         sp.opacity = 120 if actor.dead?
    #         sp.opacity = 255 if  self.actor != nil and self.actor.id == $game_party.members[index].id 
    #       end
    #       @sprites << Sprite.create do |sp|
    #         sp.attrset :x=>index * 58 + 160+add_x, :y=>498-25-60-20
    #         sp.bitmap = Cache.hp("mapstatusmask2")
    #         sp.bitmap = Cache.hp("mapstatusmask_dead") if actor.dead?
    #         sp.z = 99
    #       end
    #       if $game_party.cant_remove_actors.include? actor.id or actor.id == $game_variables[100]
    #           @sprites << Sprite.create do |sp|
    #           sp.attrset :x=>index * 58 + 185-45+275, :y=>530-20-45-58-20
    #           if actor.id == $game_variables[100] and !$game_party.cant_remove_actors.include?(actor.id)
    #              sp.bitmap = Cache.system("JM")
    #           else
    #              sp.bitmap = Cache.system("Locked")
    #           end  
    #           if self.visible == true
    #              sp.opacity = 255
    #              @junshi.opacity = 255 if @junshi != nil
    #           else
    #              sp.opacity = 0
    #              @junshi.opacity = 0  if @junshi != nil
    #           end
    #           sp.z = 999
    #         end
    #       end
    #     }
    #   end
    #   def create_arrow
    #     @arrow = Sprite.create do |sp|
    #       sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
    #     end
    #     update_cursor
    #   end
    #   def actor ; $game_party.members[self.index]; end  
    #   def update_cursor
    #     # self.active ? cursor_rect.set(self.index*48, 0 , 32, 24) : cursor_rect.empty
    #     unless @arrow.nil?
    #       @arrow.x = self.index%22*58 + 190 +276-38
    #       @arrow.y = self.index/22*62 + 507-15-59-19-20
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

    #       if Input.repeat?(:LEFT) and handle?(:left)
    #          call_handler(:left)
    #       end
    #       if Input.repeat?(:RIGHT) and handle?(:right)
    #          call_handler(:right)
    #       end
    #     end
    #   end

    #     def process_cursor_move
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
    #     end

    # end
    # @party_window.instance_eval do 
    #   self.opacity = 0 ; self.refresh ; self.index = 0 ; self.activate ; self.create_arrow
    # end

    @party_window.set_handler(:ok,     method(:on_party_ok))
    @party_window.set_handler(:cancel, method(:on_party_cancel))
    @party_window.set_handler(:left, method(:on_party_left))
    @party_window.set_handler(:right, method(:on_party_right))

  end

  def create_house_window
    @house_window = Actor_House_House_Window.new(350,520-20,800,200)

    # class << @house_window
    #   def item_max ; 60 end
    #   def col_max ; 20 end

    #   def refresh

    #     self.contents.clear
    #     @sprites.nil? ? @sprites = [] : dispose_sprites
    #     $game_party.house_members.each_with_index do |actor,index|
    #       @sprites << Sprite.create do |sp|
    #         sp.attrset :x=>index % 20 * 58 + 160-156+56, :y=>index/20*62 + 587 -5-62-20
    #         sp.bitmap = Cache.sface(actor.face_name)
    #         sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
    #         sp.z = 100
    #         sp.tone = Tone.new(0,0,0,255) if actor.dead?
    #         if self.visible == true
    #            sp.opacity = 120
    #         else
    #            #if self.actor != nil and self.actor.id == $game_party.house_members[index].id 
    #                if $game_party.cant_join_actors.include? actor.id
    #                    sp.opacity = 120
    #                  else
    #                    sp.opacity = 255 
    #                 end
    #            #else
    #            #sp.opacity = 255
    #            #end
    #         end
    #       end
    #       if $game_party.cant_join_actors.include? actor.id 
    #          @sprites << Sprite.create do |sp|
    #          sp.attrset :x=>index % 20 * 58 + 160-156+8+56, :y=>index/20*62 + 587-5+10-62-20
    #          sp.bitmap = Cache.system("Locked_2")
    #          sp.z = 500
    #       end
    #       end

    #     end
    #   end
    #   def actor ; $game_party.house_members[self.index]; end
    #   def create_arrow
    #     @arrow = Sprite.create do |sp|
    #       sp.attrset :x=>self.x,:y=>self.y,:z=>999,:bitmap=>Cache.system("Arrow_ccc")
    #       sp.z = 490
    #     end
    #   end
    #   def update_cursor
    #     # self.active ? cursor_rect.set(self.index*48, 0 , 32, 24) : cursor_rect.empty
    #     unless @arrow.nil?
    #       @arrow.x = self.index%20*58 + 190-156+57-38
    #       @arrow.y = self.index/20*62 + 587-62-14-20
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
    #          call_handler(:left)
    #       end
    #       if Input.repeat?(:RIGHT) && handle?(:right)
    #          call_handler(:right)
    #       end
    #       if Input.repeat?(:UP) && handle?(:up)
    #          call_handler(:left)
    #       end
    #       if Input.repeat?(:DOWN) && handle?(:down)
    #          call_handler(:right)
    #       end
    #     end
    #   end
    #    def process_cursor_move
    #         return unless cursor_movable?
    #         last_index = @index
    #          if Input.repeat?(:RIGHT) or Keys.repeat?(Keys::D)
    #             cursor_right(Input.trigger?(:RIGHT))
    #             call_handler(:left)
    #          end   
    #          if Input.repeat?(:LEFT)  or Keys.repeat?(Keys::A)
    #             cursor_left (Input.trigger?(:LEFT))  
    #             call_handler(:right)
    #          end  
    #          if Input.repeat?(:DOWN)  or Keys.repeat?(Keys::S)
    #             cursor_down (Input.trigger?(:DOWN)) 
    #             call_handler(:right)
    #          end
    #          if Input.repeat?(:UP)  or Keys.repeat?(Keys::W)
    #             cursor_up   (Input.trigger?(:UP)) 
    #             call_handler(:left) 
    #          end
    #          Sound.play_cursor if @index != last_index
    #     end
    # end
    # @house_window.instance_eval do 
    #   self.opacity = 0 ; self.refresh ; self.index = 0 ; self.deactivate; self.create_arrow ; @arrow.visible = false
    # end
    @house_window.set_handler(:ok,     method(:on_house_ok))
    @house_window.set_handler(:cancel, method(:on_house_cancel))
    @house_window.set_handler(:left,   method(:on_house_left))
    @house_window.set_handler(:right,  method(:on_house_right))
    @house_window.set_handler(:up,     method(:on_house_left))
    @house_window.set_handler(:down,   method(:on_house_right))
  end

  def on_party_cancel
    @party_window.activate
    SceneManager.call(Scene_Map)
  end

  def on_party_ok
    if @party_window.actor != nil && $game_party.cant_remove_actors.include?(@party_window.actor.id) or ( @party_window.actor != nil and @party_window.actor.dead? ) or (@party_window.actor != nil and @party_window.actor.id == $game_variables[100]) 
      Sound.play_buzzer
      @party_window.activate
      @house_window.deactivate
      refresh_actor(@party_window.actor)
      @party_window.refresh if !@party_window.actor.dead?#; @house_window.refresh 
    else
      @house_window.visible = false
      @party_window.visible = false
      @house_window.refresh 
      @party_window.refresh
      @house_window.activate
      @party_window.deactivate
      refresh_actor(@house_window.actor)
    end
  end

  def on_party_left
    refresh_actor(@party_window.actor)
  end

  def on_party_right
    refresh_actor(@party_window.actor)
  end

  def on_house_ok
    actor1 = @party_window.actor
    actor2 = @house_window.actor
    if @house_window.actor == nil and  $game_party.alive_members.size == 1
      Sound.play_buzzer
      @party_window.refresh ; @house_window.refresh 
      refresh_actor(@party_window.actor)
      @party_window.activate ; @house_window.deactivate
      return
    end

    if @house_window.actor != nil and $game_party.cant_join_actors.include? actor2.id 
      Sound.play_buzzer
      @house_window.refresh 
      #refresh_actor(@party_window.actor)
      @house_window.activate 
      return
    end   

    if @party_window.actor != nil && $game_party.cant_remove_actors.include?(@party_window.actor.id)
      @party_window.activate ; @house_window.deactivate
      return
    end
    if @house_window.actor != nil and $game_switches[S::CV] == true
       if $game_switches[632] == false 
          Audio.se_play("Audio/SE/Actor_first/#{@house_window.actor.id}"+"-"+"#{1+rand(2)}")
       else
          Audio.se_play("Music/CV/#{@house_window.actor.id}"+"-"+"#{1+rand(2)}") 
       end
    end
    Audio.se_play("Audio/SE/Decision3")
    @house_window.visible = true
    @party_window.visible = true
    $game_party.change_actor(actor1,actor2)
    @party_window.select($game_party.members.size-1)
    @party_window.refresh ; @house_window.refresh 
    @party_window.activate ; @house_window.deactivate
    refresh_actor(@party_window.actor)
  end

  def on_house_cancel
    @house_window.visible = true
    @party_window.visible = true
    @house_window.refresh
    @party_window.refresh
    @house_window.index = 0
    @party_window.activate
    refresh_actor(@party_window.actor)
  end

  def on_house_left
    refresh_actor(@house_window.actor)
        @house_window.refresh 
  end

  def on_house_right
    refresh_actor(@house_window.actor)
        @house_window.refresh 
  end

  # def dispose_menu_background
  #   super
  #   # $game_temp.background_bitmap.dispose
  # end

  def create_help_window
    super
    @help_window.attrset(:x=>490,:y=>60)
  end

  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("actorhouse_back")
    if $game_variables[99] < 7
    @xxx = Sprite.new
    @xxx.bitmap = Bitmap.new("Graphics/system/house_0"+"#{$game_variables[99]}")
    @xxx.x =274+1
    @xxx.y = -60-19 
    @xxx.z = 300
    end
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
     @now_character.update
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   dispose_menu_background
  #   @kong.bitmap.dispose ; @kong.dispose
  #   if $game_variables[99] < 7
  #     @xxx.bitmap.dispose ; @xxx.dispose
  #   end
  #   if @menuback_sprite
  #     @menuback_sprite.bitmap.dispose  if @menuback_sprite.bitmap
  #     @menuback_sprite.dispose
  #   end
  #   @back_sprite_name.bitmap.dispose ; @back_sprite_name.dispose
  #   @now_character.dispose ; @now_character.bitmap.dispose
  #   @now_actor.dispose ; @now_actor.bitmap.dispose
  # end
end


class Window_Over_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, Graphics.width, Graphics.height)
    @actor = actor
    self.opacity = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end

  # def dispose
  #   super
  # end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    actor = @actor
    return if actor.nil?
      contents.font.size = 19 + $game_variables[300]
      contents.font.color = normal_color
      contents.font.name = "Noto"
      draw_text(328, 358-2, 150, 100,@actor.kill_size_all, 0)
      draw_text(328, 358+36-2, 150, 100,@actor.dead_size_all, 0)
      draw_text(328, 358+72-2, 150, 100,@actor.over_damage_all, 0)
      draw_text(328, 358+108-2, 150, 100,@actor.over_sup_all, 0)
  end

end



