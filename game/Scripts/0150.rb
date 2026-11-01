#encoding:utf-8
#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　标题画面
#==============================================================================



class Scene_Title < Scene_Base
  include Module_Weather_EX 
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start

    super
    #$op_2nd = true
    @tiaoguo = 0 if @tiaoguo == nil 
    @tiaoguo = 1 if $TEST or $back_title
    $hei = 0                    # 默认关闭屏幕全黑
    @m = true
    @z = 0
    @left = 0
    @a = 0
    @size = 1
    @km_size = 0
    Audio.bgm_play("Audio/bgm/title-sdm_new",90)
    @n = 1
    if @tiaoguo != nil and @tiaoguo == 1
      @c = 500
      @ok = 3
    else
      @c = 1
      @ok = 0
    end

    @tanks = 0
    SceneManager.clear
    Graphics.freeze
    create_background
    #create_foreground
    create_cursor
    create_multiple_layers
    # create_command_window
    #play_title_music
    @cursor_index = 0
  end

  def create_multiple_layers
    $game_temp.weather_fade = false
    $game_system.weather.clear
    $game_system.weather = [9, 1, "VS_jiangwei"]
    dispose_weather_ex    
    create_weather_ex
  end

  #--------------------------------------------------------------------------
  # ● 获取渐变速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 20
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   dispose_background
  #   didpose_cursor
  # end

  #--------------------------------------------------------------------------
  # ● 释放对象之后
  #--------------------------------------------------------------------------
  def after_dispose
    # SceneManager.snapshot_for_background
    $game_temp.weather_fade = false
    $game_system.weather.clear
    $game_system.weather = [-1,0,""]
    $game_system.weather_restore  = [-1,0,""]
    $game_system.weather_temp = [-1,0,""]  
    dispose_weather_ex
  end


  def create_cursor
    @s = Sprite.new
    @s.bitmap = Cache.system("Title_s")
    @s.x = 0
    @s.y = 336+60
    @s.z = 103
    @s.blend_type = 0
  end

  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background

    @logo_1 = Sprite.new
    @logo_1.bitmap = Cache.picture("LOGO_01")
    @logo_1.opacity = 0
    @logo_1.z = 998

    @logo_2 = Sprite.new
    @logo_2.bitmap = Cache.picture($platform_logo_name)
    @logo_2.opacity = 0
    @logo_2.z = 999


    @sprite_00 = Sprite.new
    @sprite_00.bitmap = Cache.picture("00")
    @sprite_00.z = 200


    @sprite_waite = Sprite.new
    @sprite_waite.bitmap = Cache.picture("000")
    @sprite_waite.z = 201
    @sprite_waite.opacity = 1

    @sprite_jian = Sprite.new
    @sprite_jian.bitmap = Cache.system("Title_jian")
    @sprite_jian.y = 328-10
    @sprite_jian.x = 1280
    @sprite_jian.z = 201
    @sprite_jian.opacity = 0

    @mu = Sprite.new
    @mu.bitmap = Bitmap.new(92,92)
    @mu.bitmap.blt(0,0,Cache.system("hz1"),Rect.new(0,0,92,92))
    @mu.x = 290
    @mu.y = 704
    @mu.z = 45
   # @mu.zoom_x = 0.95

    @ll = Sprite.new
    @ll.bitmap = Cache.system("LL")
    @ll.blend_type = 1
    @ll.x = 300-30
    @ll.y = 704
    @ll.z = 46

    @mu2 = Sprite.new
    @mu2.bitmap = Bitmap.new(92,92)
    @mu2.bitmap.blt(0,0,Cache.system("hz1"),Rect.new(0,0,92,92))
    @mu2.x = 850+20+20
    @mu2.y = 760
    @mu2.z = 45
    @mu2.zoom_x = 0.8
    @mu2.zoom_y = 0.85

    @ll2 = Sprite.new
    @ll2.bitmap = Cache.system("LL2")
    @ll2.blend_type = 1
    @ll2.x = 850+20
    @ll2.y = 760
    @ll2.z = 46

    @mu3 = Sprite.new
    @mu3.bitmap = Bitmap.new(92,92)
    @mu3.bitmap.blt(0,0,Cache.system("hz1"),Rect.new(0,0,92,92))
    @mu3.zoom_x = 0.55
    @mu3.zoom_y = 0.6
    @mu3.x = 865
    @mu3.y = 704
    @mu3.z = 48

    @ll3 = Sprite.new
    @ll3.bitmap = Cache.system("LL3")
    @ll3.blend_type = 1
    @ll3.x = 865
    @ll3.y = 704
    @ll3.z = 49

    @sprite_deng = Sprite.new
    @sprite_deng.bitmap = Cache.system("Title_deng")
    #@pp = Bitmap.new("Graphics/System/Title_deng")
   #@sprite_deng.bitmap.blt(0,704,@pp,Rect.new(0,704,640,704))
    @sprite_deng.opacity = 0
   # @sprite_deng.blend_type = 1
    @sprite_deng.z = 40
    @sprite_deng.x = 222+4
    @sprite_deng.y = 0
    #@sprite_deng.zoom_x = 2.1
    #@sprite_deng.zoom_y = 2.1
    #@sprite_deng.tone = Tone.new(255,255,255,255) 

    @sprite_faguang = Sprite.new
    @sprite_faguang.bitmap = Cache.system("faguang2")
    @sprite_faguang.ox = 230
    @sprite_faguang.oy = 230
    @sprite_faguang.opacity = 0
    @sprite_faguang.blend_type = 1
    @sprite_faguang.x = 640
    @sprite_faguang.y = 352+3
    @sprite_faguang.z = 39+4
    @sprite_faguang.z = 103

    @sprite_logo = Sprite.new
    @sprite_logo.bitmap = Cache.system("Title_logo")
    @sprite_logo.bitmap = Cache.system("Title_logo_2nd") if $op_2nd == true
    @sprite_logo.z = 104
    @sprite_logo.x = 310
    @sprite_logo.y = 170

    @km = Sprite.new
    @km.bitmap = Cache.body("kk_1")
    @km.z = 102;@km.x=370 ;@km.y =35 

    @sprite1 = Sprite.new
    @sprite1.bitmap = Cache.system("Title_back")
    @sprite1.bitmap = Cache.system("Title_back_2nd") if $op_2nd == true 
    #@sprite1.zoom_x = 1.00
    #@sprite1.zoom_y = 1.00
    @sprite1.y = -703

  end
  #--------------------------------------------------------------------------
  # ● 生成前景
  #--------------------------------------------------------------------------
  def create_foreground
    @foreground_sprite = Sprite.new
    @foreground_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @foreground_sprite.z = 100
    draw_game_title if $data_system.opt_draw_title
  end
  #--------------------------------------------------------------------------
  # ● 绘制游戏标题
  #--------------------------------------------------------------------------
  def draw_game_title
    @foreground_sprite.bitmap.font.size = 48
    rect = Rect.new(0, 0, Graphics.width, Graphics.height / 2)
    @foreground_sprite.bitmap.draw_text(rect, $data_system.game_title, 1)
  end
  #--------------------------------------------------------------------------
  # ● 释放背景
  #--------------------------------------------------------------------------
  def dispose_background

    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite_00.bitmap.dispose
    @sprite_00.dispose
    @sprite_waite.bitmap.dispose
    @sprite_waite.dispose
    @sprite_deng.bitmap.dispose
    @sprite_deng.dispose
    @sprite_logo.bitmap.dispose
    @sprite_logo.dispose
    @logo_1.bitmap.dispose
    @logo_1.dispose
    @logo_2.bitmap.dispose
    @logo_2.dispose
    @sprite_faguang.bitmap.dispose
    @sprite_faguang.dispose
    @mu.bitmap.dispose
    @mu.dispose
    @mu2.bitmap.dispose
    @mu2.dispose
    @mu3.bitmap.dispose
    @mu3.dispose
    @ll.bitmap.dispose
    @ll.dispose
    @ll2.bitmap.dispose
    @ll2.dispose
    @ll3.bitmap.dispose
    @ll3.dispose
    @km.bitmap.dispose
    @km.dispose 
    @sprite_jian.bitmap.dispose
    @sprite_jian.dispose 

  end

  def didpose_cursor
    if @s
      @s.bitmap.dispose
      @s.dispose
    end
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
  # ● 释放前景
  #--------------------------------------------------------------------------
  def dispose_foreground
    @foreground_sprite.bitmap.dispose
    @foreground_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 执行精灵居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_TitleCommand.new
    @command_window.set_handler(:new_game, method(:command_new_game))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:thanks, method(:command_thanks))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
  end
  #--------------------------------------------------------------------------
  # ● 关闭指令窗口
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  #--------------------------------------------------------------------------
  # ● 指令“开始游戏”
  #--------------------------------------------------------------------------
  def command_new_game
     Audio.se_play("Audio/SE/0short01b",100)
    DataManager.setup_new_game
    BattleManager.setEventBattle
     $game_variables[251] = []
     $game_variables[251][30] = 4.11   #版本号代码
     $game_switches[S::CV] = true # 默认打开武将语音
     $game_variables[41] = 1      # 默认打开41号变量 水效果
     $game_switches[437] = true   # 默认打开环境和天气效果
     $game_switches[486] = true   # 默认打开战斗特效
     $game_switches[487] = true   # 默认打开地名显示
     $game_switches[489] = true   # 默认关闭自动存档
     $game_switches[491] = true   # 默认播放动画提醒
     $game_switches[742] = false  # 默认关闭手柄模式
     $game_switches[693] = true   # 战斗结束统计数据开启
     $hei = 0                     # 默认关闭屏幕全黑
     $game_variables[250] = []    # 特殊角色保护密码
     for i in 1...220
         $game_variables[250].push(i)
         $game_variables[250][i] = [0,0,0,0,0,0,0,0] 
     end 
     if $game_switches[700] == false
        $game_variables[240] = []    # 拥有角色数组开启
        $game_variables[279] = []          
        $game_variables[278] = []   
        $game_variables[274] = []   
        $game_variables[272] = []  
        $game_variables[273] = []   
        $game_variables[261] = [] if $game_variables[261] == 0      
        for i in 1...999
            $game_variables[274].push(i)
            $game_variables[274][i] = 0
        end 
        for i in 1...999
            $game_variables[273].push(i)
            $game_variables[273][i] = 0
        end 
        for i in 1...999
            $game_variables[272].push(i)
            $game_variables[272][i] = 0
        end 
     end 
    # close_command_window
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
    num_lock unless $TEST
  end

  def num_lock
    #--------------------------------------------------------------------------
    @getKeyState = Win32API.new("user32","GetAsyncKeyState",['I'],'I')
    @getKeyboardState = Win32API.new("user32","GetKeyState",['I'],'I')
    @getSetKeyState = Win32API.new("user32","SetKeyboardState",['I'],'I')
    @full = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
    #--------------------------------------------------------------------------
    @full.call 0x90, 0, 0, 0
    Graphics.wait(10)
    @full.call 0x90, 0, 2, 0
    Graphics.wait(10)
    @full.call 0x90, 0, 0, 0
    Graphics.wait(10)
    @full.call 0x90, 0, 2, 0
    Graphics.wait(10)
  end
  #--------------------------------------------------------------------------
  # ● 指令“继续游戏”
  #--------------------------------------------------------------------------
  def command_continue
    if $op_2nd == true
      Audio.se_play("Audio/SE/Buzzer1",90) 
    else
      @tiaoguo = 1
      Audio.se_play("Audio/SE/Cursor2",100)
      BattleManager.setEventBattle
      SceneManager.call(Scene_Load)
    end
  end

  #--------------------------------------------------------------------------
  # ● 【废】指令“感谢”
  #--------------------------------------------------------------------------
  def command_thanks
    @tiaoguo = 1
    Audio.se_play("Audio/SE/Cursor2",100)
    SceneManager.call(Scene_System)
    #@sprite_name.opacity = 255
    @tanks = 1
  end

  #--------------------------------------------------------------------------
  # ● 指令“退出游戏”
  #--------------------------------------------------------------------------
  def command_shutdown
    Audio.se_play("Audio/SE/Cursor2",100)
    num_lock unless $TEST
    fadeout_all
    SceneManager.exit
  end
  #--------------------------------------------------------------------------
  # ● 播放标题画面音乐
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_weather_ex

    @c += 1

    if @c > 500
       @n += 1 
    end

    if @ok == 1
      @ok = 2
    end

    if @km and @n % 3 == 0
      @km.bitmap = Cache.body("kk_"+"#{@km_size}")
      @km_size += 1
      @km_size = 1 if @km_size > 41 
    end   

    if @mu != nil 
      @mu.y -= 1
      @mu.y = 704 if @mu.y < -120

      if @z > 0
        if @mu.angle >= 35
          @mu.angle += 0.3
        elsif @mu.angle >= 20
          @mu.angle += 0.7
        else
          @mu.angle += 1
        end
        @z = 0  if @mu.angle >= 40
      else
        @mu.y -= 1  
        if @mu.angle <= -35
          @mu.angle -= 0.3
        elsif @mu.angle <= -20
          @mu.angle -= 0.5
        else
          @mu.angle -= 0.7
        end
        @z = 1 if @mu.angle <= -45
      end
      @ll.angle = @mu.angle
      @ll.y = @mu.y-20
    end

    if @mu2 != nil and @n > 50
      @mu2.y -= 1
      @mu2.y = 760 if @mu2.y < -120
      
      if @z > 0
         @mu2.y -= 1
        if @mu2.angle <= -35
           @mu2.angle -= 0.3
        elsif @mu2.angle <= -20
           @mu2.angle -= 0.7
        else
           @mu2.angle -= 1
        end
        @z = 0  if @mu2.angle <= -40
      else
          
        if @mu2.angle >= 35
           @mu2.angle += 0.3
        elsif @mu2.angle >= 20
           @mu2.angle += 0.5
        else
           @mu2.angle += 0.7
        end
        @z = 1  if @mu2.angle >= 45
      end

      @ll2.angle = @mu2.angle
      @ll2.y = @mu2.y
    end

    if @mu3 != nil and @n > 350
      @mu3.y -= 1
      @mu3.y = 704 if @mu3.y < -120
      if @z > 0
        if @mu3.angle >= 35
          @mu3.angle += 0.3
        elsif @mu3.angle >= 20
          @mu3.angle += 0.7
        else
          @mu3.angle += 1
        end
        @z = 0 if @mu3.angle >= 40
      else
        @mu3.y -= 1  
        if @mu3.angle <= -35
          @mu3.angle -= 0.3
        elsif @mu3.angle <= -20
          @mu3.angle -= 0.5
        else
          @mu3.angle -= 0.7
        end
        @z = 1 if @mu3.angle <= -45
      end
      @ll3.angle = @mu3.angle
      @ll3.y = @mu3.y
    end

    if @sprite_deng.opacity >= 255
      if @m == true
        @sprite_faguang.opacity += 1
        @m = false if @sprite_faguang.opacity >= 255
      else
        @sprite_faguang.opacity -= 1
        @m = true if @sprite_faguang.opacity <= 0
      end
    end

    if @tiaoguo != 1
      case @c
      when 1..125
        @logo_1.opacity += 10
      when 145..240
        @logo_1.opacity -= 10
      when 241..360
        @logo_2.opacity += 10
      when 390..518
        @logo_2.opacity -= 10
      when 519
        @ok = 1
        @tiaoguo = 1
      end
    end

    case @n
    when 2
      Audio.se_play("Audio/SE/title",100,100)
    when 5
      #Audio.se_play("Audio/SE/Sword4",100)
    when 7...27
      @sprite_jian.x -= 110
      @sprite_jian.opacity += 20
      @sprite_waite.opacity += 30 
    when 28...55
      @sprite_00.opacity -= 30
    when 56...220
      @sprite_waite.opacity -= 3
    end

    case @n
    when 44...71
      @sprite_deng.opacity += 9
      #@a = 355-@sprite_deng.opacity
      #@sprite_deng.tone.set(@a,@a,@a,@a) 
      #@sprite_deng.zoom_x -= 0.04  if @sprite_deng.zoom_x > 1
     # @sprite_deng.zoom_y -= 0.04  if @sprite_deng.zoom_y > 1
    when 71
      #@sprite_deng.zoom_x = 1.0 if @sprite_deng.zoom_x != 1.0
      # @sprite_deng.zoom_y = 1.0 if @sprite_deng.zoom_y != 1.0
      @sprite_deng.opacity = 255
    end

    case @n
    when 81
      # @sprite_deng.blend_type = 0
      @a = 255
    when 82...130
      # @a += 10
      # @sprite_deng.tone.set(@a,@a,@a,@a)  
      #when 121...160
      @a -= 8
      @a = 0 if @a < 0
      #@sprite_deng.tone.set(@a,@a,@a,@a) 
    end

    if @n%2 == 0 and @sprite1.y <= -1
      @sprite1.y += 1
    end

    if @n%2 == 0 and @mu != nil
      @sprite_faguang.angle += 1
      @size += 1
      @mu.bitmap.clear
      @mu.bitmap.blt(0,0,Cache.system("hz1"),Rect.new((@size-1)*92,0,92,92))
      @mu2.bitmap.clear
      @mu2.bitmap.blt(0,0,Cache.system("hz1"),Rect.new((@size-1)*92,0,92,92))
      @mu3.bitmap.clear
      @mu3.bitmap.blt(0,0,Cache.system("hz1"),Rect.new((@size-1)*92,0,92,92))
      @size = 0 if @size == 25
    end

    if Input.repeat?(Input::DOWN) or Keys.repeat?(Keys::S)
      if @tanks == 0
        Sound.play_ok  
        @cursor_index += 1
        @cursor_index = 0 if @cursor_index > 3
      end
    end

    if Input.repeat?(Input::UP) or Keys.repeat?(Keys::W)
      if @tanks == 0
        Sound.play_ok  
        @cursor_index -= 1
        @cursor_index = 3 if @cursor_index < 0
      end
    end
       
    case @cursor_index
    when 0    #New game
      @s.y = 336+60
    when 1    # Continue
      @s.y = 336+45+58
    when 2    # thanks
      @s.y = 336+90+58
    when 3    # Shutdown
      @s.y = 336+90+55+45
    end

    if Input.trigger?(Input::C)
      case @cursor_index
      when 0    #New game
        command_new_game if @n > 100
      when 1    # Continue
        command_continue if @n > 100
      when 2    # thanks
        if @tanks == 0
          command_thanks   if @n > 100
        else
          Audio.se_play("Audio/SE/Cursor2",100) 
          @tanks = 0
        end
      when 3    # Shutdown
        command_shutdown if @n > 100
      end
    end
  end
end
