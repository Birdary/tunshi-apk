#encoding:utf-8
#==============================================================================
# ■ Scene_Base
#------------------------------------------------------------------------------
# 　游戏中所有 Scene 类（场景类）的父类
#==============================================================================

class Scene_Base
  include DisableableObject
  #--------------------------------------------------------------------------
  # ● 主逻辑
  #--------------------------------------------------------------------------
  def main
    before_start
    start
    post_start
    update until scene_changing?
    # loop_scene
    pre_terminate
    terminate
    after_terminate
  end

  def loop_scene
    while !scene_changing?
      update
    end 
  end

  def before_start
    GC.cache_start
    $game_variables[300] = 3
  end

  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    create_main_viewport
    # @sprite_notice = sprite_notice.new @viewport
    # @sprite_notice = Sprite_Tip.new(@viewport)
    # Net2nd.notice
  end
  #--------------------------------------------------------------------------
  # ● 开始后处理
  #--------------------------------------------------------------------------
  def post_start
    perform_transition
    Input.update
  end
  #--------------------------------------------------------------------------
  # ● 判定是否更改场景中
  #--------------------------------------------------------------------------
  def scene_changing?
    SceneManager.scene != self
  end

  # For wegame
  def notice msg
    # msgbox("推送了消息:"+msg)
    # msgbox(text + "success!")
    # @sprite_notice.add text,"green"
    $game_system.wegame_push_achievement[msg] = true if $game_system.wegame_push_achievement[msg] == false
  end
  
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_basic
    if @sprite_notice
      @sprite_notice.update
      # Net2nd::Queue.update
    end
    WegameSDK.updateEvent if defined?(WegameSDK)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面（基础）
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update
    Input.update
    update_all_windows
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  def pre_terminate
  end

  def clear_objects
    
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    Graphics.freeze if Config::SCENE_FREEZE
    dispose_all_objects
    
    # => 无需手动释放
    # dispose_all_windows
    # dispose_main_viewport
    # if @sprite_notice
    #   @sprite_notice.dispose
    #   @sprite_notice.bitmap.dispose
    #   @sprite_notice = nil
    # end

    after_dispose
  end

  #--------------------------------------------------------------------------
  # ● 释放对象之后
  #--------------------------------------------------------------------------
  def after_dispose
  end

  #--------------------------------------------------------------------------
  # ● 执行渐变
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(transition_speed)
  end
  #--------------------------------------------------------------------------
  # ● 获取渐变速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 10
  end
  #--------------------------------------------------------------------------
  # ● 生成显示端口
  #--------------------------------------------------------------------------
  def create_main_viewport
    @viewport = Viewport.new
    @viewport.z = 200
  end
  #--------------------------------------------------------------------------
  # ● 释放显示端口
  #--------------------------------------------------------------------------
  def dispose_main_viewport
    @viewport.dispose if @viewport
  end
  #--------------------------------------------------------------------------
  # ● 更新所有窗口
  #--------------------------------------------------------------------------
  def update_all_windows
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.update if ivar.is_a?(Window)
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放所有
  #--------------------------------------------------------------------------
  def dispose_all_objects
    _dispose
    # instance_variables.each do |varname|
    #   ivar = instance_variable_get(varname)
    #   ivar.dispose if ivar.is_a?(Window)
    #   if ivar.is_a?(Sprite)
    #     ivar.bitmap.dispose if ivar.bitmap
    #     ivar.dispose
    #     instance_variable_set(varname,nil)
    #   end
    #   if ivar.is_a?(Bitmap)
    #     ivar.dispose
    #     instance_variable_set(varname,nil)
    #   end
    #   if ivar.is_a?(Viewport)
    #     ivar.dispose
    #     instance_variable_set(varname,nil)
    #   end
    #   if ivar.is_a?(Plane)
    #     ivar.dispose
    #     instance_variable_set(varname,nil)
    #   end
    #   if ivar.respond_to?(:dispose)
    #     ivar.dispose
    #     instance_variable_set(varname,nil)
    #   end
    #   varname = nil
    # end
  end
  #--------------------------------------------------------------------------
  # ● 【已废】释放所有窗口
  #--------------------------------------------------------------------------
  def dispose_all_windows
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.dispose if ivar.is_a?(Window)
      ivar = nil
      instance_variable_set(varname,nil)
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回前一个场景
  #--------------------------------------------------------------------------
  def return_scene
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # ● 淡出各种音效以及图像
  #--------------------------------------------------------------------------
  def fadeout_all(time = 1000)
    RPG::BGM.fade(time)
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    Graphics.fadeout(time * Graphics.frame_rate / 1000)
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # ● 游戏结束的判定
  #    如果全灭则切换到游戏结束画面。
  #--------------------------------------------------------------------------
  def check_gameover
    if SceneManager.scene.is_a?(Scene_Battle)
      SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成菜单画面背景
  #--------------------------------------------------------------------------
  def create_menu_background
    @menuback_sprite = Sprite.new

    case $game_temp.shop_type
    when 4
      if $game_switches[743] == true
         @menuback_sprite.bitmap = Bitmap.new("Graphics/System/shop_back_40")
      else
         @menuback_sprite.bitmap = Bitmap.new("Graphics/System/shop_back_4")
      end
    when 1
      @menuback_sprite.bitmap = Bitmap.new("Graphics/System/shop_back_1")
    when 2
      @menuback_sprite.bitmap = Bitmap.new("Graphics/System/shop_back_2")
    when 3
      @menuback_sprite.bitmap = Bitmap.new("Graphics/System/shop_back_3")
    when 5
      @menuback_sprite.bitmap = Bitmap.new("Graphics/System/shop_back_5")
    end

    # @menuback_sprite.bitmap = $game_temp.background_bitmap
   # @menuback_sprite.color.set(16, 16, 16, 255)
    update_menu_background
  end
  #--------------------------------------------------------------------------
  # ● 释放菜单画面背景
  #--------------------------------------------------------------------------
  def dispose_menu_background
    if @menuback_sprite
      @menuback_sprite.bitmap.dispose 
      @menuback_sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新菜单画面背景
  #--------------------------------------------------------------------------
  def update_menu_background
  end

  #--------------------------------------------------------------------------
  # ● 检查角色和技能是否通过修改加入，如果通过修改加入，立刻删除
  #--------------------------------------------------------------------------
  def team_ac_check

    return if $TEST

    #角色删除
    if $game_variables[251][30] > 4.11
       SceneManager.goto(Scene_Title)
    end
    remove = []
    for i in 0...$game_party.members.size
      actor = $game_party.members[i]
      if !$game_variables[240].include?(actor.id)
        remove << actor.id
      end
      if actor.level > 50 or ( $game_party.members[i].hp > 6000 and actor.id < 208 )
        remove << actor.id
      end
      if $game_party.members[i].mp > 1600 and actor.id < 208 
        remove << actor.id
      end
      if actor.atk > 355 or actor.def > 355
        remove << actor.id
      end
      if actor.str > ($data_classes[actor.id].params[2,actor.level]+100) or \
        actor.ski > ($data_classes[actor.id].params[3,actor.level]+100) or \
        actor.int > ($data_classes[actor.id].params[4,actor.level]+100) or \
        actor.agi > ($data_classes[actor.id].params[6,actor.level]+100) 
        remove << actor.id
      end
    end
    if $game_variables[250][9] != [9,0,9,0,9,0,9,0]
      remove << 9
      $game_variables[240].delete(9)
      $game_variables[261].delete(9) if $game_variables[261] != 0
    end  
    if $game_variables[250][10] != [1,9,8,5,0,9,1,2]
      remove << 10
      $game_variables[240].delete(10)
      $game_variables[261].delete(10) if $game_variables[261] != 0
    end  
    if $game_variables[250][29] != [2,6,5,2,9,2,0,8]
      remove << 29
      $game_variables[240].delete(29)
      $game_variables[261].delete(29) if $game_variables[261] != 0
    end 
    if $game_variables[250][30] != [1,9,8,7,1,2,0,9] 
      remove << 30
      $game_variables[240].delete(30)
      $game_variables[261].delete(30) if $game_variables[261] != 0
    end 
    if $game_variables[250][40] != [2,7,9,8,4,7,4,4] 
      remove << 40
      $game_variables[240].delete(40)
      $game_variables[261].delete(40) if $game_variables[261] != 0
    end 
    if $game_variables[250][41] != [1,9,8,8,1,2,0,8] 
      remove << 41
      $game_variables[240].delete(41)
      $game_variables[261].delete(41) if $game_variables[261] != 0
    end 
    if $game_variables[250][50] != [6,3,6,3,6,3,6,3] 
      remove << 50 
      $game_variables[240].delete(50)
      $game_variables[261].delete(50) if $game_variables[261] != 0
    end 
    if $game_variables[250][24] != [7,8,7,8,7,8,7,8] 
      remove << 24
      $game_variables[240].delete(24)
      $game_variables[261].delete(24) if $game_variables[261] != 0
    end 
    if $game_variables[250][52] != [1,0,0,0,0,0,0,0] 
      remove << 52
      $game_variables[240].delete(52)
      $game_variables[261].delete(52) if $game_variables[261] != 0
    end 
    if $game_variables[250][63] != [3,3,3,3,3,3,3,3] 
      remove << 63
      $game_variables[240].delete(63)
      $game_variables[261].delete(63) if $game_variables[261] != 0
    end 
    if $game_variables[250][58] != [7,1,7,1,7,1,7,1] 
      remove << 58
      $game_variables[240].delete(58)
      $game_variables[261].delete(58) if $game_variables[261] != 0
    end 
    if $game_variables[250][28] != [5,6,0,5,3,3,7,1] 
      remove << 28
      $game_variables[240].delete(28)
      $game_variables[261].delete(28) if $game_variables[261] != 0
    end 
    if $game_variables[250][64] != [1,6,7,7,5,9,5,3] 
      remove << 64
      $game_variables[240].delete(64)
      $game_variables[261].delete(64) if $game_variables[261] != 0
    end 
    if $game_variables[250][71] != [8,8,3,1,8,6,0,6]
      remove << 71
      $game_variables[240].delete(71)
      $game_variables[261].delete(71) if $game_variables[261] != 0
    end 
    if $game_variables[250][25] != [7,4,7,4,7,4,7,4] 
      remove << 25
      $game_variables[240].delete(25)
      $game_variables[261].delete(25) if $game_variables[261] != 0
    end 
    if $game_variables[250][69] != [6,8,6,8,6,8,6,8]
      remove << 69
      $game_variables[240].delete(69)
      $game_variables[261].delete(69) if $game_variables[261] != 0
    end 
    if $game_variables[250][214] != [7,1,7,1,7,1,7,1] 
      remove << 214
      $game_variables[240].delete(214)
      $game_variables[261].delete(214) if $game_variables[261] != 0
    end 
    if $game_variables[250][215] != [5,1,5,1,5,1,5,1] 
      remove << 215
      $game_variables[240].delete(215)
      $game_variables[261].delete(215) if $game_variables[261] != 0
    end 
    
    if remove != []
      remove.uniq!
      for i in 0...remove.size
        $game_party.remove_actor_hack(remove[i]) if remove[i] != nil
      end 
    end  
    # 武将技删除
    if $game_switches[629] == false
       $game_actors[23].forget_skill(330)  unless $game_variables[279].include?(330) 
      for s in 168...174
        for i in 0...250
          if !$game_variables[279].include?(s) 
            if $data_actors[i] != nil and  $data_classes[i] != nil
              $game_actors[i].forget_skill(s)
            end
          end
        end
      end
    end
    # 2nd超级装备删除 武器
    for i in 578..583
      unless $game_variables[278].include?(i)
         $game_party.gain_item($data_weapons[i],-99,true)
      end
      if $game_party.item_number($data_weapons[i]) > 1
         j_s = -( $game_party.item_number($data_weapons[i]) - 1 )
         $game_party.gain_item($data_weapons[i],j_s,true)
      end
    end    
    # 2nd超级装备删除 防具     
    for i in 206..208
      unless $game_variables[278].include?(i)
        $game_party.gain_item($data_armors[i],-99,true)
      end  
      if $game_party.item_number($data_armors[i]) > 1
         j_s = -( $game_party.item_number($data_armors[i]) - 1 )
         $game_party.gain_item($data_armors[i],j_s,true)
      end
    end
     # 2nd超级装备删除 饰品  
      unless $game_variables[278].include?(375)
        $game_party.gain_item($data_armors[375],-99,true)
      end  
      if $game_party.item_number($data_armors[375]) > 1
         j_s = -( $game_party.item_number($data_armors[375]) - 1 )
         $game_party.gain_item($data_armors[375],j_s,true)
      end
      # 试炼印删除
      sl_max = 0
      for i in 151...159
        if $game_party.item_number($data_items[i]) > 0
           sl_max += $game_party.item_number($data_items[i])
        end   
      end
      if $game_variables[314] != (sl_max * 999).to_i
         for i in 151...159
             $game_party.gain_item($data_items[i],-99,true)
             $game_variables[314] = 0
         end
      end  

    # 特殊道具删除
    a = 8493071
    for i in 1...999
      item = $data_weapons[i]
      $game_party.gain_item(item,-99) if item != nil and item.name != nil and $game_party.item_number(item)*a != $game_variables[272][i]
    end
    for i in 1...999
      item = $data_armors[i]
      $game_party.gain_item(item,-99) if item != nil and item.name != nil and $game_party.item_number(item)*a != $game_variables[273][i]
    end
    for i in 1...999
      item = $data_items[i]
      $game_party.gain_item(item,-99) if item != nil and item.name != nil and $game_party.item_number(item)*a != $game_variables[274][i]
    end
  end

  def after_terminate
    _instance_clean
  end
end

