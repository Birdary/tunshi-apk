#encoding:utf-8
#==============================================================================
# ■ Window_Status
#------------------------------------------------------------------------------
# 　状态画面中，显示角色基本信息的窗口。
#==============================================================================

class Window_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(actor,mode=:complete)
    super(0, 0, Graphics.width, Graphics.height)
    @actor = actor
    self.opacity = 0
    @countdtnl = 0
    @dtzthpk = Sprite.new
    @dtzthpk.bitmap = Cache.hp("hpk")
    @dtzthpk.x = x + 89-1
    @dtzthpk.y = y + 77-24
    @dtzthpk.z =200
    @dtnl = Sprite.new
    if @actor.tp == 100
    @dtnl.bitmap = Cache.hp("n01") 
    else
    @dtnl.bitmap = Cache.hp("b01") 
    end
    @dtnl.x = x + 140+24
    @dtnl.y = y + 136
    @hpmask = Sprite.new; w = 0; 
    @mpmask = Sprite.new; w = 0; 
    @apmask = Sprite.new; w = 0;


         @master_char = Sprite.new
         @master_char.bitmap = Bitmap.new("Graphics/jm/master_char_s")
         @master_char.x = 35+53
         @master_char.y = 35+53
         @master_char.z = 220
         @master_char.opacity = 0

    if actor.id ==  $game_variables[100]
    @master_char.opacity = 255
    else
    @master_char.opacity = 0
    end

    @dtn2 = Sprite.new
    if actor.hp == 0
    @dtn2.bitmap= Cache.hp("face_bk_dead")
    else
    @dtn2.bitmap= Cache.hp("face_bk")
    end
    @dtn2.x = 89
    @dtn2.y = 79-24
    @dtn2.z = 3

    @mode = mode
    refresh
    activate
  end

  def refresh_mask
    actor = @actor
    return if @actor.nil?
    @hpmask.bitmap.clear unless @hpmask.bitmap.nil?
    if actor.hp < actor.mhp
      bitmap_hp = Bitmap.new(w = 200-200*actor.hp/actor.mhp,11)
      bitmap_hp.fill_rect(0,0,bitmap_hp.width,bitmap_hp.height,hp_gauge_color2)
      bitmap_hp.fill_rect(0,0,1,bitmap_hp.height,Color.new(0,0,0))
      @hpmask.attrset(:x=>x+307+60-w-3,:y=>y+161-25,:z=>2,:bitmap=>bitmap_hp)
      if @mode == :simple2
        @hpmask.attrset(:x=>x+307+60-w-18,:y=>y+161-25+24,:z=>2,:bitmap=>bitmap_hp)
      end

    end
    @mpmask.bitmap.clear unless @mpmask.bitmap.nil?
    if actor.mp < actor.mmp
      bitmap_mp = Bitmap.new(w = 200-200*actor.mp/actor.mmp,5)
      bitmap_mp.fill_rect(0,0,bitmap_mp.width,bitmap_mp.height,hp_gauge_color2)
      bitmap_mp.fill_rect(0,0,1,bitmap_mp.height,Color.new(0,0,0))
      @mpmask.attrset(:x=>x+307+60-w-3,:y=>y+175-26,:z=>2,:bitmap=>bitmap_mp)
      if @mode == :simple2
        @mpmask.attrset(:x=>x+307+60-w-18,:y=>y+175-26+24,:z=>2,:bitmap=>bitmap_mp)
      end
    end
    @apmask.bitmap.clear unless @apmask.bitmap.nil?
    if actor.tp < actor.mtp
      bitmap_ap = Bitmap.new(w = 79-(79.0*actor.tp/actor.mtp).to_i,10)
      bitmap_ap.fill_rect(0,0,bitmap_ap.width,5,Color.new(60,60,60,255))
      bitmap_ap.fill_rect(0,5,bitmap_ap.width,5,Color.new(30,30,30,255))
      @apmask.attrset(:x=>x+307-w-1-27-35,:y=>y+179-23,:z=>5,:bitmap=>bitmap_ap)
       if @mode == :simple2
       @apmask.attrset(:x=>x+307-w-1-40-35,:y=>y+179+1,:z=>5,:bitmap=>bitmap_ap)
       end
   end
    if actor.id ==  $game_variables[100]
    @master_char.opacity = 255
    else
    @master_char.opacity = 0
    end
  end

  #--------------------------------------------------------------------------
  # ● 设置模式
  # :simple 简单
  # :complete 完整
  #--------------------------------------------------------------------------
  def mode=(mode)
    @mode = mode
  end

  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @dtzthpk.bitmap.dispose
  #   @dtzthpk.dispose
  #   @dtnl.bitmap.dispose
  #   @dtnl.dispose
  #   @dtn2.bitmap.dispose
  #   @dtn2.dispose
  #   @hpmask.bitmap.dispose unless @hpmask.bitmap.nil?
  #   @hpmask.dispose
  #   @mpmask.bitmap.dispose unless @mpmask.bitmap.nil?
  #   @mpmask.dispose
  #   @apmask.bitmap.dispose unless @apmask.bitmap.nil?
  #   @apmask.dispose
  #   @master_char.bitmap.dispose unless @master_char.bitmap.nil?
  #   @master_char.dispose
  # end

  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    refresh_para
    refresh_mask
        if @actor.hp == 0
    @dtn2.bitmap= Cache.hp("face_bk_dead")
    else
    @dtn2.bitmap= Cache.hp("face_bk")
    end
  end

  def refresh_para
    contents.clear
    actor = @actor
    return if actor.nil?
    if @mode != :simple2
      draw_actor_face(actor, 76+4, 78-21, 92,actor.hp > 0)
    end

    if @mode == :complete
       contents.font.size = 20 + $game_variables[300]+2
    contents.font.name = "Noto"
      x = 180
      y = 60 
    end
    if @mode == :simple
       contents.font.size = 20 + $game_variables[300]+2
    contents.font.name = "Noto"
      x = 175+5; y = 84 - 24
    end

    if @mode == :simple2
      @master_char.x = 35-9
      @master_char.y = 35+10
      x = 175; y = 84
      draw_actor_face(actor, 76+4, 78-21+20, 92,actor.hp > 0)
    end
    @dtzthpk.bitmap = Cache.hp("hpk_h")    if @mode == :simple2
    contents.font.size = 20 + $game_variables[300]+2
    contents.font.name = "Noto"
    if actor.name.length == 2 or SceneManager.scene.is_a?(Scene_Actor_House)
      draw_actor_name(actor, x-114, y+69-32)
    else
      draw_actor_name(actor, x-114-18, y+69-32)
    end
    contents.font.size = 17 + $game_variables[300]+2
    contents.font.name = "Noto"
    draw_actor_level(actor, x-90-40, y+65-1) if actor.level >= 10
    draw_actor_level(actor, x-90-32, y+65-1) if actor.level < 10
    contents.font.size = 21 + $game_variables[300]+1
    draw_actor_icons(actor, x-28+10, y+5)
    
    if @mode == :simple2
      draw_text(x+83-10, y+63-27-1-3, 55, line_height, actor.hp, 0)
      draw_text(x+132+29-10, y+79-43-1-3, 55, line_height, actor.mp, 0)
    else
      draw_text(x+83+2, y+63-27-1-3, 55, line_height, actor.hp, 0)
      draw_text(x+132+29, y+79-43-1-3, 55, line_height, actor.mp, 0)
    end
 
    
    if @mode == :complete
      contents.font.size = 19 + $game_variables[300]
      contents.font.color = normal_color
      s1 = @actor.max_level? ? "??" : @actor.exp
      s2 = @actor.max_level? ? "??" : @actor.next_level_exp - @actor.exp
      #draw_text(152+10, y -107+ 114 + line_height * 3, 80, line_height, s1, 1)
      draw_text(158, y-112+ 140 + line_height * 3-1, 60, line_height, s2, 0)

      draw_actor_exp0_gauge(@actor, 81+28, 256-75 ) #if !@actor.max_level?
      draw_text(366, y+219-2, 40, line_height, @actor.atk, 2)
      draw_text(366, y+219+26-2, 40, line_height, @actor.def, 2)
      draw_text(366, y+219+52-2, 40, line_height, @actor.str, 2)
      draw_text(366, y+219+78-2, 40, line_height, @actor.ski, 2)
      draw_text(366, y+219+104-2, 40, line_height, @actor.int, 2)
      draw_text(366, y+219+130-2, 40, line_height, @actor.agi, 2)


      contents.font.name = "Noto"
      draw_text(158, 412-2, 150, 100,@actor.kill_size_all, 0)
      draw_text(158, 412+46-2, 150, 100,@actor.dead_size_all, 0)
      draw_text(158, 412+92-2, 150, 100,@actor.over_damage_all, 0)
      draw_text(158, 412+138-2, 150, 100,@actor.over_sup_all, 0)
      #draw_equipments(90+20, 345+121+24+3)
    end
  end

  def draw_actor_icons(actor, x, y, width = 320)
    icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
  end

  def update
    super
    if @actor.tp == 100
      case @countdtnl
      when 1
        @dtnl.bitmap = Cache.hp("n01")   
      when 10
        @dtnl.bitmap = Cache.hp("n02")
      when 20
        @dtnl.bitmap = Cache.hp("n03")
      when 30
        @dtnl.bitmap = Cache.hp("n04")
      when 40
        @dtnl.bitmap = Cache.hp("n05")
      when 50
        @dtnl.bitmap = Cache.hp("n06")
      when 60
        @dtnl.bitmap = Cache.hp("n07")
      when 70
        @dtnl.bitmap = Cache.hp("n08")
      when 80
        @dtnl.bitmap = Cache.hp("n09")
      when 90
        @dtnl.bitmap = Cache.hp("n10")  
      when 100                
        @countdtnl = 0
      end
    else
      case @countdtnl
      when 1
        @dtnl.bitmap = Cache.hp("b01")   
      when 10
        @dtnl.bitmap = Cache.hp("b02")
      when 20
        @dtnl.bitmap = Cache.hp("b03")
      when 30
        @dtnl.bitmap = Cache.hp("b04")
      when 40
        @dtnl.bitmap = Cache.hp("b05")
      when 50
        @dtnl.bitmap = Cache.hp("b06")
      when 60
        @dtnl.bitmap = Cache.hp("b07")
      when 70
        @dtnl.bitmap = Cache.hp("b08")
      when 80
        @dtnl.bitmap = Cache.hp("b09")
      when 90
        @dtnl.bitmap = Cache.hp("b10")  
      when 100                
        @countdtnl = 0
      end
    end

    @countdtnl += 1
  end

  #--------------------------------------------------------------------------
  # ● 绘制区域 1 
  #--------------------------------------------------------------------------
  def draw_block1(y)
    draw_actor_name(@actor, 4, y)
    draw_actor_class(@actor, 128, y)
    draw_actor_nickname(@actor, 288, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 2 
  #--------------------------------------------------------------------------
  def draw_block2(y)
    draw_actor_face(@actor, 8, y)
    draw_basic_info(136, y)
    draw_exp_info(304, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 3 
  #--------------------------------------------------------------------------
  def draw_block3(y)
    draw_parameters(32, y)
    draw_equipments(288, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 4 
  #--------------------------------------------------------------------------
  def draw_block4(y)
    draw_description(4, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制水平线
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # ● 获取水平线的颜色
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ● 绘制基本信息
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + line_height * 0)
    draw_actor_icons(@actor, x, y + line_height * 1)
    draw_actor_hp(@actor, x, y + line_height * 2)
    draw_actor_mp(@actor, x, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ● 绘制能力值
  #--------------------------------------------------------------------------
  def draw_parameters(x, y)
    6.times {|i| draw_actor_param(@actor, x, y + line_height * i, i + 2) }
  end
  #--------------------------------------------------------------------------
  # ● 绘制经验值信息
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.max_level? ? "-------" : @actor.exp
    s2 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 180, line_height, Vocab::ExpTotal)
    draw_text(x, y + line_height * 2, 180, line_height, s_next)
    change_color(normal_color)
    draw_text(x, y + line_height * 1, 180, line_height, s1, 2)
    draw_text(x, y + line_height * 3, 180, line_height, s2, 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制装备
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    @actor.equips.each_with_index do |item, i|
      draw_item_name(item, x, y + (line_height+2) * i )
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制说明
  #--------------------------------------------------------------------------
  def draw_description(x, y)
    draw_text_ex(x, y, @actor.description)
  end

  def visible=(visible)
    super
    if @master_char != nil
      @master_char.visible = @hpmask.visible = @mpmask.visible = @apmask.visible = visible
    else
      @hpmask.visible = @mpmask.visible = @apmask.visible = visible
    end
  end
end
