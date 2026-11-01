#encoding:utf-8
#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　过关得分画面
#==============================================================================
class Scene_Score < Scene_Base
  include Module_Weather_EX 
  include RPG::EXT::FlashSprite
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
      super
      Graphics.transition(50)
=begin      
      $game_party.members[0].over_damage_all = 35000
      $game_party.members[0].over_sup_all = 11002
      $game_party.members[1].over_damage_all = 2000
      $game_party.members[1].over_sup_all = 800
      $game_party.members[2].over_damage_all = 1000
      $game_party.members[2].over_sup_all = 505
      $game_party.members[3].over_damage_all = 9999
      $game_party.members[3].over_sup_all = 400
      $game_party.members[4].over_damage_all = 2000
      $game_party.members[4].over_sup_all = 17
      $game_party.members[5].over_damage_all = 200
      $game_party.members[5].over_sup_all = 21205
      $game_party.members[6].over_damage_all = 10280
      $game_party.members[6].over_sup_all = 300
      $game_party.score_damage = 215720
      $game_party.score_sup = 125725
      $game_party.score_dead = 15
      $game_variables[137] = 20
=end

      score_bgm
      make_code
      create_back
      create_gua

      @k = true
  end
  #--------------------------------------------------------------------------
  # ● 创建光效
  #--------------------------------------------------------------------------
  def create_effect
      $game_temp.weather_fade = false
      $game_system.weather.clear
      $game_system.weather = [10, 1, "VS_score"]
      dispose_weather_ex    
      create_weather_ex
  end
  #--------------------------------------------------------------------------
  # ● Create Weather EX
  #--------------------------------------------------------------------------                   
  def create_weather_ex
      dispose_weather_ex
      create_weather_viewport
      create_weather_sprite     
  end                
  def dispose_weather_ex
      dispose_weather_ex_sprite
      dispose_weather_ex_viewport
  end
  #--------------------------------------------------------------------------
  # ● 计算数据
  #--------------------------------------------------------------------------
  def make_code
      @points = 0
      s = $game_party.members.size 
      h = $game_party.house_members.size
      a = 0
      for i in 0...s
        a += $game_party.members[i].level
      end  
      for i in 0...h
        a += $game_party.house_members[i].level
      end  
      @damage = $game_party.score_damage.to_i                   # 队伍伤害
      @damage = 9999999 if @damage > 9999999
      @sup =    $game_party.score_sup.to_i                      # 队伍辅助
      @sup = 9999999 if @sup > 9999999
      @lv =     ( (a*1.0) / (s+h) ).to_i                        # 队伍+仓库全平均等级
      @dead =   $game_party.score_dead.to_i                     # 队伍死亡次数
      @dead = 999 if @dead > 999
      num = 0
      for i in 304...481
          num += 1 if $game_party.has_item?($data_items[i])
      end 
      @zaoyi =  num.to_i  # 造诣完成数量
      @hid =  $game_variables[137].to_i                       # 寻找隐藏数量
      #计算最终得分
  end
  def points_text_01
      @points += @damage / 100.0
     # p @points
  end 

  def points_text_02     
      @points += @sup / 100.0
    #  p @points
  end

  def points_text_03
      @points *= 1+(@lv*@lv)/2500.0
      #msgbox @points
  end

  def points_text_04
      @points -= @dead * 50
      @points -= @dead * 100  if @dead > 20
      @points -= @dead * 150  if @dead > 40
      @points -= @dead * 200  if @dead > 60
      @points -= @dead * 250  if @dead > 80
      @points -= @dead * 300  if @dead > 100
      #msgbox @points
  end

  def points_text_05
      for i in 400...451  #蓝色造诣+分
          @points += 3000 if $game_party.has_item?($data_items[i])   
      end
      for i in 460...481  #金色造诣+分
          @points += 9000 if $game_party.has_item?($data_items[i])   
      end
      @points += @zaoyi * 1200
      #msgbox @points
  end

  def points_text_06
      @points += @hid * 250
      @points *= 1.5   if $game_variables[309] > 0
      @points *= 0.7   if $game_variables[309] < 0
      @points = @points.to_i
      #msgbox @points
      @points = 0 if @points < 0
      $game_variables[281] = @points
      show_text_end
  end
  #--------------------------------------------------------------------------
  # ● 创建背景
  #--------------------------------------------------------------------------
  def create_back
      @title = Sprite.new
      @title.bitmap = Cache.picture("score_title")
      @title.x = 0
      @title.z = 202
      @title.opacity = 255

      @guodu = Sprite.new
      @guodu.bitmap = Cache.picture("guodu4")
      @guodu.x = -1280
      @guodu.z = 299
      @guodu.opacity = 255

      @back = Sprite.new
      @back.bitmap = Cache.picture("score_back_"+"#{$game_variables[230]}")
      @back.x = 0 ; @back.y = 0 ; @back.z = 0 ; @back.opacity = 255
      @back_hong = Sprite.new
      @back_hong.bitmap = Cache.picture("score_back_hong")
      @back_hong.x = 640 ; @back_hong.y = 352  
      @back_hong.z = 1 ; 
      @back_hong.opacity = 255
      @back_hong.zoom_x = 1.20
      @back_hong.zoom_y = 1.20
      @back_hong.ox = 640
      @back_hong.oy = 352

      @light = Sprite.new
      @light.bitmap = Cache.picture("score_light")
      @light.x = 394 ; @light.y = 51
      @light.z = 256 ;
      @light.opacity = 0
      @light.blend_type = 1

      @gong = Sprite.new
      @gong.bitmap = Cache.picture("score_gong")
      @gong.x = 604 ; @gong.y = 79
      @gong.z = 210 ;
      @gong.opacity = 255

      @points_text = Sprite.new
      @points_text.bitmap = Bitmap.new(600,100)
      @points_text.x = 334 ; @points_text.y = 60
      @points_text.z = 255 ; 
      @points_text.opacity = 255

  end

  def show_text
      @points_text.bitmap.clear
      damage_array =  (@points.to_s).scan(/./)   # 分割伤害值字符串
      damage_x = 300 - (@points.to_s).size * 16
      for char in damage_array  # 循环伤害值字符串
          number = char.to_i
          @points_text.bitmap.blt(damage_x, 0, Cache.zdbg("score_size"), Rect.new(number * 54, 0, 54, 100))
          damage_x += 30 
      end
  end

  def show_text_end
      @points_text.bitmap.clear
      damage_array =  (@points.to_s).scan(/./)   # 分割伤害值字符串
      damage_x = 300 - (@points.to_s).size * 16
      for char in damage_array  # 循环伤害值字符串
          number = char.to_i
          @points_text.bitmap.blt(damage_x, 0, Cache.zdbg("score_size"), Rect.new(number * 54, 0, 54, 100))
          damage_x += 30 
      end
      @points_text.tone = Tone.new(255,255,255,255)
      @points_text.zoom_x = 1.25
      @points_text.zoom_y = 1.25
      @points_text.ox = 328
      @points_text.oy = 58
      @points_text.x = 660
      @points_text.y = 122
      
      @light.zoom_x = 1.0
      @light.ox = 240
      @light.oy = 51
      @light.x = 655
      @light.y = 102
      @light.opacity = 255
      @gong.tone = Tone.new(0,0,0,0)

      a=255
      while a > 0
            a = 0 if a < 0
            @points_text.tone.set(a,a,a,a)
            a-= 10
            @points_text.zoom_x -= 0.01
            @points_text.zoom_y -= 0.01
            @light.opacity -= 10
            @gong.opacity -= 10
            b= (a-255).abs
            @gong.tone.set(b,b,b,b)
            @light.zoom_x += 0.1
            wait(1)
      end
            @points_text.zoom_x = 1.0
            @points_text.zoom_y = 1.0
  end
  #--------------------------------------------------------------------------
  # ● 创建能力条+能力值
  #--------------------------------------------------------------------------
  def create_gua
      @max=297
      hgiht = 56
      op_x = 532
      op_y = 207
      @color = Color.new(55,55,55)
      @black_color = Color.new(0,0,0)
  @G_01 = Sprite.new ; @G_01.z = 205
      @G_01.bitmap = Bitmap.new(297,9)
      @G_01.x = op_x
      @G_01.y = op_y
      @G_01.bitmap.fill_rect(0, 0, @max, 9, @color)
   @G_02 = Sprite.new ; @G_02.z = 205
      @G_02.bitmap = Bitmap.new(297,9)
      @G_02.x = op_x
      @G_02.y = op_y+hgiht
      @G_02.bitmap.fill_rect(0, 0, @max, 9, @color)
   @G_03 = Sprite.new ; @G_03.z = 205 
      @G_03.bitmap = Bitmap.new(297,9)
      @G_03.x = op_x
      @G_03.y = op_y+hgiht*2
      @G_03.bitmap.fill_rect(0, 0, @max, 9, @color)
   @G_04 = Sprite.new ; @G_04.z = 205 
      @G_04.bitmap = Bitmap.new(297,9)
      @G_04.x = op_x
      @G_04.y = op_y+hgiht*3
      @G_04.bitmap.fill_rect(0, 0, @max, 9, @color)
  @G_05 = Sprite.new ; @G_05.z = 205 
      @G_05.bitmap = Bitmap.new(297,9)
      @G_05.x = op_x
      @G_05.y = op_y+hgiht*4
      @G_05.bitmap.fill_rect(0, 0, @max, 9, @color)
  @G_06 = Sprite.new ; @G_06.z = 205 
      @G_06.bitmap = Bitmap.new(297,9)
      @G_06.x = op_x
      @G_06.y = op_y+hgiht*5
      @G_06.bitmap.fill_rect(0, 0, @max, 9, @color)

      @shine = Sprite.new
      @shine.bitmap = Cache.picture("FF03")
      @shine.x = op_x-4
      @shine.y = op_y-2
      @shine.opacity = 0
      @shine.z = 210

      op_x += 218
      op_y -= 6
   @_t1 = Sprite.new ; @_t1.bitmap = Bitmap.new(72,25)
      @_t1.bitmap.font.name = "Noto" ; @_t1.bitmap.font.size = 18 + $game_variables[300] ; @_t1.bitmap.clear ; @_t1.z = 206
      @_t1.x = op_x
      @_t1.y = op_y-1
      @_t1.bitmap.draw_text(0,0,72,25," ",0)
   @_t2 = Sprite.new ; @_t2.bitmap = Bitmap.new(72,25)
      @_t2.bitmap.font.name = "Noto" ; @_t2.bitmap.font.size = 18 + $game_variables[300] ; @_t2.bitmap.clear ; @_t2.z = 206
      @_t2.x = op_x
      @_t2.y = op_y+hgiht*1-1
      @_t2.bitmap.draw_text(0,0,72,25," ",0)
   @_t3 = Sprite.new ; @_t3.bitmap = Bitmap.new(72,25)
      @_t3.bitmap.font.name = "Noto" ; @_t3.bitmap.font.size = 18 + $game_variables[300] ; @_t3.bitmap.clear ; @_t3.z = 206
      @_t3.x = op_x
      @_t3.y = op_y+hgiht*2-1
      @_t3.bitmap.draw_text(0,0,72,25," ",0)
   @_t4 = Sprite.new ; @_t4.bitmap = Bitmap.new(72,25)
      @_t4.bitmap.font.name = "Noto" ; @_t4.bitmap.font.size = 18 + $game_variables[300] ; @_t4.bitmap.clear ; @_t4.z = 206
      @_t4.x = op_x
      @_t4.y = op_y+hgiht*3-1
      @_t4.bitmap.draw_text(0,0,72,25," ",0)
   @_t5 = Sprite.new ; @_t5.bitmap = Bitmap.new(72,25)
      @_t5.bitmap.font.name = "Noto" ; @_t5.bitmap.font.size = 18 + $game_variables[300] ; @_t5.bitmap.clear ; @_t5.z = 206
      @_t5.x = op_x
      @_t5.y = op_y+hgiht*4-1
      @_t5.bitmap.draw_text(0,0,72,25," ",0)
   @_t6 = Sprite.new ; @_t6.bitmap = Bitmap.new(72,25)
      @_t6.bitmap.font.name = "Noto" ; @_t6.bitmap.font.size = 18 + $game_variables[300] ; @_t6.bitmap.clear ; @_t6.z = 206
      @_t6.x = op_x
      @_t6.y = op_y+hgiht*5-1
      @_t6.bitmap.draw_text(0,0,72,25," ",0)
  end
  #--------------------------------------------------------------------------
  # ● 创建角色头像
  #--------------------------------------------------------------------------
  def create_face
      for i in 0...20
         @back_hong.zoom_x -= 0.01
         @back_hong.zoom_y -= 0.01
         wait(1)
      end
      for i in 0...60
            if @guodu.x < 1680
               @guodu.x += 40
               wait(1)
            end
      end
      members = []
     # members.concat($game_party.members)
      #members.concat($game_party.house_members)
      members += $game_party.members
      members += $game_party.house_members
      members.sort!{ |a,b| (a.over_damage_all+a.over_sup_all)  <=>  (b.over_damage_all+b.over_sup_all) }
      members = members.reverse
      normal_color = Color.new(255,255,255)
      red_color = Color.new(255,75,65)
      _x = 59
      @name = Sprite.new ; @name.bitmap = Bitmap.new(460,100) ; @name.z = 260; @name.opacity = 250
      @name.bitmap.font.name = "Noto" 
      @name.x = 416
      @name.y = 581
      @s123 = Sprite.new ; @s123.bitmap = Cache.system("s123") ; @s123.z = 261; @s123.opacity = 0
      @s123.tone = Tone.new(255,255,255,255)
      @s123.x = 420
      @s123.y = 528

      if members.size >= 1
         actor = members[0]
         @face_1 = Sprite.new ; @face_1.bitmap = Cache.sface(actor.face_name) ; @face_1.z = 255
         @face_1.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58) ; @face_1.opacity = 0
         @face_1.x = 436+16
         @face_1.y = 535
         se_face
         for i in 0...16
         @face_1.x -= 1
         @face_1.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
            @name.bitmap.draw_text(0,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else
            @name.bitmap.draw_text(0,20,100,25,"#{actor.over_damage_all+actor.over_sup_all}",1)
         end
      end  
      if members.size >= 2
         actor = members[1]
         @face_2 = Sprite.new ; @face_2.bitmap = Cache.sface(actor.face_name) ; @face_2.z = 255
         @face_2.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58); @face_2.opacity = 0
         @face_2.x = 436+_x+16
         @face_2.y = 535
         se_face
         for i in 0...16
         @face_2.x -= 1
         @face_2.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26+_x,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
         @name.bitmap.draw_text(0+_x,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else
         @name.bitmap.draw_text(0+_x,20,100,25,"#{actor.over_damage_all+actor.over_sup_all}",1)
         end
      end
      if members.size >= 3
         actor = members[2]
         @face_3 = Sprite.new ; @face_3.bitmap = Cache.sface(actor.face_name) ; @face_3.z = 255
         @face_3.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58); @face_3.opacity = 0
         @face_3.x = 436+_x*2+16
         @face_3.y = 535
         se_face
         for i in 0...16
         @s123.opacity += 16
         @s123.tone.set((15-i)*i,(15-i)*i,(15-i)*i,255)
         @face_3.x -= 1
         @face_3.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26+_x*2,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
         @name.bitmap.draw_text(0+_x*2,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else
         @name.bitmap.draw_text(0+_x*2,20,100,25,"#{actor.over_damage_all+actor.over_sup_all}",1)
         end
      end
      if members.size >= 4
         actor = members[3]
         @face_4 = Sprite.new ; @face_4.bitmap = Cache.sface(actor.face_name) ; @face_4.z = 255
         @face_4.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58); @face_4.opacity = 0
         @face_4.x = 436+_x*3+16
         @face_4.y = 535
         se_face
         for i in 0...16
         @face_4.x -= 1
         @face_4.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26+_x*3,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
         @name.bitmap.draw_text(_x*3,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else
         @name.bitmap.draw_text(_x*3,20,100,25,"#{actor.over_damage_all+actor.over_sup_all}",1)
         end
      end
      if members.size >= 5
         actor = members[4]
         @face_5 = Sprite.new ; @face_5.bitmap = Cache.sface(actor.face_name) ; @face_5.z = 255
         @face_5.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58); @face_5.opacity = 0
         @face_5.x = 436+_x*4+16
         @face_5.y = 535
         se_face
         for i in 0...16
         @face_5.x -= 1
         @face_5.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26+_x*4,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
         @name.bitmap.draw_text(_x*4,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else 
         @name.bitmap.draw_text(_x*4,20,100,25,"#{(actor.over_damage_all+actor.over_sup_all)}",1)
         end
      end
      if members.size >= 6
         actor = members[5]
         @face_6 = Sprite.new ; @face_6.bitmap = Cache.sface(actor.face_name) ; @face_6.z = 255
         @face_6.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58); @face_6.opacity = 0
         @face_6.x = 436+_x*5+16
         @face_6.y = 535
         se_face
         for i in 0...16
         @face_6.x -= 1
         @face_6.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26+_x*5,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
         @name.bitmap.draw_text(_x*5,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else
         @name.bitmap.draw_text(_x*5,20,100,25,"#{actor.over_damage_all+actor.over_sup_all}",1)
         end
      end
      if members.size >= 7
         actor = members[6]
         @face_7 = Sprite.new ; @face_7.bitmap = Cache.sface(actor.face_name) ; @face_7.z = 255
         @face_7.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58); @face_7.opacity = 0
         @face_7.x = 436+_x*6+16
         @face_7.y = 535
         se_face
         for i in 0...16
         @face_7.x -= 1
         @face_7.opacity += 16
         wait(1)
         end
         @name.bitmap.color = normal_color ; @name.bitmap.font.size = 17 + $game_variables[300] 
         @name.bitmap.draw_text(26+_x*6,0,50,25,"#{actor.name}",1)
         @name.bitmap.font.size = 18 + $game_variables[300] ; @name.bitmap.color = red_color
         if actor.over_damage_all+actor.over_sup_all > 100000
         @name.bitmap.draw_text(_x*6,20,100,25,"#{((actor.over_damage_all+actor.over_sup_all)*0.0001).to_i}"+"W",1)
         else 
         @name.bitmap.draw_text(_x*6,20,100,25,"#{actor.over_damage_all+actor.over_sup_all}",1)
         end
      end

  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
      duration.times {|i| update_for_wait }
      update_weather_ex
      update_flash_background
  end

  def update_for_wait
      update_basic
  end

  def update_basic
      Graphics.update
      Input.update
      update_all_windows
  end
  #--------------------------------------------------------------------------  
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
      super
      update_weather_ex
      update_gua
      update_flash_background
  end
  #--------------------------------------------------------------------------  
  # ● 播放SE
  #--------------------------------------------------------------------------
  def score_bgm
      $game_system.save_bgm
      Audio.bgm_play("Audio/BGM/score",90)
  end
  def se_open
      Audio.se_play("Audio/SE/156-Support14",95,60)
  end  
  def se_1_6
      Audio.se_play("Audio/SE/J_qian",90,80) 
  end
  def se_last
      create_effect
      Audio.se_play("Audio/SE/Evolution",95,90)
      Audio.se_play("Audio/SE/FC_SQ",100)
      Audio.se_play("Audio/SE/060-Cheer01",100)
      create_flash_background Cache.flash("score_flash_"+"#{$game_variables[230]}")
  end  
  def se_face
      Audio.se_play("Audio/SE/Wind1",90,130)
  end  
  def se_esc
      Audio.se_play("Audio/SE/0short01b",100)
  end  
  #--------------------------------------------------------------------------  
  # ● 按下确认键退出
  #--------------------------------------------------------------------------
  def out_esc
      if @k == false
        if Input.trigger?(:B) or Input.trigger?(:C)
           se_esc
           weather_stop
           fadeout_all(1000)
           SceneManager.call(Scene_Map)
           perform_transition
           $game_system.replay_bgm
        end
      end
  end

  def weather_stop
      $game_temp.weather_fade = false
      $game_system.weather.clear
      $game_system.weather = [-1,0,""]
      $game_system.weather_restore  = [-1,0,""]
      $game_system.weather_temp = [-1,0,""]      
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def  update_gua
       out_esc
       hgiht = 56
       if @k == true
          create_face
          a = 0 ; b = 1
          #总伤害##############################
          se_open
          wh = (@damage / 10000000.0 * @max ).to_i
          wh = @max if wh > @max
          while a < wh
                a += 1
                @shine.x = 528+a
                @shine.opacity = 255
                @G_01.bitmap.clear
                @G_01.bitmap.fill_rect(a, 0, @max-a, 9, @color)
                b += @damage*1.0/wh
                @_t1.bitmap.clear 
                @_t1.bitmap.draw_text(0,0,72,25,"#{b.to_i}",2) 
                wait(1)
          end
          @shine.opacity = 0
          se_1_6
          @_t1.bitmap.clear 
          @_t1.bitmap.draw_text(0,0,72,25,"#{@damage}",2) 
          @G_01.bitmap.fill_rect(a, 0, 1, 9, @black_color)
          points_text_01 
          #总辅助##############################
          se_open
          a = 0 ; b = 1
          wh = (@sup / 10000000.0 * @max ).to_i
          wh = @max if wh > @max
          @shine.y += hgiht
          while a < wh
                a += 1
                @shine.x = 528+a
                @shine.opacity = 255
                @G_02.bitmap.clear
                @G_02.bitmap.fill_rect(a, 0, @max-a, 9, @color)
                b += @sup*1.0/wh
                @_t2.bitmap.clear 
                @_t2.bitmap.draw_text(0,0,72,25,"#{b.to_i}",2) 
                wait(1)
          end
          @shine.opacity = 0
          se_1_6
          @_t2.bitmap.clear 
          @_t2.bitmap.draw_text(0,0,72,25,"#{@sup}",2) 
          @G_02.bitmap.fill_rect(a, 0, 1, 9, @black_color) 
          points_text_02
          #均等级##############################
          se_open
          a = 0 ; b = 1
          wh = (@lv / 50.0 * @max ).to_i
          wh = @max if wh > @max
          @shine.y += hgiht
          while a < wh
                a += 1
                @shine.x = 528+a
                @shine.opacity = 255
                @G_03.bitmap.clear
                @G_03.bitmap.fill_rect(a, 0, @max-a, 9, @color)
                b += @lv*1.0/wh
                @_t3.bitmap.clear 
                @_t3.bitmap.draw_text(0,0,72,25,"#{b.to_i}",2) 
                wait(1)
          end
          @shine.opacity = 0
          se_1_6
          @_t3.bitmap.clear 
          @_t3.bitmap.draw_text(0,0,72,25,"#{@lv}",2) 
          @G_03.bitmap.fill_rect(a, 0, 1, 9, @black_color) 
          points_text_03
          #死亡数##############################
          se_open
          a = 0 ; b = 1
          wh = (@dead / 100.0 * @max ).to_i
          wh = @max if wh > @max
          @shine.y += hgiht
          while a < wh
                a += 1
                @shine.x = 528+a
                @shine.opacity = 255
                @G_04.bitmap.clear
                @G_04.bitmap.fill_rect(a, 0, @max-a, 9, @color)
                b += @dead*1.0/wh
                @_t4.bitmap.clear 
                @_t4.bitmap.draw_text(0,0,72,25,"#{b.to_i}",2) 
                wait(1)
          end
          @shine.opacity = 0
          se_1_6
          @_t4.bitmap.clear 
          @_t4.bitmap.draw_text(0,0,72,25,"#{@dead}",2) 
          @G_04.bitmap.fill_rect(a, 0, 1, 9, @black_color) 
          points_text_04
          #造诣数##############################
          se_open
          a = 0 ; b = 1
          wh = (@zaoyi / 75.0 * @max ).to_i
          wh = @max if wh > @max
          @shine.y += hgiht
          while a < wh
                a += 1
                @shine.x = 528+a
                @shine.opacity = 255
                @G_05.bitmap.clear
                @G_05.bitmap.fill_rect(a, 0, @max-a, 9, @color)
                b += @zaoyi*1.0/wh
                @_t5.bitmap.clear 
                @_t5.bitmap.draw_text(0,0,72,25,"#{b.to_i}",2) 
                wait(1)
          end
          @shine.opacity = 0
          se_1_6
          @_t5.bitmap.clear 
          @_t5.bitmap.draw_text(0,0,72,25,"#{@zaoyi}",2) 
          @G_05.bitmap.fill_rect(a, 0, 1, 9, @black_color) 
          points_text_05
          #隐藏数##############################
          se_open
          a = 0 ; b = 1
          wh = (@hid / 255.0 * @max ).to_i
          wh = @max if wh > @max
          @shine.y += hgiht
          while a < wh
                a += 1
                @shine.x = 528+a
                @shine.opacity = 255
                @G_06.bitmap.clear
                @G_06.bitmap.fill_rect(a, 0, @max-a, 9, @color)
                b += @hid*1.0/wh
                @_t6.bitmap.clear 
                @_t6.bitmap.draw_text(0,0,72,25,"#{b.to_i}",2) 
                wait(1)
          end
          @shine.opacity = 0
          se_last
          @_t6.bitmap.clear 
          @_t6.bitmap.draw_text(0,0,72,25,"#{@hid}",2) 
          @G_06.bitmap.fill_rect(a, 0, 1, 9, @black_color) 
          points_text_06
       end
       @k = false
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   dispose_sp
  #   dispose_flash_background
  #   $game_system.weather.clear
  #   dispose_weather_ex
  # end

  def after_dispose
    $game_system.weather.clear
  end

  #--------------------------------------------------------------------------
  # ● 删除精灵
  #--------------------------------------------------------------------------
  def dispose_sp
    if @G_01 ; @G_01.bitmap.dispose ; @G_01.dispose ; end
    if @G_02 ; @G_01.bitmap.dispose ; @G_01.dispose ; end
    if @G_03 ; @G_01.bitmap.dispose ; @G_01.dispose ; end
    if @G_04 ; @G_01.bitmap.dispose ; @G_01.dispose ; end
    if @G_05 ; @G_01.bitmap.dispose ; @G_01.dispose ; end
    if @G_06 ; @G_01.bitmap.dispose ; @G_01.dispose ; end
    if @_t1 ; @_t1.bitmap.dispose ; @_t1.dispose ; end
    if @_t2 ; @_t2.bitmap.dispose ; @_t2.dispose ; end
    if @_t3 ; @_t3.bitmap.dispose ; @_t3.dispose ; end
    if @_t4 ; @_t4.bitmap.dispose ; @_t4.dispose ; end
    if @_t5 ; @_t5.bitmap.dispose ; @_t5.dispose ; end
    if @_t6 ; @_t6.bitmap.dispose ; @_t6.dispose ; end
    if @face_1 ; @face_1.bitmap.dispose ; @face_1.dispose ; end
    if @face_2 ; @face_2.bitmap.dispose ; @face_2.dispose ; end
    if @face_3 ; @face_3.bitmap.dispose ; @face_3.dispose ; end
    if @face_4 ; @face_4.bitmap.dispose ; @face_4.dispose ; end
    if @face_5 ; @face_5.bitmap.dispose ; @face_5.dispose ; end
    if @face_6 ; @face_6.bitmap.dispose ; @face_6.dispose ; end
    if @face_7 ; @face_7.bitmap.dispose ; @face_7.dispose ; end
    if @shine ; @shine.bitmap.dispose ; @shine.dispose ; end
    if @light ; @light.bitmap.dispose ; @light.dispose ; end
    if @gong ; @gong.bitmap.dispose ; @gong.dispose ; end
    if @back_hong ; @back_hong.bitmap.dispose ; @back_hong.dispose ; end
    if @points_text ; @points_text.bitmap.dispose ; @points_text.dispose ; end
    if @name ; @name.bitmap.dispose ; @name.dispose ; end
    if @s123 ; @s123.bitmap.dispose ; @s123.dispose ; end
    if @title ; @title.bitmap.dispose ; @title.dispose ; end
  end  


end

