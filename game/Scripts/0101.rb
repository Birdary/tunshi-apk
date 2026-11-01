#encoding:utf-8
#==============================================================================
# ■ Window_BattleSkill
#------------------------------------------------------------------------------
# 　战斗画面中，选择“使用技能”的窗口。
#==============================================================================
class Window_BattleList


end



class Window_BattleSkill < Window_SkillList
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     info_viewport : 信息显示用显示端口
  #--------------------------------------------------------------------------
  def initialize(help_window, info_viewport)
    super(1076, 160-22, 200, 277)
    self.visible = false
    @help_window = help_window
    @show_back = false
    self.opacity = 0
    self.z = 200
    create_background
    create_flash
    create_cost
    #self.windowskin = Cache.system("Window_no3")
  end

  def create_background
    @back = Sprite.new(@info_viewport)
    @back.visible = false
    @back.x = 0
    @back.y = 460-359
    @back.z = 100
 

    @back_tag = Sprite.new(@info_viewport)
    @back_tag.bitmap = Cache.system("select_tag")
    @back_tag.visible = false
    @back_tag.x = 1004
    @back_tag.z = 101
  end

  def hide_back_tag
      @back_tag.opacity = 255
  end

  def show_back_tag
      @back_tag.opacity = 255
  end

  def create_flash
    @flash = Sprite_Flash.new(@info_viewport)
    @flash.bitmap = Cache.flash("Battlecomm2_kong")
    @flash.visible = false
    @flash.x = 76
    @flash.y = 460-359
    @flash.z = 150
  end

  def create_cost
    @cost = Sprite.new(@info_viewport)
    @cost.visible = false
    @cost.bitmap = Bitmap.new(48,32)
    @cost.bitmap.font.size = 18 + $game_variables[300]
    @cost.x = 1255
    @cost.y = 483-359-4
    @cost.z = 250
  end

  # 无需手动释放
  # def dispose
  #   super
  #   [@back,@flash,@cost,@back_tag].each do |sp|
  #     sp.bitmap.dispose if sp.bitmap
  #     sp.dispose
  #   end
  # end

  def set_background(filename)
    @back.bitmap = Cache.system("skill_back_kong")
    @back.bitmap.clear
    @flash.bitmap.clear
    h = 0
    h = @data.size 
    h = 1 if h < 1 
    if h < 10
      hi = (10 - h) * 24
      self.height == 277 - hi
      @back.bitmap.blt(0,0,Cache.system(filename),Rect.new(0,0,311,290-hi)) 
      @flash.bitmap.blt(0,0,Cache.flash("Battlecomm22"),Rect.new(0,0,251,61)) 
      @flash.bitmap.blt(0,61,Cache.flash("Battlecomm22"),Rect.new(0,61+hi,251,250)) 
    else
      @back.bitmap.blt(0,0,Cache.system(filename),Rect.new(0,0,311,290)) 
      @flash.bitmap.blt(0,0,Cache.flash("Battlecomm2"),Rect.new(0,0,251,320)) 
    end   
  end

  #--------------------------------------------------------------------------
  # ● 光标向右移动
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if top_row + page_row_max < row_max
      self.top_row += page_row_max
      select([@index + page_item_max, item_max - 1].min)
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标向左移动
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if top_row > 0
      self.top_row -= page_row_max
      select([@index - page_item_max, 0].max)
    end
  end


  def back_opacity=(n)
    @back.opacity = @flash.opacity = n
  end

  def init_back(dir)
    if dir == 4
      @back.x = 600+370 ; @flash.x = 600+370+76 ; self.x = 1076-52 ; @cost.x = 1155 ; @back_tag.x = 1004 ;
    end
    if dir == 6
      @back.x = 700+370 ; @flash.x = 700+370+76 ; self.x = 1176-52 ; @cost.x = 1255 ; @back_tag.x = 1104 ;
    end
  end

  def change_back_x(x,dir)
    if dir == 4
      @back.x -= x ; @flash.x -= x ; self.x -= x; @cost.x -= x ; @back_tag.x -= x ;
            @back_tag.y = 125+24
    end
    if dir == 6
      @back.x += x ; @flash.x += x ; self.x += x; @cost.x += x ; @back_tag.x += x ;
    end
  end

  def change_back_opacity(x,flag)
    if flag == "+"
      @back.opacity += x ; @flash.opacity += x ; self.contents_opacity += x ; @cost.opacity += x ; @back_tag.opacity += x ;
    end
    if flag == "-"
      @back.opacity -= x ; @flash.opacity -= x ; self.contents_opacity -= x;  @cost.opacity -= x ; @back_tag.opacity -= x ;
      cursor_rect.x = 1300
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 查询使用列表中是否含有此物品
  #--------------------------------------------------------------------------
  def include?(item)
    $game_party.usable?(item)
  end
  #--------------------------------------------------------------------------
  # ● 显示窗口
  #--------------------------------------------------------------------------
  def show
    select_last
    @cost.visible = true
    @help_window.show
    @back.opacity = 255
    show_back_tag
    super
  end
  #--------------------------------------------------------------------------
  # ● 隐藏窗口
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide
    hide_back
    @cost.visible = false
     @back.opacity = 0
    super
  end
  def show_back
    @show_back = true
  end
  def hide_back
    @show_back = false
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的高度
  #--------------------------------------------------------------------------
  def item_height
    return 24
  end
  def update
    super
    @back.visible = @flash.visible = @show_back
    @back_tag.visible = @flash.visible
    update_flash if @flash.visible
  end

  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    if Input.repeat?(:RIGHT) 
      cursor_right(Input.trigger?(:RIGHT)) if self.active
      back_tag_y if self.active
    end   
    if Input.repeat?(:LEFT) 
      cursor_left (Input.trigger?(:LEFT)) if self.active 
      back_tag_y if self.active
    end  
    if Input.repeat?(:DOWN) 
      cursor_down (Input.trigger?(:DOWN)) if self.active
      back_tag_y if self.active
    end
    if Input.repeat?(:UP)  
      cursor_up   (Input.trigger?(:UP)) if self.active
      back_tag_y if self.active
    end
    if Keys.repeat?(Keys::D)
      cursor_right(Keys.trigger?(Keys::D)) if self.active
      back_tag_y if self.active
    end   
    if Keys.repeat?(Keys::A)
      cursor_left (Keys.trigger?(Keys::A)) if self.active 
      back_tag_y if self.active
    end  
    if Keys.repeat?(Keys::S)
      cursor_down (Keys.trigger?(Keys::S)) if self.active
      back_tag_y if self.active
    end
    if Keys.repeat?(Keys::W)
      cursor_up   (Keys.trigger?(Keys::W)) if self.active
      back_tag_y if self.active
    end
     Sound.play_cursor if @index != last_index
  end

  def back_tag_y
      use_y = item_rect(index).y - self.oy + 125+24
      @back_tag.y = use_y
  end

  def update_flash
      @flash.update
  end 

  def refresh
    super
    str = case @type
    when :marv
      @cost.bitmap.font.size = 18 + $game_variables[300]
      @cost.bitmap.color = mp_cost_color
      @actor.mp
    when :skill
      @cost.bitmap.color = tp_cost_color
      #@actor.tp.to_i
      if @actor.id == 4800 #显示金币
         @cost.bitmap.font.size = 18 + $game_variables[300]
        "#{$game_party.gold}"
      else
         @cost.bitmap.font.size = 18 + $game_variables[300]
         @actor.tp.to_i
      end
    when :formation
      @cost.bitmap.font.size = 18 + $game_variables[300]
      @cost.bitmap.color = cp_cost_color
      $game_party.boost.to_i
    end
    @stype_id = 0
    self.index = 0
    @cost.bitmap.clear
    @cost.bitmap.draw_text 0,1,48,32,str,2
  end


  def item_rect(index)
    rect = Rect.new
    rect.width = item_width - 6 -30
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing) + 30
    rect.y = index/ col_max * item_height+1
    rect
  end



  def draw_item(index)
    skill = @data[index]
    if skill
      if skill.is_jm? 
        rect = item_rect(index)
        #rect.width -= 4
        #rect.y -=2
        #rect.width = item_width-8-54
        #rect.height = item_height
        if SceneManager.scene.is_a?(Scene_Battle)
          draw_item_name(skill, rect.x, rect.y, enable?(skill)) if @actor.id == $game_variables[100]
        else
          draw_item_name(skill, rect.x, rect.y, (skill)) if @actor.id == $game_variables[100]
        end
        rect.y +=3
        draw_skill_cost(rect, skill)
      else
        rect = item_rect(index)
        #rect.width -= 4
        #rect.y -=2
        #rect.width = item_width-8-54
        #rect.height = item_height
        _x = 0
        _y = index * 24-1+1

        if SceneManager.scene.is_a?(Scene_Battle)
          #计策加成战斗列表显示 and 后面是不可使用的颜色
          if skill.is_wood_marv? and @actor.state?(110) 
            draw_item_name_vip(skill, _x, _y, enable?(skill))
          elsif skill.is_water_marv? and @actor.state?(111) 
            draw_item_name_vip(skill, _x, _y, enable?(skill))
          elsif skill.is_fire_marv? and @actor.state?(112) 
            draw_item_name_vip(skill, _x, _y, enable?(skill))
          elsif skill.is_wind_marv? and @actor.state?(113) 
            draw_item_name_vip(skill, _x, _y, enable?(skill))
          elsif skill.is_formation? and skill.id == $game_party.formation.id
            draw_item_name_ff(skill, _x, _y, enable?(skill))
          else
            draw_item_name(skill, _x, _y, enable?(skill))  
          end 
        else
          if skill.is_marv?
            if enable?(skill)
              draw_item_name(skill, _x, _y, enable?(skill)) 
            else
              draw_item_name(skill, _x, _y, enable?(skill)) 
            end
          else
            draw_item_name(skill, _x, _y, enable?(skill)) 
          end
        end  
        rect_2 = Rect.new(_x+116, _y-10, 50, 50)
        draw_skill_cost(rect_2,skill)
      end
    end
  end



end
