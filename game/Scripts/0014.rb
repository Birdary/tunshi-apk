#encoding:utf-8
module Audio
  @@method_bgm_play = method(:bgm_play)
  @@method_se_play = method(:se_play)
  @@method_me_play = method(:me_play)
  @@method_bgs_play = method(:bgs_play)

	def self.bgm_play(*args)
    if $game_system
      volume = $game_system.system_menu_config[:bgm_volume] || 100
    else
      volume = 90
    end
    ori_volume = args[1].blank? ? 100 : args[1]
    volume = (ori_volume * (volume / 100.to_f)).to_i
    @@method_bgm_play.call(args[0],volume,args[2] || 100)
	end

  def self.se_play(*args)
    if $game_system
      volume = $game_system.system_menu_config[:se_volume] || 100
    else
      volume = 100
    end
    ori_volume = args[1].blank? ? 100 : args[1]
    volume = (ori_volume * (volume / 100.to_f)).to_i
    @@method_se_play.call(args[0],volume,args[2] || 100)
  end


  def self.me_play(*args)
    if $game_system
      volume = $game_system.system_menu_config[:se_volume] || 100
    else
      volume = 100
    end
    ori_volume = args[1].blank? ? 100 : args[1]
    volume = (ori_volume * (volume / 100.to_f)).to_i
    @@method_me_play.call(args[0],volume,args[2] || 100)
  end

  def self.bgs_play(*args)
    if $game_system
      volume = $game_system.system_menu_config[:se_volume] || 100
    else
      volume = 100
    end
    ori_volume = args[1].blank? ? 100 : args[1]
    volume = (ori_volume * (volume / 100.to_f)).to_i
    @@method_bgs_play.call(args[0],volume,args[2] || 100)
  end
end