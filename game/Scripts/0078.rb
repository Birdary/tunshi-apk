#encoding:utf-8
#==============================================================================
# ■ Window_BattleStatus
#------------------------------------------------------------------------------
# 　战斗画面中，显示“队伍成员状态”的窗口。
#==============================================================================

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 500+90, 320)
    @states = {}
    @actor_states = {}
    @faces = {}
    $game_party.battle_members.each_with_index do |actor,index|
      @states[actor.id] = {:hp=>actor.hp,:mp=>actor.mp,:ap=>actor.ap}
      face_sp = Sprite.create() do |sp|
        sp.attrset :x=> 850, :y => 577-65-35 + index * 29,:z => 10,:opacity => 0
        sp.bitmap = Cache.bface(actor.id.to_s)
       # sp.bitmap = Bitmap.new("Graphics/Faces/face/ok_face")
      end
      @faces[actor.id.to_s] = face_sp
      @actor_states[actor.id] = actor.states
    end
    refresh
    # @faces.each { |id,sp|  sp.opacity = 0 }
    #@faces.each { |id,sp| sp.update if !sp.nil?}
    #self.openness = 0
    self.opacity = 0
  end

  def set_bitmap(bitmap,type)

  end

  def dispose
    super
    if @faces && @faces.size > 0
      @faces.each_pair do |k,v|
        if v
          v.bitmap.dispose if v.bitmap
          v.dispose
          @faces[k] = nil
        end
      end
      @faces.clear
      @faces = nil
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)+24
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
    $game_party.battle_members.size
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    # draw_all_items
    $game_party.battle_members.each_with_index do |actor,index|
      refresh_actor(actor,index)
      refresh_mask(actor.id,index)
    end
  end

  def flash_face(actor_id)
    @faces[actor_id.to_s].flash(Color.new(255,0,0,255),20) unless @faces[actor_id.to_s].nil?
  end

  def dead_face(actor_id)
    @faces[actor_id.to_s].tone = Tone.new(0,0,0,255) unless @faces[actor_id.to_s].nil?
  end

  def alive_face(actor_id)
    @faces[actor_id.to_s].tone = Tone.new(0,0,0,0)
  end

  def show_all_face
    @faces.each { |id,sp|  sp.opacity = 255 }
  end

  def hide_all_face
    @faces.each { |id,sp|  sp.opacity = 0 }
  end

  def refresh_mask(actor_id,index)
    #@masks[actor_id][:hp].
  end

  def refresh_actor(actor,index)
      $game_variables[98] = 5 if $game_variables[98] == 0 or $game_variables[98] > 5  
            if actor.index < $game_variables[98]
    x = 180+25+94+96
    y = 29 * index + 14
    contents.font.size = 16 + $game_variables[300]
    contents.font.name = "Noto"
    draw_actor_name(actor, x+26-6, y+13+100-35)
    contents.font.name = "Noto"
    refresh_actor_hp(actor,index)
    contents.font.size = 14 + $game_variables[300]
    refresh_actor_states(actor,index)
         end
  end

  def refresh_actor_states(actor,index)
    x = 192-48+96; y = 29 * index + 126 - 35
    contents.clear_rect(x, y, 48, 24) 
    draw_actor_icons(actor, x, y, 192+96)
  end

  def draw_actor_icons(actor, x, y, width = 96)
      icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
      icons.each_with_index {|n, i| draw_icon(n, x - 24 * i, y) }
  end

  def refresh_actor_hp(actor,index)
    x = 110+94+96 ;  y = 29 * index + 25-2+100-35
    contents.font.size = 18 + $game_variables[300]+2
    contents.font.name = "Noto"
    contents.clear_rect(x+32-41, y-3, 80,line_height-4) 
    contents.color = normal_color if actor.hp > 0
    draw_text(x+32-41, y-3, 68, line_height, @states[actor.id][:hp].round.to_s, 1)
  end



  def update
    super
    $game_party.battle_members.each_with_index do |actor,index|
      next if @states[actor.id].nil?
      orihp = @states[actor.id][:hp]
      # orimp = @states[actor.id][:mp]
      # oriap = @states[actor.id][:ap]
      if actor.hp > orihp
        l = actor.mhp / 100.to_f
        @states[actor.id][:hp] += l
        @states[actor.id][:hp] = actor.hp if @states[actor.id][:hp] > actor.hp
        refresh_actor_hp(actor,index)
      end
      if actor.hp < orihp
        l = actor.mhp / 100.to_f
        @states[actor.id][:hp] -= l
        @states[actor.id][:hp] = actor.hp if @states[actor.id][:hp] < actor.hp
        refresh_actor_hp(actor,index)
      end

      # 状态数字窗口 只需要刷新hp 所以屏蔽 mp, tp
      # if actor.mp > orimp
      #   l = actor.mmp / 100.to_f
      #   @states[actor.id][:mp] += l
      #   @states[actor.id][:mp] = actor.mp if @states[actor.id][:mp] > actor.mp
      #   refresh_actor_mp(actor,index)
      # end
      # if actor.mp < orimp
      #   l = actor.mmp / 100.to_f
      #   @states[actor.id][:mp] -= l
      #   @states[actor.id][:mp] = actor.mp if @states[actor.id][:mp] < actor.mp
      #   refresh_actor_mp(actor,index)
      # end
      # if actor.ap > oriap
      #   l = actor.map / 100.to_f
      #   @states[actor.id][:ap] += l
      #   @states[actor.id][:ap] = actor.ap if @states[actor.id][:ap] > actor.ap
      #   refresh_actor_ap(actor,index)
      # end
      # if actor.ap < oriap
      #   l = actor.map / 100.to_f
      #   @states[actor.id][:ap] -= l
      #   @states[actor.id][:ap] = actor.ap if @states[actor.id][:ap] < actor.ap
      #   refresh_actor_ap(actor,index)
      # end
      # 检查状态变化
      if @actor_states[actor.id] != actor.states
        refresh_actor_states(actor,index)
        @actor_states[actor.id] = actor.states
      end
    end
    @faces.each { |id,sp| sp.update if !sp.nil?}
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


