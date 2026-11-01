#encoding:utf-8
#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　技能画面中，显示技能的窗口。
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height,type=nil)
    super(x,y,width,height)
    @type = type
    @actor = nil
    @stype_id = 0
    self.opacity = 0
    @data = []
    self.index = 0
    @skillpicture = Sprite.new
    @skillpicture.bitmap = Cache.skillp("0")
    @skillpicture.z = 220
  end
  def type=(type)
    @type = type
  end
  def set_type(stype)
    @type = stype
    case @type
    when :marv
      stype_id = 1
    when :skill
      stype_id = 2
    when :formation
      stype_id = 3
    when :jm
      stype_id = 5
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    set_skill_p
    @stype_id = 0
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 光标向下移动
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    super
    set_skill_p
  end
  #--------------------------------------------------------------------------
  # ● 光标向上移动
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    super
    set_skill_p
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   if @skillpicture ; @skillpicture.bitmap.dispose ; @skillpicture.dispose ; end
  # end

  def set_skill_p

    return if $game_party.in_battle
    if item.nil?
       @skillpicture.bitmap =Cache.skillp("0")
       return
    end
    id = item.id
     @skillpicture.bitmap = Cache.skillp( (@type==:formation ? "#{id}"+"-t" : "0"))
     @skillpicture.opacity = 255
  end

    def set_skill_p_opacity
    return if $game_party.in_battle
    @skillpicture.opacity = 0 
    end
  #--------------------------------------------------------------------------
  # ● 设置技能类型 ID 
  #--------------------------------------------------------------------------
  def stype_id=(stype_id)
    return if @stype_id == stype_id
    @stype_id = stype_id
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
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
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ● 查询列表中是否含有此技能
  #--------------------------------------------------------------------------
  def include?(item)
    item && item.stype_id == @stype_id
  end
  #--------------------------------------------------------------------------
  # ● 查询此技能是否可用
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item.nil?
    if @type == :formation 
       if SceneManager.scene.is_a?(Scene_Battle)
          return false if item.id == $game_party.formation.id 
       else
          return false if item.id == $game_variables[108]
       end
          
       if item.id == 13
          if SceneManager.scene.is_a?(Scene_Battle)
             return true 
          else
             return false
          end
       elsif item.id == 15
          team = [3,4,5,6,7]
          for i in 0...$game_party.alive_members.size
              team.delete($game_party.alive_members[i].id)
          end
          if  team.empty?
              return true if SceneManager.scene.is_a?(Scene_Battle)
          else
              return false
          end
       elsif  item.id == 12
          if  SceneManager.scene.is_a?(Scene_Battle)
              return true 
          else
              return false
          end
       elsif  item.id == 19 #云龙阵必须
          if  @actor.state?(84)#$game_party.item_number($data_items[9]) > 0
              return true if SceneManager.scene.is_a?(Scene_Battle)
          else
              return false
          end
       else  
          $game_party.alive_members.size >= 5 && $game_party.boost >= item.hh.to_i
       end
  else
      if @type == :jm
         @actor.id == $game_variables[100]
      end
      @actor && @actor.usable?(item)
    end
end
  #--------------------------------------------------------------------------
  # ● 生成技能列表
  #--------------------------------------------------------------------------
  def make_item_list
    case @type
    when :marv
      @data = @actor ? @actor.skills.select {|skill| skill.is_marv? } : []
    when :skill
       if @actor.id == $game_variables[100]
          @data = @actor ? @actor.skills.select {|skill| skill.is_skill? or skill.is_jm?} : []
       else
          @data = @actor ? @actor.skills.select {|skill| skill.is_skill? } : []
       end
    when :formation
      @data = @actor ? @actor.skills.select {|skill| skill.is_formation? } : []
    when :jm  
      @data = @actor ? @actor.skills.select {|skill| skill.is_jm? } : []
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个选择的位置
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index(@actor.last_skill.object) || 0)
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
      skill = @data[index]
  if  skill
      if  skill.is_jm? 
      rect = item_rect(index)
      rect.width -= 4
      rect.y -=1
           if SceneManager.scene.is_a?(Scene_Battle)
           draw_item_name(skill, rect.x, rect.y, enable?(skill)) if @actor.id == $game_variables[100]
           else
           draw_item_name(skill, rect.x, rect.y, false) if @actor.id == $game_variables[100]
           end
      rect.y +=1
      draw_skill_cost(rect, skill)
      else
      rect = item_rect(index)
      rect.width -= 4
      rect.y -=1
           if SceneManager.scene.is_a?(Scene_Battle)
               
           else
                   if skill.is_marv?
                       if enable?(skill)
                       draw_item_name(skill, rect.x, rect.y, enable?(skill)) 
                       else
                       draw_item_name(skill, rect.x, rect.y, enable?(skill)) 
                       end
                   else
                   draw_item_name(skill, rect.x, rect.y, enable?(skill)) 
                   end
           end  
      rect.y +=1
      draw_skill_cost(rect, skill)
      end
  end
  end
  #--------------------------------------------------------------------------
  # ● 绘制技能的使用消耗
  #--------------------------------------------------------------------------
  def draw_skill_cost(rect, skill)
    # if @actor.skill_tp_cost(skill) > 0
    #   change_color(tp_cost_color, enable?(skill))
    #   draw_text(rect, @actor.skill_tp_cost(skill), 2)
    # elsif @actor.skill_mp_cost(skill) > 0
    #   change_color(mp_cost_color, enable?(skill))
    #   draw_text(rect, @actor.skill_mp_cost(skill), 2)
    # end
    if skill.is_marv?
      if @actor.skill_mp_cost(skill) >= 0
        change_color(mp_cost_color, enable?(skill))
        if SceneManager.scene.is_a?(Scene_Battle)
        draw_text(rect, "#{@actor.skill_mp_cost(skill)}", 2)
        else
             if enable?(skill)
             draw_text(rect, "#{@actor.skill_mp_cost(skill)}", 2)
             draw_text(rect, "                    「可用」", 0)
             else
             draw_text(rect, "#{@actor.skill_mp_cost(skill)}", 2)
             end
        end
      end
    end
    if skill.is_skill?
      if @actor.skill_tp_cost(skill) >= 0
        if @actor.skill_tp_cost(skill) == 0 and skill.id != 341
             if SceneManager.scene.is_a?(Scene_Battle)
             change_color(tp_cost_color,enable?(skill))
             draw_text(rect, "", 2)
             draw_text(rect, "#{@actor.level * 20}", 2) if skill.id == 341 #金钱技能要求
             else
             change_color(tp_beidong_color)
             draw_text(rect, "被动", 2)
             end
        else
            if SceneManager.scene.is_a?(Scene_Battle)
            change_color(tp_cost_color,enable?(skill))
                          contents.font.size = 14 + $game_variables[300]
                          case @actor.skill_tp_cost(skill)
                         # when 33
                          #draw_text(rect, "●", 2)
                         # when 66
                         # draw_text(rect, "●", 2)
                          when 100
                          draw_text(rect, "●", 2)
                          end
                          contents.font.size = 18 + $game_variables[300]
            else
            change_color(tp_jiangji_color)
            draw_text(rect, "将技", 2)
            end
        end
      end
    end
    if skill.is_formation?
         if  SceneManager.scene.is_a?(Scene_Battle)
                 change_color(cp_cost_color, enable?(skill))
                 draw_text(rect, @actor.skill_cp_cost(skill), 2)
         else
             if skill.id == $game_variables[108] and $game_party.alive_members.size > 4 #如果设置阵法，并且人数大于4人
                change_color(mp_cost_color, enable?(skill))
                draw_text(rect, "                    「当前阵型」", 0)
             else
                if skill.id == 12 or skill.id == 13 or skill.id == 15 or skill.id == 19
                   change_color(Color.new(255,0,0,255), (skill))
                   draw_text(rect, "战斗", 2)
                else
                   change_color(Color.new(200,200,200,255), (skill))
                   draw_text(rect, "普通", 2)
                end
             end
         end 
    end
    if skill.is_jm?
      if @actor.id == $game_variables[100]
                 if SceneManager.scene.is_a?(Scene_Battle)
                 change_color(tp_cost_color,enable?(skill))
                 draw_text(rect, "", 2)
                 else
                 change_color(jm_cost_color)
                 draw_text(rect, "军师", 2)
                 end 
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
    create_contents
    draw_all_items
  end
  def dispose
    super
  end

  def visible=(v)
    super

  end

end
