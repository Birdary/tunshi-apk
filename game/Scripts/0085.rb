#encoding:utf-8
#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　存档画面和读档画面中显示存档文件的窗口。
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :selected                 # 选择状态
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     index : 存档文件的索引
  #--------------------------------------------------------------------------
  def initialize(height, index)
    super(50, index * height+58-20, 430+600, 67+30)
    @file_index = index
    self.opacity = 0
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    contents.font.size = 20 + ($game_variables[300])
    draw_party_stage(-80, 1)
    draw_party_face(435, 11)
    @k = 0 if @k == nil
    #draw_party_characters(100+175+58+58*@k, 63)
    # draw_playtime(60, 25+@file_index-50, contents.width - 4, 2)
    draw_playtime(320, 30-1, 100, 20)
    draw_2nd(37, 0, 100, 20)
    draw_zaoyi
  end

    #name = "#{@file_index + 1}"
    #draw_text(258-20, 25+@file_index-50, 200, line_height, name)
   # draw_text(32, 30, 200, line_height, name)
    #@name_width = text_size(name).width
  def draw_zaoyi
    header = DataManager.load_header(@file_index)
    return unless header
    return if header[:zaoyi] == nil
    name = header[:zaoyi].to_s
    draw_text(953, 30-1, 200, line_height, name,0)
        @name_width = text_size(name).width
  end
  #--------------------------------------------------------------------------
  # ● 绘制队伍角色
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    header[:characters].each_with_index do |data, i|
      draw_character(data[0], data[1], x + i * 42, y)
    end
  end

  #--------------------------------------------------------------------------
  # ● 绘制队伍角色头像
  #--------------------------------------------------------------------------
  def draw_party_face(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    return if header[:actors] == nil 
    header[:actors].each_with_index do |data, i|
      draw_sface(data[0], data[1], x + i * 58, y)
      @k = i
    end
  end

  #--------------------------------------------------------------------------
  # ● 绘制章节数
  #--------------------------------------------------------------------------
  def draw_party_stage(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    return if header[:stage] == nil 
    #msgbox header[:stage]
    #header[:stage]#.each_with_index do |i|
      draw_stage("s"+header[:stage].to_s,x,y)
   # end
  end

  def kong?
    header = DataManager.load_header(@file_index)
    return false unless header
    return false if header[:stage] == nil 
    return true
  end
  #--------------------------------------------------------------------------
  # ● 绘制游戏时间
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height, header[:playtime_s], 0)
  end

  def draw_2nd(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    if header[:nd] == true

       cc = header[:nd_size].to_i
       cc = 25  if header[:nd_size] == nil 
       cc = 1 + cc/25.round
       contents.font.size = 16 + $game_variables[300]
       #contents.font.color = Color.new(255,220,0,255)
       if cc == 2
          draw_text(x, y, width, line_height, "2nd Mode", 0)
        else
          draw_text(x, y, width, line_height, "#{cc}"+"th Mode", 0)
       end
       contents.font.size = 20 + $game_variables[300]
       #contents.font.color = normal_color
    end   
  end
  #--------------------------------------------------------------------------
  # ● 设置选择状态
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● 更新光标
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
        cursor_rect.set(33, 18, 396, 44)
     # case @file_index
     # when 0 ; cursor_rect.set(154+6, 67 * @file_index, 118+235, 40)
     # when 1 ; cursor_rect.set(154+6, 0, 118+235, 40)
      #when 2 ; cursor_rect.set(154+6, 0 * @file_index, 118+235, 40)
     # when 3 ; cursor_rect.set(154+6, 67 * @file_index, 118+235, 40)
     # when 4 ; cursor_rect.set(154+6, 67 * @file_index, 118+235, 40)
     # when 5 ; cursor_rect.set(154+6, 67 * @file_index, 118+235, 40)
     # when 6 ; cursor_rect.set(154+6, 67 * @file_index, 118+235, 40)
     # when 7 ; cursor_rect.set(154+6, 67 * @file_index, 118+235, 40)
     # end
    else
      cursor_rect.empty
    end
  end
end


