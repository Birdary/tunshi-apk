#encoding:utf-8

class Window_System < Window_Selectable

  
  SCENE_EFFECT_SWITCH = 437

  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @index = 0
    @bgm = get_bgm_volume
    @se = get_se_volume
    @scene_effect = get_scene_effect
    @cv = get_cv
    @battle_effect = get_battle_effect
    @cname = get_cname
    @jump_au = get_jump_au
    @auto_save = get_auto_save
    @padmode = get_padmode

    self.opacity = 0

    create_ui

    self.activate

    refresh
  end

  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    return 6
  end

  def create_ui

    @sp_bgm = Sprite.new
    @sp_bgm.bitmap = Bitmap.new("Graphics/Pictures/nc")
    @sp_bgm.x,@sp_bgm.y = 191+98,223-125+8

    @sp_se = Sprite.new
    @sp_se.bitmap = Bitmap.new("Graphics/Pictures/nc")
    @sp_se.x,@sp_se.y = 191+98,311-125+8-29

    @sp_bgm_text = Sprite.new
    @sp_bgm_text.bitmap = Bitmap.new(128,24)
    @sp_bgm_text.bitmap.font.size = 19 + $game_variables[300]
    @sp_bgm_text.x,@sp_bgm_text.y = 500-40+98,216-125+8

    @sp_se_text = Sprite.new
    @sp_se_text.bitmap = Bitmap.new(128,24)
    @sp_se_text.bitmap.font.size = 19 + $game_variables[300]
    @sp_se_text.x,@sp_se_text.y = 500-40+98,297+7-125+8-29

    @sp_scene_effect_text_open = Sprite.new
    @sp_scene_effect_text_open.bitmap = Bitmap.new(56,24)
    @sp_scene_effect_text_open.bitmap.font.size = 18 + $game_variables[300]
    @sp_scene_effect_text_open.x,@sp_scene_effect_text_open.y = 186,218

    @sp_scene_effect_text_close = Sprite.new
    @sp_scene_effect_text_close.bitmap = Bitmap.new(56,24)
    @sp_scene_effect_text_close.bitmap.font.size = 18 + $game_variables[300]
    @sp_scene_effect_text_close.x,@sp_scene_effect_text_close.y = 237,218

    @sp_cv_text_open = Sprite.new
    @sp_cv_text_open.bitmap = Bitmap.new(56,24)
    @sp_cv_text_open.bitmap.font.size = 18 + $game_variables[300]
    @sp_cv_text_open.x,@sp_cv_text_open.y = 186,218+60

    @sp_cv_text_close = Sprite.new
    @sp_cv_text_close.bitmap = Bitmap.new(56,24)
    @sp_cv_text_close.bitmap.font.size = 18 + $game_variables[300]
    @sp_cv_text_close.x,@sp_cv_text_close.y = 237,218+60

    @sp_battle_effect_text_open = Sprite.new
    @sp_battle_effect_text_open.bitmap = Bitmap.new(56,24)
    @sp_battle_effect_text_open.bitmap.font.size = 18 + $game_variables[300]
    @sp_battle_effect_text_open.x,@sp_battle_effect_text_open.y = 186,218+120

    @sp_battle_effect_text_close = Sprite.new
    @sp_battle_effect_text_close.bitmap = Bitmap.new(56,24)
    @sp_battle_effect_text_close.bitmap.font.size = 18 + $game_variables[300]
    @sp_battle_effect_text_close.x,@sp_battle_effect_text_close.y = 237,218+120



    @sp_cname_text_open = Sprite.new
    @sp_cname_text_open.bitmap = Bitmap.new(56,24)
    @sp_cname_text_open.bitmap.font.size = 18 + $game_variables[300]
    @sp_cname_text_open.x,@sp_cname_text_open.y = 186,218+180

    @sp_cname_text_close = Sprite.new
    @sp_cname_text_close.bitmap = Bitmap.new(56,24)
    @sp_cname_text_close.bitmap.font.size = 18 + $game_variables[300]
    @sp_cname_text_close.x,@sp_cname_text_close.y = 237,218+180


    @sp_jump_au_text_open = Sprite.new
    @sp_jump_au_text_open.bitmap = Bitmap.new(56,24)
    @sp_jump_au_text_open.bitmap.font.size = 18 + $game_variables[300]
    @sp_jump_au_text_open.x,@sp_jump_au_text_open.y = 186,218+240

    @sp_jump_au_text_close = Sprite.new
    @sp_jump_au_text_close.bitmap = Bitmap.new(56,24)
    @sp_jump_au_text_close.bitmap.font.size = 18 + $game_variables[300]
    @sp_jump_au_text_close.x,@sp_jump_au_text_close.y = 237,218+240

    @sp_auto_save_text_open = Sprite.new
    @sp_auto_save_text_open.bitmap = Bitmap.new(56,24)
    @sp_auto_save_text_open.bitmap.font.size = 18 + $game_variables[300]
    @sp_auto_save_text_open.x,@sp_auto_save_text_open.y = 186,218+300

    @sp_auto_save_text_close = Sprite.new
    @sp_auto_save_text_close.bitmap = Bitmap.new(56,24)
    @sp_auto_save_text_close.bitmap.font.size = 18 + $game_variables[300]
    @sp_auto_save_text_close.x,@sp_auto_save_text_close.y = 237,218+300

    @padmode_text_open = Sprite.new
    @padmode_text_open.bitmap = Bitmap.new(56,24)
    @padmode_text_open.bitmap.font.size = 18 + $game_variables[300]
    @padmode_text_open.x,@padmode_text_open.y = 186,218+360

    @padmode_text_close = Sprite.new
    @padmode_text_close.bitmap = Bitmap.new(56,24)
    @padmode_text_close.bitmap.font.size = 18 + $game_variables[300]
    @padmode_text_close.x,@padmode_text_close.y = 237,218+360
  end

  # 无需手动释放
  # def dispose
  #   super
  #   [@sp_bgm,@sp_se,@sp_se_text,@sp_bgm_text,@sp_scene_effect_text_open, @sp_scene_effect_text_close].each{|sp| sp.bitmap.dispose; sp.dispose }
  #   [@padmode_text_open,@padmode_text_close,@sp_cv_text_open,@sp_cv_text_close,@sp_jump_au_text_open,@sp_jump_au_text_close,@sp_battle_effect_text_open, @sp_battle_effect_text_close,@sp_cname_text_open, @sp_cname_text_close,@sp_auto_save_text_open, @sp_auto_save_text_close].each{|sp| sp.bitmap.dispose;sp.dispose  }
  # end

  def get_bgm_volume
      $game_system.system_menu_config[:bgm_volume] || 75
  end

  def get_se_volume
      $game_system.system_menu_config[:se_volume] || 75
  end

  def get_scene_effect
      $game_switches[SCENE_EFFECT_SWITCH]
  end

  def get_cv
       $game_switches[S::CV]
  end

  def get_battle_effect
      $game_switches[S::BATTLE_EFFECT]
  end

  def get_cname
      $game_switches[S::CNAME]
  end

  def get_jump_au
      $game_switches[S::JUMP_AU]
  end

  def get_auto_save
      $game_switches[S::AUTO_SAVE]
  end

  def get_padmode
      $game_switches[742]
  end

  def set_bgm_volume(_v)
      @bgm = _v
      $game_system.system_menu_config[:bgm_volume] = _v
  end

  def set_se_volume(_v)
      @se = _v
      $game_system.system_menu_config[:se_volume] = _v
  end

  def open_scene_effect
      @scene_effect = true
      $game_switches[SCENE_EFFECT_SWITCH] = true
  end

  def open_cv
      @cv = true
      $game_switches[S::CV] = true
  end

  def open_battle_effect
      @battle_effect = true
      $game_switches[S::BATTLE_EFFECT] = true
  end

  def open_cname
      @cname = true
      $game_switches[S::CNAME] = true
  end

  def open_jump_au
      $s491 = true
      @jump_au = true
      $game_switches[S::JUMP_AU] = true
  end

  def open_auto_save
      @auto_save = true
      $game_switches[S::AUTO_SAVE] = true
  end

  def open_padmode
      $padmode = true
      @padmode = true
      $game_switches[742] = true
  end

  def close_scene_effect
      @scene_effect = false
      $game_switches[SCENE_EFFECT_SWITCH] = false
  end

  def close_cv
      @cv = false
      $game_switches[S::CV] = false
  end
  
  def close_battle_effect
      @battle_effect = false
      $game_switches[S::BATTLE_EFFECT] = false
  end

  def close_cname
      @cname = false
      $game_switches[S::CNAME]  = false
  end

  def close_jump_au
      $s491 = false
      @jump_au = false
      $game_switches[S::JUMP_AU]  = false
  end

  def close_auto_save
      @auto_save = false
      $game_switches[S::AUTO_SAVE] = false
  end

  def close_padmode
      $padmode = false
      @padmode = false
      $game_switches[742] = false
  end


  def get_item
    return case @index
    when 0,1
      :bgm
    when 2,3
      :se
    when 4,5
      :scene_effect
    when 6,7
      :cv
    when 8,9
      :battle_effect
    when 10,11
      :cname
    when 12,13
      :jump_au
    when 14,15
      :auto_save
    when 16,17
      :padmode
    else
      nil
    end
  end

  def refresh
    refresh_item_bgm
    refresh_item_se
    refresh_item_scene_effect
    refresh_item_cv
    refresh_item_battle_effect
    refresh_item_cname
    refresh_item_jump_au
    refresh_item_auto_save
    refresh_item_padmode
  end

  def set_item_and_refresh
    _item = get_item
    return if _item.nil?
    send("set_item_#{_item.to_s}")
    send("refresh_item_#{_item.to_s}")
  end

  def set_item_bgm
    case @index
    when 1
      _bgm = [@bgm +5, 100].min
      set_bgm_volume(_bgm)
    when 0
      _bgm = [@bgm -5, 0].max
      set_bgm_volume(_bgm)
    end
  end

  def set_item_se
    case @index
    when 3
      _se = [@se +5, 100].min
      set_se_volume(_se)
    when 2
      _se = [@se -5, 0].max
      set_se_volume(_se)
    end
  end

  def set_item_scene_effect
    case @index
    when 4
      open_scene_effect
    when 5
      close_scene_effect
    end
  end

  def set_item_cv
    case @index
    when 6
      open_cv
    when 7
      close_cv
    end
  end

  def set_item_battle_effect
    case @index
    when 8
      open_battle_effect
    when 9
      close_battle_effect
    end
  end

  def set_item_cname
    case @index
    when 10
      open_cname
    when 11
      close_cname
    end
  end

  def set_item_jump_au
    case @index
    when 12
      open_jump_au
    when 13
      close_jump_au
    end
  end

  def set_item_auto_save
    case @index
    when 14
      open_auto_save
    when 15
      close_auto_save
    end
  end

    def set_item_padmode
    case @index
    when 16
      open_padmode
    when 17
      close_padmode
    end
  end
  # def refresh_item
  #   _item = get_item
  #   return if _item.nil?
  #   send("refresh_item_#{_item.to_s}")
  # end

  def refresh_item_bgm
    w = @sp_bgm.bitmap.width
    w = (@bgm / 100.to_f) * w
    h = @sp_bgm.bitmap.height
    @sp_bgm.src_rect = Rect.new(0,0,w,h)
    @sp_bgm_text.bitmap.clear
    @sp_bgm_text.bitmap.draw_text(0,0,128,24,get_bgm_volume)
  end

  def refresh_item_se
    w = @sp_se.bitmap.width
    w = (@se / 100.to_f) * w
    h = @sp_se.bitmap.height
    @sp_se.src_rect = Rect.new(0,0,w,h)
    @sp_se_text.bitmap.clear
    @sp_se_text.bitmap.draw_text(0,0,128,24,get_se_volume)
  end

  def refresh_item_scene_effect
      if @scene_effect
      @sp_scene_effect_text_open.bitmap.color = Color.new(255,210,40,255)
      @sp_scene_effect_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @sp_scene_effect_text_open.bitmap.color = Color.new(128,128,128,255)
      @sp_scene_effect_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @sp_scene_effect_text_open.bitmap.clear
      @sp_scene_effect_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @sp_scene_effect_text_close.bitmap.clear
      @sp_scene_effect_text_close.bitmap.draw_text(0,0,56,24,"关闭")
    end

    def refresh_item_cv
      if @cv
      @sp_cv_text_open.bitmap.color = Color.new(255,210,40,255)
      @sp_cv_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @sp_cv_text_open.bitmap.color = Color.new(128,128,128,255)
      @sp_cv_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @sp_cv_text_open.bitmap.clear
      @sp_cv_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @sp_cv_text_close.bitmap.clear
      @sp_cv_text_close.bitmap.draw_text(0,0,56,24,"关闭")
    end

  def refresh_item_battle_effect
      if @battle_effect
      @sp_battle_effect_text_open.bitmap.color = Color.new(255,210,40,255)
      @sp_battle_effect_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @sp_battle_effect_text_open.bitmap.color = Color.new(128,128,128,255)
      @sp_battle_effect_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @sp_battle_effect_text_open.bitmap.clear
      @sp_battle_effect_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @sp_battle_effect_text_close.bitmap.clear
      @sp_battle_effect_text_close.bitmap.draw_text(0,0,56,24,"关闭")
    end

  def refresh_item_cname
      if @cname
      @sp_cname_text_open.bitmap.color = Color.new(255,210,40,255)
      @sp_cname_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @sp_cname_text_open.bitmap.color = Color.new(128,128,128,255)
      @sp_cname_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @sp_cname_text_open.bitmap.clear
      @sp_cname_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @sp_cname_text_close.bitmap.clear
      @sp_cname_text_close.bitmap.draw_text(0,0,56,24,"关闭")
    end

  def refresh_item_jump_au
      if @jump_au
      @sp_jump_au_text_open.bitmap.color = Color.new(255,210,40,255)
      @sp_jump_au_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @sp_jump_au_text_open.bitmap.color = Color.new(128,128,128,255)
      @sp_jump_au_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @sp_jump_au_text_open.bitmap.clear
      @sp_jump_au_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @sp_jump_au_text_close.bitmap.clear
      @sp_jump_au_text_close.bitmap.draw_text(0,0,56,24,"关闭")
    end

  def refresh_item_auto_save
      if @auto_save
      @sp_auto_save_text_open.bitmap.color = Color.new(255,210,40,255)
      @sp_auto_save_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @sp_auto_save_text_open.bitmap.color = Color.new(128,128,128,255)
      @sp_auto_save_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @sp_auto_save_text_open.bitmap.clear
      @sp_auto_save_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @sp_auto_save_text_close.bitmap.clear
      @sp_auto_save_text_close.bitmap.draw_text(0,0,56,24,"关闭")
  end

  def refresh_item_padmode
      if @padmode
      @padmode_text_open.bitmap.color = Color.new(255,210,40,255)
      @padmode_text_close.bitmap.color = Color.new(128,128,128,255)
      else
      @padmode_text_open.bitmap.color = Color.new(128,128,128,255)
      @padmode_text_close.bitmap.color = Color.new(255,210,40,255)
      end
      @padmode_text_open.bitmap.clear
      @padmode_text_open.bitmap.draw_text(0,0,56,24,"开启")
      @padmode_text_close.bitmap.clear
      @padmode_text_close.bitmap.draw_text(0,0,56,24,"关闭")
  end



  #--------------------------------------------------------------------------
  # ● 光标向下移动
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    case @index
    when 0,1
      _index = 2
    when 2,3
      _index = 4
    when 4,5
      _index = 6
    when 6,7
      _index = 8
    when 8,9
      _index = 10
    when 10,11
      _index = 12
    when 12,13
      _index = 14
    when 14,15
      _index = 16
    else
      _index = @index
    end
    select(_index)
  end
  #--------------------------------------------------------------------------
  # ● 光标向上移动
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    case @index
    when 16,17
      _index = 14
    when 14,15
      _index = 12
    when 12,13
      _index = 10
    when 10,11
      _index = 8
    when 8,9
      _index = 6
    when 6,7
      _index = 4
    when 4,5
      _index = 2
    when 2,3
      _index = 0
    else
      _index = @index
    end
    select(_index)
  end
  #--------------------------------------------------------------------------
  # ● 光标向右移动
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    case @index
    when 0,2,4,6,8,10,12,14,16
      _index = @index + 1
    else
      _index = @index
    end
    select(_index)
  end
  #--------------------------------------------------------------------------
  # ● 光标向左移动
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    case @index
    when 1,3,5,7,9,10,11,13,15,17
      _index = @index - 1
    else
      _index = @index
    end
    select(_index)
  end
  #--------------------------------------------------------------------------
  # ● 获取行高
  #--------------------------------------------------------------------------
  def line_height
    return 24
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = 43
    rect.height = 28
    case index
    when 0
      rect.x, rect.y = 70, 208
    when 1
      rect.x, rect.y = 122, 208
    when 2
      rect.x, rect.y = 70, 268
    when 3
      rect.x, rect.y = 122, 268
    when 4
      rect.x, rect.y = 70, 328
    when 5
      rect.x, rect.y = 122, 328
    when 6
      rect.x, rect.y = 70, 328+60
    when 7
      rect.x, rect.y = 122, 328+60
    when 8
      rect.x, rect.y = 70, 328+120
    when 9
      rect.x, rect.y = 122, 328+120
    when 10
      rect.x, rect.y = 70, 328+180
    when 11
      rect.x, rect.y = 122, 328+180
    when 12
      rect.x, rect.y = 70, 328+240
    when 13
      rect.x, rect.y = 122, 328+240
    when 14
      rect.x, rect.y = 70, 328+300
    when 15
      rect.x, rect.y = 122, 328+300
    when 16
      rect.x, rect.y = 70, 328+360
    when 17
      rect.x, rect.y = 122, 328+360
    end
    rect
  end
end

class Scene_System < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super

    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)

    create_background
    create_window
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # 无需手动释放
  # def terminate
  #   super
  #   if @menuback_sprite
  #     @menuback_sprite.bitmap.dispose
  #     @menuback_sprite.dispose
  #   end
  #   if @back
  #     @back.bitmap.dispose
  #     @back.dispose
  #   end
  #   if @window
  #     @window.dispose
  #   end
  #   if @background_sprite
  #     @background_sprite.bitmap.dispose  if @background_sprite.bitmap
  #     @background_sprite.dispose
  #   end
  # end

  def create_window
    @window = Window_System.new(0+98,0-125,1280,704+125)
  end

  def create_background
    @back = Sprite.new
    @back.bitmap = Bitmap.new("Graphics/System/system_config")
  end

  def update
    super
    if Input.trigger?(:C)
      Audio.se_play("Audio/SE/0decide1")
      @window.set_item_and_refresh
    end
    if Input.trigger?(:B)
      Sound.play_cancel
      DataManager.save_cache_file
      return_scene
    end
  end
end
