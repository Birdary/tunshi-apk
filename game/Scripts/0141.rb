#encoding:utf-8
#==============================================================================
# ■ Scene_Name
#------------------------------------------------------------------------------
# 　名字输入画面
#==============================================================================

class Scene_Name < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 准备
  #--------------------------------------------------------------------------
  def prepare(actor_id, max_char)
    @actor_id = actor_id
    @max_char = max_char
  end
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    @x = 0
    @z = 0
    @n = 0
    @size = 1
    @back = Sprite.new
    @back.bitmap = Cache.system("edit_back")
    @actor = $game_actors[@actor_id]
    @edit_window = Window_NameEdit.new(@actor, @max_char)
    @input_window = Window_NameInput.new(@edit_window)
    @input_window.z = 120
    @input_window.set_handler(:ok, method(:on_input_ok))
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
  #--------------------------------------------------------------------------
  # ● 输入“确定”
  #--------------------------------------------------------------------------
  def on_input_ok
    @actor.name = @edit_window.name
    return_scene
  end

  # => 无需手动删除
  # def dispose
  #   if @back != nil
  #     @back.bitmap.dispose 
  #     @back.dispose 
  #   end
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
  # end

  def on_cancel
    Sound.play_cancel
    SceneManager.call(Scene_Title)
    DataManager.load_cache_file
    $back_title = true
  end

  def update

    super
    if ( Keys.trigger?(Keys::R) or Input.trigger?(:L) ) and !$op_2nd
       return on_cancel  
    end         
    @n += 1


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
        @z = 1  if @mu3.angle <= -45
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


