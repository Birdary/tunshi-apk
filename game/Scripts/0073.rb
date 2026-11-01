#encoding:utf-8
#==============================================================================
# ■ Window_BattleEnemy
#------------------------------------------------------------------------------
# 　战斗画面中，选择“敌人目标”的窗口。
#==============================================================================

class Window_BattleEnemy < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     info_viewport : 信息显示用显示端口
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super(info_viewport.rect.x-12, info_viewport.rect.y, info_viewport.rect.width, info_viewport.rect.height+350)
    self.visible = false
    self.opacity = 0
    #self.contents_opacity = 0
    #self.back_opacity = 0
    @info_viewport = info_viewport
    create_background
    create_flash
    @clone_arrows = []
    create_arrow
    create_success_rate
    @index = 0
    @callbacks = {}
    @arrow_state = :none
    @arrow_count = 0
    @show_state = false
    self.z = 500
    refresh(false)
  end
  def create_background
    @back = Sprite.new#(@info_viewport)
    @back.bitmap = Cache.picture("atk_back")
    @back.visible = false
    @back.x = 0
    @back.y = 457
    @back.z = 100
    @_opacity = Sprite.new
    @_opacity.bitmap = Bitmap.new(551,242)
    @_opacity.visible = false
    @_opacity.x = 0
    @_opacity.y = 457
    @_opacity.z = 101
  end
  def create_flash
    @flash = Sprite_Flash.new(@info_viewport)
    @flash.bitmap = Cache.flash("target")
    @flash.visible = false
    @flash.x = 13-10
    @flash.y = 0
    @flash.z = 50

    @flash_state = Sprite_Flash.new#(@info_viewport)
    @flash_state.bitmap = Cache.flash("target_state")
    @flash_state.visible = false
    @flash_state.x = 271
    @flash_state.y = 458
    @flash_state.z = 150
  end

  def switch_flash(all = false)
    if all
      @flash.bitmap = Cache.flash("target_all")
    else
      @flash.bitmap = Cache.flash("target")
    end
  end

  def create_success_rate
    @succ = Sprite.new#(@info_viewport)
    @succ.bitmap = Bitmap.new(84,79)
    @succ.bitmap.font.size = 16 + $game_variables[300]
    @succ.x  = 100
    @succ.y  = 100
    @succ.z  = 500
  end

  def refresh_succ
    user = BattleManager.actor
    return unless user
    skill = user.last_skill.object
    if !skill.nil? && skill.is_marv? && skill.for_opponent?
        switch_flash(true) if skill.can_all?
            @succ.bitmap.clear
            @succ.bitmap.blt(0,0,Cache.system("success_rate"),Rect.new(0,0,84,79))
      make_succ(user,skill)
      @succ.x  = user.screen_x-327
      @succ.y  = user.screen_y-195
      @succ.bitmap.font.color = Color.new(187,255,0,255) if @rate >= 75
      @succ.bitmap.font.color = Color.new(255,210,0,255) if @rate < 75 and @rate >= 50 
      @succ.bitmap.font.color = Color.new(230,100,0,255) if @rate < 50 and @rate >= 30 
      @succ.bitmap.font.color = Color.new(255,0,0,255)   if @rate < 30
      @succ.bitmap.font.size = 25 + $game_variables[300]
      if @rate < 10
         @succ.bitmap.draw_text 19+10,1,84,79,@rate.to_s
      else
         @succ.bitmap.draw_text 19,1,84,79,@rate.to_s
      end
      @succ.visible = true
    else
      switch_flash(false)
    end
  end

  def make_succ(user,skill)
      if @arrow_state == :all
         s = $game_troop.alive_members.size
         all_rate = 0
         for i in 0...s
             @rate = $game_troop.alive_members[i].item_hit(user, skill) * 100.to_i
             @rate = [@rate.to_i,95].min
             @rate = [@rate.to_i,0].max
             all_rate += @rate
         end
         @rate = ( all_rate / s*1.0 ).to_i
         @succ.bitmap.font.color = Color.new(255,255,255,255) 
         @succ.bitmap.font.size = 16 + $game_variables[300]
         @succ.bitmap.draw_text 45,20,84,79,"Mea"
      else
         @rate = enemy.item_hit(user, skill) * 100.to_i
         @rate = [@rate.to_i,95].min
         @rate = [@rate.to_i,0].max
      end  
  end

  def create_arrow
    @arrow = Sprite.new
    @arrow.bitmap = Cache.system("Arrow_s")
    
    @arrow.mirror = true
    @arrow.z = 500
    @arrow.visible =false

    $game_troop.members.each do |e|
      a = Sprite_Flash.create do |sp|
        sp.attrset :x=>e.screen_x-288+8,:y=>e.screen_y-122+9,:visible=>false,:z=>500,:mirror=>true
        sp.bitmap = Cache.system("Arrow_s")
      end
      @clone_arrows << a 
    end
  end

  def dispose
    super

    # 无需手动释放
    # ( [@back,@flash,@succ,@arrow,@flash_state] + @clone_arrows ).each do |sp|
    #   sp.bitmap.dispose if sp.bitmap
    #   sp.dispose
    # end
    # if @_opacity != nil 
    #    @_opacity.bitmap.dispose
    #    @_opacity.dispose
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

  def update_arrow_pos

  end

  def set_handler(sym,fun)
    @callbacks[sym] = fun
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人实例
  #--------------------------------------------------------------------------
  def enemy
    troop[@index]
  end
  def troop
    $game_troop.alive_members
  end

  def refresh(move_back = true)
    return if enemy.nil?
    eny = enemy
    
    @back.bitmap = Cache.picture("atk_back")
    s = eny.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = eny.enemy.note.split("\r\n")[5].split(" = ").last
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
    @_opacity.bitmap.font.color = Color.new(0,0,0)
    @_opacity.bitmap.font.color = Color.new(255,255,255)
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

    add_atk = eny.atk - $battle_old_param[eny.index+10][0]
    add_def = eny.def - $battle_old_param[eny.index+10][1]
    add_str = eny.str - $battle_old_param[eny.index+10][2]
    add_ski = eny.ski - $battle_old_param[eny.index+10][3]
    add_int = eny.int - $battle_old_param[eny.index+10][4]
    add_agi = eny.agi - $battle_old_param[eny.index+10][5]
    up_color = Color.new(128,255,128,255)
    down_color = Color.new(235,51,51,255)
    @_opacity.bitmap.font.color = up_color     if add_atk > 0
    @_opacity.bitmap.font.color = down_color   if add_atk < 0
    @_opacity.bitmap.font.color = normal_color if add_atk == 0
    @_opacity.bitmap.draw_text(455,24+11,40,20,eny.atk.to_s,2)
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
    SceneManager.scene.spriteset.init_select_enemy_face_back(enemy) if move_back && enemy.index < 5
    refresh_succ
  end

  def draw_enemy_icons(enemy, x, y, width = 320)
      icons = (enemy.state_icons + enemy.buff_icons)[0, width / 24]
      #icons.each_with_index {|n, i| draw_icon_state(n, x , y+ 24 * i) if i < 6}
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
    return if enemy.nil?
    eny = enemy

    s = eny.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = eny.enemy.note.split("\r\n")[5].split(" = ").last
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
    @back.bitmap = Cache.picture("atk_back_00")
    @_opacity.bitmap.clear
    @_opacity.bitmap.blt(0, 20-70, bitmap, rect)
    @_opacity.bitmap.font.size = 20 + $game_variables[300]+2
    @_opacity.bitmap.draw_text(0,133,155,55,eny.name,1)
    bitmap.dispose
    @_opacity.bitmap.font.size = 16 + $game_variables[300]+2
    draw_enemy_icons(eny, x+184, y-58, width = 320)
  end

  def ch_index(n)
    return unless enemy
    enemy.selected = false
    @index = n 
    enemy.selected = true
  end

  def flash_index
    return unless enemy
    enemy.selected = true
  end

  def init_enemy_face_back
    SceneManager.scene.spriteset.init_enemy_face_back(enemy)
  end

  def update
    super
    @arrow.visible = @back.visible = @flash.visible = @flash_state.visible =  @_opacity.visible  = self.visible 
    @arrow.visible = @arrow_state == :one
    @succ.visible = false if self.visible == false
    if @arrow_state == :one || @arrow_state == :all
      update_input if active
      update_flash
      update_arrow
      unless enemy
        @index = 0
        init_enemy_face_back
        ch_index(@index)
        refresh
      end

      @arrow.x = enemy.screen_x-288+8
      @arrow.y = enemy.screen_y-122+9
    end
  end

  def update_flash
    @flash.update
    @flash_state.update
  end 

  def update_arrow
    if @arrow_state == :all
      @clone_arrows.each do |arrow|
        arrow.update
      end
    end
    # if @arrow_state == :one
    #   @arrow.update
    # end
  end

  def show_all_arrow
    @clone_arrows.each_with_index do |arrow,index|
      e = $game_troop.members[index]
      if e.alive?
        arrow.x = e.screen_x-288+8
        arrow.visible = true
        #arrow.opacity = 255
      end
    end
    @arrow.visible = false
    @arrow_state = :all
  end

  def hide_arrow
    @arrow.visible = false
    @arrow_state = :none
    @back.visible = false
    @_opacity.visible = false
  end

  def hide_all_arrow
    @clone_arrows.each do |arrow|
      arrow.visible = false
    end
  end

  def show_one_arrow
    hide_all_arrow
    @arrow.visible = true
    @arrow_state = :one
  end

  def select_all
    $game_troop.members.each { |e| e.selected = true if e.alive?}
  end

  def unselect_all
    $game_troop.members.each { |e| e.selected = false }
  end

  def cancel_select
    init_enemy_face_back
    @flash.visible = false
    @flash_state.visible = false
    self.visible = false
    @arrow_state = :none
    unselect_all
    enemy.selected = false
    hide_all_arrow
    @succ.visible = false
    @_opacity.visible = false
  end

  def update_input
    if Input.trigger?(:A) or Keys.trigger?(Keys::TAB) or Input.trigger?(:L)  or ($game_switches[742] == true and (Input.trigger?(:Z)  or Input.trigger?(:Y) or Input.trigger?(:R)))
      Sound.play_cursor
      if  @show_state == false
        #@_opacity.opacity = 0
        @_opacity.bitmap.clear
        refresh_state
        @show_state = true
      else
        @_opacity.opacity = 255
        refresh(false)
        @show_state = false
      end 
    end

    if Input.repeat?(:DOWN) or Keys.repeat?(Keys::S)
       Sound.play_cursor
      if @arrow_state == :one
        if @index < troop.size-1
          init_enemy_face_back
          ch_index(@index+1) 
        else
          init_enemy_face_back
          ch_index(0)
        end
        refresh
        @arrow.opacity = 255
      end
      if @arrow_state == :all
        show_one_arrow
        unselect_all
        enemy.selected = true
      end
      refresh_succ
    end
    if Input.repeat?(:UP) or Keys.repeat?(Keys::W)
      Sound.play_cursor
      if @arrow_state == :one
        if @index > 0
          init_enemy_face_back
          ch_index(@index-1) 
        else 
          init_enemy_face_back
          ch_index(troop.size-1)
        end
        refresh
        @arrow.opacity = 255
      end
      if @arrow_state == :all
        show_one_arrow
        unselect_all
        enemy.selected = true
      end
      refresh_succ
    end

    if Input.trigger?(:LEFT) || Input.trigger?(:RIGHT) || Keys.trigger?(Keys::A) || Keys.trigger?(Keys::D)
      skill = BattleManager.actor.last_skill.object
      if !skill.blank? && skill.can_all? && $game_troop.alive_members.size > 1
        if @arrow_state == :one
                  Audio.se_play("Audio/SE/Cursor2")
                Sound.play_cursor
          show_all_arrow
          select_all
          refresh_succ
                  @clone_arrows.each do |arrow|
                   arrow.opacity = 255 
                  end
          #@succ.bitmap.clear
        elsif @arrow_state == :all
                          Audio.se_play("Audio/SE/Cursor2")
                Sound.play_cursor
          show_one_arrow
          unselect_all
          enemy.selected = true
          refresh_succ
        end
      else
         Sound.play_buzzer
      end
    end

    if Input.trigger?(:B)
      init_enemy_face_back
      Sound.play_cancel
      @callbacks[:cancel].call
      cancel_select
    end
    if Input.trigger?(:C)
      Sound.play_ok
          @flash.visible = false
          @flash_state.visible = false
    self.visible = false
    enemy.selected = false
    hide_all_arrow
    @succ.visible = false
    @_opacity.visible = false
      init_enemy_face_back
      @callbacks[:ok].call(@arrow_state)
      cancel_select
      
    end
  end
end
