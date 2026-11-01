#encoding:utf-8
# #============================================================================
# # ■ Graphics
# #----------------------------------------------------------------------------
# #   RGSS内部默认图像模块补充定义。
# #============================================================================ 
# class << Graphics
  
#   alias __redefine_origin_update update unless method_defined? :__redefine_origin_update
  
#   def update
#     __redefine_origin_update
#     Audio.update
#   end
 
# end
  
# #============================================================================
# # ■ Input
# #----------------------------------------------------------------------------
# #   RGSS内部默认的输入模块重定义。
# #============================================================================ 
# class << Input
  
#   alias rgssx_origin_update update      unless method_defined? :rgssx_origin_update
#   alias rgssx_origin_press? press?      unless method_defined? :rgssx_origin_press?
#   alias rgssx_origin_trigger? trigger?  unless method_defined? :rgssx_origin_trigger?
#   alias rgssx_origin_repeat? repeat?    unless method_defined? :rgssx_origin_repeat?
#   alias rgssx_origin_dir4 dir4          unless method_defined? :rgssx_origin_dir4
#   alias rgssx_origin_dir8 dir8          unless method_defined? :rgssx_origin_dir8

#   def update
#     rgssx_origin_update
#     ENC::SampleInput.update
#     ENC::Mouse.update
#   end

#   def press?(num)
#     return (ENC::SampleInput.focus? and rgssx_origin_press?(num))
#   end
  
#   def trigger?(num)
#     return (ENC::SampleInput.focus? and rgssx_origin_trigger?(num))
#   end
  
#   def repeat?(num)
#     return (ENC::SampleInput.focus? and rgssx_origin_repeat?(num))
#   end
  
#   def dir4
#     return (ENC::SampleInput.focus? ? rgssx_origin_dir4 : 0)
#   end
  
#   def dir8
#     return (ENC::SampleInput.focus? ? rgssx_origin_dir8 : 0)
#   end

# end

# # #============================================================================
# # # ■ Audio
# # #----------------------------------------------------------------------------
# # #   RGSS内部默认的音频模块重定义。
# # #============================================================================
# # class << Audio

# #   #--------------------------------------------------------------------------
# #   # ● 播放函数重定义
# #   #--------------------------------------------------------------------------  
# #   alias rgssx_origin_bgm_play bgm_play  unless method_defined? :rgssx_origin_bgm_play
# #   alias rgssx_origin_bgs_play bgs_play  unless method_defined? :rgssx_origin_bgs_play
# #   alias rgssx_origin_me_play me_play    unless method_defined? :rgssx_origin_me_play
# #   alias rgssx_origin_se_play se_play    unless method_defined? :rgssx_origin_se_play
  
# #   #--------------------------------------------------------------------------
# #   # ● 停止函数重定义
# #   #--------------------------------------------------------------------------   
# #   alias rgssx_origin_bgm_stop bgm_stop  unless method_defined? :rgssx_origin_bgm_stop
# #   alias rgssx_origin_bgs_stop bgs_stop  unless method_defined? :rgssx_origin_bgs_stop
# #   #--------------------------------------------------------------------------
# #   # ● 淡出函数重定义
# #   #--------------------------------------------------------------------------  
# #   alias rgssx_origin_bgm_fade bgm_fade  unless method_defined? :rgssx_origin_bgm_fade
# #   alias rgssx_origin_bgs_fade bgs_fade  unless method_defined? :rgssx_origin_bgs_fade

# #   #--------------------------------------------------------------------------
# #   # ● 支持音乐静音相关数据定义
# #   #--------------------------------------------------------------------------  
# #   class AudioObject
    
# #     def initialize(name = "", volume = 100, pitch = 100, *rest)
# #       @name   = name
# #       @volume = volume
# #       @pitch  = pitch
# #       @rest   = rest
# #     end
    
# #     attr_accessor :name     # => 文件名
# #     attr_accessor :volume   # => 音量
# #     attr_accessor :pitch    # => 节拍
# #     attr_reader   :rest     # => 剩余参数（RM个版本不同，可能还有其他参数，比如ACE里的pos）

# #     def empty?
# #       return @name.empty?
# #     end

# #   end
  
# #   #--------------------------------------------------------------------------
# #   # ● [常量]  音乐鉴赏时插入播放的BGM淡出的时间
# #   #--------------------------------------------------------------------------   
# #   INSERT_BGM_FADE_TIME  = 3000

# #   module ::Audio

# #     @playing_bgm        = AudioObject.new
# #     @playing_bgs        = AudioObject.new
# #     @insert_bgm         = nil

# #     @bgm_volume         = ENC::Config::DefaultBGMVolume
# #     @se_volume          = ENC::Config::DefaultSEVolume

# #   end

# #   def insert_music?
# #     return @insert_bgm != nil
# #   end

# #   def set_continue_music(filename, volume = 100, pitch = 100)
# #     return unless insert_music?
# #     @playing_bgm = AudioObject.new(filename, volume, pitch)
# #   end

# #   #--------------------------------------------------------------------------
# #   # ● 获取全局音乐音效的音量大小
# #   #-------------------------------------------------------------------------- 
# #   def bgm_volume
# #     @bgm_volume
# #   end

# #   def se_volume
# #     @se_volume
# #   end

# #   #--------------------------------------------------------------------------
# #   # ● 调整全局BGM、BGS音量大小
# #   #--------------------------------------------------------------------------   
# #   def bgm_volume=(v)
# #     return if @bgm_volume == v
# #     @bgm_volume = v
# #     if @insert_bgm
# #       insert_bgm_play_normal(@insert_bgm)
# #     else
# #       bgm_play(@playing_bgm)
# #     end
# #     bgs_play(@playing_bgs)
# #   end

# #   #--------------------------------------------------------------------------
# #   # ● 调整全局SE、ME音量大小
# #   #-------------------------------------------------------------------------- 
# #   def se_volume=(v)
# #     return if @se_volume == v
# #     @se_volume = v
# #     if @se_volume == 0
# #       me_stop
# #       se_stop
# #     end    
# #   end

# #   #--------------------------------------------------------------------------
# #   # ● 获取实际的音量大小
# #   #--------------------------------------------------------------------------  
# #   def get_bgm_real_volume(origin_volume)
# #     return (origin_volume * @bgm_volume / 100.0).round
# #   end
# #   private :get_bgm_real_volume

# #   def get_se_real_volume(origin_volume)
# #     return (origin_volume * @se_volume / 100.0).round
# #   end
# #   private :get_se_real_volume

# #   #--------------------------------------------------------------------------
# #   # ● 插入中的BGM淡出
# #   # => time   - 淡出毫秒数
# #   # => t      - 淡出时时刻
# #   #--------------------------------------------------------------------------
# #   def insert_bgm_fade(time, t = nil)
# #     assert(@insert_bgm)
# #     return if @insert_bgm.e[:fadeout]
# #     rgssx_origin_bgm_fade(time)
# #     @insert_bgm.e[:fadeout]   = true            # => 设置淡出中标记
# #     @insert_bgm.e[:fadems]    = time            # => 淡出所用时间
# #     @insert_bgm.e[:fadetime]  = (t || Time.now) # => 开始淡出的时间
# #   end
# #   private :insert_bgm_fade

# #   #--------------------------------------------------------------------------
# #   # ● 更新插入中的BGM
# #   #--------------------------------------------------------------------------
# #   def update
# #     if @insert_bgm
# #       # => 获取当前时间
# #       now = Time.now
# #       # => 计算已经播放了的毫秒数
# #       dt = (now - @insert_bgm.e[:start_time]) * 1000
# #       # => BGM不在淡出中并且离播放结束剩下不到1000毫秒时开始淡出
# #       if !@insert_bgm.e[:fadeout] and dt >= @insert_bgm.e[:millsecond] - INSERT_BGM_FADE_TIME
# #         insert_bgm_fade(INSERT_BGM_FADE_TIME, now)
# #       end
# #       # => 播放结束判断（停止BGM、重新播放记忆中的BGM）
# #       if dt >= @insert_bgm.e[:millsecond]
# #         rgssx_origin_bgm_stop
# #         @insert_bgm = nil
# #         bgm_play(@playing_bgm)
# #         return
# #       end
# #       # => 淡出中
# #       if ft = @insert_bgm.e[:fadetime]
# #         # => 淡出时间已经经过（则停止插入中BGM播放、还原原来的BGM）
# #         if (now - ft) * 1000 >= @insert_bgm.e[:fadems]
# #           rgssx_origin_bgm_stop
# #           @insert_bgm = nil
# #           bgm_play(@playing_bgm)
# #           return
# #         end
# #       end
# #     end
# #   end

# #   #--------------------------------------------------------------------------
# #   # ● 播放插入中BGM（不设置任何参数）
# #   #--------------------------------------------------------------------------
# #   def insert_bgm_play_normal(bgm)
# #     return if bgm.nil? || bgm.empty?
# #     # => 设置播放参数
# #     args = []
# #     args[0] = bgm.name
# #     args[1] = get_bgm_real_volume(bgm.volume)
# #     args[2] = bgm.pitch
# #     bgm.rest.each_with_index{|value, index| args[3 + index] = value}
# #     # => 正常播放
# #     rgssx_origin_bgm_play(*args)
# #   end
# #   private :insert_bgm_play_normal

# #   #--------------------------------------------------------------------------
# #   # ● 插入BGM播放，在经过seconds秒后返回原来播放的BGM。
# #   # => 在新BGM播放途中如果再次有BGM播放，插入的BGM会被取消掉。
# #   #--------------------------------------------------------------------------
# #   def insert_bgm_play(seconds, *args)
# #     @insert_bgm = AudioObject.new(*args)
# #     return if @insert_bgm.empty?
# #     # => 设置播放参数
# #     args[0] = @insert_bgm.name
# #     args[1] = get_bgm_real_volume(@insert_bgm.volume)
# #     args[2] = @insert_bgm.pitch
# #     @insert_bgm.rest.each_with_index{|value, index| args[3 + index] = value}
# #     # => 先停止先前的再播放
# #     rgssx_origin_bgm_stop    
# #     # => 正常播放
# #     rgssx_origin_bgm_play(*args)
# #     # => 记忆参数（音乐总时长-单位毫秒、开始播放时间、是否在淡出中标记）
# #     @insert_bgm.e[:millsecond]  = seconds * 1000
# #     @insert_bgm.e[:start_time]  = Time.now
# #     @insert_bgm.e[:fadeout]     = false
# #   end

# #   def bgm_play(*args)
# #     # => 清除插入中BGM
# #     @insert_bgm = nil
# #     # => 处理静音部分
# #     @playing_bgm = AudioObject.new(*args) unless args.first.is_a?(AudioObject)
# #     if @playing_bgm.empty?
# #       bgm_stop
# #       return
# #     end
# #     args[0] = @playing_bgm.name
# #     args[1] = get_bgm_real_volume(@playing_bgm.volume)
# #     args[2] = @playing_bgm.pitch
# #     @playing_bgm.rest.each_with_index{|value, index| args[3 + index] = value}
# #     # => 正常播放
# #     rgssx_origin_bgm_play(*args)   
# #   end
  
# #   def bgs_play(*args)
# #     # => 处理静音部分
# #     @playing_bgs = AudioObject.new(*args) unless args.first.is_a?(AudioObject)
# #     if @playing_bgs.empty?
# #       bgs_stop
# #       return
# #     end
# #     args[0] = @playing_bgs.name
# #     args[1] = get_bgm_real_volume(@playing_bgs.volume)
# #     args[2] = @playing_bgs.pitch
# #     @playing_bgs.rest.each_with_index{|value, index| args[3 + index] = value}
# #     # => 正常播放    
# #     rgssx_origin_bgs_play(*args)    
# #   end
  
# #   def me_play(*args)
# #     # => 处理无效参数
# #     if args.first.empty?
# #       me_stop
# #       return
# #     end
# #     # => 调整音量
# #     args[1] = get_se_real_volume(args[1] || 100)
# #     if args[1].zero?
# #       me_stop
# #       return
# #     end 
# #     # => 正常播放
# #     rgssx_origin_me_play(*args)
# #   end
  
# #   def se_play(*args)
# #     # => 处理无效参数
# #     if args.first.empty?
# #       se_stop
# #       return
# #     end
# #     # => 调整音量
# #     args[1] = get_se_real_volume(args[1] || 100)
# #     if args[1].zero?
# #       se_stop
# #       return
# #     end    
# #     # => 正常播放      
# #     rgssx_origin_se_play(*args)     
# #   end
  
# #   def bgm_stop
# #     @insert_bgm = nil    
# #     @playing_bgm = AudioObject.new
# #     rgssx_origin_bgm_stop
# #   end
  
# #   def bgs_stop
# #     @playing_bgs = AudioObject.new
# #     rgssx_origin_bgs_stop
# #   end

# #   def bgm_fade(time)
# #     @playing_bgm = AudioObject.new
# #     if @insert_bgm
# #       insert_bgm_fade(time)
# #     else
# #       rgssx_origin_bgm_fade(time)
# #     end
# #   end
  
# #   def bgs_fade(time)
# #     @playing_bgs = AudioObject.new
# #     rgssx_origin_bgs_fade(time)
# #   end

# # end

# #============================================================================
# # ■ Audio
# #----------------------------------------------------------------------------
# #   RGSS内部默认的音频模块重定义。
# #============================================================================
# class << Audio

#   XAUDIO_NO_ERROR         = 0   # => 正常
#   XAUDIO_PLAY_FAILED      = 1   # => 播放失败
#   XAUDIO_FILE_NOT_FOUND   = 2   # => 文件未找到
#   XAUDIO_NOT_INIT         = 3   # => 声音引擎未正常初始化！

#   API_BGM_PLAY            = Win32API.new(App.app_path_s, "__rgssx_audio_bgm_play", "pii", "i")
#   API_BGM_STOP            = Win32API.new(App.app_path_s, "__rgssx_audio_bgm_stop", "v", "v")
#   API_BGM_FADE            = Win32API.new(App.app_path_s, "__rgssx_audio_bgm_fade", "i", "v")

#   API_BGS_PLAY            = Win32API.new(App.app_path_s, "__rgssx_audio_bgs_play", "pii", "i")
#   API_BGS_STOP            = Win32API.new(App.app_path_s, "__rgssx_audio_bgs_stop", "v", "v")
#   API_BGS_FADE            = Win32API.new(App.app_path_s, "__rgssx_audio_bgs_fade", "i", "v")

#   API_ME_PLAY             = Win32API.new(App.app_path_s, "__rgssx_audio_me_play", "pii", "i")
#   API_ME_STOP             = Win32API.new(App.app_path_s, "__rgssx_audio_me_stop", "v", "v")

#   API_SE_PLAY             = Win32API.new(App.app_path_s, "__rgssx_audio_se_play", "pii", "i")
#   API_SE_STOP             = Win32API.new(App.app_path_s, "__rgssx_audio_se_stop", "v", "v")

#   API_AUDIO_UPDATE        = Win32API.new(App.app_path_s, "__rgssx_audio_update", "v", "v")

#   # #--------------------------------------------------------------------------
#   # # ● 播放函数重定义
#   # #--------------------------------------------------------------------------  
#   # alias rgssx_origin_bgm_play bgm_play  unless method_defined? :rgssx_origin_bgm_play
#   # alias rgssx_origin_bgs_play bgs_play  unless method_defined? :rgssx_origin_bgs_play
#   # alias rgssx_origin_me_play me_play    unless method_defined? :rgssx_origin_me_play
#   # alias rgssx_origin_se_play se_play    unless method_defined? :rgssx_origin_se_play
  
#   # #--------------------------------------------------------------------------
#   # # ● 停止函数重定义
#   # #--------------------------------------------------------------------------   
#   # alias rgssx_origin_bgm_stop bgm_stop  unless method_defined? :rgssx_origin_bgm_stop
#   # alias rgssx_origin_bgs_stop bgs_stop  unless method_defined? :rgssx_origin_bgs_stop
#   # #--------------------------------------------------------------------------
#   # # ● 淡出函数重定义
#   # #--------------------------------------------------------------------------  
#   # alias rgssx_origin_bgm_fade bgm_fade  unless method_defined? :rgssx_origin_bgm_fade
#   # alias rgssx_origin_bgs_fade bgs_fade  unless method_defined? :rgssx_origin_bgs_fade

#   def rgssx_origin_check_retv(retv, filename)
#     return if retv == XAUDIO_NO_ERROR || retv == XAUDIO_NOT_INIT
#     raise format("播放音乐`%s'失败。", filename) if retv == XAUDIO_PLAY_FAILED
#     raise format("文件`%s'未找到。", filename) if retv == XAUDIO_FILE_NOT_FOUND
#   end
#   private :rgssx_origin_check_retv

#   def rgssx_origin_bgm_play(filename, volume = 100, pitch = 100)
#     rgssx_origin_check_retv(API_BGM_PLAY.call(filename, volume, pitch), filename)
#   end

#   def rgssx_origin_bgs_play(filename, volume = 100, pitch = 100)
#     rgssx_origin_check_retv(API_BGS_PLAY.call(filename, volume, pitch), filename)
#   end

#   def rgssx_origin_me_play(filename, volume = 100, pitch = 100)
#     rgssx_origin_check_retv(API_ME_PLAY.call(filename, volume, pitch), filename)
#   end

#   def rgssx_origin_se_play(filename, volume = 100, pitch = 100)
#     rgssx_origin_check_retv(API_SE_PLAY.call(filename, volume, pitch), filename)
#   end

#   def rgssx_origin_bgm_stop
#     API_BGM_STOP.call
#   end

#   def rgssx_origin_bgs_stop
#     API_BGS_STOP.call
#   end

#   def rgssx_origin_bgm_fade(*args)
#     API_BGM_FADE.call(*args)
#   end

#   def rgssx_origin_bgs_fade(*args)
#     API_BGS_FADE.call(*args)
#   end

#   def rgssx_origin_me_stop
#     API_ME_STOP.call
#   end

#   def rgssx_origin_se_stop
#     API_SE_STOP.call
#   end

#   def rgssx_origin_audio_update
#     API_AUDIO_UPDATE.call
#   end

#   def me_stop(*args)
#     rgssx_origin_me_stop(*args)
#   end

#   def me_fade(*args)
#     # => ...
#   end

#   def se_stop(*args)
#     rgssx_origin_se_stop(*args)
#   end

#   #--------------------------------------------------------------------------
#   # ● 支持音乐静音相关数据定义
#   #--------------------------------------------------------------------------  
#   class AudioObject
    
#     def initialize(name = "", volume = 100, pitch = 100, *rest)
#       @name   = name
#       @volume = volume
#       @pitch  = pitch
#       @rest   = rest
#     end
    
#     attr_accessor :name     # => 文件名
#     attr_accessor :volume   # => 音量
#     attr_accessor :pitch    # => 节拍
#     attr_reader   :rest     # => 剩余参数（RM个版本不同，可能还有其他参数，比如ACE里的pos）

#     def empty?
#       return @name.empty?
#     end

#   end
  
#   #--------------------------------------------------------------------------
#   # ● [常量]  音乐鉴赏时插入播放的BGM淡出的时间
#   #--------------------------------------------------------------------------   
#   INSERT_BGM_FADE_TIME  = 3000

#   module ::Audio

#     @playing_bgm        = AudioObject.new
#     @playing_bgs        = AudioObject.new
#     @insert_bgm         = nil

#     @bgm_volume         = ENC::Config::DefaultBGMVolume
#     @se_volume          = ENC::Config::DefaultSEVolume

#   end

#   def insert_music?
#     return @insert_bgm != nil
#   end

#   def set_continue_music(filename, volume = 100, pitch = 100)
#     return unless insert_music?
#     @playing_bgm = AudioObject.new(filename, volume, pitch)
#   end

#   #--------------------------------------------------------------------------
#   # ● 获取全局音乐音效的音量大小
#   #-------------------------------------------------------------------------- 
#   def bgm_volume
#     @bgm_volume
#   end

#   def se_volume
#     @se_volume
#   end

#   #--------------------------------------------------------------------------
#   # ● 调整全局BGM、BGS音量大小
#   #--------------------------------------------------------------------------   
#   def bgm_volume=(v)
#     return if @bgm_volume == v
#     @bgm_volume = v
#     if @insert_bgm
#       insert_bgm_play_normal(@insert_bgm)
#     else
#       bgm_play(@playing_bgm)
#     end
#     bgs_play(@playing_bgs)
#   end

#   #--------------------------------------------------------------------------
#   # ● 调整全局SE、ME音量大小
#   #-------------------------------------------------------------------------- 
#   def se_volume=(v)
#     return if @se_volume == v
#     @se_volume = v
#     if @se_volume == 0
#       me_stop
#       se_stop
#     end    
#   end

#   #--------------------------------------------------------------------------
#   # ● 获取实际的音量大小
#   #--------------------------------------------------------------------------  
#   def get_bgm_real_volume(origin_volume)
#     return (origin_volume * @bgm_volume / 100.0).round
#   end
#   private :get_bgm_real_volume

#   def get_se_real_volume(origin_volume)
#     return (origin_volume * @se_volume / 100.0).round
#   end
#   private :get_se_real_volume

#   #--------------------------------------------------------------------------
#   # ● 插入中的BGM淡出
#   # => time   - 淡出毫秒数
#   # => t      - 淡出时时刻
#   #--------------------------------------------------------------------------
#   def insert_bgm_fade(time, t = nil)
#     assert(@insert_bgm)
#     return if @insert_bgm.e[:fadeout]
#     rgssx_origin_bgm_fade(time)
#     @insert_bgm.e[:fadeout]   = true            # => 设置淡出中标记
#     @insert_bgm.e[:fadems]    = time            # => 淡出所用时间
#     @insert_bgm.e[:fadetime]  = (t || Time.now) # => 开始淡出的时间
#   end
#   private :insert_bgm_fade

#   #--------------------------------------------------------------------------
#   # ● 更新插入中的BGM
#   #--------------------------------------------------------------------------
#   def update
#     # => 更新声音系统
#     rgssx_origin_audio_update
#     # => 更新插入音乐
#     if @insert_bgm
#       # => 获取当前时间
#       now = Time.now
#       # => 计算已经播放了的毫秒数
#       dt = (now - @insert_bgm.e[:start_time]) * 1000
#       # => BGM不在淡出中并且离播放结束剩下不到1000毫秒时开始淡出
#       if !@insert_bgm.e[:fadeout] and dt >= @insert_bgm.e[:millsecond] - INSERT_BGM_FADE_TIME
#         insert_bgm_fade(INSERT_BGM_FADE_TIME, now)
#       end
#       # => 播放结束判断（停止BGM、重新播放记忆中的BGM）
#       if dt >= @insert_bgm.e[:millsecond]
#         rgssx_origin_bgm_stop
#         @insert_bgm = nil
#         bgm_play(@playing_bgm)
#         return
#       end
#       # => 淡出中
#       if ft = @insert_bgm.e[:fadetime]
#         # => 淡出时间已经经过（则停止插入中BGM播放、还原原来的BGM）
#         if (now - ft) * 1000 >= @insert_bgm.e[:fadems]
#           rgssx_origin_bgm_stop
#           @insert_bgm = nil
#           bgm_play(@playing_bgm)
#           return
#         end
#       end
#     end
#   end

#   #--------------------------------------------------------------------------
#   # ● 播放插入中BGM（不设置任何参数）
#   #--------------------------------------------------------------------------
#   def insert_bgm_play_normal(bgm)
#     return if bgm.nil? || bgm.empty?
#     # => 设置播放参数
#     args = []
#     args[0] = bgm.name
#     args[1] = get_bgm_real_volume(bgm.volume)
#     args[2] = bgm.pitch
#     bgm.rest.each_with_index{|value, index| args[3 + index] = value}
#     # => 正常播放
#     rgssx_origin_bgm_play(*args)
#   end
#   private :insert_bgm_play_normal

#   #--------------------------------------------------------------------------
#   # ● 插入BGM播放，在经过seconds秒后返回原来播放的BGM。
#   # => 在新BGM播放途中如果再次有BGM播放，插入的BGM会被取消掉。
#   #--------------------------------------------------------------------------
#   def insert_bgm_play(seconds, *args)
#     @insert_bgm = AudioObject.new(*args)
#     return if @insert_bgm.empty?
#     # => 设置播放参数
#     args[0] = @insert_bgm.name
#     args[1] = get_bgm_real_volume(@insert_bgm.volume)
#     args[2] = @insert_bgm.pitch
#     @insert_bgm.rest.each_with_index{|value, index| args[3 + index] = value}
#     # => 先停止先前的再播放
#     rgssx_origin_bgm_stop    
#     # => 正常播放
#     rgssx_origin_bgm_play(*args)
#     # => 记忆参数（音乐总时长-单位毫秒、开始播放时间、是否在淡出中标记）
#     @insert_bgm.e[:millsecond]  = seconds * 1000
#     @insert_bgm.e[:start_time]  = Time.now
#     @insert_bgm.e[:fadeout]     = false
#   end

#   def bgm_play(*args)
#     # => 清除插入中BGM
#     @insert_bgm = nil
#     # => 处理静音部分
#     @playing_bgm = AudioObject.new(*args) unless args.first.is_a?(AudioObject)
#     if @playing_bgm.empty?
#       bgm_stop
#       return
#     end
#     args[0] = @playing_bgm.name
#     args[1] = get_bgm_real_volume(@playing_bgm.volume)
#     args[2] = @playing_bgm.pitch
#     @playing_bgm.rest.each_with_index{|value, index| args[3 + index] = value}
#     # => 正常播放
#     rgssx_origin_bgm_play(*args)   
#   end
  
#   def bgs_play(*args)
#     # => 处理静音部分
#     @playing_bgs = AudioObject.new(*args) unless args.first.is_a?(AudioObject)
#     if @playing_bgs.empty?
#       bgs_stop
#       return
#     end
#     args[0] = @playing_bgs.name
#     args[1] = get_bgm_real_volume(@playing_bgs.volume)
#     args[2] = @playing_bgs.pitch
#     @playing_bgs.rest.each_with_index{|value, index| args[3 + index] = value}
#     # => 正常播放    
#     rgssx_origin_bgs_play(*args)    
#   end
  
#   def me_play(*args)
#     # => 处理无效参数
#     if args.first.empty?
#       me_stop
#       return
#     end
#     # => 调整音量
#     args[1] = get_se_real_volume(args[1] || 100)
#     if args[1].zero?
#       me_stop
#       return
#     end 
#     # => 正常播放
#     rgssx_origin_me_play(*args)
#   end
  
#   def se_play(*args)
#     # => 处理无效参数
#     if args.first.empty?
#       se_stop
#       return
#     end
#     # => 调整音量
#     args[1] = get_se_real_volume(args[1] || 100)
#     if args[1].zero?
#       se_stop
#       return
#     end    
#     # => 正常播放      
#     rgssx_origin_se_play(*args)     
#   end
  
#   def bgm_stop
#     @insert_bgm = nil    
#     @playing_bgm = AudioObject.new
#     rgssx_origin_bgm_stop
#   end
  
#   def bgs_stop
#     @playing_bgs = AudioObject.new
#     rgssx_origin_bgs_stop
#   end

#   def bgm_fade(time)
#     @playing_bgm = AudioObject.new
#     if @insert_bgm
#       insert_bgm_fade(time)
#     else
#       rgssx_origin_bgm_fade(time)
#     end
#   end
  
#   def bgs_fade(time)
#     @playing_bgs = AudioObject.new
#     rgssx_origin_bgs_fade(time)
#   end

# end