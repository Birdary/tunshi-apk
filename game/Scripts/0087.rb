#encoding:utf-8
#==============================================================================
# ■ Window_BattleActor
#------------------------------------------------------------------------------
# 　战斗画面中，选择“队友目标”的窗口。
#==============================================================================

class Window_BattleActor < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     info_viewport : 信息显示用显示端口
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
   # super(info_viewport.rect.x, info_viewport.rect.y, info_viewport.rect.width, info_viewport.rect.height)
    super(info_viewport.rect.x, info_viewport.rect.y, 20, 20)
    self.visible = false
    self.opacity = 0
    #self.contents_opacity = 0
    #self.back_opacity = 0
    @index = 0
    @over = true
    @clone_arrows = []
    @info_viewport = info_viewport
    create_active_tag
    create_arrow
    create_background
    create_flash
    @callbacks = {}
    @arrow_count = 0
    @arrow_state = :none
    @show_state = false
    self.z = 500
    refresh_actor_status
  end

  def create_active_tag
    @active_tag = Sprite_Flash.new(nil)
    @active_tag.bitmap = Cache.system("active")
    @active_tag.visible = false
    @active_tag.x = 1187-272
    @active_tag.y = @index * 29 +492 +11+16
    @active_tag.z = 400

    @flash_state = Sprite_Flash.new
    @flash_state.bitmap = Cache.flash("target_state")
    @flash_state.visible = false
    @flash_state.x = 271
    @flash_state.y = 458
    @flash_state.z = 150
  end

  def create_background
    @back = Sprite.new#(@info_viewport)
    @back.bitmap = Cache.picture("atk_back2")
    @back.visible = false
    @back.x = 0
    @back.y = 457
    @back.z = 100

    @_opacity = Sprite.new#(@info_viewport)
    @_opacity.bitmap = Bitmap.new(551,242)
    @_opacity.visible = false
    @_opacity.x = 0
    @_opacity.y = 457
    @_opacity.z = 101
  end

  def create_arrow
    @arrow = Sprite.new
    @arrow.bitmap = Cache.system("Arrow_s")
    @arrow.z = 500
    @arrow.visible = false

    $game_party.battle_members.each do |ac|
      a = Sprite_Flash.create do |sp|
        sp.attrset :x=>ac.screen_x-319-10,:y=>ac.screen_y-122+9,:visible=>false,:z=>500
        sp.bitmap = Cache.system("Arrow_s")
      end
      @clone_arrows << a 
    end
  end
  def set_handler(sym,fun)
    @callbacks[sym] = fun
  end
  def dispose
    super

    # => 无需手动删除
    # if @active_tag
    #    @active_tag.bitmap.dispose
    #    @active_tag.dispose
    # end
    # if @flash_state
    #    @flash_state.bitmap.dispose
    #    @flash_state.dispose
    # end
    # if @flash
    #    @flash.bitmap.dispose
    #    @flash.dispose
    # end
    # if @back
    #    @back.bitmap.dispose
    #    @back.dispose
    # end
    # if @_opacity
    #    @_opacity.bitmap.dispose
    #    @_opacity.dispose
    # end
    # if @arrow
    #    @arrow.bitmap.dispose
    #    @arrow.dispose
    # end

    if @clone_arrows && @clone_arrows.size > 0
      @clone_arrows.each_with_index do |_arrow,_index|
        if _arrow
          _arrow.bitmap.dispose if _arrow.bitmap
          _arrow.dispose
          @clone_arrows[_index] = nil
        end
      end
      @clone_arrows.clear
      @clone_arrows = nil
    end

  end

  def index
    @index
  end

  def create_flash
    @flash = Sprite_Flash.new#(@info_viewport)
    @flash.bitmap = Cache.flash("target_actor_all")
    @flash.visible = false
    @flash.x = 600+450
    @flash.y = 446+8
    @flash.z = 200
  end

  def update_flash
    @flash.update 
    @flash_state.update
  end 
  #--------------------------------------------------------------------------
  # ● 获取角色实例
  #--------------------------------------------------------------------------
  def actor
    party[@index]
  end
  def party
    $game_party.battle_members
  end
  def show_all_arrow
    @clone_arrows.each_with_index do |arrow,index|
      ac = $game_party.battle_members[index]
      if ac.alive? 
        arrow.visible = true
        arrow.x = ac.screen_x-319 -10
      end
    end
    @arrow.visible = false
    @arrow_state = :all
  end

  def hide_all_arrow
    @back.visible = false
    @flash_state.visible = false
    @_opacity.visible = false
    @clone_arrows.each do |arrow|
      arrow.visible = false
    end
  end

  def show_one_arrow
    hide_all_arrow
    @over = true
    @arrow.visible = true
    @arrow_state = :one
    @back.visible = true
    @flash_state.visible = true
    @_opacity.visible = true
    refresh_actor_status
  end

  # 重新激活当前 actor
  def activate_current_actor
    self.visible = true
    @arrow.visible = true
    @back.visible = true
    @flash_state.visible = true
    @arrow_state = :one
    unselect_all
    show.activate
    flash_index
  end

  def select_all
    $game_party.battle_members.each { |ac| ac.selected = true if ac.alive?}
  end

  def unselect_all
    $game_party.battle_members.each { |ac| ac.selected = false }
  end

  def cancel_select
      @back.visible = false
      @flash_state.visible = false
      @_opacity.visible = false
      self.visible = false
      @arrow_state = :none
      unselect_all
      actor.selected = false
      hide_all_arrow
  end

  def ch_index(n)
    actor.selected = false
    @index = n 
    actor.selected = true
  end

  def flash_index
    actor.selected = true
  end

  def update
    super
    if @over == true
       @arrow.visible = @active_tag.visible = self.visible = @flash_state.visible = @back.visible  
       @arrow.visible = @arrow_state == :one
       @flash.visible = @arrow.visible
      user = BattleManager.actor
      return unless user
      skill = user.last_skill.object
      if !skill.nil? && skill.is_marv? 
          if skill.can_all? and @arrow.visible == true
             @flash.visible = true 
          else
             @flash.visible = false 
          end
      end
    if @arrow_state == :one || @arrow_state == :all
       update_input
       update_active_tag
       update_arrow
       @arrow.x = actor.screen_x - 319 - 10
       @arrow.y = actor.screen_y - 122 + 9
    end
       update_flash
    end  
  end

  def update_arrow
    if @arrow_state == :all
      #@arrow_count += 1
      @clone_arrows.each do |arrow|
        # arrow.opacity -= 50 if (0..4).to_a.include? @arrow_count
        # arrow.opacity += 50 if (5..9).to_a.include? @arrow_count
        arrow.update
      end
      #@arrow_count = 0 if @arrow_count >= 9
    end
    # if @arrow_state == :one
    #   @arrow.update
    # end
  end

  def update_active_tag
    @active_tag.y = @index * 29 +492 - 35+11+16
    @active_tag.update
  end

  def last_skill_a
    BattleManager.actor.last_skill
  end

  def refresh_actor_status
    return if actor.nil?

    @back.bitmap = Cache.picture("atk_back2")

    up_color = Color.new(128,255,128,255)
    down_color = Color.new(235,51,51,255)
    normal_color = Color.new(255,255,255)
      eny = actor
    s = eny.actor.note.split("\r\n")[0].split(" = ").last
    s = s.to_s
    b = eny.actor.note.split("\r\n")[1].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 224
    else
      c = 0
    end
    b = b*160
    rect = Rect.new(b, c, 160, 224)
    bitmap = Bitmap.new("Graphics/Faces/"+"#{s}")
    @_opacity.bitmap.clear
    @_opacity.bitmap.blt(0, 20-70, bitmap, rect)
    bitmap.dispose
    bitmap2 = Cache.picture("nc_enemy2")
    bitmap3 = Cache.picture("nc_enemy3")
    bitmap4 = Cache.picture("nc_enemy4")
    #@_opacity.bitmap.font.color = Color.new(0,0,0)
    @_opacity.bitmap.font.color = normal_color
    @_opacity.bitmap.font.name = "Noto"
    @_opacity.bitmap.font.size = 20 + $game_variables[300]+2
    @_opacity.bitmap.draw_text(0,133,155,55,eny.name,1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.blt(202,24+19, bitmap3,Rect.new(0,0,eny.atk,bitmap3.height))
    @_opacity.bitmap.blt(202,48+19, bitmap4,Rect.new(0,0,eny.def,bitmap4.height))
    @_opacity.bitmap.blt(202,72+19, bitmap2,Rect.new(0,0,eny.str,bitmap2.height))
    @_opacity.bitmap.blt(202,96+19, bitmap2,Rect.new(0,0,eny.ski,bitmap2.height))
    @_opacity.bitmap.blt(202,120+19,bitmap2,Rect.new(0,0,eny.int,bitmap2.height))
    @_opacity.bitmap.blt(202,144+19,bitmap2,Rect.new(0,0,eny.agi,bitmap2.height))

    add_atk = eny.atk - $battle_old_param[eny.index][0]
    add_def = eny.def - $battle_old_param[eny.index][1]
    add_str = eny.str - $battle_old_param[eny.index][2]
    add_ski = eny.ski - $battle_old_param[eny.index][3]
    add_int = eny.int - $battle_old_param[eny.index][4]
    add_agi = eny.agi - $battle_old_param[eny.index][5]

    @_opacity.bitmap.font.color = up_color     if add_atk > 0
    @_opacity.bitmap.font.color = down_color   if add_atk < 0
    @_opacity.bitmap.font.color = normal_color if add_atk == 0
    @_opacity.bitmap.draw_text(455,24+11,40, 20,eny.atk.to_s,2)    
    @_opacity.bitmap.font.color = up_color     if add_def > 0
    @_opacity.bitmap.font.color = down_color   if add_def < 0
    @_opacity.bitmap.font.color = normal_color if add_def == 0
    @_opacity.bitmap.draw_text(455,48+11,40, 20,eny.def.to_s,2)
    @_opacity.bitmap.font.color = up_color     if add_str > 0
    @_opacity.bitmap.font.color = down_color   if add_str < 0
    @_opacity.bitmap.font.color = normal_color if add_str == 0
    @_opacity.bitmap.draw_text(455,72+11,40, 20,eny.str.to_s,2)
    @_opacity.bitmap.font.color = up_color     if add_ski > 0
    @_opacity.bitmap.font.color = down_color   if add_ski < 0
    @_opacity.bitmap.font.color = normal_color if add_ski == 0
    @_opacity.bitmap.draw_text(455,96+11,40, 20,eny.ski.to_s,2)
    @_opacity.bitmap.font.color = up_color     if add_int > 0
    @_opacity.bitmap.font.color = down_color   if add_int < 0
    @_opacity.bitmap.font.color = normal_color if add_int == 0
    @_opacity.bitmap.draw_text(455,120+11,40,20,eny.int.to_s,2)
    @_opacity.bitmap.font.color = up_color     if add_agi > 0
    @_opacity.bitmap.font.color = down_color   if add_agi < 0
    @_opacity.bitmap.font.color = normal_color if add_agi == 0
    @_opacity.bitmap.draw_text(455,144+11,40,20,eny.agi.to_s,2)
    @show_state = false
    bitmap2.dispose
    bitmap3.dispose
    bitmap4.dispose
  end

  def draw_enemy_icons(enemy, x, y, width = 320)
    icons = (enemy.state_icons + enemy.buff_icons)[0, width / 24]
    if icons.size > 0
      for i in 0...icons.size
        if i < 6
          draw_icon_state(icons[i], x, y + 24 * i)
          @_opacity.bitmap.draw_text(x+30,y + 24 * i-8,350,45,enemy.states[i].note,0)
        end
      end    
    else
      @_opacity.bitmap.draw_text(x+32-24,y + 24 * 0-8,350,45,"暂无更多状态",0)
    end
  end

  def draw_icon_state(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @_opacity.bitmap.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end


  def refresh_state
    return if actor.nil?
    eny = actor

    s = eny.actor.note.split("\r\n")[0].split(" = ").last
    s = s.to_s
    b = eny.actor.note.split("\r\n")[1].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 224
    else
      c = 0
    end
    b = b*160
    rect = Rect.new(b, c, 160, 224)
    bitmap = Bitmap.new("Graphics/Faces/"+"#{s}")
    @back.bitmap = Cache.picture("atk_back2_00")
    @_opacity.bitmap.clear
    @_opacity.bitmap.blt(0, 20-70, bitmap, rect)
    @_opacity.bitmap.font.size = 20 + $game_variables[300]+2
    @_opacity.bitmap.draw_text(0,133,155,55,eny.name,1)
    bitmap.dispose
    @_opacity.bitmap.font.size = 16 + $game_variables[300]+2
    draw_enemy_icons(eny, x+172, y-58, width = 320)
  end

  def update_input
    if BattleManager.actor != nil  #修复了左右出错last_skill最后一个队员按下确定后，还可以快速按按键的问题。
      if Input.trigger?(:A) or Keys.trigger?(Keys::TAB) or Input.trigger?(:L)  or ($game_switches[742] == true and (Input.trigger?(:Z)  or Input.trigger?(:Y) or Input.trigger?(:R)))
        Sound.play_cursor
        if @show_state == false
          @_opacity.bitmap.clear
          refresh_state
          @show_state = true
        else
          @_opacity.opacity = 255
          refresh_actor_status
          @show_state = false
        end 
    end  


    if Input.repeat?(:DOWN) or Keys.repeat?(Keys::S)
      Sound.play_cursor
      if @arrow_state == :one
                  @active_tag.opacity = 255
        if @index < party.size-1
          #actor.selected = false
          #SceneManager.scene.init_select(actor)
          ch_index(@index+1)
          #actor.selected = true
        else
          #actor.selected = false
          ch_index(0)
          #actor.selected = true
        end
        @arrow.opacity = 255
        refresh_actor_status
      end
      if @arrow_state == :all
        show_one_arrow
        unselect_all
        actor.selected = true
          @active_tag.bitmap = Cache.system("active")
          @active_tag.opacity = 255
      end
    end
    if Input.repeat?(:UP) or Keys.repeat?(Keys::W)
      Sound.play_cursor
      if @arrow_state == :one
                  @active_tag.opacity = 255
        if @index > 0
          #actor.selected = false
          #SceneManager.scene.init_select(actor)
          ch_index(@index-1)
          #actor.selected = true
        else
          #actor.selected = false
          ch_index(party.size-1)
          #actor.selected = true
        end
        @arrow.opacity = 255
      end
      if @arrow_state == :all
        show_one_arrow
        unselect_all
        actor.selected = true
         @active_tag.bitmap = Cache.system("active")
          @active_tag.opacity = 255
      end
      refresh_actor_status
    end
     

    if Input.trigger?(:LEFT) || Input.trigger?(:RIGHT) || Keys.trigger?(Keys::A) || Keys.trigger?(Keys::D)
      skill = last_skill_a.object
      if !skill.blank? && skill.can_all? 
        if @arrow_state == :one
          # 只有一个人的情况下不能切换全体
          if $game_party.alive_members.size > 1
                           Audio.se_play("Audio/SE/Cursor2")
                Sound.play_cursor
            show_all_arrow
            select_all
            @active_tag.bitmap = Cache.system("000")
            @active_tag.opacity = 0
                  @clone_arrows.each do |arrow|
                   arrow.opacity = 255 
                  end
          end
        elsif @arrow_state == :all 
                         Audio.se_play("Audio/SE/Cursor2")
                Sound.play_cursor
          show_one_arrow
          unselect_all
          actor.selected = true
          @active_tag.bitmap = Cache.system("active")
          @active_tag.opacity = 255

        end
      else
        Sound.play_buzzer
      end
    end

    if Input.trigger?(:B)
       Sound.play_cancel
       @callbacks[:cancel].call
       cancel_select
    end
    if Input.trigger?(:C)
        if @arrow_state == :one && actor.hp > 0 && last_skill_a.object.for_dead_friend? 
        Sound.play_buzzer
        SceneManager.scene.set_text("无法对该武将使用")
        return
        end

      if @arrow_state == :one && actor.dead? && !last_skill_a.object.for_dead_friend? 
        Sound.play_buzzer

        SceneManager.scene.set_text("无法对该武将使用")
        return
      else
        Sound.play_ok
        @back.visible = false
        @flash_state.visible = false
        @_opacity.visible = false
        self.visible = false
      
        unselect_all
        actor.selected = false
        hide_all_arrow
        self.visible = false
        @arrow.visible = false
        @flash.visible = false
        @_opacity.visible = false
        @active_tag.visible = false
      end
            @over = false
      @callbacks[:ok].call(@arrow_state)
      cancel_select
    end
  end
  end
end
