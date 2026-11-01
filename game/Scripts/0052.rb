#encoding:utf-8
#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　管理角色的类。
#   本类在 Game_Actors 类 ($game_actors) 的内部使用。
#   具体使用请查看 Game_Party 类 ($game_party) 。
#==============================================================================

class Game_Actor < Game_Battler
  MAX_AP = 100
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :name                     # 名字
  attr_accessor :nickname                 # 称号
  attr_reader   :character_name           # 行走图文件名
  attr_reader   :character_index          # 行走图索引
  attr_reader   :face_name                # 肖像文件名
  attr_reader   :face_index               # 肖像索引
  attr_reader   :class_id                 # 职业 ID
  attr_reader   :level                    # 等级
  attr_reader   :action_input_index       # 输入中的战斗行动编号
  attr_reader   :last_skill               # 光标记忆用 : 技能 & 道具

  attr_accessor :ap                       # ap 暂时没用

  attr_accessor :attack_count             # 武力攻击次数
  attr_accessor :skill_count              # 技能使用次数
  attr_accessor :marv_count               # 计策使用次数
  attr_accessor :formation_count          # 阵型使用次数
  attr_accessor :guard_count              # 防御使用次数
  attr_accessor :item_count               # 道具使用次数
  attr_accessor :action_list              # 记角色行动历史 [ item_id,item_id ]
  attr_accessor :atk_damage_count
  attr_accessor :over_damage              # 记角色战斗中造成的总伤害
  attr_accessor :over_damage_all
  attr_accessor :over_sup
  attr_accessor :over_sup_all
  attr_accessor :kill_size
  attr_accessor :kill_size_all
  attr_accessor :dead_size
  attr_accessor :dead_size_all

  def atk
    if weapons.first.nil?
      _atk = 0
    else
      # - 1 是为了减去数据库默认的1
      # _atk = weapons.first.atk
      _atk = super - 1
      
      # 关索的被动技能 - 装备的武器基础攻击力获得8%的提升
      _atk = ((_atk * 1.08).round).to_i if self.id == 14 && $game_party.exist_bskill?(14,269)
    
      _atk += 12  if $game_party.exist_jm_skill?(649) and self.actor?
      _atk += 20  if $game_party.exist_jm_skill?(616) and self.actor? and self.id == $game_variables[100]
    end
    _atk
  end

  def armors_atk
    armors.empty? ? 0 : armors.map{|a|a.nil? ? 0 : a.def}.inject{|a,b|a+b}
  end

  def def
    _def = super - 1

    # 【废弃】刘备被动技能 - 刘备在场时我方战场武将全体防御力+10%
    #_def = (_def * 1.1).to_i if $game_party.exist_bskill?(2,237)
    # 黄盖防御力 +12%
    _def = ((_def * 1.12).round).to_i if $game_party.exist_bskill?(92,396) && self.id == 92
    # 关平的被动
    _def += (self.atk * 0.3).to_i  if self.id == 12 && $game_party.exist_bskill?(12,263)

    _def += 5  if $game_party.exist_jm_skill?(650) and self.actor?

    _def += 10  if $game_party.exist_jm_skill?(601) and self.actor? and  self.id > 1 and self.id < 5

    _def += 20  if $game_party.exist_jm_skill?(616) and self.actor? and  self.id == $game_variables[100]
    
    _def
  end

  def weapon_atk
    weapons.first.atk
  end

  def cri
    _cri = super
    # 赵云被动技能 - 赵云的暴击，回避，速度，命中提升10%
    _cri += 0.1   if self.id == 5 and  $game_party.exist_bskill?(5,246) and self.actor?
    _cri += 0.05  if $game_party.exist_bskill?(9,423) and self.actor?#龙渊被动
    _cri += 0.05  if $game_party.exist_jm_skill?(662) and self.actor? and ( self.id == 6 or self.id == 17 ) #师徒军师技
    _cri += 0.15  if $game_party.exist_jm_skill?(646) and self.actor?

    _cri
  end

  def agi
    _agi = super

    # 星彩 莲华状态
    _agi = 255 if _agi < 255 and self.id == 18 and self.state?(125)

    _agi
  end

  def eva
    _eva = super 
    # 赵云被动技能 - 赵云的暴击，回避，速度，命中提升3%
    _eva += 0.1 if self.id == 5 && $game_party.exist_bskill?(5,246)
    # 月英被动技能 - 月英获得12%的回避率提升
    _eva += 0.17 if self.id == 27 && $game_party.exist_bskill?(27,302)
    # 月英被动技能 - 月英获得12%的回避率提升
    _eva += 0.15  if self.id == 27 && $game_party.exist_bskill?(27,302)
    _eva += 0.05  if $game_party.exist_bskill?(9,423) and self.actor? #龙渊被动
    _eva += 0.05  if $game_party.exist_jm_skill?(662) and self.actor? and ( self.id == 6 or self.id == 17 )
    _eva += 0.07  if $game_party.exist_jm_skill?(644) and self.actor?
    
    _eva
  end

  def hit
    _hit = super 
    # 赵云被动技能 - 赵云的暴击，回避，速度，命中提升10%
    _hit += 0.1 if self.id == 5 && $game_party.exist_bskill?(5,246)
    _hit += 0.05  if $game_party.exist_bskill?(9,423) and self.actor? #龙渊被动
    # 黄忠被动技能 - 战斗中，黄忠的普通攻击命中率+22%
    _hit += 0.22 if self.id == 7 && $game_party.exist_bskill?(7,252)

    _hit += 0.12 if $game_party.exist_jm_skill?(643) and self.actor?

    _hit += 0.2 if $game_party.exist_jm_skill?(619) and self.actor? and ( self.id == 35 or self.id == 36 )
    _hit += 0.05  if $game_party.exist_jm_skill?(662) and self.actor? and ( self.id == 6 or self.id == 17 )
    _hit
  end

  def level
    @level
  end

  def level_s
    "LV #{@level}"
  end

  def init_tp
       #吕布军师
       self.tp = 100 if self.id == $game_variables[100] && $game_party.exist_jm_skill?(613)
      super
  end
  #--------------------------------------------------------------------------
  # ● 获取角色英文名
  #--------------------------------------------------------------------------
  def ename
    NAMEHASH::TABLE[self.name]
  end
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill = Game_BaseItem.new
    @ap = 0
    @over_damage_all = 0 #if @over_damage_all == nil
    @over_sup_all = 0    #if @over_sup_all == nil
    @kill_size_all = 0  # if @kill_size_all == nil
    @dead_size_all = 0   #if @dead_size_all == nil
    clear_count
  end

  def clear_count
      @attack_count = 0
      @skill_count = 0
      @marv_count = 0
      @formation_count = 0
      @guard_count = 0
      @item_count = 0
      @action_list = []
      @atk_damage_count = 0
      @over_damage = 0
      @over_sup = 0
      @dead_size = 0
      @kill_size = 0 
  end
  #==========================================================================
  # 定义角色战斗图 X 坐标
  #==========================================================================
  def screen_x
    return 0 if self.index.nil?
    return -100 if self.index > 4
    self.index.nil? ? 0 : BattlerPos::ACTOR_X[self.index]  + @change_x
  end 
  #========================================================================
  # 定义角色战斗图 Y 坐标
  #========================================================================
  def screen_y
    self.index.nil? ? 0 : BattlerPos::ACTOR_Y[self.index]
  end 
  #========================================================================
  # 定义角色战斗图 Z 坐标
  #========================================================================
  def screen_z
    return 100
  end 
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @actor_id = actor_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = actor.initial_level
    @exp = {}
    @equips = []
    @battler_name = actor.class_id.to_s
    init_exp
    init_skills
    init_equips(actor.equips)
    clear_param_plus
    recover_all
  end

  def setup_2nd(actor_id)
    @actor_id = actor_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = 1
    @exp = {}
    @equips = []
    @battler_name = actor.class_id.to_s
    init_exp
    init_skills
    init_equips($data_actors[1].equips)
    clear_param_plus
    recover_all
  end
  #--------------------------------------------------------------------------
  # ● 获取角色实例
  #--------------------------------------------------------------------------
  def actor
    $data_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # ● 初始化图像
  #--------------------------------------------------------------------------
  def init_graphics
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
  end
  #--------------------------------------------------------------------------
  # ● 达到指定等级需要累积的经验值
  #--------------------------------------------------------------------------
  def exp_for_level(level)
    self.class.exp_for_level(level)
  end
  #--------------------------------------------------------------------------
  # ● 初始化经验值
  #--------------------------------------------------------------------------
  def init_exp
    @exp[@class_id] = current_level_exp
  end
  #--------------------------------------------------------------------------
  # ● 获取经验值
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 获取当前等级的最低经验值
  #--------------------------------------------------------------------------
  def current_level_exp
    exp_for_level(@level)
  end
  #--------------------------------------------------------------------------
  # ● 获取下一个等级的经验值
  #--------------------------------------------------------------------------
  def next_level_exp
    exp_for_level(@level + 1)
  end
  #--------------------------------------------------------------------------
  # ● 最大等级
  #--------------------------------------------------------------------------
  def max_level
    #return 50
    actor.max_level
  end
  #--------------------------------------------------------------------------
  # ● 判定是否达到最大等级
  #--------------------------------------------------------------------------
  def max_level?
    @level >= max_level
  end
  #--------------------------------------------------------------------------
  # ● 判定是否达到当前训练最大等级
  #--------------------------------------------------------------------------
  def max_x_level?
    @level >= $game_variables[223]
  end
  #--------------------------------------------------------------------------
  # ● 初始化技能
  #--------------------------------------------------------------------------
  def init_skills
    @skills = []
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level
    end
  end
  #--------------------------------------------------------------------------
  # ● 初始化装备
  #     equips : 初期装备的数组
  #--------------------------------------------------------------------------
  def init_equips(equips)
    @equips = Array.new(equip_slots.size) { Game_BaseItem.new }
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 将索引变换为装备类型
  #--------------------------------------------------------------------------
  def index_to_etype_id(index)
    index == 1 && dual_wield? ? 0 : index
  end
  #--------------------------------------------------------------------------
  # ● 将装备类型变换为装备栏 ID 的列表
  #--------------------------------------------------------------------------
  def slot_list(etype_id)
    result = []
    equip_slots.each_with_index {|e, i| result.push(i) if e == etype_id }
    result
  end
  #--------------------------------------------------------------------------
  # ● 将装备类型变换为装备栏 ID（优先返回空的装备栏）
  #--------------------------------------------------------------------------
  def empty_slot(etype_id)
    list = slot_list(etype_id)
    list.find {|i| @equips[i].is_nil? } || list[0]
  end
  #--------------------------------------------------------------------------
  # ● 获取装备栏的数组
  #--------------------------------------------------------------------------
  def equip_slots
    return [0,0,2,3,4] if dual_wield?       # 双持武器
   # return [0,0,2,3,4] if self.id == 12
    return [0,1,2,3,4]                      # 普通
  end
  #--------------------------------------------------------------------------
  # ● 获取武器实例的数组
  #--------------------------------------------------------------------------
  def weapons
    @equips.select {|item| item.is_weapon? }.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 获取武器实例
  #--------------------------------------------------------------------------
  def weapon
    weapons.first
  end

  #--------------------------------------------------------------------------
  # ● 获取护甲实例的数组
  #--------------------------------------------------------------------------
  def armors
    @equips.select {|item| item.is_armor? }.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 获取装备实例的数组
  #--------------------------------------------------------------------------
  def equips
    @equips.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以更换装备
  #     slot_id : 装备栏 ID
  #--------------------------------------------------------------------------
  def equip_change_ok?(slot_id)
    return false if equip_type_fixed?(equip_slots[slot_id])
    return false if equip_type_sealed?(equip_slots[slot_id])
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更换装备
  #     slot_id : 装备栏 ID
  #     item    : 武器／护甲（为 nil 时装备解除）
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 强制更换装备
  #     slot_id : 装备栏 ID
  #     item    : 武器／护甲（为 nil 时装备解除）
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    @equips[slot_id].object = item
    release_unequippable_items(false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 交换物品
  #     new_item : 取出的物品
  #     old_item : 放入的物品
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更换装备（用 ID 指定）
  #     slot_id : 装备栏 ID
  #     item_id : 武器／护甲 ID
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)

    if equip_slots[slot_id] == 0
       #change_equip(slot_id, $data_weapons[item_id])
       trade_item_with_party($data_weapons[item_id], equips[slot_id])
       force_change_equip(slot_id, $data_weapons[item_id])
    else
       trade_item_with_party($data_armors[item_id], equips[slot_id])
       force_change_equip(slot_id, $data_armors[item_id])
       #change_equip(slot_id, $data_armors[item_id])
    end

  end
  #--------------------------------------------------------------------------
  # ● 丢弃装备
  #     item : 丢弃的武器／护甲
  #--------------------------------------------------------------------------
  def discard_equip(item)
    slot_id = equips.index(item)
    @equips[slot_id].object = nil if slot_id
  end
  #--------------------------------------------------------------------------
  # ● 卸下无法装备的物品
  #     item_gain : 卸下的装备是否保留
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    @equips.each_with_index do |item, i|
      if !equippable?(item.object) || item.object.etype_id != equip_slots[i]
        trade_item_with_party(nil, item.object) if item_gain
        item.object = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 卸下全部装备
  #--------------------------------------------------------------------------
  def clear_equipments
    equip_slots.size.times do |i|
      change_equip(i, nil) if equip_change_ok?(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 装备上最强装备
  #--------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = $game_party.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否装备技能所需要的所有必要武器装备
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    return true if wtype_id1 == 0 && wtype_id2 == 0
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 是否装备着特定类型的武器装备
  #--------------------------------------------------------------------------
  def wtype_equipped?(wtype_id)
    weapons.any? {|weapon| weapon.wtype_id == wtype_id }
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    release_unequippable_items
    super
  end
  #--------------------------------------------------------------------------
  # ● 判定是否队友
  #--------------------------------------------------------------------------
  def actor?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 获取队友单位
  #--------------------------------------------------------------------------
  def friends_unit
    $game_party
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人单位
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_troop
  end
  #--------------------------------------------------------------------------
  # ● 获取角色 ID 
  #--------------------------------------------------------------------------
  def id
    @actor_id
  end
  #--------------------------------------------------------------------------
  # ● 索引
  #--------------------------------------------------------------------------
  def index
    $game_party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # ● 参战角色判定
  #--------------------------------------------------------------------------
  def battle_member?
    $game_party.battle_members.include?(self)
  end
  #--------------------------------------------------------------------------
  # ● 获取职业实例
  #--------------------------------------------------------------------------
  def class
    $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 获取技能实例的数组
  #--------------------------------------------------------------------------
  def skills
    (@skills | added_skills).sort.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取当前可用的技能的数组
  #--------------------------------------------------------------------------
  def usable_skills
    skills.select {|skill| usable?(skill) }
  end
  #--------------------------------------------------------------------------
  # ● 以数组方式获取拥有特性所有实例
  #--------------------------------------------------------------------------
  def feature_objects
    super + [actor] + [self.class] + equips.compact
  end
  #--------------------------------------------------------------------------
  # ● 获取攻击属性
  #--------------------------------------------------------------------------
  def atk_elements
    set = super
    set |= [1] if weapons.compact.empty?  # 空手：物理属性
    return set
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的最大值
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 9999 if param_id == 0  # MHP
    return super
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的基础值
  #--------------------------------------------------------------------------
  def param_base(param_id)
    self.class.params[param_id, @level]
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的附加值
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    _params = super
    for i in 0...equips.compact.size
      if self.id == 51 and equips.compact[i].class == RPG::Armor and equips.compact[i].id > 320 #蒋琬被动，装备马匹属性x2
        if equips.compact[i].id >= 340 and equips.compact[i].id <= 350 
          _params += equips.compact[i].params[param_id] * 2
        end
      elsif ($game_switches[743] == true or $game_variables[309] > 0) and param_id == 7 #试炼等级记装备削弱
               atk = equips.compact[i].params[param_id]
               case $game_variables[230]
               when 1
                   atk = 20 + (atk*0.05).to_i  if atk > 20
               when 2
                   atk = 32 + (atk*0.05).to_i  if atk > 32
               when 3
                   atk = 45 + (atk*0.05).to_i  if atk > 45
               when 4
                   atk = 65 + (atk*0.05).to_i  if atk > 65
               when 5
                   atk = 95 + (atk*0.05).to_i  if atk > 95
               when 6
                   atk = 130 + (atk*0.05).to_i if atk > 130
               when 7
                   atk = 170 + (atk*0.05).to_i if atk > 170
               end
               _params += atk
      elsif ($game_switches[743] == true or $game_variables[309] > 0) and param_id == 5
               ddf = equips.compact[i].params[param_id]
               case $game_variables[230]
               when 1
                   if i == 2
                      ddf = 15 + (ddf*0.05).to_i  if ddf > 15
                   else  
                      ddf = 8 + (ddf*0.05).to_i  if ddf > 8
                   end 
               when 2
                   if i == 2
                      ddf = 20 + (ddf*0.05).to_i  if ddf > 20
                   else  
                      ddf = 12 + (ddf*0.05).to_i  if ddf > 12
                   end 
               when 3
                   if i == 2
                      ddf = 25 + (ddf*0.05).to_i  if ddf > 25
                   else  
                      ddf = 14 + (ddf*0.05).to_i  if ddf > 14
                   end 
               when 4
                   if i == 2
                      ddf = 32 + (ddf*0.05).to_i  if ddf > 32
                   else  
                      ddf = 20 + (ddf*0.05).to_i  if ddf > 20
                   end 
               when 5
                   if i == 2
                      ddf = 45 + (ddf*0.05).to_i  if ddf > 45
                   else  
                      ddf = 25 + (ddf*0.05).to_i  if ddf > 25
                   end 
               when 6
                   if i == 2
                      ddf = 65 + (ddf*0.05).to_i  if ddf > 65
                   else  
                      ddf = 32 + (ddf*0.05).to_i  if ddf > 32
                   end 
               when 7
                   if i == 2
                      ddf = 80 + (ddf*0.05).to_i  if ddf > 80
                   else  
                      ddf = 45 + (ddf*0.05).to_i  if ddf > 45
                   end 
               end
               _params += ddf
      else
        _params += equips.compact[i].params[param_id]
      end
    end
    return _params
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击的动画 ID
  #--------------------------------------------------------------------------
  def atk_animation_id1
    if dual_wield?
      return weapons[0].animation_id if weapons[0]
      return weapons[1] ? 0 : 1
    else
      return weapons[0] ? weapons[0].animation_id : 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击的动画 ID （双持武器：武器２）
  #--------------------------------------------------------------------------
  def atk_animation_id2
    if dual_wield?
      return weapons[1] ? weapons[1].animation_id : 0
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 经验值变化
  #     show : 等级上升的显示标志
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
  @chp = self.mhp
    @exp[@class_id] = [exp, 0].max
    last_level = @level
    last_skills = skills
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
    display_level_up(skills - last_skills) if show && @level > last_level
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取经验值
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 等级上升
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #--------------------------------------------------------------------------
  # ● 等级下降
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
  #--------------------------------------------------------------------------
  # ● 显示等级上升的信息
  #     new_skills : 学会的新技能的数组
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
      Sound.levelup 
    $game_message.new_page
    #$game_message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
    $game_message.add("\ec[0]" + self.name + "的等级提升为" + "\\c[3]"+ self.level.to_s + "\\c[0]" + "级" + "\ec[0]")
    $game_message.add("\ec[0]" + self.name + "的兵力提升为" + "\\c[3]" + "#{self.mhp}"  + "\\c[0]" + "点"+ "\ec[0]")
    $game_message.add("\ec[0]" + self.name + "的策略提升为" + "\\c[3]" + "#{self.mmp}"  + "\\c[0]" + "点"+ "\ec[0]")
   
    #$game_message.add("\ec[0]" + self.name + "的兵力提升了" + "\\c[3]" + "#{self.mhp - @chp}" + "级"+ "\ec[0]")
    new_skills.each do |skill|
      if skill.is_marv?
         color_code = 11
         $game_message.add("\ec[0]" + self.name + "学会新的计策「" + "\\c[26]" + skill.name + "\ec[0]" + "」")
      elsif skill.is_skill?
         color_code = 25
         $game_message.add("\ec[0]" + self.name + "学会新武将技「" + "\\c[10]" + skill.name + "\ec[0]" + "」")
      elsif skill.is_formation?
         color_code = 31
         $game_message.add("\ec[0]" + self.name + "学会新的兵阵「" + "\\c[30]" + skill.name + "\ec[0]" + "」")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获得经验值（判断经验获取加成）
  #--------------------------------------------------------------------------
  def gain_exp(exp)
    change_exp(self.exp + (exp * final_exp_rate).to_i, true)
  end
  #--------------------------------------------------------------------------
  # ● 计算最终的经验获取加成
  #--------------------------------------------------------------------------
  def final_exp_rate
      exr * (battle_member? ? 1 : reserve_members_exp_rate)
  end
  #--------------------------------------------------------------------------
  # ● 获取不出战成员的经验获取加成
  #--------------------------------------------------------------------------
  def reserve_members_exp_rate
    #$data_system.opt_extra_exp ? 1 : 0
    $data_system.opt_extra_exp ? 1 : 1
  end
  #--------------------------------------------------------------------------
  # ● 等级变化
  #     show : 等级上升显示的标志
  #--------------------------------------------------------------------------
  def change_level(level, show)
    level = [[level, max_level].min, 1].max
    change_exp(exp_for_level(level), show)
  end
  #--------------------------------------------------------------------------
  # ● 领悟技能
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # ● 遗忘技能
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能是否已经学会
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    skill.is_a?(RPG::Skill) && @skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能是否已经学会 传id
  #--------------------------------------------------------------------------
  def skill_is_learn?(skill_id)
    @skills.include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取说明
  #--------------------------------------------------------------------------
  def description
    actor.description
  end
  #--------------------------------------------------------------------------
  # ● 职业变化
  #     keep_exp : 是否保留经验值
  #--------------------------------------------------------------------------
  def change_class(class_id, keep_exp = false)
    @exp[class_id] = exp if keep_exp
    @class_id = class_id
    change_exp(@exp[@class_id] || 0, false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更换图像
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #--------------------------------------------------------------------------
  # ● 是否使用精灵
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 执行伤害效果
  #--------------------------------------------------------------------------
  def perform_damage_effect
    $game_troop.screen.start_shake(5, 5, 10)
    @sprite_effect_type = :blink
    Sound.play_actor_damage
  end
  #--------------------------------------------------------------------------
  # ● 执行人物倒下的效果
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      @sprite_effect_type = :collapse
      Sound.play_actor_collapse
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成自动战斗用的行动候选列表
  #--------------------------------------------------------------------------
  def make_action_list
    list = []
    list.push(Game_Action.new(self).set_attack.evaluate)
    usable_skills.each do |skill|
      list.push(Game_Action.new(self).set_skill(skill.id).evaluate)
    end
    list
  end
  #--------------------------------------------------------------------------
  # ● 生成自动战斗时的战斗行动
  #--------------------------------------------------------------------------
  def make_auto_battle_actions
    @actions.size.times do |i|
      @actions[i] = make_action_list.max {|action| action.value }
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成混乱时的战斗行动
  #--------------------------------------------------------------------------
  def make_confusion_actions
    @actions.size.times do |i|
      @actions[i].set_confusion
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗行动
  #--------------------------------------------------------------------------
  def make_actions
    super
    if auto_battle?
      make_auto_battle_actions
    elsif confusion?
      make_confusion_actions
    end
  end
  #--------------------------------------------------------------------------
  # ● 角色移动一步时的处理
  #--------------------------------------------------------------------------
  def on_player_walk
    @result.clear
    check_floor_effect
    if $game_player.normal_walk?
      turn_end_on_map
      states.each {|state| update_state_steps(state) }
      show_added_states
      show_removed_states
      hushengyan_123_124
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新状态的步数计数
  #--------------------------------------------------------------------------
  def update_state_steps(state)
    if state.remove_by_walking
      if @state_steps[state.id] > 0
         @state_steps[state.id] -= 1 
      end
      remove_state(state.id) if @state_steps[state.id] == 0
    end
  end

  def hushengyan_123_124
    if SceneManager.scene.is_a?(Scene_Map)
       if $game_variables[123] > 1 and self.id == $game_party.members[0].id
          $game_variables[123] -= 1 
       if $game_variables[123] == 1 
          SceneManager.scene.over_100  
       elsif $game_variables[123] > 0 
             SceneManager.scene.refresh_100
        end
     end

       if $game_variables[124] > 1 and self.id == $game_party.members[0].id
          $game_variables[124] -= 1
       if $game_variables[124] == 1  
          SceneManager.scene.over_200 
        elsif $game_variables[124] > 0   
           SceneManager.scene.refresh_200 
       end
       end
    end   
  end
  #--------------------------------------------------------------------------
  # ● 显示被附加的状态
  #--------------------------------------------------------------------------
  def show_added_states
    @result.added_state_objects.each do |state|
      $game_message.add(name + state.message1) unless state.message1.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示被解除的状态
  #--------------------------------------------------------------------------
  def show_removed_states
    @result.removed_state_objects.each do |state|
      $game_message.add(name + state.message4) unless state.message4.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 地图上的多少步等于一回合？
  #--------------------------------------------------------------------------
  def steps_for_turn
    return 99999
  end
  #--------------------------------------------------------------------------
  # ● 地图画面上回合结束的处理
  #--------------------------------------------------------------------------
  def turn_end_on_map
    if $game_party.steps % steps_for_turn == 0
      on_turn_end
      perform_map_damage_effect if @result.hp_damage > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 地形效果判定
  #--------------------------------------------------------------------------
  def check_floor_effect
    execute_floor_damage if $game_player.on_damage_floor?
  end
  #--------------------------------------------------------------------------
  # ● 地形伤害的处理
  #--------------------------------------------------------------------------
  def execute_floor_damage
    damage = (basic_floor_damage * fdr).to_i
   # self.hp -= [damage, max_floor_damage].min
    perform_map_damage_effect if damage > 0
  end
  #--------------------------------------------------------------------------
  # ● 获取地形伤害的基础值
  #--------------------------------------------------------------------------
  def basic_floor_damage
    return 10
  end
  #--------------------------------------------------------------------------
  # ● 获取地形伤害的最大值
  #--------------------------------------------------------------------------
  def max_floor_damage
    $data_system.opt_floor_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 执行地图上的伤害效果
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
    $game_map.screen.start_flash_for_damage
  end
  #--------------------------------------------------------------------------
  # ● 清除战斗行动
  #--------------------------------------------------------------------------
  def clear_actions
    super
    @action_input_index = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取输入中的战斗行动
  #--------------------------------------------------------------------------
  def input
    @actions[@action_input_index]
  end
  #--------------------------------------------------------------------------
  # ● 进行下一个指令输入
  #--------------------------------------------------------------------------
  def next_command
    return false if @action_input_index >= @actions.size - 1
    @action_input_index += 1
    return true
  end
  #--------------------------------------------------------------------------
  # ● 返回下一个指令输入
  #--------------------------------------------------------------------------
  def prior_command
    return false if @action_input_index <= 0
    @action_input_index -= 1
    return true
  end
end
