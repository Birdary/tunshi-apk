#encoding:utf-8
#==============================================================================
# ■ Scene_Load
#------------------------------------------------------------------------------
# 　读档画面
#==============================================================================

class Scene_Load < Scene_File
  def create_background
    @background_sprite = Sprite.create do |sp|
      sp.bitmap = Cache.system("load_map")
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取帮助窗口的文本
  #--------------------------------------------------------------------------
  def help_window_text
    Vocab::LoadMessage
  end
  #--------------------------------------------------------------------------
  # ● 获取开始时文件索引的位置
  #--------------------------------------------------------------------------
  def first_savefile_index
    DataManager.latest_savefile_index
  end
  #--------------------------------------------------------------------------
  # ● 确定读档文件
  #--------------------------------------------------------------------------
  def on_savefile_ok
    super
    if DataManager.load_game(@index)
       on_load_success
    else
       Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● 读档成功时的处理
  #--------------------------------------------------------------------------
  def on_load_success
    Sound.play_load
    fadeout_all
    $game_system.on_after_load
    SceneManager.goto(Scene_Map)
    num_lock if $TEST == false
    back_name
    $back_title = false
  end

  def back_name
    if $game_variables[136] != 0
      a = "S"
      b = $game_variables[136]
      c = a+b
      @w = c
      BattleManager.specfg do |cfg|
        cfg.background = :"#{@w}"
      end
    end
  end

  def num_lock
    #--------------------------------------------------------------------------
    @getKeyState = Win32API.new("user32","GetAsyncKeyState",['I'],'I')
    @getKeyboardState = Win32API.new("user32","GetKeyState",['I'],'I')
    @getSetKeyState = Win32API.new("user32","SetKeyboardState",['I'],'I')
    @full = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
    #--------------------------------------------------------------------------
    @full.call 0x90, 0, 0, 0
    Graphics.wait(10)
    @full.call 0x90, 0, 2, 0
    Graphics.wait(10)
    @full.call 0x90, 0, 0, 0
    Graphics.wait(10)
    @full.call 0x90, 0, 2, 0
    Graphics.wait(10)
  end
end

class Load_Confirmation < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x-150, y-29, Graphics.width, 48)
    self.opacity = 0
    @back2 = Sprite.new
    @back = Sprite.new

    if SceneManager.scene.is_a?(Scene_Load)  
      if $game_party.members.size > 0
        @back.bitmap = Cache.system("load_yes_no")
      else
        @back.bitmap = Cache.system("open_yes_no")
      end
      @back2.bitmap = Cache.system("load_map2")
    else
      @back.bitmap = Cache.system("save_yes_no")
      @back2.bitmap = Cache.system("save_map2")
    end
    @back.y = 400-190
    @back2.visible = false
    @back.visible = false
    self.visible = false
    self.active = false
    deactivate
  end

  def back_hide
    @back2.visible = false
  end  

  def back_show
    @back2.visible = true
  end  

  def back_clear
    @back.visible = false
  end  

  def back_y(add)
    @back.y = add
  end  

  def item=(_item)
    @item = _item
  end

  def col_max
    return 2
  end

  def item_max
    return 2
  end

  def item_width
    60
  end

  def contents_width
    Graphics.width - 200
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    case index
    when 0
      rect.x = 600 + 240+40
    when 1
      rect.x = 660 + 240+40
    end
    rect.y = (index / col_max * item_height) 
    rect
  end

  def make_command_list
    add_command("是", :command_yes)
    add_command("否", :command_no)
  end


  def draw_item(index)
    change_color(normal_color, command_enabled?(index))

    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    rect.y += 2
    contents.font.size = 18 + $game_variables[300]
    draw_text(rect, command_name(index), alignment)
  end

  def yes?
    index == 0
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose
  #   @back.dispose
  #   @back2.bitmap.dispose
  #   @back2.dispose
  # end


  def update
    super
    self.visible = self.active
    @back.visible = self.active
  end

  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT) 
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)  
    cursor_right  (Keys.trigger?(Keys::D))    if Keys.repeat?(Keys::D)
    cursor_left   (Keys.trigger?(Keys::A))    if Keys.repeat?(Keys::A) 
    Sound.play_cursor if @index != last_index
  end

end
