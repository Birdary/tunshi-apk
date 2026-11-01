#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　战斗画面
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 战斗结束后
  #--------------------------------------------------------------------------
  def over_damge_add(targets,target,item)
      if target != nil 
        if !item.damage.recover? and @subject.unit != target.unit
           #if target.result.hp_damage > 0
             # @subject.over_damage += target.result.hp_damage
           #end

           #记录死亡次数和击破个数
           if target.dead?
              if @subject.actor?
                 @subject.kill_size += target.d_size
                     if $game_switches[S::CV] == true and @kill_audio == true
                            if $game_troop.alive_members.size == 0 
                               if $game_switches[632] == false 
                                  Audio.se_play("Audio/SE/Actor_first/#{@subject.id}"+"-kill") 
                               else
                                  Audio.se_play("Music/CV/#{@subject.id}"+"-kill") 
                               end
                            else
                                unless BattleManager.all_atk == :start
                                       if $game_switches[632] == false
                                          Audio.se_play("Audio/SE/Actor_first/#{@subject.id}"+"-kill") 
                                       else
                                          Audio.se_play("Music/CV/#{@subject.id}"+"-kill") 
                                       end
                                end       
                            end   
                            @kill_audio = false
                     end
                 else
                 target.dead_size_all += 1 
                 target.dead_size += 1 
                 $game_party.score_dead += 1
              end
           end
           #记录被反弹死的人，也算击破和死亡。
           if @subject.dead?
              if @subject.actor?
                 @subject.dead_size_all += 1 
                 @subject.dead_size += 1 
                 $game_party.score_dead += 1
              else
                 target.kill_size += @subject.d_size
                   if $game_switches[S::CV] == true and target.actor? and @kill_audio == true
                            if $game_troop.alive_members.size == 0 
                               if $game_switches[632] == false 
                                  Audio.se_play("Audio/SE/Actor_first/#{target.id}"+"-kill") 
                               else
                                  Audio.se_play("Music/CV/#{target.id}"+"-kill") 
                               end   
                            else
                               unless BattleManager.all_atk == :start
                                     if $game_switches[632] == false  
                                        Audio.se_play("Audio/SE/Actor_first/#{target.id}"+"-kill")
                                     else
                                        Audio.se_play("Music/CV/#{target.id}"+"-kill")
                                     end
                               end       
                            end
                             @kill_audio = false
                   end
              end
           end
        end
        #辅助计策+sup
        if item.is_marv? and item.note.split("\r\n")[0] != nil and item.note.split("\r\n")[0][0,3] = "sup" 
                 unless target.result.missed
                    @subject.over_sup += (item.note.split("\r\n")[0].split("sup=").last.to_i) * 5
                 end
        end 
        #辅助技能+sup

        if item.is_skill? and  item.note.split("\r\n")[2] != nil and item.note.split("\r\n")[2][0,3] = "sup" 
                 unless target.result.missed
                    @subject.over_sup += (item.note.split("\r\n")[2].split("sup=").last.to_i) * 5
                 end
        end 
        #辅助道具+sup
        if item.is_item? and item.note.split("\r\n")[0] != nil and item.note.split("\r\n")[0][0,3] = "sup" 
                 unless target.result.missed
                    @subject.over_sup += (item.note.split("\r\n")[0].split("sup=").last.to_i) * 5
                 end
        end 
        #辅助阵型+sup
        if item.is_formation?
                    @subject.over_sup += 100
        end 

        #辅助回复+sup
        if item.damage.recover? 
           @subject.over_sup += (target.result.hp_damage * 0.5).to_i
        end

        #个别Dot伤害的处理统计
        #落毒计
        if item.is_marv? and item.id == 191 
               if !target.result.missed
               if target.enemy?
                  du_damage = (target.mhp * 0.12).to_i
                  du_damage = 1500 + rand(500) if du_damage > 1500
               else
                  du_damage = (target.mhp * 0.3).to_i
               end
               @subject.over_damage += du_damage
               end
        end
        #黄泉技能_毒雾
        if item.is_skill? and item.id == 499
               if !target.result.missed
               if target.enemy?
                  du_damage = (target.mhp * 0.12).to_i
                  du_damage = 1500 + rand(500) if du_damage > 1500
               else
                  du_damage = (target.mhp * 0.3).to_i
               end
               @subject.over_damage += du_damage
               end
        end
      end
          
      #如果我军胜利, 判断是否被反弹死胜利 
      if $game_troop.alive_members.size == 0  
          if @subject.unit != target.unit
             if @subject.actor?
                @last_subject = @subject 
             else
                @last_subject = target 
             end
          else
              @last_subject = $game_party.alive_members[0] #最后一下敌人自己打死自己了，默认用第一个活着的角色为mvp
          end   
      end

      #如果我军失败了, 显示敌人第一个头像
      if $game_party.alive_members.size == 0 
         @last_subject = $game_troop.alive_members[0] 
      end    

  end  
  #--------------------------------------------------------------------------
  # ● 攻击次数解除状态(颜良)
  #--------------------------------------------------------------------------
    def akt_remove_state(targets,item)
        n = 100
        @subject.update_mt_turns(n,200) if @subject.state?(n) and item.is_atk?
        n = 81
        @subject.remove_state(n) if @subject.state?(n) and ( item.is_atk? or (item.is_skill? and item.for_opponent?) )
        @subject.remove_state(n) if @subject.state?(n) and item.id == 188 and item.is_marv?
    end
  #--------------------------------------------------------------------------
  # ● 盗贼的被动技能，不上场，只要在队伍中即可触发
  #--------------------------------------------------------------------------
  def bskill_6_7
    #盗贼标记
     if $game_party.exist_bskill?(52,438)
        $add_gold_item = 1
     else
        $item_add = []
        $add_gold_item = 0
     end
  end   
#--------------------------------------------------------------------------
# ● 盗贼
#--------------------------------------------------------------------------
 def bskill_end_52(target,type,item)
     if @subject.id == 52 and item.id == 437 and type == :skill
            wait_for_animation
            targets2 = []
            targets2[0] = @subject
            $item_add = []
            target.make_drop_items.each do |item|
            if item != nil
               show_state_animation(targets2, 959, mirror = false) unless BattleManager.all_atk == :start
               wait_for_animation
               Audio.se_play("Audio/SE/0decide1",100,100)
               text = "从敌将处窃取到了"
               #----------------------------获得道具对话框处理
               text2 = item.name
               back = Sprite.new
               back.bitmap = Bitmap.new("Graphics/System/in_item")
               back.x = 0 ; back.y = 330 ; back.z = 999
               back.bitmap.font.size = 19 + $game_variables[300]
               bitmap_icon = Cache.system("Iconset")
               rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)
               back.bitmap.draw_text(180,23,800,32,text,1)
               back.bitmap.blt(648, 25, bitmap_icon, rect, 255)
               back.bitmap.draw_text(677,23,800,32,text2,0)
               wait(60)
               for i in 0...28
                   back.opacity -= 9
                   wait(1)
               end
               $item_add.push(item)
               back.bitmap.dispose
               back.dispose
               #----------------------------获得道具对话框处理
            end
            end
    end
 end

   #盗贼出场
  def bskill_end_52s
    #我军队伍里有盗贼
    for i in 0...$game_party.alive_members.size
        if $game_party.alive_members[i].id == 52 and i < 5 and $game_party.alive_members[i].hp > 0 
           targets2 = []
           targets2[0] = $game_party.alive_members[i]
           show_state_animation_quick(targets2,960,mirror = false) unless BattleManager.all_atk == :start
           $game_party.gain_gold(targets2[0] .level * -(rand(10)+10) ) 
        end
    end    
  end  
#--------------------------------------------------------------------------
# ● 太史慈被动，每多一个武将，能力提升10% +傀儡娃娃+阴魂娃娃
#--------------------------------------------------------------------------
  def bskill_end_91
    for i in 0...$game_party.alive_members.size
      # 娃娃  
      if $game_party.alive_members[i].element_rate(29) > 1
         $game_party.alive_members[i].add_state_must(168)
      end
      if $game_party.alive_members[i].element_rate(30) > 1
         $game_party.alive_members[i].add_state_must(169)
      end
      # 太史慈
      if $game_party.alive_members[i].id == 91 and i < 5 and $game_party.alive_members[i].hp > 0 
        r = $game_troop.alive_members.size - $game_party.alive_members.size
        if r > 0
          wait_for_animation
          targets = []
          targets[0] = $game_party.alive_members[i]
          show_state_animation(targets,317,mirror = false) unless BattleManager.all_atk == :start
          $game_party.alive_members[i].over_sup += rand(200) #统计
        end
        case r
        when 1 ; $game_party.alive_members[i].add_state(131)
        when 2 ; $game_party.alive_members[i].add_state(132)
        when 3 ; $game_party.alive_members[i].add_state(133)
        when 4 ; $game_party.alive_members[i].add_state(134)
        when 5 ; $game_party.alive_members[i].add_state(135)
        end
      end
    end
  end
      # 太史慈回合
  def bskill_end_91s
    for i in 0...$game_party.alive_members.size
      if $game_party.alive_members[i].id == 91 and i < 5 and $game_party.alive_members[i].hp > 0 
        r = $game_troop.alive_members.size - $game_party.alive_members.size
        if r > 0
           wait_for_animation
           targets = []
           targets[0] = $game_party.alive_members[i]
           show_state_animation(targets,317,mirror = false) unless BattleManager.all_atk == :start
           $game_party.alive_members[i].remove_state(131)
           $game_party.alive_members[i].remove_state(132)
           $game_party.alive_members[i].remove_state(133)
           $game_party.alive_members[i].remove_state(134)
           $game_party.alive_members[i].remove_state(135)
           case r
             when 1 ; $game_party.alive_members[i].add_state_must(131) 
             when 2 ; $game_party.alive_members[i].add_state_must(132)
             when 3 ; $game_party.alive_members[i].add_state_must(133)
             when 4 ; $game_party.alive_members[i].add_state_must(134)
             when 5 ; $game_party.alive_members[i].add_state_must(135)
           end
           $game_party.alive_members[i].over_sup += rand(200)
        else
           $game_party.alive_members[i].remove_state(131)
           $game_party.alive_members[i].remove_state(132)
           $game_party.alive_members[i].remove_state(133)
           $game_party.alive_members[i].remove_state(134)
           $game_party.alive_members[i].remove_state(135)
        end
        wait_for_animation
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 曹操和刘备的被动技能动画和属性效果都在这里
  #--------------------------------------------------------------------------
  def bskill_end_2_63
    #我军队伍里有曹操
    if $game_party.exist_bskill?(63,400)
      for i in 0...$game_party.alive_members.size
        if $game_party.alive_members[i].id == 63 and $game_party.alive_members[i].hp >= $game_party.alive_members[i].mhp and i < 5 
            wait_for_animation
          for c in 0...$game_troop.alive_members.size
            $game_troop.alive_members[c].add_state_must(127)
            targets2 = []
            targets2[0] = $game_troop.alive_members[c] 
            show_state_animation_quick(targets2,321,mirror = false) unless BattleManager.all_atk == :start
            $game_party.alive_members[i].over_sup += rand(200) #统计
          end
        end
      end    
    end    

    # 我军队伍里有刘备
    if  $game_party.exist_bskill?(2,237)
      for i in 0...$game_party.alive_members.size
        if $game_party.alive_members[i].id == 2 and $game_party.alive_members[i].hp >= $game_party.alive_members[i].mhp and i < 5 
           wait_for_animation
          for c in 0...$game_party.alive_members.size
            $game_party.alive_members[c].add_state_must(128)
            targets2 = []
            targets2[0] = $game_party.alive_members[c] 
            show_state_animation_quick(targets2,320,mirror = false) unless BattleManager.all_atk == :start
            $game_party.alive_members[i].over_sup += rand(200) #统计
          end
        end
      end
    end

    # 敌军队伍里有曹操的战斗
    if $game_troop.troop.id == 73 or $game_troop.troop.id == 145 or $game_troop.troop.id == 229 
      wait_for_animation
      for i in 0...$game_party.alive_members.size
        if $game_party.alive_members[i].hp > 0
          $game_party.alive_members[i].add_state_must(127)
          targets2 = []
          targets2[0] = $game_party.alive_members[i]
          show_state_animation_quick(targets2,321,mirror = false) unless BattleManager.all_atk == :start
        end
      end
    end

    #我军队伍里有司马师
      for i in 0...$game_party.alive_members.size
        if $game_party.alive_members[i].equip_wtype_ok?(26) and $game_party.alive_members[i].mp >= $game_party.alive_members[i].mmp and i < 5 and $game_party.alive_members[i].hp > 0
           targets2 = []
           targets2[0] = $game_party.alive_members[i]
           show_state_animation_quick(targets2,970,mirror = false) unless BattleManager.all_atk == :start
           $game_party.alive_members[i].add_state_must(227)
           $game_party.alive_members[i].over_sup += rand(150) #统计
           wait_for_animation
        end
      end    

    # 敌军队伍里有司马师
    for i in 0...$game_troop.alive_members.size
              if $game_troop.alive_members[i].equip_wtype_ok?(26) and $game_troop.alive_members[i].hp > 0
                 targets2 = []
                 targets2[0] = $game_troop.alive_members[i]
                 show_state_animation_quick(targets2,970,mirror = false) unless BattleManager.all_atk == :start
                 $game_troop.alive_members[i].add_state_must(227)
                 $game_troop.alive_members[i].over_sup += rand(150) #统计
                 wait_for_animation
              end
    end


  end    
  #--------------------------------------------------------------------------
  # ● 庞统被动 连续使用计策提升10% 最多50% 状态配合动画+心乱计
  #--------------------------------------------------------------------------  
  def bskill_end_24(target,type,item)
    if  @subject.id == 24 and item.is_hp_damage_marv? and type == :marv and !target.result.missed
      if  @subject.state?(91) or @subject.state?(92) or @subject.state?(93) or @subject.state?(94) or @subject.state?(95) 
        wait_for_animation
        targets2 = []
        targets2[0] = @subject
        show_state_animation(targets2,319,mirror = false) unless BattleManager.all_atk == :start
        if     @subject.state?(91)
          @subject.remove_state(91)
          @subject.add_state_must(85)
        elsif  @subject.state?(92)
          @subject.remove_state(92)
          @subject.add_state_must(86)
        elsif  @subject.state?(93)
          @subject.remove_state(93)
          @subject.add_state_must(87)
        elsif  @subject.state?(94)
          @subject.remove_state(94)
          @subject.add_state_must(88)
        elsif  @subject.state?(95)
          @subject.remove_state(95)
          @subject.add_state_must(89)
        end
      end
    end

    #心乱计
    if item.is_marv? and item.id == 187
      if !target.result.missed
        wait_for_animation
        targets2 = []
        targets2[0] = @subject
        show_state_animation(targets2,270,mirror = false) unless BattleManager.all_atk == :start
        @subject.mp += @subject.mmp*0.1
      end
    end
    #司马师被动
    @subject.remove_state(227) if @subject.state?(227) and item.is_marv? 

  end   

#--------------------------------------------------------------------------
# ● 鲁肃被动，每3回合战气+100
#--------------------------------------------------------------------------
  def bskill_end_50

    #记录回合数
    @turn_size += 1
      for i in 0...$game_party.alive_members.size
        a=$game_party.alive_members[i]
        if @turn_size % 3 == 0
        if a.id == 50 and i < 5 and a.tp < 100 and $game_party.alive_members[i].hp > 0
           wait_for_animation
           targets = []
           targets[0] = a
           show_state_animation(targets,653,mirror = false) unless BattleManager.all_atk == :start
           a.tp += 100
        end
        end
      end


    #黄盖嘲讽起作用
    for i in 0...$game_troop.alive_members.size
        mm = $game_troop.alive_members[i]
          if mm.state?(231)
             mm.remove_state(231)
             mm.add_state_must(232)
          end  
    end    
    for i in 0...$game_party.alive_members.size
        mm = $game_party.alive_members[i]
          if mm.state?(231)
             mm.remove_state(231)
             mm.add_state_must(232)
          end  
    end   





    #岑昏被动2，+DP
    for i in 0...$game_troop.alive_members.size
      a=$game_troop.alive_members[i]
      targets = []
      targets[0] = a
      if a.equip_wtype_ok?(18) and !a.equip_wtype_ok?(19) and !a.equip_wtype_ok?(20)
        unless BattleManager.all_atk == :start
          show_state_animation_quick(targets,931,mirror = false) 
          wait(5)
          targets = []
          targets = $game_troop.alive_members
          targets.delete_if { |a| a.equip_wtype_ok?(18) }
          show_state_animation_quick(targets,932,mirror = false) 
          wait_for_animation
        end
        for i in 0...$game_troop.alive_members.size
          b= $game_troop.alive_members[i]
           if b.dp < 30
              b.dp += 1.25
              a.over_sup += 50 if a != nil #统计
            end
        end     
      end

      $game_troop.alive_members[i].add_state_must(225) if $game_troop.alive_members[i].state?(224)
    end     

    for i in 0...$game_party.alive_members.size
      a=$game_party.alive_members[i]
      targets = []
      targets[0] = a
      if a.equip_wtype_ok?(18) and a.movable? and !a.confusion?
        unless BattleManager.all_atk == :start
          show_state_animation_quick(targets,930,mirror = false) 
          wait(5)
          targets = []
          targets = $game_party.alive_members
          targets.delete_if { |a| a.equip_wtype_ok?(18) }
          show_state_animation_quick(targets,932,mirror = false) 
          wait_for_animation
        end
        for i in 0...$game_party.alive_members.size
          b= $game_party.alive_members[i]
          b.tp += 8
        end
          a.over_sup += 50 if a != nil #统计
      end
    end

    $game_party.alive_members.each do |actor|
       actor.add_state_must(225) if actor.state?(224)
    end
    $game_troop.alive_members.each do |enemy|
       enemy.add_state_must(225) if enemy.state?(224)
    end

end
#--------------------------------------------------------------------------
# ● 虎伍阵回合结束后，每回合都施加伤害
#--------------------------------------------------------------------------
def wuhu_skill_turn_end #虎伍阵伤害
  if $game_party.formation.id == 15 
    damage = 0
    ok = 0
    w = -1
    d = 0
    targets = []
    targets_actor = []
    for i in 0...$game_party.alive_members.size
      ac = $game_party.alive_members[i]
      ac.add_state_must(13) if !ac.state?(13)
      if ac.tp == 100  and ok == 0 and #ac.state?(13)
        actor = ac
        ok = 1
        targets_actor[0] = actor
      end
      if ac.hp > 0
        d += $game_party.alive_members[i].hp
        w += 1
      end
    end

    for i in 0...$game_troop.alive_members.size
      if  w >= i                                                  
          $game_troop.alive_members[i].result.hp_damage = (d*(  rand(200)+200  )*0.00020).to_i #最高总HP的5%
          $game_troop.alive_members[i].result.critical = false
          targets[i] = $game_troop.alive_members[i]
          damage += $game_troop.alive_members[i].result.hp_damage 
      end
    end

    if $game_troop.alive_members.size > 0 and ok > 0
       actor.tp = 0 
       actor.remove_state(3)
       #统计
       actor.over_damage += damage  if damage != nil
      if BattleManager.all_atk == :start
        $turn_damage = -1
        show_state_animation_quick(targets,58,mirror = false) 
      else
        $turn_damage = -1
        show_state_animation_quick(targets_actor,363,mirror = false) 
        wait_for_animation
        show_state_animation_quick(targets,365,mirror = false) 
      end
      $game_party.incr_boost 10
      wait_for_animation
      au = 0

      for i in 0...targets.size
        if targets[i].hp == 0
          targets[i].set_animation(:dead)
          targets[i].animation_id = RPG::Animation::DEAD_ID
          targets[i].change_btm_st :dead
          wait_for_animation
          _battler = targets[i]
          _unit = targets[i].unit
          @last_subject = actor
               if $game_troop.alive_members.size == 0
                   if $game_switches[S::CV] == true and @last_subject.actor? and au == 0
                      if $game_switches[632] == false 
                         Audio.se_play("Audio/SE/Actor_first/#{@last_subject.id}"+"-kill")
                         else
                         Audio.se_play("Music/CV/#{@last_subject.id}"+"-kill") 
                      end
                   end   
               else
                  unless BattleManager.all_atk == :start
                         if $game_switches[S::CV] == true and @last_subject.actor? and au == 0
                            if $game_switches[632] == false 
                               Audio.se_play("Audio/SE/Actor_first/#{@last_subject.id}"+"-kill") 
                            else
                               Audio.se_play("Music/CV/#{@last_subject.id}"+"-kill") 
                            end
                         end   
                  end
               end
               au = 1
          if _unit.formation?
            if _unit.is_bagua
              if _unit.alive_gate.eql?(_battler)
                formation_sankai!(_unit)
              else
                formation_sankai!(_unit) if !_unit.can_use_formation?
              end
            else
                formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          end
        end
      end

      for i in 0...$game_troop.alive_members.size
        $game_troop.alive_members[i].result.clear 
      end

      $turn_damage = 0
    end
  end


  #五子阵伤害

  if $game_troop.formation.id == 20
    damage = 0
    targets = []
    d = 0
    for i in 0...$game_troop.alive_members.size
      d+= $game_troop.alive_members[i].hp
    end

    for i in 0...$game_party.alive_members.size   
      if $game_troop.members.size > 5 
         $game_party.alive_members[i].result.hp_damage = (d*(  rand(150)+150  )*0.00003).to_i 
      else                                       
         $game_party.alive_members[i].result.hp_damage = (d*(  rand(150)+150  )*0.00004).to_i #最高总HP的4%
      end
      $game_party.alive_members[i].result.critical = false
      targets[i] = $game_party.alive_members[i]
      damage = $game_party.alive_members[i].result.hp_damage 
    end

    for i in 0...$game_troop.alive_members.size
            #统计
      $game_troop.alive_members[i].over_damage += damage if damage != nil
    end

    if BattleManager.all_atk == :start
      $turn_damage = -1
      show_state_animation_quick(targets,58,mirror = false) 
    else
      $turn_damage = -1
      show_state_animation_quick($game_troop.alive_members,351,mirror = false) 
      wait_for_animation
      show_state_animation_quick(targets,352,mirror = false) 
    end
    $game_party.cost_boost 10
    wait_for_animation


    for i in 0...targets.size
      if targets[i].hp == 0
        targets[i].set_animation(:dead)
        targets[i].animation_id = RPG::Animation::DEAD_ID
        targets[i].change_btm_st :dead
        wait_for_animation
        _battler = targets[i]
        _unit = targets[i].unit
        if _unit.formation?
          if _unit.is_bagua
            if _unit.alive_gate.eql?(_battler)
              formation_sankai!(_unit)
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          else
            formation_sankai!(_unit) if !_unit.can_use_formation?
          end
        end
      end
    end

    for i in 0...$game_party.alive_members.size
      $game_party.alive_members[i].result.clear 
    end

    $turn_damage = 0
  end
end



#岑昏被动2-吸
def bskill_end_CH(target)
  if target != nil and target.equip_wtype_ok?(18) and target.result.hp_damage > 0 and @subject.unit != target.unit 
    if target.enemy?
      if target.dp >= 5 
        target.dp -= 5 if !target.state?(3)
        ok = 1
      end
    else
      if target.tp >= 15 
        target.tp -= 15 if !target.state?(3)
        ok = 1
      end
    end   

    if ok == 1
      targets=[]
      targets[0]=target
      unless BattleManager.all_atk == :start
        show_state_animation_quick(targets,933,mirror = false) 
      else
           if target.actor?
              show_state_animation_quick($game_party.alive_members,296,mirror = false) 
           else
              show_state_animation_quick($game_party.alive_members,293,mirror = false) 
           end
      end
      wait_for_animation
      if target.actor?
        $game_party.incr_boost 8
      else
        $game_party.cost_boost 8 
      end
      ok=0
    end
  end
end

#--------------------------------------------------------------------------
# ● 甘宁新主动，回复效果。
#--------------------------------------------------------------------------
def bskill_end_93(item)
  if  item.is_water_marv? and $game_party.alive_members.size > 0 and $game_troop.alive_members.size > 0 
      ac = 0
      for i in 0...$game_party.alive_members.size
          a = $game_party.alive_members[i]
          ac = a  if a.equip_wtype_ok?(32)  and a.state?(109) and a.movable?
      end
      if  ac != 0
          targets=[]
          targets[0]=ac
          wait_for_animation
          ac.result.hp_damage = (ac.mhp * 0.05)
          ac.result.hp_damage = (ac.result.hp_damage * ac.element_rate(5)).to_i
          ac.result.critical = false
          unless BattleManager.all_atk == :start
                 show_state_animation_quick(targets,304,mirror = false) 
          else
                 show_state_animation_quick(targets,296,mirror = false) 
          end
          ac.add_state_must(149)
          ac.over_sup += (ac.result.hp_damage * 0.5).to_i
          wait_for_animation
      ac=0
      end


      #敌人甘宁
      for i in 0...$game_troop.alive_members.size
          a = $game_troop.alive_members[i]
          ac = a  if a.equip_wtype_ok?(32)  and a.state?(109) and a.movable?
      end    
      if  ac != 0
          targets=[]
          targets[0]=ac
          wait_for_animation
          ac.result.hp_damage = (ac.mhp * 0.05)
          ac.result.hp_damage = (ac.result.hp_damage  * ac.element_rate(5)).to_i
          ac.result.critical = false
          unless BattleManager.all_atk == :start
                 show_state_animation_quick(targets,304,mirror = false) 
          else
                 show_state_animation_quick(targets,296,mirror = false) 
          end
          ac.add_state_must(149)
          wait_for_animation
      ac=0
      end
  end
end

def bskill_end_bls(targets)
  $turn_damage = -1
  fw_actor=0
  fw_enemy=0
  targets_a=[]
  m = 25
 
  if  @subject.equip_wtype_ok?(17) and @subject.movable? and @subject.mp > m
    @subject.mp -= m
    if  @subject.actor?
      fw_actor = 1   
    else
      fw_enemy = 1  
    end  
  end

  if fw_enemy == 1
    p = rand($game_party.alive_members.size)
    a = $game_party.alive_members[p]
  end
  if fw_actor == 1
    p = rand($game_troop.alive_members.size)
    a = $game_troop.alive_members[p]
  end

  if fw_enemy == 1 or fw_actor == 1
    targets_a[0] = a
    if a.state?(166)
      if fw_enemy == 1
         a.result.hp_damage  = 300#0.15*(enemy.atk*2+(enemy.hp/10.0))*(0.2+enemy.int/77.5)*(1-a.def/(a.def+75.0))
      else
         actor = @subject
         a.result.hp_damage  = 0.5*(actor.atk*2+(actor.mhp/10.0))*(0.2+actor.int/77.5)*(1-a.def/(a.def+75.0))
         a.result.hp_damage *= 1+(actor.int - 215)*0.04 if actor.int > 215
      end
      a.result.hp_damage  = 5 if a.result.hp_damage < 5
      # 统计 无需统计伤害，步练师的被动算在行动内
      # @subject.over_damage += a.result.hp_damage.to_i
      a.result.critical = false
      if BattleManager.all_atk == :start
        show_state_animation_quick(targets_a,58,mirror = false) 
      else
        targets2 = []
        targets2[0] = @subject
        show_state_animation_quick(targets2,922,mirror = false) 
        wait(30)
        show_state_animation_quick(targets_a,926,mirror = false) 
      end
      wait_for_animation
      a.remove_state(166)
    else       
      if BattleManager.all_atk == :start
      else
        targets2 = []
        targets2[0] = @subject
        show_state_animation_quick(targets2,922,mirror = false) 
        wait(30)
        show_state_animation_quick(targets_a,923,mirror = false) 
        wait_for_animation
      end
      a.add_state_must(166)
    end    



    for i in 0...targets_a.size
      if targets_a[i].hp == 0
         if @subject.actor?
            @subject.kill_size += targets_a[i].d_size
         else
            targets_a[i].dead_size += 1
         end
        targets_a[i].set_animation(:dead)
        targets_a[i].animation_id = RPG::Animation::DEAD_ID
        targets_a[i].change_btm_st :dead
        wait_for_animation
        _unit = targets_a[i].unit
        _battler = targets_a[i]
               if $game_troop.alive_members.size == 0
                  if $game_switches[S::CV] == true and @subject.actor?
                     if $game_switches[632] == false 
                        Audio.se_play("Audio/SE/Actor_first/#{@subject.id}"+"-kill") 
                     else
                        Audio.se_play("Music/CV/#{@subject.id}"+"-kill") 
                     end
                   end 
               else
                  unless BattleManager.all_atk == :start
                      if $game_switches[S::CV] == true and @subject.actor?
                         if $game_switches[632] == false 
                            Audio.se_play("Audio/SE/Actor_first/#{@subject.id}"+"-kill") 
                         else
                            Audio.se_play("Music/CV/#{@subject.id}"+"-kill") 
                         end
                      end
                  end
               end
               if _unit.formation?
                  if _unit.is_bagua
                     if _unit.alive_gate.eql?(_battler)
                        formation_sankai!(_unit)
                     else
                        formation_sankai!(_unit) if !_unit.can_use_formation?
                     end
                  else
                     formation_sankai!(_unit) if !_unit.can_use_formation?
                  end
               end
              #被动击败敌人后，从数组中删除，避免对人攻击，并且判断胜负
              if @subject.actor?
                 targets.delete_if { |a| (a.hp == 0 and a.enemy?) }
                 targets[0] = $game_troop.alive_members[0] if targets == [] and $game_troop.alive_members.size > 0
              else
                 targets.delete_if { |a| (a.hp == 0 and a.actor?) }
                 targets[0] = $game_party.alive_members[0] if targets == [] and $game_party.alive_members.size > 0
              end
              if $game_party.alive_members.size == 0 or $game_troop.alive_members.size == 0
                 $game_party.clear_actions
                 @subject.remove_current_action
                 process_action_end
              end
      end #if
    end #for

  end   
   
   $turn_damage = 0
   wait_for_animation
end

#--------------------------------------------------------------------------
# ● 剧本动画，回合结束后
#--------------------------------------------------------------------------

def fire_turn_end #剧本放火
  $game_switches[693] = false
  au = 0
  talk_size = 0
  donghua_id = $game_variables[132]
  ok = 0
  for i in 0...$game_party.alive_members.size
    if $game_party.alive_members[i].state?(60)
      ok = 1
    end  
  end

  if ok == 1
    targets = []

    for i in 0...$game_party.alive_members.size
      hp_damage_ = ( rand($game_party.alive_members[i].mhp/12).to_i + ($game_party.alive_members[i].mhp/15).to_i ) + $game_variables[131] 
      hp_damage_ = 50 if hp_damage_ < 50
      $game_party.alive_members[i].result.hp_damage = hp_damage_
      $game_party.alive_members[i].result.critical = false
      $game_troop.over_plot_damage += $game_party.alive_members[i].result.hp_damage
      targets[i] = $game_party.alive_members[i]
    end

    if BattleManager.all_atk == :start
      $turn_damage = -1
      show_state_animation_quick(targets,58,mirror = false) 
    else
      $turn_damage = -1
      $game_switches[400] = true
      $game_message.add("#{$animation_message}")
      wait_for_message
      $game_switches[400] = false
      show_state_animation(targets,donghua_id,mirror = false) 
    end
    wait_for_animation
    talk_size = 1


    $turn_damage = -1
    $game_switches[400] = true
    #$game_message.add("#{$animation_message}")
    wait_for_message
    $game_switches[400] = false

    for i in 0...targets.size
      if targets[i].hp == 0
        targets[i].set_animation(:dead)
        targets[i].animation_id = RPG::Animation::DEAD_ID
        targets[i].change_btm_st :dead
        wait_for_animation
        _unit = targets[i].unit
        _battler = targets[i]
        if _unit.formation?
          if _unit.is_bagua
            if _unit.alive_gate.eql?(_battler)
              formation_sankai!(_unit)
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          else
            formation_sankai!(_unit) if !_unit.can_use_formation?
          end
        end
      end
    end

    for i in 0...$game_party.alive_members.size
      $game_party.alive_members[i].result.clear 
    end

    $turn_damage = 0


    ok = 0
  end
   
  #-------敌人------------------------------------------------------------
  ok = 0
  for i in 0...$game_troop.alive_members.size
    if $game_troop.alive_members[i].state?(60)
      ok = 1
    end  
  end

  if ok == 1
        targets = []
    
    for i in 0...$game_troop.alive_members.size
      if $game_switches[700] == true
         $game_troop.alive_members[i].result.hp_damage = (rand($game_troop.alive_members[i].mhp/20).to_i + ($game_troop.alive_members[i].mhp/20).to_i )
      else
         $game_troop.alive_members[i].result.hp_damage = (rand($game_troop.alive_members[i].mhp/10).to_i + ($game_troop.alive_members[i].mhp/20).to_i ) + $game_variables[131] 
      end
      $game_troop.alive_members[i].result.critical = false
      targets[i] = $game_troop.alive_members[i]
      $game_party.over_plot_damage += $game_troop.alive_members[i].result.hp_damage
    end

    if BattleManager.all_atk == :start
      $turn_damage = -1
      show_state_animation_quick(targets,58,mirror = false) 
    else
      $turn_damage = -1
      #如果我方已经说过话了，敌人就不说，不可能存在说两次。
      if talk_size == 0
        $turn_damage = -1
        $game_switches[400] = true
        $game_message.add("#{$animation_message}")
        wait_for_message
        $game_switches[400] = false
      end
      talk_size = 0
      show_state_animation(targets,donghua_id,mirror = false) 
    end
    wait_for_animation

    for i in 0...targets.size
      if targets[i].hp == 0
        targets[i].set_animation(:dead)
        targets[i].animation_id = RPG::Animation::DEAD_ID
        targets[i].change_btm_st :dead
        wait_for_animation
        _unit = targets[i].unit
        _battler = targets[i]
              if $game_troop.alive_members.size == 0
                if $game_switches[S::CV] == true and  @last_subject != nil and @last_subject and @last_subject.actor? and au == 0
                   if $game_switches[632] == false 
                      Audio.se_play("Audio/SE/Actor_first/#{@last_subject.id}"+"-kill") 
                   else
                      Audio.se_play("Music/CV/#{@last_subject.id}"+"-kill")
                   end
                end 
              else
                  unless BattleManager.all_atk == :start
                         if $game_switches[S::CV] == true and @last_subject != nil and @last_subject and @last_subject.actor? and au == 0
                            if $game_switches[632] == false 
                               Audio.se_play("Audio/SE/Actor_first/#{@last_subject.id}"+"-kill") 
                            else
                               Audio.se_play("Music/CV/#{@last_subject.id}"+"-kill") 
                            end
                         end
                  end
              end
               au = 1
        if _unit.formation?
          if _unit.is_bagua
            if _unit.alive_gate.eql?(_battler)
              formation_sankai!(_unit)
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          else
            formation_sankai!(_unit) if !_unit.can_use_formation?
          end
        end
      end
    end

    for i in 0...$game_troop.alive_members.size
      $game_troop.alive_members[i].result.clear 
    end

    $turn_damage = 0
    ok = 0
  end
$game_switches[693] = true
end
#--------------------------------------------------------------------------
# ● 寂静阵法回合结束后，每回合都施加新的状态
#--------------------------------------------------------------------------
def jing_star #影身
  a=[]
  w=0
  if $game_party.formation.id == 12 
    for i in 0...$game_party.alive_members.size
      if !$game_party.alive_members[i].state?(5300)
        $game_party.alive_members[i].change_btm_st :normal 
        a[w] = $game_party.alive_members[i]
        w+=1
      end
    end
    show_state_animation_quick(a,477,mirror = false) 
    wait_for_animation
    for i in 0...$game_party.alive_members.size
      if !$game_party.alive_members[i].state?(5300)
        $game_party.alive_members[i].change_btm_st :jing 
        $game_party.alive_members[i].add_state_must(16)
      end
    end
   end

  if $game_troop.formation.id == 12 
    for i in 0...$game_troop.alive_members.size
      if !$game_troop.alive_members[i].state?(5300) and $game_troop.alive_members[i].index != 5
        $game_troop.alive_members[i].change_btm_st :normal 
        a[w] = $game_troop.alive_members[i]
        w+=1
      end
    end
    show_state_animation_quick(a,477,mirror = false) 
    wait_for_animation
    for i in 0...$game_troop.alive_members.size
      if !$game_troop.alive_members[i].state?(5300) and $game_troop.alive_members[i].index != 5
        $game_troop.alive_members[i].change_btm_st :jing 
        $game_troop.alive_members[i].add_state_must(16)
      end
    end
  end
end

def jing_clear(_unit) #启动任何阵型前，如果有寂静存在，先清除。这里的判断和被敌人打散阵型，相反。
  #wait_for_animation
  a=[]
  if $game_party.formation.id == 12 and _unit.is_a?(Game_Troop)
    for i in 0...$game_party.alive_members.size
      $game_party.alive_members[i].change_btm_st :normal
      $game_party.alive_members[i].remove_state(16)
      a[i] = $game_party.alive_members[i]
    end
    show_state_animation_quick(a,477,mirror = false) 
    wait_for_animation
  end
  if _unit.is_a?(Game_Party) and $game_troop.formation.id == 12 
    for i in 0...$game_troop.alive_members.size
      if $game_troop.alive_members[i].index != 5 
        $game_troop.alive_members[i].change_btm_st :normal 
        $game_troop.alive_members[i].remove_state(16)
        a[i] = $game_troop.alive_members[i]
      end
    end 
    show_state_animation_quick(a,477,mirror = false)
    wait_for_animation
  end
end


def jing_over(_unit)
  a=[]
  if $game_party.formation.id == 12 and _unit.is_a?(Game_Party)
    for i in 0...$game_party.alive_members.size
      $game_party.alive_members[i].change_btm_st :normal
      $game_party.alive_members[i].remove_state(16)
      a[i] = $game_party.alive_members[i]
    end
    show_state_animation_quick(a,477,mirror = false) 
    wait_for_animation
  end
  if _unit.is_a?(Game_Troop) and $game_troop.formation.id == 12 
    for i in 0...$game_troop.alive_members.size
      if $game_troop.alive_members[i].index != 5
      $game_troop.alive_members[i].change_btm_st :normal 
      $game_troop.alive_members[i].remove_state(16)
      a[i] = $game_troop.alive_members[i]
      end
    end 
    show_state_animation_quick(a,477,mirror = false)
    wait_for_animation
  end
end

def jing_turn #寂静回合结束效果
  if $game_party.formation.id == 12
    for i in 0...$game_party.alive_members.size
      $game_party.alive_members[i].change_btm_st :normal 
    end
    show_state_animation_quick($game_party.alive_members,477,mirror = false) 
    wait_for_animation
    for i in 0...$game_party.alive_members.size
      $game_party.alive_members[i].remove_state(16)
    end
  end

  if $game_troop.formation.id == 12
    for i in 0...$game_troop.alive_members.size
      $game_troop.alive_members[i].change_btm_st :normal  if  $game_troop.alive_members[i].index != 5 
    end
    show_state_animation_quick($game_troop.alive_members,477,mirror = false) 
    wait_for_animation
    for i in 0...$game_troop.alive_members.size
      $game_troop.alive_members[i].remove_state(16) if  $game_troop.alive_members[i].index != 5 
    end
  end
end

def bskill_end_jz_jing(targets,type,item) #解阵计 寂静
  if item.id == 198 and type == :marv 
    if ($game_party.formation.id == 12 and @subject.enemy?) or 
      ($game_troop.formation.id == 12 and @subject.actor?)
      a = []
      w = 0
      for i in 0...targets.size
        if !targets[i].result.missed and targets[i].index != 5
          a[w] = targets[i]
          w+=1
        end
      end
      show_state_animation_quick(a, 477, mirror = false)
      for i in 0...targets.size
        if !targets[i].result.missed 
          targets[i].change_btm_st :normal  
          targets[i].remove_state(16)
        end
      end
      wait_for_animation
    end
  end
end

#--------------------------------------------------------------------------
# ● 八卦阵法回合结束后，每回合都施加新的状态
#--------------------------------------------------------------------------
  def bskill_end_bagua
    #八卦添加随机状态
    if $game_party.formation != nil and $game_party.formation.id == 13
      wait_for_animation
      show_state_animation_quick($game_party.alive_members,475,mirror = false) unless BattleManager.all_atk == :start
      wait_for_animation
      $game_party.alive_gate = $game_party.alive_members[rand($game_party.alive_members.size)]
      for i in 0...$game_party.alive_members.size
        $game_party.alive_members[i].remove_state(14)
        $game_party.alive_members[i].remove_state(15)
        $game_party.alive_members[i].remove_state(288)
        $game_party.alive_members[i].remove_state(289)
        $game_party.alive_members[i].remove_state(290)
        $game_party.alive_members[i].remove_state(291)
        $game_party.alive_members[i].remove_state(292)
        $game_party.alive_members[i].remove_state(293)
        $game_party.alive_members[i].remove_state(294)
        $game_party.alive_members[i].remove_state(295)
        $game_party.alive_members[i].remove_state(296)
        $game_party.alive_members[i].remove_state(297)
        if $game_party.alive_members[i].index != $game_party.alive_gate.index
           $game_party.alive_members[i].add_state_must(rand(8)+288) 
        else
           $game_party.alive_members[i].add_state_must(14) #真.生门标记
        end
      end
    end     
    if  $game_troop.formation != nil and $game_troop.formation.id == 13 and $game_troop.turn_count%2 == 0
      wait_for_animation
      a = []
      for i in 0...$game_troop.alive_members.size
        a[i] = $game_troop.alive_members[i] if $game_troop.alive_members[i].index != 5 
      end 
      show_state_animation_quick(a,475,mirror = false) unless BattleManager.all_atk == :start
      wait_for_animation
      if $game_troop.alive_members.size == 6
        op = rand(5)
      else
        op = rand($game_troop.alive_members.size)
      end
      for i in 0...$game_troop.alive_members.size
        $game_troop.alive_members[i].remove_state(14)
        $game_troop.alive_members[i].remove_state(15)
        $game_troop.alive_members[i].remove_state(288)
        $game_troop.alive_members[i].remove_state(289)
        $game_troop.alive_members[i].remove_state(290)
        $game_troop.alive_members[i].remove_state(291)
        $game_troop.alive_members[i].remove_state(292)
        $game_troop.alive_members[i].remove_state(293)
        $game_troop.alive_members[i].remove_state(294)
        $game_troop.alive_members[i].remove_state(295)
        $game_troop.alive_members[i].remove_state(296)
        $game_troop.alive_members[i].remove_state(297)
        if $game_troop.alive_members[i].index != 5

          if i != op  
            $game_troop.alive_members[i].add_state_must(rand(10)+288) 
          else
            if $game_switches[446] == true
              $game_troop.alive_members[i].add_state_must(14) 
            else
              $game_troop.alive_members[i].add_state_must(15) 
            end
            $game_troop.set_bagua $game_troop.alive_members[i]
          end
        end
      end
    end 
  end     

  def bskill_end_bm
      for i in 0...$game_party.alive_members.size
        if $game_party.alive_members[i].equip_wtype_ok?(55) 
           $game_party.alive_members[i].remove_state(300)
           $game_party.alive_members[i].remove_state(301)
           $game_party.alive_members[i].remove_state(302)
           $game_party.alive_members[i].remove_state(303)
           $game_party.alive_members[i].remove_state(304)
           $game_party.alive_members[i].remove_state(305)
           $game_party.alive_members[i].remove_state(306)
           $game_party.alive_members[i].remove_state(307)
           if $game_party.alive_members[i].mp > 0 
              $game_party.alive_members[i].add_state_must(rand(8)+300) 
              $game_party.alive_members[i].mp -= ($game_party.alive_members[i].mmp * 0.03).to_i if $game_troop.turn_count >= 1 
           end
        end
      end     
  end       
#--------------------------------------------------------------------------
# ● 孙坚被动，15%hp以下触发主动技能
#--------------------------------------------------------------------------
  def bskill_end_60
    for i in 0...$game_party.alive_members.size
      if $game_party.alive_members[i].id == 60 and i < 5 and $game_party.alive_members[i].hp > 0 
        if $game_party.alive_members[i].hp < $game_party.alive_members[i].mhp * 0.15 
          if $game_party.alive_members[i].state?(98)
          else
            wait_for_animation
            targets = []
            targets[0] = $game_party.alive_members[i]
            $game_party.alive_members[i].add_state(98)
            show_state_animation(targets,611,mirror = false) unless BattleManager.all_atk == :start
            $game_party.alive_members[i].over_sup += rand(80) #统计
          end
        else
          $game_party.members[i].remove_state(98)   
        end
      end
    end
  end
#--------------------------------------------------------------------------
# ● 马岱每2轮攻击，附加一个攻击BUFF，有动画显示
#--------------------------------------------------------------------------
  def bskill_end_17
    #记录回合数
    for i in 0...$game_party.alive_members.size
      if $game_party.alive_members[i].id == 17 and i < 5 and $game_party.alive_members[i].hp > 0 
        if $game_party.alive_members[i].attack_count >= 4 
          $game_party.alive_members[i].attack_count = 0
          wait_for_animation
          targets = []
          targets[0] = $game_party.alive_members[i]
          show_state_animation(targets,311,mirror = false) unless BattleManager.all_atk == :start
          $game_party.alive_members[i].add_state_must(114)
        end
      end
    end
  end

#--------------------------------------------------------------------------
# ● 孔明天变
#--------------------------------------------------------------------------
  def bskill_end_23(type,item)
      @move_up = 0
      if @subject.id == 23 and type == :skill 
         wait_for_animation
         item = item
         @spriteset.create_km_picture(item)
         @km = true
         @km_c = 0
         if @subject.skill_is_learn?(330)
            @km_c = 3 if item.id == 286 #地
            @km_c = 2 if item.id == 287 #水
            @km_c = 1 if item.id == 288 #火
            @km_c = 4 if item.id == 289 #风
         end   
      end   
  end
#--------------------------------------------------------------------------
# ● 孔明天变回合
#--------------------------------------------------------------------------
  def bskill_end_23_hh
      if @km_c != nil and @km_c > 0
         actor = []
         for i in 0...$game_party.alive_members.size
         if $game_party.alive_members[i].id == 23
             actor = $game_party.alive_members[i]
             if @km_c == 3
                actor.add_state_must(312) 
             elsif @km_c == 1
                actor.add_state_must(313) 
             else
                actor.add_state_must(311) 
             end
         end
         end
         return if actor == []

        au = 0
        add_skill = []
        add_skill = Array.new(actor.skills)
        add_skill.delete_if { |item| item.damage.element_id != @km_c }
        #add_skill = (add_skill.last).id + 1
        add_skill = add_skill[rand(add_skill.size)].id + 1
        skill = $data_skills[add_skill]

        targets = []
        for i in 0...$game_troop.alive_members.size
          targets[i] = $game_troop.alive_members[i]
          $turn_damage = -2
          $game_troop.alive_members[i].item_apply1(actor,skill)
          $game_troop.alive_members[i].result.critical = false
          actor.over_damage += $game_troop.alive_members[i].result.hp_damage
        end

        if BattleManager.all_atk == :start
          show_state_animation(targets, 58, mirror = false)
        else
          show_state_animation(targets, skill.animation_id, mirror = false)
        end
        wait_for_animation

    for i in 0...targets.size
      if targets[i].hp == 0
        actor.kill_size += targets[i].d_size
        targets[i].set_animation(:dead)
        targets[i].animation_id = RPG::Animation::DEAD_ID
        targets[i].change_btm_st :dead
        wait_for_animation
        _unit = targets[i].unit
        _battler = targets[i]
              if $game_troop.alive_members.size == 0
                if $game_switches[S::CV] == true and  @last_subject != nil and @last_subject and @last_subject.actor? and au == 0
                   if $game_switches[632] == false 
                      Audio.se_play("Audio/SE/Actor_first/#{actor.id}"+"-kill") 
                   else
                      Audio.se_play("Music/CV/#{actor.id}"+"-kill")
                   end
                end 
              else
                  unless BattleManager.all_atk == :start
                         if $game_switches[S::CV] == true and actor != [] and au == 0
                            if $game_switches[632] == false 
                               Audio.se_play("Audio/SE/Actor_first/#{actor.id}"+"-kill") 
                            else
                               Audio.se_play("Music/CV/#{actor.id}"+"-kill") 
                            end
                         end
                  end
              end
               au = 1
        if _unit.formation?
          if _unit.is_bagua
            if _unit.alive_gate.eql?(_battler)
              formation_sankai!(_unit)
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          else
              formation_sankai!(_unit) if !_unit.can_use_formation?
          end
        end
      end
    end
    $turn_damage = 0
    actor.remove_state(311)
    actor.remove_state(312)
    actor.remove_state(313)
  end
  end
#--------------------------------------------------------------------------
# ● 天变结束
#--------------------------------------------------------------------------
  def bskill_end_23_over
      return unless @km == true
      km_over = true
      for i in 0...$game_party.alive_members.size
        a=$game_party.alive_members[i]
           if a.state?(110) or a.state?(111) or a.state?(112) or a.state?(113) 
              km_over = false
           end 
      end
      if km_over == true
         @spriteset.km_picture_over 
         @km = false
         @km_c = 0
      end
  end
#--------------------------------------------------------------------------
# ● 天书
#--------------------------------------------------------------------------
  def bskill_end_book(target,type,item)
    @move_up = 0
    if  @subject.actor? and type == :item and item.damage.variance == 13
      @subject.add_state_must(96)
      @move_up = 1 #不上前动画
      case item.id 
        when 17
        @subject.force_action(161,0)
        when 18
        @subject.force_action(162,0)
        when 19
        @subject.force_action(163,0)
        when 20
        @subject.force_action(164,0)
      end
      BattleManager.clear_action_force
      process_action
      wait_for_animation
      @move_up = 1
      @subject.remove_state(96)
    end
  end

  #--------------------------------------------------------------------------
  # ● 马良+hp 持续加血
  #--------------------------------------------------------------------------
  def bskill_end_26
    #记录回合数
    for i in 0...$game_party.alive_members.size
      if $game_party.alive_members[i].state?(115) and i < 5 and $game_party.alive_members[i].hp > 0 and !$game_party.alive_members[i].state?(57)
        if $game_party.alive_members[i].hp == $game_party.alive_members[i].mhp
           $game_party.alive_members[i].remove_state(115)
        else
          wait_for_animation
          targets = []
          targets[0] = $game_party.alive_members[i]
          targets[0].result.clear
          targets[0].result.hp_damage = ($game_party.alive_members[i].mhp * 0.1 * $game_party.alive_members[i].element_rate(5))
          if BattleManager.all_atk == :start
             Audio.se_play("Audio/SE/Saint6")
             show_state_animation(targets,315,mirror = false)
          else
             show_state_animation(targets,312,mirror = false)
          end
          wait_for_animation
              #统计
              for i in 0...$game_party.alive_members.size
                $game_party.alive_members[i].over_sup += (targets[0].result.hp_damage).to_i  if $game_party.members[i].id == 26
              end
        end
      end

      #七星灯
      if $game_party.alive_members[i].element_rate(39) > 1  and $game_party.alive_members[i].hp < $game_party.alive_members[i].mhp * 0.5 and !$game_party.alive_members[i].state?(57)
        wait_for_animation
        targets = []
        targets[0] = $game_party.alive_members[i]
        targets[0].result.clear
        targets[0].result.hp_damage = ($game_party.alive_members[i].mhp * 0.05 * $game_party.alive_members[i].element_rate(5))
        targets[0].result.hp_damage *= 0.6 if $game_party.formation.id == 12
        if BattleManager.all_atk == :start
          Audio.se_play("Audio/SE/Saint6")
          show_state_animation(targets,315,mirror = false)
        else
          show_state_animation(targets,297,mirror = false)
        end
        targets[0].mp += (targets[0].mmp * 0.03).to_i
        targets[0].over_sup += rand(100) #统计
        #统计
        $game_party.alive_members[i].over_sup += ($game_party.alive_members[i].result.hp_damage*0.5).to_i 
        wait_for_animation
      end
    end
  end
#--------------------------------------------------------------------------
# ● 青囊书 第一回合加血
#--------------------------------------------------------------------------
  def bskill_end_QNS
    if @turn_size == 1
      qns = 0
      for i in 0...$game_party.al.size
        if $game_party.al[i].element_rate(27) > 1 and i < 5 and $game_party.al[i].hp > 0 and $game_party.al[i].mp > 55
          qns = $game_party.al[i].element_rate(27)-1
          actor = $game_party.al[i]
          $game_party.al[i].mp -= 55 
        end
      end

      if qns > 0  
        for i in 0...$game_party.members.size  
          if $game_party.members[i].hp > 0
            targets = []
            targets[0] = $game_party.members[i]
            targets[0].result.clear
            targets[0].result.hp_damage = ($game_party.members[i].mhp * qns).to_i * $game_party.members[i].element_rate(5)
            if BattleManager.all_atk == :start
              show_state_animation_quick(targets,296,mirror = false)
            else
              show_state_animation_quick(targets,295,mirror = false)
            end
              #统计
              actor.over_sup += (targets[0].result.hp_damage * 0.5).to_i if actor != nil 
          end
        end
      end
    end
  end
#--------------------------------------------------------------------------
# ● 祝融被动死亡自动复活
#--------------------------------------------------------------------------
  def bskill_end_39
    for i in 0...$game_party.members.size
      if $game_party.members[i].id == 39 and $game_party.members[i].dead? and rand(100) > 40
         wait_for_animation
         $game_party.members[i].result.hp_damage = ($game_party.members[i].mhp * 0.1).to_i
         $game_party.members[i].animation_id = 287
         wait_for_animation
         show_dead_and_alive_animation($game_party.members[i], $data_items[49])
         $game_party.members[i].hp = ($game_party.members[i].mhp * 0.1).to_i
        #统计
         $game_party.members[i].over_sup += ($game_party.members[i].mhp * 0.05).to_i
         wait(1)
      end
    end
  end

#--------------------------------------------------------------------------
# ● 周瑜，火属性计策附加伤害(灼伤)
#--------------------------------------------------------------------------
  def bskill_end_58(target,type,item)
    if (@subject.id == 58 or @subject.id == 312 or @subject.id == 592 or @subject.id == 696) 
      if !target.result.missed and type == :marv and target.result.hp_damage > 0 and item.is_fire_marv? and target.hp >0
        $turn_damage = -1
        target.result.critical = false
        targets2 = []
        targets2[0] = target
        targets2[0].result.hp_damage = target.result.hp_damage/10
        targets2[0].result.hp_damage = 5 if targets2[0].result.hp_damage < 5
        if BattleManager.all_atk == :start
          show_state_animation(targets2, 58, mirror = false)
        else
          show_state_animation(targets2, 307, mirror = false)
        end
        wait_for_animation
      end
      $turn_damage = 0
    end
 end
#--------------------------------------------------------------------------
# ● 郭嘉，水属性计策附加冰玉
#--------------------------------------------------------------------------
   def bskill_end_29(target,type,item)
    if @subject.element_rate(60) > 1
      if !target.result.missed and type == :marv and target.result.hp_damage > 0 and item.is_water_marv? and target.hp >0
             r = 0
             r = @subject.atk_states_rate(145) * 100
              if r <= 0
                 r = 8
                 r = 17    if !item.for_one? 
              else
                 r = r*0.3  if !item.for_one? 
              end
          if r > rand(100) and target.unit != @subject.unit
             wait(25)
             targets2 = []
             targets2[0] = target
             if BattleManager.all_atk == :start
                show_state_animation(targets2, 58, mirror = false)
             else
                show_state_animation(targets2, 328, mirror = false)
             end
             target.add_state(145)
             wait_for_animation
          end
      end
    end
 end


  def bskill_end_yq(targets,item)
    if @subject.element_rate(37) > 1 
      team = []
      if @subject.actor?
        team = $game_troop.alive_members
      else
      team = $game_party.alive_members
      end
      #$turn_damage = -1
      target = targets[0]
      #第二个目标
      if target.hp == 0 and !target.result.missed and target.result.hp_damage > 0 and team.size > 0
            if @subject.actor?
               $game_party.incr_boost 8
               @subject.kill_size += target.d_size
            else
               $game_party.incr_boost 8
            end
        targets_dead = []
        targets_dead[0] = target 
        a=[]
        for i in 0...team.size
          a[i] = team[i].hp
        end
        a=a.index(a.min)
        targets2 = []
        targets2[0] = team[a]
        targets2[0].item_apply1(@subject, $data_skills[433])
        if BattleManager.all_atk == :start
          show_state_animation(targets2, 58, mirror = false)
        else
          show_state_animation(targets2, 834, mirror = false)
        end
        wait_for_animation
        team = []
        if @subject.actor?
          team = $game_troop.alive_members
        else
          team = $game_party.alive_members
        end

        #第三个目标
        if targets2[0].hp == 0 
            if @subject.actor?
               $game_party.incr_boost 8
               @subject.kill_size += targets2[0].d_size
            else
               $game_party.incr_boost 8
            end
          targets_dead[1] = targets2[0]
          if team.size > 0
            a=[]
            for i in 0...team.size
              a[i] = team[i].hp
            end
            a=a.index(a.min)
            targets3 = []
            targets3[0] = team[a]
            targets3[0].item_apply1(@subject, $data_skills[434])
            if BattleManager.all_atk == :start
              show_state_animation(targets3, 58, mirror = false)
            else
              show_state_animation(targets3, 834, mirror = false)
            end
            wait_for_animation
            targets_dead[2] = targets3[0]  if targets3[0].hp == 0
          end
        end
      end      

      #回来----------------
      @subject.change_btm_st :normal 
      subject_=[]
      subject_[0] = @subject
      if BattleManager.all_atk == :start
        show_state_animation(subject_, 58, mirror = false)
      else
        if @subject.actor?
        show_state_animation(subject_, 954, mirror = false)
        else
        show_state_animation(subject_, 891, mirror = false)
        end
      end

      #死亡-----------------
      if targets_dead != nil 
        for i in 0...targets_dead.size
          if targets_dead[i].hp == 0
            targets_dead[i].set_animation(:dead)
            targets_dead[i].animation_id = RPG::Animation::DEAD_ID
            targets_dead[i].change_btm_st :dead
            wait_for_animation
            _unit = targets_dead[i].unit
            _battler = targets[i]
            if _unit.formation?
              if _unit.is_bagua
                if _unit.alive_gate.eql?(_battler)
                  #  formation_sankai!(_unit)
                else
                  #  formation_sankai!(_unit) if !_unit.can_use_formation?
                end
              else
                # formation_sankai!(_unit) if !_unit.can_use_formation?
              end
            end
          end
        end   
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 张苞 技能50%晕眩 
  #--------------------------------------------------------------------------
  def bskill_end_15(target,type,item)
    if  @subject.id == 15 and item.id == 271 # or item.id == 375 or item.id == 463
      if !target.result.missed and type == :skill and target.result.hp_damage > 0 and target.hp > 0
        wait_for_animation
        targets2 = []
        targets2[0] = target
        if  rand(100) < 50
          target.add_state(122) #张苞 二回合
          show_state_animation(targets2, 313, mirror = false) unless BattleManager.all_atk == :start
          @subject.over_sup += rand(100) #统计
        end
      end
    end

    #孙尚香武将技
    if @subject.id == 94 and item.id == 411
       if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          if @subject.str < target.str
             wait_for_animation
             targets2 = []
             targets2[0] = target
             target.add_state(122) #张苞 二回合
             show_state_animation(targets2, 313, mirror = false) unless BattleManager.all_atk == :start
             @subject.over_sup += rand(100) #统计
          end
       end
    end  

  end
  #--------------------------------------------------------------------------
  # ● 刘封 主动技能，血少返还战气 
  #--------------------------------------------------------------------------
  def bskill_end_16(target,type,item)
      if @subject.id == 16 and item.id == 274 and item.is_skill? 
         if !target.result.missed and target.result.hp_damage > 0 and target.hp < @subject.hp
             unless @subject.state?(228)
                    wait_for_animation
                    targets2 = []
                    targets2[0] = @subject
                    show_state_animation(targets2, 247, mirror = false) unless BattleManager.all_atk == :start
                    wait(10)
                    @subject.tp += 100
                    @subject.add_state_must(228) 
             end
         end
      end    
  end    
  #--------------------------------------------------------------------------
  # ● 孙策减少法力值
  #--------------------------------------------------------------------------
  def bskill_end_59(target,type,item)
    if  @subject.id == 59 and item.id == 367
      if !target.result.missed and type == :skill and target.result.hp_damage > 0 and target.hp >0
        wait_for_animation
        wait(15)
        targets2 = []
        targets2[0] = target
        show_state_animation(targets2, 671, mirror = false) unless BattleManager.all_atk == :start
        target.mp -= ( (target.result.hp_damage * (10+rand(5))*0.01) + (target.mmp * 0.07) ).to_i
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 星彩 技能使用后自身速度提升至255
  #--------------------------------------------------------------------------
  def bskill_end_18(target,type,item)
    if  @subject.id == 18 and item.id == 280 
      if  type == :skill and !target.result.missed
          targets2 = []
          targets2[0] = @subject
          show_state_animation(targets2, 318, mirror = false) unless BattleManager.all_atk == :start
          wait_for_animation
          @subject.add_state_must(125)
          @subject.over_sup += rand(100) #统计
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 周泰普通攻击吸血 for 总攻 or 正常 +项羽护手攻击吸血
  #--------------------------------------------------------------------------
  def bskill_end_90_allatk(target,targets)
    if @subject.trg > 0 #and type == :atk
      wait_for_animation
      target = targets[0]
      if  !target.result.missed and target.result.hp_damage > 0 
      wait_for_animation
      targets2 = []
      targets2[0] = @subject
      @subject.result.hp_damage = (target.result.hp_damage * @subject.trg *  @subject.element_rate(5)).to_i
      @subject.result.hp_damage = 5 if  @subject.result.hp_damage < 5
      #统计
      @subject.over_sup += (@subject.result.hp_damage * 0.5).to_i
      show_state_animation(targets2, 309, mirror = false)
      end
    end
    #平A卖血-总攻
    if @subject.element_rate(50) != 1.0 and !target.result.missed and @subject.hp > @subject.mhp * ( 1 - @subject.element_rate(50) )
      $turn_damage = -1
      wait_for_animation
      targets2 = []
      targets2[0] = @subject
      targets2[0].result.critical = false
      @subject.result.hp_damage = @subject.hp * ( 1 - @subject.element_rate(50) )
      show_state_animation(targets2, 58, mirror = false)
      wait_for_animation
      $turn_damage = 0
    end
    #平A吸蓝-总攻
    if @subject.element_rate(51) > 1.0 and !target.result.missed and @subject.mmp > @subject.mp and target.result.hp_damage > 0 and @subject.hp > 0 
      $turn_damage = -1
      wait_for_animation
      targets2 = []
      targets2[0] = @subject
      @subject.mp += (@subject.mmp * ( @subject.element_rate(51) - 1 ).round(2)).to_i
      @subject.over_sup += rand(50) #统计
      show_state_animation(targets2, 294, mirror = false)
      wait_for_animation
      $turn_damage = 0
    end
    #平A减战气-总攻
    if @subject.element_rate(56) != 1.0 and rand < @subject.element_rate(56)  and !target.result.missed and target.result.hp_damage > 0 and @subject.hp > 0  and target.hp > 0 
      $turn_damage = -1
      targets2 = []
      targets2[0] = target
      wait_for_animation
      if target.actor?
        target.tp -= 10 
      else
        target.dp -= 10 if target.dp > 0
      end
      $turn_damage = 0
    end

    #三重剑-总攻
    if @subject.element_rate(57) > 1.0 and !@subject.state?(202) and @subject.attack_count >= 3 and @subject.attack_count % 3 == 0 and  @subject.hp > 0
       #if target != nil and !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          @subject.add_state_must(202) if @subject.state?(201)
          @subject.add_state_must(201) if @subject.state?(200)
          @subject.add_state_must(200) if @subject.state?(199)
          @subject.add_state_must(199) if @subject.state?(198)
          @subject.add_state_must(198) 
       #end
    end  
  end

  def bskill_end_90(targets,type,item)
    target = targets[0]
    if @subject.trg > 0 and (type == :atk or (@subject.id == 90 and type == :skill) or (@subject.id == 16 and type == :skill))
      if !target.result.missed and target.result.hp_damage > 0 
        wait_for_animation
        targets2 = []
        targets2[0] = @subject
        @subject.result.hp_damage = (target.result.hp_damage * @subject.trg * @subject.element_rate(5)).to_i
        @subject.result.hp_damage = (target.result.hp_damage * 0.45) if @subject.id == 90 and type == :skill
        @subject.result.hp_damage = 5 if  @subject.result.hp_damage < 5
        #统计
        @subject.over_sup += (@subject.result.hp_damage * 0.5).to_i
        show_state_animation(targets2, 308, mirror = false)
      end
    end
    #平A卖血
    if @subject.element_rate(50) != 1.0 and type == :atk and !target.result.missed and @subject.hp > @subject.mhp * ( 1 - @subject.element_rate(50) )
      $turn_damage = -1
      wait_for_animation
      targets2 = []
      targets2[0] = @subject
      targets2[0].result.critical = false
      @subject.result.hp_damage = @subject.mhp * ( 1 - @subject.element_rate(50) )
      show_state_animation(targets2, 336, mirror = false)
      wait_for_animation
      $turn_damage = 0
    end
    #平A吸蓝
    if @subject.element_rate(51) > 1.0 and type == :atk and !target.result.missed and @subject.mmp > @subject.mp and target.result.hp_damage > 0 and @subject.hp > 0 
      $turn_damage = -1
      wait_for_animation
      targets2 = []
      targets2[0] = @subject
      @subject.mp += (@subject.mmp * ( @subject.element_rate(51) - 1 ).round(2)).to_i
      @subject.over_sup += rand(100) #统计
      show_state_animation(targets2, 270, mirror = false)
      wait_for_animation
      $turn_damage = 0
    end
    #平A减战气
    if type == :atk and @subject.element_rate(56) != 1.0 and rand < @subject.element_rate(56)  and !target.result.missed and target.result.hp_damage > 0 and @subject.hp > 0 and target.hp > 0
      $turn_damage = -1
      wait_for_animation
      if target.actor?
        target.tp -= 10 
      else
        target.dp -= 5 if target.dp > 0
        target.dp = 0   if target.dp < 0
      end
      show_state_animation(targets, 330, mirror = false)
      wait_for_animation
      $turn_damage = 0
    end
    #三重剑
    #if @subject.element_rate(57) > 1.0 and !@subject.state?(202) and @subject.attack_count % @subject.element_rate(57).to_i == 0 and  @subject.hp > 0
    if @subject.element_rate(57) > 1.0 and !@subject.state?(202) and @subject.attack_count >= 3 and @subject.attack_count % 3 == 0 and  @subject.hp > 0 and item.is_atk?
       #if  target != nil and !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
           targets = []
           targets[0] = @subject
           show_state_animation(targets,322,mirror = false)
           @subject.add_state_must(202) if @subject.state?(201)
           @subject.add_state_must(201) if @subject.state?(200)
           @subject.add_state_must(200) if @subject.state?(199)
           @subject.add_state_must(199) if @subject.state?(198)
           @subject.add_state_must(198) 
       #end   
     end
  end
#--------------------------------------------------------------------------
# ● 魏延15%击晕 + 晕锤效果
#--------------------------------------------------------------------------
  def bskill_end_8(target,targets,type)
    if targets[0] != nil 
      if (( targets[0].state?(116) and @subject.state?(248)) or ( targets[0].state?(122) and @subject.id == 8 and type == :skill) ) and (type == :atk or (@subject.id == 16 and type == :skill) or (@subject.id == 8 and type == :skill)) 
        @subject.remove_state(248)
        target = targets[0]
        if  !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          wait_for_animation
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 313, mirror = false) unless BattleManager.all_atk == :start
        end
      end
    end   
  end

#--------------------------------------------------------------------------
# ● 黄浩主动技能
#--------------------------------------------------------------------------
  def bskill_end_552(target,type,item)
    if @subject.element_rate(42) > 1.0 and type == :skill
      if @subject.actor?
        targets2 = []
        w = 0
        for i in 0...$game_party.alive_members.size
          if $game_party.alive_members[i].element_rate(42) <= 1.0
            targets2[w] = $game_party.alive_members[i]
            w += 1
          end
        end
        wait_for_animation
        show_state_animation(targets2, 905, mirror = false) unless BattleManager.all_atk == :start
        wait_for_animation
        for i in 0...$game_party.alive_members.size
          $game_party.alive_members[i].add_state_must(194) if $game_party.alive_members[i].element_rate(42) <= 1.0
        end
      else
        targets2 = []
        w = 0
        for i in 0...$game_troop.alive_members.size
          if $game_troop.alive_members[i].element_rate(42) <= 1.0
            targets2[w] = $game_troop.alive_members[i]
            w += 1
          end
        end
        wait_for_animation
        show_state_animation(targets2, 905, mirror = false) unless BattleManager.all_atk == :start
        wait_for_animation
        for i in 0...$game_troop.alive_members.size
          $game_troop.alive_members[i].add_state_must(194) if $game_troop.alive_members[i].element_rate(42) <= 1.0
        end
      end
    end
  end

   #黄浩吸收
   def bskill_end_552_b(targets,type)
     if targets[0] != nil and targets[0].element_rate(42) > 1.0 and type == :atk and !targets[0].result.missed and @subject.hp > 0 and targets[0].mp > 55 and  targets[0].hp > 0 and targets[0].result.hp_damage > 0
        if rand(100) > 0.89 and targets[0].unit != @subject.unit
        targets2 = []
        targets2[0] = targets[0]
        targets2[0].result.hp_damage = targets[0].result.hp_damage * 1.5 
        show_state_animation(targets2, 942, mirror = false) 
        wait_for_animation
        wait(30)
        #统计
        targets[0].over_sup += (targets[0].result.hp_damage*0.5).to_i
        end
     end
    end   

   #总攻
   def bskill_end_552_b_allatk(target,targets)
     if targets[0].element_rate(42) > 1.0 and targets[0] != nil and !targets[0].result.missed and @subject.hp > 0 and targets[0].mp > 55 and  targets[0].hp > 0 and targets[0].result.hp_damage > 0
        if rand(100) > 0.89 and targets[0].unit != @subject.unit
        wait_for_animation
        targets2 = []
        targets2[0] = targets[0]
        targets2[0].result.hp_damage = targets[0].result.hp_damage * 2
        show_state_animation(targets2, 296, mirror = false) 
        wait_for_animation
        #统计
        targets[0].over_sup += (targets[0].result.hp_damage*0.5).to_i
        end
     end
    end   


  def bskill_end_540(targets,type,item)
    if type == :skill and item.id == 540
      wait_for_animation
      for i in 0...targets.size
        if !targets[i].result.missed and !targets[i].state?(3) 
            targets[i].tp -= 50
            #targets[i].remove_state(3) if targets[i].state?(3)
        end
      end
    end
  end
#--------------------------------------------------------------------------
# ● 诸葛连弩被动技能-【觉醒】
#--------------------------------------------------------------------------
  def bskill_end_two_atk(target,targets,type)

    unless @subject.opponent_unit.all_dead? || @subject.dead?
      if @subject.state?(114)  and  @nn == -2 
      elsif @subject.state?(114) and  @nn == -1 
        @subject.add_state_must(129)
      elsif @subject.equip_wtype_ok?(5) and @nn == -1
      elsif @two_atk > @nn and @subject.hp > 0 and type == :atk #and targets[0].hp > 0
        wait_for_animation
        wait(10)
        targets2 = []
        targets2[0] = @subject
        show_state_animation(targets2, 337, mirror = false) unless BattleManager.all_atk == :start
        @subject.add_state_must(129)  #攻击下降50%状态
      end
    end

  end
 

  def bskill_end_two_atk_allatk(target,targets)
    unless @subject.opponent_unit.all_dead? || @subject.dead?
      if @subject.state?(114)    and  @nn == -2 
      elsif @subject.state?(114) and  @nn == -1 
        @subject.add_state_must(129)
      elsif @subject.equip_wtype_ok?(5) and @nn == -1
      elsif @two_atk > @nn and @subject.hp > 0 
        wait_for_animation
        #wait(5)
        #targets2 = []
        #targets2[0] = @subject
        #show_state_animation(targets2, 337, mirror = false) unless BattleManager.all_atk == :start
        @subject.add_state_must(129)  #攻击下降50%状态
      end
    end
  end


  # 再动动画(弃用 不会触发 TODO 重写)
  # def action_2nd
  #     if @actor_2nd_size > 1 and @subject.actions.size == 1
  #        targets2 = []
  #        targets2[0] = @subject
  #        show_state_animation(targets2, 340, mirror = false) unless BattleManager.all_atk == :start
  #        @actor_2nd_size = 0
  #        wait_for_animation
  #     end
  # end   

  #--------------------------------------------------------------------------
  # ● 玉石效果，攻击法球效果动画,木牛流马
  #--------------------------------------------------------------------------
  def bskill_end_duyu #毒玉，落毒计,每回合单独方法，木牛流马+5%
    for i in 0...$game_troop.members.size
      #陷阱计--------------------- 
      if  $game_troop.members[i].state?(31) and rand(10) > 5 
        x = []
        x[0] = $game_troop.members[i]
        show_state_animation_quick(x, 447, mirror = false) unless BattleManager.all_atk == :start 
        $game_troop.members[i].remove_state(31)
        $game_troop.members[i].add_state_must(32)
      end
      #----------------------------
      a = 0.0
      b = 0.0
      a = 0.035 if $game_troop.members[i].state?(141)
      b = 0.070 if $game_troop.members[i].state?(138)
      if ($game_troop.members[i].state?(141) or $game_troop.members[i].state?(138)) and $game_troop.members[i].hp > 0 
        $turn_damage = -1
   
        wait_for_animation
        targets2 = []
        targets2[0] = $game_troop.members[i]
        targets2[0].result.critical = false
        targets2[0].result.hp_damage = (targets2[0].mhp * ( a + b ) ).to_i if targets2[0].hp > 0
        if a > 0
        targets2[0].result.hp_damage = 400+rand(100)  if targets2[0].result.hp_damage > 500
        end
        if b > 0
        targets2[0].result.hp_damage = 500+rand(200)  if targets2[0].result.hp_damage > 600
        end
        if BattleManager.all_atk == :start
          show_state_animation(targets2, 58, mirror = false) 
        else
          show_state_animation(targets2, 331, mirror = false) 
        end
        if targets2[0].dead?
          dead_face(targets2[0]) 
          targets2[0].set_animation(:dead)
          targets2[0].animation_id = RPG::Animation::DEAD_ID
          targets2[0].change_btm_st :dead
          wait_for_animation
          _unit = targets2[0].unit
          _battler = targets2[0]
          if _unit.formation?
            if _unit.is_bagua
              if _unit.alive_gate.eql?(_battler)
                formation_sankai!(_unit)
              else
                formation_sankai!(_unit) if !_unit.can_use_formation?
              end
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          end
        end
      end

      #木牛-敌人
      if $game_troop.members[i] != nil and $game_troop.members[i].hrg > 0 and $game_troop.members[i].hp > 0 and !$game_troop.members[i].state?(57)
        wait_for_animation
        targets2 = []
        targets2[0] = $game_troop.members[i]
        targets2[0].result.hp_damage = (targets2[0].mhp * targets2[0].hrg).to_i
        targets2[0].result.hp_damage *= 0.5 if $game_troop.formation.id == 12
        if BattleManager.all_atk == :start
          show_state_animation(targets2, 296, mirror = false) 
        else
          show_state_animation(targets2, 332, mirror = false) 
        end
        wait_for_animation
        #统计
        targets2[0].over_sup += targets2[0].result.hp_damage
      end
    end


            if $game_party.exist_jm_skill?(686) 
               zc = false
               zj = false
               zc_zj = false
                for i in 0...$game_party.members.size
                    if $game_party.members[i].id == 28
                        zc = true 
                        $game_party.members[i].mp += ($game_party.members[i].mmp * 0.03).to_i  if $game_party.members[i].hp > 0 
                    end   
                    if $game_party.members[i].id == 71
                        zj = true 
                        $game_party.members[i].mp += ($game_party.members[i].mmp * 0.03).to_i  if $game_party.members[i].hp > 0
                    end 
                end
                zc_zj = true if zc == true and zj == true
            end

    #毒玉，每回合单独方法，木牛流马+5% 我方
    for i in 0...$game_party.members.size
      #陷阱计--------------------------
      x = []
      if  $game_party.members[i].state?(31) and rand(10) > 5 
        x[0] = $game_party.members[i]
        show_state_animation_quick(x, 447, mirror = false) unless BattleManager.all_atk == :start 
        $game_party.members[i].remove_state(31)
        $game_party.members[i].add_state_must(32)
      end
      #------------------------------
      a = 0.0
      b = 0.0
      a = 0.065 if $game_party.members[i].state?(141)
      b = 0.12  if $game_party.members[i].state?(138)
      if ($game_party.members[i].state?(141) or $game_party.members[i].state?(138)) and $game_party.members[i].hp > 0
        wait_for_animation
        $turn_damage = -1
        targets2 = []
        targets2[0] = $game_party.members[i]
        targets2[0].result.critical = false
        targets2[0].result.hp_damage = (targets2[0].mhp*(a+b)).to_i if targets2[0].hp > 0
        if BattleManager.all_atk == :start
          show_state_animation(targets2, 58, mirror = false) 
        else
          show_state_animation(targets2, 331, mirror = false) 
        end
        if targets2[0].dead?
          dead_face(targets2[0]) 
          targets2[0].set_animation(:dead)
          targets2[0].animation_id = RPG::Animation::DEAD_ID
          targets2[0].change_btm_st :dead
          wait_for_animation
          _unit = targets2[0].unit
          _battler = targets2[0]
          if _unit.formation?
            if _unit.is_bagua
              if _unit.alive_gate.eql?(_battler)
                formation_sankai!(_unit)
              else
                formation_sankai!(_unit) if !_unit.can_use_formation?
              end
            else
              formation_sankai!(_unit) if !_unit.can_use_formation?
            end
          end
        end
      end 


      #木牛-我方
      if $game_party.members[i] != nil 
        if $game_party.members[i].hrg > 0 and $game_party.members[i].hp > 0 and !$game_party.members[i].state?(57)
          wait_for_animation
          targets2 = []
          targets2[0] = $game_party.members[i]
          targets2[0].result.clear
          targets2[0].result.hp_damage = (targets2[0].mhp * targets2[0].hrg).to_i 
          targets2[0].result.hp_damage *= targets2[0].element_rate(5)
          targets2[0].result.hp_damage *= 0.6 if $game_party.formation.id == 12
          if BattleManager.all_atk == :start
            show_state_animation(targets2, 296, mirror = false) 
          else
            show_state_animation(targets2, 332, mirror = false) 
          end
          #统计
          $game_party.members[i].over_sup += ($game_party.members[i].result.hp_damage*0.5).to_i
          wait_for_animation
        end
        #流马-只有我方
        if   $game_party.members[i].hp > 0  and ( $game_party.members[i].mrg > 0  or  ( zc_zj == true  and  ( $game_party.members[i].id == 28 or $game_party.members[i].id == 71 ) ) )
          wait_for_animation 
          targets2 = []
          targets2[0] = $game_party.members[i]
          if BattleManager.all_atk == :start
            show_state_animation(targets2, 294, mirror = false) 
          else
            show_state_animation(targets2, 333, mirror = false) 
          end
          #统计
          $game_party.members[i].over_sup += 50
          wait_for_animation
        end
      end
    end
  end



  #炎玉 for 总攻
  def bskill_end_yanyu_allatk(target,targets)
    if  targets[0].state?(140) and @subject.state?(240) and targets[0].unit != @subject.unit
      wait_for_animation
      @subject.remove_state(240)
      target = targets[0]
      if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
        target.result.critical = false
        $turn_damage = -1
        targets2 = []
        targets2[0] = target
        if  @subject.actor?
          targets2[0].result.hp_damage = @subject.element_rate(28) * @subject.level
          targets2[0].result.hp_damage = @subject.element_rate(28) * @subject.level * 1.3 if @subject.state?(112)
        else
          targets2[0].result.hp_damage = @subject.element_rate(28) * 30
        end 
        show_state_animation(targets2, 58, mirror = false)
      end
    end
  end

  def bskill_end_yushi_buff(target,targets,type)
    if targets[0] != nil 
      #炎玉
      if  targets[0].state?(140) and @subject.state?(240) and targets[0].unit != @subject.unit #and type == :atk 
        wait_for_animation
        @subject.remove_state(240)
        target = targets[0]
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          $turn_damage = -1
          target.result.critical = false
          targets2 = []
          targets2[0] = target
          if  @subject.actor?
            d = @subject.element_rate(28)
            d = 7.5  if d > 7.5 
            targets2[0].result.hp_damage = d * @subject.level
            targets2[0].result.hp_damage = d * @subject.level * 1.33 if @subject.state?(112)
          else
            targets2[0].result.hp_damage = @subject.element_rate(28) * 30
          end 
          show_state_animation(targets2, 323, mirror = false) unless BattleManager.all_atk == :start
        end
      end
      #毒玉
      if  targets[0].state?(141) and @subject.state?(241) #and type == :atk 
        wait_for_animation
        @subject.remove_state(241)
        target = targets[0]
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          target.result.critical = false
          $turn_damage = -1
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 324, mirror = false) unless BattleManager.all_atk == :start
             if @subject.enemy?
                a = 0.075 
             else
                a = 0.02 
             end
             du_damage = (targets2[0].mhp * ( a ) ).to_i
             du_damage = 400+rand(100)  if du_damage > 500
             @subject.over_damage += (du_damage * 2.5).to_i #统计 
        end
      end
      #阳玉
      if targets[0].state?(142) and @subject.state?(242) #and type == :atk 
        wait_for_animation
        @subject.remove_state(242)
        target = targets[0]
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 325, mirror = false) unless BattleManager.all_atk == :start
          @subject.over_sup += rand(100) if targets[0].unit != @subject.unit #统计 
        end
      end
      #烈玉
      if targets[0].state?(143) and @subject.state?(243) #and type == :atk 
        wait_for_animation
        @subject.remove_state(243)
        target = targets[0]
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 326, mirror = false) unless BattleManager.all_atk == :start
           @subject.over_sup += rand(100) if targets[0].unit != @subject.unit #统计
        end
      end
      #雷玉
      if targets[0].state?(144) and @subject.state?(244) #and type == :atk 
        wait_for_animation
        @subject.remove_state(244)
        target = targets[0]
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 327, mirror = false) unless BattleManager.all_atk == :start
           @subject.over_sup += rand(100) if targets[0].unit != @subject.unit #统计
        end
      end
      #冰玉
      if targets[0].state?(145) and @subject.state?(245) #and type == :atk 
        wait_for_animation
        @subject.remove_state(245)
        target = targets[0]
        if !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 328, mirror = false) unless BattleManager.all_atk == :start
           @subject.over_sup += rand(100) if targets[0].unit != @subject.unit #统计
        end
      end
      #阴玉
      if targets[0].state?(146) and @subject.state?(246) #and type == :atk 
        wait_for_animation
        @subject.remove_state(246)
        target = targets[0]
        if  !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 329, mirror = false) unless BattleManager.all_atk == :start
           @subject.over_sup += rand(100) if targets[0].unit != @subject.unit #统计
        end
      end
    end     
  end
#--------------------------------------------------------------------------
# ● 左慈被动技能，反弹6种玉石属性
#--------------------------------------------------------------------------
   def bskill_end_28(target,targets,type)
    if targets[0] != nil and targets[0].element_rate(41) > 1 and type == :atk  and targets[0].unit != @subject.unit
      if !targets[0].result.missed and targets[0].result.hp_damage > 0 and targets[0].hp > 0
        wait_for_animation
        targets2 = []
        targets2[0] = targets[0]
        show_state_animation(targets2, 524, mirror = false) unless BattleManager.all_atk == :start
        wait(10)
        i = rand(5)
        case i
        when 0
          targets3 = []
          targets3[0] = @subject
          show_state_animation(targets3, 329, mirror = false) unless BattleManager.all_atk == :start
          @subject.add_state_must(146)
        when 1
          targets3 = []
          targets3[0] = @subject
          show_state_animation(targets3, 328, mirror = false) unless BattleManager.all_atk == :start
          @subject.add_state_must(145)
        when 2
          targets3 = []
          targets3[0] = @subject
          show_state_animation(targets3, 327, mirror = false) unless BattleManager.all_atk == :start
          @subject.add_state_must(144)
        when 3
          targets3 = []
          targets3[0] = @subject
          show_state_animation(targets3, 326, mirror = false) unless BattleManager.all_atk == :start
          @subject.add_state_must(143)
        when 4
          targets3 = []
          targets3[0] = @subject
          show_state_animation(targets3, 325, mirror = false) unless BattleManager.all_atk == :start
          @subject.add_state_must(142)
        end
        wait_for_animation
         targets[0].over_sup += rand(100) #统计
      end
    end
  end


  def bskill_end_28_allatk(target,targets)
    if targets[0] != nil and targets[0].id == 28 and targets[0].actor? and targets[0].unit != @subject.unit
      if !targets[0].result.missed and targets[0].result.hp_damage > 0 and targets[0].hp > 0
        i = rand(5)
        case i
        when 0
          @subject.add_state_must(146)
        when 1
          @subject.add_state_must(145)
        when 2
          @subject.add_state_must(144)
        when 3
          @subject.add_state_must(143)
        when 4
          @subject.add_state_must(142)
        end
        targets[0].over_sup += rand(100) #统计
      end
    end
  end    

  #李进被动
   def bskill_end_10(targets,type)
    if targets[0] != nil and targets[0].element_rate(59) > 1 and type == :atk and targets[0].unit != @subject.unit
          wait_for_animation
      if !targets[0].result.missed and targets[0].result.hp_damage > 0 and targets[0].hp > 0 
        r = 50
        r = 100 if targets[0].state?(221)
        if r > rand(100)
        targets2 = []
        targets2[0] = targets[0]
        wait_for_animation
        targets[0].result.critical = false
        targets2[0].result.critical = false
        targets3 = []
        targets3[0] = @subject
        targets3[0].item_apply1(targets2[0], $data_skills[1])
        unless BattleManager.all_atk == :start
           if targets[0].actor?
           show_state_animation(targets2, 947, mirror = false) 
           show_state_animation(targets3, 948, mirror = false) 
           else
           show_state_animation(targets2, 945, mirror = false) 
           show_state_animation(targets3, 946, mirror = false) 
           end
            wait_for_animation
            for i in 0...targets3.size
                if targets3[i].hp == 0
                   targets3[i].set_animation(:dead)
                   targets3[i].animation_id = RPG::Animation::DEAD_ID
                   targets3[i].change_btm_st :dead
                   wait_for_animation
                   _unit = targets3[i].unit
                   _battler = targets3[i]
                    if _unit.formation?
                       if _unit.is_bagua
                       if _unit.alive_gate.eql?(_battler)
                          formation_sankai!(_unit)
                       else
                          formation_sankai!(_unit) if !_unit.can_use_formation?
                       end
                    else
                       formation_sankai!(_unit) if !_unit.can_use_formation?
                    end
                end
            end
                 BattleManager.judge_win_loss
          end
          end   
                wait_for_animation

        end  #unless
      end
    end
   end       

     #李进被动总攻
   def bskill_end_10_allatk(target,targets)
    if targets[0] != nil and targets[0].element_rate(59) > 1 and targets[0].unit != @subject.unit
        wait_for_animation
      if !targets[0].result.missed and targets[0].result.hp_damage > 0 and targets[0].hp > 0 
        r = 50
        r = 100 if targets[0].state?(221)
        if r > rand(100)
        targets2 = []
        targets2[0] = targets[0]
        wait_for_animation
        targets[0].result.critical = false
        targets2[0].result.critical = false
        targets3 = []
        targets3[0] = @subject
        targets3[0].item_apply1(targets2[0], $data_skills[1])
        show_state_animation(targets3, 58, mirror = false) 
        wait_for_animation
            for i in 0...targets3.size
                if targets3[i].hp == 0
                   targets3[i].set_animation(:dead)
                   targets3[i].animation_id = RPG::Animation::DEAD_ID
                   targets3[i].change_btm_st :dead
                   wait_for_animation
                   _unit = targets3[i].unit
                   _battler = targets3[i]
                    if _unit.formation?
                       if _unit.is_bagua
                       if _unit.alive_gate.eql?(_battler)
                          formation_sankai!(_unit)
                       else
                          formation_sankai!(_unit) if !_unit.can_use_formation?
                       end
                    else
                       formation_sankai!(_unit) if !_unit.can_use_formation?
                    end
                end
            end
                 BattleManager.judge_win_loss
          end   
                wait_for_animation

        end
      end
    end
   end   

#--------------------------------------------------------------------------
# ● 马谡50%雷击伤害+印记 for 总攻 or 正常
#--------------------------------------------------------------------------
  def bskill_end_57_allatk(target,targets)
    if targets[0] != nil and  @subject.id == 57 
      target = targets[0]
      if  !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
        if  rand(100) < 55
          $turn_damage = -1
          target.result.critical = false
          wait_for_animation
          targets2 = []
          targets2[0] = target
          targets2[0].result.hp_damage = target.result.hp_damage/10
          targets2[0].result.hp_damage = 5 if targets2[0].result.hp_damage < 5
          show_state_animation(targets2, 58, mirror = false)
          targets2[0].result.critical = false
          target.add_state(123)
          @subject.over_sup += rand(100) #统计
        end
      end
    end
  end

  def bskill_end_57(target,targets,type)
  if  targets[0] != nil and @subject.id == 57 and type == :atk 
    target = targets[0]
    if  !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
      if  rand(100) < 50
          $turn_damage = -1
          wait_for_animation
          targets2 = []
          targets2[0] = target
          targets2[0].result.hp_damage = target.result.hp_damage/10
          targets2[0].result.hp_damage = 5 if targets2[0].result.hp_damage < 5
          show_state_animation(targets2, 316, mirror = false)
          target.add_state(123)
           @subject.over_sup += rand(100) #统计
        end
      end
    end
  end
#--------------------------------------------------------------------------
# ● 鬼魅娃娃触发
#--------------------------------------------------------------------------
    def bskill_end_wawa
        if  @wawa != nil and @wawa == true
            wait_for_animation
            @subject.animation_id = 285
            wait_for_animation
            @subject.add_state_must(170)
            @wawa = false
            return
        end   
    end
#--------------------------------------------------------------------------
# ● 战斗即时触发开关$game_switches[627]
#--------------------------------------------------------------------------
    def process_event_in_time(targets,item)
        if $game_switches[627] == true
           #马超真无双习得条件，250士气无双击杀曹操。
             if $game_troop.troop.id == 229
                 if @subject.id == 6 && item.id == 248 && $game_party.boost >= 200 && targets[0].dead? && targets[0].index == 5 && $game_troop.alive_members.size >= 5
                    $game_switches[628] = true
                 end
             end
           #黄忠多次击杀夏侯源 
             if (targets[0].id == 431 or targets[0].id == 557) && @subject.id == 7 && targets[0].dead?
                $game_switches[630] = true
             end 
        end
    end
#--------------------------------------------------------------------------
# ● 天罡杖触发
#--------------------------------------------------------------------------
    def bskill_end_tgz(target,item)
        if  @subject.equip_wtype_ok?(36)
        if  item.is_marv? and item.for_one? and target.result.missed
            wait_for_animation
            unless BattleManager.all_atk == :start
                   @subject.animation_id = 266
            else
                   @subject.animation_id = 294
            end       
            @subject.mp += (@subject.skill_mp_cost(item)*0.5).to_i
            wait_for_animation
        end
        end
    end
#--------------------------------------------------------------------------
# ● 糜竺被动，全部失败+成功率
#--------------------------------------------------------------------------
   def bskill_end_46(targets,item)
       if @subject.id == 46 and item.is_marv? and @subject.actor?
          ok = true
          for i in 0...targets.size
              a = targets[i]
              ok = false unless a.result.missed 
          end
          if ok == true
             wait_for_animation
             @subject.animation_id = 515  unless BattleManager.all_atk == :start
             if    @subject.state?(185)
                   @subject.remove_state(185)
                   @subject.remove_state(187)
                   @subject.add_state_must(186)
             elsif @subject.state?(186)
                   @subject.remove_state(185)
                   @subject.remove_state(186)
                   @subject.add_state_must(187)
             else
                   @subject.remove_state(186)
                   @subject.remove_state(187)
                   @subject.add_state_must(185)
             end   
             wait_for_animation
          else
              if ( @subject.state?(185) or @subject.state?(186) or @subject.state?(187) )and item.for_opponent?
                 @subject.remove_state(185)
                 @subject.remove_state(186)
                 @subject.remove_state(187)
              end  
          end  
       end   
   end
#--------------------------------------------------------------------------
# ● 暗杀计标志
#--------------------------------------------------------------------------
def bskill_assassin
    $game_party.alive_members.each do |target|
       if target.hp < target.mhp * 0.30
          target.add_state_must(233)
       end      
    end
    $game_troop.alive_members.each do |target|
       if target.hp < target.mhp * 0.40
          target.add_state_must(233)
       end      
    end
end
#--------------------------------------------------------------------------
# ● 城内计
#--------------------------------------------------------------------------
   def bskill_end_cnj(targets,item)
       if item.id == 178 and item.is_marv?
          targets.each do |target|
            unless target.result.missed
              if target.state?(66)
                 target.remove_state(66)
                 target.add_state_must(65)
              end 
              if target.state?(67)
                 target.remove_state(67)
                 target.add_state_must(66)
              end  
              if target.state?(68)
                 target.remove_state(68)
                 target.add_state_must(67)
              end  
              if target.state?(69)
                 target.remove_state(69)
                 target.add_state_must(68)
              end
            end  
        end  
       end   
   end           
#--------------------------------------------------------------------------
# ● 孙乾被动，自动犒赏
#--------------------------------------------------------------------------
   def bskill_end_48(targets)
       index = -1 
       $game_party.members.each do |actor|
          index = actor.index if actor.id == 48 and actor.hp > 0 and actor.movable? 
       end    
       if index != -1 and @subject.actor? and @subject.unit != targets[0].unit and @subject.id != 48 and $game_troop.alive_members.size > 0
          ok = false
          for i in 0...targets.size
              a = targets[i]
              ok = true if a.dead?
          end
       end 
       if ok == true
          unless BattleManager.all_atk == :start
                 wait_for_animation
                 $game_party.members[index].animation_id = 539
                 abs_wait(18)
                 @subject.animation_id = 540
                 wait_for_animation
          else
                 @subject.animation_id = 289  
                 abs_wait(10)    
          end
          for i in 171...181
              @subject.remove_state(i)
          end  
          @subject.add_state_must(171+rand(10))
          $game_party.members[index].over_sup += rand(300)
       end
   end        
#--------------------------------------------------------------------------
# ● 甘宁被动，水策略附加攻击状态.总攻不能使用计策，所以不用写总攻。
#--------------------------------------------------------------------------
  def bskill_end_93_marv(targets,item)
    if targets[0] != nil and @subject.equip_wtype_ok?(32) and item.is_water_marv? #and !@subject.state?(109)
          if $game_party.alive_members.size > 0 and $game_troop.alive_members.size > 0
          wait_for_animation
          targets2 = []
          targets2[0] = @subject
          show_state_animation(targets2, 680, mirror = false)
          @subject.add_state_must(149)
          @subject.over_sup += rand(100) #统计
          end
    end
  end
#--------------------------------------------------------------------------
# ● 文鸯被动
#--------------------------------------------------------------------------
  def bskill_end_215(targets,type)
  if  targets[0] != nil and @subject.equip_wtype_ok?(28) and type == :atk 
      target = targets[0]
      if  !target.result.missed and target.result.hp_damage > 0 
          $turn_damage = -1 # 0表示可以增加士气，-1表示不增加士气，文鸯的被动属于打击累，可以增加士气，但需要在次手动增加，不在(d)方法内增加
          wait_for_animation
          targets2 = []
          if @subject.actor? 
             if $game_troop.alive_members.size > 0 and rand(100) < @subject.tp * 0.5 #tp满时候为50%
                r = $game_troop.alive_members[rand($game_troop.alive_members.size)]
                targets2[0] = r
                a = @subject
                b = r
                targets2[0].result.hp_damage  = 0.35*(a.atk*2+(a.mhp/10.0))*(0.2+a.ski/77.5)*(1-b.def/(b.def+75.0))
                targets2[0].result.hp_damage *= 1+(a.ski - 225)*0.03 if a.ski > 225
                targets2[0].result.hp_damage  = 5 if targets2[0].result.hp_damage < 5
                show_state_animation(targets2, 971, mirror = false)
                $game_party.incr_boost rand(2)+2
                      wait_for_animation
                        for i in 0...targets2.size
                          if targets2[i].hp == 0
                             targets2[i].set_animation(:dead)
                             targets2[i].animation_id = RPG::Animation::DEAD_ID
                             targets2[i].change_btm_st :dead
                             wait_for_animation
                             _battler = targets2[i]
                             _unit = targets2[i].unit
                          if _unit.formation?
                             if _unit.is_bagua
                                if _unit.alive_gate.eql?(_battler)
                                   formation_sankai!(_unit)
                                else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                                end
                             else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                             end
                          end
                          end
                      end
             end     
          else
             if $game_party.alive_members.size > 0 and rand(100) < 25
                r = $game_party.alive_members[rand($game_party.alive_members.size)]
                targets2[0] = r
                a = @subject
                b = r
                targets2[0].result.hp_damage  = 0.2*(a.atk*2+(a.hp/10.0))*(0.2+a.ski/77.5)*(1-b.def/(b.def+75.0))
                targets2[0].result.hp_damage = 5 if targets2[0].result.hp_damage < 5
                show_state_animation(targets2, 972, mirror = true)
                $game_party.cost_boost rand(2)+2
                      wait_for_animation
                          for i in 0...targets2.size
                          if targets2[i].hp == 0
                             targets2[i].set_animation(:dead)
                             targets2[i].animation_id = RPG::Animation::DEAD_ID
                             targets2[i].change_btm_st :dead
                             wait_for_animation
                             _battler = targets2[i]
                             _unit = targets2[i].unit
                          if _unit.formation?
                             if _unit.is_bagua
                                if _unit.alive_gate.eql?(_battler)
                                   formation_sankai!(_unit)
                                else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                                end
                             else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                             end
                          end
                          end
                      end
             end
          end
      end
    end
    $turn_damage = 0
  end

    def bskill_end_215_allatk(target,targets)
  if  target != nil and @subject.equip_wtype_ok?(28) 
      if  !target.result.missed and target.result.hp_damage > 0 
          $turn_damage = -1
          wait_for_animation
          targets2 = []
          if @subject.actor? 
             if $game_troop.alive_members.size > 0 and rand(100) < @subject.tp * 0.5 #tp满时候为50%
                r = $game_troop.alive_members[rand($game_troop.alive_members.size)]
                targets2[0] = r
                a = @subject
                b = r
                targets2[0].result.hp_damage  = 0.35*(a.atk*2+(a.hp/10.0))*(0.2+a.ski/77.5)*(1-b.def/(b.def+75.0))
                targets2[0].result.hp_damage *= 1+(a.ski - 225)*0.03 if a.ski > 225
                targets2[0].result.hp_damage  = 5 if targets2[0].result.hp_damage < 5
                show_state_animation(targets2, 58, mirror = false)
                $game_party.incr_boost rand(2)+2
                        wait_for_animation
                        for i in 0...targets2.size
                          if targets2[i].hp == 0
                             targets2[i].set_animation(:dead)
                             targets2[i].animation_id = RPG::Animation::DEAD_ID
                             targets2[i].change_btm_st :dead
                             wait_for_animation
                             _battler = targets2[i]
                             _unit = targets2[i].unit
                          if _unit.formation?
                             if _unit.is_bagua
                                if _unit.alive_gate.eql?(_battler)
                                   formation_sankai!(_unit)
                                else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                                end
                             else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                             end
                          end
                          end
                      end
             end     
          else
             if $game_party.alive_members.size > 0 and rand(100) < 25
                r = $game_party.alive_members[rand($game_party.alive_members.size)]
                targets2[0] = r
                a = @subject
                b = r
                targets2[0].result.hp_damage = 0.2*(a.atk*2+(a.hp/10.0))*(0.2+a.ski/77.5)*(1-b.def/(b.def+75.0))
                targets2[0].result.hp_damage = 5 if targets2[0].result.hp_damage < 5
                show_state_animation(targets2, 58, mirror = false)
                $game_party.cost_boost rand(2)+2
                        wait_for_animation
                        for i in 0...targets2.size
                          if targets2[i].hp == 0
                             targets2[i].set_animation(:dead)
                             targets2[i].animation_id = RPG::Animation::DEAD_ID
                             targets2[i].change_btm_st :dead
                             wait_for_animation
                             _battler = targets2[i]
                             _unit = targets2[i].unit
                          if _unit.formation?
                             if _unit.is_bagua
                                if _unit.alive_gate.eql?(_battler)
                                   formation_sankai!(_unit)
                                else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                                end
                             else
                                   formation_sankai!(_unit) if !_unit.can_use_formation?
                             end
                          end
                          end
                      end
             end
          end
      end
    end
    $turn_damage = 0
  end
#--------------------------------------------------------------------------
# ●  司马昭祸心
#--------------------------------------------------------------------------
  def bskill_end_211(targets,type)
  if  targets[0] != nil and @subject.equip_wtype_ok?(27) and type == :atk 
      target = targets[0]
    if  !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
      if  rand(100) < 21
          wait_for_animation
          targets2 = []
          targets2[0] = target
          show_state_animation(targets2, 969, mirror = false)
          wait_for_animation
          target.add_state_must(224)
           @subject.over_sup += rand(100) #统计
        end
      end
    end
  end

  def bskill_end_211_allatk(target,targets)
      if  targets[0] != nil and @subject.equip_wtype_ok?(27) 
          target = targets[0]
          if  !target.result.missed and target.result.hp_damage > 0 and target.hp > 0
              if  rand(100) < 21
                  target.add_state_must(224)
                   @subject.over_sup += rand(100) #统计
              end
          end
      end
  end


#--------------------------------------------------------------------------
# ●  司马懿昼夜
#--------------------------------------------------------------------------
  def sima_open(type,item)
      if (item.id == 547  or item.id == 548) and type == :skill and @subject.enemy? 
          wait_for_animation
          @spriteset.sima_picture_close
          @spriteset.create_sima_picture(item)
          for i in 0...$game_party.alive_members.size
             a = $game_party.alive_members[i]
             a.remove_state(223)
             a.remove_state(222)
          end
          @sima = true
      end     

      if (item.id == 409  or item.id == 413) and type == :skill and @subject.actor?
          wait_for_animation
          @spriteset.sima_picture_close
          @spriteset.create_sima_picture(item)
          for i in 0...$game_troop.alive_members.size
             a = $game_troop.alive_members[i]
             a.remove_state(208)
             a.remove_state(207)
          end
          @sima = true
      end
  end

  def sima_over 
      return unless @sima == true
      close = true
      for i in 0...$game_troop.alive_members.size
          a = $game_troop.alive_members[i]
          if a.state?(208) or a.state?(207) 
             close = false
          end
      end
      for i in 0...$game_party.alive_members.size
          a = $game_party.alive_members[i]
          if a.state?(223) or a.state?(222) 
             close = false
          end  
      end
       if close == true
          @sima = false
          @spriteset.sima_picture_close
       end  
  end   


 #def bskill_end_xx(targets,type,item)
           #if  @subject.id == 93 and type == :atk
          # targets2 = []
           #targets2[0] = targets[0]
           #if  !targets2[0].result.missed and targets2[0].result.hp_damage > 0 
          # grate = targets2[0].item_hit(@subject, $data_skills[86]) * 100
          # if rand(100) < grate
          # targets2[0].result.hp_damage = (170 + @subject.int / 5.0 + @subject.level * 10)
          # show_state_animation(targets2, 310, mirror = false)
          # wait(1)
          # else
          # targets2[0].result.hp_damage = 0
          # show_state_animation(targets2, 310, mirror = false)
          # targets2[0].set_animation(:marv_miss,@subject)
          # show_state_animation(targets2, 101, mirror = false)
          # end
          # end
          # end
 #end           
   #雷玉制作方法
       # targets[0] = target
       # members = $game_troop.alive_members
       # for i in 0...members.size
       # if targets[i] != target
       # targets[1] = $game_troop.alive_members[i]
       # members.delete_at(i)
       # end
       # end
  #--------------------------------------------------------------------------
  # ● 显示回合结束状态动画
  #     targets      : 目标的数组
  #     animation_id : 动画ID
  #     mirror       : 左右反转
  #--------------------------------------------------------------------------
  def show_state_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation
      targets.each do |target|
        target.animation_id = animation_id
        target.animation_mirror = mirror
        abs_wait_short unless animation.to_screen?
      end
      abs_wait_short if animation.to_screen?
    end
  end

  def show_state_animation_quick(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation
      targets.each do |target|
        target.animation_id = animation_id
        target.animation_mirror = mirror
        #abs_wait_short unless animation.to_screen?
      end
      abs_wait_short if animation.to_screen?
    end
  end
  #--------------------------------------------------------------------------
  # ● 【弃用】回合结束判断阵法消耗是否足够，如果不足则解散。
  #--------------------------------------------------------------------------
  def turn_end_formation
    @subject = $game_party.members[4] if $game_party.members[4] != nil and $game_party.members[4].dead? == false
    @subject = $game_party.members[3] if $game_party.members[3] != nil and $game_party.members[3].dead? == false 
    @subject = $game_party.members[2] if $game_party.members[2] != nil and $game_party.members[2].dead? == false
    @subject = $game_party.members[1] if $game_party.members[1] != nil and $game_party.members[1].dead? == false
    @subject = $game_party.members[0] if $game_party.members[0] != nil and $game_party.members[0].dead? == false
    if @subject.unit.formation?
      if @subject.is_a?(Game_Actor)
        if $game_party.boost >= $game_party.formation.note.split("\r\n")[11].split(" = ").last.to_i
          $game_party.boost -= $game_party.formation.note.split("\r\n")[11].split(" = ").last.to_i
        else
          $game_party.boost = 0
          formation_sankai!(@subject.unit) 
        end
      end
    end
  end   




  def animation_1212
    if @subject.actor?
       @subject.animation1_name =  "#{@subject.id}" 
    else
      if @subject.element_rate(45) != 1
         @subject.animation1_name = "DM#{(@subject.element_rate(45)*100).round}" 
      else
         @subject.animation1_name = "DM#{@subject.id}"
      end
         @subject.animation1_name = @subject.animation1_name + "-q" if @subject.equip_wtype_ok?(31) 
    end

    if @subject.actor?
       @subject.animation2_name =  "#{@subject.id}" 
    else
      if @subject.element_rate(45) != 1
         @subject.animation2_name = "DM#{(@subject.element_rate(45)*100).round}" 
      else
         @subject.animation2_name = "DM#{@subject.id}"
      end 
         @subject.animation2_name = @subject.animation2_name + "-q" if @subject.equip_wtype_ok?(31)
    end

  end           

  #--------------------------------------------------------------------------
  # ● 战斗开始前敌人变身
  #--------------------------------------------------------------------------
    def process_event_int
        if $game_switches[698] == true
          #while !scene_changing?
          loop do 
                 $game_troop.interpreter.update
                 $game_troop.setup_battle_event
          return if $game_switches[698] == false
          return unless $game_troop.interpreter.running?
          end
        end
    end    
  #--------------------------------------------------------------------------
  # ● 获取进入战斗前，小兵随着我军等级提升的加成HP
  #--------------------------------------------------------------------------
  def enemy_hero_team

    #---战斗开始前获取队伍平均等级-------------
    k=0
    for i in 0...$game_party.members.size
      if i<$game_party.members.size and i<5
        actor = $game_party.members[i]
        k += actor.level
      end
    end
    if $game_party.members.size >= 5
      k=(k/5.0).to_i
    else
      k= ( k / (($game_party.members.size)*1.0) ).to_i
    end
    $game_variables[121] = k

    #计算能力加成----杂兵的数据库内备注文档设置---------
    # if $data_enemies[i].params[0] != 100 and ( $data_enemies[i].note.split("\r\n")[4].split(" = ").last == "002_big" or $data_enemies[i].note.split("\r\n")[4].split(" = ").last == "001_big" or $data_enemies[i].note.split("\r\n")[4].split(" = ").last == "001_big2" )
    # $data_enemies[i].params[0] = ($data_enemies[i].note[0,4]).to_i
    #if $game_variables[121] > ($data_enemies[i].note[8,4]).to_i
    #每高一级杂兵增加HP
    # $data_enemies[i].params[0] += (($game_variables[121]-($data_enemies[i].note[8,4]).to_i) * ($data_enemies[i].note[13,4]).to_i).to_i
    #每高一级随机减少，不固定HP
    #$data_enemies[i].params[0] -= rand(($data_enemies[i].note[13,4]).to_i/10)*10.to_i
    # end
    #end

    #计算在野武将能力加成
    if $game_switches[700] == true
       atk = k * (rand(20)+20) * 0.1
       df  = k * (rand(25)+25) * 0.1
    else
       atk = k * (rand(20)+20) * 0.1
       df  = k * (rand(20)+20) * 0.1
    end
    atk  = atk-atk%5
    df   = df-df%5
    exp  = k * 20
    gold = k * 15
    atk  = atk.to_i
    df   = df.to_i
    exp  = exp.to_i
    gold = gold.to_i
    for i in 0...$game_troop.members.size
      item = $game_troop.members[i]
      id = $data_enemies[$game_troop.members[i].id]
      data_lv = (id.note[13,4]).to_i
      hp = (k * data_lv + rand(100 * $game_variables[230])) #随机500左右Hp 章节x
      hp = hp-hp%5
      mp = (k * 35 + rand(50 * $game_variables[230])) #随机500左右mp
      mp = mp-mp%5
      mp = mp.to_i
      #杂鱼，计算兵力加成
      if $game_troop.members[i].equip_wtype_ok?(12)
         data = (id.note[8,4]).to_i
         if $game_variables[121] > data
            max_hp = (($game_variables[121]-data) * data_lv).to_i
            item.add_param(0,max_hp)
            item.hp += 99999
         end
      elsif $game_troop.troop.name[0,1] == "S"
            #在野武将，直接根据玩家等级计算，抛弃原来的兵力和攻防
            item.add_param(0,-item.param_base(0))
            item.add_param(0,hp)
            item.add_param(1,-item.param_base(1))
            item.add_param(1,mp)
            item.hp += 99999
            item.mp += 9999
            item.add_param(5,-item.param_base(5))
            item.add_param(5,df)
            item.add_param(7,-item.param_base(7))
            item.add_param(7,atk)
            id.exp = exp
            id.gold = gold
       elsif $game_troop.troop.name[0,1] == "P"
         #试炼武将，
             hp = (data_lv * 10 * 1.0  + rand(110 * $game_variables[230])) if $game_variables[230] == 1
             hp = (data_lv * 15 * 1.0  + rand(110 * $game_variables[230])) if $game_variables[230] == 2
             hp = (data_lv * 20 * 1.0  + rand(110 * $game_variables[230])) if $game_variables[230] == 3
             hp = (data_lv * 25 * 1.05 + rand(115 * $game_variables[230])) if $game_variables[230] == 4
             hp = (data_lv * 30 * 1.1  + rand(120 * $game_variables[230])) if $game_variables[230] == 5
             hp = (data_lv * 35 * 1.1  + rand(120 * $game_variables[230])) if $game_variables[230] == 6
             hp = (data_lv * 41 * 1.2  + rand(130 * $game_variables[230])) if $game_variables[230] == 7
             hp = (data_lv * 50 * 1.25 + rand(140 * $game_variables[230])) if $game_variables[230] == 8
             hp = hp-hp%5
             item.add_param(0,-item.param_base(0))
             item.add_param(0,hp)
             item.change_hp(hp,true)
             item.add_param(1,-item.param_base(1))
             item.add_param(1,mp)
             item.mp += 9999
             item.hp += 9999
             if $game_variables[230] == 1 ; atk = 10 * (rand(30)+15) *0.1 ; df  = 10 * (rand(30)+20) * 0.1 ;end
             if $game_variables[230] == 2 ; atk = 15 * (rand(30)+15) *0.1 ; df  = 15 * (rand(30)+20) * 0.1 ;end
             if $game_variables[230] == 3 ; atk = 20 * (rand(30)+15) *0.1 ; df  = 20 * (rand(30)+20) * 0.1 ;end
             if $game_variables[230] == 4 ; atk = 25 * (rand(35)+20) *0.1 ; df  = 25 * (rand(35)+20) * 0.1 ;end
             if $game_variables[230] == 5 ; atk = 30 * (rand(35)+20) *0.1 ; df  = 30 * (rand(35)+20) * 0.1 ;end
             if $game_variables[230] == 6 ; atk = 35 * (rand(35)+20) *0.1 ; df  = 35 * (rand(35)+20) * 0.1 ;end
             if $game_variables[230] == 7 ; atk = 41 * (rand(40)+20) *0.1 ; df  = 41 * (rand(40)+20) * 0.1 ;end
             if $game_variables[230] == 8 ; atk = 50 * (rand(40)+25) *0.1 ; df  = 50 * (rand(40)+25) * 0.1 ;end
             atk = atk.to_i
             df  = df.to_i
             item.add_param(7,-item.param_base(7))
             item.add_param(7,atk)
             item.add_param(5,-item.param_base(5))
             item.add_param(5,df)
             id.exp = exp
             id.gold = gold
      end
    end
  end

  def hard_easy_mode
      if $game_variables[309] > 0 
            for i in 0...$game_troop.alive_members.size
            enemy = $game_troop.alive_members[i]
            hp = enemy.hp
            at = enemy.atk
            df = enemy.def
            if $game_variables[230] <= 3
               hp *= 0.20
               at *= 0.10
               df *= 0.20
            elsif $game_variables[230] == 5 or $game_variables[230] == 6 
               hp *= 0.12
               at *= 0.10
               df *= 0.15
            else
               hp *= 0.07
               at *= 0.10
               df *= 0.10
            end
            enemy.add_param(0,hp)
            enemy.add_param(7,at)
            enemy.add_param(5,df)
            enemy.hp += 99999
            end
      end
      #EASY模式------------------------
      if $game_variables[309] < 0
            for i in 0...$game_troop.alive_members.size
            enemy = $game_troop.alive_members[i]
            hp = enemy.hp
            at = enemy.atk
            df = enemy.def
            if $game_variables[230] <= 3
               hp *= 0.20
               at *= 0.10
               df *= 0.20
            elsif $game_variables[230] == 5 or $game_variables[230] == 6 
               hp *= 0.12
               at *= 0.15
               df *= 0.15
            else
               hp *= 0.12
               at *= 0.15
               df *= 0.15
            end
            enemy.add_param(0,-hp)
            enemy.add_param(7,-at)
            enemy.add_param(5,-df)
            enemy.hp += 99999
            end
      end
  end  


  def full_hp_mp
      for i in 0...$game_troop.alive_members.size
          enemy = $game_troop.alive_members[i]
          enemy.hp += 99999
          enemy.mp += 9999
          enemy.add_state_must(316) if $game_variables[309] > 0 and !enemy.equip_wtype_ok?(12)
          enemy.refresh
      end
  end


end
