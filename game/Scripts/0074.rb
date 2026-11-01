#encoding:utf-8
#==============================================================================
# ■ Window_ActorCommand
#------------------------------------------------------------------------------
# 　战斗画面中，选择角色行动的窗口。
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(56, 0)
    self.openness = 0
    deactivate
    @actor = nil
    self.opacity = 0
    @show_back = false
    create_background
    create_flash
  end
  def create_background
    @back = Sprite.new(self.viewport)
    @back.bitmap = Cache.system("select_k")

    @back.visible = false
    @back.x = 947+60-10
    @back.y = 113
    @back.z = 50
  end
  def create_flash
    @flash = Sprite_Flash.new(self.viewport)
    @flash.bitmap = Cache.flash("Battlecomm_back")
    @flash.visible = false
    @flash.x = 969+60-10
    @flash.y = 106
    @flash.z = 100
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @back.bitmap.dispose if @back.bitmap
  #   @back.dispose
  #   @flash.bitmap.dispose if @flash.bitmap
  #   @flash.dispose
  # end

  def show

    @back.bitmap.clear
    @back.bitmap.blt(0,0,Cache.system("select"),Rect.new(0,0,350,183)) 

    if @actor.state?(41) or @actor.state?(97)
      @back.bitmap.blt(0,36,Cache.system("select_cant"),Rect.new(0,36,350,29)) 
    end
    if @actor.state?(40) or @actor.state?(62)
      @back.bitmap.blt(0,0,Cache.system("select_cant"),Rect.new(0,0,350,36)) 
    end
    if @actor.state?(53) or $game_party.al.size < 5
      @back.bitmap.blt(0,150,Cache.system("select_cant"),Rect.new(0,150,350,34)) 
    end
    if @actor.tp >= 100
      @back.bitmap.blt(0,58,Cache.system("select_100"),Rect.new(0,00,350,33)) 
    end

    @show_back = true
  end


  def hide
    @show_back = false
  end

  def change_back_x(x,dir)
    if dir == 4
      @back.x -= x ; @flash.x -= x
    end
    if dir == 6
      @back.x += x ; @flash.x += x
    end
  end

  def back_opacity=(n)
    @back.opacity = @flash.opacity = n
  end

  def init_back(dir)
    if dir == 4
      @back.x = 947-10 ; @flash.x = 969-10
    end
    if dir == 6
      @back.x = 947+60-10 ; @flash.x = 969+60-10
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
    return 6
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    #add_attack_command
    add_command(Vocab::blank, :attack)
    add_command(Vocab::blank, :marv)
    add_command(Vocab::blank, :skill)
    #add_marv_command
    #add_skill_commands
    #add_guard_command
    add_command(Vocab::blank, :guard, @actor.guard_usable?)
    add_command(Vocab::blank, :item)
    #add_item_command
    #if $game_party.alive_members.size >= 5 then
    add_command(Vocab::blank, :formation)
    #end
    #add_formation_command
  end
  #--------------------------------------------------------------------------
  # ● 添加攻击指令
  #--------------------------------------------------------------------------
  def add_attack_command
    add_command(Vocab::attack, :attack, @actor.attack_usable?)
  end
  #--------------------------------------------------------------------------
  # ● 添加技能指令
  #--------------------------------------------------------------------------
  def add_skill_commands
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 添加防御指令
  #--------------------------------------------------------------------------
  def add_guard_command
    add_command(Vocab::guard, :guard, @actor.guard_usable?)
  end
  #--------------------------------------------------------------------------
  # ● 添加物品指令
  #--------------------------------------------------------------------------
  def add_item_command
    add_command(Vocab::item, :item)
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def setup(actor)
    @actor = actor
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    show
    open
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的绘制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width-8-54-32
    rect.height = item_height
    case index
    when 0; y = 0; when 1; y = 26+1; when 2; y = 54+2;
    when 3; y = 82+3; when 4; y = 110+3; when 5; y = 138+3;
    end
    rect.x = 0+32
    rect.y = y
    rect
  end
  def update
    super
    @back.visible = @flash.visible = @show_back
    update_flash if @flash.visible
  end

  def update_flash
    @flash.update if self.active
  end 


  #--------------------------------------------------------------------------
  # ● 按下确定键时的处理
  #--------------------------------------------------------------------------
  def process_ok
    if @index == 0 and ( @actor.state?(40) or @actor.state?(62)  )
       Sound.play_buzzer
      unless SceneManager.scene.tip_animation?
        SceneManager.scene.tip("本体当前正处于「限击」状态","red")
      end

    elsif  @index == 1 && @actor.state?(97)
       Sound.play_buzzer
       unless SceneManager.scene.tip_animation?
        SceneManager.scene.tip("本体当前正处于「沉默」状态","red")
       end 
    elsif  @index == 5  
          if @actor.state?(53) and $game_party.al.size >= 5
             Sound.play_buzzer
             unless SceneManager.scene.tip_animation?
             SceneManager.scene.tip("本体当前正处于「解阵」状态","red")
             end 
          elsif $game_party.al.size < 5
             Sound.play_buzzer
             unless SceneManager.scene.tip_animation?
             SceneManager.scene.tip("不足五人不可用「阵法」指令","red")
             end
          else  
             super 
          end 
    elsif @index == 1 && @actor.state?(41)
        Sound.play_buzzer
      unless SceneManager.scene.tip_animation?
        SceneManager.scene.tip("本体当前正处于「限策」状态","red")
      end
    else
      super
    end
  end

end
