#encoding:utf-8

# 战前配置范例
# BattleManager.specfg do |cfg|
#   cfg.background = :castle
#   cfg.bgm = "boss"
#   cfg.castle_lv = 6
#   cfg.cant_elements = []
#   cfg.cant_commands = []
# end
#        平原0   雪地1   洼地2  
#        路寨3   村落4 
#        城池5   城内6   驿馆7   古城8   宫殿9   官邸10
#        山角11  山道12  山峰13  山谷14  山林15  窄道16  河道17  
#        洞窟18  皇陵19  石阵20                  
#        关隘21  关内22  
#        渡船23  渡口24  梦境25  密道26  坡道27  练兵28  试炼29
#==============================================================================
# ■ EventBattle
#------------------------------------------------------------------------------
# 　事件战役配置
#==============================================================================
class EventBattle
  BACK = {
    :S9_00 => ["普通试炼",         "29"],
    :S9_01 => ["大将试炼",         "29"],
    :S0_00 => ["调试战斗场景",     "0"],
    :S1_00 => ["第一章平原+水",    "0"],
    :S1_01 => ["第一章平原",       "0",],
    :S1_02 => ["第一章平原栅栏",   "3"],
    :S1_03 => ["第一章洞穴",       "18"],
    :S1_04 => ["第一章关隘",       "21"],
    :S1_05 => ["第一章城池",       "5"],
    :S1_06 => ["第一章村庄",       "4"],
    :S1_07 => ["张角山下",         "11"],
    :S1_08 => ["第一章山道",       "12"],
    :S1_09 => ["张角山顶",         "13"],
    :S1_10 => ["张角山顶夜空",     "13"],
    :S1_11 => ["第一张河道",       "17"],
    :S1_12 => ["第一张石阵",       "20"],
    :S1_13 => ["新手指引",         "5"],
    :S1_99 => ["练兵用",           "28"],
    :S2_99 => ["练兵用",           "28"],
    :S3_99 => ["练兵用",           "28"],
    :S6_99 => ["练兵用",           "28"],
    :S7_99 => ["练兵用",           "28"],
    :S8_99 => ["练兵用",           "28"],
    #---------------------------------------
    :S2_00 => ["第二章平原+水",    "1"],
    :S2_01 => ["第二章平原",       "1"],
    :S2_02 => ["第二章城池",       "5"],
    :S2_03 => ["第二章洛阳",       "5"],
    :S2_04 => ["第二章洛阳起火",   "5"],
    :S2_05 => ["第二章关隘",       "21"],
    :S2_06 => ["第二章关隘起火",   "21"],
    :S2_07 => ["第二章山林",       "15"],
    :S2_08 => ["第2345678章室内",  "7"],
    :S2_09 => ["第二章白马坡+上",  "11"],
    :S2_10 => ["第二章白马坡+平",  "12"],
    :S2_11 => ["第二章路寨",       "4"],
    :S2_12 => ["第二章BOSS许昌",   "5"],
    :S2_13 => ["第二章古城",       "8"],
    :S2_14 => ["第二章徐州山洞",   "18"],
    :S2_15 => ["第二章徐州城内",   "6"],
    :S2_16 => ["第二章徐州洞口",   "1"],
     #---------------------------------------
    :S3_00 => ["第三章平原+水",    "0"],
    :S3_01 => ["第三章平原",       "0"],
    :S3_02 => ["第3+4+5章+普通城池",      "5"],
    :S3_03 => ["第三章村落",       "4"],
    :S3_04 => ["第三章博望山下",   "11"],
    :S3_05 => ["第三章博望白天",   "12"],
    :S3_06 => ["第三章博望晚上",   "12"],
    :S3_07 => ["第三章博望起火",   "12"],
    :S3_08 => ["第三章长坂坡",     "15"],
    :S3_09 => ["第三章后宫密道",   "26"],
    :S3_10 => ["第三章江夏boss",   "5"],
    :S3_11 => ["江陵城内",         "6"],
     #---------------------------------------
    :S4_00 => ["第四章平原+水",     "0"],
    :S4_01 => ["第四章平原",        "0"],
    :S4_02 => ["第四章大臣官邸",   "10"],
    :S4_03 => ["第四章火药山洞",   "18"],
    :S4_04 => ["第四东风+山下",    "11"],
    :S4_05 => ["第四东风+山中",    "12"],
    :S4_06 => ["第四东风+山顶",    "13"],
    :S4_07 => ["第四章蒋干城内",   "6"],
    :S4_08 => ["第四章蔡瑁城池",   "5"],
    :S4_09 => ["草船借箭+水上",    "23"],
    :S4_10 => ["草船借箭+靠岸",    "24"],
    :S4_11 => ["boss曹操船第一战", "23"],
    :S4_12 => ["boss曹操船第二战", "23"],
    :S4_21 => ["曹操逃亡01",       "15"],
    :S4_22 => ["曹操逃亡02",       "27"],
    :S4_23 => ["曹操逃亡03",       "14"],
     #---------------------------------------
    :S5_00 => ["第五章平原+水",       "0"],
    :S5_01 => ["第五章平原",          "0"],
    :S5_03 => ["襄阳+夏侯惇",      "5"],
    :S5_04 => ["取地图山洞",       "18"],
    :S5_05 => ["南郡",             "5"],
    :S5_06 => ["凌零",             "5"],
    :S5_07 => ["贵阳",             "5"],
    :S5_08 => ["武陵",             "5"],
    :S5_09 => ["长沙",             "5"],
    :S5_10 => ["第五章营寨",       "3"],
    :S5_11 => ["羊油弓山洞一层",   "18"],
    :S5_12 => ["羊油弓山洞二层",   "18"],
    :S5_13 => ["大殿",             "9"],
     #---------------------------------------
    :S6_00 => ["第六章平原+水",    "0"],
    :S6_01 => ["第六章平原",       "0"],
    :S6_02 => ["第六章营寨",       "3"],
    :S6_03 => ["马超+葭萌关",      "21"],
    :S6_04 => ["第六章普通关卡",   "21"],
    :S6_05 => ["第六章镇南关",     "21"],
    :S6_06 => ["巴关",             "21"],
    :S6_07 => ["第六章绵竹关+后门","22"],
    :S6_08 => ["第六章绵竹关+起火","22"],
    :S6_11 => ["涪水",             "5"],
    :S6_12 => ["巴城",             "5"],
    :S6_13 => ["汉中",             "5"],
    :S6_14 => ["第六章普通城",     "5"],
    :S6_15 => ["建宁+后门",        "5"],
    :S6_16 => ["越秀",             "5"],
    :S6_17 => ["成都",             "5"],
    :S6_18 => ["越秀+城内",        "6"],
    :S6_21 => ["汉景帝一层",       "19"],
    :S6_22 => ["汉景帝二层",       "19"],
    :S6_23 => ["汉景帝boss",       "19"],
    :S6_31 => ["落凤坡一层",       "12"],
    :S6_32 => ["落凤坡二层",       "12"],
    :S6_33 => ["落凤坡三层",       "14"],
    :S6_41 => ["建宁峡谷",         "16"],
    :S6_51 => ["成都洼地",         "2"],
     #---------------------------------------
    :S7_00 => ["第七章平原+水",    "0"],
    :S7_01 => ["第七章平原",       "0"],
    :S7_02 => ["第七章出门+汉水关","21"],
    :S7_11 => ["第七章普通城池",   "5"],
    :S7_12 => ["天水",             "5"],
    :S7_13 => ["陈仓",             "5"],
    :S7_14 => ["白帝",             "5"],
    :S7_15 => ["南安城内",         "6"],
    :S7_21 => ["街亭关",           "21"],
    :S7_22 => ["祁山关",           "21"],
    :S7_23 => ["斜谷关",           "21"],
    :S7_31 => ["第七章村庄",       "4"],
    :S7_32 => ["六甲天书山洞",     "18"],
    :S7_33 => ["斜谷普通场景",     "14"],
    :S7_41 => ["街亭+下",          "12"],
    :S7_42 => ["街亭+上",          "12"],
    :S7_43 => ["梦境一层",         "25"],
    :S7_44 => ["梦境二层",         "25"],
    #---------------------------------------
    :S8_00 => ["第八章平原+水",    "0"],
    :S8_01 => ["第八章平原",       "0"],
    :S8_03 => ["上庸关",           "21"],
    :S8_04 => ["虎牢",             "21"],
    :S8_05 => ["西郊",             "21"],
    :S8_06 => ["东陌",             "21"],
    :S8_11 => ["许昌",             "5"],
    :S8_12 => ["长安",             "5"],
    :S8_20 => ["五丈原1",          "11"],
    :S8_21 => ["五丈原2",          "12"],
    :S8_22 => ["五丈原3",          "13"],
    :S8_31 => ["子午谷",           "18"],
    :S8_32 => ["子午谷vs",         "18"],
    :S8_41 => ["关卡1",            "21"],
    :S8_42 => ["关卡2",            "21"],
    :S8_51 => ["决战",             "5"],
    :S8_52 => ["决战",             "5"],
    :S8_53 => ["决战",             "5"],
    :S8_54 => ["麦城",             "5"],
    :S8_55 => ["麦城平地",         "1"]
  }
  CantElementsLists = {
    :fire => 1, :water => 2, :wood => 3, :wind => 4, :reco => 5, :imm => 6,
    :dead => 7, :mstat => 8, :alive => 9, :noact=> 10, :esc => 11,
    :addab => 12, :minab => 13, :ref => 14, :abs => 15, :deforma => 16,
    :jingji => 17, :bagua => 18
  }

  attr_accessor :background
  attr_accessor :bgm
  attr_accessor :castle_lv
  attr_accessor :cant_elements
  attr_accessor :cant_commands

  def initialize
    clear
  end
  def clear
    @background = nil # 背景 :camp(营寨) :castle(城) :fire(着火)
    @bgm = nil
    @castle_lv = 0 # 城防等级 0-9
    # 不能使用的属性类型  :fire(火) :water(水) :wood(石) :wind(风) :reco(回复) :imm(免疫) :dead(死亡) :mstat(减状态)
    #                     :alive(复活) :cantact(无法行动) :esc(逃脱) :addab(增加能力)  :minab(降低能力)
    #                      :ref(反弹) :abs(吸收) :deform(解阵) :jingji(静寂) :bagua(八卦)
    @cant_elements = [] 
    @cant_command = [] # 不能使用的命令 :attack :item :marv :skill :formation
    @mode = :normal # :normal :camp :castle :boss 
  end
  def cant_element_ids
    @cant_elements.map{|n|CantElementsLists[n]}
  end
  def background_filename
      BACK[@background]
  end
end

#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　战斗过程的管理器。
#==============================================================================

module BattleManager
  def self.setEventBattle
    if @event_battle.nil?
      self.init_event_battle
    else
      self.clear_battle_event
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    init_members
    $game_troop.setup(troop_id)
    @can_escape = can_escape
    @can_lose = can_lose
    make_escape_ratio
    # $game_party.members.each do |member|
    #   member.init_formation
    # end
  end

  def self.specfg
    @type = :event
    block_given? ? yield(@event_battle) : @event_battle
    #记录CFG背景设置中的名字，读取存档时可以载入，不然无法载入存档事件中的战斗背景
    $game_variables[136] = (yield(@event_battle)).to_s[1,6]
  end

  def self.init_event_battle
    @type = :map
    @event_battle = EventBattle.new
  end

  def self.clear_battle_event
    @event_battle.clear
  end

  def self.event_battle
    @event_battle
  end

  def self.type
    @type
  end

  def self.all_atk
    @all_atk
  end

  def self.set_all_atk(tag)
    @all_atk = tag
  end

  #--------------------------------------------------------------------------
  # ● 初始化成员
  #--------------------------------------------------------------------------
  def self.init_members
    @phase = :init              # 战斗阶段
    @can_escape = false         # 允许撤退的标志
    @can_allatk = true
    @can_lose = false           # 允许全灭的标志
    @event_proc = nil           # 事件用回调
    @preemptive = false         # 先制攻击的标志
    @surprise = false           # 被偷袭的标志
    @actor_index = -1           # 指令输入中的角色
    @action_forced = nil        # 强制的战斗行动
    @now_subject = nil          # 当前行动者
    @map_bgm = nil              # 战斗前的 BGM（记忆用）
    @map_bgs = nil              # 战斗前的 BGS（记忆用）
    @action_battlers = []       # 行动顺序列表
    @all_atk = :over            # 总攻标记 start cancle over
    @view = Viewport.new
    @view.z = 1000
    @view2 = Viewport.new
    @view2.z = 2000
  end

  def self.view(n)
    v = case n
        when 1 ; @view
        when 2 ; @view2
    end
    v 
  end

  #--------------------------------------------------------------------------
  # ● 遇敌时的处理
  #--------------------------------------------------------------------------
  def self.on_encounter
   #  @preemptive = (rand < rate_preemptive)
   # @surprise = (rand < rate_surprise && !@preemptive)
     @preemptive = (rand(100) < 3)
     @surprise   = (rand(100) < 3 && !@preemptive)
  end
  #--------------------------------------------------------------------------
  # ● 获取先制攻击的几率
  #--------------------------------------------------------------------------
  def self.rate_preemptive
    $game_party.rate_preemptive($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # ● 获取被偷袭的几率
  #--------------------------------------------------------------------------
  def self.rate_surprise
    $game_party.rate_surprise($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # ● 保存 BGM 和 BGS
  #--------------------------------------------------------------------------
  def self.save_bgm_and_bgs
    @map_bgm = RPG::BGM.last
    @map_bgs = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # ● 播放战斗 BGM
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    $game_system.battle_bgm.play
    RPG::BGS.stop
  end
  #--------------------------------------------------------------------------
  # ● 播放战斗结束 ME
  #--------------------------------------------------------------------------
  def self.play_battle_end_me
    $game_system.battle_end_me.play
  end
  #--------------------------------------------------------------------------
  # ● 重播 BGM 和 BGS
  #--------------------------------------------------------------------------
  def self.replay_bgm_and_bgs
    @map_bgm.replay unless $BTEST
    @map_bgs.replay unless $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 生成撤退成功率
  #--------------------------------------------------------------------------
  def self.make_escape_ratio                                               
   # @escape_ratio = 1.3 - 1.0 * ( $game_troop.agi / $game_party.agi ) 
   @escape_ratio = (0.6 + $game_party.agi/500.0).round(2)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否回合执行中
  #--------------------------------------------------------------------------
  def self.in_turn?
    @phase == :turn
  end
  #--------------------------------------------------------------------------
  # ● 判定是否回合结束
  #--------------------------------------------------------------------------
  def self.turn_end?
    @phase == :turn_end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否中止战斗
  #--------------------------------------------------------------------------
  def self.aborting?
    @phase == :aborting
  end
  #--------------------------------------------------------------------------
  # ● 获取是否允许撤退
  #--------------------------------------------------------------------------
  def self.can_escape?
    @can_escape
  end

  def self.can_allatk?  
    @can_allatk
  end

  def self.can_escape
    @can_escape = true
  end

  def self.not_escape
    @can_escape = false
  end

  def self.not_allatk
    @can_allatk = false
  end

  def self.can_allatk
    @can_allatk = true
  end
  #--------------------------------------------------------------------------
  # ● 获取指令输入中的角色
  #--------------------------------------------------------------------------
  def self.actor
    @actor_index >= 0 ? $game_party.members[@actor_index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 清除指令输入中的角色
  #--------------------------------------------------------------------------
  def self.clear_actor
    @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 进行下一个指令输入
  #--------------------------------------------------------------------------
  def self.next_command
    begin
      if !actor || !actor.next_command
        if @actor_index >= 0 && actor.alive? && actor.normal?
          actor.animation(:back)
          actor.cmd_active = false
        end
        @actor_index += 1
        return false if @actor_index >= $game_party.members.size
      end
    end until actor.inputable?
    
    actor.animation(:forward)
    
    actor.cmd_active = true
    BattleManager.actor.current_action.clear
    BattleManager.actor.last_skill.object = nil
    return true
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个指令输入
  #--------------------------------------------------------------------------
  def self.prior_command
    begin
      if !actor || !actor.prior_command
        if @actor_index >= 0 && actor.alive? && actor.normal?
          actor.animation(:back)
          actor.cmd_active = false
        end
        @actor_index -= 1
        return false if @actor_index < 0
      end
    end until actor.inputable?
    actor.animation(:forward)
    actor.cmd_active = true
    actor.current_action.clear
    actor.last_skill.object = nil
    return true
  end
  #--------------------------------------------------------------------------
  # ● 设置返回事件的回调用 Proc
  #--------------------------------------------------------------------------
  def self.event_proc=(proc)
    @event_proc = proc
  end
  #--------------------------------------------------------------------------
  # ● 设置等待用方法
  #--------------------------------------------------------------------------
  def self.method_wait_for_message=(method)
    @method_wait_for_message = method
  end
  #--------------------------------------------------------------------------
  # ● 等待信息显示的结束
  #--------------------------------------------------------------------------
  def self.wait_for_message
    @method_wait_for_message.call if @method_wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    # $game_party.on_battle_start
    # $game_troop.on_battle_start

    unless $TEST_ST

      # 测试奔溃 屏蔽文字
      if !$game_test.battle_escape
        # a = ""
        # $game_troop.enemy_names.each do |name|
        # b = name  
        # a = a + b + "、" 
        # end
        # a = a.chop
        # if a != ""
        # $game_message.add(sprintf("敌将"+"「"+a+"」"+"出现！"))
        # end
          
        if @preemptive
          # 先制攻击
          $game_message.add(sprintf("\\c[29]#{$game_party.name}先发制人！\\c[0]", $game_party.name))
          Audio.se_play("Audio/SE/0decide1",100,120)
        elsif @surprise
          # 偷袭
          $game_message.add(sprintf("\\c[10]#{$game_party.name}遭到了敌军的偷袭！\\c[0]", $game_party.name))
          Audio.se_play("Audio/SE/Decision2",100,80)
        end

      end

    end


    wait_for_message
    self.battle_wait(5) #防止战斗对话框闪烁
  end
  #--------------------------------------------------------------------------
  # ● 中止战斗
  #--------------------------------------------------------------------------
  def self.abort
    @phase = :aborting
  end
  #--------------------------------------------------------------------------
  # ● 判定胜败
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
       if $game_party.all_dead?
          $game_switches[395] = false  #战斗结束关闭状态tip提示
          return process_defeat
         end
      # return process_abort   if $game_party.members.empty?
       if $game_troop.all_dead?
          $game_switches[395] = false  #战斗结束关闭状态tip提示
          return process_victory
       end

      return process_abort   if aborting?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 胜利时的处理
  #--------------------------------------------------------------------------
  def self.process_victory
    BattleFiber.over_wave

    if $game_party.formation.id == 12 
      for i in 0...$game_party.alive_members.size
        $game_party.alive_members[i].change_btm_st :normal if $game_party.alive_members[i].hp > 0
        $game_party.alive_members[i].animation_id = 477
      end
      self.battle_wait(140)
    end

    #战斗结束结算伤害数据统计累计到个人
    for i in 0...$game_party.members.size
      ac = $game_party.members[i]
      ac.over_damage_all += ac.over_damage
      ac.over_sup_all    += ac.over_sup
      ac.kill_size_all   += ac.kill_size   #胜利的情况下，才计算击杀数
      #ac.dead_size_all   += ac.dead_size  #死亡的话，不胜利也计算，不在这里统计。
      $game_party.score_damage += ac.over_damage
      $game_party.score_sup += ac.over_sup
    end

    lvbu_skill_ace
    play_battle_end_me
    Audio.bgm_fade(2000)
    Audio.bgm_stop
    SceneManager.scene.show_battle_over_list

    self.battle_wait(10)
    $game_switches[395] = false
    display_exp
    SceneManager.return
    replay_bgm_and_bgs
    battle_end(0)
    return true
  end

  def self.lvbu_skill_ace
    $game_party.members.each do |actor|
      if actor.id == 69 and actor.over_damage_all > 500000 and !actor.skill_is_learn?(173)
        self.battle_wait(80)
        $game_message.face_name = nil
        $game_message.face_index = -1
        $game_message.add("吕布所临之处，敌阵皆破，士卒散乱，将帅尽皆战栗。")
        wait_for_message
        $game_message.add("骑乘赤兔呼啸嘶鸣，敌马匹大惊，皆不能行，阵法大乱致兵将溃不成军。")
        wait_for_message
        $game_message.face_name  = "B_wenwushuangquan"
        $game_message.face_index =  5
        $game_message.add("吕布：汝等杂碎，极限于此。这乱世间，能与吾匹敌之人何在？布定会斩落这无上技艺！")
        wait_for_message
        $game_message.add("吕布：统统觉悟吧，吾之极意尽在于此，吕奉先，真奥义参上！")
        wait_for_message
        $game_message.face_name = nil
        $game_message.face_index = -1
        Audio.se_play("Audio/SE/Decision2",100,80)
        $game_message.add("吕布五十万伤害突破完成，习得武将技\\c[26]「真·武魂天下」\\c[0]")
        actor.learn_skill(173)
        $game_variables[279] << 173
        wait_for_message
      end
    end  
  end  
  #--------------------------------------------------------------------------
  # ● 撤退时的处理
  #--------------------------------------------------------------------------
  def self.process_escape
    success = @preemptive ? true : (rand < @escape_ratio)
    success = true if $game_test.battle_escape || $TEST_ST
    BattleFiber.escape { SceneManager.scene.update_basic }
    SceneManager.scene.my_hide
    @mask = Sprite.new
    @mask.bitmap = Cache.picture("guodu3")
    @mask.x = -1280
    @mask.y = 61
    @mask.z = 900
    @mask.opacity = 0
    for i in 0...30
      if @mask.x < 180
        @mask.x += 36
        @mask.opacity += 12
        self.battle_wait(1)
      end
    end

    if success
      self.battle_wait(10)
      Audio.se_play("Audio/SE/move",100,95)
      process_abort

      # => 无需手动释放
      # dispose_escape_back
    else
      self.battle_wait(1)
      Audio.se_play("Audio/SE/Buzzer1",100,100)
      $game_message.add('\.' + Vocab::EscapeFailure)
      wait_for_message
      l = lambda {
        @escape_ratio += 0.1
        $game_party.clear_actions
      }
      BattleFiber.escape(false,l,lambda{wait_for_message}){ SceneManager.scene.update_basic }
      #@mask.bitmap = Cache.picture("guodu3-1")
      @mask.x -= 200
      self.battle_wait(1)
      for i in 0...10
        #@mask.x += 36
        @mask.opacity -= 26 #if i > 5
        self.battle_wait(1)
      end
      SceneManager.scene.my_show

      # => 无需手动释放
      # dispose_escape_back
    end
    return success
  end

  def self.dispose_escape_back
    if @mask
      @mask.bitmap.dispose ; @mask.dispose
      @mask = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 中止时的处理
  #--------------------------------------------------------------------------
  def self.process_abort
    replay_bgm_and_bgs
    SceneManager.return
    battle_end(1)
    return true
  end

  def self.wait_battle_update(frame)
    frame.times { self.battle_update }
  end

  #--------------------------------------------------------------------------
  # ● 战斗场景的刷新
  #--------------------------------------------------------------------------
  def self.battle_wait(frame = 1)
    frame.times { SceneManager.scene.update_basic }
  end
  #--------------------------------------------------------------------------
  # ● 全灭时的处理
  #--------------------------------------------------------------------------
  def self.process_defeat

    BattleFiber.over_wave
 
    Audio.me_play("Audio/ME/lost",80)
    Audio.bgm_fade(2000)
    self.battle_wait(10)
    Audio.bgm_stop
    SceneManager.scene.show_battle_over_list
    $game_message.add(sprintf("\\c[10]#{$game_party.name}全灭了！\\c[0]", $game_party.name))
  
    wait_for_message

    if @can_lose
      #返回地图bgm
      SceneManager.return
      #replay_bgm_and_bgs #正常情况下战斗失败，回城的，所以无需继续切换BGM。回住宿后自动播放住宿的音乐
      revive_battle_members
      $game_map.screen.start_fadeout(1)
      #淡出画面对应的设置
      $hei = 1
      $game_switches[1] = true
      SceneManager.scene.hide_status
      SceneManager.scene.hide_cname
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 复活参战角色（全灭时）
  #--------------------------------------------------------------------------
  def self.revive_battle_members
    $game_party.battle_members.each do |actor|
      if actor.dead?
         actor.remove_state(1) 
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 战斗结束
  #     result : 结果（0:胜利 1:撤退 2:全灭）
  #--------------------------------------------------------------------------
  def self.battle_end(result)
    @phase = nil
    $game_variables[254] = 0
    @event_proc.call(result) if @event_proc
    $game_party.on_battle_end
    $game_troop.on_battle_end
    #$game_party.init_boost
    $game_party.clear_states
    $game_troop.clear_states
    f_id = $game_party.formation.id
    if f_id != 12 and f_id != 13 and f_id != 15 and f_id != 19
      $game_variables[108] = f_id
    else
      $game_variables[108] = 4
      $game_party.set_formation(4)
      #$game_party.formation.id = 4
    end
    SceneManager.exit if $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 开始输入指令
  #--------------------------------------------------------------------------
  def self.input_start
    if @phase != :input
      @phase = :input
      $game_party.make_actions
      clear_actor
    end
    return !@surprise && $game_party.inputable?
  end
  #--------------------------------------------------------------------------
  # ● 回合开始
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    # 初始化角色索引
    $game_troop.make_actions
    clear_actor
    $game_troop.increase_turn
    # 生成行动顺序
    make_action_orders
  end
  #--------------------------------------------------------------------------
  # ● 回合结束
  #--------------------------------------------------------------------------
  def self.turn_end
    @phase = :turn_end
    @preemptive = false
    @surprise = false
  end
  #--------------------------------------------------------------------------
  # ● 显示获得的经验值
  #--------------------------------------------------------------------------
  def self.display_exp
    if $game_troop.exp_total > 0
      exp  = $game_troop.exp_total
      text = sprintf("获得经验"+" "+"#{exp}点")
      $game_message.add('\.' + text)
      expbook = $game_troop.expbook_total_real
      text = sprintf("获得练兵"+" "+"#{expbook}点")
      $game_message.add('\.' + text)
      if $game_variables[252] != ($game_party.expbook + 850912) * 55
        if $game_variables[253] != $game_party.expbook.to_s[0,3] + "realexpbook"
          $game_party.expbook = rand(255)
        end
      end
      $game_party.expbook += expbook
      $game_variables[252] = ($game_party.expbook + 850912) * 55
      $game_variables[253] = $game_party.expbook.to_s[0,3] + "realexpbook"
    end  
    self.gain_gold
    self.gain_drop_items
    self.gain_exp
  end

  #--------------------------------------------------------------------------
  # ● 显示获得的金钱
  #--------------------------------------------------------------------------
  def self.gain_gold
    if $game_troop.gold_total > 0
      gold = $game_troop.gold_total
      text = sprintf("获得银两"+" "+"#{(gold).to_i}金")
      $game_message.add('\.' + text)
      $game_party.gain_gold(gold)
    end
    #wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 显示获得的物品
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      #$game_message.add(sprintf(Vocab::ObtainItem, item.name))
      #Audio.se_play("Audio/SE/0decide1",85,100)
      $game_message.add("获得物品" + " " + "\\i[#{item.icon_index}]" +item.name )
    
      #阵法购买
      if item != nil and item.class == RPG::Item and item.id >= 125 and item.id <= 141
        a = (item.id.to_i) - 120 
        for i in 0...150
          if $game_actors[i] != nil and !$game_actors[i].skill_is_learn?(a)
            $game_actors[i].learn_skill(a) 
          end
        end
      end
    end

    if $item_add and $item_add != []
      $item_add.each do |item|
        $game_party.gain_item(item, 1)
        $game_message.add("获得物品" + " " + "\\i[#{item.icon_index}]" + item.name )
      end
    end
    $item_add = []
    # wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 显示获得经验值和等级上升
  #--------------------------------------------------------------------------
  def self.gain_exp
    wait_for_message
    $game_party.all_members.each do |actor|
      _exp_total = $game_troop.exp_total
      actor.gain_exp(_exp_total) 
      wait_for_message
    end
    #wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 生成行动顺序
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @action_battlers = []
    @action_battlers += $game_party.members unless @surprise
    @action_battlers += $game_troop.members unless @preemptive
    @action_battlers.each {|battler| battler.make_speed }
    @action_battlers.sort! {|a,b| b.speed - a.speed }
  end
  #--------------------------------------------------------------------------
  # ● 强制行动
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    #自动战斗
    #开关控制角色强制执行战斗指令，而不强制第一个行动。在行动顺序中执行强制
    #开关默认off，会强制第一个行动。当on时：会强制执行战斗指令，但是按照战斗出手顺序
    if $game_switches[427] == true
      @now_subject = battler
    else
      @now_subject = battler
      @action_forced = battler
      @action_battlers.delete(battler)
    end
    #$game_switches[427] = false
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗行动的强制状态
  #--------------------------------------------------------------------------
  def self.action_forced?
    @action_forced != nil
  end
  #--------------------------------------------------------------------------
  # ● 获取强制行动的战斗者
  #--------------------------------------------------------------------------
  def self.action_forced_battler
    @action_forced
  end
  #--------------------------------------------------------------------------
  # ● 清除强制的战斗行动
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @action_forced = nil
  end
  #--------------------------------------------------------------------------
  # ● 获取下一个行动角色
  #    获取处于行动顺序列表顶端的战斗者。
  #    没有获取角色时（index 为 nil, 或者战斗事件在战斗后发生）则跳过此行动。
  #--------------------------------------------------------------------------
  def self.next_subject
    loop do
      battler = @action_battlers.shift
      return nil unless battler
      next unless battler.index && battler.alive?
      @now_subject = battler
      return battler
    end
  end

  def self.now_subject
    @now_subject
  end
end

