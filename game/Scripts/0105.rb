#encoding:utf-8
#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　物品画面中，显示持有物品的窗口。
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @category = :none
    @data = []
  end
  #--------------------------------------------------------------------------
  # ● 设置分类
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
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
  # ● 查询列表中是否含有此物品
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
       item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
       item.is_a?(RPG::Weapon)
    when :armor
       item.is_a?(RPG::Armor)
    when :key_item
       item.is_a?(RPG::Item) && item.key_item?
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 查询此物品是否可用
  #--------------------------------------------------------------------------
  def enable?(item)
    $game_party.usable?(item)
  end

  def battle_item_size(item)

  end  
  #--------------------------------------------------------------------------
  # ● 生成物品列表
  #--------------------------------------------------------------------------
  def make_item_list
      if $game_party.in_battle
         s = []
         s = [1,2,3,4,11,12,13,30,31,50,14,29,61,17,18,19,20]
         for i in 0...s.size
             id = s[i]
         @data +=  $game_party.all_items.select {|item| item.id == id and item.is_a?(RPG::Item)}
         end
         @data +=  $game_party.all_items.select {|item| include?(item) and enable?(item) and ( !s.include?(item.id) and item.is_a?(RPG::Item) )}
      else
         @data =  $game_party.all_items.select {|item| include?(item) and enable?(item) }
         @data += $game_party.all_items.select {|item| include?(item) and !enable?(item) }
      end
      @data.push(nil) if include?(nil)
      @data.uniq!
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个选择的位置
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制物品个数
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
  #如果速度大于90则判断为事件道具，不显示个数。
  if SceneManager.scene.is_a?(Scene_Item) or SceneManager.scene.is_a?(Scene_Battle) or SceneManager.scene.is_a?(Scene_Equip)
    draw_text(rect, sprintf("x%2d", $game_party.item_number(item)), 2) 
  end

  if SceneManager.scene.is_a?(Scene_Cj) and item.id == 300  #300号物品，区分事件主线和支线
    draw_text(rect, sprintf(" %2d", $game_party.item_number(item)), 2) 
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
end
