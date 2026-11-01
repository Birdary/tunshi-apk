# module Mouse
  
#   module_function
  
#   KeyHash = {:l=>0x1, :m=>0x4, :r=>0x2}

#   $mouse_x = 0
#   $mouse_y = 0
  
#   RgssxSetCursor  = Win32API.new(App.app_path_s, "__rgssx_set_cursor", "l", "l")
#   LoadCursor      = Win32API.new("user32", "LoadCursor", "ll", "l")
#   GetModuleHandle = Win32API.new("kernel32", "GetModuleHandle", "l", "l")

#   @cursor_hash    = {}
  
#   def set_cursor
#     # RgssxSetCursor.call(@cursor_hash[@curr_cursor_type].to_cursor)
#     RgssxSetCursor.call(@cursor_hash[@curr_cursor_type])
#   end

#   #--------------------------------------------------------------------------
#   # ● 设置游戏光标：
#   # => cursor_type  - 光标类型（:normal、:move、:attack）
#   #--------------------------------------------------------------------------
#   def set_game_cursor(cursor_type)
#     if @curr_cursor_type != cursor_type
#       assert(@cursor_hash.include?(cursor_type))
#       @curr_cursor_type = cursor_type
#       set_cursor
#     end
#   end

#   #--------------------------------------------------------------------------
#   # ● 快捷函数 设置各类型光标
#   #--------------------------------------------------------------------------
#   def set_normal_cursor
#     set_game_cursor(:normal)
#   end

#   def set_move_cursor
#     set_game_cursor(:move)
#   end

#   def set_attack_cursor
#     set_game_cursor(:attack)
#   end

#   def set_stay_cursor
#     set_game_cursor(:stay)
#   end  

#   def curr_sursor_type
#     @curr_cursor_type
#   end
  
#   #--------------------------------------------------------------------------
#   # ● 初始化鼠标
#   #--------------------------------------------------------------------------
#   def init
#     @cursor_hash ||= {}
#     handle_exe = GetModuleHandle.call(0)
#     @cursor_hash[:normal] = LoadCursor.call(handle_exe, 105)#BitmapEx.new("Graphics/cursor")
#     @cursor_hash[:move]   = LoadCursor.call(handle_exe, 107)#BitmapEx.new("Graphics/cursor_move")
#     @cursor_hash[:attack] = LoadCursor.call(handle_exe, 106)#BitmapEx.new("Graphics/cursor_attack")
#     @cursor_hash[:stay]   = LoadCursor.call(handle_exe, 108)#BitmapEx.new("Graphics/cursor_wait")
#     # @cursor_hash.each_value{|b| b.to_cursor}
#     @curr_cursor_type = :normal
#     set_cursor
#   end
  
#   def update
#     @pos = (SampleInput::SysMouse.is_over? ? SampleInput::SysMouse.get_pos : nil)
#     if @pos.nil?
#       #$mouse_x = 0
#       #$mouse_y = 0
#     else
#       $mouse_x, $mouse_y = @pos
#     end  
#   end

#   def pos
#     return @pos
#   end

#   def area?(x, y, width, height)
#     return false if @pos.nil?
#     return false unless @pos[0].between?(x, x + width)
#     return false unless @pos[1].between?(y, y + height)
#     return true
#   end

#   def rect?(rect)
#     return area?(rect.x, rect.y, rect.width, rect.height)
#   end

#   def up?(key)
#     key = KeyHash[key] || key
#     return SampleInput.key_up?(key)
#   end

#   def down?(key)
#     key = KeyHash[key] || key
#     return SampleInput.key_down?(key)
#   end

#   def click?(key)
#     key = KeyHash[key] || key
#     return SampleInput.click?(key)
#   end

#   def dblclk?(key)
#     key = KeyHash[key] || key
#     return SampleInput::SysMouse.dblclk?(key)
#   end

#   def press?(key)
#     key = KeyHash[key] || key
#     return SampleInput.press?(key)
#   end

#   def scroll
#     return SampleInput::SysMouse.wheel_delta
#   end

#   def set_pos(x, y)
#     SampleInput::SysMouse.set_pos(x, y)
#   end

# end