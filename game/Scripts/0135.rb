#encoding:utf-8
#==============================================================================
# ■ Scene_MenuBase
#------------------------------------------------------------------------------
# 　所有菜单画面的基本处理
#==============================================================================

class Scene_MenuBase < Scene_Base
  include RPG::EXT::FlashSprite
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    #create_menu_background
    @actor = $game_party.menu_actor
    $game_switches[488] = true
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    dispose_background
  end
  #--------------------------------------------------------------------------
  # ● 设置菜单背景
  #--------------------------------------------------------------------------
  def set_menu_background(btm)
    @menuback_sprite = Sprite.create do |sp|
      sp.bitmap = btm
    end
  end

  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  #--------------------------------------------------------------------------
  # ● 释放背景
  #--------------------------------------------------------------------------
  def dispose_background
    if @background_sprite
      @background_sprite.dispose
      @background_sprite.bitmap.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成帮助窗口
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 切换到下一个角色
  #--------------------------------------------------------------------------
  def next_actor
    @actor = $game_party.menu_actor_next
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● 切换到上一个角色
  #--------------------------------------------------------------------------
  def prev_actor
    @actor = $game_party.menu_actor_prev
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  def on_actor_change
  end

  def update
    super
    update_flash_background
  end

  def terminate
    super
    dispose_flash_background
  end
end
