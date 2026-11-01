#encoding:utf-8
#==============================================================================
# ■ Window_BattleStatus
#------------------------------------------------------------------------------
# 　战斗画面中，显示“队伍成员状态”的窗口。
#==============================================================================

class Window_BattleStatusEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    @states = {}
    @show_boss_hp = false
    $game_troop.members.each do |enemy|
      @states[get_key(enemy)] = {:hp=>enemy.hp}
    end
    refresh
    #self.openness = 0
    self.opacity = 0
    @boss = item_max > 5
    #self.activate
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    #Graphics.width
    return 840
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    #fitting_height(visible_line_number)+24
    return 222
  end
  #--------------------------------------------------------------------------
  # ● 获取显示行数
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    $game_troop.members.size
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    # draw_all_items
    $game_troop.members.each_with_index do |enemy,index|
      refresh_enemy(enemy,index)
    end
  end

  def refresh_enemy(enemy,index)
    if enemy.hp == 0
      contents.font.color = Color.new(255,0,0,255) 
    else
      contents.font.color = normal_color
    end
    if index < 5
      x = 0 ; y = 41 + 29 * index
      # draw_ebface(enemy.id.to_s,x,y)
      contents.font.size = 16 + $game_variables[300]
      contents.font.name = "Noto"
      draw_text(x+94, y+10, 128 , 24,enemy.name,1)
      contents.font.size = 18 + $game_variables[300]+2
      if enemy.equip_wtype_ok?(33) 
        draw_text(x+222, y+1, 114, 29, @states[get_key(enemy)][:hp]<=3000 ? @states[get_key(enemy)][:hp].round.to_s : "???" ,1)
      else
        draw_text(x+222, y+1, 114, 29, enemy.hp,1)
      end   
    end
    # boss
    if index == 5
      # draw_ebface(enemy.id.to_s,x,y)
      contents.font.size = 19 + $game_variables[300]
      contents.font.name = "Noto"
      draw_text(94, 16, 128 , 29,enemy.name,1)
      contents.font.size = 22 + $game_variables[300]+1
      draw_text(744-280, 11-1, 114, 29, @states[get_key(enemy)][:hp]<=enemy.mhp*0.5 ? @states[get_key(enemy)][:hp].round.to_s : "???")
    end
    SceneManager.scene.spriteset.enemy_face_dead_alive(enemy) if $game_party.in_battle
  end

  def refresh_enemy_hp(enemy,index)
    # 少血时颜色变化取消
    # if enemy.result.hp_damage != nil 
    #  contents.font.color = Color.new(145,218,91,255)  if @states[get_key(enemy)][:hp] < enemy.hp
      #contents.font.color = Color.new(255,0,0,255)  if @states[get_key(enemy)][:hp] > enemy.hp
      #contents.font.color = normal_color  if @states[get_key(enemy)][:hp] == enemy.hp
    # else
      #contents.font.color = normal_color
    # end
    if enemy.hp == 0
      contents.font.color = Color.new(255,0,0,255) 
    else
      contents.font.color = normal_color
    end
    @states[get_key(enemy)][:hp] == enemy.hp
    if index < 5
      x = 0 ; y = 41 + 29 * index
      contents.font.size = 18 + $game_variables[300]+2
      contents.clear_rect(x+222, y+1, 114, 29) 
      if enemy.equip_wtype_ok?(33)
        draw_text(x+222, y+1, 114, 29, @states[get_key(enemy)][:hp]<=3000 ? @states[get_key(enemy)][:hp].round.to_s : "???" ,1)
      else 
        draw_text(x+222, y+1, 114, 29, @states[get_key(enemy)][:hp].round.to_s, 1)
      end
    end
    if index == 5
      contents.font.size = 18 + $game_variables[300]
      contents.clear_rect(744-280, 11, 114, 29) 
      if @states[get_key(enemy)][:hp] <= enemy.mhp*0.5 && !@show_boss_hp
        @show_boss_hp = true
      end
      contents.font.size = 22 + $game_variables[300]+1
      draw_text(744-280, 11-1, 114, 29,  @show_boss_hp ? @states[get_key(enemy)][:hp].round.to_s : "???")
    end
  end

  def update
    super
    $game_troop.members.each_with_index do |enemy,index|
      orihp = @states[get_key(enemy)][:hp]
      if enemy.hp > orihp
        l = enemy.mhp / 100.to_f
        @states[get_key(enemy)][:hp] += l
        @states[get_key(enemy)][:hp] = enemy.hp if @states[get_key(enemy)][:hp] > enemy.hp
        refresh_enemy_hp(enemy,index)
      end
      if enemy.hp < orihp
        l = enemy.mhp / 100.to_f
        @states[get_key(enemy)][:hp] -= l
        @states[get_key(enemy)][:hp] = enemy.hp if @states[get_key(enemy)][:hp] < enemy.hp
        refresh_enemy_hp(enemy,index)
      end
    end
  end

  def get_key enemy
    enemy.id.to_s + enemy.index.to_s
  end

  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.battle_members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  #--------------------------------------------------------------------------
  # ● 获取基本区域的矩形
  #--------------------------------------------------------------------------
  def basic_area_rect(index)
    rect = item_rect_for_text(index)
    rect.width -= gauge_area_width + 10
    rect
  end
  #--------------------------------------------------------------------------
  # ● 获取值槽区域的矩形
  #--------------------------------------------------------------------------
  def gauge_area_rect(index)
    rect = item_rect_for_text(index)
    rect.x += rect.width - gauge_area_width
    rect.width = gauge_area_width
    rect
  end
  #--------------------------------------------------------------------------
  # ● 获取值槽区域的宽度
  #--------------------------------------------------------------------------
  def gauge_area_width
    return 220
  end
  #--------------------------------------------------------------------------
  # ● 绘制基本区域
  #--------------------------------------------------------------------------
  def draw_basic_area(rect, actor)
    draw_actor_name(actor, rect.x + 0, rect.y, 100)
    draw_actor_icons(actor, rect.x + 104, rect.y, rect.width - 104)
  end
  #--------------------------------------------------------------------------
  # ● 绘制值槽区域
  #--------------------------------------------------------------------------
  def draw_gauge_area(rect, actor)
    if $data_system.opt_display_tp
      draw_gauge_area_with_tp(rect, actor)
    else
      draw_gauge_area_without_tp(rect, actor)
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制值槽区域（包括 TP）
  #--------------------------------------------------------------------------
  def draw_gauge_area_with_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 72)
    draw_actor_mp(actor, rect.x + 82, rect.y, 64)
    draw_actor_tp(actor, rect.x + 156, rect.y, 64)
  end
  #--------------------------------------------------------------------------
  # ● 绘制值槽区域（不包括 TP）
  #--------------------------------------------------------------------------
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 134)
    draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
  end
end
