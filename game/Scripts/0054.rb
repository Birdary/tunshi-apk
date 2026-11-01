#encoding:utf-8
#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　管理敌群和战斗相关资料的类，也可执行如战斗事件管理之类的功能。
#   本类的实例请参考 $game_troop 。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 敌人名字后缀的字表
  #--------------------------------------------------------------------------
  LETTER_TABLE = [' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',
                  ' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',
                  ' U',' V',' W',' X',' Y',' Z']
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # 战斗画面的状态
  attr_reader   :interpreter              # 战斗事件用事件解释器
  attr_reader   :event_flags              # 战斗事件执行完成的标志
  attr_reader   :turn_count               # 回合数
  attr_reader   :name_counts              # 敌人名称出现数的记录 HASH
  attr_accessor :over_plot_damage
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    clear
  end

  #--------------------------------------------------------------------------
  # ● 获取成员
  #--------------------------------------------------------------------------
  def members
    @enemies
  end

  alias :battle_members :members

  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @screen.clear
    @interpreter.clear
    @event_flags.clear
    @enemies = []
    @turn_count = 0
    @over_plot_damage = 0
    @names_count = {}
  end
  #--------------------------------------------------------------------------
  # ● 获取敌群
  #--------------------------------------------------------------------------
  def troop
    $data_troops[@troop_id]
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def setup(troop_id) 
    clear
         $game_variables[271] = [] 
         for i in 0...7
             $game_variables[271][i] = []
         end  
    @troop_id = troop_id
    @enemies = []

       troop.members.each_with_index do |member,index|
         next unless $data_enemies[member.enemy_id]
         enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
         enemy.hide if member.hidden
         enemy.screen_x = set_screen_x(index)  # member.x
         enemy.screen_y = set_screen_y(index)  # member.y
         @enemies.push(enemy)
         if @enemies.size == 6
            @boss = enemy
            break
         end
       end

    rand_enemy
    rand_enemy_sl
    init_screen_tone
    make_unique_names
  end

  #--------------------------------------------------------------------------
  # ● 二周目添加随机武将
  #--------------------------------------------------------------------------
  def rand_enemy
      if $game_switches[700] == true
      @enemies.each_with_index do |enemy,index|  
         a = $data_enemies[72+rand(633)]
         cant_a = [125,142,327,436,438,467,468,469,500,604,605,612,527]
         if a.note != ""
            text = a.note.split("\r\n")[4].split(" = ").last[0,3] 
         else
            text = "001"
         end
         #如果当前角色不是杂兵，被替换角色也不是杂兵也不是空，再排除掉cant中特殊的不能随机的敌将。
         if (!@enemies[index].equip_wtype_ok?(12) or rand(100) > 500 ) and $game_troop.troop.name[0,1] == "S" and a.note != "" and text != "001" and text != "002" and !cant_a.include?(a.id) 
             can = true #防止角色名字重复
             @enemies.each do |e|
                can = false if a.name == e.name
             end
             if can == true   
                #在变身之前先储存原来的掉落装备
                $game_variables[271][index] += $data_enemies[a.id].drop_items
                enemy.transform(a.id)
             end
         end
      end  
      end
  end

  def rand_enemy_sl
      if $game_switches[743] == true
            hard = $game_switches[744]
            enemy_list = []
            boss_list  = []
            skill_list = []
         if $game_variables[230] == 1
            enemy_list = [72,73,74,75,76,77,78,79,81,82,83,84,85,87,88,89] 
            boss_list  = [85]
            skill_list = [81,82,83,84,85,87] 
         elsif $game_variables[230] == 2
            enemy_list = [95,96,97,98,99,582,583,584,585,586,587] 
            boss_list  = [95,96,101,125,582,583]
            skill_list = [97,98,99,112] 
            skill_list += boss_list
            for i in 101...125
                enemy_list += [i] if i != 116 and i != 117 and i != 118
            end
         elsif $game_variables[230] == 3
            enemy_list = [175,177,179,180,182,183,185,186,187,188,190,191,192,193,195,196,197,198,200,201,202,203,204,206,207,208] 
            boss_list  = [185,96,200,689]
            skill_list = [186,187,195,201,206,207,208] 
            skill_list +=[95,96,101,125,582,583]
            skill_list += boss_list
         elsif $game_variables[230] == 4
            enemy_list = [217,218,219,220,221,225,226,227,228,229,230,232,233,234,235,236,239,240,241,242,243,244,255,256,257] 
            boss_list  = [135,239,689,142]
            skill_list = [226,227,228,229,230,232,233,234,235,240] 
            skill_list +=[185,96,200,689]
            skill_list += boss_list
         elsif $game_variables[230] == 5
            enemy_list = [267,269,272,273,274,275,277,278,280,281,282,284,285,286,288,289,291,294,295,297,298,299,300,301,312,313,314,315,316,318] 
            boss_list  = [297,312,689,142]
            skill_list = [269,272,274,277,278,280,288,294,298,301,314,315] 
            skill_list +=[135,239,689]
            skill_list += boss_list
         elsif $game_variables[230] == 6
            enemy_list = [324,325,326,327,329,330,331,335,336,337,341,342,343,344,345,349,350,351,354,355,356,359,360,361,362,363,366,367,368,372,373,374,378,379,380,381,384,388,389,390,391,394,396,397,398,399,400,696,697,698,699,700,701,689] 
            boss_list  = [327,341,359,394,396,696,689]
            skill_list = [324,325,326,336,342,350,361,362,368,372,378,384,388,397,398,399,699,701,142] 
            skill_list +=[297,312,689,142]
            skill_list += boss_list
         elsif $game_variables[230] == 7
            enemy_list = [431,432,433,436,437,438,439,440,441,443,444,445,446,449,450,451,452,459,460,461,462,464,466,467,471,472,473,476,477,478,479,480,483,486,487,488,489,490,493,494,495,496,497,498,500,501,502,503,504,505,703,704,705,696,697,698,699,700,701,689,606,607,608,609,610,611,612,613,614,615] 
            boss_list  = [436,467,500,521,696,689,703]
            skill_list = [431,434,438,443,449,459,460,466,478,479,486,487,488,489,490,501,502,503,504,505,699,701,704,705,142] 
            skill_list +=[327,341,359,394,396,696,689]
            skill_list += boss_list
         elsif $game_variables[230] == 8
            enemy_list = [518,519,520,521,522,523,524,525,526,527,529,530,531,532,533,535,536,537,538,539,542,543,544,545,546,547,549,550,551,552,553,555,557,558,559,560,561,564,565,566,567,568,569,571,572,573,574,575,576,577,578,579,580,703,704,705,696,697,698,699,700,701,689,599,600,591,592,593,594,595,596,606,607,608,609,610,611,612,613,614,615] 
            boss_list  = [527,525,526,547,591,696,689,703]
            skill_list = [518,522,523,524,529,530,531,532,535,536,537,539,542,543,544,545,546,549,550,551,552,553,557,559,564,565,566,571,572,573,574,575,699,701,704,705,142] 
            skill_list +=[436,467,500,521,696,689,703]
            skill_list += boss_list
         end
         enemy_list.delete_if { |a| $data_enemies[a].params[0] < 300 }
         skill_list.delete_if { |a| $data_enemies[a].params[0] < 300 }
          boss_list.delete_if { |a| $data_enemies[a].params[0] < 300 }

         @enemies.each_with_index do |enemy,index|  
             a = $data_enemies[ enemy_list[rand(enemy_list.size)]   ]
             b = $data_enemies[  boss_list[rand(boss_list.size)]    ]
             s = $data_enemies[ skill_list[rand(skill_list.size)]   ]

             if  enemy.index != 5
                 if hard == true and rand(100) > 35
                    enemy.transform(s.id)
                 else
                    enemy.transform(a.id)
                 end
             else
                 enemy.transform(b.id) if hard == true   
             end
                 enemy.hp += 9999
                 enemy.mp += 9999
                 enemy.dp = 30 if hard == true

         end

      end
  end




  def set_screen_x(index)
    BattlerPos::ENEMY_X[index]
  end
  def set_screen_y(index)
    BattlerPos::ENEMY_Y[index]
  end

  #--------------------------------------------------------------------------
  # ● 初始化画面的色调
  #--------------------------------------------------------------------------
  def init_screen_tone
    @screen.start_tone_change($game_map.screen.tone, 0) if $game_map
  end
  #--------------------------------------------------------------------------
  # ● 同名的敌人附加字母后缀
  #--------------------------------------------------------------------------
  def make_unique_names
    members.each do |enemy|
      next unless enemy.alive?
      next unless enemy.letter.empty?
      n = @names_count[enemy.original_name] || 0
      enemy.letter = LETTER_TABLE[n % LETTER_TABLE.size]
      @names_count[enemy.original_name] = n + 1
    end
    members.each do |enemy|
      n = @names_count[enemy.original_name] || 0
      enemy.plural = true if n >= 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人名字的数组
  #    战斗开始时的显示用。除去重复的。
  #--------------------------------------------------------------------------
  def enemy_names
    names = []
    members.each do |enemy|
      next unless enemy.alive?
      next if names.include?(enemy.original_name)
      names.push(enemy.original_name)
    end
    names
  end
  #--------------------------------------------------------------------------
  # ● 判定战斗事件（页）条件是否符合
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if !c.turn_ending && !c.turn_valid && !c.enemy_valid &&
       !c.actor_valid && !c.switch_valid
      return false      # 条件未设置…不执行
    end
    if @event_flags[page]
      return false      # 执行完成
    end
    if c.turn_ending    # 回合结束时
      return false unless BattleManager.turn_end?
    end
    if c.turn_valid     # 回合数
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 && n != a)
      return false if (b > 0 && (n < 1 || n < a || n % b != a % b))
    end
    if c.enemy_valid    # 敌人
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp_rate * 100 > c.enemy_hp
    end
    if c.actor_valid    # 角色
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp_rate * 100 > c.actor_hp
    end
    if c.switch_valid   # 开关
      return false if !$game_switches[c.switch_id]
    end
    return true         # 条件符合
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗事件
  #--------------------------------------------------------------------------
  def setup_battle_event
    return if @interpreter.running?
    return if @interpreter.setup_reserved_common_event
    troop.pages.each do |page|
      next unless conditions_met?(page)
      @interpreter.setup(page.list)
      @event_flags[page] = true if page.span <= 1
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加回合
  #--------------------------------------------------------------------------
  def increase_turn
    troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    @turn_count += 1
  end
  #--------------------------------------------------------------------------
  # ● 计算经验值的总数
  #--------------------------------------------------------------------------
  def exp_total
      a = dead_members.inject(0) {|r, enemy| r += enemy.exp }
      a = (a * 1.25).round if $add_gold_item == 1
      a = (a * 1.5).round if $game_switches[700] == true
      a
  end
  #--------------------------------------------------------------------------
  # ● 计算金钱的总数
  #--------------------------------------------------------------------------
  def gold_total
      a = dead_members.inject(0) {|r, enemy| r += enemy.gold } * gold_rate
      a = (a * 1.25).round if $add_gold_item == 1
      a = (a * 1.5).round if $game_switches[700] == true
      a 
  end
  #--------------------------------------------------------------------------
  # ● 计算练兵的总数
  #--------------------------------------------------------------------------
  def expbook_total
      a = dead_members.inject(0) {|r, enemy| r += enemy.exp }
      if $game_switches[700] == true
         a = ( a * ( (rand(51)+50) * 0.01 ) ).to_i
      elsif
         a = ( a * ( (rand(26)+25) * 0.01 ) ).to_i
      end
      a
      @real_expbook = a
  end

  def expbook_total_real
      if @real_expbook == nil
         0
      else
         @real_expbook 
      end 
  end
  #--------------------------------------------------------------------------
  # ● 获取金钱的倍率
  #--------------------------------------------------------------------------
  def gold_rate
      $game_party.gold_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # ● 生成物品数组
  #--------------------------------------------------------------------------
  def make_drop_items
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_items }
  end
end
