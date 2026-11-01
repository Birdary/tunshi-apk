#encoding:utf-8
#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　处理战斗中的行动的类。本类在 Game_Battler 类的内部使用。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :subject                  # 行动主体
  attr_reader   :forcing                  # 强制行动的标志
  attr_reader   :item                     # 技能 / 物品
  attr_accessor :target_index             # 目标索引
  attr_reader   :value                    # 评价值（自动战斗用）
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(subject, forcing = false)
    @subject = subject
    @forcing = forcing
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @item = Game_BaseItem.new
    @target_index = -1
    @random_icon = -1
    @value = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取队友单位
  # subject 为 Game_Actor : $game_party
  # subject 为 Game_Enemy : $game_troop
  #--------------------------------------------------------------------------
  def friends_unit
    subject.friends_unit
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人单位
  # 与 friends_unit 相反
  #--------------------------------------------------------------------------
  def opponents_unit
    subject.opponents_unit
  end
  #--------------------------------------------------------------------------
  # ● 设置敌人的战斗行动
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def set_enemy_action(action)
    if action
      set_skill(action.skill_id)
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置普通攻击
  #--------------------------------------------------------------------------
  def set_attack
    set_skill(subject.attack_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # ● 设置防御
  #--------------------------------------------------------------------------
  def set_guard
    set_skill(subject.guard_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # ● 设置技能
  #--------------------------------------------------------------------------
  def set_skill(skill_id)
    @item.object = $data_skills[skill_id]
    self
  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #--------------------------------------------------------------------------
  def set_item(item_id)
    @item.object = $data_items[item_id]
    self
  end
  #--------------------------------------------------------------------------
  # ● 获取物品实例
  #--------------------------------------------------------------------------
  def item
    @item.object
  end
  #--------------------------------------------------------------------------
  # ● 判定是否为普通攻击
  #--------------------------------------------------------------------------
  def attack?
    item == $data_skills[subject.attack_skill_id]
  end

  def item?
    @item.object.is_a?(RPG::Item)
  end

  def marv?
    @item.object.is_marv?
  end

  def skill?
    @item.object.is_skill?
  end

  def formation?
    @item.object.is_formation?
  end
  #--------------------------------------------------------------------------
  # ● 随机目标
  #--------------------------------------------------------------------------
  def decide_random_target
    if item.for_dead_friend?
      target = friends_unit.random_dead_target
    elsif item.for_friend?
      target = friends_unit.random_target
    else
      target = opponents_unit.random_target
    end
    if target
      @target_index = target.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置混乱行动
  #--------------------------------------------------------------------------
  def set_confusion
    set_attack
  end
  #--------------------------------------------------------------------------
  # ● 行动准备
  #--------------------------------------------------------------------------
  def prepare
    set_confusion if subject.confusion? && !forcing
  end
  #--------------------------------------------------------------------------
  # ● 判定行动是否有效
  #    假设在事件指令中没有选择强制行动时，
  #    受到状态的限制，也没有可用的物品，或者没有预定的行动，则返回 false。
  #--------------------------------------------------------------------------
  def valid?
    unit = subject.unit
    if item.is_a?(RPG::Skill)
      # 击免计 - 物理伤害无效 #不公平设定，导致击免计 = 无法行动 取消
      if item.is_atk? && @subject.state?(40)
        # return false
      end
      # 策免计 - 敌策略无效(解策计除外) #不公平设定，导致策免计 = 无法行动 取消
      if item.is_marv? && @subject.state?(41)
        if item.id != 199
           #return false
        end
      end
      # 无法使用阵型
      return false if item.is_formation? && !unit.can_use_formation_start?
    end
    (forcing && item) || subject.usable?(item)
  end
  #--------------------------------------------------------------------------
  # ● 计算行动速度
  #--------------------------------------------------------------------------
  def speed
    #speed = subject.agi + rand(5 + subject.agi / 10)
    speed = subject.agi
    speed += item.speed if item
    speed += subject.atk_speed #if attack?
    if subject.actor?
       speed -= 99 if $game_party.formation.id == 6 and subject.index < 4
       speed += 5  if $game_party.formation.id == 7  #白马被动
       speed += 10 if $game_party.exist_jm_skill?(645) #军师天赋
       speed += 75 if subject.state?(113) and item.is_wind_marv? #天变风
       speed += 20 if subject.equip_wtype_ok?(42)
       speed += 25+rand(25) if subject.id == 47 and item.is_marv? and item.for_friend? #简雍新被动
       for i in 0...$game_party.al.size
           if  $game_party.al[i].element_rate(26) > 1
               speed += ($game_party.al[i].element_rate(26)*100 - 100)
           end
       end
    else 
       speed += 5  if $game_troop.formation.id == 7 #白马被动
       speed -= 99 if $game_troop.formation.id == 6 and subject.index < 4
    end   
    speed
  end
  #--------------------------------------------------------------------------
  # ● 生成目标数组
  #--------------------------------------------------------------------------
  def make_targets
    if !forcing && subject.confusion?
      # 混乱时候的目标
      [confusion_target]
    elsif item.for_opponent?
      # 目标为敌人时 
          @random_icon = 1 if !forcing and item.for_one? and !@subject.actor? and item.is_marv? and item.id != 1
      targets_for_opponents
    elsif item.for_friend?
          @random_icon = 1 if !forcing and item.for_one? and !@subject.actor? and (item.is_hp_recover_marv? or item.is_buff_marv? or item.is_sow_marv?)
      # 目标为自己人时
      targets_for_friends
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # ● 混乱时的目标
  #--------------------------------------------------------------------------
  def confusion_target
    case subject.confusion_level
    when 1
      y = 0
      if @subject.equip_wtype_ok?(41)
         opponents_unit.members.each do |a|
            if a.equip_wtype_ok?(40) and a.hp > 0
               y = 1
               return opponents_unit.smooth_target(a.index)
               break
            end
         end
         opponents_unit.random_target if y == 0
      else
         opponents_unit.random_target
      end
    when 2
      if rand(2) == 0
        opponents_unit.random_target
      else
        friends_unit.random_target
      end
    else
      friends_unit.random_target
    end
  end
  #--------------------------------------------------------------------------
  # ● 目标为敌人
  #--------------------------------------------------------------------------
  def targets_for_opponents
    if item.for_random?
      @cc = Array.new
      @bb = Array.new
      case opponents_unit.alive_members.size
      when 6
        @bb[0] = opponents_unit.alive_members[0]
        @bb[1] = opponents_unit.alive_members[1]
        @bb[2] = opponents_unit.alive_members[2]
        @bb[3] = opponents_unit.alive_members[3]
        @bb[4] = opponents_unit.alive_members[4]
        @bb[5] = opponents_unit.alive_members[5]
      when 5
        @bb[0] = opponents_unit.alive_members[0]
        @bb[1] = opponents_unit.alive_members[1]
        @bb[2] = opponents_unit.alive_members[2]
        @bb[3] = opponents_unit.alive_members[3]
        @bb[4] = opponents_unit.alive_members[4]
      when 4
        @bb[0] = opponents_unit.alive_members[0]
        @bb[1] = opponents_unit.alive_members[1]
        @bb[2] = opponents_unit.alive_members[2]
        @bb[3] = opponents_unit.alive_members[3]
      when 3
        @bb[0] = opponents_unit.alive_members[0]
        @bb[1] = opponents_unit.alive_members[1]
        @bb[2] = opponents_unit.alive_members[2]
      when 2
        @bb[0] = opponents_unit.alive_members[0]
        @bb[1] = opponents_unit.alive_members[1]
      when 1
        @bb[0] = opponents_unit.alive_members[0]
      end
      #判断随机敌人个数，增加一个删除一个。
      isum=0
      for i in 0..item.number_of_targets - 1
        b=rand(@bb.length)
        @cc[isum]=@bb[b]
        @bb.delete_at(b)
        isum=isum+1;
      end
      return @cc
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @random_icon == 1
         @random_icon = 0
          rint = rand(300)
          rint = rand(250)  if $game_switches[700] == true
          rint = rand(500)  if $game_variables[309] < 0
        #如果用策略AI，打智力最低的人，判断策免计
        if  @subject.int > rint
          r = 1
          r = 27  if item.id == 180
          r = 28  if item.id == 181
          r = 29  if item.id == 182

          # totest 选出对方队伍中智力最低且不含有策免的人
          _target = opponents_unit.members.select{|m| m.mrf <= 0 && !m.state?(r) && !m.state?(22) }.sort{|a,b| a.int <=> b.int }.first
          _target = opponents_unit.members.select{|m| m.hp < m.mhp*0.35 }.sort{|a,b| a.hp <=> b.hp }.first if item.id == 190

          if _target
            [opponents_unit.smooth_target(_target.index)] * 1
          else
            [opponents_unit.random_target] * 1
          end
        else
          [opponents_unit.random_target] * 1
        end
      else
        if @target_index < 0
            _target2 = opponents_unit.members.select{|m| !m.state?(24) and !m.state?(25) }.sort{|a,b| a.hp <=> b.hp }.first
            randdd = rand(100)
            randdd = rand(50) if $game_variables[309] > 0 
            if item and item.is_atk? and 25 > randdd and _target2 and $game_switches[700] == true
               [opponents_unit.smooth_target(_target2.index)] * 1
            else
               [opponents_unit.random_target] * 1
            end
        else
          [opponents_unit.smooth_target(@target_index)] * 1#num
        end
      end
    else
      opponents_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # ● 目标为队友
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        if @random_icon == 1 #and !@subject.actor? and item.is_hp_recover_marv?
           @random_icon = 0
          #如果是回复性计策，或者保护性计策，给少血最多的人加(设置AI)
          if ( item.is_hp_recover_marv? or item.is_defend_marv? ) and item.id != 194
            r = 1
            r = 43  if item.id == 183
            r = 24  if item.id == 202
            r = 25  if item.id == 203
            r = 23  if item.id == 204
            r = 22  if item.id == 205
            r = 50  if item.id == 210
            r = 51  if item.id == 213
            if item.is_hp_recover_marv?
               _target11 = friends_unit.members.select{|m| !m.equip_wtype_ok?(35) and m.hp > 0 and m.hp < m.mhp}.sort{|a,b| (a.mhp-a.hp) <=> (b.mhp-b.hp) }.last
            else
               _target11 = friends_unit.members.select{|m| !m.state?(r) and m.hp > 0 }.sort{|a,b| a.hp <=> b.hp }.first
            end   

            if _target11
               [friends_unit.smooth_target(_target11.index)] * 1
            else
               [friends_unit.random_target] * 1
            end

          #如果是武力BUFF计策(斗击倍击计)
          elsif item.id == 207 or item.id == 212
            b = []
            c = 0
            r = 46  if item.id == 207
            r = 45  if item.id == 212
            #只给武将+,如果目标武将已经有这个状态了。那换一个，如果全有了。那就给第一个活着的人+。
            for i in 0...friends_unit.members.size
              if friends_unit.members[i].str > 155 and !friends_unit.members[i].state?(r)
                b[c] = i
                c += 1
              end
            end
            if c > 0
              @target_index = b[rand(c)]
            else
              @target_index = 0
            end
            [friends_unit.smooth_target(@target_index)] * 1
          elsif item.id == 194
             _target = friends_unit.members.select{|m| m.mp < m.mmp and m.hp > 0 }.sort{|a,b| a.mp <=> b.mp }.first
            if _target
               [friends_unit.smooth_target(_target.index)] * 1
            else
               [friends_unit.random_target] * 1
            end
          #如果是智力BUFF计策(增策计，准策计)
          elsif item.id == 186 or item.id == 201
            b = []
            c = 0
            r = 38  if item.id == 186
            r = 39  if item.id == 201
            #只给智将领+,如果目标武将已经有这个状态了。那换一个，如果全有了。那就给第一个活着的人+。
            for i in 0...friends_unit.members.size
              if friends_unit.members[i].int > 170 and !friends_unit.members[i].state?(r)
                b[c] = i
                c += 1
              end
            end
            if c > 0
              @target_index = b[rand(c)]
            else
              @target_index = 0
            end
            [friends_unit.smooth_target(@target_index)] * 1

          #解策计，只给有异常状态的人解除。
          elsif item.id == 199
            b = 0
            for i in 0...friends_unit.members.size
              if friends_unit.members[i].check_state?
               b = i
              end
            end
            @target_index = b
            [friends_unit.smooth_target(@target_index)] * 1
          else  
            [friends_unit.random_target] * 1#num
          end
        else
          if @target_index < 0
            [friends_unit.random_target] * 1#num
          else
            [friends_unit.smooth_target(@target_index)] * 1#num
          end
        end
      else
            friends_unit.alive_members
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 行动的价值评价（自动战斗用）
  #    自动设置 @value 和 @target_index 。
  #--------------------------------------------------------------------------
  def evaluate
    @value = 0
    evaluate_item if valid?
    @value += rand if @value > 0
    self
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的评价
  #--------------------------------------------------------------------------
  def evaluate_item
    item_target_candidates.each do |target|
      value = evaluate_item_with_target(target)
      if item.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取技能／使用物品的候选目标
  #--------------------------------------------------------------------------
  def item_target_candidates
    if item.for_opponent?
      opponents_unit.alive_members
    elsif item.for_user?
      [subject]
    elsif item.for_dead_friend?
      friends_unit.dead_members
    else
      friends_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的评价（对指定目标）
  #--------------------------------------------------------------------------
  def evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if item.for_opponent?
      return target.result.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.result.hp_damage, target.mhp - target.hp].min
      return recovery.to_f / target.mhp
    end
  end
end
