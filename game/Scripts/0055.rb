#encoding:utf-8
#==============================================================================
# ■ Game_Unit
#------------------------------------------------------------------------------
# 　管理游戏单位的类。是 Game_Party 和 Game_Troop 类的父类。
#==============================================================================

class Game_Unit

  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor   :in_battle                # 战斗中的标志
  attr_accessor   :states                   # 队伍状态
  # attr_reader     :is_bagua                 # 是否为八卦阵
  attr_accessor   :alive_gate               # 生门武将
  attr_accessor   :boss                     # boss
  attr_accessor   :formation_id             # 阵型ID

  STATE_TABLE = { jc: ["减策计",0.2], jm: ["击免计",0.3], cm: ["策免计",0.3], xl: ["血路计",0.2], chm: ["嘲骂计",0.2], wt: ["伪退", 0.2] }

  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @in_battle = false
    @formation_id = 4 

    # 队伍状态
    # 1: 减策计 - 策略伤害减半           :jc
    # 2: 击免计 - 物理伤害无效           :jm
    # 3: 策免计 - 敌策略无效 (解策计除外)  :cm
    # 4: 血路计 - 使敌人受到的回复效果减半  :xl
    # 5: 嘲骂计 - 敌军命中下降15%        :chm
    # 5: 伪退计 - 敌行动速度下降20%       :wt  （未实现）

    @states = []

    # 是否八卦阵
    # @is_bagua = false
    # 生门武将
    @alive_gate = nil
    @boss = nil

  end

  def is_bagua
    @alive_gate.is_a?(Game_Battler)
  end

  def set_bagua battler
    # @is_bagua = true
    @alive_gate = battler
  end

  def clear_bagua!
    if @formation_id == 13
      # @is_bagua = false
      @alive_gate = nil
    end
  end

  # 解策计效果：清除解策技状态 减策计除外
  def clear_jc_states!
    @states.delete_if { |k,v| k != :jc }
  end

  def clear_states
    @states.clear
    # @is_bagua = false
    @alive_gate = nil
  end

  #--------------------------------------------------------------------------
  # ● 获取成员
  #--------------------------------------------------------------------------
  def members
    return []
  end

  def formation
    $data_skills[@formation_id]
  end

  def set_formation(id)
    @formation_id = id
    formation
  end

  def init_formation
    set_formation RPG::Skill::DEFAULT_FORMATION_ID
  end

  def formation?
    @formation_id != RPG::Skill::DEFAULT_FORMATION_ID
  end

  def can_use_formation?
      alive_members.select { |_member| !_member.eql?(@boss) }.size >= Config::FORMATION_NEED_MEMBER_COUNT
  end

  def can_use_formation_start?
      alive_members.select { |_member| !_member.eql?(@boss) }.size >= 5
  end
  #--------------------------------------------------------------------------
  # ● 获取存活的成员数组
  #--------------------------------------------------------------------------
  def alive_members
    members.select {|member| member.alive? }
  end

  def al
    members.select {|member| member.alive? }
  end
  #--------------------------------------------------------------------------
  # ● 获取死亡的成员数组
  #--------------------------------------------------------------------------
  def dead_members
    members.select {|member| member.dead? }
  end
  #--------------------------------------------------------------------------
  # ● 获取可以行动的成员数组
  #--------------------------------------------------------------------------
  def movable_members
    members.select {|member| member.movable? }
  end
  #--------------------------------------------------------------------------
  # ● 清除全员的战斗行为
  #--------------------------------------------------------------------------
  def clear_actions
    members.each {|member| member.clear_actions }
  end
  #--------------------------------------------------------------------------
  # ● 计算敏捷值的平均值
  #--------------------------------------------------------------------------
  def agi
    return 1 if members.size == 0
    members.inject(0) {|r, member| r += member.agi } / members.size
  end
  #--------------------------------------------------------------------------
  # ● 计算受到攻击的几率的总数
  #--------------------------------------------------------------------------
  def tgr_sum
    alive_members.inject(0) {|r, member| r + member.tgr }
  end
  #--------------------------------------------------------------------------
  # ● 随机决定目标
  #--------------------------------------------------------------------------
  def random_target
    tgr_rand = rand * tgr_sum
    alive_members.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    alive_members[0]
  end
  #--------------------------------------------------------------------------
  # ● 随机决定目标（无法战斗）
  #--------------------------------------------------------------------------
  def random_dead_target
    dead_members.empty? ? nil : dead_members[rand(dead_members.size)]
  end
  #--------------------------------------------------------------------------
  # ● 决定顺带目标
  #    也就是如果上下目标无效，则获取下一个目标
  #--------------------------------------------------------------------------
  def smooth_target(index)
    member = members[index]
    (member && member.alive?) ? member : alive_members[0]
  end
  #--------------------------------------------------------------------------
  # ● 决定顺带目标（无法战斗）
  #--------------------------------------------------------------------------
  def smooth_dead_target(index)
    member = members[index]
    (member && member.dead?) ? member : dead_members[0]
  end
  #--------------------------------------------------------------------------
  # ● 清除行动结果
  #--------------------------------------------------------------------------
  def clear_results
    members.select {|member| member.result.clear }
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始处理
  #--------------------------------------------------------------------------
  def on_battle_start
    members.each {|member| member.on_battle_start }
    @in_battle = true
  end
  #--------------------------------------------------------------------------
  # ● 战斗结束处理
  #--------------------------------------------------------------------------
  def on_battle_end
    @in_battle = false
    #init_formation
    members.each {|member| member.on_battle_end }
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗行动
  #--------------------------------------------------------------------------
  def make_actions
    members.each {|member| member.make_actions }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否全灭
  #--------------------------------------------------------------------------
  def all_dead?
    alive_members.empty?
  end
  #--------------------------------------------------------------------------
  # ● 获取保护弱者的战斗者
  #--------------------------------------------------------------------------
  def substitute_battler
    members.find {|member| member.substitute? }
  end
  #--------------------------------------------------------------------------
  # ● 清除特殊计策
  #--------------------------------------------------------------------------
  def remove_spe_item_effect
    remove_states = []
    @states.each do |state_tag|
      state = STATE_TABLE[state_tag]
      remove_states << state_tag if rand < state.last
    end
    remove_states.each do |state_tag|
      state = STATE_TABLE[state_tag]
      @states.delete state_tag
    end
  end
end
