#encoding:utf-8
#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　技能画面中，显示技能的窗口。
#==============================================================================

class Window_JmList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x,y,width,height)
    @actor = nil
    @master = $game_actors[208]
    @hack   = $game_actors[207]
    if @master.skills.size > 0 and @master.skills.size != @hack.skills.size or $game_variables[249] / 88318 != @master.skills.size
       for i in 601...694
           @master.forget_skill(i)  if rand(10) > 4
       end
    end  
    @master_skill = @master.skills.select {|skill| skill && skill.is_jm? }.sort{|a,b| a.success_rate <=> b.success_rate }
    @stype_id = 0
    self.opacity = 0
    @data = []
    self.index = 0
  end

  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def create_icon_back
    @_icon = Sprite.new
    @_icon.bitmap = Cache.system("jm_icon_back_kong")
    @_icon.x = 0
    @_icon.y = 181
    @_icon.z = 20

    @size = Sprite.new
    @size.bitmap = Bitmap.new(229,121)
    @size.x = 129
    @size.y = 116
    @size.z = 22

    max_size = $game_party.jm_size
    ge = (max_size.to_s[0,1]).to_i
    @size.bitmap.blt(16,-4,Cache.zdbg("turn_size2"),Rect.new(ge*54,0,54,100))

    if $game_variables[227] / $game_party.jm_size_max == 8493071
      size = $game_party.jm_size_max
      else
      size = 3
    end
    ge = (size.to_s[0,1]).to_i
    @size.bitmap.blt(47,24,Cache.zdbg("turn_size2"),Rect.new(ge*54,0,54,100))
    create_icon_flash
  end

  def create_icon_flash
    @flash = Sprite_Flash.new
    @flash.bitmap = Cache.system("jm_icon_flash")
    @flash.x = 0
    @flash.y = 181
    @flash.z = 14
  end

  def actor=(actor)
    return if @actor == actor
    @actor = actor
    #refresh
    @stype_id = 0
    self.index = 0
  end

  def create_arrow
    @arrow = Sprite.create do |sp|
      sp.attrset :x=>self.x,:y=>self.y,:z=>15,:bitmap=>Cache.hp("jskill_icon_select")
    end
    hide_arrow
  end

  def show_arrow ; @arrow.visible = true  if @arrow ; end

  def hide_arrow ; @arrow.visible = false if @arrow ; end

  def update_cursor
    unless @arrow.nil?
      @arrow.x = self.index%15*57+214-15
      @arrow.y = self.index/15*57+203-16
      #@arrow.visible = @size.visible = self.active
    end
  end

  def add_skill
    skill = @master_skill[self.index]
    size = $game_party.jm_size
    max = $game_party.jm_size_max
    if size < max or @actor.skill_is_learn?(skill.id)
      if @actor.skill_is_learn?(skill.id)
        $game_party.jm_size -= 1 if $game_party.jm_size > 0
        Audio.se_play("Audio/SE/hammer",85,70)
        @actor.forget_skill(skill.id)  
        can_skills?
        refresh
      else
        $game_party.jm_size += 1 
        Audio.se_play("Audio/SE/J_qian",95,70)
        @actor.forget_skill(skill.id)  
        @actor.learn_skill(skill.id) 
        can_skills?
        refresh
      end
      $game_party.members.each do |a|
        a.refresh
      end
      $game_party.house_members.each do |a|
        a.refresh
      end
    else
     Sound.play_buzzer
    end
  end

  def refresh_jm_size
    return unless @size
    @size.bitmap.clear
    max_size = $game_party.jm_size
    ge = (max_size.to_s[0,1]).to_i
    @size.bitmap.blt(16,-4,Cache.zdbg("turn_size2"),Rect.new(ge*54,0,54,100))
    if $game_variables[227] / $game_party.jm_size_max == 8493071
      size = $game_party.jm_size_max
    else
      size = 3
    end
    ge = (size.to_s[0,1]).to_i
    @size.bitmap.blt(47,23,Cache.zdbg("turn_size2"),Rect.new(ge*54,0,54,100))
  end  
  #--------------------------------------------------------------------------
  # ● 光标向下移动
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    super
  end
  #--------------------------------------------------------------------------
  # ● 光标向上移动
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    super
  end

  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def item_max ; 90 end
  def col_max ; 15 end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● 获取技能
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 获取选择项目的有效状态
  #--------------------------------------------------------------------------
  #def current_item_enabled?
      #enable?(@data[index])
 # end
  #--------------------------------------------------------------------------
  # ● 查询列表中是否含有此技能
  #--------------------------------------------------------------------------
  def include?(item)
    item && item.stype_id == @stype_id
  end
  #--------------------------------------------------------------------------
  # ● 查询此技能是否可用
  #--------------------------------------------------------------------------
  def jm_enable?(item)
    #return false if item.nil?
      return true 
  end
  #--------------------------------------------------------------------------
  # ● 生成技能列表
  #--------------------------------------------------------------------------
  def make_item_list
      @data = @master_skill  #.select {|skill| skill.is_jm? }.sort{|a,b| a.success_rate <=> b.success_rate }
      #@data = @data.sort_by {|id| [ $data_states[id].priority, id] }
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个选择的位置
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index(@actor.last_skill.object) || 0)
  end


  def update
    super
    if self.active
      if Input.repeat?(:LEFT) 
         @ind = self.index
      end
      if Input.repeat?(:RIGHT) 
         @ind = self.index
      end
      if Input.repeat?(:UP) 
         @ind = self.index
      end
      if Input.repeat?(:DOWN) 
         @ind = self.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助内容
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    #self.contents.clear
    @_icon.bitmap.clear
    @flash.bitmap.clear
    for i in 0...@data.size
      item = @data[i]
      x  = i%15*57+214 
      y  = i/15*57+22
      x2 = i%15*57+214-20
      y2 = i/15*57+1
      #sp.bitmap.clear if sp.bitmap 

      if @actor.skill_is_learn?(item.id)
        @_icon.bitmap.blt(x,y,Cache.hp("jskill_icon_light") ,Rect.new(0,0,55,65)) 
        @_icon.bitmap.font.size = 17 + $game_variables[300]
        @_icon.bitmap.font.color = Color.new(255,255,255)
        @_icon.bitmap.clear_rect(0,45,55,20)
        @_icon.bitmap.draw_text(x-2,y+35,60,32,"#{item.name}",1) 
        @flash.bitmap.blt(x2,y2,Cache.hp("jskill_icon_flash") ,Rect.new(0,0,95,95)) 
      else
        @_icon.bitmap.blt(x,y,Cache.hp("jskill_icon") ,Rect.new(0,0,55,65)) 
        @_icon.bitmap.font.size = 17 + $game_variables[300]
        @_icon.bitmap.font.color = Color.new(120,120,120)
        @_icon.bitmap.clear_rect(0,45,55,20)
        @_icon.bitmap.draw_text(x-2,y+35,60,32,"#{item.name}",1) 
      end
    end
    if $game_variables[100] == @actor.id
       @size.visible = true
    else
       @size.visible = false
    end
    refresh_jm_size
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    @flash.update
  end

  # => 无需手动释放
  def dispose
    super
    if @arrow ; @arrow.bitmap.dispose ; @arrow.dispose ; end
    if @size ; @size.bitmap.dispose ; @size.dispose ; end
    if @_icon ; @_icon.bitmap.dispose ; @_icon.dispose ; end
    if @flash ; @flash.bitmap.dispose ; @flash.dispose ; end
  end

  def visible=(v)
      super
  end

  def forget_all_skills
      $game_party.jm_size = 0
      for p in 0...$game_party.members.size
         for i in 598...700
            if $data_skills[i].is_jm?
               $game_party.members[p].forget_skill(i)
            end
         end
      end
      can_skills?
  end

  def can_skills?
    if $game_party.exist_jm_skill?(651) 
      $game_variables[112] = 75
    else
      $game_variables[112] = 0
    end

    if $game_party.exist_jm_skill?(617) 
      $game_variables[113] = 250
    else
      $game_variables[113] = 0
    end

    if $game_party.exist_jm_skill?(621) 
       $game_variables[114] = 200
    else
      $game_variables[114] = 0
    end

    if $game_party.exist_jm_skill?(604) 
      $game_variables[115] = 8
    else
      $game_variables[115] = 0
    end

    if $game_party.exist_jm_skill?(652) 
      $game_variables[116] = 100
    else
      $game_variables[116] = 0
    end

    if $game_party.exist_jm_skill?(624)
      $game_variables[119] = 200
    else
      $game_variables[119] = 0
    end

    if $game_party.exist_jm_skill?(626)
      $game_variables[109] = 300
    else
      $game_variables[109] = 0
    end
   
    if $game_party.exist_jm_skill?(608) #暗杀军师天赋
       @actor.learn_skill(190) 
    else
       @actor.forget_skill(190) 
    end

    if $game_party.exist_jm_skill?(659)  #令杀军师天赋
       @actor.learn_skill(188) 
     else
       @actor.forget_skill(188) 
    end

    if $game_party.exist_jm_skill?(661)  #落雷军师天赋
       @actor.learn_skill(113) 
     else
      @actor.forget_skill(113)
    end

    if $game_party.exist_jm_skill?(660)  #陷阱军师天赋
       @actor.learn_skill(189) 
     else
      @actor.forget_skill(189) 
    end


  end

end
