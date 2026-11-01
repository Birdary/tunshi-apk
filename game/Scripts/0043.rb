#encoding:utf-8
#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　处理战斗者的类。Game_Actor 和 Game_Enemy 类的父类。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 常量（使用效果）
  #--------------------------------------------------------------------------
  EFFECT_RECOVER_HP     = 11              # 恢复 HP
  EFFECT_RECOVER_MP     = 12              # 恢复 MP
  EFFECT_GAIN_TP        = 13              # 增加 TP
  EFFECT_ADD_STATE      = 21              # 附加状态
  EFFECT_REMOVE_STATE   = 22              # 解除状态
  EFFECT_ADD_BUFF       = 31              # 强化能力
  EFFECT_ADD_DEBUFF     = 32              # 弱化能力
  EFFECT_REMOVE_BUFF    = 33              # 解除能力强化
  EFFECT_REMOVE_DEBUFF  = 34              # 解除能力弱化
  EFFECT_SPECIAL        = 41              # 特殊效果
  EFFECT_GROW           = 42              # 能力提升
  EFFECT_LEARN_SKILL    = 43              # 学会技能
  EFFECT_COMMON_EVENT   = 44              # 公共事件
  #--------------------------------------------------------------------------
  # ● 常量（特殊效果）
  #--------------------------------------------------------------------------
  SPECIAL_EFFECT_ESCAPE = 0               # 撤退
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :battler_name             # 战斗图像文件名
  attr_reader   :battler_hue              # 战斗图像色相
  attr_reader   :action_times             # 行动回数
  attr_reader   :actions                  # 战斗行动（行动方）
  attr_reader   :speed                    # 行动速度
  attr_accessor :result                   # 行动结果（目标方）
  attr_accessor :last_target_index        # 最后目标的索引
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :animation_mirror         # 动画左右反转的标志
  attr_accessor :sprite_effect_type       # 精灵的效果
  attr_accessor :animation_during         # 动画时间
  attr_accessor :change_x                 # 变化的screen_x
  attr_accessor :formation_pos            # 阵型的位置
  attr_accessor :formation_pos_incr       # 阵型位置的移动量(+ , -)
  attr_accessor :animation_tag            # 动画标记
  attr_accessor :animation1_name          # 动画1文件名
  attr_accessor :animation2_name          # 动画2文件名

  attr_accessor   :hp_damage
  attr_accessor   :mp_damage
  attr_accessor   :damage_pop
  attr_accessor   :critical 

  attr_accessor :selected  # 是否被选中

  attr_accessor :cmd_active # 命令中

  attr_accessor :sprite_battler # 关联战斗的动画精灵

  attr_reader   :bitmap_state          # 位图 普通 死亡 复活

  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @actions = []
    @speed = 0
    @result = Game_ActionResult.new(self)
    @last_target_index = 0
    @guarding = false
    @animation_during = 0
    @animation_tag = nil
    @change_x = 0
    @formation_pos = 0
    @formation_pos_incr = 0
    @animation1_name = nil
    @animation2_name = nil
    
    @cmd_active = false

    @hp_damage = 0
    @mp_damage = 0
    @damage_pop = false
    @critical = false

    @bitmap_state = :start

    @selected = false

    @sprite_battler = nil
   
    clear_sprite_effects
    super
  end

  def remove_sprite_battler
    @sprite_battler = nil
  end

  def def
    _unit = unit
    # 嘲骂计 - 敌防御力下降15%
    if _unit.states.include?(:chm)
     # return super * 0.85
    end
    # 静寂阵 - 全体防御力提升50%
    if _unit.states.include?(:jj)
      #return super * 1.5
    end
    super
  end

  def unit
    self.actor? ? $game_party : $game_troop
  end

  def opponent_unit
    self.actor? ? $game_troop : $game_party
  end

  def initialize_animation(sprite_battler)
    @sprite_battler = sprite_battler
  end 

  def change_btm_st(state)
    @bitmap_state = state
  end

  def animation(tag,option={})
    @animation_tag = tag
    case tag
    when :forward
      @animation_during = (@animation_during == 0 ? 12 : 12 - @animation_during)
    when :back
      @animation_during = (@animation_during == 0 ? 12 : 12 - @animation_during)
    when :formation
      pos = option[:pos] - @formation_pos
      return if pos == 0
      @formation_pos_incr = self.actor? ? -pos : pos
      @formation_pos = option[:pos]
      if BattleManager.all_atk == :over
         @animation_during = (@animation_during == 0 ? 12 : 12 - @animation_during)
      end
    when :all_atk
      @animation_during = 24
    when :cancel_all_atk
      @animation_during = 24
    when :face_back
      @animation_during = 1
    when :face_forward
      @animation_during = 1
    end
  end

  def set_animation(type,attacker=nil)
    if [:atk,:guard,:use_item,:use_skill,:use_marv,:use_formation,:formation_object,:dead,:alive].include?(type)
     if self.is_a?(Game_Actor) 
        @animation1_name = self.actor.id.to_s 
     else    
       if self != nil and self.element_rate(45) != 1
          @animation1_name = "DM#{(self.element_rate(45)*100).round}" 
          @animation1_name = @animation1_name + "-q" if self.index == 5 #用骑乘判断，死亡动画会显示错误
       else
          @animation1_name = "DM#{self.id}"
          @animation1_name = @animation1_name + "-q" if self.index == 5
       end
    end 
      if type == :use_marv
         $marv_name_id = self.current_action.item.note.split("\r\n")[1][0,3].to_i
         @animation2_name = "C_name"  #{}"C_#{self.current_action.item.id}"
      end
      if type == :dead  
         @animation2_name = "dead_m" if self.equip_wtype_ok?(33)
      end
    end

    if type == :hit || type == :miss
      if self.is_a?(Game_Actor) 
        if attacker != nil and attacker.element_rate(45) != 1
          @animation1_name =  "DM#{(attacker.element_rate(45)*100).round}" 
          @animation1_name = @animation1_name + "-q" if attacker.equip_wtype_ok?(31)  
        else
          @animation1_name =  "DM#{attacker.id}" 
          @animation1_name = @animation1_name + "-q" if attacker.equip_wtype_ok?(31)  
        end
      else
          @animation1_name =  attacker.id.to_s
      end

      if self.is_a?(Game_Actor)
        @animation2_name = self.id.to_s 
      else
        if self != nil and self.element_rate(45) != 1
          @animation2_name =  "DM#{(self.element_rate(45)*100).round}" 
          @animation2_name = @animation2_name + "-q" if self.equip_wtype_ok?(31)  
        else
          @animation2_name =  "DM#{self.id}"
          @animation2_name = @animation2_name + "-q" if self.equip_wtype_ok?(31)  
        end
      end
    end
    if type == :marv_miss
      if self.is_a?(Game_Actor) 
        @animation1_name = self.id.to_s
      else
        if self != nil and self.element_rate(45) != 1
          @animation1_name = "DM#{(self.element_rate(45)*100).round}" 
          @animation1_name = @animation1_name + "-q" if self.equip_wtype_ok?(31)  
        else
          @animation1_name = "DM#{self.id}"
          @animation1_name = @animation1_name + "-q" if self.equip_wtype_ok?(31)  
        end   
      end
    end
  end

  def clear_anmation_name
    @animation1_name = nil
    @animation2_name = nil
  end

  #--------------------------------------------------------------------------
  # ● 清除精灵的效果
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @sprite_effect_type = nil
  end
  #--------------------------------------------------------------------------
  # ● 清除战斗行动
  #--------------------------------------------------------------------------
  def clear_actions
    @actions.clear
  end
  #--------------------------------------------------------------------------
  # ● 清除状态信息
  #--------------------------------------------------------------------------
   def clear_states_d
    super
    @result.clear_status_effects
  end


  def clear_states
    super
    @result.clear_status_effects
  end
  #--------------------------------------------------------------------------
  # ● 附加状态
  #--------------------------------------------------------------------------
  def add_state(state_id,user = nil)
    if state_addable?(state_id)
       if $game_switches[700] == true and $game_variables[230] < 8 
          state_id = 69  if state_id == 68
          state_id = 68  if state_id == 67
          state_id = 67  if state_id == 66
          state_id = 66  if state_id == 65
          state_id = 219 if state_id == 218
          state_id = 218 if state_id == 217
          state_id = 217 if state_id == 216
          state_id = 216 if state_id == 215
       end   
       add_new_state(state_id) unless state?(state_id)
       reset_state_counts(state_id,user)
       @result.added_states.push(state_id).uniq!
    end
  end

  def add_state_must(state_id,user = nil)
    add_new_state(state_id) unless state?(state_id)
    reset_state_counts(state_id,user)
    @result.added_states.push(state_id).uniq!
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否可以附加
  #--------------------------------------------------------------------------
  def state_addable?(state_id)
    alive? && $data_states[state_id] && !state_resist?(state_id) &&
      !state_removed?(state_id) && !state_restrict?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否已被解除
  #--------------------------------------------------------------------------
  def state_removed?(state_id)
    @result.removed_states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否受到行动限制影响而无法附加
  #--------------------------------------------------------------------------
  def state_restrict?(state_id)
    $data_states[state_id].remove_by_restriction && restriction > 0
  end
  #--------------------------------------------------------------------------
  # ● 附加新的状态
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    die if state_id == death_state_id
    @states.push(state_id)

    if $game_party.in_battle
      state = $data_states[state_id]
      unless [1,10].include?(state_id)
        if state.message1 != ""
          SceneManager.scene.tip("#{self.name}#{state.message1}","#{state.message2}")
        end
      end
    end

    on_restrict if restriction > 0
    sort_states
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 行动受到限制时的处理
  #--------------------------------------------------------------------------
  def on_restrict
    clear_actions
    states.each do |state|
      remove_state(state.id) if state.remove_by_restriction
    end
  end
  #--------------------------------------------------------------------------
  # ● 重置状态计数（回合数或步数）
  #--------------------------------------------------------------------------
  def reset_state_counts(state_id,user = nil)
    state = $data_states[state_id]
    variance = 1 + [state.max_turns - state.min_turns, 0].max
    variance_add = 0

   unless user.nil?
      if state.id >= 27 and state.id <= 29 #貂蝉
         variance_add += 1 if self.actor? and $game_party.exist_bskill?(70,381) and variance > 1 
      end   
      if self.actor? and state.id >= 72 and state.id <= 80 and $game_party.exist_jm_skill?(615)
         variance_add += 2
      end   
      if self.actor? and state.id >= 27 and state.id <= 29 and $game_party.exist_jm_skill?(636)
          if variance > 1
             if state.id == 27
                variance_add -= 2
             else
                variance_add -= 1
             end   
          end  
      end   
      if self.enemy? and self.index == 5 and state.id >= 27 and state.id <= 29
         if variance > 1 
            if state.id == 27
               variance_add -= 1
            else
               r = 4
               r = 2 if self.str > 200
               variance_add -= 1 if rand(10) > r
            end   
         end   
      end   
   end
    
    @state_turns[state_id] = state.min_turns + rand(variance) + variance_add
    @state_turns[state_id] = 0 if @state_turns[state_id] < 0
    @state_steps[state_id] = state.steps_to_remove
  end
  #--------------------------------------------------------------------------
  # ● 解除状态
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    if state_id == 3
       if self.enemy?
          self.dp = 0
       else
          self.tp = 0 if $game_party.in_battle
       end
    end
    if state?(state_id)
      if state_id == death_state_id
        revive
      end
      erase_state(state_id)

      if $game_party.in_battle
        state = $data_states[state_id]
        unless [1,10].include? state_id
          # $game_message.add("#{self.name}解除了#{state.name}")
          # SceneManager.scene.set_text("#{self.name}解除了#{state.name}","green")
          if state.message3 != ""
          SceneManager.scene.tip("#{self.name}#{(state.message3)}","#{state.message4}")
          end
        end
      end

      refresh
      @result.removed_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ● 死亡
  #--------------------------------------------------------------------------
  def die
    @hp = 0
    clear_states_d
    clear_buffs
    if self.actor? && !$game_party.in_battle
      change_btm_st :dead
    end
  end
  #--------------------------------------------------------------------------
  # ● 复活
  #--------------------------------------------------------------------------
  def revive
    if @hp == 0
      @hp = 1 
      if self.actor? && !$game_party.in_battle
        change_btm_st :alive
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 撤退
  #--------------------------------------------------------------------------
  def escape
    hide if $game_party.in_battle
    clear_actions
    clear_states
    Sound.play_escape
  end
  #--------------------------------------------------------------------------
  # ● 强化能力
  #--------------------------------------------------------------------------
  def add_buff(param_id, turns)
    return unless alive?
    @buffs[param_id] += 1 unless buff_max?(param_id)
    erase_buff(param_id) if debuff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 弱化能力
  #--------------------------------------------------------------------------
  def add_debuff(param_id, turns)
    return unless alive?
    @buffs[param_id] -= 1 unless debuff_max?(param_id)
    erase_buff(param_id) if buff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_debuffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 解除能力强化／弱化状态
  #--------------------------------------------------------------------------
  def remove_buff(param_id)
    return unless alive?
    return if @buffs[param_id] == 0
    erase_buff(param_id)
    @buff_turns.delete(param_id)
    @result.removed_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 消除能力强化／弱化
  #--------------------------------------------------------------------------
  def erase_buff(param_id)
    @buffs[param_id] = 0
    @buff_turns[param_id] = 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力强化状态
  #--------------------------------------------------------------------------
  def buff?(param_id)
    @buffs[param_id] > 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力弱化状态
  #--------------------------------------------------------------------------
  def debuff?(param_id)
    @buffs[param_id] < 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力强化是否为最大程度
  #--------------------------------------------------------------------------
  def buff_max?(param_id)
    @buffs[param_id] == 2
  end
  #--------------------------------------------------------------------------
  # ● 判定能力弱化是否为最大程度
  #--------------------------------------------------------------------------
  def debuff_max?(param_id)
    @buffs[param_id] == -2
  end
  #--------------------------------------------------------------------------
  # ● 重新设置能力强化／弱化的回合数
  #    如果新的回合数比较短，保持原值。
  #--------------------------------------------------------------------------
  def overwrite_buff_turns(param_id, turns)
    @buff_turns[param_id] = turns if @buff_turns[param_id].to_i < turns
  end
  #--------------------------------------------------------------------------
  # ● 更新状态的回总数数
  #--------------------------------------------------------------------------
  def update_state_turns
    states.each do |state|
      @state_turns[state.id] -= 1 if @state_turns[state.id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 颜良更新攻击后的计算次数，不按照回合
  #--------------------------------------------------------------------------
  def update_mt_turns(id,n)
      if @state_turns[id] > 0 
         @state_turns[id] -= n
      else
         remove_state(id)
      end
  end
  #--------------------------------------------------------------------------
  # ● 更新强化／弱化的回总数数
  #--------------------------------------------------------------------------
  def update_buff_turns
    @buff_turns.keys.each do |param_id|
      @buff_turns[param_id] -= 1 if @buff_turns[param_id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除战斗状态
  #--------------------------------------------------------------------------
  def remove_battle_states
    states.each do |state|
      remove_state(state.id) if state.remove_at_battle_end
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除所有的强化／弱化状态
  #--------------------------------------------------------------------------
  def remove_all_buffs
    @buffs.size.times {|param_id| remove_buff(param_id) }
  end
  #--------------------------------------------------------------------------
  # ● 状态的自动解除
  #     timing : 时机（1:行动结束 2:回合结束）
  #--------------------------------------------------------------------------
  def remove_states_auto(timing)
    states.each do |state|
      if @state_turns[state.id] == 0 && state.auto_removal_timing == timing
         remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 强化／弱化的自动解除
  #--------------------------------------------------------------------------
  def remove_buffs_auto
    @buffs.size.times do |param_id|
      next if @buffs[param_id] == 0 || @buff_turns[param_id] > 0
      remove_buff(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 受到伤害时解除状态
  #--------------------------------------------------------------------------
  def remove_states_by_damage
    states.each do |state|
      if state.remove_by_damage && rand(100) < state.chance_by_damage
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 决定行动回数
  #--------------------------------------------------------------------------
  def make_action_times
    action_plus_set.inject(1) {|r, p| rand < p ? r + 1 : r }
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗行动
  #--------------------------------------------------------------------------
  def make_actions
    clear_actions
    return unless movable?
    @actions = Array.new(make_action_times) { Game_Action.new(self) }
  end
  #--------------------------------------------------------------------------
  # ● 决定行动速度
  #--------------------------------------------------------------------------
  def make_speed
      @speed = @actions.collect {|action| action.speed }.min || 0
  end
  #--------------------------------------------------------------------------
  # ● 获取当前战斗行动
  #--------------------------------------------------------------------------
  def current_action
    @actions[0]
  end
  #--------------------------------------------------------------------------
  # ● 移除当前战斗行动
  #--------------------------------------------------------------------------
  def remove_current_action
    @actions.shift
  end
  #--------------------------------------------------------------------------
  # ● 强制战斗行动
  #--------------------------------------------------------------------------
  def force_action(skill_id, target_index)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    if target_index == -2
      action.target_index = last_target_index
    elsif target_index == -1
      action.decide_random_target
    else
      action.target_index = target_index
    end
    @actions.push(action)
  end
  #--------------------------------------------------------------------------
  # ● 计算伤害
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    r = 1
    value = item.damage.eval(user, self, $game_variables)
    if item.is_a?(RPG::Skill)
      if item.is_atk?
        if user.actor?
          user.attack_count += 1
          _def = self.def
          _def *= user.element_rate(52)  if user.element_rate(52) < 1.0 
          _userstr = user.str

          # 曹操被动技能 - 曹操在场时敌方战场武将全体防御力-5
          #_def -= 10 if $game_party.exist_bskill?(63,400)

          # 马超被动技能 - 马超的普通攻击将会受到技属性的影响和加成。
          _userstr = user.ski if user.id == 6 && $game_party.exist_bskill?(6,249)

          # 姜维被动技能 - 姜维的普通攻击将会受到智属性的影响和加成。
          _userstr = user.int if user.id == 56 && $game_party.exist_bskill?(56,359)

          # 星彩被动技能 - 姜维的普通攻击将会受到智属性的影响和加成。
          _userstr = user.agi if user.id == 18 && $game_party.exist_bskill?(18,281)
          # 孙尚香被动
          _userstr = self.str if user.id == 94 && user.str < self.str

          _userhp = user.hp

          # 孟获被动技能 - 孟获普通攻击至少获得50%的最大兵力加成。
          if user.element_rate(38) > 1 and user.hp <= user.mhp/2 
            _userhp = user.mhp/2
          end

          # 计算 value
          if user.state?(101) or user.state?(98)
            value  = user.atk * 2.0 + (user.mhp/10.0)
            _userhp = user.mhp
          else
            value  = user.atk * 2.0 + (_userhp/10.0)
          end
          value *= 0.2 + (_userstr/155.0) * 2
          value *= (1 - ( _def/ (_def + 75.0)))
          value = rand( _userhp/100.0 + user.atk ) + 5 if value < 0

          # 马谡被动技能攻击下降 
          value = (value * 0.9).to_i if $game_party.exist_bskill?(57,372) 

          # 张飞新被动，张飞的普通攻击获得战气加成，战气满时，伤害+成1.15倍
          if user.id == 4 && $game_party.exist_bskill?(4,240) && user.tp == 100
            value *= 1.15
          end

          # 文丑被动技能 - 满兵力状态下，文丑普通攻击威力+17%
          value *= 1.17 if user.id == 36 && $game_party.exist_bskill?(36,315) && user.maxhp?
          # 甘宁水的意志被动
              if $game_variables[179] > 0
                 value += ( $game_variables[179].to_i * 0.5 ).to_i
                 $game_variables[179] = 0
                 user.remove_state(149)
              end

     else
          # user 为敌人的情况

          # 记录受到伤害次数
          if self.actor?
             self.atk_damage_count += 1
          end

          _def = self.def
          _def *= user.element_rate(52)  if user.element_rate(52) < 1.0 
          _userhp = user.hp
          _userstr = user.str

          #boss的HP加强1.5倍，攻击计算的时候减少1.5倍
          if $game_troop.members.size == 6 and user.index == 5
            _userhp = (user.hp / 1.5).to_i
          end

          # 孟获被动技能 - 孟获普通攻击至少获得50%的最大兵力加成。
          if user.element_rate(38) > 1 and user.hp <= user.mhp/2 
            _userhp = user.mhp / 2
          end
           _userhp = 7500 if  _userhp > 7500
           _userhp = 8000 if $game_variables[309] > 0 and _userhp > 8000
          value  = user.atk * 2.0 + (_userhp/10.0)
          value *= 0.2 + (_userstr/155.0) * 2
          value *= (1 - ( _def.to_f / (_def + 75.0)).to_f)
          value = rand( _userhp/100.0 + user.atk ) + 5 if value < 0
        end
      end

      if item.is_marv?
          # 马良的被动技能 - 使用回复计策时，总回复量增加+17%
          if item.is_hp_recover_marv?
             value *= user.element_rate(48) 
          end  
        # 使用者为 我方
        if user.actor?

          #敌人是 #鱼鳞阵 & 方圆阵 # 的情况
          value *= 0.80  if $game_troop.formation.id == 8 and !item.damage.recover?
          value *= 1.25  if $game_troop.formation.id == 16 and !item.damage.recover? and item.speed != -1

          if $game_party.exist_jm_skill?(687) and user.id == $game_variables[100] 
             value *= (1 + user.level * 0.002)
          end

          if item.is_wood_marv?
            value *= user.element_rate(31)
            value *= 1.06  if $game_party.exist_jm_skill?(655)
          end

          if item.is_water_marv?
            value *= user.element_rate(32)
            value *= 1.06  if $game_party.exist_jm_skill?(656)
          end

          if item.is_fire_marv?
            value *= user.element_rate(33)
            value *= 1.06 if $game_party.exist_jm_skill?(657)
          end

          if item.is_wind_marv?
            value *= user.element_rate(34)
            value *= 1.06  if $game_party.exist_jm_skill?(658)
          end

          value *= user.element_rate(34) if item.damage.element_id == 23

          if (item.damage.variance == 14 or item.damage.variance == 13) 
            #只有一人时候修正群体计算公式
            value = (value/1.60).to_i  if $game_troop.alive_members.size == 1
            #有6人时候修正群体计算公式.按照5人计算
            value = value*1.2.to_i     if $game_troop.alive_members.size == 6
          end    

          # 魏延的被动技能 - 魏延在场时，我方计策威力下降10%。
          value *= 0.90 if $game_party.exist_bskill?(8,256)


          if user.id == 71 #$game_party.exist_bskill?(71,384)
            if item.for_one?
              # 张角的被动技能 - 张角20%法力值加成
               if item.damage.recover?
                  value -=  ( user.mp * 0.2 ).to_i 
               else
                  value +=  ( user.mp * 0.05 ).to_i 
               end
            else
               if item.damage.recover?
                  value -=  ( user.mp * 0.2 ).to_i 
               else
                  value +=  ( user.mp * 0.05 ).to_i 
               end
            end
          end

          # 庞统的被动技能 - 庞统连续使用计策威力持续上升。
          if user.id == 24 && $game_party.exist_bskill?(24,293)
            if item.is_hp_damage_marv? #or @marv_item == 1
              _n = 1.0
              if  user.state?(85)
                _n = 1.05
              elsif  user.state?(86)
                _n = 1.1
              elsif  user.state?(87)
                _n = 1.15
              elsif  user.state?(88)
                _n = 1.2
              elsif  user.state?(89)
                _n = 1.25
              end

              case _n
              when 1.0
                user.add_state_must(91)
              when 1.05
                user.add_state_must(92)
              when 1.1
                user.add_state_must(93)
              when 1.15
                user.add_state_must(94)
              when 1.2
                user.add_state_must(95)
              when 1.25
                user.remove_state(95)
                user.remove_state(89)
              end
              value *= _n
            end
          end
        end
      
        # 使用者为 敌方
        if self.actor?
          value = (value/1.60).to_i if item.damage.variance == 14 and $game_party.alive_members.size == 1
          # 孙策被动技能 - 孙策受到的所有计策伤害降低12%
          value *= 0.90 if self.id == 59 && $game_party.exist_bskill?(59,368)
          #我军 #鱼鳞阵 & 方圆阵 # 的情况
          value *= 0.80    if $game_party.formation.id == 8 and !item.damage.recover?
          value *= 1.25    if $game_party.formation.id == 16 and !item.damage.recover? and item.speed != -1

          value = (value/1.50).to_i  if item.damage.variance == 14 and $game_party.alive_members.size == 1 and item.is_marv?
          if item.is_wood_marv?
             value *= user.element_rate(31)
          end
          if item.is_water_marv?
             value *= user.element_rate(32)
          end
          if item.is_fire_marv?
             value *= user.element_rate(33)
          end
          if item.is_wind_marv?
             value *= user.element_rate(34)
          end
        end
      end 

      if item.is_skill?
        case item.id
        when 383 #张角10%MP*3 技能加成
                 value += ( user.mp * 0.1 ).to_i 
        when 320 #孟获主动技能。卖血30%
                 user.hp = ( user.hp * 0.7 ).to_i if user.hp > 100
        when 532 #孟获主动技能。卖血30%
                 user.hp = ( user.hp * 0.7 ).to_i if user.hp > 100
        when 361 #马谡雷电，打到雷玉效果x3
                 value *= 3    if self.state?(123) or self.state?(144)
        when 389 #太史慈炎玉，伤害提升20%
          if user.equips.include?($data_armors[355]) 
             value *= 1.15
          elsif user.equips.include?($data_armors[376])
             value *= 1.25
          end
        end
      end
    end

    if  item.is_atk?
      value *= user.element_rate(49)
      value -= (( self.element_rate(62)-1.0 ) * 100 ).to_i
      value *= 0.9  if self.state?(51) #护体计
      value *= 0.5  if self.state?(137) #左慈仙法
      value *= self.element_rate(35)
                # 甘宁水的意志被动-敌人
              if $game_variables[179] > 0
                 value += ( $game_variables[179].to_i * 0.5 ).to_i
                 $game_variables[179] = 0
                 user.remove_state(149)
              end
    end

    value *= 1.12  if user.actor? and !item.damage.recover? and $game_party.exist_jm_skill?(603) and user.equip_wtype_ok?(13)
    value *= 1.05  if user.actor? and item.is_hp_recover_marv? and $game_party.exist_jm_skill?(606)
    value *= 1.40  if user.actor? and self.equip_wtype_ok?(12) and $game_party.exist_jm_skill?(610) and !item.damage.recover?
    value *= 1.05  if $game_party.exist_jm_skill?(653) and user.actor? and item.is_atk?  and !item.damage.recover?
    value *= 0.95  if $game_party.exist_jm_skill?(664) and user.enemy? and !item.is_marv? and !item.damage.recover?
    value *= 0.90  if $game_party.exist_jm_skill?(679) and user.enemy? and self.actor? and user.index == 5 and !item.damage.recover?
    value *= 1.10  if $game_party.exist_jm_skill?(679) and user.actor? and self.enemy? and self.index == 5 and !item.damage.recover?
    value *= 1.05  if $game_party.exist_jm_skill?(654) and user.actor? and item.is_marv? #or @marv_item == 1) and !item.damage.recover?
    value *= 1.05  if $game_party.exist_jm_skill?(609) and user.actor? and !item.damage.recover? and user.id >= 3 and user.id <= 7
       if user.enemy? 
          value *= 0.95  if $game_party.exist_jm_skill?(667) and user.equip_wtype_ok?(1) and self.actor?
          value *= 0.95  if $game_party.exist_jm_skill?(668) and user.equip_wtype_ok?(2) and self.actor?
          value *= 0.95  if $game_party.exist_jm_skill?(669) and user.equip_wtype_ok?(3) and self.actor?
          value *= 0.95  if $game_party.exist_jm_skill?(670) and user.equip_wtype_ok?(4) and self.actor?
          value *= 0.95  if $game_party.exist_jm_skill?(671) and user.equip_wtype_ok?(5) and self.actor?
          value *= 0.95  if $game_party.exist_jm_skill?(672) and user.equip_wtype_ok?(6) and self.actor?
          value *= 0.95  if $game_party.exist_jm_skill?(673) and user.equip_wtype_ok?(7) and self.actor?
          value *= 1.05  if $game_variables[309] > 0 and item.is_marv?
          value *= 0.90  if $game_variables[309] < 0 and item.is_marv?
       end
    if self.id == $game_variables[100]
       if $game_party.exist_jm_skill?(683)
          value *= 1.12  if user.actor? and (item.is_marv? or item.is_atk?) and !item.damage.recover?
          value *= 0.88  if self.actor? and item.damage.recover?
       end
       value *= 0.88  if $game_party.exist_jm_skill?(682) and self.actor? and self.hp < self.mhp*0.5 and !item.damage.recover? 
       if $game_party.exist_jm_skill?(690) and user.actor? and self.hp == self.mhp and !item.damage.recover?
          value += (self.mhp * 0.04).to_i
       end
    end
    if $game_party.exist_jm_skill?(691) and user.actor? and self.hp < self.mhp*0.5 and !item.damage.recover?
       value *= 1.05
    end

    if item.is_atk? 
       if user.actor? 
          value *= 1.08  if $game_party.exist_jm_skill?(628) and user.equip_wtype_ok?(1)  
          value *= 1.08  if $game_party.exist_jm_skill?(629) and user.equip_wtype_ok?(2)
          value *= 1.08  if $game_party.exist_jm_skill?(630) and user.equip_wtype_ok?(3)
          value *= 1.08  if $game_party.exist_jm_skill?(631) and user.equip_wtype_ok?(4)
          value *= 1.08  if $game_party.exist_jm_skill?(632) and user.equip_wtype_ok?(5)
          value *= 1.08  if $game_party.exist_jm_skill?(633) and user.equip_wtype_ok?(6)
          value *= 1.08  if $game_party.exist_jm_skill?(634) and user.equip_wtype_ok?(7)
          value *= 1.10  if $game_party.exist_jm_skill?(665) and user.id == $game_variables[100] and user.hp < user.mhp * 0.75
           if user.equip_wtype_ok?(53) and user.mp >= 100
              value *= 1.25
              user.mp -= 100
           end   
       end
          value *= 0.5 if self.state?(280) and user.equip_wtype_ok?(1)
          value *= 0.5 if self.state?(281) and user.equip_wtype_ok?(3)
          value *= 0.5 if self.state?(282) and user.equip_wtype_ok?(5)
          value *= 0.5 if self.state?(283) and user.equip_wtype_ok?(4)
          value *= 0.5 if self.state?(272) and user.equip_wtype_ok?(2)
    end
    if item.is_skill? 
       if user.actor? 
          value *= 1.12  if $game_party.exist_jm_skill?(622)  
       else
          value *= self.element_rate(61)
          value *= 0.9  if $game_party.exist_jm_skill?(623) 
       end
    end


    #杖装备策略伤害提升
    if item.is_hp_damage_marv? or item.is_hp_recover_marv? and user.actor?
       up = 0 #天罡杖成长特殊算法
       if user.equips.include?($data_weapons[582])
          up = ( (user.kill_size_all) / 5.0 ).to_i
          up = 150 if up > 150
       end 
       if item.for_one?
          _fdr = ( (user.fdr-1) * 100.0 ) + up
          _fdr = _fdr.to_i
            if $game_switches[743] == true or $game_variables[309] > 0
               _fdr = $game_variables[230] * 30 if _fdr > $game_variables[230] * 30
            end
          if item.is_hp_recover_marv?
             value -= _fdr
          else
             value += _fdr
          end  
       else
          _fdr = ( (user.fdr-1) * 30.0 ) + up
          _fdr = _fdr.to_i
            if $game_switches[743] == true or $game_variables[309] > 0
               _fdr = $game_variables[230] * 12 if _fdr > $game_variables[230] * 12
            end
          if item.is_hp_recover_marv?
             value -= _fdr
          else
             value += _fdr
          end   
       end
    end

    value *= item_element_rate(user, item)
    value *= user.pdr if item.is_atk? #or (item.is_skill? and item.damage.to_hp? and !item.damage.recover?)
    value *= user.mdr if item.is_hp_damage_marv? #or @marv_item == 1 #or (item.is_skill? and item.damage.to_hp? and !item.damage.recover?)
    value *= user.element_rate(24) if item.is_skill? and user.element_rate(24) > 0

    value *= user.rec if item.damage.recover?
    if @result.critical and !item.damage.recover?

        cri_a = (1.25 + user.element_rate(25)-1.0)
        cri_b = 0
        cri_b += 0.15  if $game_party.exist_jm_skill?(602) and user.actor?
        cri_b -= 0.15  if $game_party.exist_jm_skill?(611) and self.actor?
        cri_b += 0.25  if user.state?(45)
        cri_b += 0.25  if user.state?(81)
        cri_b -= 0.08  if user.state?(81) and user.state?(45) and user.actor? and user.id != 16
        cri_b -= 0.10  if user.state?(81) and user.state?(45) and user.state?(46)
        cri_b *= 0.80  if !item.is_atk?

        cri_c = cri_a + cri_b
        cri_c = 1.0  if cri_c < 1.0
        value *= cri_c

       if user.equip_wtype_ok?(25) and self.int > 195  #马玩
          cri_d  = (self.int - 195) * 0.005
          if item.is_skill? 
             cri_d *= 1.5
          end    
          cri_d  = (1+cri_d)
          value *= cri_d
       end
    end

    # 减策计 - 策略伤害减少
    if item.is_hp_damage_marv? #or @marv_item == 1
       value *= 0.85  if  self.state?(43)
       value *= 1.4   if  self.state?(137) #左慈仙法
       value *= 0.94 if $game_party.exist_jm_skill?(638) and user.enemy? 
    end

    #技能额外属性加成
    if item.is_skill? and user.actor?
      if item.note.split("\r\n")[1] != nil
        skill_st = item.note.split("\r\n")[1][0,3]  
        skill_add = (item.note.split("\r\n")[1].split(" = ").last).to_i
      end
      if skill_st != nil and skill_add != nil
        value *= 1+(user.str - skill_add)*0.010 if skill_st == "str" and user.str > skill_add
      end
      if skill_st != nil and skill_add != nil 
        if user.id == 6
           value *= 1+(user.ski - skill_add)*0.010 if skill_st == "ski" and user.ski > skill_add
        else
           value *= 1+(user.ski - skill_add)*0.015 if skill_st == "ski" and user.ski > skill_add
        end
      end
      if skill_st != nil and skill_add != nil 
        value *= 1+(user.int - skill_add)*0.010 if skill_st == "int" and user.int > skill_add
      end
      if skill_st != nil and skill_add != nil 
         value *= 1+(user.agi - skill_add)*0.010 if skill_st == "agi" and user.agi > skill_add
      end
    end 

    if user.actor? and !item.damage.recover? and !item.is_hp_recover_marv? and item.id != 187 and item.id != 194
          if $game_party.boost >= 100
             if item.is_skill?
                #if item.id >= 168 and item.id <= 173
                   #value = ( value * (($game_party.boost*2.0 )  / 200.0 ).to_f ).to_i        #真武 峰值255%
                #else
                   value = ( value * (($game_party.boost*2.0 + 110.0) / 310.0 ).to_f ).to_i  #将技 峰值200%
                #end
             else
                   value = ( value * (($game_party.boost*2.0 + 420.0) / 620.0 ).to_f ).to_i  #普攻 峰值150%
             end
          else
             if item.is_skill?
                if $game_party.exist_jm_skill?(688) 
                   value = ( value * (($game_party.boost*2.0 + 1800.0) / 2000.0 ).to_f ).to_i  #技能 低谷90%
                else
                   value = ( value * (($game_party.boost*2.0 + 600.0) / 800.0 ).to_f ).to_i    #技能 低谷75%
                end
             else
                if $game_party.exist_jm_skill?(688) 
                   value = ( value * (($game_party.boost*2.0 + 400.0) / 600.0 ).to_f ).to_i    #普攻 低谷65%
                else
                   value = ( value * (($game_party.boost*2.0 + 200.0) / 400.0 ).to_f ).to_i    #普攻 低谷50%
                end
             end
             value *= (1+((100-$game_party.boost)*0.004)) if $game_variables[309] < 0
          end     
    end

    #周仓
    value = (self.mhp * 0.23).to_i  if self.id == 34 and value > ( self.mhp * 0.23 ) and !item.damage.recover?
     if !item.damage.recover? #按防御后的效果
         value = (value * self.grd).to_i
         if self.state?(2) 
            value *= 0.85  if $game_party.exist_jm_skill?(684) and self.actor? 
            value *= 0.85  if self.enemy? 
         end
     end
  
    #只受到技能伤害
    value *= 0.25 if self.state?(206) and !item.is_skill? and !item.damage.recover?

    #只受到技能伤害
    value *= 0.25 if self.state?(205) and !@result.critical and !item.damage.recover?


    if user.equip_wtype_ok?(54) and item.is_atk? and user.actor? and user.hp > 0
       user.add_state_must(62) 
    end
    #城防&&无视城防
    if !item.damage.recover?
    if self.element_rate(54) < 1.0
    if user.element_rate(53) > 1.0
       value *= ( ( 1 - self.element_rate(54)*1.0 ) * (user.element_rate(53) - 1.0) + self.element_rate(54)*1.0 )
    else
       value *= self.element_rate(54)
    end
    end
    end
    #直接打BOSS，boss伤害再减少25%
    value *= 0.75 if self.enemy? and self.index == 6 and $game_troop.alive_members.size == 6
    #自己打自己 伤害减半
    value *= 0.5 if user.actor? and self.actor? and ( item.is_atk? or item.is_marv? ) and !item.damage.recover?
    value *= 0.5 if user.enemy? and self.enemy? and ( item.is_atk? or item.is_marv? ) and !item.damage.recover?
    #第八章难度降低
    if user.enemy? and $game_variables[230] >= 8
        if !item.damage.recover? and !item.is_hp_recover_marv?
            value *= 0.90
        end 
    end 

    #我修改了，最小伤害5
    if item.is_atk? then
       value = 5+rand(30)  if value < 30
    end
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)

    @result.make_damage([value.to_i.abs,1].max, item)
  end
  #--------------------------------------------------------------------------
  # ● 获取技能／物品的属性修正值
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    if item.damage.element_id < 0
      user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements)
    else
      element_rate(item.damage.element_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取属性的最大修正值，返回所有属性中最有效的一个
  #     elements : 属性 ID 数组
  #--------------------------------------------------------------------------
  def elements_max_rate(elements)
    elements.inject([0.0]) {|r, i| r.push(element_rate(i)) }.max
  end
  #--------------------------------------------------------------------------
  # ● 应用关键一击
  #--------------------------------------------------------------------------
  def apply_critical(damage)
  end

  def apply_critical_ace(damage)
  end
  #--------------------------------------------------------------------------
  # ● 应用离散度
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    return damage if $TEST
    amp = [damage.abs * variance / 100, 0].max.to_i
    var = rand(amp + 1) + rand(amp + 1) - amp
    damage >= 0 ? damage + var : damage - var
  end
  #--------------------------------------------------------------------------
  # ● 应用防御修正
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    damage / (damage > 0 && guard? ? 2 * grd : 1)
  end
  #--------------------------------------------------------------------------
  # ● 处理伤害
  #    调用前需要设置好
  #    @result.hp_damage   @result.mp_damage 
  #    @result.hp_drain    @result.mp_drain
  #--------------------------------------------------------------------------
  def execute_damage(user,item=nil)
    on_damage(@result.hp_damage,item) if @result.hp_damage > 0
    unless $game_party.in_battle
      self.hp += item.damage.type == 3 ? @result.hp_damage : (-@result.hp_damage)
    end
    self.mp += item.damage.type == 4 ? @result.mp_damage : (-@result.mp_damage)

    user.hp += @result.hp_drain
    user.mp += @result.mp_drain
    
    # 心乱计 - 使敌减少SP最大值20%
    if item && item.id == 187
      self.mp -= (self.mmp * 0.1).round
      self.mp = [0, self.mp].max
    end
  end

    def execute_boost(d)
        $game_party.boost.to_i
        boost = $game_party.boost
        if $turn_damage == 0 
           if @item_1 != nil and !@result.missed
              n = 0
              n = @item_1.message1.to_f if !@item_1.is_item?
              n -= 3    if @user_1.equip_wtype_ok?(5) and @item_1.is_atk?     #弓箭手打2次削弱士气
              n *= 1.25 if @result.critical                                   #暴击士气+5
              n *= 2    if @user_1.state?(136)                                #士气双倍状态
              n =  0    if @user_1.unit == self.unit and @item_1.is_atk?      #如果自己打自己人
              n =  0    if self.actor? and self.state?(42)                   #定军计不减少士气
              n *= 1.25 if $game_variables[309] < 0 and self.actor?
              #n *= 0.5 if @item_1.id == 361  
              unless n == 0
              if @user_1.actor?
                     if     boost >= 200
                            n *= 0.5
                     elsif  boost >= 100
                            n *= 1.0
                     elsif  boost >= 50
                            n *= 1.5
                     else
                            n *= 2.0
                     end
                 $game_party.incr_boost n
              else
                     if     boost >= 200
                            n *= 1.5
                     elsif  boost >= 100
                            n *= 1.0
                     elsif  boost >= 50
                            n *= 0.75
                     else
                            n *= 0.5
                     end
                 $game_party.cost_boost n
              end
              end
           end
       end
    end   
  #--------------------------------------------------------------------------
  # ● 技能／使用物品
  #    对使用目标使用完毕后，应用对于使用目标以外的效果。
  #--------------------------------------------------------------------------
  def use_item(item)
    # 技能的情况下 减少 mp 或 tp
    pay_skill_cost(item) if item.is_a?(RPG::Skill)

    #如果敌人使用技能，扣除DP
    if item.is_skill? and !self.actor?
       self.dp -= item.tp_cost if !self.state?(3) #不是无双状态
    end

    # 消费道具减少数量
    if item.is_a?(RPG::Item)
        consume_item(item)
    end
    # 消费道具公共事件效果 - 预设置公共事件的ID
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  #--------------------------------------------------------------------------
  # ● 消耗物品
  #--------------------------------------------------------------------------
  def consume_item(item)
    $game_party.consume_item(item)
  end
  #--------------------------------------------------------------------------
  # ● 应用对于使用目标以外的效果
  #--------------------------------------------------------------------------
  def item_global_effect_apply(effect)
    if effect.code == EFFECT_COMMON_EVENT
      $game_temp.reserve_common_event(effect.data_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的应用测试
  #    如果使用目标的 HP 或者 MP 全满时，禁止使用恢复道具。
  #--------------------------------------------------------------------------
  def item_test(user, item)
    return true

    if item.for_opponent?

    elsif item.for_friend?

    elsif item.for_dead_friend?

    else
      return true
    end

    # 回复且体力为0

    # 复活且体力不为0

    # 

    # 效果范围为自己 但自己已经死了 -> 无效
    # return false if item.for_dead_friend? && dead?
    # return true if $game_party.in_battle
    # 效果范围为对方 -> 有效
    return true if item.for_opponent?
    # 效果为回复体力并且体力不满 -> 有效
    return true if item.damage.recover? && item.damage.to_hp? && hp <= mhp
    # 效果为回复mp并且mp不满 -> 有效
    return true if item.damage.recover? && item.damage.to_mp? && mp <= mmp
    # 道具的使用效果列表中的效果 任何一个效果有效 -> 有效
    return true if item_has_any_valid_effects?(user, item)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定技能／物品是否有效果
  #--------------------------------------------------------------------------
  def item_has_any_valid_effects?(user, item)
    item.effects.any? {|effect| item_effect_test(user, item, effect) }
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的反击几率
  #--------------------------------------------------------------------------
  def item_cnt(user, item)
    return 0 unless item.physical?          # 攻击类型不是物理攻击
    return 0 if item.is_skill?              # 技能无法反击
    return 0 unless opposite?(user)         # 队友无法反击
   # return 0 unless user.equip_wtype_ok?(37) 
    return cnt                              # 返回反击几率
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的反射几率
  #--------------------------------------------------------------------------
  def item_mrf(user, item)
    return mrf if item.magical?             # 是魔法攻击则返回反射魔法几率
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的成功几率
  #--------------------------------------------------------------------------
  def item_hit(user, item)
    @user_1 = user
    @item_1 = item
    $turn_damage = 0  if $turn_damage != -2 
    return 0 if item.damage.recover? and ( self.equip_wtype_ok?(35) or self.state?(57) )
    return 1 if item.certain?                # 必定命中直接返回
    return 1 if self.equip_wtype_ok?(35) and BattleManager.in_turn?  # 生门必定被命中
    return 1 if user.state?(55)              # 必中状态
    return 1 if user.eql?(self)              # 攻击自己的情况下直接命中返回
    rate = item.success_rate * 0.01          # 获取计策基础成功几率
    if item.is_a?(RPG::Skill) 
      @item_all = 0
      if item.is_atk? or ( item.is_skill? and item.hit_type == 1 ) 
        rate *= ((user.ski+255.0) / (self.agi+255.0))  #255系数，越大越接近


        if item.physical?
           rate += (user.hit)   # 阵型和被动技能HIT加成
        end
           rate += 0.12 if $game_party.exist_jm_skill?(674) and self.index == 0
           rate += 0.12 if $game_party.exist_jm_skill?(675) and self.index == 1
           rate += 0.12 if $game_party.exist_jm_skill?(676) and self.index == 2
           rate += 0.12 if $game_party.exist_jm_skill?(677) and self.index == 3
           rate += 0.12 if $game_party.exist_jm_skill?(678) and self.index == 4
      end

      # 如果是【法术型技能】计算命中
      if item.is_skill? and item.hit_type == 2 
        rate *= ((user.int+255.0) / (int+255.0))  #255系数，越大越接近
        if item.physical?
          rate += (user.hit)  # 阵型和被动技能HIT加成
        end
      end
    end

    if item.is_marv?
      _user_val = item.hit_type == 2 ? user.int : user.str
      _target_val = item.hit_type == 2 ? int : str

      rate *= ( (_user_val*0.75+user.ski*0.75 ) / (_target_val * 2.5))

      if user.actor?
         rate += 0.07 if $game_party.exist_jm_skill?(647) 
         rate += 0.08 if $game_party.exist_jm_skill?(666) and user.id == $game_variables[100] and user.hp < user.mhp*0.5
         rate *= 1.10 if $game_party.exist_jm_skill?(618) and ( user.id == 26 or user.id == 57 )
         rate += 0.10 if $game_party.exist_jm_skill?(674) and self.index == 0
         rate += 0.10 if $game_party.exist_jm_skill?(675) and self.index == 1
         rate += 0.10 if $game_party.exist_jm_skill?(676) and self.index == 2
         rate += 0.10 if $game_party.exist_jm_skill?(677) and self.index == 3
         rate += 0.10 if $game_party.exist_jm_skill?(678) and self.index == 4
         if $game_party.exist_jm_skill?(687) and user.id == $game_variables[100] 
             rate += user.level * 0.002
         end 
         rate += 0.12 if $game_party.exist_jm_skill?(693) and ( item.id == 161 or item.id == 162 or item.id == 163 or item.id == 164)
         #额外的技属性，对玩家的计策命中提升
         add_ski = user.ski - $data_classes[user.id].params[3,1]
         if add_ski > 0
            rate += (add_ski * 0.0015)
         end
      end


      # 被攻击者-为-我方
      if self.actor?
         rate -= 0.05   if $game_party.exist_jm_skill?(648) 
      end

          if item.is_wood_marv?
             rate *= user.element_rate(63)
             rate += 0.05  if $game_party.exist_jm_skill?(655) and user.actor?
             rate *= 1.25  if user.state?(110)
          end

          if item.is_water_marv?
             rate *= user.element_rate(64)
             rate += 0.05  if $game_party.exist_jm_skill?(656) and user.actor?
          end

          if item.is_fire_marv?
             rate *= user.element_rate(65)
             rate += 0.05  if $game_party.exist_jm_skill?(657) and user.actor?
          end

          if item.is_wind_marv?
             rate *= user.element_rate(66)
             rate += 0.05  if $game_party.exist_jm_skill?(658) and user.actor?
          end

      if !item.damage.recover?
        rate *= user.element_rate(21)  
        rate *= self.element_rate(22) 
      end

      #离间，叛离状态加成
      rate *= 2    if item.id == 181 and self.state?(27)
      if item.id == 182 
        rate *= 2    if self.state?(27)
        rate *= 2    if self.state?(28)
      end

    end


    rate = [rate,0.05].max
  

    # 严颜新的被动技能。不会受到来自疑心，离间，叛离计的伤害 
    if item.is_marv? and item.is_sow_marv?
       rate *= user.element_rate(67)
       rate *= self.element_rate(58)
       rate = 0 if self.actor? and self.id == 37
    end   
    rate = 0  if item.id == 198 and self.index == 5 #BOSS不参与阵法，所以第6人永远不会中解阵计
    rate = 0  if item.is_marv? and ( self.state?(207) or self.state?(222) ) and !user.state?(209)
    rate = 0  if item.is_atk?  and ( self.state?(208) or self.state?(223) ) and !user.state?(209)

    #暗杀计策命中
    if item.id == 190
       rate = 0 unless self.state?(233)
    end

    if rate != 0
       if item.is_marv?
          rate = [rate,0.975].min 
       else
          rate -= item_eva(user, item)
          rate = (10000 - (self.agi * 3)) * 0.0001 if rate > 1  #3代表基础回避率系数，越高回避越高
          rate += 0.03 if user.actor? and item.for_one?
          rate = [rate,0.975].min 
       end 
    end     

    return rate  # 返回计算后的成功几率

  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的闪避几率
  #--------------------------------------------------------------------------
  def item_eva(user, item)
    return eva if item.physical?            # 是物理攻击则返回闪避几率
    return mev if item.magical?             # 是魔法攻击则返回闪避魔法几率 
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的必杀几率
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    # 原来的方法
    # item.damage.critical ? user.cri * (1 - cev) : 0  

    #阵法的会率加成 
    _rate = (user.cri) * (1 - cev)
    #双方【技属性】的差距 + 阵法的会心率加成
    n = 0#item.damage.critical ? (0.0 + (user.ski)*0.0005 + _rate) : 0
    n += _rate
    n = 0  if n < 0
    n += (( user.ski * user.ski * user.ski * user.ski * user.ski ) *0.000001 / 3000000.0 ).round(3)  #自身技属性的暴击加成

    if user.actor?
       add_ski = user.ski - $data_classes[user.id].params[3,1]
    else
       add_ski = user.ski - $data_enemies[user.id].params[3]
    end
    if add_ski > 0
       n += (add_ski * 0.005)
    end
    n = n.round(3)

    #if n > 240
    #elsif n  n > 230

    a = (self.element_rate(47).to_f).round(2)
    n *= a 
    # 颜良被动技能 - 颜良的会心一击几率+22%
    if user.is_a?(Game_Actor) 
       n += 0.25 if user.id == 35 && $game_party.exist_bskill?(35,312)
       n += 0.25 if user.state?(81)
       n += 0.15 if $game_party.exist_jm_skill?(674) and self.index == 0
       n += 0.15 if $game_party.exist_jm_skill?(675) and self.index == 1
       n += 0.15 if $game_party.exist_jm_skill?(676) and self.index == 2
       n += 0.15 if $game_party.exist_jm_skill?(677) and self.index == 3
       n += 0.15 if $game_party.exist_jm_skill?(678) and self.index == 4
    else
       n -= 0.15 if $game_party.exist_jm_skill?(611)
    end

    # 马玩被动
    if user.equip_wtype_ok?(25) and self.int > 190
       cri_add = (self.int - 190) * 0.01
       cri_add = 0.55 if cri_add > 0.55
       n += cri_add
    end

    if item.is_skill?
      if $game_party.formation.id != 17 
        #赵云主动技能01
        n += 0.5 if item.id == 245 
        #赵云剧本技能必定暴击
        n += 1   if item.id == 220
      end
    end      


    n = [n,0.01].max 
    #n = [n,0.95].min
    if user.actor?
      n = 0 if $game_party.formation.id == 17 
      #鱼鳞阵 15一定被必杀
      n = 10 if $game_troop.formation.id == 8 and (self.index == 4 or self.index == 0)
    else
      n = 0 if $game_troop.formation.id == 17 
      n = 10 if $game_party.formation.id == 8 and (self.index == 4 or self.index == 0)
    end
    n = 0 if item.damage.critical == false
    n = 0  if n < 0 

    # 弃心计 暴击=0 
    n = 0 if user.state?(44)

    return n
  end
  #--------------------------------------------------------------------------
  # ● 应用普通攻击的效果
  #--------------------------------------------------------------------------
  def attack_apply(attacker)
    item_apply(attacker, $data_skills[attacker.attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # ● 应用技能／物品的效果 (原来的方法)
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        execute_damage(user,item)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用技能／物品的效果 拆分1 计算命中率
  #--------------------------------------------------------------------------
  def item_apply1(user, item)
    @result.clear
    # 判定是否成功试用 item_test -> 测试技能/物品是否有效果
    @result.used = item_test(user, item)

    # 计算是否miss -> 有效并且道具效果命中率计算为 随机数 >= 道具计算命中率 则miss有效,否则miss无效
    _item_hit = item_hit(user, item)
    @result.missed = (@result.used && rand >= _item_hit )
    # @result.missed = (@result.used && rand >= (_item_hit) * (1.0 - item_eva(user, item)))
    item_apply1a(user, item)
  end

  def item_apply1a(user, item)
    if @result.hit?
      unless item.damage.none?
        _item_cri = item_cri(user, item)
        # 计算是否会心一击
        @result.critical = (rand < _item_cri)
        # 计算伤害值 并保存于 @result 中
        make_damage_value(user, item)
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 应用技能／物品的效果 拆分2 计算伤害
  #--------------------------------------------------------------------------
  def item_apply2(user, item)
    if @result.hit?
      unless item.damage.none?
        # 执行伤害，扣除 mp, tp, 由于 hp 为动画闪光时扣除，故这里删除了
        execute_damage(user,item)
      end
      # 应用技能/物品 所有的使用效果
      item.effects.each {|effect| item_effect_apply(user, item, effect) }

      # 用用物品/技能 对使用者的效果 ( 获得tp )
      item_user_effect(user, item)

      # 处理特殊计策效果
      spe_item_effect_apply(user, item)
    end
  end

  #--------------------------------------------------------------------------
  # ● 处理特殊计策效果
  #--------------------------------------------------------------------------
  def spe_item_effect_apply(user, item)
    #if item.is_marv?
    #  _unit = unit
    #  _size = unit.states.size
      #_unit.states.push(:jc)  if item.id == 183 # 1: 减策计 - 回复效果减半
     # _unit.states.push(:jm)  if item.id == 184 # 2: 击免计 - 物理伤害无效
     # _unit.states.push(:cm)  if item.id == 185 # 3: 策免计 - 敌策略无效
     # _unit.states.push(:xl)  if item.id == 195 # 4: 血路计 - 使敌人受到的回复效果减半
     # _unit.states.push(:chm) if item.id == 197 # 5: 嘲骂计 - 敌防御力下降15%
    #  _unit.states.uniq!
     # if _unit.
      # != _size
      # _state = Game_Unit::STATE_TABLE[_unit.states.last]
        #  if  item.id == 183 or item.id == 184 or item.id == 185 or item.id == 195 or item.id == 197
         # if _unit.is_a?(Game_Party) 
           # SceneManager.scene.tip("我军陷入了#{_state.first}","red")
         # else
           # SceneManager.scene.tip("敌军陷入了#{_state.first}","red")
         # end
         # end
     # end
   # end
  end
  #--------------------------------------------------------------------------
  # ● 处理特殊阵型效果
  #--------------------------------------------------------------------------
  def spe_formation_effect_apply(item)
    if item.is_formation?
      _unit = unit
      _unit.states.push(:jj) if item.id == 12  # 静寂阵
      _unit.is_bagua = true if item.id == 13   # 八卦阵
    end
  end

  #--------------------------------------------------------------------------
  # ● 测试使用效果
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP      # => 恢复体力值
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP      # => 恢复魔力值
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_ADD_STATE       # => 附加状态
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE    # => 解除状态
      state?(effect.data_id)
    when EFFECT_ADD_BUFF        # => 强化能力
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF      # => 弱化能力
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF     # => 解除强化能力
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF   # => 解除弱化能力
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL     # => 学会技能
      actor? && !skills.include?($data_skills[effect.data_id])
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用使用效果
  #--------------------------------------------------------------------------
  def item_effect_apply(user, item, effect)
    method_table = {
      EFFECT_RECOVER_HP    => :item_effect_recover_hp,
      EFFECT_RECOVER_MP    => :item_effect_recover_mp,
      EFFECT_GAIN_TP       => :item_effect_gain_tp,
      EFFECT_ADD_STATE     => :item_effect_add_state,
      EFFECT_REMOVE_STATE  => :item_effect_remove_state,
      EFFECT_ADD_BUFF      => :item_effect_add_buff,
      EFFECT_ADD_DEBUFF    => :item_effect_add_debuff,
      EFFECT_REMOVE_BUFF   => :item_effect_remove_buff,
      EFFECT_REMOVE_DEBUFF => :item_effect_remove_debuff,
      EFFECT_SPECIAL       => :item_effect_special,
      EFFECT_GROW          => :item_effect_grow,
      EFFECT_LEARN_SKILL   => :item_effect_learn_skill,
      EFFECT_COMMON_EVENT  => :item_effect_common_event,
    }
    method_name = method_table[effect.code]
    send(method_name, user, item, effect) if method_name
  end
  #--------------------------------------------------------------------------
  # ● 应用“恢复 HP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_hp(user, item, effect)
    value = (mhp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.hp_damage -= value
    @result.success = true
    self.hp += value
  end
  #--------------------------------------------------------------------------
  # ● 应用“恢复 MP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_mp(user, item, effect)
      a=0
      if item.is_item? and user.actor? and $game_party.exist_jm_skill?(607)
         a=0.08  if item.id == 30
         a=0.03  if item.id == 31
      end
      value = (mmp * (effect.value1+a) + effect.value2) * rec
      value *= user.pha if item.is_a?(RPG::Item)
      value = value.to_i
      @result.mp_damage -= value
      @result.success = true if value != 0
      self.mp += value
  end
  #--------------------------------------------------------------------------
  # ● 应用“增加 TP”效果
  #--------------------------------------------------------------------------
  def item_effect_gain_tp(user, item, effect)
    value = effect.value1.to_i
    @result.tp_damage -= value
    @result.success = true if value != 0
    self.tp += value
    self.ap += value.to_i if user.actor?
  end
  #--------------------------------------------------------------------------
  # ● 应用“附加状态”效果
  #--------------------------------------------------------------------------
  def item_effect_add_state(user, item, effect)
    if effect.data_id == 0
      item_effect_add_state_attack(user, item, effect)
    else
      item_effect_add_state_normal(user, item, effect)
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“状态附加”效果：普通攻击
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    user.atk_states.each do |state_id|
      chance  = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      #chance *= luk_effect_rate(user)
      if rand < chance
         add_state(state_id,user)
         @result.success = true
         unless self.equip_wtype_ok?(38)  
                case state_id
                when 140 ; user.add_state_must(240) #携带玉石攻击标记
                when 141 ; user.add_state_must(241)
                when 142 ; user.add_state_must(242)
                when 143 ; user.add_state_must(243)
                when 144 ; user.add_state_must(244)
                when 145 ; user.add_state_must(245)
                when 146 ; user.add_state_must(246)
                when 116 ; user.add_state_must(248)
         end
         end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“状态附加”效果：普通
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    #chance *= luk_effect_rate(user)      if opposite?(user)
    if rand < chance
      add_state(effect.data_id,user)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“状态解除”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    chance = effect.value1
    if rand < chance
       remove_state(effect.data_id)
       @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“强化能力”效果
  #--------------------------------------------------------------------------
  def item_effect_add_buff(user, item, effect)
    add_buff(effect.data_id, effect.value1)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“弱化能力”效果
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“解除能力强化”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_buff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] > 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“解除能力弱化”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_debuff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] < 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“特殊效果”效果
  #--------------------------------------------------------------------------
  def item_effect_special(user, item, effect)
    case effect.data_id
    when SPECIAL_EFFECT_ESCAPE
      escape
    end
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“能力提升”效果
  #--------------------------------------------------------------------------
  def item_effect_grow(user, item, effect)
    add_param(effect.data_id, effect.value1.to_i)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“学会技能”效果
  #--------------------------------------------------------------------------
  def item_effect_learn_skill(user, item, effect)
    learn_skill(effect.data_id) if actor?
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“公共事件”效果
  #--------------------------------------------------------------------------
  def item_effect_common_event(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # ● 对技能／物品使用者的效果
  #--------------------------------------------------------------------------
  def item_user_effect(user, item)
    #战气可以增加标志
    if $game_variables[133] > 0 and user.actor? and !SceneManager.scene.is_a?(Scene_Item) and !SceneManager.scene.is_a?(Scene_Marv) 
       itp = item.tp_gain  
       if $game_party.exist_jm_skill?(635) and user.id == $game_variables[100]
          if item.for_one?
             itp += (5+rand(5)) 
          else
             itp += (1+rand(3)) 
          end
       end   
       itp *= 0.5 if user.equip_wtype_ok?(5) and item.is_atk?   
       user.tp += (itp * user.tcr).to_i
    end
    if user.enemy? #二周目敌人加强
       if $game_switches[700] == true
          dp = 1 + rand(1)
       else
          dp = 0.75
       end
       user.dp += dp unless item.is_skill?
    end  
  end
  #--------------------------------------------------------------------------
  # ● 获取幸运影响程度
  #--------------------------------------------------------------------------
  def luk_effect_rate(user)
    return 1 if user.is_a?(Game_Enemy)
    return 1 
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敌对关系
  #--------------------------------------------------------------------------
  def opposite?(battler)
    actor? != battler.actor?
  end
  #--------------------------------------------------------------------------
  # ● 在地图上受到伤害时的效果
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
  end
  #--------------------------------------------------------------------------
  # ● 初始化敌人目标 TP  初始战气
  #--------------------------------------------------------------------------
  def init_tp_enemy
    if !self.actor?
        self.dp = ($data_enemies[self.id].note.split("\r\n")[3][3,1].to_i) * 10
        if $game_switches[700] == true
          if rand(100) > 75
             self.dp += 10
          else
             self.dp += 20
          end
        end 
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除 TP 
  #--------------------------------------------------------------------------
  def clear_tp
    #self.tp = 0
  end
  #--------------------------------------------------------------------------
  # ● 受到伤害时增加的 TP
  #--------------------------------------------------------------------------
  def charge_tp_by_damage(damage_rate,item)
    # 伤害性计策 => 增加 tp
    #if item.is_hp_damage_marv?
       #self.tp += 100 * damage_rate * tcr
      # 张飞被动技能 - 战斗中，张飞每次获得的怒气值+2
      #self.tp += 5 if self.id == 4 && $game_party.exist_bskill?(4,240)
   # end
   if $game_variables[133] > 0 && self.actor? && self.equip_wtype_ok?(39) && self.hp > 0 && !item.damage.recover?
      self.tp += 5 + rand(5) #帝王盾
   end 
    #如果角色死亡，TP全部为0
    if self.hp <= 0 and self.actor?
       self.tp = 0 unless $game_party.exist_jm_skill?(627)
    end
  end
  #--------------------------------------------------------------------------
  # ● HP 自动恢复
  #--------------------------------------------------------------------------
  def regenerate_hp
    #damage = -(mhp * hrg).to_i
    #perform_map_damage_effect if $game_party.in_battle && damage > 0
    #@result.hp_damage = [damage, max_slip_damage].min
    #_damage = @result.hp_damage
    #if _damage > 0
      # $game_message.add("#{self.name}损失了#{_damage}兵力")
      # SceneManager.scene.set_text("#{self.name}损失了#{_damage}兵力","red")
      # SceneManager.scene.tip("#{self.name}损失了#{_damage}兵力","red")
      #@sprite_battler.damage(_damage, false)
    #end
    #if _damage < 0
      # $game_message.add("#{self.name}恢复了#{_damage.abs}兵力")
      # SceneManager.scene.set_text("#{self.name}恢复了#{_damage.abs}兵力","green")
    # SceneManager.scene.tip("#{self.name}恢复了#{_damage.abs}兵力","green")
      #@sprite_battler.damage(_damage, false)
   # end
    #self.hp += @result.hp_damage
  end
  #--------------------------------------------------------------------------
  # ● 获取连续伤害最大值
  #--------------------------------------------------------------------------
  def max_slip_damage
    $data_system.opt_slip_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # ● MP 自动恢复
  #--------------------------------------------------------------------------
  def regenerate_mp
    @result.mp_damage = -(mmp * mrg).to_i
    self.mp -= @result.mp_damage
  end
  #--------------------------------------------------------------------------
  # ● TP 自动恢复
  #--------------------------------------------------------------------------
  def regenerate_tp
    #self.tp += 100 * trg
  end
  #--------------------------------------------------------------------------
  # ● 全部自动恢复
  #--------------------------------------------------------------------------
  def regenerate_all
    if alive?
      regenerate_hp
      regenerate_mp
      regenerate_tp
    end
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始处理
  #--------------------------------------------------------------------------
  def on_battle_start
    init_tp_enemy

    # 不是特技专注的情况下
    # init_tp unless preserve_tp?

    # p $game_party.formation.id
    # if self.is_a?(Game_Actor) && $game_party.formation.id != 4
    #   pos = case @formation_pos
    #     when 0 ; 10
    #     when 2 ; 8
    #     when 4 ; 6
    #   end
    #   @change_x -= pos*12
    #   BattleFiber.fc_actor.bitmap = Cache.skillp("#{$game_party.formation.id}")
    #   #p @change_x
    #   p "on battle start"
    # end
  end
  #--------------------------------------------------------------------------
  # ● 战斗行动结束时的处理
  #--------------------------------------------------------------------------
  def on_action_end
    @result.clear
    remove_states_auto(1)
    remove_buffs_auto
  end
  #--------------------------------------------------------------------------
  # ● 回合结束处理
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
  end
  
   def on_turn_end_2
    regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
  end

  def on_turn_end_3
  @result.clear
  end
  #--------------------------------------------------------------------------
  # ● 战斗结束处理
  #--------------------------------------------------------------------------
  def on_battle_end
    @result.clear
    remove_battle_states
    remove_all_buffs
    remove_sprite_battler
    clear_actions

    clear_tp
    @change_x = 0
    @change_x = 0
    @formation_pos = 0
    @formation_pos_incr = 0
    $game_switches[492] = false #结算画面关闭，对话框坐标恢复
    $game_switches[693] = true  #计算结果开启
    $game_party.over_plot_damage = 0 #剧情伤害清空
    $game_troop.over_plot_damage = 0

    #战斗结束恢复在野武将几率
    $game_variables[182] = 100
    $game_variables[195] = 10  if $game_variables[195] == -666
    $game_variables[197] = 10  if $game_variables[197] == -666
    $game_variables[199] = 10  if $game_variables[199] == -666
    $game_switches[488] = true #战斗结束地名显示动画不刷新
    $game_switches[627] = false #特殊战斗即时事件触发关闭
    if self.is_a?(Game_Actor)
       clear_count
    end
    enemy_old_drop_items
    appear
  end
  #--------------------------------------------------------------------------
  # ● 还原二周目随机武将的掉落
  #--------------------------------------------------------------------------
  def  enemy_old_drop_items
       if $game_switches[700] == true and $game_troop.troop.name[0,1] == "S"
       if self.is_a?(Game_Enemy)
          $game_troop.members.each_with_index do |member,index|
           if $game_variables[271][index] != nil and $game_variables[271][index] != []
              $data_enemies[member.id].drop_items.clear
              $data_enemies[member.id].drop_items += $game_variables[271][index]
           end
       end   
       end
       end
  end
  #--------------------------------------------------------------------------
  # ● 被伤害时的处理
  #--------------------------------------------------------------------------
  def on_damage(value,item)
    remove_states_by_damage
    charge_tp_by_damage(value.to_f / mhp,item)
  end

  def init_formation
    @change_x = 0
  end
end
