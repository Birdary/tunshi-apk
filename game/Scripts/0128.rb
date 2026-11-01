#encoding:utf-8
#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　显示战斗者的精灵。根据 Game_Battler 类的实例自动变化。
#==============================================================================

class Sprite_Battler < Sprite_Base_Ad
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :battler
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
    @effect_type = nil
    @effect_duration = 0
    @pattern = rand(4)
    @select_count = 0
    @select_state = :up
    @yuan_open = 0
    @bitmap2 = Sprite.new
    @bitmap2.visible = false
    if @battler.actor?
       @bitmap2.bitmap = Cache.picture("bbb")
    else
       @bitmap2.bitmap = Cache.picture("bbb2") 
       @bitmap2.bitmap = Cache.picture("bbb3") if @battler.index == 5
    end
    @bitmap2.z = 9
  end

  def bitmap_width
    self.bitmap.width/4
  end
  def bitmap_height
    self.bitmap.height
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap
       self.bitmap.dispose
       self.bitmap = nil
    end
    if @bitmap2
       @bitmap2.bitmap.dispose
       @bitmap2.dispose
       @bitmap2 = nil
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    return unless $game_party.in_battle
    super

    self.opacity = 255
    if @battler
      @use_sprite = @battler.use_sprite?
      if @use_sprite
         update_bitmap
         update_origin
         update_position
      end
      setup_new_effect
      setup_new_animation
      update_effect
      update_select
      if @battler.damage_pop
        if @battler.result.hp_damage != 0 and  @battler.result.hp_damage != nil
          damage(@battler.result.hp_damage, @battler.critical)
        end
        if @battler.result.mp_damage != 0 and  @battler.result.mp_damage != nil
          damage(@battler.result.mp_damage, @battler.critical)
        end
        if @battler.result.missed
          damage("Miss", @battler.critical)
        end
        if @battler.result.evaded
          damage("Evaded", @battler.critical)
        end
        @battler.damage_pop = false
      end
    else
      self.bitmap = nil
      @effect_type = nil
    end
  end

  #--------------------------------------------------------------------------
  # ● 更新源位图（Source Bitmap）
  #--------------------------------------------------------------------------
  def update_bitmap
    if (Graphics.frame_count % 10).zero?
      @pattern >= 3 ? @pattern = 0 : @pattern += 1
    end
    new_bitmap = nil
    case @battler.bitmap_state
    when :normal
      if @battler.index == 5
        new_bitmap = Cache.battler(@battler.battler_name+"-q", @battler.battler_hue)
      else
        new_bitmap = Cache.battler(@battler.battler_name, @battler.battler_hue)
      end
      bitmap2_update
    when :hid
        new_bitmap = Cache.battler("jj", @battler.battler_hue)
    when :jing
        new_bitmap = Cache.battler(@battler.battler_name+"j", @battler.battler_hue)
        bitmap2_update
    when :start
      @bitmap2.visible = false
      new_bitmap = Cache.battler("jj", @battler.battler_hue)
    when :dead
      if @battler.index == 5
        new_bitmap = Cache.battler("★★",0) 
      else
        if @battler.equip_wtype_ok?(33)
          new_bitmap = Cache.battler("jj", 0)
        else
          new_bitmap = Cache.battler("★", 0)
        end   
      end
      bitmap2_update
      #self.tone.set(0,0,0,0)
    when :alive
      if @battler.index == 5
        new_bitmap = Cache.battler(@battler.battler_name+"-q", @battler.battler_hue)
      else
        new_bitmap = Cache.battler(@battler.battler_name, @battler.battler_hue)
      end
      @battler.change_btm_st :normal  
      # self.tone.set(0,0,0,0) 
      #总攻中有人死亡，按下取消，把人拉回来。
      #if @battler.actor?
      # @battler.change_x = 24*@battler.formation_pos_incr
      # else
      # @battler.change_x = (24*@battler.formation_pos_incr).abs
      # end
    end

    if bitmap != new_bitmap
      if self.bitmap
        self.bitmap.dispose
        self.bitmap = nil
      end

      self.bitmap = new_bitmap
      #init_visibility
    end
    self.src_rect.set(@pattern*bitmap_width,0,bitmap_width,bitmap_height)
    @bitmap2.src_rect.set(@pattern*56,0,56,32)
    if new_bitmap
      new_bitmap.dispose
      new_bitmap = nil
    end
  end

  #--------------------------------------------------------------------------
  # ● 初始化可视状态
  #--------------------------------------------------------------------------
  def init_visibility
    #@battler_visible = @battler.alive?
    #self.opacity = 0 unless @battler_visible
  end
  #--------------------------------------------------------------------------
  # ● 更新原点
  #--------------------------------------------------------------------------
  def update_origin
    if bitmap
      self.ox = bitmap.width / 2
      self.oy = bitmap.height
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    if @battler.animation_during > 0
      @battler.animation_during -= 1
      case @battler.animation_tag
      when :forward
        @battler.change_btm_st :normal if @battler.unit.formation.id == 12
        @battler.change_x += (@battler.is_a?(Game_Actor) ? -3 : 3)
        #战斗中上前一步，角色下方出现圆环，
        if @yuan_open == 1 and @battler.actor?
           @bitmap2.bitmap = Cache.picture("bbb0")
           @bitmap2.src_rect.set(0,0,56,32)
        if $game_switches[S::CV] == true and @au == 1
           if $game_switches[632] == false 
              Audio.se_play("Audio/SE/Actor_first/#{@battler.id}"+"-"+"#{1+rand(2)}",100)   
           else
              Audio.se_play("Music/CV/#{@battler.id}"+"-"+"#{1+rand(2)}",100)   
           end    
           @au = 0
        end     
       # @battler.change_btm_st :normal
        end
      when :back
        @battler.change_x += (@battler.is_a?(Game_Actor) ? 3 : -3)
        @battler.change_btm_st :jing if @battler.state?(16)
           if @battler.actor?
           @bitmap2.bitmap = Cache.picture("bbb")
           @bitmap2.src_rect.set(0,0,56,32)
           @yuan_open = 0
           end
      when :formation
        @battler.change_x += 2*@battler.formation_pos_incr  # if @battler.hp > 0
        # @battler.change_x += (@battler.is_a?(Game_Actor) ? (-2*@battler.formation_pos) : (2*@battler.formation_pos))
      when :all_atk
        change_x = case @battler.formation_pos
                   when 0 ; 9
                   when 1 ; 8
                   when 2 ; 7
                   when 3 ; 6
                   when 4 ; 5
                   when 5 ; 4
                   when 6 ; 3
                   when 7 ; 2
                   when 8 ; 1
                   when 9 ; 0
        end
        @battler.actor? ? @battler.change_x -= change_x : @battler.change_x += change_x
      when :cancel_all_atk
        change_x = case @battler.formation_pos
                   when 0 ; 9
                   when 1 ; 8
                   when 2 ; 7
                   when 3 ; 6
                   when 4 ; 5
                   when 5 ; 4
                   when 6 ; 3
                   when 7 ; 2
                   when 8 ; 1
                   when 9 ; 0
        end
        @battler.actor? ? @battler.change_x += change_x : @battler.change_x -= change_x
      when :face_back
        self.mirror = true
      when :face_forward
        self.mirror = false
      end
    end
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
    if @battler.actor?
       @bitmap2.x = self.x-384+69
       @bitmap2.y = self.y-193+96
    else
       @bitmap2.x = self.x-386+69
       @bitmap2.y = self.y-193+96
    end  
  end
  #--------------------------------------------------------------------------
  # ● 更新脚下圆圈
  #--------------------------------------------------------------------------
  def bitmap2_update
    if @battler.actor?
       if @yuan_open == 1
          @bitmap2.bitmap = Cache.picture("bbb0")
       else
          @bitmap2.bitmap = Cache.picture("bbb")
       end
       @bitmap2.visible = true
    else
       @bitmap2.bitmap = Cache.picture("bbb2") 
       @bitmap2.bitmap = Cache.picture("bbb3") if @battler.index == 5 or @battler.id == 11 
       @bitmap2.visible = true
    end
       @bitmap2.visible = false if @battler.dead?    
       @bitmap2.src_rect.set(0,0,56,32)
  end

  def yuan_quan
      @bitmap2.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 设置新的效果
  #--------------------------------------------------------------------------
  def setup_new_effect
    if !@battler_visible && @battler.alive?
      start_effect(:appear)
    elsif @battler_visible && @battler.hidden?
      start_effect(:disappear)
    end
    if @battler_visible && @battler.sprite_effect_type
      start_effect(@battler.sprite_effect_type)
      @battler.sprite_effect_type = nil   
    end
    if BattleManager.actor === @battler && @effect_duration == 0
      @yuan_open = 1
      @au = 1
      start_effect(:whiten)
    end
  end
  #--------------------------------------------------------------------------
  # ● 效果开始
  #--------------------------------------------------------------------------
  def start_effect(effect_type)
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 16
      @battler_visible = true
    when :disappear
      @effect_duration = 32
      @battler_visible = false
    when :whiten
      @effect_duration = 24
      @battler_visible = true
    when :blink
      @effect_duration = 20
      @battler_visible = true
    when :collapse
      @effect_duration = 48
      @battler_visible = false
    when :boss_collapse
      @effect_duration = bitmap.height
      @battler_visible = false
    when :instant_collapse
      @effect_duration = 16
      @battler_visible = false
    end
    revert_to_normal
  end
  #--------------------------------------------------------------------------
  # ● 返回普通设置
  #--------------------------------------------------------------------------
  def revert_to_normal
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
    self.ox = bitmap.width / 2 if bitmap
    self.src_rect.y = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置新的动画
  #--------------------------------------------------------------------------
  def setup_new_animation
    if @battler.animation_id > 0
      animation = $data_animations[@battler.animation_id]
      mirror = @battler.animation_mirror
      start_animation(animation, mirror,@battler.animation1_name, @battler.animation2_name)
      @battler.clear_anmation_name
      @battler.animation_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定效果是否执行中
  #--------------------------------------------------------------------------
  def effect?
    @effect_type != nil
  end

  def update_select
    if @battler.selected
      @select_count += 0.5 if @select_state == :up
      @select_count -= 0.5 if @select_state == :down
      @select_state = :down if @select_count >= 10
      @select_state = :up if @select_count <= 0
      selected_flash
    else
      init_select unless effect?
    end
  end

  def selected_flash
      @battler.actor?? self.color.set(25, 255, 255, 255) : self.color.set(255, 0, 0, 255)
      self.color.alpha = @select_count * 22
      @battler.actor?? @bitmap2.color.set(255, 246, 0, 255) : @bitmap2.color.set(164, 56, 255, 255)
      @bitmap2.color.alpha = @select_count * 22
  end

  def init_select
      @battler.actor?? self.color.set(0, 0, 0, 0) : self.color.set(0, 0, 0, 0)
      @bitmap2.color.set(0, 0, 0, 0) 
  end

  #--------------------------------------------------------------------------
  # ● 更新效果
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when :whiten
        update_whiten
      when :blink
        update_blink
      when :appear
        update_appear
      when :disappear
        update_disappear
      when :collapse
        update_collapse
      when :boss_collapse
        update_boss_collapse
      when :instant_collapse
        update_instant_collapse
      end
      @effect_type = nil if @effect_duration == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新白闪烁效果
  #--------------------------------------------------------------------------
  def update_whiten
    self.color.set(255, 255, 255, 0)
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # ● 更新明灭效果
  #--------------------------------------------------------------------------
  def update_blink
    self.opacity = (@effect_duration % 10 < 5) ? 255 : 0
  end
  #--------------------------------------------------------------------------
  # ● 更新出现效果
  #--------------------------------------------------------------------------
  def update_appear
    self.opacity = (16 - @effect_duration) * 16
  end
  #--------------------------------------------------------------------------
  # ● 更新消灭效果
  #--------------------------------------------------------------------------
  def update_disappear
    self.opacity = 256 - (32 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # ● 更新击溃效果
  #--------------------------------------------------------------------------
  def update_collapse
    self.blend_type = 1
    self.color.set(255, 128, 128, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end
  #--------------------------------------------------------------------------
  # ● 更新击溃首领效果
  #--------------------------------------------------------------------------
  def update_boss_collapse
    alpha = @effect_duration * 120 / bitmap.height
    self.ox = bitmap.width / 2 + @effect_duration % 2 * 4 - 2
    self.blend_type = 1
    self.color.set(255, 255, 255, 255 - alpha)
    self.opacity = alpha
    self.src_rect.y -= 1
    Sound.play_boss_collapse2 if @effect_duration % 20 == 19
  end
  #--------------------------------------------------------------------------
  # ● 更新瞬间消失效果
  #--------------------------------------------------------------------------
  def update_instant_collapse
    # self.opacity = 0
  end
end



