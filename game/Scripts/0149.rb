#encoding:utf-8
#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　存档画面
#==============================================================================

class Scene_Save < Scene_File
  def create_background
    super
    #$game_variables[230] = 1 if $game_switches[473] = true
    #$game_variables[230] = 2 if $game_switches[473] = true
    $game_variables[230] = 3 if $game_switches[473] == true
    $game_variables[230] = 4 if $game_switches[474] == true
    $game_variables[230] = 5 if $game_switches[475] == true
    $game_variables[230] = 6 if $game_switches[476] == true
    $game_variables[230] = 7 if $game_switches[477] == true
    $game_variables[230] = 8 if $game_switches[478] == true
    @background_sprite2 = Sprite.create do |sp|
      sp.bitmap = Cache.system("save_map")
    end
  end

  # => 无需手动释放
  # def terminate
  #   super
  #   @background_sprite2.dispose ; @background_sprite2.bitmap.dispose
  # end

  #--------------------------------------------------------------------------
  # ● 获取帮助窗口的文本
  #--------------------------------------------------------------------------
  def help_window_text
    Vocab::SaveMessage
  end
  #--------------------------------------------------------------------------
  # ● 获取开始时文件索引的位置
  #--------------------------------------------------------------------------
  def first_savefile_index
    DataManager.last_savefile_index
  end
  #--------------------------------------------------------------------------
  # ● 确定存档文件
  #--------------------------------------------------------------------------
  def on_savefile_ok
    super
    if DataManager.save_game(@index)
       on_save_success
    else
       Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● 存档成功时的处理
  #--------------------------------------------------------------------------
  def on_save_success
    Sound.play_save
    return_scene
  end
end
