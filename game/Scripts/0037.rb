#encoding:utf-8
#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　管理队伍的类。保存有金钱及物品的信息。本类的实例请参考 $game_party 。
#==============================================================================

class Game_Party < Game_Unit
  attr_accessor :actors
  #--------------------------------------------------------------------------
  # ● 常量
  #--------------------------------------------------------------------------
  ABILITY_ENCOUNTER_HALF    = 0           # 遇敌几率减半
  ABILITY_ENCOUNTER_NONE    = 1           # 随机遇敌无效
  ABILITY_CANCEL_SURPRISE   = 2           # 敌人偷袭无效
  ABILITY_RAISE_PREEMPTIVE  = 3           # 先制攻击几率上升
  ABILITY_GOLD_DOUBLE       = 4           # 获得金钱数量双倍
  ABILITY_DROP_ITEM_DOUBLE  = 5           # 物品掉落几率双倍
  MAX_MEMBERS = 7                         # 最大成员数
  MAX_MEMBERS_VARIABLE = 99               # 99 号变量控制最大成员数
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :gold                     # 持有金钱
  attr_reader   :steps                    # 步数
  attr_reader   :last_item                # 光标记忆用 : 物品
  attr_accessor :last_actor_index         # 光标位置记忆：角色
  attr_accessor :last_target_index        # 光标位置记忆：目标
  attr_accessor :boost                    # 士气 0-255
  attr_reader   :counsellor               # 军师 GameActor 对象
  attr_accessor :cant_remove_actors       # 不能离队的角色
  attr_accessor :cant_join_actors
  attr_accessor :jm_actor                 # 军师
  attr_accessor :jm_size_max              # 军师天赋点数最大值
  attr_accessor :jm_size                  # 军师天赋点数
  attr_accessor :over_plot_damage         # 剧情伤害
  attr_accessor :expbook                  # 经验书累计
  attr_accessor :score_damage             # 章节评价用，全军总伤害
  attr_accessor :score_sup
  attr_accessor :score_dead
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super
    @gold = 0
    @steps = 0
    @last_item = Game_BaseItem.new
    @menu_actor_id = 0
    @target_actor_id = 0
    @over_plot_damage = 0
    @expbook = 0
    @score_damage = 0
    @score_sup = 0
    @score_dead = 0
    @actors = []
    @actors2 = []
    @boost = 100
    @jm_size = 0
    @jm_size_max = 3
    @counsellor = nil
    @cant_join_actors = []    # => 不能入队的角色
    @cant_remove_actors = [2]  # => 不能离队的角色
    @jm_actor = []  # => 默认的军师
    @initialize_battle_members = []
    init_all_items
  end

  def level_up
    members.each { |actor| actor.level_up }
  end

  def set_counsellor(actor)
    @counsellor = actor
  end

  def set_atk_cmd
    battle_members.each do |member|
      member.input.set_attack  if member.alive? and member.movable? 
    end
  end

  def init_boost
       @boost = 100
       #法正的被动技能 - 法正在场时，队伍初始士气+12
       for i in 0...$game_party.alive_members.size
       @boost += 12  if $game_party.alive_members[i].id == 49 and i < $game_variables[98]
       end
       @boost += 8   if $game_party.exist_jm_skill?(605)
       if $game_switches[700] == true and $game_variables[309] <= 0 
          if $game_switches[743] == true
             #@boost += $game_variables[270]
          else
             @boost += $game_variables[270]
          end
       end  
       @boost= 255 if @boost > 255
  end

  def init_old_param
      $battle_old_param = []
      $battle_old_param[0] = [0,0,0,0,0,0]
      $battle_old_param[1] = [0,0,0,0,0,0]
      $battle_old_param[2] = [0,0,0,0,0,0]
      $battle_old_param[3] = [0,0,0,0,0,0]
      $battle_old_param[4] = [0,0,0,0,0,0]
      $battle_old_param[10] = [0,0,0,0,0,0]
      $battle_old_param[11] = [0,0,0,0,0,0]
      $battle_old_param[12] = [0,0,0,0,0,0]
      $battle_old_param[13] = [0,0,0,0,0,0]
      $battle_old_param[14] = [0,0,0,0,0,0]
      $battle_old_param[15] = [0,0,0,0,0,0]

      for i in 0...$game_party.members.size
          actor = $game_party.members[i]
          a = actor.atk
          b = actor.def
          c = actor.str
          d = actor.ski
          e = actor.int
          f = actor.agi
          if i < $game_variables[98]
             $battle_old_param[i] = [a,b,c,d,e,f]
          end
      end   
      for i in 0...$game_troop.members.size
          enemy = $game_troop.members[i]
          a = enemy.atk
          b = enemy.def
          c = enemy.str
          d = enemy.ski
          e = enemy.int
          f = enemy.agi
          $battle_old_param[i+10] = [a,b,c,d,e,f]
      end  
  end  


  def cost_boost(n)
    @boost -= n
    @boost = ([boost,0].max)#.to_i
  end

  def decr_boost(n)
    @boost -= n
    @boost = ([boost,0].max)#.to_i
  end

  def incr_boost(n)
    @boost += n
    @boost = ([boost,255].min)#.to_i
  end

  def cancel_all_attack
    @members.each do |battler|
      battler.change_x += case battler.formation_pos
        when 0 ; 10
        when 2 ; 8
        when 4 ; 6
      end
    end
  end

  # 全队总hp 默认为5人
  def hp(num=5)
    _hp = 0
    members.select{|n| n.index < num}.each do |_actor|
      _hp += _actor.hp
    end
    _hp
  end

  def mhp(num=5)
    _mhp = 0
    members.select{|n| n.index < num}.each do |_actor|
      _mhp += _actor.mhp
    end
    _mhp = 0 if members.size <= 0
    _mhp
  end

    def mp(num=5)
    _mp = 0
    members.select{|n| n.index < num}.each do |_actor|
      _mp += _actor.mp
    end
    _mp
  end

  def mmp(num=5)
    _mmp = 0
    members.select{|n| n.index < num}.each do |_actor|
      _mmp += _actor.mmp
    end
    _mmp
  end

  alias_method :decr_boost,:cost_boost

  #--------------------------------------------------------------------------
  # ● 初始化所有物品列表
  #--------------------------------------------------------------------------
  def init_all_items
    @items = {}
    @weapons = {}
    @armors = {}
  end
  #--------------------------------------------------------------------------
  # ● 存在判定
  #--------------------------------------------------------------------------
  def exists
    !@actors.empty?
  end
  #--------------------------------------------------------------------------
  # ● 获取成员
  #--------------------------------------------------------------------------
  def house_members
    a = []
    a += @actors2
    b = []
    a.each do |i|
        if @cant_join_actors.include?(i)
           @actors2.delete(i)
           b.push(i)
        end   
    end       
    @actors2 += b
    @actors2.delete_if{|id| $game_actors[id] == nil }.map{|id| $game_actors[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取成员
  #--------------------------------------------------------------------------
  def members
    # in_battle ? @initialize_battle_members : all_members
    in_battle ? battle_members : all_members
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始处理
  #--------------------------------------------------------------------------
  def on_battle_start
      battle_ac_check
      init_boost
      init_old_param
      initialize_battle_members
      @initialize_battle_members.each do |actor|
      actor.change_btm_st :start
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 初始化战斗成员
  #--------------------------------------------------------------------------
  def initialize_battle_members    
    $game_variables[98] = 5 if $game_variables[98] == 0 or $game_variables[98] > 5         
                                                                        #最大战斗人数变量
    @initialize_battle_members = all_members.select {|actor| actor.alive? }[0..($game_variables[98]-1)]
  end
  #--------------------------------------------------------------------------
  # ● 检查角色是否通过修改加入，如果通过修改加入，立刻删除
  #--------------------------------------------------------------------------
  def battle_ac_check
      return if $TEST
      #角色删除
      remove = []
      for i in 0...$game_party.members.size
        actor = $game_party.members[i]
        if !$game_variables[240].include?(actor.id)
           remove << actor.id
        end
        if actor.level > 50 or ( $game_party.members[i].hp > 6000 and actor.id < 207 )
           remove << actor.id
        end
        if $game_party.members[i].mp > 1900 and actor.id < 207 
           remove << actor.id
        end
        if actor.atk > 355 or actor.def > 355
           remove << actor.id
        end
        if actor.str > ($data_classes[actor.id].params[2,actor.level]+100) or \
           actor.ski > ($data_classes[actor.id].params[3,actor.level]+100) or \
           actor.int > ($data_classes[actor.id].params[4,actor.level]+100) or \
           actor.agi > ($data_classes[actor.id].params[6,actor.level]+100) 
           remove << actor.id
        end
      end
      if $game_variables[250][9]  != [9,0,9,0,9,0,9,0]
         remove << 9
         $game_variables[240].delete(9)
         $game_variables[261].delete(9) if $game_variables[261] != 0
      end  
      if $game_variables[250][10] != [1,9,8,5,0,9,1,2]
         remove << 10
         $game_variables[240].delete(10)
         $game_variables[261].delete(10) if $game_variables[261] != 0
      end  
      if $game_variables[250][29] != [2,6,5,2,9,2,0,8]
         remove << 29
         $game_variables[240].delete(29)
         $game_variables[261].delete(29) if $game_variables[261] != 0
      end 
      if $game_variables[250][30] != [1,9,8,7,1,2,0,9] 
         remove << 30
         $game_variables[240].delete(30)
         $game_variables[261].delete(30) if $game_variables[261] != 0
      end 
      if $game_variables[250][40] != [2,7,9,8,4,7,4,4] 
         remove << 40
         $game_variables[240].delete(40)
         $game_variables[261].delete(40) if $game_variables[261] != 0
      end 
      if $game_variables[250][41] != [1,9,8,8,1,2,0,8] 
         remove << 41
         $game_variables[240].delete(41)
         $game_variables[261].delete(41) if $game_variables[261] != 0
      end 
      if $game_variables[250][50] != [6,3,6,3,6,3,6,3] 
         remove << 50 
         $game_variables[240].delete(50)
         $game_variables[261].delete(50) if $game_variables[261] != 0
      end 
      if $game_variables[250][24] != [7,8,7,8,7,8,7,8] 
         remove << 24
         $game_variables[240].delete(24)
         $game_variables[261].delete(24) if $game_variables[261] != 0
      end 
      if $game_variables[250][52] != [1,0,0,0,0,0,0,0] 
         remove << 52
         $game_variables[240].delete(52)
         $game_variables[261].delete(52) if $game_variables[261] != 0
      end 
      if $game_variables[250][63] != [3,3,3,3,3,3,3,3] 
         remove << 63
         $game_variables[240].delete(63)
         $game_variables[261].delete(63) if $game_variables[261] != 0
      end 
      if $game_variables[250][58] != [7,1,7,1,7,1,7,1] 
         remove << 58
         $game_variables[240].delete(58)
         $game_variables[261].delete(58) if $game_variables[261] != 0
      end 
      if $game_variables[250][28] != [5,6,0,5,3,3,7,1] 
         remove << 28
         $game_variables[240].delete(28)
         $game_variables[261].delete(28) if $game_variables[261] != 0
      end 
      if $game_variables[250][64] != [1,6,7,7,5,9,5,3] 
         remove << 64
         $game_variables[240].delete(64)
         $game_variables[261].delete(64) if $game_variables[261] != 0
      end 
      if $game_variables[250][71] != [8,8,3,1,8,6,0,6]
         remove << 71
         $game_variables[240].delete(71)
         $game_variables[261].delete(71) if $game_variables[261] != 0
      end 
      if $game_variables[250][25] != [7,4,7,4,7,4,7,4] 
         remove << 25
         $game_variables[240].delete(25)
         $game_variables[261].delete(25) if $game_variables[261] != 0
      end 
      if $game_variables[250][69] != [6,8,6,8,6,8,6,8]
         remove << 69
         $game_variables[240].delete(69)
         $game_variables[261].delete(69) if $game_variables[261] != 0
      end 
      if $game_variables[250][214] != [7,1,7,1,7,1,7,1] 
         remove << 214
         $game_variables[240].delete(214)
         $game_variables[261].delete(214) if $game_variables[261] != 0
      end 
      if $game_variables[250][215] != [5,1,5,1,5,1,5,1] 
         remove << 215
         $game_variables[240].delete(215)
         $game_variables[261].delete(215) if $game_variables[261] != 0
      end 
      if remove != []
         remove.uniq!
         for i in 0...remove.size
            $game_party.remove_actor_hack(remove[i]) if remove[i] != nil
         end 
 #        $game_party.add_actor(2) if $game_party.members.size < 1 
      end  

      #武将技删除 
      if $game_switches[629] == false #武将技保护开关，部分剧情需要解除检测
         $game_actors[23].forget_skill(330)  unless $game_variables[279].include?(330) 
      for s in 168...174
         for i in 0...250
         if !$game_variables[279].include?(s) 
             if $data_actors[i] != nil and  $data_classes[i] != nil
                $game_actors[i].forget_skill(s)
             end
         end
         end
      end   
      end
      #2nd超级装备删除
      for i in 578..583
          unless $game_variables[278].include?(i)
                 $game_party.gain_item($data_weapons[i],-99,true)
          end  
      end         
      for i in 206..208
          unless $game_variables[278].include?(i)
                 $game_party.gain_item($data_armors[i],-99,true)
          end  
      end
      #特殊道具删除
        a=8493071
        for i in 1...999
            item = $data_weapons[i]
            $game_party.gain_item(item,-99) if item != nil and item.name != nil and $game_party.item_number(item)*a != $game_variables[272][i]
        end
        for i in 1...999
            item = $data_armors[i]
            $game_party.gain_item(item,-99) if item != nil and item.name != nil and $game_party.item_number(item)*a != $game_variables[273][i]
        end
        for i in 1...999
            item = $data_items[i]
            $game_party.gain_item(item,-99) if item != nil and item.name != nil and $game_party.item_number(item)*a != $game_variables[274][i]
        end
  end     
  #--------------------------------------------------------------------------
  # ● 获取所有成员
  #--------------------------------------------------------------------------
  def all_members
    @actors.collect {|id| $game_actors[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取参战角色
  #--------------------------------------------------------------------------
  def battle_members
    # all_members.select {|actor| actor.exist? }
    if in_battle
      @initialize_battle_members.select {|actor| actor.exist? }
    else
      all_members.select {|actor| actor.exist? }
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取参战角色的最大数
  #--------------------------------------------------------------------------
  def max_battle_members
    return 5
  end
  #--------------------------------------------------------------------------
  # ● 获取领队
  #--------------------------------------------------------------------------
  def leader
    battle_members[0]
  end
  #--------------------------------------------------------------------------
  # ● 获取物品实例的数组 
  #--------------------------------------------------------------------------
  def items
    @items.keys.sort.collect {|id| $data_items[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取武器实例的数组 
  #--------------------------------------------------------------------------
  def weapons
    @weapons.keys.sort.collect {|id| $data_weapons[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取护甲实例的数组 
  #--------------------------------------------------------------------------
  def armors
    @armors.keys.sort.collect {|id| $data_armors[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取所有装备实例的数组
  #--------------------------------------------------------------------------
  def equip_items
    weapons + armors
  end
  #--------------------------------------------------------------------------
  # ● 获取所有物品实例的数组
  #--------------------------------------------------------------------------
  def all_items
    items + equip_items
  end
  #--------------------------------------------------------------------------
  # ● 获取物品类对应的容器实例
  #--------------------------------------------------------------------------
  def item_container(item_class)
    return @items   if item_class == RPG::Item
    return @weapons if item_class == RPG::Weapon
    return @armors  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 获取打造装备材料
  #--------------------------------------------------------------------------
  def forge_materials
    start_id = RPG::Item::FORGE_REQUIREMENT_START_ID
    hash = {}
    [start_id, start_id+1, start_id+2,start_id+3].each do |id|
      _item_number = @items[id]
      hash[id] = _item_number if _item_number
    end
    hash
  end
  #--------------------------------------------------------------------------
  # ● 设置初期队伍
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = $data_system.party_members.clone
  end
  #--------------------------------------------------------------------------
  # ● 获取队伍名称
  #    只有一人时返回角色的名字，含有多人时返回“某某的队伍”。
  #--------------------------------------------------------------------------
  def name
    return ""           if battle_members.size == 0
    return leader.name  if battle_members.size == 1
    return sprintf(Vocab::PartyName, leader.name)
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试
  #--------------------------------------------------------------------------
  def setup_battle_test
    setup_battle_test_members
    setup_battle_test_items
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试用队伍
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    $data_system.test_battlers.each do |battler|
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.init_equips(battler.equips)
      actor.recover_all
      add_actor(actor.id)
    end
    add_actor(7)
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试用物品
  #--------------------------------------------------------------------------
  def setup_battle_test_items
    $data_items.each do |item|
      gain_item(item, max_item_number(item)) if item && item.name != nil && item.name != ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试用武器
  #--------------------------------------------------------------------------
  def setup_battle_test_weapons
    $data_weapons.each do |item|
      gain_item(item, 5) if item && item.name != nil && item.name != ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试用防具
  #--------------------------------------------------------------------------
  def setup_battle_test_armors
    $data_armors.each do |item|
      gain_item(item, 5) if item && item.name != nil && item.name != ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取队伍成员的最高等级
  #--------------------------------------------------------------------------
  def highest_level
    lv = members.collect {|actor| actor.level }.max
  end
  #--------------------------------------------------------------------------
  # ● 角色入队
  #--------------------------------------------------------------------------
  def add_actor(actor_id,which = :actors)
      @actors.delete(actor_id)
      @actors2.delete(actor_id)
    if which == :actors
      max_member = $game_variables[MAX_MEMBERS_VARIABLE].blank? ? MAX_MEMBERS : $game_variables[MAX_MEMBERS_VARIABLE].to_i
      if @actors.size < max_member and actor_id != 208 and actor_id != 207
         @actors.push(actor_id)
      else
         @actors2.push(actor_id)
      end
        if actor_id > 1 and actor_id != 208 and actor_id != 207
           $game_variables[240].push(actor_id)
           $game_variables[240].uniq!
           @cant_join_actors.delete(actor_id)
           @cant_join_actors.uniq!
        end   
    end
    if which == :house
      @actors2.push(actor_id)
    end
      @cant_join_actors.uniq!
      @actors2.uniq!
      @actors.uniq!

    #如果持有军印,定习得阵法,新队员也获得阵法，为了避免后续加入的队员无法习得阵法
    for i in 125...142
      if $game_party.has_item?($data_items[i])
        if $game_actors[actor_id] != nil and !$game_actors[actor_id].skill_is_learn?(i-120)
           $game_actors[actor_id].learn_skill(i-120) 
        end
      end
    end
    @actors = @actors.uniq

    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● 角色离队
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
       @actors2.delete(actor_id)
       unless SceneManager.scene.is_a?(Scene_Actor_House)
         if $game_switches[699] == false and actor_id > 1 and actor_id != 208 and actor_id != 207
            @actors2.push(actor_id)
            @cant_join_actors.push(actor_id)
         else
            $game_variables[240].delete(actor_id)
         end
       end
       @cant_join_actors.uniq!
       @actors2.uniq!
       @actors.uniq!

    if @actors.size > 1
       @actors.delete(actor_id)
       if actor_id == $game_variables[100] and $game_switches[631] == false
          jm_clear
          jm_clear_message
       end
    end   
       $game_player.refresh
       $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● 角色彻底删除
  #--------------------------------------------------------------------------
  def remove_actor_ace(actor_id)
         @actors2.delete(actor_id)
      if @actors.size > 1
         @actors.delete(actor_id)
         if actor_id == $game_variables[100]
            jm_clear
         end
      end   
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● 作弊角色彻底清楚
  #--------------------------------------------------------------------------
  def remove_actor_hack(actor_id)
      @actors2.delete(actor_id)
      @actors.delete(actor_id)
      $game_player.refresh
      $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● 军师离队
  #--------------------------------------------------------------------------
  def jm_clear
      $game_party.jm_actor = []
      $game_variables[100] = 0 
         for i in 1...220
              if $game_actors[i].class_id != 1 and i != 208 and i != 207
                 $game_actors[i].forget_skill(188)
                 $game_actors[i].forget_skill(189)
                 $game_actors[i].forget_skill(190)
                 $game_actors[i].forget_skill(113)
                 for p in 598...700
                     if $data_skills[p].is_jm?
                        $game_actors[i].forget_skill(p)
                     end
                 end
              end
         end
         $game_variables[112] = 0
         $game_variables[113] = 0
         $game_variables[114] = 0
         $game_variables[115] = 0
         $game_variables[116] = 0
         $game_variables[109] = 0
         $game_variables[119] = 0
         $game_party.members.each do |a|
            a.refresh
         end
         $game_party.house_members.each do |a|
            a.refresh
         end
  end
  #--------------------------------------------------------------------------
  # ● 军师离队对话
  #--------------------------------------------------------------------------
  def jm_clear_message  
         Audio.se_play("Audio/SE/buyyy",100,55)
         Audio.se_play("Audio/SE/Cursor3",100,60)
         $game_message.position = 1
         $game_message.add("\ec[10]军师变动，请重新设置激活军师天赋。\ec[0]")
         Fiber.yield while $game_message.busy?
         $game_message.position = 2
  end       
  #--------------------------------------------------------------------------
  # ● 交换角色 actor1 : 队伍 actor2 : 仓库
  #--------------------------------------------------------------------------
  def change_actor(actor1,actor2)
    return if actor1.nil? && actor2.nil?
    if actor1.nil?
      add_actor(actor2.id)
    elsif actor2.nil?
      add_actor(actor1.id,:house)
    else
      add_actor(actor1.id,:house)
      add_actor(actor2.id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加／减少持有金钱
  #--------------------------------------------------------------------------
  def gain_gold(amount)
    @gold = [[@gold + amount, 0].max, max_gold].min
    a = amount
    if a < 0
      $game_variables[234] += a
    end
  end
  #--------------------------------------------------------------------------
  # ● 减少持有金钱
  #--------------------------------------------------------------------------
  def lose_gold(amount)
    gain_gold(-amount)
    a = amount
    $game_variables[234] += a
  end
  #--------------------------------------------------------------------------
  # ● 获取持有金钱的最大值
  #--------------------------------------------------------------------------
  def max_gold
    return 999999
  end
  #--------------------------------------------------------------------------
  # ● 增加步数
  #--------------------------------------------------------------------------
  def increase_steps
    @steps += 1
  end
  #--------------------------------------------------------------------------
  # ● 获取物品的持有数
  #--------------------------------------------------------------------------
  def item_number(item)
    container = item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取物品的最大持有数
  #--------------------------------------------------------------------------
  def max_item_number(item)
    return 99
  end
  #--------------------------------------------------------------------------
  # ● 判定物品是否达到最大持有数
  #--------------------------------------------------------------------------
  def item_max?(item)
    item_number(item) >= max_item_number(item)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否持有某物品
  #     include_equip : 检索是否包括装备
  #--------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    return true if item_number(item) > 0
    return include_equip ? members_equip_include?(item) : false
  end
  #--------------------------------------------------------------------------
  # ● 判定队伍成员是否装备着指定物品
  #--------------------------------------------------------------------------
  def members_equip_include?(item)
    members.any? {|actor| actor.equips.include?(item) }
  end
  #--------------------------------------------------------------------------
  # ● 增加／减少物品
  #     include_equip : 是否包括装备
  #--------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
    items_ac(item,amount)
  end
  #--------------------------------------------------------------------------
  # ● 丢弃成员的装备
  #--------------------------------------------------------------------------
  def discard_members_equip(item, amount)
    n = amount
    members.each do |actor|
      while n > 0 && actor.equips.include?(item)
        actor.discard_equip(item)
        n -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 减少物品
  #     include_equip : 是否包括装备
  #--------------------------------------------------------------------------
  def lose_item(item, amount, include_equip = false)
    gain_item(item, -amount, include_equip)
  end
  #--------------------------------------------------------------------------
  # ● 消耗物品
  #    减少 1 个持有数。
  #--------------------------------------------------------------------------
  def consume_item(item)
    lose_item(item, 1) if item.is_a?(RPG::Item) && item.consumable
  end
  #--------------------------------------------------------------------------
  # ● 技能／使用物品可能判定
  #--------------------------------------------------------------------------
  def usable?(item)
    members.any? {|actor| actor.usable?(item) }
  end
  #--------------------------------------------------------------------------
  # ● 战斗时指令输入可能判定
  #--------------------------------------------------------------------------
  def inputable?
    members.any? {|actor| actor.inputable? }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否全灭
  #--------------------------------------------------------------------------
  def all_dead?
    super && ($game_party.in_battle || members.size > 0)
  end
  #--------------------------------------------------------------------------
  # ● 角色移动一步时的处理
  #--------------------------------------------------------------------------
  def on_player_walk
    members.each {|actor| actor.on_player_walk }
    Graphics.wait(2) if $game_map.region_id($game_player.x , $game_player.y) == 55
  end
  #--------------------------------------------------------------------------
  # ● 获取菜单画面中选中角色
  #--------------------------------------------------------------------------
  def menu_actor
    $game_actors[@menu_actor_id] || members[0]
  end
  #--------------------------------------------------------------------------
  # ● 设置菜单画面中选中角色
  #--------------------------------------------------------------------------
  def menu_actor=(actor)
    @menu_actor_id = actor.id
  end
  #--------------------------------------------------------------------------
  # ● 菜单画面中，选择下一个角色
  #--------------------------------------------------------------------------
  def menu_actor_next
    index = members.index(menu_actor) || -1
    index = (index + 1) % members.size
    self.menu_actor = members[index]
  end
  #--------------------------------------------------------------------------
  # ● 菜单画面中，选择上一个角色
  #--------------------------------------------------------------------------
  def menu_actor_prev
    index = members.index(menu_actor) || 1
    index = (index + members.size - 1) % members.size
    self.menu_actor = members[index]
  end
  #--------------------------------------------------------------------------
  # ● 获取技能／使用物品目标
  #--------------------------------------------------------------------------
  def target_actor
    $game_actors[@target_actor_id] || members[0]
  end
  #--------------------------------------------------------------------------
  # ● 设置技能／使用物品目标
  #--------------------------------------------------------------------------
  def target_actor=(actor)
    @target_actor_id = actor.id
  end
  #--------------------------------------------------------------------------
  # ● 交换顺序
  #--------------------------------------------------------------------------
  def swap_order(index1, index2)
    @actors[index1], @actors[index2] = @actors[index2], @actors[index1]
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 存档文件显示用的角色图像信息
  #--------------------------------------------------------------------------
  def characters_for_savefile
    battle_members.collect do |actor|
      [actor.character_name, actor.character_index]
    end
  end

  def actors_for_savefile
    battle_members.collect do |actor|
      [actor.face_name, actor.face_index]
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定队伍能力
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    battle_members.any? {|actor| actor.party_ability(ability_id) }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否遇敌几率减半
  #--------------------------------------------------------------------------
  def encounter_half?
    if $game_variables[124] > 1
      return true 
    else
      return false
    end
    #party_ability(ABILITY_ENCOUNTER_HALF)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否随机遇敌无效
  #--------------------------------------------------------------------------
  def encounter_none?
    if $game_variables[123] > 1
      return true 
    else
      return false
    end
    #party_ability(ABILITY_ENCOUNTER_NONE)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敌人偷袭无效
  #--------------------------------------------------------------------------
  def cancel_surprise?
    party_ability(ABILITY_CANCEL_SURPRISE)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否先制攻击几率上升
  #--------------------------------------------------------------------------
  def raise_preemptive?
    party_ability(ABILITY_RAISE_PREEMPTIVE)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否获得金钱数量双倍
  #--------------------------------------------------------------------------
  def gold_double?
    party_ability(ABILITY_GOLD_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否物品掉落几率双倍
  #--------------------------------------------------------------------------
  def drop_item_double?
    party_ability(ABILITY_DROP_ITEM_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # ● 计算先制攻击几率
  #--------------------------------------------------------------------------
  def rate_preemptive(troop_agi)
    (agi >= troop_agi ? 0.05 : 0.03) * (raise_preemptive? ? 4 : 1)
  end
  #--------------------------------------------------------------------------
  # ● 计算敌人偷袭几率
  #--------------------------------------------------------------------------
  def rate_surprise(troop_agi)
    cancel_surprise? ? 0 : (agi >= troop_agi ? 0.03 : 0.05)
  end
  #--------------------------------------------------------------------------
  # ● 判断物品可以使用
  #     item_id : 物品 ID
  #--------------------------------------------------------------------------
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item_number(item) == 0
    if $game_party.in_battle
      return item.battle_ok?
    else
      return item.menu_ok?
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取角色
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def get_member(actor_id)
    members.select {|member| member.alive? && member.id == actor_id }.first
  end
  #--------------------------------------------------------------------------
  # ● 判断被动技能是否可用
  #     actor_id : 角色 ID
  #     skill_id : 技能 ID
  #--------------------------------------------------------------------------
  def exist_bskill?(actor_id,skill_id)
    _actor = get_member(actor_id)
    _actor && _actor.skill_is_learn?(skill_id)
  end

  def exist_jm_skill?(skill_id)
      all_members.any? {|actor| actor.skill_is_learn?(skill_id) }
  end



  def items_ac(item,amount)
        a = amount*8493071
        max = 840814029
        item_id = item.id
        if item.is_a?(RPG::Weapon)
           $game_variables[272][item_id] += a
           $game_variables[272][item_id] = [max,$game_variables[272][item_id]].min
           $game_variables[272][item_id] = [0,$game_variables[272][item_id]].max
        end
        if item.is_a?(RPG::Armor)
           $game_variables[273][item_id] += a
           $game_variables[273][item_id] = [max,$game_variables[273][item_id]].min
           $game_variables[273][item_id] = [0,$game_variables[273][item_id]].max
        end
        if item.is_a?(RPG::Item)
           $game_variables[274][item_id] += a
           $game_variables[274][item_id] = [max,$game_variables[274][item_id]].min
           $game_variables[274][item_id] = [0,$game_variables[274][item_id]].max
        end   
  end  


end

