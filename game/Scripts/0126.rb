#encoding:utf-8
#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　处理战斗画面的精灵的类。本类在 Scene_Battle 类的内部使用。
#==============================================================================

class Spriteset_Battle

  include DisableableObject

  UPDATE_RATE = 10
  BATTLE_MEMBER_SIZE = 0
  attr_reader :background_filename
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @battle_member_size = $game_party.battle_members.size
    @cc = 0
    @hide = 1
    @hide_enemy = 0
    @actor_hp_bar_pattern = 1
    @enemy_hp_bar_pattern = 0
    @boss_hp_bar_pattern = 0
    @boss_mp_bar_pattern = 0
    @exist_boss = exist_boss?
    @allload = false
    @show_all_atk_text = false
    create_viewports
    @boss_temp_hp_real = 0
    @background_filename = ""
    create_battleback

    create_enemies
    create_actors

    create_pictures
    create_timer

    create_enemy_status_back1
    create_enemy_status_back2
    create_enemy_face_back
    create_boss_status
    create_enemy_mask
    create_boost
    create_boost_text

    create_all_atk_text

    create_enemy_states_sp

    hide_boost
    update
  end

  def create_enemy_states_sp
    @enemy_state = Sprite.new(@viewport2)
    @enemy_state.attrset(:x=> 348, :y=>0,:z=>60,:bitmap => Bitmap.new(192+320,480))
  end

  def show_all_atk_text
    @show_all_atk_text = true
    @all_atk_text.opacity = 0
  end

  def hide_all_atk_text
    @show_all_atk_text = false
    @all_atk_text.opacity = 0
  end

  def create_all_atk_text
    @all_atk_text = Sprite_Flash.create do |sp|
      sp.bitmap = Cache.flash("Battlecomm2-zg")
      sp.attrset x: 518, y: 478, z: 300, opacity: 0
    end
  end

  def create_actor_status_sp
    create_actor_status_back1
    create_actor_status_back2
    create_actor_mask
  end

  def allload!
    @allload = true
  end

  def animation?
    
  end

  def create_boost
    @boost_count = 0
    @boost_back = Sprite.new(@viewport2)
    @boost_back.bitmap = Cache.cp("e#{@boost_count}")
    @boost_back.attrset(:x=>327+480,:y=>535-53+150,:z=>20)
    @boost_actor = Sprite.new(@viewport2)
    #@boost_actor.bitmap = Cache.cp("#{@boost_count}")
    @boost_actor.bitmap = Cache.cp("0")
    @boost_actor.attrset(:x=>327+480,:y=>535-53+150,:z=>30)
    @boost_tag = Sprite.new(@viewport2)
    @boost_tag.bitmap = Cache.cp("morale_4")
    @boost_per = 291 / 255.to_f
    @ori_boost = ($game_party.boost).to_i
    @boost_m = (255 - @ori_boost)*@boost_per
    @boost_tag.attrset(:x=>835+@boost_m,:y=>511-53+157,:z=>40)
  end

  def create_boost_text
    @boost_text = Sprite.new(@viewport2)
    @boost_text.bitmap = Bitmap.new(48,25)
    @boost_text.attrset(:y=>515-21-5+154-3,:z=>99)
    @boost_text.bitmap.font.name = "Noto"
    @boost_text.bitmap.font.size = 23 + $game_variables[300]
    refresh_boost_text
  end

  def refresh_boost_text
    @boost_text.bitmap.clear
    @boost_text.bitmap.draw_text 0,0,48,25,@ori_boost.to_i
    #@boost_text.attrset(:x=>0)
  end

  def hide_boost
    @boost_text.opacity = @boost_back.opacity = @boost_actor.opacity = @boost_tag.opacity = 0
  
  end

  def show_boost
    @boost_text.opacity = @boost_back.opacity = @boost_actor.opacity = @boost_tag.opacity = 255
    #@boost_actor.opacity = 255
  end

  def update_boost
    if (Graphics.frame_count % UPDATE_RATE).zero?
      @boost_count >= 9 ? @boost_count = 0 : @boost_count += 1
      @boost_back.bitmap = Cache.cp("e#{@boost_count}")
      #@boost_actor.bitmap = Cache.cp("#{@boost_count}")
     # @boost_tag.bitmap = Cache.cp("morale_"+"#{$game_party.formation.id}")
      @boost_tag.bitmap = Cache.cp("morale_4")
    end
    if $game_party.boost > @ori_boost
      @ori_boost += 1
      @boost_m = (255 - @ori_boost)*@boost_per
      @boost_tag.bitmap = Cache.cp("morale_st")
      refresh_boost_text
    end
    if $game_party.boost < @ori_boost
      @ori_boost -= 1
      @boost_m = (255 - @ori_boost)*@boost_per
      @boost_tag.bitmap = Cache.cp("morale_st")
      refresh_boost_text
    end
    @boost_actor.src_rect = Rect.new(0,0,@boost_m+55,@boost_actor.bitmap.height)#Rect.new(@boost_m,0,420-@boost_m,@boost_actor.bitmap.height)
    @boost_actor.x = 327+480#+@boost_m
    @boost_tag.x = 835+@boost_m +10
    @boost_text.x = 25+460+44+465+238+3#@boost_m*0.95
  end

  def create_enemy_mask
    @e_masks = {}
    @e_states = {}
    color = Color.new(64,64,64)
    $game_troop.members.each_with_index do |enemy,index|
      if index < 5
        x = 235 + 101 +13
        y = 126 + index * 29+1-1
        hp = Sprite.new(@viewport2)
        w_hp = 114-114*enemy.hp/enemy.mhp
        bitmap_hp = Bitmap.new(114,10)
        bitmap_hp.fill_rect(0,0,bitmap_hp.width,bitmap_hp.height,color)
        hp.attrset(:x=>x-w_hp-1,:y=>y,:z=>300,:bitmap=>bitmap_hp)
        hp.src_rect = Rect.new(0+2,0,w_hp,bitmap_hp.height)
        mp = Sprite.new(@viewport2)
        w_mp = 114-114*enemy.mp/enemy.mmp
        bitmap_mp = Bitmap.new(114,4)
        bitmap_mp.fill_rect(0,0,bitmap_mp.width,bitmap_mp.height,color)
        mp.attrset(:x=>x-w_mp-1,:y=>y+14-1,:z=>300,:bitmap=>bitmap_mp)
        mp.src_rect = Rect.new(0,0,w_mp,bitmap_mp.height)
        dp = Sprite.new(@viewport2)
        w_dp = 35-(35*enemy.dp/30.0).to_i
        bitmap_dp = Bitmap.new(35,14)
        bitmap_dp.fill_rect(0,0,bitmap_dp.width,bitmap_dp.height,color)
        dp.attrset(:x=>x-w_dp-1-290-7,:y=>y+14-1-12,:z=>300,:bitmap=>bitmap_dp)
        dp.src_rect = Rect.new(0,0,w_dp,bitmap_dp.height)

        dp_hong = Sprite.new(@viewport2)
        w_dp_hong = (35*enemy.dp/30.0).to_i
        bitmap_dp_hong = Bitmap.new(35,14)
        bitmap_dp_hong.fill_rect(0,0,35,7,Color.new(255,35,35,255))
        bitmap_dp_hong.fill_rect(0,7,35,7,Color.new(133,0,0,255))
        dp_hong.attrset(:x=>x-333,:y=>y+14-1-12,:z=>299,:bitmap=>bitmap_dp_hong)
        #dp_hong.src_rect = Rect.new(0,0,41,14)
        @e_masks[enemy.id.to_s+index.to_s] = {:hp=>hp,:mp=>mp,:dp=>dp,:dp_hong=>dp_hong}
        @e_states[enemy.id.to_s+index.to_s] = {:hp=>enemy.hp,:mp=>enemy.mp,:dp=>enemy.dp}
      else
        x = 16
        y = 93
        dp_boss_hong = Sprite.new(@viewport2)
        w_dp_boss_hong = (35*enemy.dp/30.0).to_i
        bitmap_dp_boss_hong = Bitmap.new(35,14)
        bitmap_dp_boss_hong.fill_rect(0,0,35,7,Color.new(205,35,35,255))
        bitmap_dp_boss_hong.fill_rect(0,7,35,7,Color.new(133,0,0,255))
        dp_boss_hong.attrset(:x=>x,:y=>y,:z=>30,:bitmap=>bitmap_dp_boss_hong)
        dp_boss = Sprite.new(@viewport2)
        w_dp_boss = 35-(35*enemy.dp/30.0).to_i
        bitmap_dp_boss = Bitmap.new(35,14)
        bitmap_dp_boss.fill_rect(0,0,bitmap_dp_boss.width,bitmap_dp_boss.height,color)
        dp_boss.attrset(:x=>x-w_dp_boss+35,:y=>y,:z=>31,:bitmap=>bitmap_dp_boss)
        dp_boss.src_rect = Rect.new(0,0,w_dp_boss,bitmap_dp_boss.height)

        @e_masks[enemy.id.to_s+index.to_s] = {:hp=>hp,:mp=>mp,:dp=>dp,:dp_boss=>dp_boss,:dp_boss_hong=>dp_boss_hong}
        @e_states[enemy.id.to_s+index.to_s] = {:hp=>enemy.hp,:mp=>enemy.mp,:dp=>enemy.dp}
      end
    end

    @hong = {}
    @hong_states = {}
    color = Color.new(255,0,0)
    $game_troop.members.each_with_index do |enemy,index|
      if index < 5
        x = 235 + 101 +13
        y = 126 + index * 29+1-1
        hp = Sprite.new(@viewport2)
        w_hp = 114-114*enemy.hp/enemy.mhp
        bitmap_hp = Bitmap.new(114,10)
        bitmap_hp.fill_rect(0,0,bitmap_hp.width,bitmap_hp.height,color)
        hp.attrset(:x=>x-w_hp-1,:y=>y,:z=>301,:bitmap=>bitmap_hp)
        hp.src_rect = Rect.new(0,0,w_hp,bitmap_hp.height)
        mp = Sprite.new(@viewport2)
        w_mp = 114-114*enemy.mp/enemy.mmp
        bitmap_mp = Bitmap.new(114,4)
        bitmap_mp.fill_rect(0,0,bitmap_mp.width,bitmap_mp.height,color)
        mp.attrset(:x=>x-w_mp-1,:y=>y+14-1,:z=>301,:bitmap=>bitmap_mp)
        mp.src_rect = Rect.new(0,0,w_mp,bitmap_mp.height)
        dp = Sprite.new(@viewport2)
        w_dp = 35-(35*enemy.dp/30.0).to_i
        bitmap_dp = Bitmap.new(35,14)
        bitmap_dp.fill_rect(0,0,bitmap_dp.width,bitmap_dp.height,color)
        dp.attrset(:x=>x-w_dp-1-290-6,:y=>y+14-1-12,:z=>301,:bitmap=>bitmap_dp)
        dp.src_rect = Rect.new(0,0,0,bitmap_dp.height)
        @hong[enemy.id.to_s+index.to_s] = {:hp=>hp,:mp=>mp,:dp=>dp}
        @hong_states[enemy.id.to_s+index.to_s] = {:hp=>enemy.hp,:mp=>enemy.mp,:dp=>enemy.dp}
      else
        x=200-16+51
        y=90-10+4+6
        w_hp = 512-512*boss.hp/boss.mhp
        @color = Color.new(255,255,0)
        @boss_hp_hong = Sprite.new(@viewport2)
        @boss_hp = Bitmap.new(512,12)
        @boss_hp.fill_rect(0,0,@boss_hp.width,@boss_hp.height,color)
        @boss_hp_hong.attrset(:x=>x-w_hp-1,:y=>y,:z=>10,:bitmap=>@boss_hp)
        @boss_hp_hong.src_rect = Rect.new(0,0,w_hp,@boss_hp.height)


        dp_boss_shine = Sprite.new(@viewport2)
        w_dp_boss_shine = 35-35*enemy.dp/30
        bitmap_dp_boss_shine = Bitmap.new(35,14)
        bitmap_dp_boss_shine.fill_rect(0,0,bitmap_dp_boss_shine.width,bitmap_dp_boss_shine.height,Color.new(255,255,255,255))
        dp_boss_shine.opacity = 0
        dp_boss_shine.attrset(:x=>x-w_dp_boss_shine+35,:y=>y+3,:z=>32,:bitmap=>bitmap_dp_boss_shine)
        dp_boss_shine.src_rect = Rect.new(0,0,w_dp_boss_shine,bitmap_dp_boss_shine.height)
        @hong[enemy.id.to_s+index.to_s] = {:hp=>hp,:mp=>mp,:dp=>dp,:dp_boss_shine=>dp_boss_shine}
        @hong_states[enemy.id.to_s+index.to_s] = {:hp=>enemy.hp,:mp=>enemy.mp,:dp=>enemy.dp}
      end
    end
  end

  def refresh_hpmask_enemy(index,enemy)
    if index < 5
      x = 235 + 101+13 ; y = 126 + index * 29+1
      pindex = enemy.id.to_s + index.to_s
      orihp = @e_states[pindex][:hp]
      orihp_2 = @hong_states[pindex][:hp]
      w = 114 - (114 * orihp / enemy.mhp)
      if w < 0
         w = 0
         @e_states[pindex][:hp] = enemy.mhp
      end
      w2 = 114 - (114 * enemy.hp / enemy.mhp)
      hpsp_1 = @hong[pindex][:hp]
      
      #敌军hp 闪段
      a = (orihp_2 + 1.0 - enemy.hp) 
      a = 1 if a == 0
      if orihp > enemy.hp
        hpsp_1.color = Color.new(255,255,255)
        hpsp_1.opacity = [(255 * ( ( orihp + 1.0  - enemy.hp ) / ( a )).to_f).to_i,150].max
        hpsp_1.src_rect.width = w2 - w 
        hpsp_1.x = x-w2
        #hpsp_1.src_rect.width = 0   if hpsp_1.x + hpsp_1.src_rect.width > 394 
      else
        hpsp_1.color = Color.new(210,210,210)
        hpsp_1.opacity = (255 * ( ( orihp + 1.0  - enemy.hp ) / ( a )).to_f).to_i
        hpsp_1.src_rect.width =  w - w2 - 2
        hpsp_1.x = x - w
      end

      hpsp = @e_masks[pindex][:hp]
      hpsp.src_rect.width = w
      hpsp.x = x-w
      hpsp.src_rect.width = w-1 if orihp == orihp_2 #弥补缺陷缩短
    end
  end

  def refresh_mpmask_enemy(index,enemy)
    if index < 5
      x = 235 + 101+13 ; y = 140 + index * 29 +1-1
      pindex = enemy.id.to_s + index.to_s
      orimp = @e_states[pindex][:mp]
      orimp_2 = @hong_states[pindex][:mp]
      w = 114-(114*orimp/enemy.mmp)
      w2 = 114-(114*enemy.mp/enemy.mmp)
      mpsp_1 = @hong[pindex][:mp]

      #敌军sp 闪段
      if orimp > enemy.mp
        mpsp_1.color = Color.new(255,255,255)
        mpsp_1.opacity = 255# * ( ( orimp+1  - enemy.mp ) / ( orimp_2+1 - enemy.mp ))
        mpsp_1.src_rect.width = w2 - w 
        mpsp_1.x = x-w2
      else
        mpsp_1.color = Color.new(255,255,255)
        mpsp_1.opacity = 255# * ( ( orimp+1  - enemy.mp ) / ( orimp_2+1 - enemy.mp ))
        mpsp_1.src_rect.width =  w - w2 - 2
        mpsp_1.x = x - w
      end

      mpsp = @e_masks[pindex][:mp]
      mpsp.src_rect.width = w
      mpsp.x = x-w-1
    end
  end

  def refresh_dpmask_enemy(index,enemy)
    if index < 5
      x = 235 + 101+13; y = 140 + index * 29 +1-1
      pindex = enemy.id.to_s + index.to_s
      dpsp = @e_masks[pindex][:dp]
      oridp = @e_states[pindex][:dp]
      oridp_2 = @hong_states[pindex][:dp]
      w = 35-(35*oridp/30.0).to_i
      w2 = 35-(35*enemy.dp/30.0).to_i
      mpdp_1 = @hong[pindex][:dp]
      
      #敌军dp 闪段
      if oridp > enemy.dp
        mpdp_1.color = Color.new(255,255,255)
        mpdp_1.opacity = 255# * ( ( orimp+1  - enemy.mp ) / ( orimp_2+1 - enemy.mp ))
        mpdp_1.src_rect.width = w2 - w 
        mpdp_1.x = x-w2-1-291-6
      else
        mpdp_1.color = Color.new(255,255,255)
        mpdp_1.opacity = 255# * ( ( orimp+1  - enemy.mp ) / ( orimp_2+1 - enemy.mp ))
        mpdp_1.src_rect.width =  w - w2 
        mpdp_1.x = x - w-1-291-6
      end

      if enemy.state?(3)
        @e_masks[pindex][:dp_hong].bitmap.fill_rect(0,0,39,7,Color.new(167,46,255,255))
        @e_masks[pindex][:dp_hong].bitmap.fill_rect(0,7,39,7,Color.new(87,16,174,255))
      else
        @e_masks[pindex][:dp_hong].bitmap.fill_rect(0,0,39,7,Color.new(255,35,35,255))
        @e_masks[pindex][:dp_hong].bitmap.fill_rect(0,7,39,7,Color.new(155,0,0,255))
      end  

      dpsp.src_rect.width = w
      dpsp.x = x-w-1-291-6
    else
      x = 16; y = 93
      pindex = enemy.id.to_s + index.to_s
      dpsp = @e_masks[pindex][:dp_boss]
      oridp = @e_states[pindex][:dp]
      oridp_2 = @hong_states[pindex][:dp]
      w = 35-(35*oridp/30.0).to_i
      w2 = 35-(35*enemy.dp/30.0).to_i
      mpdp_1 = @hong[pindex][:dp_boss_shine]
      dpsp.src_rect.width = w
      dpsp.x = x-w+35

      if enemy.state?(3)
        @e_masks[pindex][:dp_boss_hong].bitmap.fill_rect(0,0,39,7,Color.new(167,46,255,255))
        @e_masks[pindex][:dp_boss_hong].bitmap.fill_rect(0,7,39,7,Color.new(87,16,174,255))
      else
        @e_masks[pindex][:dp_boss_hong].bitmap.fill_rect(0,0,39,7,Color.new(255,35,35,255))
        @e_masks[pindex][:dp_boss_hong].bitmap.fill_rect(0,7,39,7,Color.new(155,0,0,255))
      end  

      if oridp > enemy.dp
        mpdp_1.color = Color.new(255,255,255)
        mpdp_1.opacity = 255# * ( ( orimp+1  - enemy.mp ) / ( orimp_2+1 - enemy.mp ))
        mpdp_1.src_rect.width = w2 - w 
        mpdp_1.x = x-w2+35
      else
        mpdp_1.color = Color.new(255,255,255)
        mpdp_1.opacity = 255# * ( ( orimp+1  - enemy.mp ) / ( orimp_2+1 - enemy.mp ))
        mpdp_1.src_rect.width =  w - w2 
        mpdp_1.x = x - w+35
      end

    end
  end



  def create_actor_mask
    @masks = {}
    @states = {}
    @masks_hong_actor = {}
    @states_hong_actor = {}
    color = Color.new(64,64,64)
    count = 0
    $game_party.battle_members.each_with_index do |actor,index|
      if count < 5
        y = index * 29 - 35
        hp = Sprite.new(@viewport2)
        w_hp = 114-114*actor.hp/actor.mhp
        bitmap_hp = Bitmap.new(114,9)
        bitmap_hp.fill_rect(0,0,bitmap_hp.width,bitmap_hp.height,color)
        hp.attrset(:x=>970,:y=>y+526,:z=>300,:bitmap=>bitmap_hp)
        hp.src_rect = Rect.new(0,0,w_hp,bitmap_hp.height)
        mp = Sprite.new(@viewport2)
        w_mp = 114-114*actor.mp/actor.mmp
        bitmap_mp = Bitmap.new(114,4)
        bitmap_mp.fill_rect(0,0,bitmap_mp.width,bitmap_mp.height,color)
        mp.attrset(:x=>970,:y=>y+526+13,:z=>300,:bitmap=>bitmap_mp)
        mp.src_rect = Rect.new(0,0,w_mp,bitmap_mp.height)
        ap = Sprite.new(@viewport2)
        w_ap = 39-(39.0*actor.tp/actor.mtp).to_i
        bitmap_ap = Bitmap.new(39,14)
        bitmap_ap.fill_rect(0,0,bitmap_ap.width,bitmap_ap.height,color)
        ap.attrset(:x=>970+266,:y=>y+526+17-16,:z=>299,:bitmap=>bitmap_ap)
        ap.src_rect = Rect.new(0,0,w_ap,bitmap_ap.height)

        # #战气没满之前 增加白色条子
        ap_100 = Sprite.new(@viewport2)
        bitmap_ap_100 = Bitmap.new(39,14)
        if actor.state?(3)
          bitmap_ap_100.fill_rect(0,0,bitmap_ap_100.width,7,Color.new(167,46,255,255))
          bitmap_ap_100.fill_rect(0,7,bitmap_ap_100.width,7,Color.new(87,16,174,255))
        else
          bitmap_ap_100.fill_rect(0,0,bitmap_ap_100.width,7,Color.new(255,35,35,255))
          bitmap_ap_100.fill_rect(0,7,bitmap_ap_100.width,7,Color.new(155,0,0,255))
        end
        ap_100.attrset(:x=>970+266+w_ap,:y=>y+526+17-16,:z=>298,:bitmap=>bitmap_ap_100)
        ap_100.src_rect = Rect.new(w_ap,0,(39.0*actor.tp/actor.mtp).to_i,bitmap_ap_100.height)
        if actor.tp == 100
          #ap_100.src_rect.width = 0
        end

        ap_tag = Sprite_Flash.new(@viewport2)
        bitmap_ap_tag = Bitmap.new("Graphics/hp/ap100")
        ap_tag.attrset(:x=>970+266-12-155+108,:y=>y+526+17-16-10-8,:z=>201,:bitmap=>bitmap_ap_tag)

        @masks[actor.id]  = {:hp=>hp,:mp=>mp,:ap=>ap,:ap_100=>ap_100,:ap_tag=>ap_tag}
        @states[actor.id] = {:hp=>actor.hp,:mp=>actor.mp,:ap=>actor.tp}

        y = index * 29 - 35
        hp = Sprite.new(@viewport2)
        w_hp = 114-114*actor.hp/actor.mhp
        bitmap_hp = Bitmap.new(114,9)
        bitmap_hp.fill_rect(0,0,bitmap_hp.width,bitmap_hp.height,color)
        hp.attrset(:x=>970,:y=>y+526,:z=>301,:bitmap=>bitmap_hp)
        hp.src_rect = Rect.new(0,0,w_hp,bitmap_hp.height)
        mp = Sprite.new(@viewport2)
        w_mp = 114-114*actor.mp/actor.mmp
        bitmap_mp = Bitmap.new(114,4)
        bitmap_mp.fill_rect(0,0,bitmap_mp.width,bitmap_mp.height,color)
        mp.attrset(:x=>970,:y=>y+526+13,:z=>301,:bitmap=>bitmap_mp)
        mp.src_rect = Rect.new(0,0,w_mp,bitmap_mp.height)
        ap = Sprite.new(@viewport2)
        w_ap = 39-(39.0*actor.tp/actor.mtp).to_i
        bitmap_ap = Bitmap.new(39,14)
        bitmap_ap.fill_rect(0,0,bitmap_ap.width,bitmap_ap.height,color)
        ap.attrset(:x=>970+266,:y=>y+526+17-16,:z=>299,:bitmap=>bitmap_ap)
        ap.src_rect = Rect.new(0,0,w_ap,bitmap_ap.height)
        @masks_hong_actor[actor.id]  = {:hp=>hp,:mp=>mp,:ap=>ap}
        @states_hong_actor[actor.id] = {:hp=>actor.hp,:mp=>actor.mp,:ap=>actor.tp}

        count += 1
      end
    end
  end

  def refresh_hpmask(index,actor)
    orihp = @states[actor.id][:hp]
    orihp_2 = @states_hong_actor[actor.id][:hp]
    w = 114-114*orihp/actor.mhp
    w2 = 114-114*actor.hp/actor.mhp
    if w < 0
       w = 0
       @states[actor.id][:hp] = actor.mhp
    end
    hpsp_1 = @masks_hong_actor[actor.id][:hp]
    x = 970

    #我军 hp红遮罩
    a = (orihp_2 + 1.0 - actor.hp) 
    a = 1 if a == 0
    if orihp > actor.hp
      hpsp_1.color = Color.new(255,0,0)
      hpsp_1.opacity = [(255 * ( ( orihp + 1.0  - actor.hp ) / ( a )).to_f).to_i,150].max
      hpsp_1.src_rect.width =  w2 - w
      hpsp_1.x =  w+x
    else
      hpsp_1.color = Color.new(0,222,255)
      hpsp_1.opacity = (255 * ( ( orihp + 1.0  - actor.hp ) / ( a )).to_f).to_i
      hpsp_1.src_rect.width =  w - w2
      hpsp_1.x = w2+x
    end

    hpsp = @masks[actor.id][:hp]
    hpsp.src_rect.width = w
    hpsp.x = 970
  end

  def refresh_mpmask(index,actor)
    orimp = @states[actor.id][:mp]
    w = 114-114*orimp/actor.mmp
    #orimp_2 = @states_hong_actor[actor.id][:mp]
    w2 = 114-114*actor.mp/actor.mmp
    mpsp_2 = @masks_hong_actor[actor.id][:mp]
    x = 970

    #我军 sp红遮罩
    if orimp > actor.mp
      mpsp_2.color = Color.new(255,255,255)
      mpsp_2.opacity = 255#(255 * ( ( orimp + 1.0  - actor.mp ) / ( orimp_2 + 1.0 - actor.mp )).to_f).to_i
      mpsp_2.src_rect.width =  w2 - w
      mpsp_2.x =  w+x
    else
      mpsp_2.color = Color.new(255,255,255)
      mpsp_2.opacity =255# (255 * ( ( orimp + 1.0  - actor.mp ) / ( orimp_2 + 1.0 - actor.mp )).to_f).to_i
      mpsp_2.src_rect.width =  w - w2
      mpsp_2.x = w2+x
    end

    mpsp = @masks[actor.id][:mp]
    mpsp.src_rect.width = w
    mpsp.x = 970
  end

  def refresh_apmask(index,actor)
    oritp = @states[actor.id][:ap]
    w = 39-(39.0*oritp/actor.mtp).to_i
    w2 = 39-(39.0*actor.tp/actor.mtp).to_i
    apsp_2 = @masks_hong_actor[actor.id][:ap]
    x = 970+266

    #我军 ap红遮罩
    if oritp > actor.tp 
      apsp_2.color = Color.new(255,255,255)
      apsp_2.opacity = 255#(255 * ( ( orimp + 1.0  - actor.mp ) / ( orimp_2 + 1.0 - actor.mp )).to_f).to_i
      apsp_2.src_rect.width =  w2 - w
      apsp_2.x =  w+x 
    else
      apsp_2.color = Color.new(255,255,255)
      apsp_2.opacity =255# (255 * ( ( orimp + 1.0  - actor.mp ) / ( orimp_2 + 1.0 - actor.mp )).to_f).to_i
      apsp_2.src_rect.width =  w - w2
      apsp_2.x = w2+x
    end

    apsp = @masks[actor.id][:ap]
    apsp.src_rect.width = w
    apsp.x = 970+266
    apsp_100 = @masks[actor.id][:ap_100]
    apsp_100.x = 970+266+w
    apsp_100.src_rect.x = w
    apsp_100.src_rect.width = (39.0*oritp/actor.mtp).to_i
    if actor.state?(3)
      apsp_100.bitmap.fill_rect(0,0,39,7,Color.new(167,46,255,255))
      apsp_100.bitmap.fill_rect(0,7,39,7,Color.new(87,16,174,255))
    else
      apsp_100.bitmap.fill_rect(0,0,39,7,Color.new(255,35,35,255))
      apsp_100.bitmap.fill_rect(0,7,39,7,Color.new(155,0,0,255))
    end  

    if oritp == 100
      # apsp.src_rect.width = w
      #apsp_100.src_rect.width = 0
      Audio.se_play("Audio/SE/J_qian",85,60)
    end
  end




  def update_mask
    $game_party.battle_members.each_with_index do |actor,index|
      next if @states[actor.id].nil?
      orihp = @states[actor.id][:hp]
      orimp = @states[actor.id][:mp]
      oritp = @states[actor.id][:ap]
      if actor.hp > orihp
        l = [(actor.hp - orihp).abs/60.0,10].max
        l = l.to_i
        #l = actor.mhp / 100.to_i
        @states[actor.id][:hp] += l
        if @states[actor.id][:hp] >= actor.hp
           @states[actor.id][:hp] = actor.hp 
           @states_hong_actor[actor.id][:hp] = actor.hp 
        end
        refresh_hpmask(index,actor)
      end
      if actor.hp < orihp
        l = [(actor.hp - orihp).abs/30.0,10].max
        l = l.to_i
        #l = actor.mhp / 100.to_i
        @states[actor.id][:hp] -= l
        if @states[actor.id][:hp] <= actor.hp
        @states[actor.id][:hp] = actor.hp 
        @states_hong_actor[actor.id][:hp] = actor.hp 
        end
        refresh_hpmask(index,actor)
      end
      if actor.mp > orimp
        l = [(actor.mp - orimp).abs/30.0,1].max
        l = l.to_i
        # l = actor.mmp / 100.to_i
        @states[actor.id][:mp] += l
        if @states[actor.id][:mp] >= actor.mp
        @states[actor.id][:mp] = actor.mp 
        @states_hong_actor[actor.id][:mp] = actor.mp 
        end
        refresh_mpmask(index,actor)
      end
      if actor.mp < orimp
        l = [(actor.mp - orimp).abs/30.0,1].max
        l = l.to_i
        #l = actor.mmp / 100.to_i
        @states[actor.id][:mp] -= l
        if @states[actor.id][:mp] <= actor.mp
        @states[actor.id][:mp] = actor.mp
        @states_hong_actor[actor.id][:mp] = actor.mp 
        end 
        refresh_mpmask(index,actor)
      end
      if actor.tp > oritp
        l = 1#[(actor.tp - oritp).abs/20.to_i,1].max
        #l = actor.mtp / 100.to_i
        @states[actor.id][:ap] += 1
        if @states[actor.id][:ap] >= actor.tp
        @states[actor.id][:ap] = actor.tp 
        @states_hong_actor[actor.id][:ap] = actor.tp 
        end
        refresh_apmask(index,actor)
      end
      if actor.tp < oritp
        l = 1#[(actor.tp - oritp).abs/20.to_i,1].max
        #l = actor.mtp / 100.to_i
        @states[actor.id][:ap] -= 1
        if @states[actor.id][:ap] <= actor.tp
        @states[actor.id][:ap] = actor.tp 
        @states_hong_actor[actor.id][:ap] = actor.tp 
        end
        refresh_apmask(index,actor)
      end
    end
  end

  def update_mask_enemy
    $game_troop.members.each_with_index do |enemy,index|
      if index < 5
        pindex = enemy.id.to_s + index.to_s
        orihp = @e_states[pindex][:hp]
        orimp = @e_states[pindex][:mp]
        oridp = @e_states[pindex][:dp]
        if enemy.hp > orihp
          #l = [(enemy.hp - orihp).abs/20.to_i,10].max
          l = enemy.mhp / 100 / 4.to_f
          @e_states[pindex][:hp] += l
          if @e_states[pindex][:hp] >= enemy.hp
            @e_states[pindex][:hp] = enemy.hp
            @hong_states[pindex][:hp] = enemy.hp 
          end
          refresh_hpmask_enemy(index,enemy)
        end
        if enemy.hp < orihp
          #l = [(enemy.hp - orihp).abs/20.to_i,10].max
          l = enemy.mhp / 100 / 4.to_f
          @e_states[pindex][:hp] -= l
          if @e_states[pindex][:hp] <= enemy.hp
            @e_states[pindex][:hp] = enemy.hp 
            @hong_states[pindex][:hp] = enemy.hp 
          end
          refresh_hpmask_enemy(index,enemy)
        end
        if enemy.mp > orimp
          #l = [(enemy.mp - orimp).abs/20.to_i,10].max
          l = enemy.mmp / 100 / 4.to_f
          @e_states[pindex][:mp] += l
          if @e_states[pindex][:mp] >= enemy.mp
            @e_states[pindex][:mp] = enemy.mp 
            @hong_states[pindex][:mp] = enemy.mp 
          end
          refresh_mpmask_enemy(index,enemy)
        end
        if enemy.mp < orimp
          #l = [(enemy.mp - orimp).abs/20.to_i,10].max
          l = enemy.mmp / 100 / 4.to_f
          @e_states[pindex][:mp] -= l
          if @e_states[pindex][:mp] <= enemy.mp
            @e_states[pindex][:mp] = enemy.mp 
            @hong_states[pindex][:mp] = enemy.mp 
          end
          refresh_mpmask_enemy(index,enemy)
        end
            if enemy.dp > oridp
          #l = [(enemy.mp - orimp).abs/20.to_i,10].max
          l = 0.2
          @e_states[pindex][:dp] += l
          if @e_states[pindex][:dp] >= enemy.dp
            @e_states[pindex][:dp] = enemy.dp 
            # @hong_states[pindex][:dp] = enemy.dp 
          end
          refresh_dpmask_enemy(index,enemy)
        end
        if enemy.dp < oridp
          #l = [(enemy.mp - orimp).abs/20.to_i,10].max
          l = 0.2
          @e_states[pindex][:dp] -= l
          if @e_states[pindex][:dp] <= enemy.dp
            @e_states[pindex][:dp] = enemy.dp 
            # @hong_states[pindex][:dp] = enemy.dp 
          end
          refresh_dpmask_enemy(index,enemy)
        end
      else
        pindex = enemy.id.to_s + index.to_s
        orihp = @e_states[pindex][:hp]
        orimp = @e_states[pindex][:mp]
        oridp = @e_states[pindex][:dp]
        if enemy.dp > oridp
          #l = [(enemy.mp - orimp).abs/20.to_i,10].max
          l = 0.2
          @e_states[pindex][:dp] += l
          if @e_states[pindex][:dp] >= enemy.dp
            @e_states[pindex][:dp] = enemy.dp 
            # @hong_states[pindex][:dp] = enemy.dp 
          end
          refresh_dpmask_enemy(index,enemy)
        end
        if enemy.dp < oridp
          #l = [(enemy.mp - orimp).abs/20.to_i,10].max
          l = 0.2
          @e_states[pindex][:dp] -= l
          if @e_states[pindex][:dp] <= enemy.dp
            @e_states[pindex][:dp] = enemy.dp 
            # @hong_states[pindex][:dp] = enemy.dp 
          end
          refresh_dpmask_enemy(index,enemy)
        end
      end
    end
  end

  def init_enemy_face_back(enemy)
    pindex = enemy.id.to_s + enemy.index.to_s
    @enemy_face_back_hash[pindex].x = 0
  end
   #敌人战斗头像左右移动
  def init_select_enemy_face_back(enemy)
    pindex = enemy.id.to_s + enemy.index.to_s
    @enemy_face_back_hash[pindex].x = -20
    @enemy_face_back_hash[pindex]
    @enemy_face_back_hash[pindex].flash(Color.new(255,0,0,255),25)
  end

  def enemy_face_dead_alive(enemy)
    pindex = enemy.id.to_s + enemy.index.to_s
    if enemy.dead?
       @enemy_face_back_hash[pindex].tone = Tone.new(0,0,0,255)
    else
       @enemy_face_back_hash[pindex].tone = Tone.new(0,0,0,0)
    end
  end

  def update_enemy_face_back
    @enemy_face_back_hash.each { |id,sp| sp.update }
  end

  def create_enemy_face_back
    @enemy_face_back_hash = {}
    $game_troop.members.each_with_index do |enemy,index|
      pindex = enemy.id.to_s+enemy.index.to_s
      sp = Sprite.new(@viewport2)
      sp.x = 0
      sp.z = 10
      if index < 5
        if enemy.element_rate(44) != 1
          sp.bitmap = Bitmap.new("Graphics/Faces/ebface/#{(enemy.element_rate(44)*100).round}") 
        else
          sp.bitmap = Bitmap.new("Graphics/Faces/ebface/#{enemy.id}") 
        end
        #Cache.ebface(enemy.id.to_s)
        #sp.bitmap = Bitmap.new("Graphics/Faces/ebface/ok_face") 
        sp.y = 113 + index * 29
      end
      if index == 5
        sp.bitmap = Cache.bossface(enemy.id.to_s)
        #sp.bitmap = Bitmap.new("Graphics/Faces/bossface/ok_face") 
        sp.y = 68
      end
      @enemy_face_back_hash[pindex] = sp
    end
  end

  def flash_enemy_face(enemy)
    pindex = enemy.id.to_s + enemy.index.to_s
    @enemy_face_back_hash[pindex].flash(Color.new(255,0,0,255),20) unless @enemy_face_back_hash[enemy.id].nil?
  end

  def create_boss_status
    if @exist_boss
      create_boss_hp_status_back
      create_boss_mp_status_back
      create_boss_mp_status_back2
      create_boss_status_back
      create_boss_status_back2
    end
  end

  def actor_battle_member_size
    @battle_member_size
  end

  def create_actor_status_back1
    @actor_status_back1 = Sprite.new(@viewport2)
    @actor_status_back1.bitmap = Cache.hp("z#{actor_battle_member_size}0#{@actor_hp_bar_pattern}")
    @actor_status_back1.y = 587+24-91+4-35
    @actor_status_back1.x = -24+20+1030-57
     @actor_status_back1.z =  200
   # @actor_status_back1.opacity = 0
  end

  def create_actor_status_back2
    @actor_status_back2 = Sprite.new(@viewport2)
    @actor_status_back2.bitmap = Cache.hp("zhpk#{actor_battle_member_size}")
    @actor_status_back2.y = 587+20-91-35
    @actor_status_back2.x = -24+20+925
    @actor_status_back2.z =  400
  end

  def all_hide
    @actor_status_back2.visible = false
    @actor_status_back1.visible = false
    hide_boost
    @hide = 1
    @masks.each_value{|ha| ha.each_value{|spr| spr.visible = false if spr.is_a?(Sprite)}}
    @masks_hong_actor.each_value{|ha| ha.each_value{|spr| spr.visible = false if spr.is_a?(Sprite)}}
  end

  def all_hide_enemy
    @enemy_status_back2.visible = false
    @enemy_status_back1.visible = false
    @e_masks.each_value{|ha| ha.each_value{|spr| spr.visible = false if spr.is_a?(Sprite)}}
    @e_states.each_value{|ha| ha.each_value{|spr| spr.visible = false if spr.is_a?(Sprite)}}
    @hong.each_value{|ha| ha.each_value{|spr| spr.visible = false if spr.is_a?(Sprite)}}
    @enemy_state.visible = false
    if @enemy_face_back_hash
      @enemy_face_back_hash.values.each do |sp|
        sp.visible = false
      end
    end
    if exist_boss?
      @boss_hp_status_back.visible = false
      @boss_hp_status_back2.visible = false
      @boss_mp_status_back.visible = false
      @boss_mp_status_back2.visible = false
      @boss_status_back.visible = false
      @boss_status_back2.visible = false
      @boss_hp_hong.opacity = 0
      @shine.opacity = 0
    end
    @hide_enemy = 1
  end

  def all_show
    @actor_status_back2.visible = true
    @actor_status_back1.visible = true
    show_boost
    @hide = 0
    @masks.each_value{|ha| ha.each_value{|spr| spr.visible = true if spr.is_a?(Sprite)}}
    @masks_hong_actor.each_value{|ha| ha.each_value{|spr| spr.visible = true if spr.is_a?(Sprite)}}
  end

  def update_actor_status_back1
    if (Graphics.frame_count % UPDATE_RATE).zero?
      @actor_hp_bar_pattern >= 9 ? @actor_hp_bar_pattern = 0 : @actor_hp_bar_pattern += 1
    end
    @actor_status_back1.bitmap = Cache.hp("z#{actor_battle_member_size}0#{@actor_hp_bar_pattern}")
  end

  def enemy_battle_member_size
    return 5 if @exist_boss
    return $game_troop.members.size
  end

  def exist_boss?
    $game_troop.members.size >= 6
  end

  def boss
    $game_troop.members[5]
  end

  def create_enemy_status_back1
    @enemy_status_back1 = Sprite.new(@viewport2)
    @enemy_status_back1.bitmap = Cache.dhp("d#{enemy_battle_member_size}#{@enemy_hp_bar_pattern}")
    @enemy_status_back1.y = 123+3-1
    @enemy_status_back1.x = 240-6
    @enemy_status_back1.z = 50
  end

  def create_enemy_status_back2
    @enemy_status_back2 = Sprite.new(@viewport2)
    @enemy_status_back2.bitmap = Cache.dhp("d#{enemy_battle_member_size}font")
    @enemy_status_back2.y = 123-1-3
    @enemy_status_back2.x = 200-6-214+35
    @enemy_status_back2.z = 401
  end

  def update_enemy_status_back1
    if (Graphics.frame_count % UPDATE_RATE).zero?
      @enemy_hp_bar_pattern >= 9 ? @enemy_hp_bar_pattern = 1 : @enemy_hp_bar_pattern += 1
    end
    @enemy_status_back1.bitmap = Cache.dhp("d#{enemy_battle_member_size}#{@enemy_hp_bar_pattern}")
  end

  def create_boss_hp_status_back
    @boss_hp_status_back = Sprite.new(@viewport2)
    @boss_hp_status_back.bitmap = Cache.boss("#{@boss_hp_bar_pattern}")
    @boss_hp_rect = Rect.new(0,0,0,@boss_hp_status_back.bitmap.height)
    @boss_hp_status_back.src_rect = @boss_hp_rect
    @boss_hp_status_back.y = 90
    @boss_hp_status_back.x = 235
    @boss_temp_hp = 0

    @shine = Sprite.create @viewport2 do |option|
      option.attrset :x=>235,:y=>90,:z=>700,:opacity=>0
      option.bitmap = Cache.boss("shine")
    end
    @shine2 = Sprite.create @viewport3 do |option|
      option.attrset :x=>235,:y=>108,:z=>700,:opacity=>0
      option.bitmap = Cache.boss("shine2")
    end
  end

  def create_boss_mp_status_back
    @boss_mp_status_back = Sprite.new(@viewport2)
    @boss_mp_status_back.bitmap = Cache.boss("n#{@boss_mp_bar_pattern}")
    @boss_mp_rect = Rect.new(0,0,0,@boss_mp_status_back.bitmap.height)
    @boss_mp_status_back.src_rect = @boss_mp_rect
    @boss_mp_status_back.y = 108
    @boss_mp_status_back.x = 235
    @boss_temp_mp = 0
  end

  def create_boss_mp_status_back2
    @boss_mp_status_back2 = Sprite.new(nil)
    @boss_mp_status_back2.z = 1
    bitmap = Bitmap.new(380,6)
    bitmap.fill_rect(0,0,380,6, Color.new(40,40,40,255)) 
    @boss_mp_status_back2.bitmap = bitmap
    @boss_mp_status_back2.y = 90-10+4+18+6
    @boss_mp_status_back2.x = 200-16+51

    @boss_hp_status_back2 = Sprite.new(nil)
    @boss_hp_status_back2.z = 1
    bitmap_2 = Bitmap.new(512,12)
    bitmap_2.fill_rect(0,0,512,12, Color.new(40,40,40,255)) 
    @boss_hp_status_back2.bitmap = bitmap_2
    @boss_hp_status_back2.y = 90-10+4+18+6-18
    @boss_hp_status_back2.x = 200-16+51
  end

  def create_boss_status_back
    @boss_status_back = Sprite.new(@viewport2)
    @boss_status_back.bitmap = Cache.boss("bossk")
    @boss_status_back.y = 90-10+4
    @boss_status_back.x = -16
    @boss_status_back.z = 50
  end

  def create_boss_status_back2
    @boss_status_back2 = Sprite.new(@viewport1)
    bitmap = Bitmap.new(512,12)
    bitmap.fill_rect(0,0,512,12, Color.new(45,45,45,255)) 
    @boss_status_back2.bitmap = bitmap
    @boss_status_back2.y = 90-10+4+6
    @boss_status_back2.x = 200-16 + 51
    @boss_status_back2.z = 400
  end

  def update_boss_hp_status_back
    if (Graphics.frame_count % UPDATE_RATE).zero?
      @boss_hp_bar_pattern >= 9 ? @boss_hp_bar_pattern = 0 : @boss_hp_bar_pattern += 1
      @boss_hp_status_back.bitmap = Cache.boss("#{@boss_hp_bar_pattern}")
      @boss_hp_status_back.src_rect = @boss_hp_rect
    end
    @shine.opacity = 0
    if boss.hp > @boss_temp_hp 
      l = boss.mhp / 100 .to_f 
      @boss_temp_hp += l
      @boss_temp_hp_real = boss.hp if @boss_temp_hp >= boss.hp
      if @boss_temp_hp > boss.hp
        @boss_temp_hp = boss.hp 
      end
      @boss_hp_rect.width = @boss_temp_hp / boss.mhp.to_f * @boss_hp_status_back.bitmap.width
      @boss_hp_status_back.src_rect = @boss_hp_rect
      @shine.opacity = 255
      @shine.x = 235 + @boss_hp_rect.width-6

      #boss红条+学
      x=235
      w = 512 - (512 * @boss_temp_hp / boss.mhp).to_i
      w2 = (512 * @boss_temp_hp / boss.mhp).to_i
      @boss_hp_hong.color = Color.new(255,0,0)
      a = ( @boss_temp_hp_real + 1.0 - boss.hp ) 
      a = 1 if a == 0
      @boss_hp_hong.opacity = 255 * (( @boss_temp_hp + 1.0 - boss.hp) / ( a ))
      @boss_hp_hong.src_rect.width = w - (512 - (512 * boss.hp / boss.mhp).to_i)
      @boss_hp_hong.x = x + w2

    end
    if boss.hp < @boss_temp_hp and @hide_enemy == 0
      l = boss.mhp / 100 / 4.to_f 
      @boss_temp_hp -= l
      @boss_temp_hp_real = boss.hp if @boss_temp_hp <= boss.hp
      if @boss_temp_hp <= 0
        @boss_temp_hp = 0
      end
      @boss_hp_rect.width = @boss_temp_hp / boss.mhp.to_f * @boss_hp_status_back.bitmap.width
      @boss_hp_status_back.src_rect = @boss_hp_rect
      @shine.opacity = 255
      @shine.x = 235 + @boss_hp_rect.width-6

      #boss红条
      x=235
      w = 512 - (512 * @boss_temp_hp / boss.mhp).to_i
      w2 = (512 * boss.hp / boss.mhp).to_i
      @boss_hp_hong.color = Color.new(255,255,255)
      if @boss_temp_hp != nil and @boss_temp_hp_real != nil and @boss_temp_hp_real != 0
        @boss_hp_hong.opacity = 255 * (( @boss_temp_hp + 1.0 - boss.hp) /( @boss_temp_hp_real + 1.0 - boss.hp  ))
      else
        @boss_hp_hong.opacity = 255
      end
      @boss_hp_hong.src_rect.width = 512 - w2 - w
      @boss_hp_hong.x = x + w2 
    end
  end

  def update_boss_mp_status_back
    if (Graphics.frame_count % UPDATE_RATE).zero?
      if boss.mp > 0
        @boss_mp_bar_pattern >= 5 ? @boss_mp_bar_pattern = 0 : @boss_mp_bar_pattern += 1
        @boss_mp_status_back.bitmap = Cache.boss("n#{@boss_mp_bar_pattern}")
        @boss_mp_status_back.src_rect = @boss_mp_rect
      end
    end
    @shine2.opacity = 0
    if boss.mp > @boss_temp_mp
      l = boss.mmp / 100 .to_f
      @boss_temp_mp += l
      @boss_temp_mp = boss.mp if @boss_temp_mp > boss.mp
      @boss_mp_rect.width = (@boss_temp_mp / boss.mmp.to_f * @boss_mp_status_back.bitmap.width).to_i
      @boss_mp_status_back.src_rect = @boss_mp_rect
      @shine2.opacity = 255
      @shine2.x = 235+@boss_mp_rect.width-6
    end
    if boss.mp < @boss_temp_mp
      l = boss.mmp / 100 / 4.to_f
      @boss_temp_mp -= l
      @boss_temp_mp = 0 if @boss_temp_mp <= 0
      @boss_mp_rect.width = (@boss_temp_mp / boss.mmp.to_f * @boss_mp_status_back.bitmap.width).to_i
      @boss_mp_status_back.src_rect = @boss_mp_rect
      @shine2.opacity = 255
      @shine2.x = 235+@boss_mp_rect.width-6
      @boss_mp_rect
    end
  end

  def update_all_attack_text
    @all_atk_text.update
  end

  #--------------------------------------------------------------------------
  # ● 生成显示端口
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗背景
  #--------------------------------------------------------------------------
  def create_battleback
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Bitmap.new(1280,704)
    battleback_text
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗背景名称贴图
  #--------------------------------------------------------------------------
  def battleback_text
    if @back_sprite
      back = Cache.zdbg(SceneManager.scene.get_battle_back_filename) 
      @back_sprite.bitmap.blt(0,0,back,Rect.new(0,0,1280,704)) 
      #msgbox BattleManager.event_battle.background_filename
      if BattleManager.event_battle.background_filename == nil
        a = 0 #$game_variables[136][0].to_i
      else
        a = BattleManager.event_battle.background_filename[1].to_i
        a = 0 if a == nil
      end
      @back_sprite.bitmap.blt(1178+35,0,Cache.zdbg("bg_text2"),Rect.new(0,0,78,60)) 
      @back_sprite.bitmap.blt(1178,7,Cache.zdbg("bg_text"),Rect.new(0,49*a,95,49)) 
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成司马懿专用变化贴图
  #--------------------------------------------------------------------------
  def create_sima_picture(item)
    @sima = Sprite.new 
    @sima.opacity = 0
    @sima.y = 62
    @sima.z = 2
    @sima.bitmap.clear if @sima.bitmap
    if item.id == 409 or item.id == 547
      @sima.bitmap = Cache.zdbg("sima_bai") 
      @sima.blend_type = 1
    end
    if item.id == 413 or item.id == 548
      @sima.bitmap = Cache.zdbg("sima_hei")  
      @sima.blend_type = 0
    end
    for i in 0...52
      @sima.opacity += 5 if @sima.opacity <= 255
      SceneManager.scene.update_basic
    end
    
    if item.id == 409 or item.id == 547
      @sima.blend_type = 1
    end

    if item.id == 413 or item.id == 548
      @sima.blend_type = 0
      @back_sprite.bitmap.blt(0,62,Cache.zdbg("sima_hei") ,Rect.new(0,0,1280,580))
      @sima.opacity = 0
      @sima.bitmap.dispose
      @sima.dispose
      @sima = nil 
    end
  end
  #--------------------------------------------------------------------------
  # ● 删除司马懿专用变化贴图
  #--------------------------------------------------------------------------
  def sima_picture_close
    @sima2 = Sprite.new
    @sima2.opacity = 0
    @sima2.y = 62
    @sima2.z = 3
    @sima2.bitmap = Bitmap.new(1280,580)
    back = Cache.zdbg(SceneManager.scene.get_battle_back_filename) 
    @sima2.bitmap.blt(0,0,back,Rect.new(0,62,1280,580))
    for i in 0...52
      @sima2.opacity += 5
      1.times { SceneManager.scene.update_basic }
    end
    @back_sprite.bitmap.clear_rect(0,62,1280,580)
    @back_sprite.bitmap.blt(0,62,back,Rect.new(0,62,1280,580)) 
    @sima2.bitmap.dispose
    @sima2.dispose
    @sima2 = nil 
    if @sima != nil
      @sima.bitmap.dispose
      @sima.dispose
      @sima = nil 
    end
    5.times { SceneManager.scene.update_basic }
  end
  #--------------------------------------------------------------------------
  # ● 删除司马懿和孔明的特效
  #--------------------------------------------------------------------------
  def dispose_sima_over
    if @sima != nil ; @sima.bitmap.dispose ; @sima.dispose ; @sima = nil ; end
    if @sima2 != nil ; @sima2.bitmap.dispose ; @sima2.dispose ; @sima2 = nil ; end
    if @km_picture != nil ; @km_picture.bitmap.dispose ; @km_picture.dispose ; @km_picture = nil ; @km_item = nil ; end
  end
  #--------------------------------------------------------------------------
  # ● 生成孔明天变特效
  #--------------------------------------------------------------------------
  def create_km_picture(item)
    km_picture_over
    @km_picture = Sprite_Flash.new 
    @km_picture.bitmap = Cache.zdbg("km_di")  if item.id == 286
    @km_picture.bitmap = Cache.zdbg("km_shui")  if item.id == 287
    @km_picture.bitmap = Cache.zdbg("km_huo")  if item.id == 288
    @km_picture.bitmap = Cache.zdbg("km_feng")  if item.id == 289
    @km_item = item.id if item != nil 
    @km_picture.opacity = 0
    @km_picture.y = 60
    @km_picture.z = 20
    @can_updata = true
  end

  def km_item
    @km_item
  end
  #--------------------------------------------------------------------------
  # ● 更新天变
  #--------------------------------------------------------------------------
  def km_update
    @km_picture.update if @km_picture != nil and @can_updata == true
  end  
  #--------------------------------------------------------------------------
  # ● 天变结束
  #--------------------------------------------------------------------------
  def km_picture_over
    if @km_picture != nil 
     for i in 0...50
        @can_updata = false
        @km_picture.opacity -= 5
        SceneManager.scene.update_basic
     end
    end
    @km_item = nil 
    if @km_picture != nil ; @km_picture.bitmap.dispose ; @km_picture.dispose ; @km_picture = nil ; end
  end  
  #--------------------------------------------------------------------------
  # ● 生成战场背景（地面）精灵
  #--------------------------------------------------------------------------
  def create_battleback1
    @back1_sprite = Sprite.new(@viewport1)
    @back1_sprite.bitmap = battleback1_bitmap
    @back1_sprite.z = 0
    center_sprite(@back1_sprite)
  end
  #--------------------------------------------------------------------------
  # ● 生成战场背景（墙壁）精灵
  #--------------------------------------------------------------------------
  def create_battleback2
    @back2_sprite = Sprite.new(@viewport1)
    @back2_sprite.bitmap = battleback2_bitmap
    @back2_sprite.z = 1
    center_sprite(@back2_sprite)
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（地面）的位图
  #--------------------------------------------------------------------------
  def battleback1_bitmap
    if battleback1_name
      Cache.battleback1(battleback1_name)
    else
      create_blurry_background_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（墙壁）的位图
  #--------------------------------------------------------------------------
  def battleback2_bitmap
    if battleback2_name
      Cache.battleback2(battleback2_name)
    else
      Bitmap.new(1, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成由地图画面加工而来的战场背景
  #--------------------------------------------------------------------------
  def create_blurry_background_bitmap
    source = SceneManager.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(120, 16)
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（地面）的文件名
  #--------------------------------------------------------------------------
  def battleback1_name
    if $BTEST
      $data_system.battleback1_name
    elsif $game_map.battleback1_name
      $game_map.battleback1_name
    elsif $game_map.overworld?
      overworld_battleback1_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（墙壁）的文件名
  #--------------------------------------------------------------------------
  def battleback2_name
    if $BTEST
      $data_system.battleback2_name
    elsif $game_map.battleback2_name
      $game_map.battleback2_name
    elsif $game_map.overworld?
      overworld_battleback2_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def overworld_battleback1_name
    $game_player.vehicle ? ship_battleback1_name : normal_battleback1_name
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def overworld_battleback2_name
    $game_player.vehicle ? ship_battleback2_name : normal_battleback2_name
  end
  #--------------------------------------------------------------------------
  # ● 获取普通时的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def normal_battleback1_name
    terrain_battleback1_name(autotile_type(1)) ||
    terrain_battleback1_name(autotile_type(0)) ||
    default_battleback1_name
  end
  #--------------------------------------------------------------------------
  # ● 获取普通时的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def normal_battleback2_name
    terrain_battleback2_name(autotile_type(1)) ||
    terrain_battleback2_name(autotile_type(0)) ||
    default_battleback2_name
  end
  #--------------------------------------------------------------------------
  # ● 获取与地形对应的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def terrain_battleback1_name(type)
    case type
    when 24,25        # 野外
      "Wasteland"
    when 26,27        # 泥地
      "DirtField"
    when 32,33        # 沙漠
      "Desert"
    when 34           # 岩地
      "Lava1"
    when 35           # 岩地（熔岩）
      "Lava2"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 云端
      "Clouds"
    when 4,5          # 毒沼
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取与地形对应的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def terrain_battleback2_name(type)
    case type
    when 20,21        # 森林
      "Forest1"
    when 22,30,38     # 山丘
      "Cliff"
    when 24,25,26,27  # 野外、泥地
      "Wasteland"
    when 32,33        # 沙漠
      "Desert"
    when 34,35        # 岩地
      "Lava"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 云端
      "Clouds"
    when 4,5          # 毒沼
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取默认的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def default_battleback1_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # ● 获取默认的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def default_battleback2_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # ● 获取乘船时的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def ship_battleback1_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # ● 获取乘船时的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def ship_battleback2_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # ● 获取角色脚下的自动原件的种类
  #--------------------------------------------------------------------------
  def autotile_type(z)
    $game_map.autotile_type($game_player.x, $game_player.y, z)
  end
  #--------------------------------------------------------------------------
  # ● 精灵居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 敌人精灵生成
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = $game_troop.members.reverse.collect do |enemy|
      sp = Sprite_Battler.new(@viewport2, enemy)
      enemy.initialize_animation(sp)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成角色精灵
  #    默认下不显示角色的图像。为了方便使用，敌我双方使用共通的精灵。
  #--------------------------------------------------------------------------
  def create_actors
    # @actor_sprites = Array.new(4) { Sprite_Battler.new(@viewport1,actor) }
    @actor_sprites = $game_party.members.map do |actor|
      sp = Sprite_Battler.new(@viewport2, actor)
      actor.initialize_animation(sp)
      sp
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成图片精灵
  #    游戏开始时生成空的数组，在需要使用时才添加内容。
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 计时器精灵生成
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  # => 无需手动释放
  def dispose
    _dispose

    # => 无需手动释放
    # dispose_battleback1
    # dispose_battleback2
    # dispose_timer
    # dispose_viewports
    # dispose_all_atk_text
    # dispose_enemy_states
    # dispose_back_sprite
    # dispose_status_back
    # dispose_boss_hp
    # dispose_boss_mp_status
    # dispose_boss_status_back
    # dispose_boost
    # dispose_sima_over

    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_enemy_face_back
    dispose_e_masks
  end

  def dispose_boost
    if @boost_back
      if @boost_back.bitmap
        @boost_back.bitmap.dispose
      end
      @boost_back.dispose
      @boost_back = nil
    end

    if @boost_actor
      if @boost_actor.bitmap
        @boost_actor.bitmap.dispose
      end
      @boost_actor.dispose
      @boost_actor = nil
    end

    if @boost_tag
      if @boost_tag.bitmap
        @boost_tag.bitmap.dispose
      end
      @boost_tag.dispose
      @boost_tag = nil
    end

    if @boost_text
      if @boost_text.bitmap
        @boost_text.bitmap.dispose
      end
      @boost_text.dispose
      @boost_text = nil
    end
  end

  def dispose_e_masks
    if @e_masks
      @e_masks.each_pair do |key,hash|
        hp = hash[:hp]
        mp = hash[:mp]
        dp = hash[:dp] 
        dp_boss = hash[:dp_boss]  
        dp_boss_hong = hash[:dp_boss_hong]  
        dp_hong = hash[:dp_hong]  

        if hp
          if hp.bitmap
            hp.bitmap.dispose
          end
          hp.dispose
          @e_masks[key][:hp] = nil
          hp = nil
        end
        if mp
          if mp.bitmap
            mp.bitmap.dispose
          end
          mp.dispose
          @e_masks[key][:mp] = nil
          mp = nil
        end
        if dp
          if dp.bitmap
            dp.bitmap.dispose
          end
          dp.dispose
          @e_masks[key][:dp] = nil
          dp = nil
        end
        if dp_boss
          if dp_boss.bitmap
            dp_boss.bitmap.dispose
          end
          dp_boss.dispose
          @e_masks[key][:dp_boss] = nil
          dp_boss = nil
        end
        if dp_boss_hong
          if dp_boss_hong.bitmap
            dp_boss_hong.bitmap.dispose
          end
          dp_boss_hong.dispose
          @e_masks[key][:dp_boss_hong] = nil
          dp_boss_hong = nil
        end
        if dp_hong
          if dp_hong.bitmap
            dp_hong.bitmap.dispose
          end
          dp_hong.dispose
          @e_masks[key][:dp_hong] = nil
          dp_hong = nil
        end
      end
      @e_masks.clear
      @e_masks = nil
    end

    if @hong
      @hong.each_pair do |key,hash|
        hp = hash[:hp]
        mp = hash[:mp]
        dp = hash[:dp] 
        dp_boss_shine = hash[:dp_boss_shine]
        if hp
          if hp.bitmap
            hp.bitmap.dispose
          end
          hp.dispose
          @hong[key][:hp] = nil
          hp = nil
        end
        if mp
          if mp.bitmap
            mp.bitmap.dispose
          end
          mp.dispose
          @hong[key][:mp] = nil
          mp = nil
        end
        if dp
          if dp.bitmap
            dp.bitmap.dispose 
          end
          dp.dispose
          @hong[key][:dp] = nil
          dp = nil
        end
        if dp_boss_shine
          if dp_boss_shine.bitmap
            dp_boss_shine.bitmap.dispose
          end
                    dp_boss_shine.dispose
          dp_boss_shine = nil
        end
      end
      @hong.clear
      @hong = nil
    end

    if @masks_hong_actor
      @masks_hong_actor.each_pair do |key,hash|
        hp = hash[:hp]
        mp = hash[:mp]
        ap = hash[:ap]
        if hp
          if hp.bitmap
            hp.bitmap.dispose
          end
          hp.dispose
          @masks_hong_actor[key][:hp] = nil
          hp = nil
        end
        if mp
          if mp.bitmap
            mp.bitmap.dispose
          end
          mp.dispose
          @masks_hong_actor[key][:mp] = nil
          mp = nil
        end
        if ap
          if ap.bitmap
            ap.bitmap.dispose
          end
          ap.dispose
          @masks_hong_actor[key][:ap] = nil
          ap = nil
        end
      end
      @masks_hong_actor.clear
      @masks_hong_actor = nil
    end

    if @masks
      @masks.each_pair do |key,hash|
        hp = hash[:hp]
        mp = hash[:mp]
        ap = hash[:ap]
        ap_100 = hash[:ap_100]
        ap_tag = hash[:ap_tag]
        if hp
          if hp.bitmap
            hp.bitmap.dispose
          end
          hp.dispose
          @masks[key][:hp] = nil
          hp = nil
        end
        if mp
          if mp.bitmap
            mp.bitmap.dispose
          end
          mp.dispose
          @masks[key][:mp] = nil
          mp = nil
        end
        if ap
          if ap.bitmap
            ap.bitmap.dispose
          end
          ap.dispose
          @masks[key][:ap] = nil
          ap = nil
        end
        if ap_100
          if ap_100.bitmap
            ap_100.bitmap.dispose
          end
          ap_100.dispose
          @masks[key][:ap_100] = nil
          ap_100 = nil
        end
        if ap_tag
          if ap_tag.bitmap
            ap_tag.bitmap.dispose
          end
          ap_tag.dispose
          @masks[key][:ap_tag] = nil
          ap_tag = nil
        end
      end
      @masks.clear
      @masks = nil
    end
  end

  def dispose_boss_status_back
    if @boss_status_back

      if @boss_status_back.bitmap
        @boss_status_back.bitmap.dispose
      end
      @boss_status_back.dispose
      @boss_status_back = nil


      if @boss_hp_hong.bitmap
        @boss_hp_hong.bitmap.dispose
      end
      @boss_hp_hong.dispose

      if @boss_hp
         @boss_hp.dispose
         @boss_hp = nil
      end
    end
    if @boss_status_back2
      if @boss_status_back2.bitmap
        @boss_status_back2.bitmap.dispose
      end
      @boss_status_back2.dispose
      @boss_status_back2 = nil
    end
  end

  def dispose_boss_mp_status
    if @boss_mp_status_back
      if @boss_mp_status_back.bitmap
        @boss_mp_status_back.bitmap.dispose
      end
      @boss_mp_status_back.dispose
      @boss_mp_status_back = nil
    end
    if @boss_mp_status_back2
      if @boss_mp_status_back2.bitmap
        @boss_mp_status_back2.bitmap.dispose
      end
       @boss_mp_status_back2.dispose
    end
    if @boss_hp_status_back2
      if @boss_hp_status_back2.bitmap
        @boss_hp_status_back2.bitmap.dispose
      end
            @boss_hp_status_back2.dispose
      @boss_hp_status_back2 = nil
    end
  end

  def dispose_boss_hp
    if @boss_hp_status_back
      if @boss_hp_status_back.bitmap
        @boss_hp_status_back.bitmap.dispose
      end
      @boss_hp_status_back.dispose
      @boss_hp_status_back = nil
    end
    if @shine
      if @shine.bitmap
        @shine.bitmap.dispose
      end
            @shine.dispose
      @shine = nil
    end
    if @shine2
      if @shine2.bitmap
        @shine2.bitmap.dispose
      end
      @shine2.dispose
      @shine2 = nil
    end
  end

  def dispose_enemy_face_back
    if @enemy_face_back_hash
      @enemy_face_back_hash.each_pair do |k,sp|
        if sp
          sp.bitmap.dispose
          sp.dispose
          @enemy_face_back_hash[k] = nil
        end
        sp = nil
      end
      @enemy_face_back_hash.clear
      @enemy_face_back_hash = nil
    end
  end

  def dispose_status_back
    if @enemy_status_back1
      if @enemy_status_back1.bitmap
        @enemy_status_back1.bitmap.dispose
      end
      @enemy_status_back1.dispose
      @enemy_status_back1 = nil
    end

    if @enemy_status_back2
      if @enemy_status_back2.bitmap
        @enemy_status_back2.bitmap.dispose
      end
      @enemy_status_back2.dispose
      @enemy_status_back2 = nil
    end
  end

  def dispose_back_sprite
    if @back_sprite
      if @back_sprite.bitmap
        @back_sprite.bitmap.dispose
      end
      @back_sprite.dispose
      @back_sprite = nil
    end

   if @actor_status_back1
      if @actor_status_back1.bitmap
        @actor_status_back1.bitmap.dispose
      end
      @actor_status_back1.dispose
      @actor_status_back1 = nil
    end

   if @actor_status_back2
      if @actor_status_back2.bitmap
        @actor_status_back2.bitmap.dispose
      end
      @actor_status_back2.dispose
      @actor_status_back2 = nil
    end

  end

  def dispose_enemy_states
    if @enemy_state
      if @enemy_state.bitmap
        @enemy_state.bitmap.dispose
      end
      @enemy_state.dispose
      @enemy_state = nil
    end
  end

  def dispose_all_atk_text
    if @all_atk_text
      if @all_atk_text.bitmap
        @all_atk_text.bitmap.dispose
      end
      @all_atk_text.dispose
      @all_atk_text = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放战场背景的精灵（地面）
  #--------------------------------------------------------------------------
  def dispose_battleback1
    if @back1_sprite
      if @back1_sprite.bitmap
        @back1_sprite.bitmap.dispose
      end
      @back1_sprite.dispose
      @back1_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放战场背景的精灵（墙壁）
  #--------------------------------------------------------------------------
  def dispose_battleback2
    if @back2_sprite
      if @back2_sprite.bitmap
        @back2_sprite.bitmap.dispose
      end
      @back2_sprite.dispose
      @back2_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放敌人精灵
  #--------------------------------------------------------------------------
  def dispose_enemies
    if @enemy_sprites
      @enemy_sprites.each_with_index do |sprite,_index| 
        sprite.dispose
        @enemy_sprites[_index] = nil
        sprite = nil
      end
      @enemy_sprites.clear
      @enemy_sprites = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放角色精灵
  #--------------------------------------------------------------------------
  def dispose_actors
    if @actor_sprites
      @actor_sprites.each_with_index do |sprite,_index| 
        sprite.dispose
        @actor_sprites[_index] = nil
        sprite = nil
      end
      @actor_sprites.clear
      @actor_sprites = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放图片精灵
  #--------------------------------------------------------------------------
  def dispose_pictures
    if @picture_sprites
      @picture_sprites.compact.each_with_index do |sprite,_index| 
        sprite.dispose
        @picture_sprites[_index] = nil
        sprite = nil
      end
      @picture_sprites.clear
      @picture_sprites = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放计时器精灵
  #--------------------------------------------------------------------------
  def dispose_timer
    if @timer_sprite
      @timer_sprite.dispose
      @timer_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放显示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @viewport1 = nil
    @viewport2 = nil
    @viewport3 = nil
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    #update_battleback1
    #update_battleback2

    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
    update_bar
    update_enemy_face_back
    update_all_attack_text if @show_all_atk_text
    ap_tag_update
    km_update

  end

  def ap_tag_update #AP满时的闪烁标志
    if @masks != nil and SceneManager.scene_is?(Scene_Battle) and @hide == 0
      for i in 0...$game_party.members.size
        if $game_party.members[i].tp == 100 
          if i < 5 and $game_party.members[i] != nil 
            if $game_party.members[i].hp > 0
              @masks[$game_party.members[i].id][:ap_tag].visible = true
              @masks[$game_party.members[i].id][:ap_tag].update 
            else
              @masks[$game_party.members[i].id][:ap_tag].visible = false 
              $game_party.members[i].tp = 0 unless $game_party.exist_jm_skill?(627)
            end
          end   
        else
          if i < 5 and $game_party.members[i] != nil and $game_party.members[i].hp > 0
            @masks[$game_party.members[i].id][:ap_tag].visible = false 
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def refresh_enemy_status(enemy_id)
    bitmap = Cache.system("Iconset")
    
    $game_troop.members.each_with_index do |enemy,index|
      if enemy.id == enemy_id
        if index < 5
          x = 0+3; y = 29 * index + 122
        end
        if index == 5
          x = 266; y = 108
        end
        @enemy_state.bitmap.clear_rect(x,y,192,24)
        
        icons = (enemy.state_icons + enemy.buff_icons)[0, 192 / 24]
        icons.each_with_index do |n, i|
          rect = Rect.new(n % 16 * 24, n / 16 * 24, 24, 24)
          @enemy_state.bitmap.blt(x + 24 * i, y, bitmap, rect, 255)
        end
      end
    end
    bitmap.dispose
  end

  def update_bar
    if @allload
      update_actor_status_back1
      update_mask
    end
    update_enemy_status_back1
    update_mask_enemy
    if @exist_boss
      update_boss_mp_status_back
      update_boss_hp_status_back
    end
    update_boost
  end

  #--------------------------------------------------------------------------
  # ● 更新战场背景的精灵（地面）
  #--------------------------------------------------------------------------
  def update_battleback1
    @back1_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新战场背景的精灵（墙壁）
  #--------------------------------------------------------------------------
  def update_battleback2
    @back2_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新敌人的精灵
  #--------------------------------------------------------------------------
  def update_enemies
    @enemy_sprites.each {|sprite| sprite.update } if @enemy_sprites
  end
  #--------------------------------------------------------------------------
  # ● 更新角色的精灵
  #--------------------------------------------------------------------------
  def update_actors
    if @actor_sprites
      @actor_sprites.each_with_index do |sprite, i|
        sprite.battler = $game_party.members[i]
        sprite.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新图片精灵
  #--------------------------------------------------------------------------
  def update_pictures
    $game_troop.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(nil, pic)
      @picture_sprites[pic.number].update
      @picture_sprites[pic.number].z = 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新计时器精灵
  #-------------------------------F-------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新显示端口
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone.set($game_troop.screen.tone)
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color.set($game_troop.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人和角色的精灵
  #--------------------------------------------------------------------------
  def battler_sprites
    (@enemy_sprites || []) + (@actor_sprites || [])
  end
  #--------------------------------------------------------------------------
  # ● 判定是否动画显示中
  #--------------------------------------------------------------------------
  def animation?
    battler_sprites.any? {|sprite| sprite.animation? }
  end
  #--------------------------------------------------------------------------
  # ● 判定效果是否执行中
  #--------------------------------------------------------------------------
  def effect?
    battler_sprites.any? {|sprite| sprite.effect? }
  end
end
