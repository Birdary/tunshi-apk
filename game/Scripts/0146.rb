#encoding:utf-8
#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　标题画面
#==============================================================================

module SpriteLoadder
  def load_arrow
    Sprite.create do |sp|
      sp.attrset :x=>0,:y=>0,:z=>999,:bitmap=>Cache.system("Arrow_s")
    end
  end
  def load_body(filename)
    sp = Sprite.create do |sp|
      sp.attrset :x=>0,:y=>0,:z=>999,:bitmap=>Cache.body(filename)
    end
    yield sp if block_given?
    sp
  end
end

module System
  def set_counsellor(actor)
    $game_party.set_counsellor(actor)
  end
end

class Window_Face_Select < Window_Selectable
  include   SpriteLoadder
  def initialize(_size,_col_max,*args)
    @arrow = load_arrow
    super *args
    self.opacity = 0
    @size = _size
    @col_max = _col_max
    @index = 0
    update_arrow(@index)
    refresh
  end
  [:item_max,:col_max].each do |symbol|
    define_method symbol do
      $game_party.members.size
    end
  end
  def size ;  @size ; end
  def update_cursor
    super
    @arrow.visible = self.active
  end
  def item_rect(index)
    update_arrow index
    super
  end
  def update_arrow(index)
    @arrow.x = self.x + index * size
    @arrow.y = self.y
  end
  def actor ;  $game_party.members[@index] ;  end
  def process_cursor_move
    super
    if Input.repeat?(:LEFT) && handle?(:cursor_left)
      call_handler(:cursor_left)
    end
    if Input.repeat?(:RIGHT) && handle?(:cursor_right)
      call_handler(:cursor_right)
    end
  end
  def refresh
    contents.clear
    $game_party.members.each_with_index do |actor,index|
      draw_actor_face(actor, size * index, 0, size)
    end
  end
end



class Scene_Skill_Graph < Scene_Base
  include   System
  include   SpriteLoadder

  def start
    super
    create_background
    @data = SkGraph.data
    @skill_graph_w = Window_Skill_Graph.new(@data)
    @skill_graph_w.set_handler(:cancel, method(:return_cmd))

    # hack cmd window
    class << @cmd = Window_HorzCommand.new(330,450,640,80)
      def window_width ; 620 ; end
      def col_max ; 3 ; end
      def item_rect(index)
        case index
          when 0 ; w = 226 ; x = 0
          when 1 ; w = 202 ; x = 226
          when 2 ; w = 180 ; x = 433
        end
        Rect.new(x, 0, w, 32)
      end
    end
    @cmd.instance_eval do
      self.opacity = 0 ; self.index = 0 ; self.activate
      self.add_command("", :set_con)
      self.add_command("", :levelup)
      self.add_command("", :clear_all)
    end
    @cmd.set_handler(:ok, method(:cmd_ok))
    @cmd.set_handler(:cancel, method(:return_map))

    # hack party window
    @face_select = Window_Face_Select.new(60,1,690,646-13,420+48,60+40)
    @face_select.set_handler(:ok, method(:set_con_ok))
    @face_select.set_handler(:cancel, method(:return_cmd))
    @face_select.set_handler(:cursor_left, method(:refresh_body))
    @face_select.set_handler(:cursor_right, method(:refresh_body))

    # body
    @body = load_body(actor.ename) { |body| body.x = 1124 ; body.y = 500 }
    class << @body
      define_method :refresh do |filename|
        self.bitmap = Cache.body(filename)
      end
    end
    refresh_body

    # now_body
    counsellor_name = counsellor.nil? ? "" : counsellor.ename
    @now_body = load_body(counsellor_name) { |body| body.x = 0 ; body.y = 500 }
    class << @now_body
      define_method :refresh do |filename|
        self.bitmap = Cache.body(filename)
      end
    end
    refresh_coun

    create_now_counsellor_status_window(counsellor)
    create_now_actor_status_window(actor)
  end

  def create_now_counsellor_status_window(actor)
    @counsellor_status = Window_EquipStatus.new(202-128+18,555-113)
    if counsellor
      @counsellor_status.actor = actor
      @counsellor_status.diy :name=>{:x=>184,:y=>102},:level_s=>{:x=>184+64,:y=>102}
    end
    @counsellor_status.instance_eval do
      change_nc_pos(106,332) ; refresh 
      simple_mode
      contents.clear_rect(80, 30,120,40)
    end
  end

  def create_now_actor_status_window(actor)
    @actor_status = Window_EquipStatus.new(202-128+18+523,555-113)
    @actor_status.actor = actor
    @actor_status.instance_eval do
      change_nc_pos(106+523,332) ; refresh
      simple_mode
      contents.clear_rect(80, 30,120,40)
      diy :name=>{:x=>184,:y=>102},:level_s=>{:x=>184+64,:y=>102}
    end
  end

  def counsellor
    $game_party.counsellor
  end

  def actor
    @face_select.actor
  end

  def refresh_body
    @body.refresh(actor.ename)
    if @actor_status
      @actor_status.actor = actor
      @actor_status.refresh
      @actor_status.contents.clear_rect(80, 30,120,40)
      @actor_status.diy :name=>{:x=>184,:y=>102},:level_s=>{:x=>184+64,:y=>102}
    end 
  end

  def refresh_coun
    @now_body.refresh(counsellor.ename) if counsellor
  end

  def set_con_ok
    actor = @face_select.actor
    set_counsellor actor
    refresh_coun
    @counsellor_status.actor = actor
    @counsellor_status.refresh
    @counsellor_status.contents.clear_rect(80, 30,120,40)
    @counsellor_status.diy :name=>{:x=>184,:y=>102},:level_s=>{:x=>184+64,:y=>102}
    @skill_graph_w.check_flash
    @face_select.activate
  end

  def return_cmd
    @cmd.activate
  end


  #--------------------------------------------------------------------------
  # ● 返回地图
  #--------------------------------------------------------------------------
  def return_map
    SceneManager.call(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● 命令窗口 ok
  #--------------------------------------------------------------------------
  def cmd_ok
    @cmd.deactivate
    self.send(@cmd.current_symbol)
  end
  #--------------------------------------------------------------------------
  # ● 任命军师
  #--------------------------------------------------------------------------
  def set_con
    #@cmd.deactivate
    @face_select.activate
  end
  #--------------------------------------------------------------------------
  # ● 强化
  #--------------------------------------------------------------------------
  def levelup
    @cmd.deactivate
    @skill_graph_w.activate
  end
  #--------------------------------------------------------------------------
  # ● 清空
  #--------------------------------------------------------------------------
  def clear_all
    SkGraph.clear_all!
    SkGraph.initialize_point!
    @skill_graph_w.refresh_point
    @skill_graph_w.crushed_out_all
    @skill_graph_w.check_flash
    @cmd.activate
  end
  #--------------------------------------------------------------------------
  # ● 命令窗口 cancel
  #--------------------------------------------------------------------------
  def cmd_cancel
    @cmd.activate
  end
  #--------------------------------------------------------------------------
  # ● 获取渐变速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    @skill_graph_w.dispose
    [@body,@now_body].each do |item|
      item.dispose ; item.bitmap.dispose
    end
    dispose_background
  end
  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @s = Sprite.new
    @s.bitmap = Cache.system("skillgraph")
  end

  #--------------------------------------------------------------------------
  # ● 释放背景
  #--------------------------------------------------------------------------
  def dispose_background
    @s.bitmap.dispose
    @s.dispose
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
  end
end
