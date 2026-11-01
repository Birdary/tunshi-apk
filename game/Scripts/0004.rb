#encoding:utf-8
module WegameSDK

  SDK_UPDATE_EVENT = Win32API.new('game.exe', '__wegame_event_update', 'v', 'v')
  SDK_SET_Achievement = Win32API.new('game.exe', '__wegame_set_achievement', 'p', 'i')

  module_function

  @@count = 0

  def updateEvent
    @@count += 1
    @@count = 0 if @@count > 10000

    if @@count % 300 == 0
      SDK_UPDATE_EVENT.call
    end
  end

  def setAchievement(name)
    SDK_SET_Achievement.call(name)
    $game_system.wegame_push_achievement[name] = false
  end

end

