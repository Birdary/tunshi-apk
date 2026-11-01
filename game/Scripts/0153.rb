#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　战斗画面
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 创建经验值精灵
  #--------------------------------------------------------------------------
  def show_battle_over_list
    # return
    @chang_x = -227
    @chang_y = -8
    # @message_window.z = 999
    @sima = false
    @spriteset.sima_picture_close if @spriteset

    #升级经验判断
    @over_exp = $game_troop.exp_total

    @col = Color.new(0,0,0)
    if $game_troop.members.size > 5
      @hg = 67 #头像间隔高度
      @hg_6 = 67
      #@chang_y = -18
    else
      @hg = 71 #头像间隔高度
      @hg_6 = 0
    end

    if BattleManager.all_atk == :start
      SceneManager.scene.spriteset.hide_all_atk_text  if SceneManager.scene_is?(Scene_Battle)
    end

    damage_max = []
    sup_max = []
    actor_sum = 0
    enemy_sum = 0
    for a in 0...$game_party.members.size
      damage_max << $game_party.members[a].over_damage
      sup_max << $game_party.members[a].over_sup
      actor_sum += $game_party.members[a].over_damage
      actor_sum += $game_party.members[a].over_sup
    end
    for a in 0...$game_troop.members.size
      damage_max << $game_troop.members[a].over_damage
      sup_max << $game_troop.members[a].over_sup
      enemy_sum += $game_troop.members[a].over_damage
      enemy_sum += $game_troop.members[a].over_sup
    end
    damage_max = damage_max.max
    sup_max = sup_max.max
    all_max = [damage_max,sup_max].max



    enemy_hide #隐藏敌人所有窗口
    my_hide    #隐藏我军所有窗口

    battle_dead_size = 0
    for i in 0...$game_party.members.size
         battle_dead_size += $game_party.members[i].dead_size
    end

    @mask = Sprite.new
    @mask.bitmap = Bitmap.new("Graphics/Pictures/guodu3")
    @mask.x = -1280
    @mask.y = 61
    @mask.z = 999
    @mask.opacity = 0
    @mask.blend_type = 0

    for i in 0...40
      if @mask.x < 180
      @mask.x += 30
      @mask.opacity += 12
      abs_wait(1)
      end
    end
    
    @_opacity = Sprite.new
    @_opacity.bitmap = Bitmap.new(1280,704)
    @_opacity.x = 0-50
    @_opacity.y = 0
    @_opacity.z = 955+100
    @_opacity.opacity = 0

    @_opacity_2 = Sprite.new
    @_opacity_2.bitmap = Bitmap.new(1280,704)
    @_opacity_2.x = 0+50
    @_opacity_2.y = 0
    @_opacity_2.z = 955
    @_opacity_2.opacity = 0

    @over_back = Sprite.new
    @over_back.bitmap = Bitmap.new("Graphics/System/over_back")
    @over_back.x = 0
    @over_back.y = 0
    @over_back.z = 900

    @over_daizheng = Sprite.new
    @over_daizheng.bitmap = Bitmap.new("Graphics/System/daizheng")
    @over_daizheng.y = 59
    @over_daizheng.z = 901
    @over_daizheng.bitmap.font.size = 17 + $game_variables[300]
    @over_daizheng.opacity = 0

    if $game_party.all_members.size > 5
      @over_daizheng.opacity = 255
      @over_daizheng.x = 1063 + 85
      actor6 = $game_party.all_members[5]

      _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor6.face_name}")
      @over_daizheng.bitmap.blt(63,14,_bitmap,Rect.new(actor6.face_index%4*58,actor6.face_index/4*58,58,58))
      _bitmap.dispose; _bitmap = nil

      @over_daizheng.bitmap.draw_text(43, 49, 100, 40, actor6.name, 1)

      # Todo 什么逻辑？
      if actor6.next_level_exp - actor6.exp - @over_exp <= 0
         #@over_daizheng.bitmap.blt(95,39,Cache.system("upup"),Rect.new(0,0,37,23))
      end
    end


    if  $game_party.all_members.size > 6 
      ad_x = 56
      @over_daizheng.x -= ad_x
      actor7 = $game_party.all_members[6]

      _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor7.face_name}")
      @over_daizheng.bitmap.blt(63+ad_x,14,_bitmap,Rect.new(actor7.face_index%4*58,actor7.face_index/4*58,58,58))
      _bitmap.dispose; _bitmap = nil

      @over_daizheng.bitmap.draw_text(43+ad_x, 49, 100, 40, actor7.name , 1)

      # Todo 什么逻辑？
      if actor7.next_level_exp - actor7.exp - @over_exp <= 0
        # @over_daizheng.bitmap.blt(95+ad_x,39,Cache.system("upup"),Rect.new(0,0,37,23))
      end
    end  

    if @last_subject != nil
      mvp = @last_subject
    else
      mvp = @subject
    end

    #补足，万一是被剧情动画全灭，或者落毒全灭，没人行动角色的时候，默认为第一人
    if mvp == nil 
      if $game_troop.alive_members.size == 0
        mvp = $game_party.alive_members[0]
        if $game_switches[632] == false 
           Audio.se_play("Audio/SE/Actor_first/#{mvp.id}"+"-kill") 
        else
           Audio.se_play("Music/CV/#{mvp.id}"+"-kill") 
        end
      else
      	mvp = $game_troop.alive_members[0]
      end 	  
    end

    #补足，如果我军全灭，必定显示敌人的头像
    if $game_party.alive_members.size == 0
    	 mvp = $game_troop.alive_members[0]
    end

    if mvp.actor?
      s = mvp.actor.note.split("\r\n")[0].split(" = ").last
      b = mvp.actor.note.split("\r\n")[1].split(" = ").last
    else #敌人出手，反弹死自己
      s = mvp.enemy.note.split("\r\n")[4].split(" = ").last
      b = mvp.enemy.note.split("\r\n")[5].split(" = ").last
    end

    s = s.to_s
    b = b.to_i
    if b > 3 
      b = b-4
      c = 224
    else
      c = 0
    end
    b = b*160

    @over_back_win = Sprite.new
    if $game_troop.alive_members.size == 0
      @over_back_win.bitmap = Bitmap.new("Graphics/System/over_back_win")
    else
      @over_back_win.bitmap =  Bitmap.new("Graphics/System/over_back_lost")
    end
    @over_back_win.x = 405
    @over_back_win.y = 0
    @over_back_win.z = 905
    @over_back_win.bitmap.font.size = 20 + $game_variables[300]+1
    @over_back_win.bitmap.font.color = Color.new(255,255,255,255)
    @over_back_win.bitmap.font.name  = (["Noto"])
    if mvp.actor?
       mvptext = "#{mvp.name}"  + "「" + "#{mvp.description}" + "」"+"!"
       @over_back_win.tone = Tone.new(255,255,255,255) 
    else
       if $game_switches[694] == true
          mvptext = "本次练兵"  + "「未能达成」!"
       else
          mvptext = "#{mvp.name}"  + "「养兵十年再战不迟」!"
       end
    end
    @over_back_win.bitmap.draw_text(170, 178, 450, 30, mvptext, 0)

    _bitmap = Bitmap.new("Graphics/Faces/#{s}")
    @over_back_win.bitmap.blt(23,4,_bitmap,Rect.new(b, c, 160, 224))
    _bitmap.dispose; _bitmap = nil

    @over_back_list = Sprite.new
    @over_back_list.bitmap = Bitmap.new("Graphics/System/over_back_list")
    @over_back_list.x = 339#+100
    @over_back_list.y = 214
    @over_back_list.opacity = 0
    @over_back_list.z = 906

    @over_item = Sprite.new
    @over_item.bitmap = Bitmap.new("Graphics/System/over_item")
    @over_item.x = 0
    @over_item.y = 550+56
    @over_item.z = 960
    @over_item.opacity = 0
    @over_item.bitmap.font.size = 20 + $game_variables[300]
    @over_item.bitmap.font.name  = (["Noto"])
    @over_item.bitmap.draw_text(463,      48, 100, 40, "#{$game_troop.exp_total}" , 1) 
    @over_item.bitmap.draw_text(463+64,   48, 100, 40, "#{$game_troop.expbook_total}" , 1) 
    @over_item.bitmap.draw_text(463+64*2, 48, 100, 40, "#{$game_troop.gold_total}" , 1) 
    @over_item.bitmap.draw_text(463+64*3, 48, 100, 40, "#{battle_dead_size}" , 1) 
    @over_item.bitmap.draw_text(463+64*4, 48, 100, 40, "#{$game_troop.turn_count}" , 1) 

    $game_switches[492] = true

    # REMARK 新建前先 dispose
    # @message_window.dispose
    # @message_window = nil

    # @message_window = Window_Message.new

    if @message_window
      @message_window.hide_back
      @message_window.z = 980
    end

    case $game_party.members.size
    when 1
        actor_0(all_max)
    when 2
        actor_0(all_max)
        actor_1(all_max)
    when 3
        actor_0(all_max)
        actor_1(all_max)
        actor_2(all_max)
    when 4
        actor_0(all_max)
        actor_1(all_max)
        actor_2(all_max)
        actor_3(all_max)
    when 5
        actor_0(all_max)
        actor_1(all_max)
        actor_2(all_max)
        actor_3(all_max)
        actor_4(all_max)
    end  

    @chang_x = -227+86-1
    case $game_troop.members.size
    when 1
        enemy_0(all_max)
    when 2
        enemy_0(all_max)
        enemy_1(all_max)
    when 3
        enemy_0(all_max)
        enemy_1(all_max)
        enemy_2(all_max)
    when 4
        enemy_0(all_max)
        enemy_1(all_max)
        enemy_2(all_max)
        enemy_3(all_max)
    when 5
        enemy_0(all_max)
        enemy_1(all_max)
        enemy_2(all_max)
        enemy_3(all_max)
        enemy_4(all_max)
    when 6
        enemy_5(all_max)
        enemy_0(all_max)
        enemy_1(all_max)
        enemy_2(all_max)
        enemy_3(all_max)
        enemy_4(all_max)
    end

    m = [$game_party.members.size , $game_troop.members.size].max
    @over_nc_back = Sprite.new
    @over_nc_back.bitmap = Bitmap.new("Graphics/System/over_nc_back_"+"#{m}")
    @over_nc_back.x = 211
    @over_nc_back.y = 213+@chang_y
    @over_nc_back.z = 901


    _bitmap = Bitmap.new("Graphics/System/over_nc_icon")
    @_opacity.bitmap.blt(278,216,_bitmap,Rect.new(0,0,54,54))
    @_opacity_2.bitmap.blt(949,216,_bitmap,Rect.new(0,0,54,54))
    @_opacity.bitmap.blt(278,216+@hg,_bitmap,Rect.new(0,0,54,54)) if m > 1
    @_opacity_2.bitmap.blt(949,216+@hg,_bitmap,Rect.new(0,0,54,54)) if m > 1
    @_opacity.bitmap.blt(278,216+@hg*2,_bitmap,Rect.new(0,0,54,54)) if m > 2
    @_opacity_2.bitmap.blt(949,216+@hg*2,_bitmap,Rect.new(0,0,54,54)) if m > 2
    @_opacity.bitmap.blt(278,216+@hg*3,_bitmap,Rect.new(0,0,54,54)) if m > 3
    @_opacity_2.bitmap.blt(949,216+@hg*3,_bitmap,Rect.new(0,0,54,54)) if m > 3
    @_opacity.bitmap.blt(278,216+@hg*4,_bitmap,Rect.new(0,0,54,54)) if m > 4
    @_opacity_2.bitmap.blt(949,216+@hg*4,_bitmap,Rect.new(0,0,54,54)) if m > 4
    @_opacity.bitmap.blt(278,216+@hg*5,_bitmap,Rect.new(0,0,54,54)) if m > 5
    @_opacity_2.bitmap.blt(949,216+@hg*5,_bitmap,Rect.new(0,0,54,54)) if m > 5
    _bitmap.dispose; _bitmap = nil


    _bitmap = Bitmap.new("Graphics/System/over_sum")
    @_opacity.bitmap.blt(180,118,_bitmap,Rect.new(0,0,257,105))
    @_opacity_2.bitmap.blt(851,118,_bitmap,Rect.new(0,0,257,105))
    _bitmap.dispose; _bitmap = nil



    @_opacity.bitmap.font.size = 27 + $game_variables[300]
    @_opacity_2.bitmap.font.size = 27 + $game_variables[300]
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(129+124,  79+76-2, 100, 40, "#{enemy_sum.to_i}" , 1) 
    @_opacity_2.bitmap.draw_text(1051-124, 79+76-2, 100, 40, "#{actor_sum.to_i}" , 1)
    @_opacity.bitmap.font.size = 21 + $game_variables[300]
    @_opacity_2.bitmap.font.size = 21 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,200,0,255)
    @_opacity_2.bitmap.font.color = Color.new(255,200,0,255)
    if $game_party.over_plot_damage > 0
    @_opacity.bitmap.draw_text(1051+40-124, 55+76-2, 100, 40, "+"+"#{$game_party.over_plot_damage.to_i}" , 1) 
    end
    if $game_troop.over_plot_damage > 0
    @_opacity_2.bitmap.draw_text(129-40+124, 55+76-2, 100, 40, "#{$game_troop.over_plot_damage.to_i}"+"+" , 1) 
    end


   for i in 0...50
      @mask.opacity -= 10
      @_opacity.opacity += 6
      @_opacity_2.opacity += 6
      if i < 25
        @_opacity.x += 2
        @_opacity_2.x -= 2
      end
      @over_back_win.tone.set(255-i*5,255-i*5,255-i*5,0)
      abs_wait(1)
   end

    @mask.bitmap.dispose
    @mask.dispose
    @mask = nil

    @flash_mc = Sprite_Flash.new
    @flash_mc.bitmap = Bitmap.new("Graphics/flash/mc")  
    @flash_mc.x = 540
    @flash_mc.y = 609 
    @flash_mc.z = 1001
    @flash_mc.opacity = 0

    for i in 0...9999999
      @flash_mc.update
      abs_wait(1)
      if Input.trigger?(:B) || Input.trigger?(:C)
        Audio.se_play("Audio/SE/0short01b",100,90)
        break
      end
    end

    unless $game_switches[694] == true
      for i in 0...25
        @flash_mc.opacity -= 11
        opacity_nc
        @over_item.opacity += 11
        @over_item.y -= 2
        @over_back_list.x += 4 
        @over_back_list.opacity += 11 
        abs_wait(1)
      end
    else
      $game_switches[694] = false
    end

end


  def opacity_nc
    @over_nc_back.opacity -= 15 
    @over_daizheng.opacity -= 15
    @over_daizheng.x += 5 
    @_opacity.opacity -= 15     
    @_opacity_2.opacity -= 15     
    @_opacity.x -= 6
    @_opacity_2.x += 6
  end
  #--------------------------------------------------------------------------
  # ● 创建我方统计数据精灵
  #--------------------------------------------------------------------------
  def actor_0(all_max)
    #角色的头像
    actor = $game_party.members[0]
    damage = actor.over_damage
    if damage > 0 
    damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
    damage_line = 0
    end

    _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor.face_name}")
    @_opacity_2.bitmap.blt(1215+@chang_x,223+@chang_y,_bitmap,Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58))
    _bitmap.dispose; _bitmap = nil


    #角色的伤害输出条
    x = 1186-damage_line+@chang_x
    y = 229+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 244+@chang_y, 1, 7, @col) if damage_line > 1
    #角色的辅助条
    sup = actor.over_sup
    if sup > 0
    sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
    sup_line = 0
    end
    x = 1186-sup_line+@chang_x
    y = 226+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 254+@chang_y, 1, 7, @col) if sup_line > 1
    #在透明图片上写出角色的，伤害和辅助，两个数值
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity_2.bitmap.font.name  = (["Noto"])
    @_opacity_2.bitmap.draw_text(982+@chang_x, 224+@chang_y, 200, 40, "#{damage.to_i}" , 2) if actor.over_damage > 0
    @_opacity_2.bitmap.font.size = 17 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(1196+@chang_x, 223+37+@chang_y, 100, 40, "#{actor.name}" , 1)
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(982+@chang_x, 243+@chang_y, 200, 40, "#{sup.to_i}" , 2)  if actor.over_sup > 0

    if actor.next_level_exp - actor.exp - @over_exp <= 0

      _bitmap = Bitmap.new("Graphics/System/upup")
      @_opacity_2.bitmap.blt(1255+@chang_x,252+@hg*actor.index+@chang_y,_bitmap,Rect.new(0,0,37,23))
      _bitmap.dispose; _bitmap = nil

    end

  end    


  def actor_1(all_max)
    actor = $game_party.members[1]
    damage = actor.over_damage
    if damage > 0 
    damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
    damage_line = 0
    end

    _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor.face_name}")
    @_opacity_2.bitmap.blt(1215+@chang_x,223+@hg*actor.index+@chang_y,_bitmap,Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58))
    _bitmap.dispose; _bitmap = nil


    #角色的伤害输出条
    x = 1186-damage_line+@chang_x
    y = 229+@hg*actor.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 244+@hg*actor.index+@chang_y, 1, 7, @col) if damage_line > 1
    #角色的辅助条
    sup = actor.over_sup
    if sup > 0
    sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
    sup_line = 0
    end
    x = 1186-sup_line+@chang_x
    y = 226+@hg*actor.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 254+@hg*actor.index+@chang_y, 1, 7, @col) if sup_line > 1
    #在透明图片上写出角色的，伤害和辅助，两个数值
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity_2.bitmap.font.name  = (["Noto"])
    @_opacity_2.bitmap.draw_text(982+@chang_x, 224+@hg*actor.index+@chang_y, 200, 40, "#{damage.to_i}" , 2) if actor.over_damage > 0
    @_opacity_2.bitmap.font.size = 17 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(1196+@chang_x, 223+37+@hg*actor.index+@chang_y, 100, 40, "#{actor.name}" , 1)
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(982+@chang_x, 243+@hg*actor.index+@chang_y, 200, 40, "#{sup.to_i}" , 2) if actor.over_sup > 0

    if actor.next_level_exp - actor.exp - @over_exp <= 0

      _bitmap = Bitmap.new("Graphics/System/upup")
      @_opacity_2.bitmap.blt(1255+@chang_x,252+@hg*actor.index+@chang_y,_bitmap,Rect.new(0,0,37,23))
      _bitmap.dispose; _bitmap = nil

    end
  end

  def actor_2(all_max)
    actor = $game_party.members[2]
    damage = actor.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor.face_name}")
    @_opacity_2.bitmap.blt(1215+@chang_x,223+@hg*actor.index+@chang_y,_bitmap,Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58))
    _bitmap.dispose; _bitmap = nil

    #角色的伤害输出条
    x = 1186-damage_line+@chang_x
    y = 229+@hg*actor.index+@chang_y
    
    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 244+@hg*actor.index+@chang_y, 1, 7, @col) if damage_line > 1
    #角色的辅助条
    sup = actor.over_sup
    if sup > 0
    sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
    sup_line = 0
    end
    x = 1186-sup_line+@chang_x
    y = 226+@hg*actor.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 254+@hg*actor.index+@chang_y, 1, 7, @col) if sup_line > 1
    #在透明图片上写出角色的，伤害和辅助，两个数值
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity_2.bitmap.font.name  = (["Noto"])
    @_opacity_2.bitmap.draw_text(982+@chang_x, 224+@hg*actor.index+@chang_y, 200, 40, "#{damage.to_i}" , 2) if actor.over_damage > 0
    @_opacity_2.bitmap.font.size = 17 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(1196+@chang_x, 223+37+@hg*actor.index+@chang_y, 100, 40, "#{actor.name}" , 1)
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(982+@chang_x, 243+@hg*actor.index+@chang_y, 200, 40, "#{sup.to_i}" , 2) if actor.over_sup > 0
    if actor.next_level_exp - actor.exp - @over_exp <= 0

      _bitmap = Bitmap.new("Graphics/System/upup")
      @_opacity_2.bitmap.blt(1255+@chang_x,252+@hg*actor.index+@chang_y,_bitmap,Rect.new(0,0,37,23))
      _bitmap.dispose; _bitmap = nil


    end
  end

  def actor_3(all_max)
    actor = $game_party.members[3]
    damage = actor.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor.face_name}")
    @_opacity_2.bitmap.blt(1215+@chang_x,223+@hg*actor.index+@chang_y,_bitmap,Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58))
    _bitmap.dispose; _bitmap = nil

    #角色的伤害输出条
    x = 1186-damage_line+@chang_x
    y = 229+@hg*actor.index+@chang_y
    
    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 244+@hg*actor.index+@chang_y, 1, 7, @col) if damage_line > 1
    #角色的辅助条
    sup = actor.over_sup
    if sup > 0
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
      sup_line = 0
    end
    x = 1186-sup_line+@chang_x
    y = 226+@hg*actor.index+@chang_y
    
    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 254+@hg*actor.index+@chang_y, 1, 7, @col) if sup_line > 1
    #在透明图片上写出角色的，伤害和辅助，两个数值
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity_2.bitmap.font.name  = (["Noto"])
    @_opacity_2.bitmap.draw_text(982+@chang_x, 224+@hg*actor.index+@chang_y, 200, 40, "#{damage.to_i}" , 2) if actor.over_damage > 0
    @_opacity_2.bitmap.font.size = 17 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(1196+@chang_x, 223+37+@hg*actor.index+@chang_y, 100, 40, "#{actor.name}" , 1)
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(982+@chang_x, 243+@hg*actor.index+@chang_y, 200, 40, "#{sup.to_i}" , 2) if actor.over_sup > 0
    if actor.next_level_exp - actor.exp - @over_exp <= 0

      _bitmap = Bitmap.new("Graphics/System/upup")
      @_opacity_2.bitmap.blt(1255+@chang_x,252+@hg*actor.index+@chang_y,_bitmap,Rect.new(0,0,37,23))
      _bitmap.dispose; _bitmap = nil

    end
  end
       
  def actor_4(all_max)  
    actor = $game_party.members[4]
    damage = actor.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    _bitmap = Bitmap.new("Graphics/Faces/sface/#{actor.face_name}")
    @_opacity_2.bitmap.blt(1215+@chang_x,223+@hg*actor.index+@chang_y,_bitmap,Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58))
    _bitmap.dispose; _bitmap = nil


    #角色的伤害输出条
    x = 1186-damage_line+@chang_x
    y = 229+@hg*actor.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil


    @_opacity_2.bitmap.fill_rect(x, 244+@hg*actor.index+@chang_y, 1, 7, @col) if damage_line > 1
    #角色的辅助条
    sup = actor.over_sup
    if sup > 0
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
      sup_line = 0
    end
    x = 1186-sup_line+@chang_x
    y = 226+@hg*actor.index+@chang_y
    
    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity_2.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity_2.bitmap.fill_rect(x, 254+@hg*actor.index+@chang_y, 1, 7, @col) if sup_line > 1
    #在透明图片上写出角色的，伤害和辅助，两个数值
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity_2.bitmap.font.name  = (["Noto"])
    @_opacity_2.bitmap.draw_text(982+@chang_x, 224+@hg*actor.index+@chang_y, 200, 40, "#{damage.to_i}" , 2) if actor.over_damage > 0
    @_opacity_2.bitmap.font.size = 17 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(1196+@chang_x, 223+37+@hg*actor.index+@chang_y, 100, 40, "#{actor.name}" , 1)
    @_opacity_2.bitmap.font.size = 18 + $game_variables[300]
    @_opacity_2.bitmap.draw_text(982+@chang_x, 243+@hg*actor.index+@chang_y, 200, 40, "#{sup.to_i}" , 2) if actor.over_sup > 0
    if actor.next_level_exp - actor.exp - @over_exp <= 0

      _bitmap = Bitmap.new("Graphics/System/upup")
      @_opacity_2.bitmap.blt(1255+@chang_x,252+@hg*actor.index+@chang_y,_bitmap,Rect.new(0,0,37,23))
      _bitmap.dispose; _bitmap = nil

    end
  end 

  #--------------------------------------------------------------------------
  # ● 创建敌人统计数据精灵
  #--------------------------------------------------------------------------
  def enemy_0(all_max)
    #敌人_的的头像
    enemy = $game_troop.members[0]
    s = enemy.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = enemy.enemy.note.split("\r\n")[5].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 58
    else
      c = 0
    end
    b = b*58
    damage = enemy.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end
    

    # @_opacity.bitmap.blt(376+@chang_x,223+@chang_y,Cache.sface("#{s}"),Rect.new(b, c, 58, 58))
    _bitmap = Bitmap.new("Graphics/Faces/sface/#{s}")
    @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,_bitmap,Rect.new(b, c, 58, 58))
    _bitmap.dispose; _bitmap = nil


    #敌人_的伤害输出条
    x = 462+@chang_x
    y = 229+@hg_6+@hg*enemy.index+@chang_y
    
    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+damage_line, 244+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if damage_line > 1
    #敌人_的的辅助条
    sup = enemy.over_sup
    if sup > 0
    sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
    sup_line = 0
    end
    x = 462+@chang_x
    y = 226+@hg_6+@hg*enemy.index+@chang_y
    
    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+sup_line, 254+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if sup_line > 1
    #在透明图片上写出敌人_的，伤害和辅助，两个数值
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(469+@chang_x, 224+@hg_6+@chang_y, 200, 40, "#{damage.to_i}" , 0) if enemy.over_damage > 0
    @_opacity.bitmap.font.size = 17 + $game_variables[300]
    @_opacity.bitmap.draw_text(357+@chang_x, 223+37+@hg_6+@chang_y, 100, 40, "#{enemy.name}" , 1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.draw_text(469+@chang_x, 243+@hg_6+@chang_y, 200, 40, "#{sup.to_i}" , 0)  if enemy.over_sup > 0
  end       

  def enemy_1(all_max)
    #敌人_的的头像
    enemy = $game_troop.members[1]
    s = enemy.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = enemy.enemy.note.split("\r\n")[5].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 58
    else
      c = 0
    end
    b = b*58
    damage = enemy.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    # @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,Cache.sface("#{s}"),Rect.new(b, c, 58, 58))
    _bitmap = Bitmap.new("Graphics/Faces/sface/#{s}")
    @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,_bitmap,Rect.new(b, c, 58, 58))
    _bitmap.dispose; _bitmap = nil


    #敌人_的伤害输出条
    x = 462+@chang_x
    y = 229+@hg*enemy.index+@hg_6+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil


    @_opacity.bitmap.fill_rect(x+damage_line, 244+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if damage_line > 1
    #敌人_的辅助条
    sup = enemy.over_sup
    if sup > 0
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
      sup_line = 0
    end
    x = 462+@chang_x
    y = 226+@hg*enemy.index+@hg_6+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+sup_line, 254+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if sup_line > 1
    #在透明图片上写出敌人_的，伤害和辅助，两个数值
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(469+@chang_x, 224+@hg*enemy.index+@chang_y+@hg_6, 200, 40, "#{damage.to_i}" , 0) if enemy.over_damage > 0
    @_opacity.bitmap.font.size = 17 + $game_variables[300]
    @_opacity.bitmap.draw_text(357+@chang_x, 223+37+@hg*enemy.index+@chang_y+@hg_6, 100, 40, "#{enemy.name}" , 1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.draw_text(469+@chang_x, 243+@hg*enemy.index+@chang_y+@hg_6, 200, 40, "#{sup.to_i}" , 0) if enemy.over_sup > 0
  end

  def enemy_2(all_max)
    #敌人_的的头像
    enemy = $game_troop.members[2]
    s = enemy.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = enemy.enemy.note.split("\r\n")[5].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 58
    else
      c = 0
    end
    b = b*58
    damage = enemy.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    # @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,Cache.sface("#{s}"),Rect.new(b, c, 58, 58))
    _bitmap = Bitmap.new("Graphics/Faces/sface/#{s}")
    @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,_bitmap,Rect.new(b, c, 58, 58))
    _bitmap.dispose; _bitmap = nil

    #敌人_的伤害输出条
    x = 462+@chang_x
    y = 229+@hg_6+@hg*enemy.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+damage_line, 244+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if damage_line > 1
    #敌人_的辅助条
    sup = enemy.over_sup
    if sup > 0 
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor 
    else
      sup_line = 0
    end
    x = 462+@chang_x
    y = 226+@hg*enemy.index+@hg_6+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+sup_line, 254+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if sup_line > 1
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(469+@chang_x, 224+@hg_6+@hg*enemy.index+@chang_y, 200, 40, "#{damage.to_i}" , 0) if enemy.over_damage > 0
    @_opacity.bitmap.font.size = 17 + $game_variables[300]
    @_opacity.bitmap.draw_text(357+@chang_x, 223+37+@hg_6+@hg*enemy.index+@chang_y, 100, 40, "#{enemy.name}" , 1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.draw_text(469+@chang_x, 243+@hg_6+@hg*enemy.index+@chang_y, 200, 40, "#{sup.to_i}" , 0) if enemy.over_sup > 0
  end          

  def enemy_3(all_max)
    #敌人_的的头像
    enemy = $game_troop.members[3]
    s = enemy.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = enemy.enemy.note.split("\r\n")[5].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 58
    else
      c = 0
    end
    b = b*58
    damage = enemy.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    # @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,Cache.sface("#{s}"),Rect.new(b, c, 58, 58))
    _bitmap = Bitmap.new("Graphics/Faces/sface/#{s}")
    @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,_bitmap,Rect.new(b, c, 58, 58))
    _bitmap.dispose; _bitmap = nil

    #敌人_的伤害输出条
    x = 462+@chang_x
    y = 229+@hg_6+@hg*enemy.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+damage_line, 244+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if damage_line > 1
    #敌人_的辅助条
    sup = enemy.over_sup
    if sup > 0
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
      sup_line = 0
    end
    x = 462+@chang_x
    y = 226+@hg_6+@hg*enemy.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+sup_line, 254+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if sup_line > 1
    #在透明图片上写出敌人_的，伤害和辅助，两个数值
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(469+@chang_x, 224+@hg_6+@hg*enemy.index+@chang_y, 200, 40, "#{damage.to_i}" , 0) if enemy.over_damage > 0
    @_opacity.bitmap.font.size = 17 + $game_variables[300]
    @_opacity.bitmap.draw_text(357+@chang_x, 223+37+@hg_6+@hg*enemy.index+@chang_y, 100, 40, "#{enemy.name}" , 1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.draw_text(469+@chang_x, 243+@hg_6+@hg*enemy.index+@chang_y, 200, 40, "#{sup.to_i}" , 0) if enemy.over_sup > 0
  end

  def enemy_4(all_max)
    #敌人_的的头像
    enemy = $game_troop.members[4]
    s = enemy.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = enemy.enemy.note.split("\r\n")[5].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 58
    else
      c = 0
    end
    b = b*58
    damage = enemy.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    # @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,Cache.sface("#{s}"),Rect.new(b, c, 58, 58))
    _bitmap = Bitmap.new("Graphics/Faces/sface/#{s}")
    @_opacity.bitmap.blt(376+@chang_x,223+@hg_6+@hg*enemy.index+@chang_y,_bitmap,Rect.new(b, c, 58, 58))
    _bitmap.dispose; _bitmap = nil

    #敌人_的伤害输出条
    x = 462+@chang_x
    y = 229+@hg_6+@hg*enemy.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+damage_line, 244+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if damage_line > 1
    #敌人_的辅助条
    sup = enemy.over_sup
    if sup > 0
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
      sup_line = 0
    end
    x = 462+@chang_x
    y = 226+@hg_6+@hg*enemy.index+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+sup_line, 254+@hg*enemy.index+@chang_y+@hg_6, 1, 7, @col) if sup_line > 1
    #在透明图片上写出敌人_的，伤害和辅助，两个数值
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(469+@chang_x, 224+@hg_6+@hg*enemy.index+@chang_y, 200, 40, "#{damage.to_i}" , 0) if enemy.over_damage > 0
    @_opacity.bitmap.font.size = 17 + $game_variables[300]
    @_opacity.bitmap.draw_text(357+@chang_x, 223+37+@hg_6+@hg*enemy.index+@chang_y, 100, 40, "#{enemy.name}" , 1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.draw_text(469+@chang_x, 243+@hg_6+@hg*enemy.index+@chang_y, 200, 40, "#{sup.to_i}" , 0) if enemy.over_sup > 0
  end

  def enemy_5(all_max)
    #敌人_的的头像
    enemy = $game_troop.members[5]
    s = enemy.enemy.note.split("\r\n")[4].split(" = ").last
    s = s.to_s
    b = enemy.enemy.note.split("\r\n")[5].split(" = ").last
    b = b.to_i
    if b > 3 
      b = b-4
      c = 58
    else
      c = 0
    end
    b = b*58
    damage = enemy.over_damage
    if damage > 0 
      damage_line = ( damage*1.0 / all_max * 270.0 ).floor 
    else
      damage_line = 0
    end

    _bitmap = Bitmap.new("Graphics/Faces/sface/#{s}")
    @_opacity.bitmap.blt(376+@chang_x,223+@chang_y,_bitmap,Rect.new(b, c, 58, 58))
    _bitmap.dispose; _bitmap = nil
    # @_opacity.bitmap.blt(376+@chang_x,223+@chang_y,Cache.sface("#{s}"),Rect.new(b, c, 58, 58))
    
    #敌人_的伤害输出条
    x = 462+@chang_x
    y = 229+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_damage_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,damage_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+damage_line, 244+@chang_y, 1, 7, @col) if damage_line > 1
    #敌人_的的辅助条
    sup = enemy.over_sup
    if sup > 0
      sup_line = ( sup*1.0 / all_max * 270.0 ).floor
    else
      sup_line = 0
    end
    x = 462+@chang_x
    y = 226+@chang_y

    _bitmap = Bitmap.new("Graphics/System/over_sup_bar")
    @_opacity.bitmap.blt(x,y,_bitmap,Rect.new(0,0,sup_line,35))
    _bitmap.dispose; _bitmap = nil

    @_opacity.bitmap.fill_rect(x+sup_line, 254+@chang_y, 1, 7, @col) if sup_line > 1
    #在透明图片上写出敌人_的，伤害和辅助，两个数值
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.font.color = Color.new(255,255,255,255)
    @_opacity.bitmap.font.name  = (["Noto"])
    @_opacity.bitmap.draw_text(469+@chang_x, 224+@chang_y, 200, 40, "#{damage.to_i}" , 0) if enemy.over_damage > 0
    @_opacity.bitmap.font.size = 17 + $game_variables[300]
    @_opacity.bitmap.draw_text(357+@chang_x, 223+37+@chang_y, 100, 40, "#{enemy.name}" , 1)
    @_opacity.bitmap.font.size = 18 + $game_variables[300]
    @_opacity.bitmap.draw_text(469+@chang_x, 243+@chang_y, 200, 40, "#{sup.to_i}" , 0)  if enemy.over_sup > 0
  end   
  #--------------------------------------------------------------------------
  # ● 司马懿天变删除
  #--------------------------------------------------------------------------
  def dispose_sima
    if @sima != nil and @sima != []
     for i in 0...26
        @sima.opacity -= 10
        abs_wait(1)
     end  
      @sima.bitmap.dispose
      @sima.dispose
      @sima = nil
    end
  end 
  #--------------------------------------------------------------------------
  # ● 删除经验值精灵
  #--------------------------------------------------------------------------
  def dispose_exp
    if @over_nc_back 
      @over_nc_back.bitmap.dispose
      @over_nc_back.dispose 
      @over_nc_back = nil
    end
    if @_opacity ; @_opacity.bitmap.dispose ; @_opacity.dispose ; @_opacity = nil; end
    if @_opacity_2 ; @_opacity_2.bitmap.dispose ; @_opacity_2.dispose ; @_opacity_2 = nil; end
    if @over_back_list ; @over_back_list.bitmap.dispose ; @over_back_list.dispose ; @over_back_list = nil; end
    if @over_back ; @over_back.bitmap.dispose ; @over_back.dispose ; @over_back = nil ; end
    if @over_back_win ; @over_back_win.bitmap.dispose ; @over_back_win.dispose ; @over_back_win = nil ; end 
    if @flash_mc ; @flash_mc.bitmap.dispose ; @flash_mc.dispose ; @flash_mc = nil ; end
    if @over_daizheng ; @over_daizheng.bitmap.dispose ; @over_daizheng.dispose ; @over_daizheng = nil ; end
    if @over_item ; @over_item.bitmap.dispose ; @over_item.dispose ; @over_item = nil ; end
    @col = nil
    @hg = nil
    @hg_6 = nil

  end

end