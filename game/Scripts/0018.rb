#encoding:utf-8
#==============================================================================
# ■ DataManager
#------------------------------------------------------------------------------
# 　数据库和游戏实例的管理器。所有在游戏中使用的全局变量都在这里初始化。
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # ● 模块的实例变量
  #--------------------------------------------------------------------------
  @last_savefile_index = 0                # 最后访问的存档文件

  def self.check_auth
    if $isSteamLoginTag.to_s != "929808727"
       #msgbox "[Error] Cannot connect to Steam"
       #exit
    end
  end

  #--------------------------------------------------------------------------
  # ● 初始化模块
  #--------------------------------------------------------------------------
  def self.init
    @last_savefile_index = 0
    load_database
    create_game_objects
    DataManager.load_cache_file
    setup_battle_test if $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 读取数据库
  #--------------------------------------------------------------------------
  def self.load_database
    if $BTEST
      load_battle_test_database
    else

      # TODO remove
     # bitmap = Bitmap.new("Graphics/haha")
     # bitmap.dispose

      load_normal_database
      check_player_location
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取普通的数据库
  #--------------------------------------------------------------------------
  def self.load_normal_database
    $data_actors        = load_data("Data/Actors.rvdata2")
    $data_classes       = load_data("Data/Classes.rvdata2")
    $data_skills        = load_data("Data/Skills.rvdata2")
    $data_items         = load_data("Data/Items.rvdata2")
    $data_weapons       = load_data("Data/Weapons.rvdata2")
    $data_armors        = load_data("Data/Armors.rvdata2")
    $data_enemies       = load_data("Data/Enemies.rvdata2")
    $data_troops        = load_data("Data/Troops.rvdata2")
    $data_states        = load_data("Data/States.rvdata2")
    $data_animations    = load_data("Data/Animations.rvdata2")
    $data_tilesets      = load_data("Data/Tilesets.rvdata2")
    $data_common_events = load_data("Data/CommonEvents.rvdata2")
    $data_system        = load_data("Data/System.rvdata2")
    $data_mapinfos      = load_data("Data/MapInfos.rvdata2")
  end
  #--------------------------------------------------------------------------
  # ● 读取战斗测试用的数据库
  #--------------------------------------------------------------------------
  def self.load_battle_test_database
    $data_actors        = load_data("Data/BT_Actors.rvdata2")
    $data_classes       = load_data("Data/BT_Classes.rvdata2")
    $data_skills        = load_data("Data/BT_Skills.rvdata2")
    $data_items         = load_data("Data/BT_Items.rvdata2")
    $data_weapons       = load_data("Data/BT_Weapons.rvdata2")
    $data_armors        = load_data("Data/BT_Armors.rvdata2")
    $data_enemies       = load_data("Data/BT_Enemies.rvdata2")
    $data_troops        = load_data("Data/BT_Troops.rvdata2")
    $data_states        = load_data("Data/BT_States.rvdata2")
    $data_animations    = load_data("Data/BT_Animations.rvdata2")
    $data_tilesets      = load_data("Data/BT_Tilesets.rvdata2")
    $data_common_events = load_data("Data/BT_CommonEvents.rvdata2")
    $data_system        = load_data("Data/BT_System.rvdata2")
  end
  #--------------------------------------------------------------------------
  # ● 检查玩家初始位置
  #--------------------------------------------------------------------------
  def self.check_player_location
    if $data_system.start_map_id == 0
      exit
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成各种游戏对象
  #--------------------------------------------------------------------------
  def self.create_game_objects
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_timer         = Game_Timer.new
    $game_message       = Game_Message.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new

    $game_user          = Game_User.new
    $game_test          = GameTest.new

  end
  #--------------------------------------------------------------------------
  # ● 设置新游戏
  #--------------------------------------------------------------------------
  def self.setup_new_game

    # REMARK: 二周目新游戏需重新创建
    if $op_2nd == true or $back_title
      create_game_objects 
      DataManager.load_cache_file
    end

    $game_party.setup_starting_members
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    Graphics.frame_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试
  #--------------------------------------------------------------------------
  def self.setup_battle_test
    $game_party.setup_battle_test
    BattleManager.setup($data_system.test_troop_id)
    BattleManager.play_battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● 判定存档文件是否存在
  #--------------------------------------------------------------------------
  def self.save_file_exists?
    !Dir.glob('save/s0*.sav').empty?
  end
  #--------------------------------------------------------------------------
  # ● 存档文件的最大数
  #--------------------------------------------------------------------------
  def self.savefile_max
    return 8
  end
  #--------------------------------------------------------------------------
  # ● 生成文件名
  #     index : 文件索引
  #--------------------------------------------------------------------------
  def self.make_filename(index)
    sprintf("save/s%02d.sav", index + 1)
  end
  #--------------------------------------------------------------------------
  # ● 生成文件名(备份)
  #     index : 文件索引
  #--------------------------------------------------------------------------
  def self.make_filename_bk(index)
    sprintf("savebk/s%02d.sav", index + 1)
  end

  #--------------------------------------------------------------------------
  # ● 执行存档
  #--------------------------------------------------------------------------
  def self.save_game(index)
    begin
      save_game_without_rescue(index)
    rescue
      BugReport.shareObject.report!($!) unless $TEST
      delete_save_file(index)
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 执行读档
  #--------------------------------------------------------------------------
  def self.load_game(index)
    loaded = load_game_without_rescue(index)
    DataManager.load_cache_file
    $game_system.wegame_push_achievement = {} if $game_system.wegame_push_achievement.nil?
    return loaded
  end
  #--------------------------------------------------------------------------
  # ● 读取存档的头数据
  #--------------------------------------------------------------------------
  def self.load_header(index)
    load_header_without_rescue(index) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 执行存档（没有错误处理）
  #--------------------------------------------------------------------------
  def self.save_game_without_rescue(index)
    file_arr = [ make_filename(index) ]
    if Dir.exist?("savebk")
      file_arr.push(make_filename_bk(index))
    end
    file_arr.each do |fn|
      File.open(fn, "wb") do |file|
        $game_system.on_before_save
        Marshal.dump(make_save_header, file)
        Marshal.dump(make_save_contents, file)
        @last_savefile_index = index
      end
    end
    save_cache_file
    return true
  end
  #--------------------------------------------------------------------------
  # ● 缓存文件(save)
  #--------------------------------------------------------------------------
  def self.save_cache_file
    fn = "_twkcache.tobj"
    arr = [
      $game_switches[437],
      $game_switches[S::CV],
      $game_switches[S::BATTLE_EFFECT],
      $game_switches[S::CNAME],
      $game_switches[S::JUMP_AU],
      $game_switches[S::AUTO_SAVE],
      $game_switches[742]
    ]
    $game_system.system_menu_config[:other_setting] = arr

    File.open(fn,"wb") do |file|
      Marshal.dump($game_system.system_menu_config, file)
    end
  end
  #--------------------------------------------------------------------------
  # ● 缓存文件(load)
  #--------------------------------------------------------------------------
  def self.load_cache_file
    fn = "_twkcache.tobj"
    return unless File.exist?(fn)
    File.open(fn, "rb") do |file|
      $game_system.system_menu_config = Marshal.load(file)
    end
    arr = $game_system.system_menu_config[:other_setting]
    if arr
      $game_switches[437] = arr[0]
      $game_switches[S::CV] = arr[1]
      $game_switches[S::BATTLE_EFFECT] = arr[2]
      $game_switches[S::CNAME] = arr[3]
      $game_switches[S::JUMP_AU] = arr[4]
      $game_switches[S::AUTO_SAVE] = arr[5]
      $game_switches[742] = arr[6]
    end
  end
  #--------------------------------------------------------------------------
  # ● 执行读档（没有错误处理）
  #--------------------------------------------------------------------------
  def self.load_game_without_rescue(index)
    save_file_name = make_filename(index)
    return unless File.exist?(save_file_name)
    File.open(save_file_name, "rb") do |file|
      Marshal.load(file)
      extract_save_contents(Marshal.load(file))
      reload_map_if_updated
      @last_savefile_index = index
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 读取存档的头数据（没有错误处理）
  #--------------------------------------------------------------------------
  def self.load_header_without_rescue(index)
    save_file_name = make_filename(index)
    return unless File.exist?(save_file_name)
    File.open(make_filename(index), "rb") do |file|
      return Marshal.load(file)
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 删除存档文件
  #--------------------------------------------------------------------------
  def self.delete_save_file(index)
    File.delete(make_filename(index)) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 生成存档的头数据
  #--------------------------------------------------------------------------
  def self.make_save_header
    header = {}
    header[:characters] = $game_party.characters_for_savefile
    header[:playtime_s] = $game_system.playtime_s
    header[:actors] = $game_party.actors_for_savefile
    header[:stage] =  $game_variables[230]
    header[:zaoyi] = $game_variables[222]
    header[:nd] = $game_switches[700]
    header[:nd_size] = $game_variables[270]
    header
  end
  #--------------------------------------------------------------------------
  # ● 生成存档内容
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = {}
    contents[:system]        = $game_system
    contents[:timer]         = $game_timer
    contents[:message]       = $game_message
    contents[:switches]      = $game_switches
    contents[:variables]     = $game_variables
    contents[:self_switches] = $game_self_switches
    contents[:actors]        = $game_actors
    contents[:party]         = $game_party
    contents[:troop]         = $game_troop
    contents[:map]           = $game_map
    contents[:player]        = $game_player
    contents[:game_user]     = $game_user
    contents
  end
  #--------------------------------------------------------------------------
  # ● 展开存档内容
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    $game_system        = contents[:system]
    $game_timer         = contents[:timer]
    $game_message       = contents[:message]
    $game_switches      = contents[:switches]
    $game_variables     = contents[:variables]
    $game_self_switches = contents[:self_switches]
    $game_actors        = contents[:actors]
    $game_party         = contents[:party]
    $game_troop         = contents[:troop]
    $game_map           = contents[:map]
    $game_player        = contents[:player]
    $game_user          = contents[:game_user]
    $game_system.load_custom_config
  end
  #--------------------------------------------------------------------------
  # ● 如果数据已更新则重载地图
  #--------------------------------------------------------------------------
  def self.reload_map_if_updated
    if $game_system.version_id != $data_system.version_id
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
      $game_player.make_encounter_count
    end
    #$game_player.move_speed = 5
  end
  #--------------------------------------------------------------------------
  # ● 获取存档文件时间戳
  #--------------------------------------------------------------------------
  def self.savefile_time_stamp(index)
    File.mtime(make_filename(index)) rescue Time.at(0)
  end
  #--------------------------------------------------------------------------
  # ● 获取“最后更新的存档文件”的索引
  #--------------------------------------------------------------------------
  def self.latest_savefile_index
    savefile_max.times.max_by {|i| savefile_time_stamp(i) }
  end
  #--------------------------------------------------------------------------
  # ● 获取“最后访问的存档文件”的索引
  #--------------------------------------------------------------------------
  def self.last_savefile_index
    @last_savefile_index
  end
  #--------------------------------------------------------------------------
  # ● 保存下周目
  #--------------------------------------------------------------------------
  def self.save_to_next_newgame params

    contents = {}
    contents[:system]        = Game_System.new
    contents[:timer]         = Game_Timer.new
    contents[:message]       = Game_Message.new
    contents[:switches]      = Game_Switches.new
    contents[:variables]     = Game_Variables.new
    contents[:self_switches] = Game_SelfSwitches.new
    contents[:actors]        = Game_Actors.new
    contents[:party]         = Game_Party.new
    contents[:troop]         = Game_Troop.new
    contents[:map]           = Game_Map.new
    contents[:player]        = Game_Player.new
    contents[:user]          = Game_User.new
    contents[:sk_graph]      = SkGraph.dump

    contents[:system].save_count += 1
    contents[:system].frames_on_save = $data_system.version_id
    contents[:system].version_id = Graphics.frame_count

    # 加入初始化同伴
    contents[:party].setup_starting_members
    contents[:map].setup($data_system.start_map_id)
    contents[:player].moveto($data_system.start_x, $data_system.start_y)

    # 继承造诣
    # game_clear = {}
    # game_clear[:]

    # 1.5倍经验

    # 等级上限至60级

    # 特殊道具凤凰羽衣

    # 是否获得吕布

    # 是否获得张角

    # 野外遇敌加强

    

    header = {}
    header[:characters] = contents[:party].characters_for_savefile
    header[:playtime_s] = contents[:system].playtime_s
    header

    File.open(make_filename(@last_savefile_index), "wb") do |file|
      Marshal.dump(header, file)
      Marshal.dump(contents, file)
    end

  end

end
