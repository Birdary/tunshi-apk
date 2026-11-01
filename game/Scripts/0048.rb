#encoding:utf-8
#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　管理战斗者的类。主要含有能力值计算的方法。Game_Battler 类的父类。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 常量（特性）
  #--------------------------------------------------------------------------
  FEATURE_ELEMENT_RATE  = 11              # 属性抗性
  FEATURE_DEBUFF_RATE   = 12              # 弱化抗性
  FEATURE_STATE_RATE    = 13              # 状态抗性
  FEATURE_STATE_RESIST  = 14              # 状态免疫
  FEATURE_PARAM         = 21              # 普通能力
  FEATURE_XPARAM        = 22              # 添加能力
  FEATURE_SPARAM        = 23              # 特殊能力
  FEATURE_ATK_ELEMENT   = 31              # 攻击附带属性
  FEATURE_ATK_STATE     = 32              # 攻击附带状态
  FEATURE_ATK_SPEED     = 33              # 修正攻击速度
  FEATURE_ATK_TIMES     = 34              # 添加攻击次数
  FEATURE_STYPE_ADD     = 41              # 添加技能类型
  FEATURE_STYPE_SEAL    = 42              # 禁用技能类型
  FEATURE_SKILL_ADD     = 43              # 添加技能
  FEATURE_SKILL_SEAL    = 44              # 禁用技能
  FEATURE_EQUIP_WTYPE   = 51              # 可装备武器类型
  FEATURE_EQUIP_ATYPE   = 52              # 可装备护甲类型
  FEATURE_EQUIP_FIX     = 53              # 固定装备
  FEATURE_EQUIP_SEAL    = 54              # 禁用装备
  FEATURE_SLOT_TYPE     = 55              # 装备风格
  FEATURE_ACTION_PLUS   = 61              # 添加行动次数
  FEATURE_SPECIAL_FLAG  = 62              # 特殊标志
  FEATURE_COLLAPSE_TYPE = 63              # 消失效果
  FEATURE_PARTY_ABILITY = 64              # 队伍能力
  #--------------------------------------------------------------------------
  # ● 常量（特殊标志）
  #--------------------------------------------------------------------------
  FLAG_ID_AUTO_BATTLE   = 0               # 自动战斗
  FLAG_ID_GUARD         = 1               # 擅长防御
  FLAG_ID_SUBSTITUTE    = 2               # 保护弱者
  FLAG_ID_PRESERVE_TP   = 3               # 特技专注 
  #--------------------------------------------------------------------------
  # ● 常量（能力强化／弱化图标的起始编号）
  #--------------------------------------------------------------------------
  ICON_BUFF_START       = 64              # 强化（16 个）
  ICON_DEBUFF_START     = 80              # 弱化（16 个）
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :hp                       # HP
  attr_reader   :mp                       # MP
  attr_reader   :tp                       # TP
  # attr_reader  :param_plus               # 增加能力值
  #--------------------------------------------------------------------------
  # ● 各种能力值的简易访问方法
  #--------------------------------------------------------------------------
  def map;  100;        end    # 最大AP (已弃用)   
  def mtp;  100;        end    # 最大TP (角色技能消费用TP)

  # 基本属性8项
  def mhp    # 最大HP          Maximum Hit Point
    a = param(0)
    a = a + $game_variables[112]    if $game_variables[112] != nil and self.actor?
    a = a + $game_variables[113]    if $game_variables[113] != nil and self.actor? and ( self.id == 38 or self.id == 39 ) 
    a = a + $game_variables[114]    if $game_variables[114] != nil and self.actor? and ( self.id == 45 or self.id == 46 or self.id == 47 or self.id == 48 ) 
    a = a * ( 100 + $game_variables[115] ) / 100 if $game_variables[115] != nil and self.actor? and self.id > 11 and self.id < 19 
    a += $game_variables[150] if $game_variables[150] != nil and self.enemy? and self.equip_wtype_ok?(12)
    a =  $game_variables[254] if $game_variables[254] > 999
    a = a-a%5
    a
  end

  def mmp    # 最大MP          Maximum Magic Point
    a = param(1) 
    a = a + $game_variables[114] if $game_variables[114] != nil and self.actor? and ( self.id == 45 or self.id == 46 or self.id == 47 or self.id == 48 ) 
    a = a + $game_variables[119] if $game_variables[119] != nil and self.actor? and ( self.id == 23 or self.id == 27 ) 
    a = a + $game_variables[109] if $game_variables[109] != nil and self.actor? and ( self.id == 12 or self.id == 18 ) 
    a = a + $game_variables[116] if $game_variables[116] != nil and self.actor?
    a += $game_variables[151] if $game_variables[151] != nil and self.enemy? and self.equip_wtype_ok?(12)
    a = a-a%5
    a
  end

 

  def str    # 武力            ATtacK power
    a = param(2) + fparam(:str)
    a = a+5 if $game_party.exist_jm_skill?(600) and self.id == $game_variables[100]
    a = a+5 if $game_party.exist_jm_skill?(639) and self.actor?
    a = a+10 if $game_party.exist_jm_skill?(689) and self.equip_wtype_ok?(52)  
    a += $game_variables[152] if $game_variables[152] != nil and self.enemy? and self.equip_wtype_ok?(12)
    a = a-a%5
    a = 0 if a < 0
    a
  end    

  def ski  # 技力            DEFense power
    a = param(3) + fparam(:dex)
    a = a+5 if $game_party.exist_jm_skill?(600) and self.id == $game_variables[100]
    a = a+5  if $game_party.exist_jm_skill?(640) and self.actor?  
    a = a+15 if $game_party.exist_jm_skill?(620) and self.actor? and ( self.id == 6 or self.id == 17 )
    a += $game_variables[153] if $game_variables[153] != nil and self.enemy? and self.equip_wtype_ok?(12)
    a = a-a%5 
    a = 0 if a < 0
    a
  end      

  def int  # 智力            Magic ATtack power
    a = param(4) + fparam(:int) 
    a = a+5 if $game_party.exist_jm_skill?(600) and self.id == $game_variables[100]
    a = a+5 if $game_party.exist_jm_skill?(641) and self.actor?
    a = a+10 if $game_party.exist_jm_skill?(612) and self.equip_wtype_ok?(14)  
    a = a+10 if $game_party.exist_jm_skill?(663) and self.equip_wtype_ok?(13)
    a = a+10 if $game_party.exist_jm_skill?(692) and ( self.id == 49 or self.id == 51 ) and self.actor?
    a += $game_variables[154] if $game_variables[154] != nil and self.enemy? and self.equip_wtype_ok?(12)  
    a = a-a%5
    a = 0 if a < 0
    a  
  end

  def def    # 防御            Magic DeFense power
    a = param(5) + ((param(5)*fparam(:def).to_f/100)).to_i   
    a += $game_variables[155] if $game_variables[155] != nil and self.enemy? and self.equip_wtype_ok?(12)
    a = 0 if a < 0
    a
  end

  def agi  # 速度            AGIlity
    a = param(6) + fparam(:agi) 
    a = a+5 if $game_party.exist_jm_skill?(600) and self.id == $game_variables[100]
    a = a+5 if $game_party.exist_jm_skill?(642) and self.actor? 
    a = a+15 if $game_party.exist_jm_skill?(614) and self.actor? and ( self.id == 59 or  self.id == 60 )
    a = a+$game_variables[156] if $game_variables[156] != nil and self.enemy? and self.equip_wtype_ok?(12)
    a = a-a%5
    a = 0 if a < 0
    a
  end

  def atk  # 攻击力          LUcK
   a = param(7) + ((param(7)*fparam(:atk).to_f/100)).to_i  
   a += $game_variables[157] if $game_variables[157] != nil and self.enemy? and self.equip_wtype_ok?(12)
   a += (param(7) * 0.5).to_i if self.state?(46)
   a = 0 if a < 0
   a
  end  
          
  def lvup_atk  #成长型武器的攻击力成长值
      size = 5.0
      up = 0
      if self.actor? && self.equips.include?($data_weapons[578])
         up = ( (self.kill_size_all) / size ).to_i
         up = 225 if up > 225
      end 
      if self.actor? && self.equips.include?($data_weapons[579])
         up = ( (self.kill_size_all) / size ).to_i
         up = 250 if up > 250
      end 
      if self.actor? && self.equips.include?($data_weapons[580])
         up = ( (self.kill_size_all) / size ).to_i
         up = 240 if up > 240
      end 
      if self.actor? && self.equips.include?($data_weapons[581])
         up = ( (self.kill_size_all) / size ).to_i
         up = 155 if up > 155
      end 
      if self.actor? && self.equips.include?($data_weapons[582])
         up = ( (self.kill_size_all) / size ).to_i
         up = 150 if up > 150
      end 
      if self.actor? && self.equips.include?($data_weapons[583])
         up = ( (self.kill_size_all) / size ).to_i
         up = 255 if up > 255
      end 
    
      if $game_variables[309] > 0 or $game_switches[743] == true
               case $game_variables[230]
               when 1
                   up = 25 + (up*0.07).to_i  if up > 25
               when 2
                   up = 37 + (up*0.07).to_i  if up > 37
               when 3
                   up = 50 + (up*0.07).to_i  if up > 50
               when 4
                   up = 70 + (up*0.07).to_i  if up > 70
               when 5
                   up = 100 + (up*0.07).to_i  if up >100
               when 6
                   up = 140 + (up*0.07).to_i  if up > 140
               end
      end
      up = up.to_i
      return up
  end  

  def lvup_def  #成长型防具的成长值
      size = 10.0
      up = 0
      up_1 = 0
      up_2 = 0
      up_3 = 0
      if self.actor? && self.equips.include?($data_armors[206])
         up_1 = ( (self.kill_size_all) / size ).to_i
         up_1 = 80 if up_1 > 80
               if $game_variables[309] > 0 or $game_switches[743] == true
               case $game_variables[230]
               when 1
                   up_1 = 15 + (up_1*0.07).to_i  if up_1 > 15
               when 2
                   up_1 = 20 + (up_1*0.07).to_i  if up_1 > 20
               when 3
                   up_1 = 25 + (up_1*0.07).to_i  if up_1 > 25
               when 4
                   up_1 = 32 + (up_1*0.07).to_i  if up_1 > 32
               when 5
                   up_1 = 45 + (up_1*0.07).to_i  if up_1 >  45
               when 6
                   up_1 = 65 + (up_1*0.07).to_i  if up_1 > 65
               end
               end
      end 
      if self.actor? && self.equips.include?($data_armors[207])
         up_2 = ( (self.kill_size_all) / size ).to_i
         up_2 = 75 if up_2 > 75
               if $game_variables[309] > 0 or $game_switches[743] == true
               case $game_variables[230]
               when 1
                   up_2 = 15 + (up_2*0.07).to_i  if up_2 > 15
               when 2
                   up_2 = 20 + (up_2*0.07).to_i  if up_2 > 20
               when 3
                   up_2 = 25 + (up_2*0.07).to_i  if up_2 > 25
               when 4
                   up_2 = 32 + (up_2*0.07).to_i  if up_2 > 32
               when 5
                   up_2 = 45 + (up_2*0.07).to_i  if up_2 > 45
               when 6
                   up_2 = 65 + (up_2*0.07).to_i  if up_2 > 65
               end
               end
      end 
      if self.actor? && self.equips.include?($data_armors[208])
         up_3 = ( (self.kill_size_all) / size ).to_i
         up_3 = 70 if up_3 > 70
               if $game_variables[309] > 0 or $game_switches[743] == true
               case $game_variables[230]
               when 1
                   up_3 = 15 + (up_3*0.07).to_i  if up_3 > 15
               when 2
                   up_3 = 20 + (up_3*0.07).to_i  if up_3 > 20
               when 3
                   up_3 = 25 + (up_3*0.07).to_i  if up_3 > 25
               when 4
                   up_3 = 32 + (up_3*0.07).to_i  if up_3 > 32
               when 5
                   up_3 = 45 + (up_3*0.07).to_i  if up_3 > 45
               when 6
                   up_3 = 65 + (up_3*0.07).to_i  if up_3 > 65
               end
               end
      end 
      up = up_1+up_2+up_3
      return up
  end  
  # 原版加成效果
  # def mhp;  param(0);   end    # 最大HP          Maximum Hit Point
  # def mmp;  param(1);   end    # 最大MP          Maximum Magic Point
  # def atk;  param(2);   end    # 物理攻击        ATtacK power
  # def def;  param(3);   end    # 物理防御        DEFense power
  # def mat;  param(4);   end    # 魔法攻击        Magic ATtack power
  # def mdf;  param(5);   end    # 魔法防御        Magic DeFense power
  # def agi;  param(6);   end    # 敏 捷 值        AGIlity
  # def luk;  param(7);   end    # 幸 运 值        LUcK

  def hit;  xparam(0) + fparam(:hit);  end    # 物理命中几率        HIT rate
  def eva;  xparam(1) + fparam(:eva);  end    # 物理闪避几率        EVAsion rate
  def cri;  xparam(2) + fparam(:cri);  end    # 必杀几率        CRItical rate
  def cev;  xparam(3);  end                   # 闪避必杀几率    Critical EVasion rate
  def mev;  xparam(4);  end                   # 闪避魔法几率    Magic EVasion rate
  def mrf;  xparam(5);  end                   # 反射魔法几率    Magic ReFlection rate
  def cnt;  xparam(6);  end                   # 反击几率        CouNTer attack rate
  def hrg;  xparam(7);  end                   # HP再生速度      Hp ReGeneration rate
  def mrg;  xparam(8);  end                   # MP再生速度      Mp ReGeneration rate
  def trg;  xparam(9);  end                   # TP再生速度      Tp ReGeneration rate

  # 特殊能力
  def tgr;  sparam(0);  end                   # 受到攻击的几率        TarGet Rate
  def grd;  sparam(1);  end                   # 防御效果比率    GuaRD effect rate
  def rec;  sparam(2);  end                   # 恢复效果比率    RECovery effect rate
  def pha;  sparam(3);  end                   # 药理知识        PHArmacology
  def mcr;  sparam(4);  end                   # MP消费率        Mp Cost Rate
  def tcr;  sparam(5);  end                   # TP消耗率        Tp Charge Rate
  def pdr;  sparam(6);  end                   # 物理伤害加成    Physical Damage Rate
  def mdr;  sparam(7);  end                   # 魔法伤害加成    Magical Damage Rate
  def fdr;  sparam(8);  end                   # 地形伤害加成    Floor Damage Rate
  def exr;  sparam(9);  end                   # 经验获得加成    EXperience Rate

  def get_param_plus
    @param_plus
  end

  # 阵型能力加成
  def fparam(ab)
    if $game_party.in_battle && self.index < 5 #&& !self.state?(53) #解阵计状态，个人无法享受阵法效果
      formation = self.actor? ? $game_party.formation : $game_troop.formation
      return formation.send(ab)[self.index]
    else
      return 0
    end
  end

  def deep_crisis?
    hp < (mhp * 0.3)
  end

  def crisis?
    hp < (mhp * 0.5)
  end

  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @hp = @mp = @tp = 0
    @hidden = false
    @atk_animation_id = nil
    clear_param_plus
    clear_states
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # ● 清除能力的增加值
  #--------------------------------------------------------------------------
  def clear_param_plus
    @param_plus = [0] * 8
  end
  #--------------------------------------------------------------------------
  # ● 清除状态信息
  #--------------------------------------------------------------------------
  def clear_states
    @states = []
    @state_turns = {}
    @state_steps = {}
  end

  def clear_states_d
    @states = [] if @states == nil
    stc = 0
    stcl = []
    stcl_turns = {}
    stcl_steps = {}
    for state in @states
      if state != nil 
        if ( $data_states[state].id >= 215 and $data_states[state].id <= 219 ) or ( $data_states[state].id >= 65 and $data_states[state].id <= 69 ) or ( $data_states[state].id == 315 or $data_states[state].id == 316 ) 
        stcl.push(@states[stc])
        stcl_turns[state] = @state_turns[state]
        stcl_steps[state] = @state_steps[state]
      end
      stc += 1
    end
    end
    @states = stcl
    @state_turns = stcl_turns
    @state_steps = stcl_steps
    
  end
  #--------------------------------------------------------------------------
  # ● 消除状态
  #--------------------------------------------------------------------------
  def erase_state(state_id)
    @states.delete(state_id)
    @state_turns.delete(state_id)
    @state_steps.delete(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 清除能力强化信息
  #--------------------------------------------------------------------------
  def clear_buffs
    @buffs = Array.new(8) { 0 }
    @buff_turns = {}
  end
  #--------------------------------------------------------------------------
  # ● 检査是否含有某状态
  #--------------------------------------------------------------------------
  def state?(state_id)
    @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 检査是否含有无法战斗状态
  #--------------------------------------------------------------------------
  def death_state?
    state?(death_state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判断是否陷入了可以解策的状态
  #--------------------------------------------------------------------------
  def check_state?
    state?(40) or state?(41) or state?(27) or state?(28) or state?(29) or state?(31)
  end
  #--------------------------------------------------------------------------
  # ● 获取无法战斗的状态ID
  #--------------------------------------------------------------------------
  def death_state_id
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 获取当前状态的实例数组
  #--------------------------------------------------------------------------
  def states
    @states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取当前状态的图标编号数组
  #--------------------------------------------------------------------------
  def state_icons
    icons = states.collect {|state| state.icon_index }
    icons.delete(0)
    icons
  end
  #--------------------------------------------------------------------------
  # ● 获取当前强化／弱化状态的图标编号数组
  #--------------------------------------------------------------------------
  def buff_icons
    icons = []
    @buffs.each_with_index {|lv, i| icons.push(buff_icon_index(lv, i)) }
    icons.delete(0)
    icons
  end
  #--------------------------------------------------------------------------
  # ● 获取强化／弱化状态的对应图标编号
  #--------------------------------------------------------------------------
  def buff_icon_index(buff_level, param_id)
    if buff_level > 0
      return ICON_BUFF_START + (buff_level - 1) * 8 + param_id
    elsif buff_level < 0
      return ICON_DEBUFF_START + (-buff_level - 1) * 8 + param_id 
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取所有拥有特性的实例的数组
  #--------------------------------------------------------------------------
  def feature_objects
    states
  end
  #--------------------------------------------------------------------------
  # ● 获取所有特性实例的数组
  #--------------------------------------------------------------------------
  def all_features
    feature_objects.inject([]) {|r, obj| r + obj.features }
  end
  #--------------------------------------------------------------------------
  # ● 获取特性实例的数组（限定特性代码）
  #--------------------------------------------------------------------------
  def features(code)
    all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # ● 获取特性实例的数组（限定特性代码和数据ID）
  #--------------------------------------------------------------------------
  def features_with_id(code, id)
    all_features.select {|ft| ft.code == code && ft.data_id == id }
  end
  #--------------------------------------------------------------------------
  # ● 计算特性值的乘积
  #--------------------------------------------------------------------------
  def features_pi(code, id)
    features_with_id(code, id).inject(1.0) {|r, ft| r *= ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 计算特性值的总和（指定数据ID）
  #--------------------------------------------------------------------------
  def features_sum(code, id)
    features_with_id(code, id).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 计算特性值的总和（不限定数据ID）
  #--------------------------------------------------------------------------
  def features_sum_all(code)
    features(code).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 特性的集合和计算
  #--------------------------------------------------------------------------
  def features_set(code)
    features(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的基础值
  #--------------------------------------------------------------------------
  def param_base(param_id)
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的附加值
  #--------------------------------------------------------------------------
  def param_plus(param_id)
      @param_plus[param_id]
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的最小值
  #--------------------------------------------------------------------------
  def param_min(param_id)
    return 0 if param_id == 1  # MMP
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的最大值
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 999999 if param_id == 0  # MHP
    return 9999   if param_id == 1  # MMP
    return 999
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的变化率
  #--------------------------------------------------------------------------
  def param_rate(param_id)
    features_pi(FEATURE_PARAM, param_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的强化／弱化变化率
  #--------------------------------------------------------------------------
  def param_buff_rate(param_id)
    @buffs[param_id] * 0.25 + 1.0
  end

  def param_add_size(param_id)
      a=0
      case param_id
      when 2
      a = (self.element_rate(71)-1.0)*100
      when 3
      a = (self.element_rate(72)-1.0)*100
      when 4
      a = (self.element_rate(73)-1.0)*100
      when 6
      a = (self.element_rate(74)-1.0)*100
      end
      a
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力
  #--------------------------------------------------------------------------
  def param(param_id)
    _param_base = param_base(param_id)
    _param_plus = param_plus(param_id)
    if param_id == 7 and self.actor? 
       _param_plus += lvup_atk
    end
    if param_id == 5 and self.actor? 
       _param_plus += lvup_def
    end
    _param_rate = param_rate(param_id)
    _param_buff_rate = param_buff_rate(param_id)

    value = _param_base + _param_plus 
    value *= _param_rate * _param_buff_rate
    value += param_add_size(param_id)
    #武=2
    #技=3
    #智=4
    #速=6
   

    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  #--------------------------------------------------------------------------
  # ● 获取添加能力
  #--------------------------------------------------------------------------
  def xparam(xparam_id)
    features_sum(FEATURE_XPARAM, xparam_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取特殊能力
  #--------------------------------------------------------------------------
  def sparam(sparam_id)
    features_pi(FEATURE_SPARAM, sparam_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取属性抗性
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    features_pi(FEATURE_ELEMENT_RATE, element_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取弱化抗性
  #--------------------------------------------------------------------------
  def debuff_rate(param_id)
    features_pi(FEATURE_DEBUFF_RATE, param_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取状态抗性
  #--------------------------------------------------------------------------
  def state_rate(state_id)
    features_pi(FEATURE_STATE_RATE, state_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取免疫状态数组
  #--------------------------------------------------------------------------
  def state_resist_set
    features_set(FEATURE_STATE_RESIST)
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否免疫
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    state_resist_set.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取攻击附加属性
  #--------------------------------------------------------------------------
  def atk_elements
    features_set(FEATURE_ATK_ELEMENT)
  end
  #--------------------------------------------------------------------------
  # ● 获取攻击附加状态
  #--------------------------------------------------------------------------
  def atk_states
    features_set(FEATURE_ATK_STATE)
  end
  #--------------------------------------------------------------------------
  # ● 获取攻击附加状态的发动几率
  #--------------------------------------------------------------------------
  def atk_states_rate(state_id)
    features_sum(FEATURE_ATK_STATE, state_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取修正攻击速度
  #--------------------------------------------------------------------------
  def atk_speed
    features_sum_all(FEATURE_ATK_SPEED)
  end
  #--------------------------------------------------------------------------
  # ● 获取添加攻击次数
  #--------------------------------------------------------------------------
  def atk_times_add
    a = features_sum_all(FEATURE_ATK_TIMES)
  end
  #--------------------------------------------------------------------------
  # ● 获取添加技能类型
  #--------------------------------------------------------------------------
  def added_skill_types
    features_set(FEATURE_STYPE_ADD)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能类型是否被禁用
  #--------------------------------------------------------------------------
  def skill_type_sealed?(stype_id)
    features_set(FEATURE_STYPE_SEAL).include?(stype_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取添加的技能
  #--------------------------------------------------------------------------
  def added_skills
    features_set(FEATURE_SKILL_ADD)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能是否被禁用
  #--------------------------------------------------------------------------
  def skill_sealed?(skill_id)
    features_set(FEATURE_SKILL_SEAL).include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能是否需要特殊条件
  #--------------------------------------------------------------------------
  def skill_need?(skill_id)
    # 曹操技能需要孟德新书
    if skill_id == 399 
       return false unless self.armors.include?($data_armors[352])
    end
    if skill_id >= 150 and skill_id <= 159   
       return false if self.state?(8)
    end
    return true
  end  
  #--------------------------------------------------------------------------
  # ● 判定物品是否需要特殊条件
  #--------------------------------------------------------------------------
  def item_need?(item_id)
    if item_id >= 1 and item_id <= 4  
       return false if self.state?(8)
    end
    if item_id >= 11 and item_id <= 13
       return false if self.state?(8)
    end
    if item_id == 25 and $game_variables[133] <= 0 
       return false 
    end
    return true
  end  
  #--------------------------------------------------------------------------
  # ● 判定武器是否可以装备
  #--------------------------------------------------------------------------
  def equip_wtype_ok?(wtype_id)
    features_set(FEATURE_EQUIP_WTYPE).include?(wtype_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定护甲是否可以装备
  #--------------------------------------------------------------------------
  def equip_atype_ok?(atype_id)
    features_set(FEATURE_EQUIP_ATYPE).include?(atype_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否固定武器
  #--------------------------------------------------------------------------
  def equip_type_fixed?(etype_id)
    features_set(FEATURE_EQUIP_FIX).include?(etype_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定装备是否被禁用
  #--------------------------------------------------------------------------
  def equip_type_sealed?(etype_id)
    features_set(FEATURE_EQUIP_SEAL).include?(etype_id)
  end
  #--------------------------------------------------------------------------
  # ● 获取装备风格
  #--------------------------------------------------------------------------
  def slot_type
    features_set(FEATURE_SLOT_TYPE).max || 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否双持武器
  #--------------------------------------------------------------------------
  def dual_wield?
    slot_type == 1
  end
  #--------------------------------------------------------------------------
  # ● 获取添加行动次数几率的数组
  #--------------------------------------------------------------------------
  def action_plus_set
    features(FEATURE_ACTION_PLUS).collect {|ft| ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 判定特殊标志
  #--------------------------------------------------------------------------
  def special_flag(flag_id)
    features(FEATURE_SPECIAL_FLAG).any? {|ft| ft.data_id == flag_id }
  end
  #--------------------------------------------------------------------------
  # ● 获取消失效果
  #--------------------------------------------------------------------------
  def collapse_type
    features_set(FEATURE_COLLAPSE_TYPE).max || 0
  end
  #--------------------------------------------------------------------------
  # ● 判定队伍能力
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    features(FEATURE_PARTY_ABILITY).any? {|ft| ft.data_id == ability_id }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否自动战斗
  #--------------------------------------------------------------------------
  def auto_battle?
    special_flag(FLAG_ID_AUTO_BATTLE)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否擅长防御
  #--------------------------------------------------------------------------
  def guard?
    special_flag(FLAG_ID_GUARD) && movable?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否保护弱者
  #--------------------------------------------------------------------------
  def substitute?
    special_flag(FLAG_ID_SUBSTITUTE) && movable?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否特技专注
  #--------------------------------------------------------------------------
  def preserve_tp?
    special_flag(FLAG_ID_PRESERVE_TP)
  end
  #--------------------------------------------------------------------------
  # ● 添加能力
  #--------------------------------------------------------------------------
  def add_param(param_id, value)
    @param_plus[param_id] += value
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更改 HP 
  #--------------------------------------------------------------------------
  def hp=(hp)
    @hp = hp.to_i
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更改 MP 
  #--------------------------------------------------------------------------
  def mp=(mp)
    @mp = mp.to_i
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 增减 HP （事件用）
  #     value        : 数值
  #     enable_death : 是否允许致死
  #--------------------------------------------------------------------------
  def change_hp(value, enable_death)
    if !enable_death && @hp + value <= 0
      self.hp = 1
    else
      self.hp += value
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改 TP 
  #--------------------------------------------------------------------------
  def tp=(tp)
    @tp = [[tp, max_tp].min, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 获取 TP 的最大值
  #--------------------------------------------------------------------------
  def max_tp
    return 100
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    state_resist_set.each {|state_id| erase_state(state_id) }
    @hp = [[@hp, mhp].min, 0].max
    @mp = [[@mp, mmp].min, 0].max
    @hp == 0 ? add_state(death_state_id) : remove_state(death_state_id)
    if $game_party.in_battle && self.enemy?
      SceneManager.scene.refresh_enemy_state(id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 完全恢复
  #--------------------------------------------------------------------------
  def recover_all
      clear_states
      @hp = mhp
      @mp = mmp
  end
  #--------------------------------------------------------------------------
  # ● 获取 HP 的比率
  #--------------------------------------------------------------------------
  def hp_rate
    @hp.to_f / mhp
  end
  #--------------------------------------------------------------------------
  # ● 获取 MP 的比率
  #--------------------------------------------------------------------------
  def mp_rate
    mmp > 0 ? @mp.to_f / mmp : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取 TP 的比率
  #--------------------------------------------------------------------------
  def tp_rate
    @tp.to_f / 100
  end
  #--------------------------------------------------------------------------
  # ● 隐藏
  #--------------------------------------------------------------------------
  def hide
    @hidden = true
  end
  #--------------------------------------------------------------------------
  # ● 出现
  #--------------------------------------------------------------------------
  def appear
    @hidden = false
  end
  #--------------------------------------------------------------------------
  # ● 获取隐藏状态
  #--------------------------------------------------------------------------
  def hidden?
    @hidden
  end
  #--------------------------------------------------------------------------
  # ● 判定是否存在
  #--------------------------------------------------------------------------
  def exist?
    !hidden?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否死亡
  #--------------------------------------------------------------------------
  def dead?
    exist? && death_state?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否存活
  #--------------------------------------------------------------------------
  def alive?
    exist? && !death_state?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否正常
  #--------------------------------------------------------------------------
  def normal?
    exist? && restriction == 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以输入指令
  #--------------------------------------------------------------------------
  def inputable?
    normal? && !auto_battle?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以行动
  #--------------------------------------------------------------------------
  def movable?
    exist? && restriction < 4
  end
  #--------------------------------------------------------------------------
  # ● 判定是否处于混乱
  #--------------------------------------------------------------------------
  def confusion?
    exist? && restriction >= 1 && restriction <= 3 
  end
  #--------------------------------------------------------------------------
  # ● 是否可以使用阵型（事件用）
  #--------------------------------------------------------------------------
  def reteam?
      movable? && !confusion? && !death_state? && !self.state?(53) && self.unit.can_use_formation_start?
  end
  #--------------------------------------------------------------------------
  # ● 获取混乱等级
  #--------------------------------------------------------------------------
  def confusion_level
    confusion? ? restriction : 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否队友
  #--------------------------------------------------------------------------
  def actor?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敌人
  #--------------------------------------------------------------------------
  def enemy?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 状态排序
  #    依照优先度排列数组 @states，高优先度显示的状态排在前面。
  #--------------------------------------------------------------------------
  def sort_states
    @states = @states.sort_by {|id| [-$data_states[id].priority, id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取限制状态
  #    从当前附加的状态中获取限制最大的状态 
  #--------------------------------------------------------------------------
  def restriction
    states.collect {|state| state.restriction }.push(0).max
  end
  #--------------------------------------------------------------------------
  # ● 获取最重要的状态信息
  #--------------------------------------------------------------------------
  def most_important_state_text
    states.each {|state| return state.message3 unless state.message3.empty? }
    return ""
  end
  #--------------------------------------------------------------------------
  # ● 判定是否装备着使用此技能所需要装备武器
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 计算技能消费的 MP 
  #--------------------------------------------------------------------------
  def skill_mp_cost(skill)
      _down = mcr
      # 减少策路消耗，徐庶改用mcr，不在此处
      _down -= 0.1   if $game_party.exist_jm_skill?(625) and self.actor? and skill.is_hp_damage_marv?
      _down -= 0.25  if $game_party.exist_jm_skill?(685) and self.actor? and skill.is_buff_marv? and self.id == $game_variables[100]
      if skill.is_water_marv?
         _down -= 0.15 if self.equip_wtype_ok?(43)
         _down -= 0.75 if self.state?(111)   #天变水
      end
      _sp = (skill.mp_cost * _down).round

      if skill.is_sow_marv?
         if self.actor?
            _sp = 0  if $game_party.exist_jm_skill?(681) and self.equip_wtype_ok?(30)
         end
      end
      _sp = 0 if self.enemy? && skill.id == 194
      _sp = 0 if _sp < 0
      _sp
  end
  #--------------------------------------------------------------------------
  # ● 计算技能消费的 TP 
  #--------------------------------------------------------------------------
  def skill_tp_cost(skill)
    if self.state?(3)
      _tp = 0
    else
      _tp = skill.tp_cost * self.element_rate(55)
    end

    #if skill.damage.variance == 11 and $game_party.boost < 150
      #_tp = 9999
    #end   
    _tp
  end
  #--------------------------------------------------------------------------
  # ● 计算技能消费的 cp (阵型消耗的boost)
  #--------------------------------------------------------------------------
  def skill_cp_cost(skill)
    skill.hh.to_i 
  end
  #--------------------------------------------------------------------------
  # ● 判定是否足够扣除技能的使用消耗
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    if skill.is_formation?
      $game_party.boost >= skill.hh.to_i
    else
      if skill.id == 3410
        $game_party.gold >= (self.level).to_i * 20 #金钱技能要求
      else
        if skill.id > 456
          return true
        else 
          tp >= skill_tp_cost(skill) && mp >= skill_mp_cost(skill)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 扣除技能的使用消耗
  #--------------------------------------------------------------------------
  def pay_skill_cost(skill)
    if skill.is_formation?
    else
      self.mp -= skill_mp_cost(skill)
      self.tp -= skill_tp_cost(skill)
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查是否可以使用技能／物品
  #--------------------------------------------------------------------------
  def occasion_ok?(item)
      $game_party.in_battle ? item.battle_ok? : item.menu_ok?
  end
  #--------------------------------------------------------------------------
  # ● 检查技能／物品的使用条件（共通）
  #--------------------------------------------------------------------------
  def usable_item_conditions_met?(item)
    movable? && occasion_ok?(item)
  end
  #--------------------------------------------------------------------------
  # ● 检查技能的使用条件
  #--------------------------------------------------------------------------
  def skill_conditions_met?(skill)
    usable_item_conditions_met?(skill) &&
    skill_wtype_ok?(skill) && skill_cost_payable?(skill) &&
    !skill_sealed?(skill.id) && !skill_type_sealed?(skill.stype_id) && skill_need?(skill.id)
  end
  #--------------------------------------------------------------------------
  # ● 检查物品的使用条件
  #--------------------------------------------------------------------------
  def item_conditions_met?(item)
    usable_item_conditions_met?(item) && $game_party.has_item?(item) && item_need?(item.id)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能／使用物品是否可用
  #--------------------------------------------------------------------------
  def usable?(item)
    if item.is_a?(RPG::Skill)
       if item.is_formation?
          #return Config::FORMATION_NEED_MEMBER_COUNT
          return 5
        else
          return skill_conditions_met?(item)
        end
    end

    if item.is_a?(RPG::Item)
       if SceneManager.scene.is_a?(Scene_Map)
          return true
       else
          return item_conditions_met?(item) 
       end  
    end   

    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定物品是否可以装备
  #--------------------------------------------------------------------------
  def equippable?(item)
    return false unless item.is_a?(RPG::EquipItem)
    return false if equip_type_sealed?(item.etype_id)
    return equip_wtype_ok?(item.wtype_id) if item.is_a?(RPG::Weapon)
    return equip_atype_ok?(item.atype_id) if item.is_a?(RPG::Armor)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击的技能 ID
  #--------------------------------------------------------------------------
  def attack_skill_id
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 获取防御的技能 ID
  #--------------------------------------------------------------------------
  def guard_skill_id
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 判定是否能使用普通攻击
  #--------------------------------------------------------------------------
  def attack_usable?
    usable?($data_skills[attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # ● 判定是否能进行防御
  #--------------------------------------------------------------------------
  def guard_usable?
    usable?($data_skills[guard_skill_id])
  end

  def atk_animation_id
    unless @atk_animation_id.nil?
      return @atk_animation_id
    end
    if equip_wtype_ok?(1) || equip_wtype_ok?(3) || equip_wtype_ok?(4) || equip_wtype_ok?(6)
      @atk_animation_id = self.is_a?(Game_Actor) ? 10 : 30
    end
    if equip_wtype_ok?(2)
      @atk_animation_id = self.is_a?(Game_Actor) ? 14 : 34
    end
    if equip_wtype_ok?(5)
      @atk_animation_id = self.is_a?(Game_Actor) ? 18 : 38
    end
    # 忘记设置的情况下为砍动画
    if @atk_animation_id.nil?
      @atk_animation_id = self.is_a?(Game_Actor) ? 10 : 30
    end
    @atk_animation_id
  end

  def maxhp?
    @hp == self.mhp
  end
end
