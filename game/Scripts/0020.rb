#encoding:utf-8
#==============================================================================
# ■ BattleFiber
#------------------------------------------------------------------------------
# 　战斗纤程管理器
#   
#==============================================================================
module BattleFiber
  @fiber = nil
  # 预先缓存
  @fc_actor = nil
  @fc_enemy = nil
  @fc_wave  = nil
  @fc_msg   = nil
  @fc_sk    = nil

  @sk_actor = nil
  @sk_enemy = nil

  # @fc_actor.attrset :x=>878,:y=>480
  # @fc_enemy.attrset :x=>0,:y=>480

  # @sk_actor.attrset :x=>878+100,:y=>100
  # @sk_enemy.attrset :x=>-100,:y=>260

  @is_animation = false

  def self.create_sprites
    @fc_actor = Sprite.new
    @fc_enemy = Sprite.new
    @fc_wave  = Sprite.new
    @fc_msg   = Sprite.new
    @fc_sk    = Sprite.new
    @sk_actor_light = Sprite.new
    @sk_actor = Sprite.new
    @sk_enemy = Sprite.new

    @fc_actor.attrset :x=>878,:y=>480
    @fc_enemy.attrset :x=>0,:y=>480

   # @sk_actor.attrset :x=>878+100,:y=>100
   @sk_actor.attrset :x=>0,:y=>0
    @sk_enemy.attrset :x=>-100,:y=>260
  end

  def self.dispose_sprites
    # [@fc_actor, @fc_enemy, @fc_wave, @fc_msg, @fc_sk, @sk_actor, @sk_enemy].each do |sp|
    #   if sp
    #     sp.bitmap.dispose if sp.bitmap
    #     sp.dispose
    #   end
    #   sp = nil
    # end

    if @fc_actor
      @fc_actor.dispose 
      if @fc_actor.bitmap && !@fc_actor.bitmap.disposed?
        @fc_actor.bitmap.dispose
      end
      @fc_actor = nil
    end
    if @fc_enemy
      @fc_enemy.dispose 
      if @fc_enemy.bitmap && !@fc_enemy.bitmap.disposed?
        @fc_enemy.bitmap.dispose
      end
      @fc_enemy = nil
    end
    if @fc_wave
      @fc_wave.dispose 
      if @fc_wave.bitmap && !@fc_wave.bitmap.disposed?
        @fc_wave.bitmap.dispose
      end
      @fc_wave = nil
    end
    if @fc_msg
      @fc_msg.dispose 
      if @fc_msg.bitmap && !@fc_msg.bitmap.disposed?
        @fc_msg.bitmap.dispose
      end
      @fc_msg = nil
    end
    if @fc_sk
      @fc_sk.dispose 
      if @fc_sk.bitmap && !@fc_sk.bitmap.disposed?
        @fc_sk.bitmap.dispose
      end
      @fc_sk = nil
    end
    if @sk_actor
      @sk_actor.dispose 
      if @sk_actor.bitmap && !@sk_actor.bitmap.disposed?
        @sk_actor.bitmap.dispose
      end
      @sk_actor = nil
    end
    if @sk_enemy
      @sk_enemy.dispose 
      if @sk_enemy.bitmap && !@sk_enemy.bitmap.disposed?
        @sk_enemy.bitmap.dispose
      end
      @sk_enemy = nil
    end
    
    # @fc_actor.bitmap.dispose if @fc_actor.bitmap && !@fc_actor.bitmap.disposed?
    # @fc_enemy.bitmap.dispose if @fc_enemy.bitmap && !@fc_enemy.bitmap.disposed?
    # @fc_wave.bitmap.dispose if @fc_wave.bitmap && !@fc_wave.bitmap.disposed?
    # @fc_msg.bitmap.dispose if @fc_msg.bitmap && !@fc_msg.bitmap.disposed?
    # @fc_sk.bitmap.dispose if @fc_sk.bitmap && !@fc_sk.bitmap.disposed?
    # @sk_enemy.bitmap.dispose if @sk_enemy.bitmap && !@sk_enemy.bitmap.disposed?
    # @fc_actor.bitmap = nil ; @fc_enemy.bitmap = nil; @fc_wave.bitmap = nil; @fc_msg.bitmap = nil; @fc_sk.bitmap = nil
    # @sk_actor.bitmap = nil ; @sk_enemy = nil;
  end

  def self.fc_actor
    @fc_actor
  end

  def self.fc_enemy
    @fc_enemy
  end

  def self.update_wave
    @fc_wave.update if @fc_wave and $game_switches[486] == true
  end

  def self.is_animation?
    @is_animation
  end

  def self.clear
    @fiber = nil
  end

  # 行动无效动画
  def self.action_invalid(subject,&graphics_update)
    subject.animation :forward
    24.times { graphics_update.call }
    subject.animation :back
    24.times { graphics_update.call }
  end

  def self.init_formation(obj,graphics_update)
    @fc_actor.attrset :x=>1020,:y=>302,:z=>900
    @fc_enemy.attrset :x=>0,:y=>302,:z=>900
    
    obj.actor?? (fc_p = @fc_actor) : (fc_p = @fc_enemy)

    unless fc_p.bitmap.nil?
      20.times do 
        fc_p.opacity -= 13
        graphics_update.call
      end
    else
      fc_p.opacity = 0
    end

    @fc_wave.attrset :ox=>0,:oy=>0,:x=>-98,:y=>62
    @fc_wave.attrset :wave_amp=>80,:wave_length=>240,:wave_speed=>500,:opacity=>0
    @fc_msg.attrset :x=>0,:y=>242,:z=>100,:opacity=>0
    @fc_sk.attrset :y=>311,:opacity=>0,:z=>901
  end

  def self.init_skill(subject,graphics_update)
    if subject.actor?
     # @sk_actor.attrset :x=>878+100
     @sk_actor.attrset :x=>0
    else
      @sk_enemy.attrset :x=>-100
    end
    @fc_wave.attrset :ox=>0,:oy=>0,:x=>-98,:y=>62
    @fc_wave.attrset :wave_amp=>80,:wave_length=>240,:wave_speed=>500,:opacity=>0
  end

  def self.update_formation_sk(num_range,fc_sk_base_incr,graphics_update)
    @fc_sk.x += fc_sk_base_incr
    num_range.each do |num|
      @fc_sk.bitmap = Cache.fc("fc_sk/open#{num}")
      2.times { @fc_wave.update ; graphics_update.call }
    end
  end

  def self.hide_fc_picture(object)
    @fc_actor.bitmap.dispose if object == :actor
    @fc_enemy.bitmap.dispose if object == :enemy
  end

#阵法开始
  def self.update_formation_pos(subject)
    formation = $data_skills[subject.current_action.item.id]
         if subject.current_action.item.id == 12 and $game_party.formation.id == 4
            else 
              if subject.current_action.item.id != $game_party.formation.id
               Audio.se_play("Audio/SE/fcmove") 
              end 
            end
    subject.unit.members.each_with_index do |member,index|
      if index < 5
        member.animation :formation,:pos=>formation.pos[index]
      end
    end
  end


#阵法解散
  def self.fast_create_formation(unit,formation_id)
    Audio.se_play("Audio/SE/fcmove")
    formation = $data_skills[formation_id]
    unit.members.each_with_index do |member,index|
      if index < 5
        member.animation :formation,:pos=>formation.pos[index]
        member.remove_state(14)
        member.remove_state(15)
        member.remove_state(288)
        member.remove_state(289)
        member.remove_state(290)
        member.remove_state(291)
        member.remove_state(292)
        member.remove_state(293)
        member.remove_state(294)
        member.remove_state(295)
        member.remove_state(296)
        member.remove_state(297)
      end
    end
    # 如果原来是八卦阵则清除
    unit.clear_bagua!
    unit.formation_id = formation_id
  end


  def self.create_formation_for_all_atk(cfg,&graphics_update)
    subject = cfg[:subject]
    for i in 0...$game_troop.alive_members.size
      $game_troop.alive_members[i].sprite_battler.flash(Color.new(253,97,193,255),80)
    end
    self.update_formation_pos(subject)
  end

  # 技能动画
  def self.create_skill(cfg,&graphics_update)
    @is_animation = true
    subject = cfg[:subject]
    self.init_skill(subject,graphics_update)
    @fiber = Fiber.new do |cfg,blk|
    @fc_wave.bitmap = Cache.zdbg($data_skills[subject.current_action.item.id].wave_filename)
    @fc_wave.z = 9

    xxx=(subject.screen_x-1176)
    yyy=(subject.screen_y-415)
        @sk_actor.opacity = 0
        if  subject.actor?
        @sk_actor.x = 55+350+xxx+250
        else
        @sk_actor.x = 55+350+xxx+110
        end
        @sk_actor.z = 991
        @sk_actor.y = 70+153+yyy+5
        sk = subject.current_action.item
         if sk.description.split("\r\n")[1] !=nil and sk.description.split("\r\n")[1][0,2] == "TT"
          sk = sk.description.split("\r\n")[1].split("TT=").last 
        else
          sk = sk.id
        end
 
        

         @sk_actor.bitmap = Cache.skillp("skill_kong")
         @sk_actor.bitmap.clear
         @sk_actor.bitmap.blt(0,0,Cache.skillp("skill_line"),Rect.new(0,0,473,178))
         skl = $data_skills[subject.current_action.item.id]
         yuan_id = 1
         yuan_id = skl.wave_filename_num
          if subject.actor?
              @sk_actor.bitmap.blt(128,0,Cache.skillp("skill_yuan"),Rect.new(yuan_id*150,0,150,178)) 
              s = subject.actor.note.split("\r\n")[0].split(" = ").last
              b = subject.actor.note.split("\r\n")[1].split(" = ").last
           else 
              @sk_actor.bitmap.blt(242,0,Cache.skillp("skill_yuan"),Rect.new(yuan_id*150,0,150,178)) 
              s = subject.enemy.note.split("\r\n")[4].split(" = ").last
              b = subject.enemy.note.split("\r\n")[5].split(" = ").last
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
        if subject.actor?
           @sk_actor.bitmap.blt(100,-65,Cache.face("#{s}"),Rect.new(b, c, 160, 224))
           @sk_actor.bitmap.font.name  = (["Notos"])
           @sk_actor.bitmap.font.color = Color.new(0,0,0,255)
           @sk_actor.bitmap.font.size = 81
           if skl.id >= 286 and skl.id <= 289
              sname_ = "天变"
           else
              sname_ = skl.name
           end
           @sk_actor.bitmap.draw_text(230,11,250,150,"#{sname_}")
           @sk_actor.bitmap.draw_text(231,10,250,150,"#{sname_}")
           @sk_actor.bitmap.draw_text(231,12,250,150,"#{sname_}")
           @sk_actor.bitmap.draw_text(232,11,250,150,"#{sname_}")
           @sk_actor.bitmap.font.color = Color.new(255,255,255,255)
           @sk_actor.bitmap.draw_text(231,11,250,150,"#{sname_}")
           @sk_actor.bitmap.blt(200,30,Cache.skillp("wjj"),Rect.new(0, 0, 74, 31))
        else
           sk2 = skl.name.split("★")[0]
           @sk_actor.bitmap.blt(245,-65,Cache.face("#{s}"),Rect.new(b, c, 160, 224))
           @sk_actor.bitmap.font.name  = (["Notos"])
           @sk_actor.bitmap.font.color = Color.new(0,0,0,255)
           @sk_actor.bitmap.font.size = 81
           @sk_actor.bitmap.draw_text(24,11,250,150,"#{sk2}",2)
           @sk_actor.bitmap.draw_text(23,10,250,150,"#{sk2}",2)
           @sk_actor.bitmap.draw_text(23,12,250,150,"#{sk2}",2)
           @sk_actor.bitmap.draw_text(24,11,250,150,"#{sk2}",2)
           @sk_actor.bitmap.font.color = Color.new(255,255,255,255)
           @sk_actor.bitmap.draw_text(23,11,250,150,"#{sk2}",2)
           @sk_actor.bitmap.blt(222,30,Cache.skillp("wjj"),Rect.new(0, 0, 74, 31))
        end

        fc_picture = @sk_actor
        offset_x = 25
       # @sk_actor.zoom_x = 1.07
       #@sk_actor.zoom_y = 1.07
        @sk_actor.tone = Tone.new(255,255,255,255) 
        
        idd = subject.current_action.item.speed
    if  subject.actor?  #我方 #subject.current_action.item.id < 456
        @sk_actor_light.x = 0+680+xxx
        @sk_actor_light.y = 120+154+yyy
        @sk_actor_light.bitmap = Cache.system("Title_logo_light")
   else #敌人
        @sk_actor_light.x = 0+680+xxx-180+22
        @sk_actor_light.y = 120+154+yyy-1
        @sk_actor_light.bitmap = Cache.system("Title_logo_light_z")
   end
        @sk_actor_light.z = 99
        @sk_actor_light.blend_type = 1
        @sk_actor_light.opacity = 0


      while @fc_wave.opacity < 255
       # @fc_wave.update
        @fc_wave.opacity += 5
        graphics_update.call if $game_switches[486] == true
      end
      count = 0
      loop do
        #@fc_wave.update
        #graphics_update.call
        case count
        when 0
          sk = $data_skills[subject.current_action.item.id]
          if sk.speed != 55 and $game_switches[467] == true 
             if sk.description[0,2] != nil and sk.description[0,2] == "CV"
                cvid = sk.description.split("\r\n")[0].split("CV=").last
                if $game_switches[632] == false 
                   Audio.se_play("Audio/SE/Actor_fc_start/#{cvid}",100)
                else
                   Audio.se_play("Music/CVS/#{cvid}",100)
                end
             else
                if $game_switches[632] == false 
                   Audio.se_play("Audio/SE/Actor_fc_start/#{subject.current_action.item.id}",100)
                else
                   Audio.se_play("Music/CVS/#{subject.current_action.item.id}",100)
                end
             end
          end
          cfg[:skill_animation1].call  
        when 2..18
          #fc_picture.x += offset_x
          graphics_update.call
          @sk_actor.x += 3
          #@sk_actor.zoom_x -= 0.005
          #@sk_actor.zoom_y -= 0.005
          offset_x += 14
          @sk_actor.tone.set(255-offset_x, 255-offset_x, 255-offset_x, 0)
          fc_picture.opacity += 15 if fc_picture.opacity < 255
          @sk_actor_light.opacity += 25
        when 19
          #subject.actor? ? Audio.se_play("Audio/SE/saint6") : Audio.se_play("Audio/SE/saint7")

        when 20..40
          @sk_actor_light.opacity -= 15
         graphics_update.call
          # fc_picture.opacity += 5 if fc_picture.opacity < 255
       when 60..70

        when 71..91
 
          graphics_update.call
          fc_picture.opacity -= 13 if fc_picture.opacity > 0
        when 92
          cfg[:skill_animation2].call
          #fc_picture.opacity = 255
        when 93..113 # 消失 wave
               #@fc_wave.update
               if $game_switches[486] == true
        graphics_update.call
          @fc_wave.opacity -= 12 if @fc_wave.opacity > 0
              end
        when 114
          Fiber.yield()
        end
        count += 1
      end
      @fc_wave.bitmap.dispose
      @fc_msg.bitmap.dispose
      @sk_actor.bitmap.dispose
      @sk_actor_light.bitmap.dispose
      #fc_picture.bitmap.dispose
      @fc_sk.bitmap.dispose
      @is_animation = false
    end
    @fiber.resume(cfg,graphics_update)
    self.clear
  end


  def self.over_wave
    if @fc_wave
       @fc_wave.opacity = 0
       if @fc_wave.bitmap != nil
         @fc_wave.bitmap.dispose
      end
    end
    self.clear
  end

  # 阵型动画
  def self.create_formation(cfg,&graphics_update)
    @is_animation = true
    subject = cfg[:subject]
    item = subject.current_action.item
    self.init_formation(subject,graphics_update)
    @fiber = Fiber.new do |cfg,blk|
      cfg[:show_formation_obj_ani].call
      #p $data_skills[subject.current_action.item.id].wave_filename
      @fc_wave.bitmap = Cache.zdbg($data_skills[item.id].wave_filename) 
      if subject.actor?
        @fc_msg.bitmap = Cache.fc("#{item.id}")
        #@fc_actor.bitmap = Cache.fc("0000000")
        #fc_picture = @fc_actor
        @fc_sk.mirror = false
        @fc_sk.x = 500
        fc_sk_base_incr = 30
      else
        @fc_msg.bitmap = Cache.fc("#{item.id}")
        #@fc_enemy.bitmap = Cache.fc("0000000")
        #fc_picture = @fc_enemy
        @fc_sk.mirror = true
        @fc_sk.x =270
        fc_sk_base_incr = -30
      end
      while @fc_wave.opacity < 255
        #@fc_wave.update
        @fc_wave.opacity += 4
        graphics_update.call  if $game_switches[486] == true
      end
      count = 0
      loop do
      #@fc_wave.update
      graphics_update.call
      case count
        when 19
          Audio.se_play("Audio/SE/FC_SQ") 
        when 20..70
          @fc_msg.opacity += 7 if @fc_msg.opacity < 255
         # fc_picture.opacity += 5 if fc_picture.opacity < 255
        when 91
          #subject.actor? ? Audio.se_play("Audio/SE/saint6") : Audio.se_play("Audio/SE/saint7")
          @fc_sk.opacity = 255
          #self.update_formation_sk(Range.new(1,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call })
         # self.update_formation_sk(Range.new(3,7),fc_sk_base_incr,lambda{ graphics_update.call ; @fc_sk.opacity -= 12 })
         # self.update_formation_sk(Range.new(3,10),fc_sk_base_incr,lambda{ graphics_update.call ; @fc_sk.opacity -= 12 })
         # self.update_formation_sk(Range.new(4,11),fc_sk_base_incr,lambda{ graphics_update.call ; @fc_sk.opacity -= 12 })
        when 92..132 # 消失fc_msg
          @fc_msg.opacity -= 7 if @fc_msg.opacity > 0
          #fc_picture.opacity -= 5 if @fc_msg.opacity > 0
        when 133 # 技能动画
          # 八卦阵特殊动画
          if item.id == 13
            cfg[:show_formation_obj_animation2].call()
          end
          self.update_formation_pos(subject)
        when 134..184 # 消失 wave
          @fc_wave.opacity -= 5 if @fc_wave.opacity > 0 and $game_switches[486] == true
        when 185
          Fiber.yield()
        end
        count += 1
      end
      @fc_wave.bitmap.dispose
      @fc_msg.bitmap.dispose
     #fc_picture.bitmap.dispose
      @fc_sk.bitmap.dispose
      @is_animation = false
    end
    @fiber.resume(cfg,graphics_update)
    self.clear
  end

  def self.all_atk_animation(n,update_graphics,line_mode = true,cancle = false)
    [$game_party.battle_members[n],$game_troop.members[n]].each do |member|
      if member    #& & member.alive?
        member.animation cancle ? :cancel_all_atk : :all_atk
      end
    end
    # 24.times{ line_mode ? update_graphics.call : update_graphics}
  end

  def self.all_atk(cancel = false,&blk)
    if SceneManager.scene.is_a?(Scene_Battle)
      SceneManager.scene.spriteset.show_all_atk_text unless cancel
      for n in 0..4
        self.all_atk_animation(n,blk,true,cancel)
      end
      SceneManager.scene.spriteset.hide_all_atk_text if cancel 
    end
  end

  def self.cmd_menu_move(obj,tag,&graphics_update)
    obj.activate 
    case tag
    when :appear
      obj.init_back(6)
      #obj.back_x = (947+60)
      obj.back_opacity = 0
      dir = 4 ; t = "+"
    when :disappear 
      obj.init_back(4)
      obj.back_opacity = 255
      dir = 6 ; t = "-"
    end
    20.times { obj.change_back_x(3,dir) ; obj.change_back_opacity(15,t) ; graphics_update.call }
    if tag == :disappear
      obj.deactivate
      obj.back_opacity = 0
    end
  end

  def self.cmd_menu_move_toggle(obj1,obj2,&graphics_update)
    obj1.back_opacity = 255
    obj1.activate
    obj1.init_back(4)
    obj2.activate
    obj2.back_opacity = 0
    obj2.init_back(6)
    #obj2.back_x = (947+60)
    20.times { 
      obj1.change_back_x(3,6) ; obj1.change_back_opacity(13,"-") 
      obj2.change_back_x(3,4) ; obj2.change_back_opacity(13,"+") 
      graphics_update.call
    }
    obj1.deactivate
    obj1.back_opacity = 0
  end

  def self.menu_move_in(w1,w2,&graphics_update)
    w1.init_back(6)
    w1.back_opacity = 0
    w2.back_opacity = 255
    20.times { 
      w1.change_back_x(5,4) ; w1.change_back_opacity(13,"+") 
      w2.change_back_x(5,6) ; w2.change_back_opacity(13,"-") 
      graphics_update.call
    }
    w2.visible = false
  end

  def self.menu_move_out(w1,w2,&graphics_update)
    spriteset = SceneManager.scene.spriteset
    # fiber = Fiber.new do
      w1.init_back(4)
      w1.back_opacity = 255
      w2.back_opacity = 255-180
      20.times { 
        w1.change_back_x(5,6) ; w1.change_back_opacity(13,"-") 
        w2.change_back_x(5,4) ; w2.change_back_opacity(13,"+") 
        w1.update ; w2.update
        Graphics.update
        spriteset.update
      }
      w2.visible = true
      # Fiber.yield()
    # end
    # fiber.resume
  end

  def self.menu_move_out_self(w1,&graphics_update)
    spriteset = SceneManager.scene.spriteset
      w1.init_back(4)
      w1.back_opacity = 255
      20.times { 
        w1.change_back_x(5,6) ; w1.change_back_opacity(13,"-") 
        w1.update 
        Graphics.update
        spriteset.update
      }

  end

  def self.turn_end(&graphics_update)
    # fiber = Fiber.new do
      p1 = Sprite.create { |sp| sp.attrset :opacity=>0,:x=>492,:y=>215+30,:z=>1000,:bitmap=>Cache.zdbg("turn_end00") }
      p2 = Sprite.create { |sp| sp.attrset :opacity=>0,:x=>270+220,:y=>320+12+30,:z=>1001,:bitmap=>Cache.zdbg("turn_end01") }
      #p3 = Sprite.create { |sp| sp.attrset :opacity=>0,:x=>370+220,:y=>320+6,:z=>1001,:bitmap=>Cache.zdbg("turn_end02") }
      p4 = Sprite.create { |sp| sp.attrset :opacity=>0,:x=>270+220+92,:y=>320-22+30,:z=>1002,:bitmap=>Bitmap.new(85,70) }
      turn_size = $game_troop.turn_count+1
      turn_size = 99 if turn_size > 99
      if turn_size < 100
      ge = (turn_size.to_s[0,1]).to_i
      shi = (turn_size.to_s[1,1]).to_i
        if turn_size >= 10
           p4.bitmap.blt(0,0,Cache.zdbg("turn_size"),Rect.new(ge*54,0,54,100))
           p4.bitmap.blt(21,0,Cache.zdbg("turn_size"),Rect.new(shi*54,0,54,100)) 
        else
           p4.bitmap.blt(0,0,Cache.zdbg("turn_size"),Rect.new(0,0,54,100))
           p4.bitmap.blt(21,0,Cache.zdbg("turn_size"),Rect.new(ge*54,0,54,100)) 
        end
      end  
      80.times { |i| p2.x += 1 ; p4.x += 1 ; [p1,p2,p4].each{ |n|n.opacity += (i<50 ? 8 : -8) } ; graphics_update.call }
      p4.bitmap.clear
      [p1,p2,p4].each {|n| n.dispose ; n.bitmap.dispose }
      # Fiber.yield()
    # end
    # fiber.resume
  end

  def self.escape(succ=true,l1=nil,l2=nil,&graphics_update)
    # fiber = Fiber.new do
      m = [] ;
      m1 = lambda { 10.times { graphics_update.call } }
      $game_party.battle_members.each do |member|
        if member.alive?
          member.animation(:face_back)
          m << lambda { member.animation(:face_forward) }
          m1.call
        end
      end
      unless succ
        l1.call ; l2.call
        # $game_message.add('\.' + "被追击了")
        m.each { |n| [n,m1].each { |i| i.call } }
      end
      # Fiber.yield()
    # end
    # fiber.resume
  end
end



