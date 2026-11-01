#encoding:utf-8
class Window_Mapstatus < Window_Base
  #--------------------------------------------------------------------------
  # ◎ 初始化对象
  # 
  #--------------------------------------------------------------------------
  def initialize
    super(0, 504+150, 0, 0) 
    @move = 0
    @sp = []
    @mask = []
    @formation = Sprite.new
    @formation.bitmap = Bitmap.new("Graphics/hp/formation_a/4")
    @formation.x = 0
    @formation.y = 575
    @formation.z = 120 + 10

    @master = Sprite.new
    @master.bitmap = Bitmap.new("Graphics/jm/master_char_map")
    @master.x = 0
    @master.y = 600
    @master.z = 120 + 10
    @master.opacity = 0

    @cname_font = Sprite.new
    @cname_font.bitmap = Cache.hp("re_cname")
    @cname_font.x = 1092+188
    @cname_font.x = 1092 if $game_switches[488] == true 
    @cname_font.y = 47
    @cname_font.z = 121 + 10
    @cname_font.opacity = 0

    @cname_back = Sprite.new
    @cname_back.bitmap = Cache.hp("cname")
    @cname_back.x = 1092+188
    @cname_back.x = 1092 if $game_switches[488] == true 
    @cname_back.y = 47
    @cname_back.z = 120 + 10
    @cname_back.opacity = 0
    @cname_back.tone = Tone.new(255,255,255,0)  if $game_switches[488] != true

    @map_key = Sprite.new
    @map_key.bitmap = Cache.system("map_key0")
    @map_key.x = 1132+23
    @map_key.y = 579+1
    @map_key.z = 121 + 10
    re_map_key

    @now = Sprite.new
    @now.bitmap = Cache.system("now_0")
    @now.x = 530
    @now.y = 537
    @now.z = 999
    @now.opacity = 0
    @now.visible = false


    @hp_no = Sprite.new
    @hp_no.bitmap = Cache.hp("mapstatusbar_no")
    @hp_no.x = -30
    @hp_no.y = 651
    @hp_no.z = 101 + 10

    @hp_7 = Sprite.new
    @hp_7.bitmap = Cache.hp("mapstatusbg07")
    @hp_7.y = 568
    @hp_7.z = 100 + 10

    #黑底
    @hp_5 = Sprite.new
    @hp_5.bitmap = Cache.hp("mapstatusbg05")         
    @hp_5.x = 58-23+27
    @hp_5.y = 568
    @hp_5.z = 90 + 10

    #左侧固定
    @hp_0 = Sprite.new
    @hp_0.bitmap = Cache.hp("mapstatusbg00")                   
    @hp_0.y = 568
    @hp_0.z = 100 + 10
    @hp_0.x = 0

     #右侧收尾
    @hp_3 = Sprite.new
    @hp_3.bitmap = Cache.hp("mapstatusbg02")
    @hp_3.y = 568
    @hp_3.z = 99 + 10

    #遮照框
    @hp_2 = Sprite.new
    if $game_party.hp >=10000
       @hp_2.bitmap = Cache.hp("mapstatusbg01_w")
    else
       @hp_2.bitmap = Cache.hp("mapstatusbg01")
    end
    @hp_2.x = 58-23
    @hp_2.y = 568
    @hp_2.z = 101 + 10

    @hp = Sprite.new
    @hp.bitmap = Cache.hp("mapstatusbar")
    @hp.x = 58-23+26
    @hp.y = 675
    @hp.z = 90  + 10

    refresh

    self.opacity = 0
    self.z = 200
    great_100
    refresh_100
    great_200
    refresh_200
    if $game_switches[488] == true
      re_cname_quick if $hei == 0
      $game_switches[488] = false
    else
      re_cname if $hei == 0
    end
  end

  #护身烟系列
  def great_100
    if $game_variables[123] > 0 and @hsy_back == nil and $game_switches[600] == false
      if @hsy_back
        @hsy_back.bitmap.dispose 
        @hsy_back.dispose  
      end
      if @hsy_bar
        @hsy_bar.bitmap.dispose
        @hsy_bar.dispose 
      end
      if @hsy_bar_di
        @hsy_bar_di.bitmap.dispose 
        @hsy_bar_di.dispose 
      end
      @hsy_back = Sprite.new
      @hsy_back.bitmap = Cache.picture("FF11")
      @hsy_back.y = 550+75-2
      @hsy_back.x = 30+(60*  [$game_party.members.size,5].min)
      #@hsy_back.x += 123 if $game_variables[124] > 0 
      @hsy_back.z = 201
      @hsy_bar = Sprite.new
      @hsy_bar.bitmap = Cache.picture("FF10")
      @hsy_bar.x = 21+30+(60 * [$game_party.members.size,5].min)
      #@hsy_bar.x += 123 if $game_variables[124] > 0 
      @hsy_bar.y = 580+75-2
      @hsy_bar.z  = 200
      @hsy_bar_di = Sprite.new
      @hsy_bar_di.bitmap = Cache.picture("FF12")
      @hsy_bar_di.x = 21+30+(60 * [$game_party.members.size,5].min)
      #@hsy_bar_di.x += 123 if $game_variables[124] > 0 
      @hsy_bar_di.y = 580+75-2
      @hsy_bar_di.z  = 199
      refresh_100
    end
  end

   def refresh_100
    if  @hsy_bar and !@hsy_bar.disposed?
    if $game_variables[123] > 0 and @hsy_bar != nil and $game_switches[600] == false
       @hsy_bar.src_rect = Rect.new(0,0,$game_variables[123]/2.0-1,100)
    end
   end

  def over_100
    if @hsy_bar != nil 
      if @hsy_back
        @hsy_back.bitmap.dispose 
        @hsy_back.dispose  
      end
      if @hsy_bar
        @hsy_bar.bitmap.dispose
        @hsy_bar.dispose 
      end
      if @hsy_bar_di
        @hsy_bar_di.bitmap.dispose 
        @hsy_bar_di.dispose 
      end
      @hsy_bar = nil
      @hsy_back = nil
      @hsy_bar_di = nil
      $game_switches[399] = true
      $game_variables[123] = 0
    end
  end
  end

  def rest_100
    if @hsy_bar != nil 
      if @hsy_back
        @hsy_back.bitmap.dispose 
        @hsy_back.dispose  
      end
      if @hsy_bar
        @hsy_bar.bitmap.dispose
        @hsy_bar.dispose 
      end
      if @hsy_bar_di
        @hsy_bar_di.bitmap.dispose 
        @hsy_bar_di.dispose 
      end
      @hsy_bar = nil
      @hsy_back = nil
      @hsy_bar_di = nil
  end
  end

  #杀毒计系列
  def great_200
    if $game_variables[124] > 0 and @hsy_back_2 == nil

      if @hsy_back_2
        @hsy_back_2.bitmap.dispose
        @hsy_back_2.dispose
      end
      if @hsy_bar_2
        @hsy_bar_2.bitmap.dispose
        @hsy_bar_2.dispose
      end
      if @hsy_bar_di_2
        @hsy_bar_di_2.bitmap.dispose
        @hsy_bar_di_2.dispose
      end

      @hsy_back_2 = Sprite.new
      @hsy_back_2.bitmap = Cache.picture("FF15")
      @hsy_back_2.y = 550+75-2
      @hsy_back_2.x = 30+(60*  [$game_party.members.size,5].min)
      @hsy_back_2.x += 123 if $game_variables[123] > 0 
      @hsy_back_2.z = 201
      @hsy_bar_2 = Sprite.new
      @hsy_bar_2.bitmap = Cache.picture("FF14")
      @hsy_bar_2.x = 21+30+(60 * [$game_party.members.size,5].min)
      @hsy_bar_2.x += 123 if $game_variables[123] > 0 
      @hsy_bar_2.y = 580+75-2
      @hsy_bar_2.z  = 200
      @hsy_bar_di_2 = Sprite.new
      @hsy_bar_di_2.bitmap = Cache.picture("FF12")
      @hsy_bar_di_2.x = 21+30+(60 * [$game_party.members.size,5].min)
      @hsy_bar_di_2.x += 123 if $game_variables[123] > 0 
      @hsy_bar_di_2.y = 580+75-2
      @hsy_bar_di_2.z  = 199
      refresh_200
    end  
  end

  def refresh_200
    if  @hsy_bar_2 and !@hsy_bar_2.disposed?
    if $game_variables[124] > 0 and @hsy_bar_2 != nil
      @hsy_bar_2.src_rect = Rect.new(0,0,$game_variables[124]/2.0-1,100)
    end
    end
  end

  def over_200
    if @hsy_bar_2 != nil 
      if @hsy_back_2
        @hsy_back_2.bitmap.dispose
        @hsy_back_2.dispose
      end
      if @hsy_bar_2
        @hsy_bar_2.bitmap.dispose
        @hsy_bar_2.dispose
      end
      if @hsy_bar_di_2
        @hsy_bar_di_2.bitmap.dispose
        @hsy_bar_di_2.dispose
      end
      @hsy_bar_2 = nil
      @hsy_back_2 = nil
      @hsy_bar_di_2 = nil
      $game_switches[397] = true
      $game_variables[124] = 0
    end
  end

  def rest_200
    if @hsy_bar_2 != nil 
      if @hsy_back_2
        @hsy_back_2.bitmap.dispose
        @hsy_back_2.dispose
      end
      if @hsy_bar_2
        @hsy_bar_2.bitmap.dispose
        @hsy_bar_2.dispose
      end
      if @hsy_bar_di_2
        @hsy_bar_di_2.bitmap.dispose
        @hsy_bar_di_2.dispose
      end
      @hsy_bar_2 = nil
      @hsy_back_2 = nil
      @hsy_bar_di_2 = nil
    end
  end

  def now_refresh
    if !@now.disposed? 
    text = ""
    $game_party.items.each do |item|
      if item.speed == 90
        text = item.description.split("\r\n")[rand(2)]
      end   
    end 
    if $game_variables[100] > 0
      for i in 0...$game_party.members.size
        if $game_party.members[i].id == $game_variables[100]
          actor = $game_party.members[i]
        end
      end       
    else
      actor = $game_party.al[0]
    end
    @now.bitmap.clear
    now_bitmap = Cache.system("now")
    @now.bitmap.blt(0,0,now_bitmap,Rect.new(0,0,800,95))
    @now.bitmap.font.color = Color.new(255,200,50,255)
    @now.bitmap.draw_text(91 ,11,850,40,"#{actor.name}"+"：")
    @now.bitmap.font.color = normal_color
    if actor.name.length > 2
      @now.bitmap.draw_text(138+16,11,850,40, text)
    else
      @now.bitmap.draw_text(138,11,850,40, text)
    end
    now_bitmap2 = Cache.sface(actor.face_name)
    @now.bitmap.blt(25,0,now_bitmap2,Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58))

    now_bitmap.dispose
    now_bitmap2.dispose
  end
  end

  def close_now
    if !@now.disposed? 
    @now.visible = false
    @now.opacity = 0
    @now.x = 530
  end
  end

  def update
    if !@now.disposed? and !$game_message.busy? and !$game_map.interpreter.running?
      if Keys.trigger?(Keys::C) or ($game_switches[742] == true and Input.trigger?(:X)) 
        if @now.visible == false
          now_refresh
          Audio.se_play("Audio/SE/Cursor2",100)
          @now.visible = true
        else 
          close_now
          Sound.play_cancel
        end
      end
          update_now
    end   
  end

  def update_now
    if !@now.disposed?
    if @now and @now.x != 480 and @now.visible == true
       @now.x -= 5
       @now.opacity += 26
    end
  end
  end

  def can_mini?
    mini_id = [99,100,857,57,58,59,60, 61, 899, 862, 879, 918, 77, 78, 79, 80, 81, 329, 384, 385, 333, 335, 337, 342, 347, 350, 355, 359, 361, 362, 36, 365, 914, 915,415, 416, 417,418,419, 420, 421, 422,423]  
    mini_id.include?($game_map.map_id)
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目索引
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    clear_sp
    $game_party.members.each_with_index do |actor,index|
      if actor != nil && index <=4
        x = index * 60 + 43
        y = 610
        actor = $game_party.members[index]
        sp = Sprite.new
        sp.bitmap = Cache.sface(actor.face_name)
        sp.src_rect = Rect.new(actor.face_index%4*58,actor.face_index/4*58,58,58)
        @now_face_bitmap = sp.bitmap if index == 0
        sp.x = x
        sp.y = y
        sp.opacity = 255
        sp.z = 102  + 10

        mask = Sprite.new
        if actor.dead?
          mask.bitmap = Cache.hp("mapstatusmask_dead")
        else
          mask.bitmap = Cache.hp("mapstatusmask")
        end
        mask.x = sp.x-1
        mask.y = sp.y-10
        mask.z = 50  + 10

        mask_tp = Sprite.new
        if actor.tp >= 100
          mask_tp.bitmap = Cache.hp("mapstatusmask_tp")
        else
          mask_tp.bitmap = Cache.hp("mapstatusmask_tp_nil")
        end
        mask_tp.x = sp.x-1
        mask_tp.y = sp.y-10
        mask_tp.z = 150 

        if actor.dead?
          sp.tone = Tone.new(0,0,0,255)
          sp.opacity = 120 
        elsif actor.crisis?
          sp.opacity = 255
          sp.tone = Tone.new(20,20,90,150)
        end


        @sp.push sp
        @mask.push mask
        @mask.push mask_tp
      end
    end

    refresh_formation
    refresh_jm

    if $game_party.mhp <= 2000
      rate = ($game_party.mhp / 2000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate = 0  if rate < 0.1
      rate = 0  if $game_party.members.size < 1 
      rate = 0 unless $game_party.mhp > 0
      @hp.src_rect = Rect.new(0,0, 65+(200 * rate).round,30)
    elsif  $game_party.mhp <= 5000 
      rate =  [($game_party.mhp / 2000.0),1].min * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = (($game_party.mhp - 2000) / 3000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate = 0 unless $game_party.mhp > 0
      @hp.src_rect = Rect.new(0,0, (200 * rate).round + (150 * rate2).round, 30)
    elsif  $game_party.mhp <= 15000  
      rate =  [($game_party.mhp / 5000.0),1].min * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = (($game_party.mhp - 5000) / 10000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate = 0 unless $game_party.mhp > 0
      @hp.src_rect = Rect.new(0,0, (350 * rate).round + (150 * rate2).round, 30)
    else 
      rate =  [($game_party.mhp / 15000.0),1].min * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = (($game_party.mhp - 15000) / 35000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = 1 if rate2 > 1
      rate = 0 unless $game_party.mhp > 0
      @hp.src_rect = Rect.new(0,0, (500 * rate).round + (692 * rate2).round, 30)
    end


    #遮照框
    if $game_party.hp >=10000
      @hp_2.bitmap = Cache.hp("mapstatusbg01_w")
    else
      @hp_2.bitmap = Cache.hp("mapstatusbg01")
    end
    if $game_party.mhp <= 2000
      rate = ($game_party.mhp / 2000.0)
      rate = 0 if rate < 0
      rate = 0 unless $game_party.mhp > 0
      @hp_2.src_rect = Rect.new(0,0,65+(200 * rate).round,220)
    elsif  $game_party.mhp <= 5000
      rate = (($game_party.mhp - 2000) / 3000.0)
      rate = 0 unless $game_party.mhp > 0
      @hp_2.src_rect = Rect.new(0,0,200+(150 * rate).round,220)
    elsif  $game_party.mhp <= 15000
      rate = (($game_party.mhp - 5000) / 10000.0)
      rate = 0 unless $game_party.mhp > 0
      @hp_2.src_rect = Rect.new(0,0,350+(150 * rate).round,220)
    else
      rate = (($game_party.mhp - 15000)/ 35000.0)
      rate = 1 if rate > 1
      rate = 0 unless $game_party.mhp > 0
      @hp_2.src_rect = Rect.new(0,0,500+(692 * rate).round,220)
    end

    if $game_party.mhp <= 2000
      rate = ($game_party.mhp / 2000.0)
      rate = 0 if rate < 0
      rate = 0 unless $game_party.mhp > 0
      @hp_3.x = 65+35+(200* rate).to_f 
    elsif  $game_party.mhp <= 5000
      rate = (($game_party.mhp - 2000) / 3000.0)
      rate = 0 unless $game_party.mhp > 0
      @hp_3.x = 35+200+(150* rate).to_f 
    elsif  $game_party.mhp <= 15000
      rate = (($game_party.mhp - 5000) / 10000.0)
      rate = 0 unless $game_party.mhp > 0
      @hp_3.x = 35+350+(150* rate).to_f 
    else
      rate = (($game_party.mhp - 15000) / 35000.0)
      rate = 1 if rate > 1
      rate = 0 unless $game_party.mhp > 0
      @hp_3.x = 35+500+(692* rate).to_f 
    end


    if     $game_party.mhp <= 2000
    rate = ($game_party.mhp / 2000.0)
    rate = 0 if rate < 0
        rate = 0 unless $game_party.mhp > 0
    @hp_5.src_rect = Rect.new(0,0,65+(200 * rate).round,200)
    elsif  $game_party.mhp <= 5000 
    rate = (($game_party.mhp - 2000) / 3000.0)
        rate = 0 unless $game_party.mhp > 0
    @hp_5.src_rect = Rect.new(0,0,200+(150 * rate).round,200)
    elsif  $game_party.mhp <= 15000
    rate = (($game_party.mhp - 5000) / 10000.0)
        rate = 0 unless $game_party.mhp > 0
    @hp_5.src_rect = Rect.new(0,0,350+(150 * rate).round,200)
    else  
    rate = (($game_party.mhp - 15000) / 35000.0)
    rate = 1 if rate > 1
        rate = 0 unless $game_party.mhp > 0
    @hp_5.src_rect = Rect.new(0,0,500+(692 * rate).round,200)
    end 

    if $game_party.mhp <= 2000
      rate =  ($game_party.mhp / 2000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate = 0 if rate < 0
      rate = 0  if $game_party.members.size < 1 
      rate = 0 unless $game_party.mhp > 0
      @hp_7.x = 65+36+25+(200 * rate).to_f 
    elsif   $game_party.mhp <= 5000
      rate =  [($game_party.mhp / 2000.0),1].min * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = (($game_party.mhp - 2000) / 3000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate = 0 unless $game_party.mhp > 0
      rate2 = 0 unless $game_party.mhp > 0
      @hp_7.x = 36+25+(200 * rate).to_f + (150 * rate2).to_f
    elsif   $game_party.mhp <= 15000
      rate =  [($game_party.mhp / 5000.0),1].min * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = (($game_party.mhp - 5000) / 10000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate = 0 unless $game_party.mhp > 0
      rate2 = 0 unless $game_party.mhp > 0
      @hp_7.x = 36+25+(350 * rate).to_f + (150 * rate2).to_f
    else 
      rate =  [($game_party.mhp / 15000.0),1].min * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = (($game_party.mhp - 15000) / 35000.0) * ($game_party.hp / ($game_party.mhp.to_f))
      rate2 = 1 if rate2 > 1
      rate = 0 unless $game_party.mhp > 0
      rate2 = 0 unless $game_party.mhp > 0
      @hp_7.x = 36+25+(500 * rate).to_f + (692 * rate2).to_f
    end

    #地图状态栏上显示全队（前5人）HP总和的数字
    @hp_no.bitmap.clear
    @hp_no.bitmap.font.size = 22 + $game_variables[300]+1
    @hp_no.bitmap.font.name = "Noto"  
    @hp_no.bitmap.draw_text(100-6+30,-220-1,500,500,($game_party.hp).to_i) 
        
  end


  def refresh_formation
    if $game_variables[108] != nil and $game_variables[108] > 3
      if $game_party.alive_members.size > 4
        @formation.bitmap = Bitmap.new("Graphics/hp/formation_a/#{$game_variables[108]}")
      else
        @formation.bitmap = Bitmap.new("Graphics/hp/formation_a/4")
      end
      @formation.x = 0
      @formation.y = 575
      @formation.opacity = 255 
    end
   end

  def refresh_jm
    has_jm = -1
    $game_party.members.each do |actor|
      has_jm = actor.index if actor.id == $game_variables[100]
    end
    if has_jm >= 0 and @master and @master != nil and has_jm < 5
      @master.x = has_jm * 60 + 18
      @master.y = 600
      @master.opacity = 255 
    else
      @master.x = has_jm * 60 + 18
      @master.y = 600
      @master.opacity = 0
    end
  end

  def re_map_key
    if can_mini? and $game_variables[100] > 0
      @map_key.bitmap = Cache.system("map_key3")
    elsif can_mini?
      @map_key.bitmap = Cache.system("map_key1")
    elsif $game_variables[100] > 0
      @map_key.bitmap = Cache.system("map_key2")
    end
  end


  def re_cname
    if $game_switches[487] == true
      @move = 0
      @cname_back.x = 1092 + 188+2
      @cname_font.x = 1092 + 188+2
      @cname_back.tone.set(255,255,255,0) 
      if $game_map.cname != nil 
        build = $game_map.build
        @cname_font.bitmap.clear
        @cname_font.bitmap.font.size = 27 + $game_variables[300]
        @cname_font.bitmap.font.name = "Noto"  
        @cname_font.bitmap.draw_text(65,-203,500,500,($game_map.cname),0)
        @cname_font.bitmap.font.size = 20 + $game_variables[300]
        @cname_font.bitmap.draw_text(15,-175,500,500,(build),0)
        @cname_font.opacity = 255
        color = $game_map.cname_color.to_s
        name = "cname" + $game_map.cname_color.to_s
        name = "cname" + $game_map.cname_color.to_s + "_n"  if ( color == "2" or color == "3" ) and build == ""
        @cname_back.bitmap = Cache.hp(name)
        @cname_back.opacity = 255
      else
        @cname_font.bitmap.clear
        @cname_font.opacity = 0
        @cname_back.opacity = 0
      end
    end
  end

  def re_cname_quick
    if $game_switches[487] == true
      @move = 188
      @cname_back.x = 1092 +2
      @cname_font.x = 1092 +2
      if $game_map.cname != nil 
        build = $game_map.build
        @cname_font.bitmap.clear
        @cname_font.bitmap.font.size = 27 + $game_variables[300]
        @cname_font.bitmap.font.name = "Noto"  
        @cname_font.bitmap.draw_text(65,-203,500,500,($game_map.cname),0)
        @cname_font.bitmap.font.size = 20 + $game_variables[300]
        @cname_font.bitmap.draw_text(15,-175,500,500,(build),0)
        @cname_font.opacity = 255
        color = $game_map.cname_color.to_s
        name = "cname" + $game_map.cname_color.to_s
        name = "cname" + $game_map.cname_color.to_s + "_n"  if ( color == "2" or color == "3" ) and build == ""
        @cname_back.bitmap = Cache.hp(name)
        @cname_back.opacity = 255
      else
        @cname_font.bitmap.clear
        @cname_font.opacity = 0
        @cname_back.opacity = 0
      end
    end
  end

  def show_cname
    @cname_font.opacity = 255 if @cname_font != nil 
    @cname_back.opacity = 255 if @cname_back != nil 
  end

  def hide_cname
    @cname_font.opacity = 0 if @cname_font != nil 
    @cname_back.opacity = 0 if @cname_back != nil 
  end

  def move
    @move 
  end

  def move_cname
    if $game_switches[487] == true and !@cname_back.disposed?
      if  @cname_back.x <= 1092
      else
        @move += 10
        a = @move * 1.5
        a = 255  if a > 255
        @cname_font.x -= 10
        @cname_back.x -= 10
        @cname_back.tone.set(255-a,255-a,255-a,0) 
      end
    end
  end
  
  def show_sprites
    (@sp + @mask).each do |sp|
      sp.visible = true
    end
    @hp.visible = true
    @hp_2.visible = true
    @hp_3.visible = true
    @hp_0.visible = true
    @hp_no.visible = true
    @hp_5.visible = true
    @hp_7.visible = true
    @map_key.visible = true
    @hsy_back.visible = true if @hsy_back != nil 
    @hsy_bar.visible = true if @hsy_bar != nil 
    @hsy_bar_di.visible = true if @hsy_bar != nil 
    @hsy_back_2.visible = true if @hsy_back_2 != nil 
    @hsy_bar_2.visible = true if @hsy_bar_2 != nil 
    @hsy_bar_di_2.visible = true if @hsy_bar_2 != nil 
    refresh_formation
    refresh_jm
  end

  def hide_sprites
    (@sp + @mask).each do |sp|
      sp.visible = false
    end
    @hp.visible = false
    @hp_2.visible = false
    @hp_3.visible = false
    @hp_0.visible = false
    @hp_no.visible = false
    @hp_5.visible = false
    @hp_7.visible = false
    @master.opacity = 0
    @formation.opacity = 0
    @map_key.visible = false
    @now.visible = false
    @hsy_back.visible = false if @hsy_back != nil 
    @hsy_bar.visible = false if @hsy_bar != nil 
    @hsy_bar_di.visible = false if @hsy_bar != nil 
    @hsy_back_2.visible = false if @hsy_back_2 != nil 
    @hsy_bar_2.visible = false if @hsy_bar_2 != nil 
    @hsy_bar_di_2.visible = false if @hsy_bar_2 != nil 
  end

  def draw_actor_map(actor, x, y, width = 50)
   # gw = width - width * actor.hp / actor.mhp
   # self.contents.fill_rect(x + width - gw , y+4, gw, 3, hp_gauge_color2)
   # gw2 = width - width * actor.mp / actor.mmp
   # self.contents.fill_rect(x + width - gw2 , y+8, gw2, 3, hp_gauge_color2)
   # gw3 = width - width * actor.ap / actor.map
   # self.contents.fill_rect(x + width - gw3 , y+12, gw3, 3, hp_gauge_color2)
  end

  def clear_sp
    @sp.each_with_index do |_obj,_index|
      if _obj
        _obj.bitmap.dispose if _obj.bitmap
        _obj.dispose
        @sp[_index] = nil
      end
    end
    @mask.each_with_index do |_obj,_index|
      if _obj
        _obj.bitmap.dispose if _obj.bitmap
        _obj.dispose
        @mask[_index] = nil
      end
    end

    @sp.clear
    @mask.clear
    # @@sp = nil
    # @mask = nil
  end

  # => 无需手动释放
  # def dispose
  #   super
  #   if @master
  #     @master.bitmap.dispose if @master.bitmap
  #     @master.dispose
  #   end
  #   if @map_key
  #     @map_key.bitmap.dispose if @map_key.bitmap
  #     @map_key.dispose
  #   end
  #   if @now
  #     @now.bitmap.dispose if @now.bitmap
  #     @now.dispose
  #   end
  #   if @formation
  #     @formation.bitmap.dispose if @formation.bitmap
  #     @formation.dispose
  #   end
  #   if @cname_font
  #     @cname_font.bitmap.dispose if @cname_font.bitmap
  #     @cname_font.dispose
  #   end
  #   if @cname_back
  #     @cname_back.bitmap.dispose if @cname_back.bitmap
  #     @cname_back.dispose
  #   end
  #   if @hsy_back
  #     @hsy_back.bitmap.dispose 
  #     @hsy_back.dispose  
  #   end
  #   if @hsy_bar
  #     @hsy_bar.bitmap.dispose
  #     @hsy_bar.dispose 
  #   end
  #   if @hsy_bar_di
  #     @hsy_bar_di.bitmap.dispose 
  #     @hsy_bar_di.dispose 
  #   end
  #   if @hsy_back_2
  #     @hsy_back_2.bitmap.dispose
  #     @hsy_back_2.dispose
  #   end
  #   if @hsy_bar_2
  #     @hsy_bar_2.bitmap.dispose
  #     @hsy_bar_2.dispose
  #   end
  #   if @hsy_bar_di_2
  #     @hsy_bar_di_2.bitmap.dispose
  #     @hsy_bar_di_2.dispose
  #   end
  #   if @hp
  #      @hp.bitmap.dispose if @hp.bitmap
  #      @hp.dispose
  #   end
  #   if @hp_2
  #      @hp_2.bitmap.dispose if @hp_2.bitmap
  #      @hp_2.dispose
  #   end
  #   if @hp_3
  #      @hp_3.bitmap.dispose if @hp_3.bitmap
  #      @hp_3.dispose
  #   end
  #   if @hp_0
  #      @hp_0.bitmap.dispose if @hp_0.bitmap
  #      @hp_0.dispose
  #   end
  #   if @hp_no
  #      @hp_no.bitmap.dispose if @hp_no.bitmap
  #      @hp_no.dispose
  #   end
  #   if @hp_5
  #      @hp_5.bitmap.dispose if @hp_5.bitmap
  #      @hp_5.dispose
  #   end
  #   if @hp_7
  #      @hp_7.bitmap.dispose if @hp_7.bitmap
  #      @hp_7.dispose
  #   end
  #   clear_sp
  # end

end