#encoding:utf-8
#==============================================================================
# ■ Scene_End
#------------------------------------------------------------------------------
# 　结束游戏画面
#==============================================================================

class Scene_End < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    close_command_window
  end
  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    super
    @background_sprite.tone.set(0, 0, 0, 128)
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_GameEnd.new
    @command_window.set_handler(:to_title, method(:command_to_title))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
    @command_window.set_handler(:cancel,   method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● 关闭指令窗口
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  #--------------------------------------------------------------------------
  # ● 指令“返回标题”
  #--------------------------------------------------------------------------
  def command_to_title
    close_command_window
    fadeout_all
    SceneManager.goto(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 指令“退出”
  #--------------------------------------------------------------------------
  def command_shutdown
    close_command_window
    fadeout_all
    SceneManager.exit
  end
end


class Scene_End2 < Scene_MenuBase
  include Module_Weather_EX 
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    @c = 0
    @z = 0
    @n = 0
    @size = 1

    Audio.bgm_play("Audio/BGM/title-sdm_new",90)
    create_picture
    create_multiple_layers
  end

  def create_picture
    @back_h = Sprite.new
    @back_h.bitmap = Cache.picture("back_end3")
    @back_h.z = 1

    @back_mask = Sprite.new
    @back_mask.bitmap = Cache.picture("end_back_mask")
    @back_mask.z = 3

    @back = Sprite.new
    @back.bitmap = Cache.picture("end_back")
    @back.z = 98

    @text = Sprite.new
    @text.bitmap = Cache.picture("end2")
    @text.z = 2
    @text.y = 704

    @shine = Sprite.new
    @shine.bitmap = Cache.picture("00")
    @shine.z = 999
    @shine.opacity = 0

    @mu = Sprite.new
    @mu.bitmap = Bitmap.new(92,92)
    @mu.bitmap.blt(0,0,Cache.system("hz1"),Rect.new(0,0,92,92))
    @mu.x = 300
    @mu.y = 704
    @mu.z = 45

    @ll = Sprite.new
    @ll.bitmap = Cache.system("LL")
    @ll.blend_type = 1
    @ll.x = 300-30
    @ll.y = 704
    @ll.z = 46

    @mu2 = Sprite.new
    @mu2.bitmap = Bitmap.new(92,92)
    @mu2.bitmap.blt(0,0,Cache.system("hz1"),Rect.new(0,0,92,92))
    @mu2.x = 850+20
    @mu2.y = 760
    @mu2.z = 45
    @mu2.zoom_x = 0.8
    @mu2.zoom_y = 0.85

    @ll2 = Sprite.new
    @ll2.bitmap = Cache.system("LL2")
    @ll2.blend_type = 1
    @ll2.x = 850
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
  end

  def create_multiple_layers
    $game_temp.weather_fade = false
    $game_system.weather.clear
    $game_system.weather = [3, 1, "VS_jiangwei"]
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
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate
  #   super
  #   dispose_weather_ex
  #   @text.bitmap.dispose
  #   @text.dispose
  #   @shine.bitmap.dispose
  #   @shine.dispose
  #   @mu.bitmap.dispose
  #   @mu.dispose
  #   @mu2.bitmap.dispose
  #   @mu2.dispose
  #   @mu3.bitmap.dispose
  #   @mu3.dispose
  #   @ll.bitmap.dispose
  #   @ll.dispose
  #   @ll2.bitmap.dispose
  #   @ll2.dispose
  #   @ll3.bitmap.dispose
  #   @ll3.dispose
  #   @back_h.bitmap.dispose
  #   @back_h.dispose
  #   @back.bitmap.dispose
  #   @back.dispose
  #   @back_mask.bitmap.dispose
  #   @back_mask.dispose
  # end

  #--------------------------------------------------------------------------
  # ● 释放对象之后
  #--------------------------------------------------------------------------
  def after_dispose
    $game_system.weather.clear
  end

  def go_title
    ending_equip_add
    RPG::BGM.fade(10 * 1000)
    SceneManager.goto(Scene_Map)
  end


  def ending_equip_add
    a=[578,579,580,581,582,583,206,207,208]
    a.delete_if { |i| $game_variables[278].include?(i) }

    $game_variables[275] = a[rand(a.size)]
    a.delete($game_variables[275])
    
    if $game_variables[281] > 250000
      $game_variables[276] = a[rand(a.size)]
      a.delete($game_variables[276])
    end

    if $game_variables[281] > 300000
      $game_variables[277] = a[rand(a.size)]
      a.delete($game_variables[277])
    end
  end


  def update

    super
    update_weather_ex
    @n += 1
    if @text.y < (-13278+550)
      @back_mask.opacity -= 5
    end  
    if @text.y < -13278
      @c += 1
    else
      @text.y -= 1
      @text.y -= 999 if $TEST 
    end
    RPG::BGS.fade(15 * 1000) if  @c > 10  
    if @c > 300
      @shine.opacity += 1
    end  
    go_title if @shine.opacity >= 255

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
        @z = 1  if @mu.angle <= -45
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
        @z = 0  if @mu3.angle >= 40
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

    if @n%2 == 0 and @mu != nil
      @size += 1
      @mu.bitmap.clear
      @mu.bitmap.blt(0,0,Cache.system("hz1"),Rect.new((@size-1)*92,0,92,92))
      @mu2.bitmap.clear
      @mu2.bitmap.blt(0,0,Cache.system("hz1"),Rect.new((@size-1)*92,0,92,92))
      @mu3.bitmap.clear
      @mu3.bitmap.blt(0,0,Cache.system("hz1"),Rect.new((@size-1)*92,0,92,92))
      @size = 0 if @size == 25
    end
  end
end