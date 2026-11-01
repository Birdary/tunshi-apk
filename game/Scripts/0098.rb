#encoding:utf-8
#==============================================================================
# ■ Window_PartyCommand
#------------------------------------------------------------------------------
# 　战斗画面中，选择“战斗／撤退”的窗口。
#==============================================================================

class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(56, 0)
    self.openness = 0
    self.opacity = 0
    deactivate
    create_background
    create_flash
  end
  def create_background
    @back = Sprite.new(self.viewport)
    if BattleManager.can_escape? and BattleManager.can_allatk? 
      @back.bitmap = Cache.system("select_party")
    elsif !BattleManager.can_escape? and BattleManager.can_allatk? 
      @back.bitmap = Cache.system("select_party_notp")
    elsif  BattleManager.can_escape? and !BattleManager.can_allatk? 
      @back.bitmap = Cache.system("select_party_noall")
    else
      @back.bitmap = Cache.system("select_party_notp_noall")
    end
    @back.visible = false
    @back.x = 947+60-10
    @back.y = 113
    @back.z = 50
  end

  def background_refresh
    if BattleManager.can_escape? and BattleManager.can_allatk? 
      @back.bitmap = Cache.system("select_party")
    elsif !BattleManager.can_escape? and BattleManager.can_allatk? 
      @back.bitmap = Cache.system("select_party_notp")
    elsif  BattleManager.can_escape? and !BattleManager.can_allatk? 
      @back.bitmap = Cache.system("select_party_noall")
    else
      @back.bitmap = Cache.system("select_party_notp_noall")
    end
 end   

  def create_flash
    @flash = Sprite_Flash.new(self.viewport)
    @flash.bitmap = Cache.flash("Battlecomm_party")
    @flash.visible = false
    @flash.x = 969+60-10
    @flash.y = 106
    @flash.z = 100
  end

  def back_opacity=(n)
    @back.opacity = @flash.opacity = n
  end

  def init_back(dir)
    background_refresh
    if dir == 4
      @back.x = 947-10 ; @flash.x = 969-10
    end
    if dir == 6
      @back.x = 947+60-10 ; @flash.x = 969+60-10
    end
  end

  def change_back_x(x,dir)
    if dir == 4
      @back.x -= x ; @flash.x -= x
    end
    if dir == 6
      @back.x += x ; @flash.x += x
    end
  end

  def change_back_opacity(x,flag)
    if flag == "+"
      @back.opacity += x ; @flash.opacity += x
    end
    if flag == "-"
      @back.opacity -= x ; @flash.opacity -= x
      cursor_rect.x = 1300
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    return 288
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    return 350
  end
  #--------------------------------------------------------------------------
  # ● 获取显示行数
  #--------------------------------------------------------------------------
  def visible_line_number
    return 3
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    #add_command(Vocab::fight,  :fight)
    #add_command(Vocab::allattack,:allattack)
    #add_command(Vocab::escape, :escape, BattleManager.can_escape?)
    add_command(Vocab::blank,  :fight)
    add_command(Vocab::blank,  :allattack, BattleManager.can_allatk?)
    add_command(Vocab::blank,  :escape, BattleManager.can_escape?)
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def setup
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    open
  end
  #--------------------------------------------------------------------------
  # ● 获取行高
  #--------------------------------------------------------------------------
  def line_height
    return 24
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width-8-54-32
    rect.height = item_height
    case index
    when 0; y = 0; when 1; y = 26+2; when 2; y = 54+2; end
    rect.x = 0+32
    rect.y = y
    rect
  end

  def update
    super
    self.visible = @back.visible = @flash.visible = self.active
    update_flash if @flash.visible
  end

  def update_flash
    @flash.update
  end

  def process_ok
    if @index == 2 && !BattleManager.can_escape?
      Sound.play_buzzer
      unless SceneManager.scene.tip_animation?
        SceneManager.scene.tip("当前战斗不可用「撤退」指令","red")
      end   
    elsif @index == 1 && !BattleManager.can_allatk?
      Sound.play_buzzer
      unless SceneManager.scene.tip_animation?
        SceneManager.scene.tip("当前战斗不可用「总攻」指令","red")
      end    
    else
      super
    end
  end   

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose if @back.bitmap
  #   @back.dispose
  #   @flash.bitmap.dispose if @flash.bitmap
  #   @flash.dispose
  # end
end
