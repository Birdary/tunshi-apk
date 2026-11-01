#encoding:utf-8
module S

  STATUS_TIP = 15            # => 状态提示开关
  DIALOG_HONK = 400          # => 对话嘟嘟嘟
  AUTO_BATTLE_AI = 427       # => 敌人专用自动战斗AI初始化（用于跳过强制优先出手）
  CV = 467                   # => CV开关
  SCENE_EFFECT = 437         # => 显示场景特效，天气开关
  BATTLE_EFFECT = 486        # => 战斗画面内的特效开关
  CNAME = 487                # => 显示地名
  AUTO_SAVE = 489            # => 自动存档开关
  JUMP_AU = 491              # => 跳过章节动画开关

end


#==============================================================================
# ■ Module Weather EX
#==============================================================================
module Module_Weather_EX
  
 #--------------------------------------------------------------------------
 # ● Create Weather EX
 #--------------------------------------------------------------------------                   
  def create_weather_ex
      dispose_weather_ex
      create_weather_viewport
      create_weather_sprite     
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose Wheater EX
 #--------------------------------------------------------------------------                     
  def dispose_weather_ex
      dispose_weather_ex_sprite
      dispose_weather_ex_viewport
  end  
 
 #--------------------------------------------------------------------------
 # ● Create Weather Viewport
 #--------------------------------------------------------------------------                     
  def create_weather_viewport
      dispose_weather_ex_viewport
      if SceneManager.scene.is_a?(Scene_Battle) 
          @viewport_weather_ex = Viewport.new(-32,  60, 1344, 580)
      else
          @viewport_weather_ex = Viewport.new(-32, -32, 1344, 768)
      end
      @viewport_weather_ex.z = MOG_WEATHER_EX::WEATHER_SCREEN_Z
      @viewport_weather_ex.ox = ($game_map.display_x * 32)
      @viewport_weather_ex.oy = ($game_map.display_y * 32)    
      if SceneManager.scene.is_a?(Scene_Battle)  
            if  $game_switches[486] == true
                @viewport_weather_ex.visible = true
            else
                @viewport_weather_ex.visible = false 
            end
      else
         @viewport_weather_ex.visible = true 
      end
  end
 #--------------------------------------------------------------------------
 # ● Create Weather Sprite
 #--------------------------------------------------------------------------                       
  def create_weather_sprite
      dispose_weather_ex_sprite
      @old_weather = $game_system.weather
      return if $game_system.weather == [] or $game_system.weather[0] == -1
      @weather_ex = []
      index = 0
      power_efic = MOG_WEATHER_EX::WEATHER_POWER_EFIC
      power_efic = 1 if power_efic < 1
      power = [[$game_system.weather[1] * power_efic, power_efic].max, 999].min
      for i in 0...power
          @weather_ex.push(Weather_EX.new(@viewport_weather_ex,$game_system.weather[0],$game_system.weather[2],index, @viewport_weather_ex.ox, @viewport_weather_ex.oy))
          index += 1
      end            
  end

 #--------------------------------------------------------------------------
 # ● Dispose Weather EX Viewport 
 #--------------------------------------------------------------------------                       
  def dispose_weather_ex_viewport
      return if @viewport_weather_ex == nil 
      @viewport_weather_ex.dispose
  end  
  
 #--------------------------------------------------------------------------
 # ● Dispose Weather EX
 #--------------------------------------------------------------------------                   
  def dispose_weather_ex_sprite
      return if @weather_ex == nil
      index = 0
      for i in @weather_ex
          $game_temp.weather_ex_set[index] = [] if $game_temp.weather_ex_set[index] == nil
          $game_temp.weather_ex_set[index].push(i.x,i.y,i.opacity,i.angle,i.zoom_x)
          i.dispose
          index += 1
      end
      @weather_ex.each {|sprite| sprite.dispose}  
      @weather_ex.clear
      @weather_ex = nil
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose Refresh
 #--------------------------------------------------------------------------                    
  def dispose_refresh
      $game_temp.weather_ex_set.clear
      return if @weather_ex == nil
      @weather_ex.each {|sprite| sprite.dispose}
      @weather_ex.clear
      @weather_ex = nil
  end  
  
 #--------------------------------------------------------------------------
 # ● Update Weather EX
 #--------------------------------------------------------------------------                   
  def update_weather_ex
      refresh_weather_ex
      update_weather_ex_viewport
      return if @weather_ex == nil
      @weather_ex.each {|sprite| sprite.update_weather(@viewport_weather_ex.ox,@viewport_weather_ex.oy)} 
  end
  
 #--------------------------------------------------------------------------
 # ● Update Weather Ex Viewport
 #--------------------------------------------------------------------------                     
  def update_weather_ex_viewport
      return if @viewport_weather_ex == nil 
      @viewport_weather_ex.ox = ($game_map.display_x * 32)
      @viewport_weather_ex.oy = ($game_map.display_y * 32)
  end
 
 #--------------------------------------------------------------------------
 # ● Refresh Weather EX
 #--------------------------------------------------------------------------                     
  def refresh_weather_ex
      return if @old_weather == nil
      return if @old_weather == $game_system.weather
      dispose_refresh
      create_weather_sprite
  end  
end  