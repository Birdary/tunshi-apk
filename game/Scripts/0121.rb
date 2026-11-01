#encoding:utf-8
#==============================================================================
# ■ Sprite_Base
#------------------------------------------------------------------------------
# 　添加了显示动画功能的精灵。
#==============================================================================

class Sprite_Ad < Sprite
  include DisableableObject
  def dispose
    super
    _dispose
  end
end

class Sprite_Base < Sprite_Ad
  
  #--------------------------------------------------------------------------
  # ● 类变量
  #--------------------------------------------------------------------------
  @@ani_checker = []
  @@ani_spr_checker = []
  @@_reference_count = {}

  attr_accessor :ani_duplicated
  attr_accessor :timing_se_played_list
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @use_sprite = true        # 使用精灵的标志
    @ani_duration = 0         # 残余的显示时间

    @_damage_duration = 0
    @damage_sprite = []
    @total_damage = 0
    @damage_hit = 0
    @slow = 0
    @slow_p = 0
    @can_slow = false

    @play_fullscreen_animation_unique_id = nil

    # @all_flash_duration = 0   # 动画闪烁时刻的总时间

    # 是否重复动画
    @ani_duplicated = false

    # se 播放过的列表
    @timing_se_played_list = []
  end

  def all_flash_duration
    return if @animation.nil?
    t = 0
    @animation.timings.each{ |n|
      if n.is_damage? || n.is_cure?
        t += n.flash_duration
      end
    }
    return t
  end

  #--------------------------------------------------------------------------
  # ● 释放引用bitmap
  #--------------------------------------------------------------------------
  def self.dispose_reference_bitmaps
    if @@_reference_count
      @@_reference_count.each_pair do |k,v|
        @@_reference_count[k] = nil
        @@_reference_count.delete(k)
      end
      @@_reference_count.clear
      @@_reference_count = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_animation
    _dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_animation
    @@ani_checker.clear
    @@ani_spr_checker.clear
    @damage_sprite.each{|sp|sp.update unless sp.disposed?}
    # update_damage_ani
  end


  def update_damage_ani
   if @_damage_duration > 0
      @_damage_duration -= 1
      case @_damage_duration
      when 38..39
        @_damage_sprite.y -= 4
      when 36..37
        @_damage_sprite.y -= 2
      when 34..35
        @_damage_sprite.y += 2
      when 28..33
        @_damage_sprite.y += 4
      end
      @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
      if @_damage_duration == 0
        dispose_damage
      end
    end
  end

  def damage(value, critical,total = false)
    #dispose_damage                             # 释放伤害
    if value.is_a?(Numeric)                    # 如果伤害值是数值
      damage_string = value.abs.to_s           # 绝对值转为字符串
    else
      damage_string = value.to_s               # 转为字符串
    end
    if total
      bitmap = Bitmap.new(162, 64)               # 初始化位图
    else
      bitmap = Bitmap.new(240, 80)
    end


    bitmap.font.name = "Arial Black"
    bitmap.font.size = total ? 30 : 23
    if value.is_a?(Numeric)
      unless total
        damage_array = damage_string.scan(/./)   # 分割伤害值字符串
        damage_x = 80 - damage_string.size * 9
        damage_x += 5 if damage_string.size > 4
        if value < 0                             # 伤害值为负的情况下
          rect_y = 32                            # 调用回复数字表
          bitmap.blt(36, 28+5, CacheBattleBitmap.get("Damage1","picture"), Rect.new(0, 96, 90, 44))
          # bitmap.blt(36, 28+5, Cache.picture("Damage1"), Rect.new(0, 96, 90, 44))
        elsif value == 1  
          rect_y = 0  
          bitmap.blt(36, 28+5, CacheBattleBitmap.get("Damage1x","picture"), Rect.new(0, 96, 90, 44))
          # bitmap.blt(36, 28+5, Cache.picture("Damage1x"), Rect.new(0, 96, 90, 44))
        else
          rect_y = 0                             # 调用伤害数字表
          bitmap.blt(36, 28+5, CacheBattleBitmap.get("Damage1","picture"), Rect.new(90, 96, 90, 44))
          # bitmap.blt(36, 28+5, Cache.picture("Damage1"), Rect.new(90, 96, 90, 44))
        end
        for char in damage_array                 # 循环伤害值字符串
          number = char.to_i
          if value == 1  
          bitmap.blt(damage_x, 32, CacheBattleBitmap.get("Damage1x","picture"), Rect.new(number * 18, rect_y, 18, 32))
          # bitmap.blt(damage_x, 32, Cache.picture("Damage1x"), Rect.new(number * 18, rect_y, 18, 32))
          else
          bitmap.blt(damage_x, 32, CacheBattleBitmap.get("Damage1","picture"), Rect.new(number * 18, rect_y, 18, 32))
          # bitmap.blt(damage_x, 32, Cache.picture("Damage1"), Rect.new(number * 18, rect_y, 18, 32))
          end
          damage_x += 18                         # 后移一位
        end
      end
      if total
        bitmap.draw_text(0,0,240,30,"TOTAL #{value}")
        bitmap.draw_text(0,30,240,30,"#{@damage_hit} HIT")
      end
    else
      if value == "Evaded"  
        bitmap.blt(36, 28, CacheBattleBitmap.get("Damage1","picture"), Rect.new(90, 64, 90, 32))
        # bitmap.blt(36, 28, Cache.picture("Damage1"), Rect.new(90, 64, 90, 32))
      else
        bitmap.blt(36, 28, CacheBattleBitmap.get("Damage1","picture"), Rect.new(0, 96, 84, 32))
        # bitmap.blt(36, 28, Cache.picture("Damage1"), Rect.new(0, 96, 84, 32))
        # 显示未击中图画
      end
    end
    if critical                                # 会心一击标志打开的情况
      # 显示会心一击图画
      bitmap.blt(36, 0, CacheBattleBitmap.get("Damage1","picture"), Rect.new(0, 64, 90, 32))
      # bitmap.blt(36, 0, Cache.picture("Damage1"), Rect.new(0, 64, 90, 32))
      Sound.play_critical
    end
    # 伤害值定位
    damage_sprite = Sprite_Damage.new(self.viewport) 
    damage_sprite.bitmap = bitmap
    damage_sprite.x = (self.x-288)
    damage_sprite.y = self.y - self.oy+12
    damage_sprite.z = 3000 + @damage_sprite.size
    damage_sprite.total = true if total
    #@damage_hit += 1 if !total && damage
    @damage_sprite << damage_sprite
  end

  def dispose_damage
    if @_damage_sprite
      @_damage_sprite.dispose
      @_damage_sprite.bitmap.dispose
      @_damage_sprite = nil
      @_damage_duration = 0
    end
    @damage_sprite.each{|sp|
      sp.dispose if sp
      sp.bitmap.dispose if sp.bitmap
      sp = nil
    }
    @damage_sprite.clear
    @damage_sprite = nil
    GC.start
    @damage_sprite = []
    @damage_hit = 0
  end

  def animation
    @animation
  end

  #--------------------------------------------------------------------------
  # ● 判定是否显示动画中
  #--------------------------------------------------------------------------
  def animation?
    @animation != nil
  end
  #--------------------------------------------------------------------------
  # ● 开始动画
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false, animation1_name=nil, animation2_name=nil)
    dispose_animation
    dispose_damage
    @slow = 0
    @slow_p = 0
    @can_slow = false
    @animation = animation

    if @animation
       @ani_mirror = mirror
       set_animation_rate
       @ani_duration = @animation.frame_max * @ani_rate + 1
       load_animation_bitmap(animation1_name,animation2_name)
       make_animation_sprites
       set_animation_origin
    end

    if $game_party.in_battle && @animation.position == 3
       @play_fullscreen_animation_unique_id = rand(1000000)
       SceneManager.scene.play_fullscreen_animation_unique_id = @play_fullscreen_animation_unique_id
    end

  end
  #--------------------------------------------------------------------------
  # ● 设置动画的速度
  #--------------------------------------------------------------------------
  def set_animation_rate
      @ani_rate = 2  # 固定的默认值
  end
  #--------------------------------------------------------------------------
  # ● 读取动画图像
  #--------------------------------------------------------------------------
  def load_animation_bitmap(change_animation1_name=nil,change_animation2_name=nil)
    animation1_name = change_animation1_name.nil? ? @animation.animation1_name : change_animation1_name
    animation1_hue = @animation.animation1_hue
    animation2_name = change_animation2_name.nil? ? @animation.animation2_name : change_animation2_name
    animation2_hue = @animation.animation2_hue
    


    @ani_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @ani_bitmap2 = Cache.animation(animation2_name, animation2_hue)

    # if $game_party.in_battle
    #   @ani_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    #   @ani_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    # else
    #   @ani_bitmap1 = Bitmap.new("Graphics/Animations/" + animation1_name)
    #   @ani_bitmap1.hue_change(animation1_hue)

    #   @ani_bitmap2 = Bitmap.new("Graphics/Animations/" + animation2_name)
    #   @ani_bitmap2.hue_change(animation2_hue)
    # end

    if $marv_name_id != nil and $marv_name_id >= 0
       s = $marv_name_id-1
       @ani_bitmap2.clear_rect(0, 960, 192, 192)
       @ani_bitmap2.blt(0+25,960+33,CacheBattleBitmap.get("marv_name","system"), Rect.new(0,33*s,108,33) )
       # @ani_bitmap2.blt(0+25,960+33,Cache.system("marv_name"), Rect.new(0,33*s,108,33) )
       $marv_name_id = -1
    end
    @@_reference_count ||= {}
    if @@_reference_count.include?(@ani_bitmap1)
       @@_reference_count[@ani_bitmap1] += 1
    else
       @@_reference_count[@ani_bitmap1] = 1
    end
    if @@_reference_count.include?(@ani_bitmap2)
       @@_reference_count[@ani_bitmap2] += 1
    else
       @@_reference_count[@ani_bitmap2] = 1
    end
    Graphics.frame_reset
  end

  #--------------------------------------------------------------------------
  # ● 生成动画精灵
  #--------------------------------------------------------------------------
  def make_animation_sprites
    @ani_sprites = []
    if @use_sprite && !@@ani_spr_checker.include?(@animation)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @ani_sprites.push(sprite)
      end
      if @animation.position == 3
        @@ani_spr_checker.push(@animation)
      end
    end
    @ani_duplicated = @@ani_checker.include?(@animation)
    if !@ani_duplicated && @animation.position == 3
      @@ani_checker.push(@animation)
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置动画的原点
  #--------------------------------------------------------------------------
  def set_animation_origin
    if @animation.position == 3
      if viewport == nil
        if self.battler.actor?
          @ani_ox = Graphics.width / 2 + 256
        else
          @ani_ox = Graphics.width / 2 - 256
        end
        @ani_oy = Graphics.height / 2 + 70
      else
        if self.battler.actor?
          @ani_ox = viewport.rect.width / 2 + 256
        else
          @ani_ox = Graphics.width / 2 - 256
        end
        @ani_oy = viewport.rect.height / 2 + 70
      end
    else
      @ani_ox = x - ox + width / 2
      @ani_oy = y - oy + height / 2
      if @animation.position == 0
        @ani_oy -= height / 2
      elsif @animation.position == 2
        @ani_oy += height / 2
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放动画
  #--------------------------------------------------------------------------
  def dispose_animation
    if @ani_bitmap1
      @@_reference_count[@ani_bitmap1] -= 1
      if @@_reference_count[@ani_bitmap1] == 0
        @ani_bitmap1.dispose
      end
    end
    if @ani_bitmap2
      @@_reference_count[@ani_bitmap2] -= 1
      if @@_reference_count[@ani_bitmap2] == 0
        @ani_bitmap2.dispose
      end
    end
    if @ani_sprites
      @ani_sprites.each_with_index {|sprite,index|
        @ani_sprites[index].dispose
        @ani_sprites[index].bitmap.dispose if @ani_sprites[index].bitmap
        @ani_sprites[index] = nil
        # sprite.bitmap.dispose if sprite.bitmap
        # sprite.dispose
      }
      @ani_sprites.clear
      @ani_sprites = nil
      @animation = nil
    end
    # if @@ani_spr_checker.size > 0
    #   @@ani_checker.clear
    # end
    # if @@ani_checker.size > 0
    #   @@ani_checker.clear
    # end

    @ani_bitmap1.dispose if @ani_bitmap1 && !@ani_bitmap1.disposed?
    @ani_bitmap2.dispose if @ani_bitmap2 && !@ani_bitmap2.disposed?

    @ani_bitmap1 = nil
    @ani_bitmap2 = nil

    # if @total_damage > 0 && @damage_hit > 1
    #   damage(@total_damage,false,true)
    # end
    @total_damage = 0
    @slow = 0
    @slow_p = 0
    @can_slow = false

    # GC.start
  end
  #--------------------------------------------------------------------------
  # ● 慢动作击杀
  #--------------------------------------------------------------------------
  def battle_slow_animation
      if $game_party.in_battle
      while @slow > 0
        @slow -= 1 
        #_update
        Graphics.update
        BattleFiber.update_wave 
      end  
      #慢动作降低3倍，播放15帧
      sl = 3
      if @can_slow == true and @ani_duration > @slow_p - 15
         @slow_p = @ani_duration if @slow_p == 0
         @slow = sl
      end   
      end
  end  
  #--------------------------------------------------------------------------
  # ● 更新动画
  #--------------------------------------------------------------------------
  def update_animation
    return unless animation?
    battle_slow_animation
    @ani_duration -= 1

    if @ani_duration % @ani_rate == 0
      if @ani_duration > 0

        frame_index = @animation.frame_max
        frame_index -= (@ani_duration + @ani_rate - 1) / @ani_rate 
        
        # 判断 全体并且动画位置为画面的动画 则播放一次
        if !$game_party.in_battle || 
          ($game_party.in_battle && SceneManager.scene.play_fullscreen_animation_unique_id == nil) ||
          ($game_party.in_battle && SceneManager.scene.play_fullscreen_animation_unique_id == @play_fullscreen_animation_unique_id)
          animation_set_sprites(@animation.frames[frame_index])
        end
        @animation.timings.each do |timing|
          animation_process_timing(timing) if timing.frame == frame_index 
        end
      else
        end_animation
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 结束动画
  #--------------------------------------------------------------------------
  def end_animation
    if $game_party.in_battle
      if SceneManager.scene.play_fullscreen_animation_unique_id == @play_fullscreen_animation_unique_id
         SceneManager.scene.play_fullscreen_animation_unique_id = nil
      end
    end
    @timing_se_played_list.clear
    dispose_animation
  end
  #--------------------------------------------------------------------------
  # ● 设置动画的精灵
  #     frame : 帧数据（RPG::Animation::Frame）
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror
        sprite.x = @ani_ox - cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @ani_ox + cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # ● 声效(SE)和闪烁时机的处理
  #     timing : 时机（RPG::Animation::Timing）
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    all_duration = all_flash_duration 
    if all_duration > 0
      _damage = (self.battler.result.hp_damage * timing.flash_duration / all_duration.to_f).round
      if timing.is_damage?
        self.battler.hp -= _damage
        if battler.hp <= 0 and @animation.name.include?("hit")
           @slow = 3
           @can_slow = true
        end
        #角色伤害单场统计 
        if $game_party.in_battle and $game_switches[693] == true
          user = BattleManager.now_subject 
          user.over_damage += (_damage).to_i if user != nil && _damage > 1 && user.unit != self.battler.unit 
        end
        self.battler.execute_boost(_damage)
        SceneManager.scene.flash_face(self.battler)
        @total_damage += _damage
        @damage_hit += 1 if _damage != 0
        if _damage != 0
          damage(_damage,self.battler.result.critical)
        else
          if self.battler.result.missed
            damage("Evaded",false)
          end
        end
      end
      if timing.is_cure?
        self.battler.hp += _damage.abs
        _damage != 0 ? damage(-_damage,false) : damage("Evaded",false)
      end
    end

    if $game_party.in_battle
      played = false
      self.battler.unit.battle_members.each do |_battler|
        _sprite_battler = _battler.sprite_battler
        if _sprite_battler.timing_se_played_list.include?(timing.se)
          played = true
          break
        end
      end
      unless played
        # timing.se.play unless @ani_duplicated
        timing.se.play
        @timing_se_played_list << timing.se
      end
    else
      timing.se.play unless @ani_duplicated
    end


    # unless @ani_duplicated
    #   # 全体同步动画 只播放一次生效 判断battler的unit其他成员是否在播放同一个动画
    #   exist_animation = false
    #   self.battler.unit.battle_members.each do |_battler|
    #     next if self.battler.eql?(_battler)
    #     _sprite_battler = _battler.sprite_battler
    #     if _sprite_battler.animation.eql?(@animation)
    #       exist_animation = true
    #       break
    #     end
    #   end
    #   timing.se.play unless exist_animation
    # end


    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * @ani_rate)
    when 2
      if viewport && !@ani_duplicated
         viewport.flash(timing.flash_color, timing.flash_duration * @ani_rate)
      end
    when 3
      self.flash(nil, timing.flash_duration * @ani_rate)
    end
  end
end



class Sprite_Base_Ad < Sprite_Base
  include DisableableObject
  def dispose
    super
    _dispose
  end
end
