#encoding:utf-8

Graphics.resize_screen(1280,704)
Graphics.frame_rate = 60
Font.default_name = (["Noto"])

unless $TEST
  if $game_platform.to_s == "20"
    $isWegame = true 
    $platform_logo_name = "LOGO_03"
  elsif $game_platform.to_s == "10"
    $isSteam = true
    $platform_logo_name = "LOGO_04"
  elsif $game_platform.to_s == "30"
    $platform_logo_name = "LOGO_02"
  else
    msgbox "Game platform verification Error！"
    exit
  end
end

# 闪退测试标记
$TEST_ST = false
if $TEST_ST
   msgbox "闪退测试 1.34"
   $back_title = true
end



scripts = []

scripts.push "Scripts/sapi.rb" if $isSteam
scripts.push "Scripts/ext/00_config.rb"
scripts.push "Scripts/ext/01_object.rb"
scripts.push "Scripts/ext/02_rpg.rb"
scripts.push "Scripts/ext/03_sprite_flash.rb"
scripts.push "Scripts/ext/04_tree.rb"
scripts.push "Scripts/ext/05_sk_graph.rb"
scripts.push "Scripts/ext/06_cn.rb"
scripts.push "Scripts/module/01_vocab.rb"
scripts.push "Scripts/module/02_sound.rb"
scripts.push "Scripts/module/03_cache.rb"
scripts.push "Scripts/module/04_data_manager.rb"
scripts.push "Scripts/module/05_scene_manager.rb"
scripts.push "Scripts/module/06_battle_manager.rb"
scripts.push "Scripts/module/07_battle_back.rb"
scripts.push "Scripts/module/08_battler_pos.rb"
scripts.push "Scripts/module/09_battle_fiber.rb"
scripts.push "Scripts/module/10_name_hash.rb"
scripts.push "Scripts/module/11_audio.rb"
scripts.push "Scripts/module/12_extend.rb"
scripts.push "Scripts/module/13_scene_map_fiber.rb"
scripts.push "Scripts/module/17_game_const_manager.rb"
scripts.push "Scripts/module/18_wegameSDK.rb" if $isWegame
scripts.push "Scripts/module/19_bug_report.rb"
scripts.push "Scripts/game/01_game_temp.rb"
scripts.push "Scripts/game/02_game_system.rb"
scripts.push "Scripts/game/03_game_timer.rb"
scripts.push "Scripts/game/04_game_message.rb"
scripts.push "Scripts/game/05_game_switches.rb"
scripts.push "Scripts/game/06_game_variables.rb"
scripts.push "Scripts/game/07_game_self_switches.rb"
scripts.push "Scripts/game/08_game_screen.rb"
scripts.push "Scripts/game/09_game_picture.rb"
scripts.push "Scripts/game/10_game_pictures.rb"
scripts.push "Scripts/game/11_base_item.rb"
scripts.push "Scripts/game/12_game_action.rb"
scripts.push "Scripts/game/13_game_action_result.rb"
scripts.push "Scripts/game/14_game_battler_base.rb"
scripts.push "Scripts/game/15_game_battler.rb"
scripts.push "Scripts/game/16_game_actor.rb"
scripts.push "Scripts/game/17_game_enemy.rb"
scripts.push "Scripts/game/18_game_actors.rb"
scripts.push "Scripts/game/19_game_unit.rb"
scripts.push "Scripts/game/20_game_party.rb"
scripts.push "Scripts/game/21_game_troop.rb"
scripts.push "Scripts/game/22_game_map.rb"
scripts.push "Scripts/game/23_game_comment_event.rb"
scripts.push "Scripts/game/24_game_character_base.rb"
scripts.push "Scripts/game/25_game_character.rb"
scripts.push "Scripts/game/26_game_player.rb"
scripts.push "Scripts/game/27_game_follower.rb"
scripts.push "Scripts/game/28_game_followers.rb"
scripts.push "Scripts/game/29_game_vehicle.rb"
scripts.push "Scripts/game/30_game_event.rb"
scripts.push "Scripts/game/31_game_interpreter.rb"
scripts.push "Scripts/game/32_game_user.rb"
scripts.push "Scripts/sprite/01_sprite_base.rb"
scripts.push "Scripts/sprite/02_sprite_character.rb"
scripts.push "Scripts/sprite/03_sprite_battler.rb"
scripts.push "Scripts/sprite/04_sprite_picture.rb"
scripts.push "Scripts/sprite/05_sprite_timer.rb"
scripts.push "Scripts/sprite/06_spriteset_weather.rb"
scripts.push "Scripts/sprite/07_spriteset_map.rb"
scripts.push "Scripts/sprite/08_spriteset_battle.rb"
scripts.push "Scripts/sprite/11_sprite_damage.rb"
scripts.push "Scripts/sprite/12a_sprite_tip.rb"
scripts.push "Scripts/sprite/12b_sprite_battle_tip.rb"
scripts.push "Scripts/sprite/13_sprite_web_notice.rb"
scripts.push "Scripts/window/01_window_base.rb"
scripts.push "Scripts/window/02_window_selectable.rb"
scripts.push "Scripts/window/03_window_command.rb"
scripts.push "Scripts/window/04_window_horz_command.rb"
scripts.push "Scripts/window/05_window_help.rb"
scripts.push "Scripts/window/06_window_gold.rb"
scripts.push "Scripts/window/07_window_menu_command.rb"
scripts.push "Scripts/window/08_window_menu_status.rb"
scripts.push "Scripts/window/09_window_menu_actor.rb"
scripts.push "Scripts/window/10_window_item_category.rb"
scripts.push "Scripts/window/11_window_item_list.rb"
scripts.push "Scripts/window/12_window_item.rb"
scripts.push "Scripts/window/13_window_skill_command.rb"
scripts.push "Scripts/window/14_window_skill_status.rb"
scripts.push "Scripts/window/15_window_skill_list.rb"
scripts.push "Scripts/window/15a_window_jm_list.rb"
scripts.push "Scripts/window/16_window_equip_status.rb"
scripts.push "Scripts/window/17_window_equip_command.rb"
scripts.push "Scripts/window/18_window_equip_slot.rb"
scripts.push "Scripts/window/19_window_equip_item.rb"
scripts.push "Scripts/window/20_window_status.rb"
scripts.push "Scripts/window/20a_Window_expbook.rb"
scripts.push "Scripts/window/21_window_save_file.rb"
scripts.push "Scripts/window/22_window_shop_command.rb"
scripts.push "Scripts/window/23_window_shop_buy.rb"
scripts.push "Scripts/window/24_window_shop_sell.rb"
scripts.push "Scripts/window/25_window_shop_number.rb"
scripts.push "Scripts/window/26_window_shop_status.rb"
scripts.push "Scripts/window/27_window_name_edit.rb"
scripts.push "Scripts/window/28_window_name_input.rb"
scripts.push "Scripts/window/29_window_choice_list.rb"
scripts.push "Scripts/window/30_window_number_input.rb"
scripts.push "Scripts/window/31_window_key_item.rb"
scripts.push "Scripts/window/32_window_message.rb"
scripts.push "Scripts/window/33_window_scrool_text.rb"
scripts.push "Scripts/window/34_window_map_name.rb"
scripts.push "Scripts/window/35_window_battle_log.rb"
scripts.push "Scripts/window/36_window_party_command.rb"
scripts.push "Scripts/window/37_window_actor_command.rb"
scripts.push "Scripts/window/38_window_battle_status.rb"
scripts.push "Scripts/window/38_window_battle_status_enemy.rb"
scripts.push "Scripts/window/39_window_battle_actor.rb"
scripts.push "Scripts/window/40_window_battle_enemy.rb"
scripts.push "Scripts/window/41_window_battle_skill.rb"
scripts.push "Scripts/window/42_window_battle_item.rb"
scripts.push "Scripts/window/43_window_title_command.rb"
scripts.push "Scripts/window/44_window_game_end.rb"
scripts.push "Scripts/window/45_window_debug_left.rb"
scripts.push "Scripts/window/46_window_debug_right.rb"
scripts.push "Scripts/window/47_window_mapstatus.rb"
scripts.push "Scripts/window/48_window_minimap.rb"
scripts.push "Scripts/scene/01_scene_base.rb"
scripts.push "Scripts/scene/01a_scene_loading.rb"
scripts.push "Scripts/scene/02_scene_title.rb"
scripts.push "Scripts/scene/03_scene_map.rb"
scripts.push "Scripts/scene/04_scene_menu_base.rb"
scripts.push "Scripts/scene/05_scene_menu.rb"
scripts.push "Scripts/scene/06_scene_item_base.rb"
scripts.push "Scripts/scene/07_scene_cj.rb"
scripts.push "Scripts/scene/07_scene_item.rb"
scripts.push "Scripts/scene/08_scene_skill.rb"
scripts.push "Scripts/scene/08a_scene_marv.rb"
scripts.push "Scripts/scene/09_scene_equip.rb"
scripts.push "Scripts/scene/10_scene_status.rb"
scripts.push "Scripts/scene/11_scene_file.rb"
scripts.push "Scripts/scene/12_scene_save.rb"
scripts.push "Scripts/scene/13_scene_load.rb"
scripts.push "Scripts/scene/14_scene_end.rb"
scripts.push "Scripts/scene/15_scene_shop.rb"
scripts.push "Scripts/scene/16_scene_name.rb"
scripts.push "Scripts/scene/17_scene_debug.rb"
scripts.push "Scripts/scene/18_scene_battle.rb"
scripts.push "Scripts/scene/18_scene_battle_over_list.rb"
scripts.push "Scripts/scene/18_scene_battle_turn.rb"
scripts.push "Scripts/scene/19_scene_gameover.rb"
scripts.push "Scripts/scene/20_scene_formation.rb"
scripts.push "Scripts/scene/21_scene_actor_house.rb"
scripts.push "Scripts/scene/21a_scene_jm.rb"
scripts.push "Scripts/scene/21b_scene_expbook.rb"
scripts.push "Scripts/scene/22_scene_skill_graph.rb"
scripts.push "Scripts/scene/23_scene_forging.rb"
scripts.push "Scripts/scene/24_scene_system.rb"
scripts.push "Scripts/scene/25_scene_score.rb"
scripts.push "Scripts/outer/01_easy_conv.rb"
scripts.push "Scripts/outer/05_mn_Light.rb"
scripts.push "Scripts/01_fix_bitmap.rb"
scripts.push "Scripts/98_plugins.rb"

scripts.each do |script|
  if $TEST
    #p script
    
    load(script)

    # REMARK 临时测试用
    # File.open(script,"rb") do |f|
    #   eval(f.read)
    # end

  else
    File.open(script,"rb") do |f|
      eval(f.read)
    end
  end
end

# class Bitmap
#   alias ori_initialize initialize
#   def initialize *args
#     @args = args
#     ori_initialize *args
#   end

#   def args
#     @args
#   end
# end


if $TEST
  rgss_main { SceneManager.run }
else
  begin
    rgss_main { SceneManager.run }
  rescue
    BugReport.shareObject.report!($!)
    exit
  end
end

