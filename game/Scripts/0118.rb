#encoding:utf-8
#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　处理地图画面精灵和图块的类。本类在 Scene_Map 类的内部使用。
#==============================================================================

class Spriteset_Map

  include DisableableObject

  PICTURE_VIEW_ON_FADE_SWITCH_NUM = 799   # => 打开此开关，事件图片会显示在 淡入淡出层之上

  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_characters
    create_shadow
    create_weather
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # ● 生成显示端口
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport4 = Viewport.new
    @viewport1.z = 25
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 读取图块地图
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.map_data = $game_map.data
    load_tileset
  end
  #--------------------------------------------------------------------------
  # ● 读取图块组
  #--------------------------------------------------------------------------
  def load_tileset
    @tileset = $game_map.tileset
    @tileset.tileset_names.each_with_index do |name, i|
      if Config::MAP_SCENE_USE_CACHE
        @tilemap.bitmaps[i] = Cache.tileset(name)
      else
        @tilemap.bitmaps[i] = Bitmap.new("Graphics/Tilesets/#{name}")
      end
    end
    @tilemap.flags = @tileset.flags
  end
  #--------------------------------------------------------------------------
  # ● 生成远景图
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport4)
    @parallax.z = -50
  end
  #--------------------------------------------------------------------------
  # ● 生成人物精灵
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    $game_map.events.values.each do |event|
      v = event.is_water? ? @viewport4 : @viewport1
      @character_sprites.push(Sprite_Character.new(v, event))
    end
    $game_map.vehicles.each do |vehicle|
      @character_sprites.push(Sprite_Character.new(@viewport1, vehicle))
    end
    $game_player.followers.reverse_each do |follower|
      @character_sprites.push(Sprite_Character.new(@viewport1, follower))
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    @map_id = $game_map.map_id
  end
  #--------------------------------------------------------------------------
  # ● 生成飞艇影子
  #--------------------------------------------------------------------------
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    if Config::MAP_SCENE_USE_CACHE
      @shadow_sprite.bitmap = Cache.system("Shadow")
    else
      @shadow_sprite.bitmap = Bitmap.new("Graphics/System/Shadow")
    end
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #--------------------------------------------------------------------------
  # ● 生成天气
  #--------------------------------------------------------------------------
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 生成图片精灵
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 生成计时器精灵
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    _dispose
    dispose_tilemap
    if $game_map.parallax_name != ""
      dispose_parallax
    end
    dispose_characters
    dispose_shadow
    dispose_weather
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # ● 释放地图图块
  #--------------------------------------------------------------------------
  def dispose_tilemap
    if @tilemap
      for i in 0...@tileset.tileset_names.size
        bitmap = @tilemap.bitmaps[i]
        bitmap.dispose
      end
      @tilemap.dispose
      @tilemap = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放远景图
  #--------------------------------------------------------------------------
  def dispose_parallax
    if @parallax && !@parallax.disposed?
      @parallax.bitmap.dispose if @parallax.bitmap && !@parallax.bitmap.disposed?
      @parallax.dispose
      @parallax = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放人物精灵
  #--------------------------------------------------------------------------
  def dispose_characters
    if @character_sprites && @character_sprites.size > 0
      @character_sprites.each_with_index {|sprite,index| @character_sprites[index].dispose; @character_sprites[index] = nil }
      @character_sprites.clear
      @character_sprites = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放飞艇影子
  #--------------------------------------------------------------------------
  def dispose_shadow
    if @shadow_sprite
      @shadow_sprite.bitmap.dispose if @shadow_sprite.bitmap
      @shadow_sprite.dispose
      @shadow_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放天气
  #--------------------------------------------------------------------------
  def dispose_weather
    if @weather
      @weather.dispose
      @weather = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放图片精灵
  #--------------------------------------------------------------------------
  def dispose_pictures
    if @picture_sprites && @picture_sprites.size > 0
      @picture_sprites.compact.each_with_index {|sprite,index| @character_sprites[index].dispose; @character_sprites[index] = nil }
      @picture_sprites.clear
      @picture_sprites = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放计时器精灵
  #--------------------------------------------------------------------------
  def dispose_timer
    if @timer_sprite
      @timer_sprite.dispose
      @timer_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放显示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    if @viewport1
      @viewport1.dispose
      @viewport1 = nil
    end
    if @viewport2
      @viewport2.dispose
      @viewport2 = nil
    end
    if @viewport3
      @viewport3.dispose
      @viewport3 = nil
    end
    if @viewport4
      @viewport4.dispose
      @viewport4 = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新人物
  #--------------------------------------------------------------------------
  def refresh_characters
    dispose_characters
    create_characters
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_tileset
    update_tilemap
    if $game_map.parallax_name != ""
       update_parallax
    end
    update_characters
    update_shadow
    update_weather
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # ● 监视图块组是否需要被切换
  #--------------------------------------------------------------------------
  def update_tileset
    if @tileset != $game_map.tileset
      if Config::MAP_SCENE_USE_CACHE
        if @tilemap
          @tilemap.dispose
          @tilemap = nil
          GC.start
          create_tilemap
        end
      else
        load_tileset
      end
      refresh_characters
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新地图图块
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.map_data = $game_map.data
    @tilemap.ox = $game_map.display_x * 32
    @tilemap.oy = $game_map.display_y * 32
    @tilemap.update
  end
  #--------------------------------------------------------------------------
  # ● 更新远景图
  #--------------------------------------------------------------------------
  def  update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name

      if @parallax.bitmap
        @parallax.bitmap.dispose
        @parallax.bitmap = nil
      end
      @parallax = nil
      create_parallax

      if Config::MAP_SCENE_USE_CACHE
        @parallax.bitmap = Cache.parallax(@parallax_name)
      else
        @parallax.bitmap = Bitmap.new("Graphics/Parallaxes/#{@parallax_name}")
      end

      Graphics.frame_reset
    end
    @parallax.ox = $game_map.parallax_ox(@parallax.bitmap)
    @parallax.oy = $game_map.parallax_oy(@parallax.bitmap)
  end
  #--------------------------------------------------------------------------
  # ● 更新人物精灵
  #--------------------------------------------------------------------------
  def update_characters
    refresh_characters if @map_id != $game_map.map_id
    @character_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● 更新飞艇影子
  #--------------------------------------------------------------------------
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新天气
  #--------------------------------------------------------------------------
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.power = $game_map.screen.weather_power
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end
  #--------------------------------------------------------------------------
  # ● 更新图片精灵
  #--------------------------------------------------------------------------
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新计时器精灵
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新显示端口
  #--------------------------------------------------------------------------
  def update_viewports
    if $game_switches[PICTURE_VIEW_ON_FADE_SWITCH_NUM]
      @viewport2.z = 100
      @viewport3.z = 50
    else
      @viewport2.z = 50
      @viewport3.z = 100
    end

    @viewport1.tone.set($game_map.screen.tone)
    @viewport1.ox = $game_map.screen.shake
    @viewport4.tone.set($game_map.screen.tone)
    @viewport4.ox = $game_map.screen.shake
    @viewport2.color.set($game_map.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
    @viewport4.update
  end
end
