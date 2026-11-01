#encoding:utf-8
#==============================================================================
# ■ Window_MenuStatus
#------------------------------------------------------------------------------
# 　菜单画面中，显示队伍成员状态的窗口
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :pending_index            # 保留位置（整队用）
  attr_accessor :items
  attr_accessor :masks
  attr_accessor :s101                     # 选择角色头像的大圆圈
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y)
    #super(x, y, window_width, window_height)
    @dir = 0
    @pending_index = -1
    @master_char = Sprite.new 
    @master_char.bitmap = Bitmap.new("Graphics/jm/master_char_s")
    @master_char.z = 220
    @master_char.x = 88
    @master_char.opacity = 255
    super(x, y+60, 1200, 680)
    self.x = 0
    @items = []
    @nxcc = 0
    @masks = []
    init_gauge
    refresh
    self.active = false
    self.index = -1
    self.opacity = 0
    self.back_opacity = 0
    self.x = 0

    @s101 = Sprite.new
    @s101.bitmap = Cache.hp("select")
    @s101.x = 10-3
    @s101.y = 10-3
    @s101.z = 100
    @s101.opacity = 0
    if SceneManager.scene_is?(Scene_Item)
      @s101.bitmap = Cache.hp("select_2")
    end
    if SceneManager.scene_is?(Scene_Marv)
      @s101.bitmap = Cache.hp("select_3")
    end
  end

  # 初始化 精灵
  def init_gauge
    @items.clear
    @masks.clear
    $game_party.members.each_with_index do |actor,index|
      mskh = {}
      sp1 = Sprite.new; 

      if actor.tp != 100
      sp1.attrset(:x=>x+155+9,:y=>160-24+index*116,:z=>0,:bitmap=>Cache.hp("hp"))
      else
      sp1.attrset(:x=>x+155+9,:y=>160-24+index*116,:z=>0,:bitmap=>Cache.hp("hp_100"))
      end
      sp1.src_rect = Rect.new(0,0,200,30)
        sp2 = Sprite.new; 
        if actor.hp == 0
        sp2.attrset(:x=>x+89,:y=>79-24+index*116,:z=>99,:bitmap=>Cache.hp("face_bk_dead")) 
        else
        sp2.attrset(:x=>x+89,:y=>79-24+index*116,:z=>99,:bitmap=>Cache.hp("face_bk"))
        end
        sp2.attrset(:opacity=>0) if index > 4
        if actor.id == $game_variables[100]
          @master_char.y = 88+index * 116
          @master_char.opacity = 255
          @master_char.opacity = 0 if index > 4
        else
          @master_char.opacity = 0 if index > 4
        end
      if index < 5
        sp3 = Sprite.new; 
        sp3.attrset(:x=>x+89-1,:y=>77-24+index*116,:z=>100,:bitmap=>Cache.hp("hpk"))
      end
      hpmask = Sprite.new; w = 0;
      if actor.hp < actor.mhp
        bitmap_hp = Bitmap.new(w = 200-200*actor.hp/actor.mhp,11)
        bitmap_hp.fill_rect(0,0,bitmap_hp.width,bitmap_hp.height,hp_gauge_color2)
        bitmap_hp.fill_rect(0,0,1,bitmap_hp.height,Color.new(0,0,0))
      end
      hpmask.attrset(:x=>x+365-w-1,:y=>160-24+index*116,:z=>5,:bitmap=>bitmap_hp)

      mpmask = Sprite.new; w = 0; 
      if actor.mp < actor.mmp
        bitmap_mp = Bitmap.new(w = 200-200*actor.mp/actor.mmp,5)
        bitmap_mp.fill_rect(0,0,bitmap_mp.width,bitmap_mp.height,hp_gauge_color2)
        bitmap_mp.fill_rect(0,0,1,bitmap_mp.height,Color.new(0,0,0))
      end
      mpmask.attrset(:x=>x+365-w-1,:y=>173-24+index*116,:z=>5,:bitmap=>bitmap_mp)

       apmask = Sprite.new; w = 0;
       if actor.tp < actor.mtp
          bitmap_ap = Bitmap.new(w = 79-(79.0*actor.tp/actor.mtp).to_i,10)
          bitmap_ap.fill_rect(0,0,bitmap_ap.width,5,Color.new(60,60,60,255))
          bitmap_ap.fill_rect(0,5,bitmap_ap.width,5,Color.new(30,30,30,255))
       end
       apmask.attrset(:x=>x+307-w-1-27-35,:y=>179-23+index*116,:z=>5,:bitmap=>bitmap_ap)

      @items << {:actor=>actor,:hp=>sp1,:face=>sp2,:hpk=>sp3,:hpmsk=>hpmask,:mpmsk=>mpmask,:apmsk=>apmask}
      @masks << {:hpmsk=>[hpmask.x,hpmask.bitmap.nil? ? 0 : hpmask.bitmap.width],
                 :mpmsk=>[mpmask.x,mpmask.bitmap.nil? ? 0 : mpmask.bitmap.width],
                 :apmsk=>[apmask.x,apmask.bitmap.nil? ? 0 : apmask.bitmap.width]}
    end
  end


  # 队伍改变时重置mask
  def reset_guage
    dispose_mask
    init_gauge
  end

  def create_mask_bitmap(actor,type)
    case type
    when :hp
      bitmap = Bitmap.new(w = 200-200*actor.hp/actor.mhp,11)
      bitmap.fill_rect(0,0,bitmap.width,bitmap.height,hp_gauge_color2)
    when :mp
      bitmap = Bitmap.new(w = 200-200*actor.mp/actor.mmp,5)
      bitmap.fill_rect(0,0,bitmap.width,bitmap.height,mp_gauge_color2)
    when :ap
      bitmap = Bitmap.new(w = 79-(79.0*actor.tp/actor.mtp).to_i,10)
      #bitmap.fill_rect(0,0,bitmap.width,bitmap.height,Color.new(160,60,60,255))
      bitmap.fill_rect(0,0,bitmap.width,5,Color.new(60,60,60,255))
      bitmap.fill_rect(0,5,bitmap.width,5,Color.new(30,30,30,255))
    end
    bitmap
  end

  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item_max = $game_party.members.size
    for actor in $game_party.members
      draw_actor_face(actor, self.x + 76+4, actor.index * 116 + 18-21, 92,actor.hp > 0)
      x = self.x + 180
      y = actor.index * 116# + WLH / 2
      contents.font.size = 20 + $game_variables[300]+2
      contents.font.name = "Noto"
      if actor.name.length == 2
        draw_actor_name(actor, x-114, y+69-32)
      else
        draw_actor_name(actor, x-114-18, y+69-32)
      end
      contents.font.name = "Noto"
      contents.font.size = 17 + $game_variables[300]+2
      draw_actor_level(actor, x-90-40, y+65-1) if actor.level >= 10
      draw_actor_level(actor, x-90-32, y+65-1) if actor.level < 10
      contents.font.size = 21 + $game_variables[300]+1
      draw_text(x+83+2, y+63-27-4, 55, line_height, actor.hp, 0)
      contents.font.size = 21 + $game_variables[300]+1
      draw_text(x+132+29, y+79-43-4, 55, line_height, actor.mp, 0)
      draw_actor_icons(actor, x-28+10, y+5)
    end   
  end

  def refresh_gauge
    x = self.x
    #@masks.clear
    @items.each_with_index do |item,i|
      if top_row == 1
        unless @items[i+1].nil?
          actor = @items[i+1][:actor]
        end
      end
      if top_row == 2
        unless @items[i+2].nil?
          actor = @items[i+2][:actor]
        end
      end
      actor = item[:actor] if top_row == 0
      #actor = item[:face] if top_row == 0
      unless actor.nil?
        unless item[:hpmsk].bitmap.nil?
          item[:hpmsk].bitmap.clear
          w1 = 200-200*actor.hp/actor.mhp
          item[:hpmsk].attrset(:x=>x+365-w1-1)
          item[:hpmsk].bitmap.fill_rect(0,0,w1,item[:hpmsk].bitmap.height,hp_gauge_color2)
        else
          if actor.hp < actor.mhp
            item[:hpmsk].bitmap = create_mask_bitmap(actor,:hp)
            w1 = 200-200*actor.hp/actor.mhp
            item[:hpmsk].attrset(:x=>x+365-w1-1)
            item[:hpmsk].bitmap.fill_rect(0,0,w1,item[:hpmsk].bitmap.height,hp_gauge_color2)
            p [item[:hpmsk].y]
          end
        end
        unless item[:mpmsk].bitmap.nil?
          item[:mpmsk].bitmap.clear
          w2 = 200-200*actor.mp/actor.mmp
          item[:mpmsk].attrset(:x=>x+365-w2-1)
          item[:mpmsk].bitmap.fill_rect(0,0,w2,item[:mpmsk].bitmap.height,hp_gauge_color2)
        else
          if actor.mp < actor.mmp
            item[:mpmsk].bitmap = create_mask_bitmap(actor,:mp)
            w2 = 200-200*actor.mp/actor.mmp
            item[:mpmsk].attrset(:x=>x+365-w2-1)
            item[:mpmsk].bitmap.fill_rect(0,0,w2,item[:mpmsk].bitmap.height,hp_gauge_color2)
          end
        end

         unless item[:apmsk].bitmap.nil?
           item[:apmsk].bitmap.clear
           w3 =79-(79.0*actor.tp/actor.mtp).to_i
           item[:apmsk].attrset(:x=>x+307-w3-1)
           item[:apmsk].bitmap.fill_rect(0,0,w3,item[:apmsk].bitmap.height,hp_gauge_color2)
         else
           if actor.tp < actor.mtp
             item[:apmsk].bitmap = create_mask_bitmap(actor,:ap)
             w3 = 79-(79.0*actor.tp/actor.mtp).to_i
             item[:apmsk].attrset(:x=>x+307-w3-1)
             #item[:apmsk].bitmap.fill_rect(0,0,w3,item[:apmsk].bitmap.height,hp_gauge_color2)
              item[:apmsk].bitmap.fill_rect(0,0,w3,5,Color.new(60,60,60,255))
              item[:apmsk].bitmap.fill_rect(0,5,w3,5,Color.new(30,30,30,255))
           end
         end
        h = {:hpmsk=>[item[:hpmsk].x,w1.nil? ? 0 : w1],
                     :mpmsk=>[item[:mpmsk].x,w2.nil? ? 0 : w2],
                     :apmsk=>[item[:apmsk].x,w3.nil? ? 0 : w3]}
        @masks[i] = h if top_row == 0
        @masks[i+1] = h if top_row == 1
        @masks[i+2] = h if top_row == 2
      end
      #refresh_mask
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 160
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    $game_party.members.size
  end
  #--------------------------------------------------------------------------
  # ● 获取项目的高度
  #--------------------------------------------------------------------------
  def item_height
    (height - standard_padding * 2) / 4
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_face(actor, rect.x + 1, rect.y + 1, 96,enabled)
    #draw_actor_simple_status(actor, rect.x + 108, rect.y + line_height / 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目的背景
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  #--------------------------------------------------------------------------
  # ● 按下确定键时的处理
  #--------------------------------------------------------------------------
  def process_ok
    super
    $game_party.menu_actor = $game_party.members[index]
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个选择的位置
  #--------------------------------------------------------------------------
  def select_last
    select($game_party.menu_actor.index || 0)
  end
  #--------------------------------------------------------------------------
  # ● 设置保留位置（整队用）
  #--------------------------------------------------------------------------
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
  #--------------------------------------------------------------------------
  # ● 更新光标
  #--------------------------------------------------------------------------
  def update_cursor
    if @cursor_all
      cursor_rect.set(71, 12, 101, 568)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
  end

  def ensure_cursor_visible
    if row < top_row
      @dir = 8
      self.top_row = row
      refresh_mask
    end
    if row > bottom_row
      @dir = 2
      self.bottom_row = row
      refresh_mask
    end

    refresh_dead_icon
    refresh_jm_icon  
    refresh_actor_tp100
  end

  def refresh_actor_tp100
    if $game_party.members.size > 5
      e = 5
    else
      e = $game_party.members.size
    end
    for i in 0...e
      if top_row == 1 and bottom_row == 5 
        if $game_party.members[i+1] !=nil and $game_party.members[i+1].tp == 100 
          @items[i][:hp].attrset(:bitmap=>Cache.hp("hp_100"))  
        else
          @items[i][:hp].attrset(:bitmap=>Cache.hp("hp")) 
        end  
      elsif $game_party.members[i+2] !=nil and  top_row == 2 and bottom_row == 6 
       if $game_party.members[i+2].tp == 100
          @items[i][:hp].attrset(:bitmap=>Cache.hp("hp_100"))  
       else
          @items[i][:hp].attrset(:bitmap=>Cache.hp("hp")) 
       end
      else
       if $game_party.members[i] !=nil and  $game_party.members[i].tp == 100 
          @items[i][:hp].attrset(:bitmap=>Cache.hp("hp_100"))  
       else
          @items[i][:hp].attrset(:bitmap=>Cache.hp("hp")) 
       end
          update_hp
      end
    end
  end

     
  #死亡标志头像，和军师标志，在换行时的操作
  def refresh_dead_icon
    for actor in $game_party.members
      @items[actor.index][:face].attrset(:opacity=>255,:x=>x+89,:y=>79-24+actor.index*116)  if top_row == 0 
      @items[5][:face].attrset(:opacity=>0,:x=>x+89,:y=>79-24+actor.index*116) if $game_party.members.size > 5 and top_row == 0
      if top_row == 1 and bottom_row == 5 and actor.index < 5
        @items[0][:face].attrset(:opacity=>0,:x=>x+89,:y=>79-24+actor.index*116) 
        @items[actor.index.to_i + 1][:face].attrset(:opacity=>255,:x=>x+89,:y=>79-24+actor.index*116) 
      end
      if top_row == 2 and bottom_row == 6 and actor.index < 5
        @items[0][:face].attrset(:opacity=>0,:x=>x+89,:y=>79-24+actor.index*116) 
        @items[1][:face].attrset(:opacity=>0,:x=>x+89,:y=>79-24+actor.index*116) 
        @items[actor.index.to_i + 2][:face].attrset(:opacity=>255,:x=>x+89,:y=>79-24+actor.index*116)     
      end
    end   
  end

  def refresh_jm_icon
    @master_char.opacity = 0
    for i in 0...$game_party.members.size
      if $game_party.members[i].id == $game_variables[100] and top_row == 0 and i < 5
        @master_char.y = 88+i * 116
        @master_char.opacity = 255
      end
      if $game_party.members[i].id == $game_variables[100] and top_row == 0 and i > 4
        @master_char.opacity = 0
      end
      if $game_party.members.size > 5 and i < 5 and $game_party.members[i+1].id == $game_variables[100] and top_row == 1 
        @master_char.y = 88+i * 116
        @master_char.opacity = 255
      end
      if i < 1 and $game_party.members[i].id == $game_variables[100] and top_row == 1 
        @master_char.opacity = 0
      end
      if i > 5 and $game_party.members[i].id == $game_variables[100] and top_row == 1 
        @master_char.opacity = 0
      end
      if $game_party.members.size > 6 and i < 5 and $game_party.members[i+2].id == $game_variables[100] and top_row == 2 
        @master_char.y = 88+i * 116
        @master_char.opacity = 255
      end
      if i < 2 and $game_party.members[i].id == $game_variables[100] and top_row == 2 
        @master_char.opacity = 0
      end
      if i < 1 and $game_party.members[i].id == $game_variables[100] and top_row == 2 
        @master_char.opacity = 0
      end
    end 
  end   

  def refresh_mask
    @items.each_with_index do |item,i|
      mask = @masks[i] if top_row == 0
      mask = @masks[i+1] if top_row == 1
      mask = @masks[i+2] if top_row == 2
      #item[:hpmsk].bitmap = @masks[i][:hpmsk].bitmap
      unless mask.nil?
        item[:hpmsk].x = mask[:hpmsk][0]
        item[:hpmsk].bitmap.clear unless item[:hpmsk].bitmap.nil?
        unless mask[:hpmsk][1].zero?
          item[:hpmsk].bitmap = Bitmap.new(mask[:hpmsk][1],11)
          item[:hpmsk].bitmap.fill_rect(0,0,item[:hpmsk].bitmap.width,item[:hpmsk].bitmap.height,hp_gauge_color2)
        end
        item[:mpmsk].x = mask[:mpmsk][0]
        item[:mpmsk].bitmap.clear unless item[:mpmsk].bitmap.nil?
        unless mask[:mpmsk][1].zero?
          item[:mpmsk].bitmap = Bitmap.new(mask[:mpmsk][1],5)
          item[:mpmsk].bitmap.fill_rect(0,0,item[:mpmsk].bitmap.width,item[:mpmsk].bitmap.height,hp_gauge_color2)
        end
        item[:apmsk].x = mask[:apmsk][0]
        item[:apmsk].bitmap.clear unless item[:apmsk].bitmap.nil?
        unless mask[:apmsk][1].zero?
          item[:apmsk].bitmap = Bitmap.new(mask[:apmsk][1],10)
          item[:apmsk].bitmap.fill_rect(0,0,item[:apmsk].bitmap.width,5,Color.new(60,60,60,255))
          item[:apmsk].bitmap.fill_rect(0,5,item[:apmsk].bitmap.width,5,Color.new(30,30,30,255))
        end
      end
    end
 end

  def item_rect(index)
    rect = Rect.new
    rect.y = index/ col_max * 116

    @s101.x = 84 ; @s101.opacity = 255

    if top_row == 0
      @s101.y = rect.y + 49
    end
    if top_row == 1
      if index < bottom_row
        @s101.y = rect.y + 49 - 116#item_height
      else
        @s101.y = 511+2     
      end
    end
    if top_row == 2
      if index < bottom_row
        @s101.y = rect.y + 49 - 116 * 2
      else
        @s101.y = 511+2
      end
    end

    rect
  end

  def item_height
    return 116
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   @s101.bitmap.dispose
  #   @s101.dispose
  #   if @master_char != nil 
  #     @master_char.bitmap.dispose
  #     @master_char.dispose
  #   end
  #   dispose_mask
  # end

  def dispose_mask
    @items.each do |item|
      unless item[:hp].nil?
        item[:hp].bitmap.dispose unless item[:hp].bitmap.nil?
        item[:hp].dispose 
      end
      unless item[:hpk].nil?
        item[:hpk].bitmap.dispose unless item[:hpk].bitmap.nil?
        item[:hpk].dispose
      end
      unless item[:face].nil?
        item[:face].bitmap.dispose unless item[:face].bitmap.nil?
        item[:face].dispose
      end
      unless item[:hpmsk].nil?
        item[:hpmsk].bitmap.dispose unless item[:hpmsk].bitmap.nil?
        item[:hpmsk].dispose
      end
      unless item[:mpmsk].nil?
        item[:mpmsk].bitmap.dispose unless item[:mpmsk].bitmap.nil?
        item[:mpmsk].dispose
      end
       unless item[:apmsk].nil?
         item[:apmsk].bitmap.dispose unless item[:apmsk].bitmap.nil?
         item[:apmsk].dispose
       end
    end
  end

  def dispose_item(index)
    item = @items.delete_at(index)
    unless item[:hp].nil?
      item[:hp].bitmap.dispose unless item[:hp].bitmap.nil?
      item[:hp].dispose 
    end
    unless item[:hpk].nil?
      item[:hpk].bitmap.dispose unless item[:hpk].bitmap.nil?
      item[:hpk].dispose
    end
    unless item[:face].nil?
      item[:face].bitmap.dispose unless item[:face].bitmap.nil?
      item[:face].dispose
    end
    unless item[:hpmsk].nil?
      item[:hpmsk].bitmap.dispose unless item[:hpmsk].bitmap.nil?
      item[:hpmsk].dispose
    end
    unless item[:mpmsk].nil?
      item[:mpmsk].bitmap.dispose unless item[:mpmsk].bitmap.nil?
      item[:mpmsk].dispose
    end
     unless item[:apmsk].nil?
       item[:apmsk].bitmap.dispose unless item[:apmsk].bitmap.nil?
       item[:apmsk].dispose
     end
    @masks.delete_at(index)
  end

  def update
    self.x = 0
    super
    return unless self.visible
    @nxcc += 1 
    @nxcc %= 100 
    update_hp
  end

   def update_hp
       return if @items[0][:hp].bitmap.disposed?
       @xbit = @nxcc / 10 * @items[0][:hp].bitmap.height/10
       @items.each do |item|
       b = item[:hp].bitmap
       item[:hp].src_rect.set(0, @xbit, b.width, b.height/10)
       end
  end



  def visible=(t)
    super
    @s101.visible = t
    @master_char.visible = t
    @items.each do |item|
      item[:hp].opacity = ((item[:hp].visible = t) ? 255 : 0)
      item[:hpk].opacity = ((item[:hpk].visible = t) ? 255 : 0) unless item[:hpk].nil?
      item[:face].opacity = ((item[:face].visible = t) ? 255 : 0) unless item[:face].nil?
      item[:hpmsk].opacity = ((item[:hpmsk].visible = t) ? 255 : 0)
      item[:mpmsk].opacity = ((item[:mpmsk].visible = t) ? 255 : 0)
      item[:apmsk].opacity = ((item[:apmsk].visible = t) ? 255 : 0)
    end
  end
end
