#encoding:utf-8
#==============================================================================
# ■ SceneMapFiber
#------------------------------------------------------------------------------
# 　地图场景的纤程管理器
#   
#==============================================================================
module SceneMapFiber

  SWITCH_GAIN_ITEM_NO = 999               # => 打开次开关才执行

  def self.gainItem(obj, num)
    # 非地图场景则不用此方法显示
    return unless self.check_scene
    if self.check_switch or self.check_switch_vip 
    else
    return 
    end

    # 初始化地图元素 和 viewport
    viewport = self.get_scene_viewport
    spriteset = self.get_scene_spriteset



     if self.check_switch or self.check_switch_vip
    # 初始化 sprite
    sprite = Sprite.new(viewport)
    sprite.z = 1001
    sprite.bitmap = Bitmap.new(1280,704)

    # 基准 Y 坐标
    content_y = 0
    _x= 350+170+15
    _y= 350

    # 显示背景
    $data_items[8].name = "#{$game_variables[169]}" + "金"
    $data_items[7].name = "#{$game_variables[217].to_i}" + "练兵值"
    sprite.bitmap.font.size = 20 + $game_variables[300]+1
    if self.check_switch
    bitmap_back = Cache.system("in_item")
    else
    bitmap_back = Cache.system("in_item")
    end
  # 显示文字
    sprite.bitmap.blt(0,_y-24,bitmap_back,Rect.new(0,0,1280,225), 255) 
    if self.check_switch
    sprite.bitmap.draw_text(_x,content_y+_y-2,128,32,"获得了：")
    _x2 = 0
    else
    sprite.bitmap.draw_text(_x,content_y+_y-2,128,32,"获得了：")
    _x2 = 0
    #sprite.bitmap.draw_text(_x-15,content_y+_y,128,32,"贵重物品获得：")
    #sprite.bitmap.color = Color.new(255,255,255)
    #_x2 = 52-15
    end

    # 显示图标
    bitmap_icon = Cache.system("Iconset")
    rect = Rect.new(obj.icon_index % 16 * 24, obj.icon_index / 16 * 24, 24, 24)
    sprite.bitmap.blt(_x+60+_x2, content_y+2+_y, bitmap_icon, rect, 255)
    #sprite.bitmap.font.color = Color.new(255,255,255,255)
    # 显示文字
    if $game_variables[169] != nil and ( $game_variables[169] > 0 or $game_variables[217] > 0 or $game_variables[218] > 0 )
           if $game_variables[218] > 0 #写出习得军师技能的名字
              sprite.bitmap.draw_text(_x+62+28+_x2-3,content_y+_y-2,320,32,"军师天赋"+"「"+"　　"+"」") 
              sprite.bitmap.font.color = Color.new(255,203,0,255)
              sprite.bitmap.draw_text(_x+62+28+_x2-3,content_y+_y-2,320,32,"　　　　　"+"#{$data_skills[$game_variables[218]].name}") 
              sprite.bitmap.font.color = Color.new(255,255,255,255)
           else
              sprite.bitmap.draw_text(_x+62+28+_x2-3,content_y+_y-2,320,32,"#{obj.name}")
           end
    else
       if self.check_switch
          sprite.bitmap.draw_text(_x+62+28+_x2-3,content_y+_y-2,320,32,"#{obj.name} x #{num}")
       else
      #sprite.bitmap.font.color = Color.new(255,0,0,255)
          if num > 1
             sprite.bitmap.draw_text(_x+62+28+_x2-3,content_y+_y-2,320,32,"#{obj.name} x #{num}")
          else
             sprite.bitmap.draw_text(_x+62+28+_x2-3,content_y+_y-2,320,32,"#{obj.name}")
          end
       end
    end
    # 刷新循环
    loop do
      Graphics.update
      Input.update
      spriteset.update
      $game_map.update(false)
      $game_player.update
      $game_timer.update
      SceneManager.scene.message_window.flash_update
      break if Input.trigger?(:C)
      #SceneManager.scene.map_screen if Input.trigger?(:F5)
    end
  end

    # 清楚 sprite & bitmap
    if sprite
       sprite.bitmap.dispose
       sprite.dispose
    end
    bitmap_back.dispose  if bitmap_back
    bitmap_icon.dispose  if bitmap_icon
    $game_switches[888] = false
    $game_switches[999] = false
    $game_variables[169] = 0
  end

  def self.check_switch
    $game_switches[SWITCH_GAIN_ITEM_NO]
  end

  def self.check_switch_vip
    $game_switches[888]
  end

  def self.check_scene
    SceneManager.scene.is_a?(Scene_Map)
  end

  def self.get_scene_spriteset
    SceneManager.scene.instance_variable_get(:@spriteset)
  end

  def self.get_scene_viewport
    SceneManager.scene.instance_variable_get(:@viewport)
  end

end
