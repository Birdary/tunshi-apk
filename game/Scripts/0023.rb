#encoding:utf-8
module CN
  SkGraphCT = {
    "yq" => "勇气","bq" =>"兵权" ,"cb" =>"残暴" ,"jr" =>"精锐" ,"nh"=>"怒火","sh"=>"伤害",
    "bj" => "兵技","jz" =>"精准" ,"jq" =>"精确" ,"jh" =>"均衡" ,"jiq"=>"技巧","sn"=>"肆虐",
    "zm" => "智谋","ms" =>"谋士" ,"ns" =>"凝神" ,"jqi" =>"集气", "zq"=>"战气","cz"=>"策中",
    "bs" =>"兵", "js" =>"技速" ,"cs" =>"策速" ,"xj" =>"行军", "sb"=>"闪避","ss"=>"神速" 
  }
end

#==============================================================================
# ** Glitchfinder's Key Input Module
#    Version 1.30
#------------------------------------------------------------------------------
#  [RPG Maker XP] [RPG Maker VX] [RPG Maker VX Ace]
#------------------------------------------------------------------------------
#  This script helps scripters to use the full range of keys on any keyboard,
#  without being limited by the default Input Module.
#==============================================================================
# * Version History
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#   Version 1.00 ------------------------------------------------- (2010-03-18)
#     - Initial version
#     - Author: Glitchfinder
#    Version 1.10 ------------------------------------------------ (2010-08-20)
#      - Added the Keys.toggle? method
#      - Added the Keys.capslock? method
#      - Added the Keys.numlock? method
#      - Added the Keys.scroll? method
#      - Added the Keys.character_press method
#      - Added the Keys.character_trigger method
#      - Added the Keys.character_repeat method
#      - Added the Keys.get_character method
#      - Added the ANYKEY key constant
#      - Streamlined the script
#      - Patched various errors
#      - Author: Glitchfinder
#    Version 1.20 ------------------------------------------------ (2011-03-17)
#      - Added the Keys.array_press? method
#      - Added the Keys.array_trigger? method
#      - Added the Keys.array_repeat? method
#      - Added the Keys.array_release? method
#      - Added the Keys.array_toggle? method
#      - Modified the Keys.press? method for better error hendling
#      - Modified the Keys.trigger? method for better error hendling
#      - Modified the Keys.repeat? method for better error hendling
#      - Modified the Keys.release? method for better error hendling
#      - Modified the Keys.toggle? method for better error hendling
#      - Author: Glitchfinder
#    Version 1.30 ------------------------------------------------ (2014-02-07)
#      - Added the Keys.validate_key? method
#      - Modified the Keys.array_press? method for efficiency
#      - Modified the Keys.array_trigger? method for efficiency
#      - Modified the Keys.array_repeat? method for efficiency
#      - Modified the Keys.array_release? method for efficiency
#      - Modified the Keys.array_toggle? method for efficiency
#      - Modified the Keys.press? method to reduce unnecessary code
#      - Modified the Keys.trigger? method to reduce unnecessary code
#      - Modified the Keys.repeat? method to reduce unnecessary code
#      - Modified the Keys.release? method to reduce unnecessary code
#      - Modified the Keys.toggle? method to reduce unnecessary code
#      - Changed the license to be more open
#      - Author: Glitchfinder
#==============================================================================
# * Instructions
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#  Place this script above Main, and below the default scripts. (I realize this
#  is obvious to most, but some people don't get it.)
#
#  This module is automatically updated by the default Input module, which
#  means that the only time you need to call the update method is in a scene
#  that does not update the default Input module.
#
#  This module does not break the functionality of the default Input module.
#
#  If you wish to read keys from a gamepad, you must still use the default
#  input module to do so.
#
#  To use this module, simply use one of the four methods (press?(key),
#  trigger?(key), repeat?(key), or release?(key)), where key is the index of
#  the key you want to check. Key may also be used as Keys::KEYNAME. For a list
#  of acceptable key names, look below the header.
#
#  There is a key named ANYKEY. This key can be used like any other key, with
#  the exception that, instead of corresponding to any one key, it reacts to
#  them all. If you use it, and any other key would cause the same method to
#  return true, then the ANYKEY will also return true.
#==============================================================================
# * Method List
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#  Keys.update
#    Updates keyboard input. Calls to this method are not necessary unless the
#    default Input module is not being updated.
#
#  Keys.press?(key)
#    Determines whether the button determined by key is currently being
#    pressed. If the button is being pressed, returns true. If not, returns
#    false.
#
#  Keys.trigger?(key)
#    Determines whether the button determined by key is being pressed again.
#    "Pressed again" is seen as time having passed between the button being not
#    pressed and being pressed. If the button is being pressed, returns true.
#    If not, returns false.
#
#  Keys.repeat?(key)
#    Determines whether the button determined by key is being pressed again.
#    Unlike trigger?(), this takes into account the repeat input of a button
#    being held down continuously. If the button is being pressed, returns
#    true. If not, returns false.
#
#  Keys.release?(key)
#    Determines whether the button determined by key has just been released. If
#    the button has been released, returns true. If not, returns false.
#
#  Keys.toggle?(key)
#    Determines whether the button determined by key has been toggled. This
#    functions like Caps Lock, Number Lock, and Scroll Lock, only for all keys.
#
#  Keys.array_press?(keys)
#    Functions in the same manner as Keys.press?(), only it takes an array of
#    keys as input.
#
#  Keys.array_trigger?(keys)
#    Functions in the same manner as Keys.trigger?(), only it takes an array of
#    keys as input.
#
#  Keys.array_repeat?(keys)
#    Functions in the same manner as Keys.repeat?(), only it takes an array of
#    keys as input.
#
#  Keys.array_release?(keys)
#    Functions in the same manner as Keys.release?(), only it takes an array of
#    keys as input.
#
#  Keys.array_toggle?(keys)
#    Functions in the same manner as Keys.toggle?(), only it takes an array of
#    keys as input.
#
#  Keys.capslock?
#    Determines whether the caps lock key is toggled on. This will always
#    return true when the corresponding keyboard light is lit, and false when
#    it is not.
#
#  Keys.numlock?
#    Determines whether the number lock key is toggled on. This will always
#    return true when the corresponding keyboard light is lit, and false when
#    it is not.
#
#  Keys.scroll?
#    Determines whether the scroll lock key is toggled on. This will always
#    return true when the corresponding keyboard light is lit, and false when
#    it is not.
#
#  Keys.character_press
#    Returns the currently pressed key, if it would generate text input. If no
#    such key would register as pressed, it returns an empty string.
#
#  Keys.character_trigger
#    Returns the currently triggered key, if it would generate text input. If
#    no such key would register as triggered, it returns an empty string.
#
#  Keys.character_repeat
#    Returns the currently repeated key, if it would generate text input. If no
#    such key would register as repeated, it returns an empty string.
#
#  Keys.get_character(key, scan_code)
#    Returns the character corresponding to the given key. If no character
#    is recognized by the system, it returns false instead. This method is
#    intended for internal use.
#
#  Keys.validate_key(key)
#    Checks the validity of a key. If a key variable can be used by this
#    module, it will return true. Otherwise, it will return false.
#==============================================================================
# * Known Issues
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#  This script has trouble with certain foreign language keyboards, where dead
#  keys are shift sensitive. Dead keys are used to insert diacritical marks
#  such as an accent. However, the correct character can be generated with
#  creative use of shift and caps lock.
#==============================================================================
# * Glitchfinder's Advice
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#  This script is meant for people with a medium or advanced level of scripting
#  knowledge and ability, or for those using scripts that require this module.
#==============================================================================
# * License
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#  This script is licensed under the MIT License:
#
#  Copyright (c) 2010-2014 Sean Porter (Glitchfinder) <glitchkey@gmail.com>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#==============================================================================
 
#==============================================================================
# ** Keys
#------------------------------------------------------------------------------
#  This module performs key input processing
#==============================================================================
 
module Keys
  #--------------------------------------------------------------------------
  # * Miscellaneous Keys
  #--------------------------------------------------------------------------
  CANCEL              = 0x03 # Control-Break Processing
  BACKSPACE           = 0x08 # Backspace Key
  TAB                 = 0x09 # Tab Key
  CLEAR               = 0x0C # Clear Key
  RETURN              = 0x0D # Enter Key
  SHIFT               = 0x10 # Shift Key
  CONTROL             = 0x11 # Ctrl Key
  MENU                = 0x12 # Alt Key
  PAUSE               = 0x13 # Pause Key
  ESCAPE              = 0x1B # Esc Key
  CONVERT             = 0x1C # IME Convert Key
  NONCONVERT          = 0x1D # IME Nonconvert Key
  ACCEPT              = 0x1E # IME Accept Key
  SPACE               = 0x20 # Space Bar Key (Space, usually blank)
  PRIOR               = 0x21 # Page Up Key
  NEXT                = 0x22 # Page Down Key
  ENDS                = 0x23 # End Key
  HOME                = 0x24 # Home Key
  LEFT                = 0x25 # Left Arrow Key
  UP                  = 0x26 # Up Arrow Key
  RIGHT               = 0x27 # Right Arrow Key
  DOWN                = 0x28 # Down Arrow Key
  SELECT              = 0x29 # Select Key
  PRINT               = 0x2A # Print Key
  EXECUTE             = 0x2B # Execute Key
  SNAPSHOT            = 0x2C # Print Screen Key
  DELETE              = 0x2E # Delete Key
  HELP                = 0x2F # Help Key
  LSHIFT              = 0xA0 # Left Shift Key
  RSHIFT              = 0xA1 # Right Shift Key
  LCONTROL            = 0xA2 # Left Control Key (Ctrl)
  RCONTROL            = 0xA3 # Right Control Key (Ctrl)
  LMENU               = 0xA4 # Left Menu Key (Alt)
  RMENU               = 0xA5 # Right Menu Key (Alt)
  PACKET              = 0xE7 # Used to Pass Unicode Characters as Keystrokes
  #--------------------------------------------------------------------------
  # * Number Keys
  #--------------------------------------------------------------------------
  N0                  = 0x30 # 0 Key
  N1                  = 0x31 # 1 Key
  N2                  = 0x32 # 2 Key
  N3                  = 0x33 # 3 Key
  N4                  = 0x34 # 4 Key
  N5                  = 0x35 # 5 Key
  N6                  = 0x36 # 6 Key
  N7                  = 0x37 # 7 Key
  N8                  = 0x38 # 8 Key
  N9                  = 0x39 # 9 Key
  #--------------------------------------------------------------------------
  # * Letter Keys
  #--------------------------------------------------------------------------
  A                   = 0x41 # A Key
  B                   = 0x42 # B Key
  C                   = 0x43 # C Key
  D                   = 0x44 # D Key
  E                   = 0x45 # E Key
  F                   = 0x46 # F Key
  G                   = 0x47 # G Key
  H                   = 0x48 # H Key
  I                   = 0x49 # I Key
  J                   = 0x4A # J Key
  K                   = 0x4B # K Key
  L                   = 0x4C # L Key
  M                   = 0x4D # M Key
  N                   = 0x4E # N Key
  O                   = 0x4F # O Key
  P                   = 0x50 # P Key
  Q                   = 0x51 # Q Key
  R                   = 0x52 # R Key
  S                   = 0x53 # S Key
  T                   = 0x54 # T Key
  U                   = 0x55 # U Key
  V                   = 0x56 # V Key
  W                   = 0x57 # W Key
  X                   = 0x58 # X Key
  Y                   = 0x59 # Y Key
  Z                   = 0x5A # Z Key
  #--------------------------------------------------------------------------
  # * Windows Keys
  #--------------------------------------------------------------------------
  LWIN                = 0x5B # Left Windows Key (Natural keyboard)
  RWIN                = 0x5C # Right Windows Key (Natural Keyboard)
  APPS                = 0x5D # Applications Key (Natural keyboard)
  SLEEP               = 0x5F # Computer Sleep Key
  BROWSER_BACK        = 0xA6 # Browser Back Key
  BROWSER_FORWARD     = 0xA7 # Browser Forward Key
  BROWSER_REFRESH     = 0xA8 # Browser Refresh Key
  BROWSER_STOP        = 0xA9 # Browser Stop Key
  BROWSER_SEARCH      = 0xAA # Browser Search Key
  BROWSER_FAVORITES   = 0xAB # Browser Favorites Key
  BROWSER_HOME        = 0xAC # Browser Start and Home Key
  VOLUME_MUTE         = 0xAD # Volume Mute Key
  VOLUME_DOWN         = 0xAE # Volume Down Key
  VOLUME_UP           = 0xAF # Volume Up Key
  MEDIA_NEXT_TRACK    = 0xB0 # Next Track Key
  MEDIA_PREV_TRACK    = 0xB1 # Previous Track Key
  MEDIA_STOP          = 0xB2 # Stop Media Key
  MEDIA_PLAY_PAUSE    = 0xB3 # Play/Pause Media Key
  LAUNCH_MAIL         = 0xB4 # Start Mail Key
  LAUNCH_MEDIA_SELECT = 0xB5 # Select Media Key
  LAUNCH_APP1         = 0xB6 # Start Application 1 Key
  LAUNCH_APP2         = 0xB7 # Start Application 2 Key
  PROCESSKEY          = 0xE5 # IME Process Key
  ATTN                = 0xF6 # Attn Key
  CRSEL               = 0xF7 # CrSel Key
  EXSEL               = 0xF8 # ExSel Key
  EREOF               = 0xF9 # Erase EOF Key
  PLAY                = 0xFA # Play Key
  ZOOM                = 0xFB # Zoom Key
  PA1                 = 0xFD # PA1 Key
  #--------------------------------------------------------------------------
  # * Number Pad Keys
  #--------------------------------------------------------------------------
  NUMPAD0             = 0x60 # Numeric Keypad 0 Key
  NUMPAD1             = 0x61 # Numeric Keypad 1 Key
  NUMPAD2             = 0x62 # Numeric Keypad 2 Key
  NUMPAD3             = 0x63 # Numeric Keypad 3 Key
  NUMPAD4             = 0x64 # Numeric Keypad 4 Key
  NUMPAD5             = 0x65 # Numeric Keypad 5 Key
  NUMPAD6             = 0x66 # Numeric Keypad 6 Key
  NUMPAD7             = 0x67 # Numeric Keypad 7 Key
  NUMPAD8             = 0x68 # Numeric Keypad 8 Key
  NUMPAD9             = 0x69 # Numeric Keypad 9 Key
  MULTIPLY            = 0x6A # Multiply Key (*)
  ADD                 = 0x6B # Add Key (+)
  SEPARATOR           = 0x6C # Separator Key
  SUBTRACT            = 0x6D # Subtract Key (-)
  DECIMAL             = 0x6E # Decimal Key (.)
  DIVIDE              = 0x6F # Divide Key (/)
  #--------------------------------------------------------------------------
  # * Function Keys
  #--------------------------------------------------------------------------
  F1                  = 0x70 # F1 Key
  F2                  = 0x71 # F2 Key
  F3                  = 0x72 # F3 Key
  F4                  = 0x73 # F4 Key
  F5                  = 0x74 # F5 Key
  F6                  = 0x75 # F6 Key
  F7                  = 0x76 # F7 Key
  F8                  = 0x77 # F8 Key
  F9                  = 0x78 # F9 Key
  F10                 = 0x79 # F10 Key
  F11                 = 0x7A # F11 Key
  F12                 = 0x7B # F12 Key
  F13                 = 0x7C # F13 Key
  F14                 = 0x7D # F14 Key
  F15                 = 0x7E # F15 Key
  F16                 = 0x7F # F16 Key
  F17                 = 0x80 # F17 Key
  F18                 = 0x81 # F18 Key
  F19                 = 0x82 # F19 Key
  F20                 = 0x83 # F20 Key
  F21                 = 0x84 # F21 Key
  F22                 = 0x85 # F22 Key
  F23                 = 0x86 # F23 Key
  F24                 = 0x87 # F24 Key
  #--------------------------------------------------------------------------
  # * Toggle Keys
  #--------------------------------------------------------------------------
  CAPITAL             = 0x14 # Caps Lock Key
  KANA                = 0x15 # IME Kana Mode Key
  HANGUL              = 0x15 # IME Hangul Mode Key
  JUNJA               = 0x17 # IME Junja Mode Key
  FINAL               = 0x18 # IME Final Mode Key
  HANJA               = 0x19 # IME Hanja Mode Key
  KANJI               = 0x19 # IME Kanji Mode Key
  MODECHANGE          = 0x1F # IME Mode Change Request Key
  INSERT              = 0x2D # Insert Key
  NUMLOCK             = 0x90 # Num Lock Key
  SCROLL              = 0x91 # Scroll Lock Key
  #--------------------------------------------------------------------------
  # * OEM Keys (Vary by keyboard)
  #--------------------------------------------------------------------------
  OEM_1               = 0xBA # Misc Characters (; : in USA 101/102 Keyboards)
  OEM_PLUS            = 0xBB # + = Key
  OEM_COMMA           = 0xBC # , < Key
  OEM_MINUS           = 0xBD # - _ Key
  OEM_PERIOD          = 0xBE # . > Key
  OEM_2               = 0xBF # Misc Characters (/ ? in USA 101/102 Keyboards)
  OEM_3               = 0xC0 # Misc Characters (` ~ in USA 101/102 Keyboards)
  OEM_4               = 0xDB # Misc Characters ([ { in USA 101/102 Keyboards)
  OEM_5               = 0xDC # Misc Characters (\ | in USA 101/102 Keyboards)
  OEM_6               = 0xDD # Misc Characters (] } in USA 101/102 Keyboards)
  OEM_7               = 0xDE # Misc Characters (' " in USA 101/102 Keyboards)
  OEM_8               = 0xDF # Misc Characters (Varies by Keyboard)
  OEM_9               = 0xE1 # OEM Specific
  OEM_10              = 0x92 # OEM Specific
  OEM_11              = 0x93 # OEM Specific
  OEM_12              = 0x94 # OEM Specific
  OEM_13              = 0x95 # OEM Specific
  OEM_14              = 0x96 # OEM Specific
  OEM_15              = 0xE3 # OEM Specific
  OEM_16              = 0xE4 # OEM Specific
  OEM_17              = 0xE6 # OEM Specific
  OEM_18              = 0xE9 # OEM Specific
  OEM_19              = 0xEA # OEM Specific
  OEM_20              = 0xEB # OEM Specific
  OEM_21              = 0xEC # OEM Specific
  OEM_22              = 0xED # OEM Specific
  OEM_23              = 0xEE # OEM Specific
  OEM_24              = 0xEF # OEM Specific
  OEM_25              = 0xF1 # OEM Specific
  OEM_26              = 0xF2 # OEM Specific
  OEM_27              = 0xF3 # OEM Specific
  OEM_28              = 0xF4 # OEM Specific
  OEM_29              = 0xF5 # OEM Specific
  OEM_102             = 0xE2 # Angle Bracket or Backslash on RT-102 Keyboards
  OEM_CLEAR           = 0xFE # Clear Key
  #--------------------------------------------------------------------------
  # * Special Keys
  #--------------------------------------------------------------------------
  ANYKEY              = 0x100 # Any Key
  #--------------------------------------------------------------------------
  # * Declare Module Variables
  #--------------------------------------------------------------------------
  begin
    # Create strings for unpacking input
    @unpack_string = 'B' * 256
    @toggle_unpack_string = 'b' * 256
    # Generate blank input arrays
    @last_array = '0' * 256
    @press   = Array.new(256, false) # Key currently pressed
    @trigger = Array.new(256, false) # Key initially pressed
    @repeat  = Array.new(256, false) # Key being held
    @release = Array.new(256, false) # Key being released
    @toggle  = Array.new(256, false) # Key currently toggled
    # Generate blank counter array
    @repeat_counter = Array.new(256, 0)
    # Declare keyboard API
    @getKeyboardState = Win32API.new('user32.dll', 'GetKeyboardState', 'P', 'V')
    @getAsyncKeyState = Win32API.new('user32.dll', 'GetAsyncKeyState', 'I', 'I')
    @getKeyState = Win32API.new('user32.dll', 'GetKeyState', 'I', 'I')
    @getKeyboardLayoutName = Win32API.new('user32.dll', 'GetKeyboardLayoutName',
      'P', 'I')
    @loadKeyboardLayout = Win32API.new('user32.dll', 'LoadKeyboardLayout', 'PI',
      'I')
    @mapVirtualKeyEx = Win32API.new('user32.dll', 'MapVirtualKeyEx', 'III', 'I')
    @toUnicodeEx = Win32API.new('user32.dll', 'ToUnicodeEx', 'IIPPIII', 'I')
    # Call current keyboard state
    @getKeyboardState.call(@last_array)
    # Set previous keyboard state
    @last_array = @last_array.unpack(@unpack_string)
    # Set a blank keyboard state
    @keyboard_state = '0'*256
    # Set array to input character list
    @input_characters = [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S,
      T, U, V, W, X, Y, Z, N0, N1, N2, N3, N4, N5, N6, N7, N8, N9, OEM_MINUS,
      OEM_PLUS, OEM_COMMA, OEM_PERIOD, OEM_1, OEM_2, OEM_3, OEM_4, OEM_5, OEM_6,
      OEM_7, OEM_8, OEM_9, OEM_10, OEM_11, OEM_12, OEM_13, OEM_14, OEM_15,
      OEM_16, OEM_17, OEM_18, OEM_19, OEM_20, OEM_21, OEM_22, OEM_23, OEM_24,
      OEM_25, OEM_26, OEM_27, OEM_28, OEM_29, OEM_102, NUMPAD0, NUMPAD1, NUMPAD2,
      NUMPAD3, NUMPAD4, NUMPAD5, NUMPAD6, NUMPAD7, NUMPAD8, NUMPAD9, DECIMAL,
      MULTIPLY, ADD, SEPARATOR, SUBTRACT, DIVIDE, SPACE]
    # Create a keyboard layout buffer
    layout_name = '0' * 8
    # Get the keyboard name
    success = @getKeyboardLayoutName.call(layout_name)
    # Set the layout to US 101 if no name was obtained
    layout_name = '00000409' if success == 0
    # Save the keyboard layout
    @layout = @loadKeyboardLayout.call(layout_name, 0x00000001)
    # Create an empty array to store mapped virtual keys
    @mapped_keys = []
    # Iterate through the input character list
    for key in @input_characters
      # Insert the mapped virtual key into the array
      @mapped_keys.push(@mapVirtualKeyEx.call(key, 0, @layout))
    end
    # create blank input array
    @keyboard_state = '0'*256
    # Call current keyboard state
    @getKeyboardState.call(@keyboard_state)
    # Create an array to detect dead keys
    @dead_keys = []
    # Iterate through the input character array
    for key in 0...256
      # Find the key's current scan code
      scan_code = @mapVirtualKeyEx.call(key, 0, @layout)
      # Skip if there is no scan code for the current layout
      next if scan_code == 0
      # Create a character buffer
      buffer = '0' * 10
      # Test the key
      dead_key = @toUnicodeEx.call(key, scan_code, @keyboard_state, buffer, 5, 0,
        @layout)
      # if the key is a dead key
      if dead_key == -1
        # Add the key to the dead key array
        @dead_keys.push(key)
        # Create a character buffer
        buffer = '0' * 10
        # Clear the input queue
        dead_key = @toUnicodeEx.call(@input_characters[-1], @mapped_keys[-1],
          @keyboard_state, buffer, 5, 0, @layout)
      end
   end
   # Set the dead keys to off
   @dead_key_on = false
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def self.update
    # Clear input arrays
    @trigger = Array.new(256, false)
    @repeat = Array.new(256, false)
    @release = Array.new(256, false)
    # create blank input array
    @keyboard_state = '0' * 256
    # Call current keyboard state
    @getKeyboardState.call(@keyboard_state)
    # unpack toggle array
    toggle = @keyboard_state.unpack(@toggle_unpack_string)
    # Unpack key array
    array = @keyboard_state.unpack(@unpack_string)
    # Cycle through all keys
    for i in 0...array.size
      # Set the current key state
      @press[i] = (array[i].to_i != 0)
      # Set the current toggle unpack state
      @toggle[i] = (toggle[i].to_i != 0)
      # If the current key state does not match the previous state
      if array[i] != @last_array[i]
        # If the repeat counter is at 0
        if @repeat_counter[i] <= 0 && @press[i]
          # Set the key to repeat
          @repeat[i] = true
          # Set the repeat counter to 15 frames
          @repeat_counter[i] = 15
        end
        # If the key is not being pressed
        if !@press[i]
          # Set the key to released
          @release[i] = true
        # If the key is being pressed
        else
          # Set the key to triggered
          @trigger[i] = true
        end
      # If the key state is the same
      else
        # If the repeat counter is greater than 0 and the key is pressed
        if @repeat_counter[i] > 0 && @press[i]
          # Cycle the repeat counter down one frame
          @repeat_counter[i] -= 1
        # If the repeat counter is 0 or less and the key is pressed
        elsif @repeat_counter[i] <= 0 && @press[i]
          # Set the key to repeat
          @repeat[i] = true
          # Set the repeat counter to 15 frames
          @repeat_counter[i] = 3
        # If the repeat counter does not equal 0
        elsif @repeat_counter[i] != 0 && !@press[i]
          # Set the repeat counter to 0
          @repeat_counter[i] = 0
        end
      end
    end
    # Set the previous keyboard state
    @last_array = array
  end
  #--------------------------------------------------------------------------
  # * Get Key Pressed State
  #     key : key index
  #--------------------------------------------------------------------------
  def self.press?(key)
    # Return the array state if key is an array
    return array_press?(key) if (Array == key.class)
    # Return false if key is invalid
    return false if !validate_key(key)
    # Return for any key
    return @press.include?(true) if key == 0x100
    # Return key pressed state
    return @press[key]
  end
  #--------------------------------------------------------------------------
  # * Get Key Triggered State
  #     key : key index
  #--------------------------------------------------------------------------
  def self.trigger?(key)
    # Return the array state if key is an array
    return array_trigger?(key) if (Array == key.class)
    # Return false if key is invalid
    return false if !validate_key(key)
    # Return for any key
    return @trigger.include?(true) if key == 0x100
    # Return key triggered state
    return @trigger[key]
  end
  #--------------------------------------------------------------------------
  # * Get Key Repeated State
  #     key : key index
  #--------------------------------------------------------------------------
  def self.repeat?(key)
    # Return the array state if key is an array
    return array_repeat?(key) if (Array == key.class)
    # Return false if key is invalid
    return false if !validate_key(key)
    # Return for any key
    return @repeat.include?(true) if key == 0x100
    # Return key repeated state
    return @repeat[key]
  end
  #--------------------------------------------------------------------------
  # * Get Key Released State
  #     key : key index
  #--------------------------------------------------------------------------
  def self.release?(key)
    # Return the array state if key is an array
    return array_release?(key) if (Array == key.class)
    # Return false if key is invalid
    return false if !validate_key(key)
    # Return for any key
    return @release.include?(true) if key == 0x100
    # Return key released state
    return @release[key]
  end
  #--------------------------------------------------------------------------
  # * Get Key Toggled State
  #     key : key index
  #--------------------------------------------------------------------------
  def self.toggle?(key)
    # Return the array state if key is an array
    return array_toggle?(key) if (Array == key.class)
    # Return false if key is invalid
    return false if !validate_key(key)
    # Return for any key
    return @toggle.include?(true) if key == 0x100
    # Return key toggled state
    return @toggle[key]
  end
  #--------------------------------------------------------------------------
  # * Get Key Pressed State (array)
  #     keys : array of key indices
  #--------------------------------------------------------------------------
  def self.array_press?(keys)
    # Return as a key if the input is not an array
    return press?(keys) if (Array != keys.class)
    # Create a temporary array to store key states
    states = [false]
    # Iterate through the keys array
    for key in keys
      # Add the key state to the array
      states << press?(key)
    end
    # Return true if any of the keys were pressed
    return states.include?(true)
  end
  #--------------------------------------------------------------------------
  # * Get Key Triggered State (array)
  #     keys : array of key indices
  #--------------------------------------------------------------------------
  def self.array_trigger?(keys)
    # Return as a key if the input is not an array
    return trigger?(keys.to_i) if (Array != keys.class)
    # Create a temporary array to store key states
    states = [false]
    # Iterate through the keys array
    for key in keys
      # Add the key state to the array
      states << trigger?(key)
    end
    # Return true if any of the keys were pressed
    return states.include?(true)
  end
  #--------------------------------------------------------------------------
  # * Get Key Repeated State (array)
  #     keys : array of key indices
  #--------------------------------------------------------------------------
  def self.array_repeat?(keys)
    # Return as a key if the input is not an array
    return repeat?(keys.to_i) if (Array != keys.class)
    # Create a temporary array to store key states
    states = [false]
    # Iterate through the keys array
    for key in keys
      # Add the key state to the array
      states << repeat?(key)
    end
    # Return true if any of the keys were pressed
    return states.include?(true)
  end
  #--------------------------------------------------------------------------
  # * Get Key Released State (array)
  #     keys : array of key indices
  #--------------------------------------------------------------------------
  def self.array_release?(keys)
    # Return as a key if the input is not an array
    return release?(keys.to_i) if (Array != keys.class)
    # Create a temporary array to store key states
    states = [false]
    # Iterate through the keys array
    for key in keys
      # Add the key state to the array
      states << release?(key)
    end
    # Return true if any of the keys were pressed
    return states.include?(true)
  end
  #--------------------------------------------------------------------------
  # * Get Key Toggled State (array)
  #     keys : array of key indices
  #--------------------------------------------------------------------------
  def self.array_toggle?(keys)
    # Return as a key if the input is not an array
    return toggle?(keys.to_i) if (Array != keys.class)
    # Create a temporary array to store key states
    states = [false]
    # Iterate through the keys array
    for key in keys
      # Add the key state to the array
      states << toggle?(key)
    end
    # Return true if any of the keys were pressed
    return states.include?(true)
  end
  #--------------------------------------------------------------------------
  # * Get Caps Lock State
  #--------------------------------------------------------------------------
  def self.capslock?
    # Return the current toggle state of Caps Lock
    return @toggle[CAPITAL]
  end
  #--------------------------------------------------------------------------
  # * Get Number Lock State
  #--------------------------------------------------------------------------
  def self.numlock?
    # Return the current toggle state of Num Lock
    return @toggle[NUMLOCK]
  end
  #--------------------------------------------------------------------------
  # * Get Scroll Lock State
  #--------------------------------------------------------------------------
  def self.scroll?
    # Return the current toggle state of Scroll Lock
    return @toggle[SCROLL]
  end
  #--------------------------------------------------------------------------
  # * Return Current Key Character Pressed
  #--------------------------------------------------------------------------
  def self.character_press
    # Iterate through the list of input characters
    for i in 0...@input_characters.size
      # Set a temporary variable to the value of the current key
      key = @input_characters[i]
      # Skip if the character is not currently pressed
      next unless self.press?(key)
      # Get the current key's scan code
      scan_code = @mapped_keys[i]
      # Get the specified character
      character = get_character(key, scan_code)
      # Skip if there was no translation for the character
      next if !character || character == -1
      # Return the translated character
      return character
    end
    # Return blank if no characters were returned
    return ""
  end
  #--------------------------------------------------------------------------
  # * Return Current Key Character Triggered
  #--------------------------------------------------------------------------
  def self.character_trigger
    # Iterate through the list of input characters
    for i in 0...@input_characters.size
      # Set a temporary variable to the value of the current key
      key = @input_characters[i]
      # Skip if the character is not currently triggered
      next unless self.trigger?(key)
      # Get the current key's scan code
      scan_code = @mapped_keys[i]
      # Get the specified character
      character = get_character(key, scan_code)
      # Skip if there was no translation for the character
      next if !character || character == -1
      # Return the translated character
      return character
    end
    # Return blank if no characters were returned
    return ""
  end
  #--------------------------------------------------------------------------
  # * Return Current Key Character Repeated
  #--------------------------------------------------------------------------
  def self.character_repeat
    # Iterate through the list of input characters
    for i in 0...@input_characters.size
      # Set a temporary variable to the value of the current key
      key = @input_characters[i]
      # Skip if the character is not currently repeated
      next unless self.repeat?(key)
      # Get the current key's scan code
      scan_code = @mapped_keys[i]
      # Get the specified character
      character = get_character(key, scan_code)
      # Skip if there was no translation for the character
      next if !character || character == -1
      # Return the translated character
      return character
    end
    # Return blank if no characters were returned
    return ""
  end
  #--------------------------------------------------------------------------
  # * Get Character from Key
  #--------------------------------------------------------------------------
  def self.get_character(key, scan_code)
    # Create a character buffer
    buffer = '0' * 10
    # Translate the current key to Unicode
    success = @toUnicodeEx.call(key, scan_code, @keyboard_state, buffer, 5, 0,
      @layout)
    # Return false there was no translation for the character
    return false if success == 0
    # Iterate through the dead keys
    for dead_key in @dead_keys
      # If the dead key was pressed
      if @getAsyncKeyState.call(dead_key) != 0
        # Map the dead key scan code
        dead_scan =  @mapVirtualKeyEx.call(dead_key, 0, @layout)
        # Recreate a character buffer
        buffer = '0' * 10
        # Translate the current key to Unicode
        success = @toUnicodeEx.call(dead_key, dead_scan, @keyboard_state,
          buffer, 5, 0, @layout)
        # If it returns as a dead key
        if success == -1
          # Recreate a character buffer
          buffer = '0' * 10
          # Translate the current key to Unicode
          success = @toUnicodeEx.call(key, scan_code, @keyboard_state, buffer,
          5, 0, @layout)
        end
        # Return false there was no translation for the character
        return false if success == 0
      end
    end
    # Translate the characters to Ruby encoding
    characters = buffer.unpack('C*').pack('U*')
    # Create the return character
    array = []
    # Iterate through the character buffer
    for i in 0...(success * 2)
      # Add characters to the character array
      array.push(characters[i]) unless array.include?(characters[i])
    end
    # If a dead key was pressed
    if success == -1
      # Iterate through the character buffer
      for i in 0...2
        # Add characters to the character array
        array.push(characters[i]) unless array.include?(characters[i])
      end
    end
    # Delete null characters
    array.delete_if {|byte| byte == 0}
    # Create an empty string for the return character
    character = ' ' * array.size
    # Iterate through the character array
    for i in 0...array.size
      # Add the character to the string
      character[i] = array[i]
    end
    # Return the translated character
    return character
  end
  #--------------------------------------------------------------------------
  # * Validate Key
  #--------------------------------------------------------------------------
  def self.validate_key(key)
    # Return false if key is not a number
    return false if !(key.is_a?(Numeric))
    # Force key into the integer class
    key = key.to_i
    # Return false if the key does not exist or is not an integer
    return false if ((key < 0x01) || (key > 0x100) || !(key == key.to_i))
    # Return that the key is valid
    return true
  end
end
 
#==============================================================================
# ** Input
#------------------------------------------------------------------------------
#  This module performs key input processing
#==============================================================================
 
module Input
  # Add class data
  class << self
    #------------------------------------------------------------------------
    # * Alias Methods
    #------------------------------------------------------------------------
    # If the update method has not been aliased
    unless method_defined?(:keyinputmodule_input_update)
      # Alias the update method
      alias keyinputmodule_input_update update
    end
    #-------------------------------------------------------------------------
    # * Frame Update
    #-------------------------------------------------------------------------
    def update
      # Call original method
      keyinputmodule_input_update
      # Update Keys module
      Keys.update
    end
  end
end


