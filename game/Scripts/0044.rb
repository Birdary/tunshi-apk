#encoding:utf-8
#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　管理敌人的类。本类在 Game_Troop 类 ($game_troop) 的内部使用。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 敌群内的索引
  attr_reader   :enemy_id                 # 敌人 ID
  attr_reader   :original_name            # 原名
  attr_accessor :letter                   # 名字后附加的字母
  attr_accessor :plural                   # 复数出现的标志
  attr_accessor :screen_x                 # 战斗画面 X 坐标
  attr_accessor :screen_y                 # 战斗画面 Y 坐标
  attr_reader   :dp                       # 敌人战气值
  attr_accessor :over_damage              # 敌人伤害输出统计
  attr_accessor :over_sup                 # 敌人辅助统计
  attr_accessor :target_most              # 被集火标记
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = mhp
    @mp = mmp
    @dp = 0
    @over_damage = 0
    @over_sup = 0
    @target_most = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人英文名
  #--------------------------------------------------------------------------
  def ename
    NAMEHASH::TABLE[self.name]
  end
  #--------------------------------------------------------------------------
  # ● 设置敌人的战气值
  #--------------------------------------------------------------------------
  def dp=(dp)
      @dp = dp
      @dp = [[@dp, 30].min, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人 ID 
  #--------------------------------------------------------------------------
  def id
    @enemy_id
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敌人
  #--------------------------------------------------------------------------
  def enemy?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 获取队友单位
  #--------------------------------------------------------------------------
  def friends_unit
    $game_troop
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人单位
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_party
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人实例
  #--------------------------------------------------------------------------
  def enemy
    $data_enemies[@enemy_id]
  end
  #--------------------------------------------------------------------------
  # ● 以数组方式获取拥有特性所有实例
  #--------------------------------------------------------------------------
  def feature_objects
    super + [enemy]
  end
  #--------------------------------------------------------------------------
  # ● 获取显示名称
  #--------------------------------------------------------------------------
  def name
    # 去掉后缀
     #@original_name + (@plural ? letter : "")
    @original_name
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的基础值
  #--------------------------------------------------------------------------
  def param_base(param_id)
    enemy.params[param_id]
  end
  #--------------------------------------------------------------------------
  # ● 获取击杀敌人可以获得的击破数
  #--------------------------------------------------------------------------
  def d_size
      a = 1
      a = 10 unless self.equip_wtype_ok?(12) or self.equip_wtype_ok?(33) or self.id == 604
      return a
  end
  #--------------------------------------------------------------------------
  # ● 获取经验值
  #--------------------------------------------------------------------------
  def exp
    if $game_switches[381] == true
      a = enemy.exp
    else
      a = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取金钱
  #--------------------------------------------------------------------------
  def gold
    enemy.gold
  end
  #--------------------------------------------------------------------------
  # ● 生成物品数组
  #--------------------------------------------------------------------------
  def make_drop_items
    #return [] if $game_switches[381] == false
    _drate = 1
    # 盗贼
    _drate -= 0.25  if $add_gold_item == 1
    # 传说
    _drate -= 0.25  if $game_variables[309] > 0
    # 试炼
    _drate *= 0.5   if $game_switches[743] == true

    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator * _drate < drop_item_rate
         r.push(item_object(di.kind, di.data_id))
      else
         r
      end 
    end

  end
  #--------------------------------------------------------------------------
  # ● 获取物品掉率的倍率
  #--------------------------------------------------------------------------
  def drop_item_rate
    $game_party.drop_item_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # ● 获取物品实例
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 是否使用精灵
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗画面 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end

  #==========================================================================
  # 定义角色战斗图 X 坐标
  #==========================================================================
  def screen_x
    @index.nil? ? 0 : BattlerPos::ENEMY_X[@index] + @change_x
  end 
  #========================================================================
  # 定义角色战斗图 Y 坐标
  #========================================================================
  def screen_y
    @index.nil? ? 0 : BattlerPos::ENEMY_Y[@index]
  end 

  #--------------------------------------------------------------------------
  # ● 执行伤害效果
  #--------------------------------------------------------------------------
  def perform_damage_effect
    @sprite_effect_type = :blink
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # ● 执行人物倒下的效果
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    case collapse_type
    when 0
      @sprite_effect_type = :collapse
      Sound.play_enemy_collapse
    when 1
      @sprite_effect_type = :boss_collapse
      Sound.play_boss_collapse1
    when 2
      @sprite_effect_type = :instant_collapse
    end
  end
  #--------------------------------------------------------------------------
  # ● 变身
  #--------------------------------------------------------------------------
  def transform(enemy_id)
      old_enemy = enemy
      @enemy_id = enemy_id
      if enemy.name != @original_name
         @original_name = enemy.name
         @letter = ""
         @plural = false
      end
         @battler_name = enemy.battler_name
         @battler_hue = enemy.battler_hue
      #继承原来武将的掉落，防止出现第一张掉落第七章物品的现象
      if $game_switches[700] == true and $game_troop.troop.name[0,1] == "S"
         enemy.drop_items.clear
         enemy.drop_items += old_enemy.drop_items
      end
      refresh
      make_actions unless @actions.empty?
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    method_table = {
      1 => :conditions_met_turns?,
      2 => :conditions_met_hp?,
      3 => :conditions_met_mp?,
      4 => :conditions_met_state?,
      5 => :conditions_met_party_level?,
      6 => :conditions_met_switch?,
    }
    method_name = method_table[action.condition_type]
    if method_name
      send(method_name, action.condition_param1, action.condition_param2)
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“回合数”
  #--------------------------------------------------------------------------
  def conditions_met_turns?(param1, param2)
    n = $game_troop.turn_count
    if param2 == 0
      n == param1
    else
      n > 0 && n >= param1 && n % param2 == param1 % param2
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“HP”
  #--------------------------------------------------------------------------
  def conditions_met_hp?(param1, param2)
    hp_rate >= param1 && hp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“MP”
  #--------------------------------------------------------------------------
  def conditions_met_mp?(param1, param2)
    mp_rate >= param1 && mp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“状态”
  #--------------------------------------------------------------------------
  def conditions_met_state?(param1, param2)
    state?(param1)
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“队伍等级”
  #--------------------------------------------------------------------------
  def conditions_met_party_level?(param1, param2)
    $game_party.highest_level >= param1
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“开关”
  #--------------------------------------------------------------------------
  def conditions_met_switch?(param1, param2)
    $game_switches[param1]
  end
  #--------------------------------------------------------------------------
  # ● 判定在当前状況下战斗行动是否有效
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def action_valid?(action)
    conditions_met?(action) && usable?($data_skills[action.skill_id])
  end
  #--------------------------------------------------------------------------
  # ● 随机选择战斗行动
  #     action_list : RPG::Enemy::Action 的数组
  #     rating_zero : 作为零值的标准
  #--------------------------------------------------------------------------
  def select_enemy_action(action_list, rating_zero)
    sum = action_list.inject(0) {|r, a| r += a.rating - rating_zero }
    return nil if sum <= 0
    value = rand(sum)
    if self.state?(27) or self.state?(117) #疑心计 50%几率不行动。
       return nil if 60 > rand(100)
    end
    if self.state?(40) or self.state?(41)
       return nil if self.state?(28)
       return nil if self.state?(29)
    end

    action_list.each do |action|
      return action if value < action.rating - rating_zero
      value -= action.rating - rating_zero
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗行动(作弊AI)
  #--------------------------------------------------------------------------
  def make_ai_actions
      return false if $game_switches[700] == false or !self.movable? or self.confusion? or self.state?(97) or self.state?(41)
      skill_id = 0

      # 使用解阵计
      if $game_party.formation.id != 4 and self.mp > self.mhp * 0.15
         if self.int > 200 and self.mp >= 100 
            lv = 10
            fid = $game_party.formation.id
            lv = 15  if fid == 12 or fid == 13 or fid == 15 or fid == 19
            skill_id = 198 if  lv > rand(100) 
         end   
      end  

      # 被集火进行防御
      if self.target_most > ($game_party.al.size * 0.5) and $game_party.al.size > 3 and !self.state?(2)
         skill_id = 2 if self.hp > self.mhp * 0.2 and rand(100) > 50
      end   

      # 自行加血
      if self.hp < self.mhp * 0.5 and self.int > rand(500) and $game_troop.alive_members.size > 1 
         lv = $game_variables[121]
         if      lv > 40 and self.mp >= 150 
                 skill_id = 145
         elsif   lv > 30 and self.mp >= 100 
                 skill_id = 143   
         elsif   lv > 20 and self.mp >= 75 
                 skill_id = 141   
         elsif   lv > 10 and self.mp >= 40  
                 skill_id = 139 
         elsif   self.mp >= 25   
                 skill_id = 137
         end        
      end  



      if skill_id > 0
         @actions.each do |action| ; action.set_skill(skill_id) ; end
         return true
      else
         return false
      end
  end  
  #--------------------------------------------------------------------------
  # ● 生成战斗行动
  #--------------------------------------------------------------------------
  def make_actions
    super
    return if @actions.empty?
    return if make_ai_actions
    as = []
    as = Array.new(enemy.actions)
    
    hp_add = 0
    have_str = 0
    have_int = 0
    have_sow = 0
    have_defend = 0
    have_dead = 0
    hp25 = 0
    needsp = 0
    action_formation = 0

    for i in 0...$game_troop.alive_members.size
      enemy_ = $game_troop.alive_members[i]
      hp_add = 1      if enemy_.mhp != $game_troop.alive_members[i].hp
      have_str = 1    if enemy_.str > 155
      have_int = 1    if enemy_.int > 170
      have_sow = 1    if enemy_.check_state?
      have_defend = 1 if enemy_.mrf > 0 or enemy_.cnt > 0
      needsp = 1      if enemy_.mp < enemy_.mmp * 0.35
      action_formation = 1      if enemy_.state?(264)
    end
    for i in 0...$game_troop.members.size
       have_dead = 1  if $game_troop.members[i].hp == 0 
       if  $game_troop.members[i].state?(265)
           have_dead = 0 
           break
       end 
    end   
    for i in 0...$game_party.alive_members.size
       hp25 = 1  if $game_party.alive_members[i].state?(233)
    end

    # 决斗状态删除回复计策
    if self.state?(57)
       hp_add = 0
    end
    #如果敌人已经存在阵型了，那么不会使用其他阵法,如果是总大将则要全部存活
    if $game_troop.formation.id != 4 or !self.unit.can_use_formation_start? or self.state?(53) or action_formation == 1 
       as.delete_if { |a| (a.skill_id > 4 and a.skill_id <= 20 ) }
    end

    #如果我军不存在阵型，敌人就不会用解阵计。
    if $game_party.formation.id == 4
       as.delete_if { |a| (a.skill_id == 198) }
    end
    #如果对方没有武将HP小于30%删除暗杀计
    if hp25 == 0
       as.delete_if { |a| (a.skill_id == 190) }
    end
    #如果队友没有人SP低于35%，删除复策计
    if needsp == 0
       as.delete_if { |a| (a.skill_id == 194) }
    end
    #如果对方没有武将死亡，绝对不会使用招魂计
    if have_dead == 0
       as.delete_if { |a| (a.skill_id == 200) }
    end
    #如果对方有策免等保护状态，才会使用消除计策。
    if have_defend == 0
       as.delete_if { |a| (a.skill_id == 179) }
    end
    #如果没有武将，不使用斗击计，倍击。
    if have_str == 0
       as.delete_if { |a| ((a.skill_id == 207) or (a.skill_id == 212) ) }
    end
    #如果没有智将，不使用强策计，准策。
    if have_int == 0
       as.delete_if { |a| ((a.skill_id == 201) or (a.skill_id == 186) ) }
    end
    #如果没有武将异常状态，绝不会使用解策计
    if have_sow == 0
       as.delete_if { |a| (a.skill_id == 199) }
    end

    if self.state?(40)  #限击计，从可选技能列表里删除id = 1的
      as.delete_if { |a| (a.skill_id == 1) }
      as.delete_if { |a| (a.skill_id >=456 and a.skill_id <= 600)} if self.dp < 10
      as.delete_if { |a| ((a.skill_id >=53 and a.skill_id <= 167) or (a.skill_id >=174 and a.skill_id <= 215)) }  if self.state?(41)
      as.delete_if { |a| (a.skill_id >=137 and a.skill_id <= 146)} if hp_add == 0
      #action_list = as.select {|a| action_valid?(a) }
    elsif self.state?(41)  #限策计，从可选技能列表里删除策略id的
      as.delete_if { |a| (a.skill_id == 1) }  if self.state?(40)
      as.delete_if { |a| (a.skill_id >=456 and a.skill_id <= 600)} if self.dp < 10
      as.delete_if { |a| ((a.skill_id >=53 and a.skill_id <= 167) or (a.skill_id >=174 and a.skill_id <= 215)) }
      #action_list = as.select {|a| action_valid?(a) }
    elsif self.dp < 10  #敌人没有战气状态的话，从可选技能列表里删除技能id的
      as.delete_if { |a| (a.skill_id == 1) }  if self.state?(40)
      as.delete_if { |a| ((a.skill_id >=53 and a.skill_id <= 167) or (a.skill_id >=174 and a.skill_id <= 215)) }  if self.state?(41)
      as.delete_if { |a| (a.skill_id >=456 and a.skill_id <= 600)}
      as.delete_if { |a| (a.skill_id >=137 and a.skill_id <= 146)} if hp_add == 0
      #action_list = as.select {|a| action_valid?(a) }
    elsif hp_add == 0
      as.delete_if { |a| (a.skill_id >=137 and a.skill_id <= 146) }
      #action_list = as.select {|a| action_valid?(a) }
    end

    action_list = as.select {|a| action_valid?(a) }

    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    @actions.each do |action|
       act = select_enemy_action(action_list, rating_zero)
       action.set_enemy_action(act)
       if act != nil
       if act.skill_id >= 5 and act.skill_id <= 20 and self.hp > 0 
          self.add_state_must(264) 
       end
       if act.skill_id == 200 and self.hp > 0 
          self.add_state_must(265) 
       end
       end
    end
  end
end
