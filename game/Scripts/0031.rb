#encoding:utf-8
#==============================================================================
# ★ RGSS3_视界制限 Ver1.1
#==============================================================================
=begin

作者：tomoaky
首发网站：ひきも记 (http://hikimoki.sakura.ne.jp/)

设定号码的地图限制视野。

写在角色，职业，是在武器(防护具)的备注中的标签
能补正视野限制的尺寸。
例）<视界补正 32>
视界32点扩大広。
只有战斗成员进行视野补正价值的计算。

游戏变量（默认情况下，＃9），可以调整大小使用视图领域。

加入上述所有设置，将获得的实际大小限制的能见度。
然而，如果尚未设置能见度限制的地图上都是无效的。

因为每帧都会重绘整个屏幕的Sprite
将会有所加重。

操作所需的图像
  Graphics/System/sight_shadow.png
  
游戏变量使用（默认设置）
  0009

2012.02.05  Ver1.1
  ・调整Z坐标使计时器使不被遮住
  ・加使用游戏变量补正视野限制尺寸的功能(通过变量可做成开/関效果)
  
2012.01.20  Ver1.0
  公开

=end

#==============================================================================
# □ 设定项目
#==============================================================================
module TMBLSIGHT
  # 指定几号的地图进行视界制限
  # 例）SIGHT[3] = 128  # 设置地图号码３的视野能见度128点矩形

  SIGHT = {}

  # 测试模式不限制视野
  #unless $TEST
    SIGHT[369]  = 768
    SIGHT[373]  = 768
    SIGHT[856]  = 768
    SIGHT[49]  = 768
    SIGHT[51]  = 768
    SIGHT[880] = 768
    SIGHT[292] = 768
    SIGHT[293] = 768
    SIGHT[294] = 768
    SIGHT[29] = 768
    SIGHT[37] = 768
    SIGHT[389] = 768
    SIGHT[390] = 768
    SIGHT[391] = 768
    SIGHT[93]  = 768
    SIGHT[367]  = 768
    SIGHT[368]  = 768
    SIGHT[435]  = 768
    SIGHT[301]  = 768
    SIGHT[307]  = 768
    SIGHT[446]  = 768
 # end
  
  VN_SIGHT = 888    # 设定尺寸大小补正在游戏中使用的游戏变量
end

#==============================================================================
# □ RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 視界制限の補正値
  #--------------------------------------------------------------------------
  def sight_power
    unless @sight_power
      @sight_power = /<視界補正\s*(\-*\d+)\s*>/ =~ @note ? $1.to_i : 0
    end
    @sight_power
  end
end
 
#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor
  #--------------------------------------------------------------------------
  # ○ 視界制限の補正値
  #--------------------------------------------------------------------------
  def sight_power
    feature_objects.inject(0) {|result, object| result + object.sight_power }
  end
end
 
#==============================================================================
# □ Sprite_SightShadow
#==============================================================================
class Sprite_SightShadow < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.z = -1
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @bitmap_shadow = Bitmap.new("Graphics/System/sight_shadow")
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    @bitmap_shadow.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if TMBLSIGHT::SIGHT[$game_map.map_id]
      self.visible = true
      w = TMBLSIGHT::SIGHT[$game_map.map_id]      # マップに設定された補正値
      w += $game_variables[TMBLSIGHT::VN_SIGHT]   # ゲーム変数による補正値
      $game_party.battle_members.each do |actor|
        w = [w + actor.sight_power, 48].max       # 戦闘メンバーの補正値
      end
      x = $game_player.screen_x - w / 2
      y = $game_player.screen_y - w / 2 - 16
      if w != @last_w || x != @last_x || y != @last_y
        @last_w = w
        @last_x = x
        @last_y = y
        self.bitmap.clear
        rect = Rect.new(x, y, w, w)
        self.bitmap.stretch_blt(rect, @bitmap_shadow, @bitmap_shadow.rect)
        color = Color.new(0, 0, 0)
        self.bitmap.fill_rect(0, 0, Graphics.width, y, color)
        self.bitmap.fill_rect(0, y + w, Graphics.width, Graphics.height - y - w, color)
        self.bitmap.fill_rect(0, y, x, w, color)
        self.bitmap.fill_rect(x + w, y, Graphics.width - x - w, w, color)
      end
    else
      self.visible = false
    end
  end
end
 
#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tmblsight_spriteset_map_initialize initialize
  def initialize
    tmblsight_spriteset_map_initialize
    create_sight_shadow
  end
  #--------------------------------------------------------------------------
  # ○ 視界制限スプライトの作成
  #--------------------------------------------------------------------------
  def create_sight_shadow
    @sight_shadow_sprite = Sprite_SightShadow.new(@viewport2)
    update_sight_shadow
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias tmblsight_spriteset_map_dispose dispose
  def dispose
    dispose_sight_shadow
    tmblsight_spriteset_map_dispose
  end
  #--------------------------------------------------------------------------
  # ○ 視界制限スプライトの解放
  #--------------------------------------------------------------------------
  def dispose_sight_shadow
    @sight_shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmblsight_spriteset_map_update update
  def update
    update_sight_shadow
    tmblsight_spriteset_map_update
  end
  #--------------------------------------------------------------------------
  # ○ 視界制限スプライトの更新
  #--------------------------------------------------------------------------
  def update_sight_shadow
    @sight_shadow_sprite.update if @sight_shadow_sprite
  end
end

#==============================================================================
# +++ MOG - Weather EX (v1.5) +++
#==============================================================================
# By Moghunter 
# http://www.atelier-rgss.com/
#==============================================================================
# Sistema de clima com efeitos animados.
#==============================================================================
# As imagens usadas pelo sistema do clima devem ser gravadas na pasta
#
# GRAPHICS/WEATHER/
#
#==============================================================================
# UTILIZAÇÃO
# 
# Use o comando abaixo através da função chamar script.*(Evento)
#
# weather(TYPE, POWER, IMAGE_FILE)
#
# TYPE - Tipo de clima. (de 0 a 6)
# POWER - Quantidade de partículas na tela. (de 1 a 10)
# IMAGE_FILE - Nome da imagem.
#
# Exemplo (Eg)
#
# weather(0, 5, "Leaf")
#
#==============================================================================
# Tipos de Clima.
#
# O sistema vem com 7 climas pré-configurados, que podem ser testados na demo
# que vem com esse script.
#
# 0 - (Rain)  
# 1 - (Wind)
# 2 - (Fog)  
# 3 - (Light)
# 4 - (Snow)
# 5 - (Spark)
# 6 - (Random)
#
#==============================================================================
# NOTA
#
# Evite de usar imagens muito pesadas ou de tamanho grande, caso for usar
# diminua o poder do clima para evitar lag.
#
#==============================================================================
#==============================================================================
# Para parar o clima use o comando abaixo.
#
# weather_stop
#
#==============================================================================
# Para parar reativar o clima com as caracteríticas préviamente usadas use o
# comando abaixo.
#
# weather_restore
#==============================================================================
# Se você precisar ativar um novo clima mas deseja gravar as caracteríticas 
# do clima atual para ser reativado depois use os códigos abaixo.
#
# weather_store
# weather_restore_store
#
#==============================================================================

#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v 1.5 - Correção definitiva para erro de Crash randômico. 
# v 1.4 - Melhoria no sistema de dispose. * (Para quem estiver tendo problema 
#         com crashes randômicos.)
# v 1.3 - Adição do comando weather_store e weather_recover_store
# v 1.2 - Melhor codificação e compatibilidade.
# v 1.1 - Correção do Bug de salvar através do evento.
# v 1.0 - Weather EX ativo na batalha.
#       - Função restore/pause que permite reativar o clima com as
#         caracteríticas previamente usadas, ou seja, dá uma pausa no clima.
# v 0.9 - Melhoria no sistema de dispose.
#==============================================================================
module MOG_WEATHER_EX
  #Prioridade do clima na tela.
  WEATHER_SCREEN_Z = 50 
  #Definição da eficiência do poder do clima.
  #NOTA -  Um valor muito alto pode causar lag, dependendo do tipo de clima e
  #        imagem usada.
  WEATHER_POWER_EFIC = 7
  #Ativar o clima no sistema de batalha.
  WEATHER_BATTLE = true
end

#==============================================================================
# ■ Cache
#==============================================================================
module Cache
  
  #--------------------------------------------------------------------------
  # ● Weather
  #--------------------------------------------------------------------------
  def self.weather(filename)
      load_bitmap("Graphics/Pictures/", filename)
  end
  
end

#==============================================================================
# ■ Game System
#==============================================================================
class Game_System
  
  attr_accessor :weather
  attr_accessor :weather_restore
  attr_accessor :weather_record_set
  attr_accessor :weather_temp
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias weather_ex_initialize initialize  
  def initialize
      @weather = [-1,0,""]
      @weather_restore = [-1,0,""]
      @weather_temp = [-1,0,""]
      @weather_record_set = [-1,0,""]
      weather_ex_initialize 
  end  
  
end  

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp

  attr_accessor :weather_ex_set
  attr_accessor :weather_fade
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_weather_ex_temp_initialize initialize
  def initialize
      @weather_ex_set = []
      @weather_fade = false
      mog_weather_ex_temp_initialize
  end  
  
end

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● 战绩点数
  #--------------------------------------------------------------------------    
  def make_score
      points = 0
      s = $game_party.members.size 
      h = $game_party.house_members.size
      a = 0
      for i in 0...s
        a += $game_party.members[i].level
      end 
      for i in 0...h
        a += $game_party.house_members[i].level
      end  
      damage = $game_party.score_damage.to_i                   # 队伍伤害
      sup =    $game_party.score_sup.to_i                      # 队伍辅助
      lv =     ( (a*1.0) / (s+h) ).to_i                        # 队伍+仓库全平均等级
      dead =   $game_party.score_dead.to_i                     # 队伍死亡次数
      num = 0
      for i in 304...481
          num += 1 if $game_party.has_item?($data_items[i])
      end 
      zaoyi =  num.to_i  # 造诣完成数量
      $game_variables[222] = zaoyi
      hid =    $game_variables[137].to_i                       # 寻找隐藏数量

    # points_text_01
      points += damage / 100.0

    # points_text_02     
      points += sup / 100.0


    # points_text_03
      points *= 1+(lv*lv)/2500.0


    # points_text_04
      points -= dead * 50
      points -= dead * 100  if dead > 20
      points -= dead * 150  if dead > 40
      points -= dead * 200  if dead > 60
      points -= dead * 250  if dead > 80
      points -= dead * 300  if dead > 100
      #p points

    # points_text_05
      for i in 400...451  #蓝色造诣+分
          points += 3000 if $game_party.has_item?($data_items[i])   
      end
      for i in 460...481  #金色造诣+分
          points += 9000 if $game_party.has_item?($data_items[i])   
      end
      points += zaoyi * 1200
      #p points

    # points_text_06
      points += hid * 250
      points *= 1.5   if $game_variables[309] > 0
      points *= 0.7   if $game_variables[309] < 0
      points = points.to_i
      $game_variables[281] = points
      $game_variables[281] = 0 if $game_variables[281] < 0
  end
  #--------------------------------------------------------------------------
  # ● Weather
  #--------------------------------------------------------------------------    
  def weather(type = -1, power = 0, image = "")
      $game_temp.weather_fade = false
      $game_system.weather.clear
      $game_system.weather = [type,power,image]
  end
  
  #--------------------------------------------------------------------------
  # ● Weather Stop
  #--------------------------------------------------------------------------     
  def weather_stop
      $game_temp.weather_fade = false
      $game_system.weather.clear
      $game_system.weather = [-1,0,""]
      $game_system.weather_restore  = [-1,0,""]
      $game_system.weather_temp = [-1,0,""]      
  end
  
  #--------------------------------------------------------------------------
  # ● Weather Restore
  #--------------------------------------------------------------------------       
  def weather_restore
      $game_temp.weather_fade = false
      if $game_system.weather[0] != -1
         w = $game_system.weather
         $game_system.weather_restore = [w[0],w[1],w[2]] 
         $game_system.weather.clear
         $game_system.weather = [-1,0,""]
         return
      end
      w = $game_system.weather_restore 
      weather(w[0],w[1],w[2])
  end
  
  #--------------------------------------------------------------------------
  # ● Weather Fade
  #--------------------------------------------------------------------------         
  def weather_fade(value)
      $game_temp.weather_fade = value
  end
  
  #--------------------------------------------------------------------------
  # ● Weather Store
  #--------------------------------------------------------------------------           
  def weather_store
      w = $game_system.weather 
      $game_system.weather_record_set = [w[0],w[1],w[2]]
  end  
  
  #--------------------------------------------------------------------------
  # ● Weather Restore Store
  #--------------------------------------------------------------------------           
  def weather_restore_store
      w = $game_system.weather_record_set
      weather(w[0],w[1],w[2])      
  end    
  
end  

#==============================================================================
# ■ Weather_EX
#==============================================================================
class Weather_EX < Sprite
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  def initialize(viewport = nil ,type = 0, image_name = "",index = 0,nx,ny)
      super(viewport)
      self.bitmap = Cache.weather(image_name.to_s)
      self.opacity = 0
      @cw = self.bitmap.width
      @ch = self.bitmap.height
      @angle_speed = 0
      @x_speed = 0
      @y_speed = 0
      @zoom_speed = 0
      @opacity_speed = 0
      @type = type
      @index = index
      @old_nx = nx
      @old_ny = ny
      type_setup(nx,ny)
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------    
  def dispose
      if self.bitmap != nil
         self.bitmap.dispose
         self.bitmap = nil
      end   
      super
  end
  
  #--------------------------------------------------------------------------
  # ● Pre Values
  #--------------------------------------------------------------------------    
  def pre_values(index)
      return if  $game_temp.weather_ex_set[index] == nil
      self.x = $game_temp.weather_ex_set[index][0]
      self.y = $game_temp.weather_ex_set[index][1]
      self.opacity = $game_temp.weather_ex_set[index][2]
      self.angle = $game_temp.weather_ex_set[index][3]
      self.zoom_x = $game_temp.weather_ex_set[index][4]
      self.zoom_y = $game_temp.weather_ex_set[index][4]
      $game_temp.weather_ex_set[index].clear
      $game_temp.weather_ex_set[index] = nil
  end  
  
  #--------------------------------------------------------------------------
  # ● Type Setup
  #--------------------------------------------------------------------------      
  def type_setup(nx = 0, ny = 0)
      @cw2 = [(1344 + @cw) + nx, -(96 + @cw) + nx]
      @ch2 = [(768 + @ch) + ny, -(96 + @ch) + ny]
      check_weather_type
      pre_values(@index)
      @opacity_speed = -1 if $game_temp.weather_fade
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------    
  def update_weather(nx = 0, ny = 0)
      self.x += @x_speed
      self.y += @y_speed
      self.opacity += @opacity_speed
      self.angle += @angle_speed
      self.zoom_x += @zoom_speed
      self.zoom_y += @zoom_speed
      check_loop_map(nx,ny)
      type_setup(nx,ny) if can_reset_setup?
  end  

  #--------------------------------------------------------------------------
  # ● Check Loop Map
  #--------------------------------------------------------------------------        
  def check_loop_map(nx,ny)
      if (@old_nx - nx).abs > 32
         @cw2 = [(1344 + @cw) + nx, -(96 + @cw) + nx]
         self.x += nx
         self.x -= @old_nx if nx == 0
      end   
      if (@old_ny - ny).abs > 32
         @ch2 = [(768 + @ch) + ny, -(96 + @ch) + ny]
         self.y += ny
         self.y -= @old_ny if ny == 0
      end         
      @old_nx = nx
      @old_ny = ny    
  end  
    
  #--------------------------------------------------------------------------
  # ● Can Reset Setup
  #--------------------------------------------------------------------------      
  def can_reset_setup?
      return true if self.x > @cw2[0] or self.x <  @cw2[1]
      return true if self.y > @ch2[0]  or self.y < @ch2[1] 
      return true if self.opacity == 0
      return true if self.zoom_x > 2.0 or self.zoom_x < 0.5 
      return false
  end
  
 #--------------------------------------------------------------------------
 # ● Check Weather Type
 #--------------------------------------------------------------------------                         
 def check_weather_type 
     case @type
         when 0;   rain
         when 1;   wind   
         when 2;   fog
         when 3;   light
         when 4;   snow
         when 5;   spark
         when 6;   random 
         when 7;   fire   
         when 8;   xian    
         when 9;   title    
         when 10;  score  
         when 11;  sima        
      end
 end
 #--------------------------------------------------------------------------
 # ● Snow
 #--------------------------------------------------------------------------                          
 def snow
     #self.angle = rand(360)
     #self.x = rand(@cw2[0])
    # self.y = rand(@ch2[0])
     #self.opacity = 1
   #  self.zoom_x = (rand(50) + 50) / 100.0
    # self.zoom_y = self.zoom_x
    # @y_speed = [[rand(5), 1].max, 5].min
    # @opacity_speed = 5
    #  self.blend_type = 1   
    # @angle_speed = rand(3)

    # self.angle = rand_angle == 1 ? 180 : 0
    # self.angle = rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])

    # self.zoom_x = (rand(50)+50) / 100.0
    # self.zoom_y = self.zoom_x
    # @angle_speed = [[rand(3), 1].max, 3].min
     @x_speed = [[rand(15), 1].max, 15].min
     self.opacity = 1
     self.blend_type = 1
     @opacity_speed = 2
 end   
 
 #--------------------------------------------------------------------------
 # ● Spark
 #--------------------------------------------------------------------------                           
 def spark
     self.angle = rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.zoom_x = (rand(100)+40) / 100.0
     self.zoom_y = self.zoom_x
     self.blend_type = 1     
     @opacity_speed = 6
     @zoom_speed = -0.003
 end
 
 #--------------------------------------------------------------------------
 # ● Rain
 #--------------------------------------------------------------------------                          
 def fire
     self.x = rand(@cw2[0])       
     if @start == nil
        self.y = rand(@ch2[0]) 
        @start = true
     else
        self.y = @ch2[1]        
     end   
     self.blend_type = 1  
     self.opacity = 1
     self.zoom_y = (rand(100)) / 100.0
     self.zoom_x = (rand(100)) / 100.0
     @y_speed = [[rand(10) + 10, 10].max, 20].min
     @opacity_speed = 10
     @angle_speed = 0
     @x_speed = 0
     self.angle = 0
 end  


 def rain
     self.angle = 0#rand(360)
     self.x = rand(@cw2[0])       
     if @start == nil
        self.y = rand(@ch2[0]) 
        @start = true
     else
        self.y = @ch2[1]        
     end   
     self.opacity = 1
     self.zoom_y = (rand(0) + 100) / 100.0
     self.zoom_x = (rand(0) + 100) / 100.0
     @y_speed = [[rand(10) + 10, 10].max, 20].min
     @opacity_speed = 10
     @angle_speed = 0
     @x_speed = 0
 end    
 #--------------------------------------------------------------------------
 # ● Fog
 #--------------------------------------------------------------------------                            
 def fog
     self.angle = 0#rand_angle == 1 ? 180 : 0
     self.angle = 0#rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])

     self.zoom_x = (rand(100)) / 100.0
     self.zoom_y = self.zoom_x
     @angle_speed = [[rand(3), 1].max, 3].min
     @x_speed = [[rand(10), 1].max, 10].min
     self.opacity = 1
     self.blend_type = 1
     @opacity_speed = 2
 end


  def xian
 
     self.angle = 0#rand_angle == 1 ? 180 : 0
     self.angle = 0#rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])

     self.zoom_x = (rand(100)) / 20.0
     self.zoom_y = self.zoom_x
     @angle_speed = 0
     @x_speed = [[rand(10), 1].max, 10].min
     self.opacity = 1
     self.blend_type = 1
     @opacity_speed = 2
 end
 
 #--------------------------------------------------------------------------
 # ● Light
 #--------------------------------------------------------------------------                           
 def light 
     self.angle = 0#rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.zoom_x = (rand(100) ) / 100.0
     self.zoom_y = self.zoom_x
     self.blend_type = 1
     @angle_speed = [[rand(3), 1].max, 3].min
     @y_speed = -[[rand(10), 1].max, 10].min
     @opacity_speed = 2
     @x_speed = 0
 end

  def sima
     self.angle = 0#rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.zoom_x = (rand(100) ) / 100.0
     self.zoom_y = self.zoom_x
     self.blend_type = 1
     @angle_speed = [[rand(3), 1].max, 3].min
     @y_speed = -[[rand(5), 1].max, 5].min
     @opacity_speed = 2
     @x_speed = 0
 end

  def title
     self.angle = 0#rand(30)
     self.x = rand(600)+320
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.zoom_x = (rand(100) ) / 100.0
     self.zoom_y = self.zoom_x
     self.blend_type = 1
     @angle_speed = [[rand(3), 1].max, 3].min
     @y_speed = -[[rand(10), 1].max, 10].min
     @opacity_speed = 2
     @x_speed = 0
 end

 def score
     self.angle = 0#rand(30)
     self.x = rand(600)+320
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.zoom_x = (rand(100) ) / 100.0
     self.zoom_y = self.zoom_x
     self.blend_type = 1
     @angle_speed = [[rand(3), 1].max, 3].min
     @y_speed = -[[rand(5), 1].max, 5].min
     @x_speed = 0
     @opacity_speed = 2
 end
 
 #--------------------------------------------------------------------------
 # ● Wind
 #--------------------------------------------------------------------------                          
 def wind
     self.angle = 0#rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.zoom_x = (rand(50) + 50) / 100.0
     self.zoom_y = self.zoom_x
     self.blend_type = 0
     @x_speed = [[rand(10), 1].max, 10].min
     @y_speed = [[rand(10), 1].max, 10].min
     @opacity_speed = 10
     @angle_speed = 0
 end   
 #--------------------------------------------------------------------------
 # ● Random
 #--------------------------------------------------------------------------                          
 def random
     #self.angle = rand(360)
     self.x = rand(@cw2[0])
     self.y = rand(@ch2[0])
     self.opacity = 1
     self.blend_type = 1
     self.zoom_x = (rand(100)) / 100.0
     self.zoom_y = self.zoom_x
     x_s = [[rand(5), 1].max, 5].min
     y_s = [[rand(5), 1].max, 5].min
     rand_x = rand(2)
     rand_y = rand(2)
     @x_speed = rand_x == 1 ? x_s : -x_s
     @y_speed = rand_y == 1 ? y_s : -y_s      
     @opacity_speed = 10
     @angle_speed = [[rand(2), 1].max, 3].min
     @y_speed = -[[rand(6), 1].max, 6].min
 end    
 
end

#==============================================================================
# ■ Module Weather EX
#==============================================================================
module Module_Weather_EX
  
 #--------------------------------------------------------------------------
 # ● Create Weather EX
 #--------------------------------------------------------------------------                   
  def create_weather_ex
      dispose_weather_ex
      create_weather_viewport
      create_weather_sprite     
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose Wheater EX
 #--------------------------------------------------------------------------                     
  def dispose_weather_ex
      dispose_weather_ex_sprite
      dispose_weather_ex_viewport
  end  
 
 #--------------------------------------------------------------------------
 # ● Create Weather Viewport
 #--------------------------------------------------------------------------                     
  def create_weather_viewport
      dispose_weather_ex_viewport
      if SceneManager.scene.is_a?(Scene_Battle) 
          @viewport_weather_ex = Viewport.new(-32,  60, 1344, 580)
      else
          @viewport_weather_ex = Viewport.new(-32, -32, 1344, 768)
      end
      @viewport_weather_ex.z = MOG_WEATHER_EX::WEATHER_SCREEN_Z
      @viewport_weather_ex.ox = ($game_map.display_x * 32)
      @viewport_weather_ex.oy = ($game_map.display_y * 32)    
      if SceneManager.scene.is_a?(Scene_Battle)  
            if  $game_switches[486] == true
                @viewport_weather_ex.visible = true
            else
                @viewport_weather_ex.visible = false 
            end
      else
         @viewport_weather_ex.visible = true 
      end
  end

 #--------------------------------------------------------------------------
 # ● Create Weather Sprite
 #--------------------------------------------------------------------------                       
  def create_weather_sprite
      dispose_weather_ex_sprite
      @old_weather = $game_system.weather
      return if $game_system.weather == [] or $game_system.weather[0] == -1
      @weather_ex = []
      index = 0
      power_efic = MOG_WEATHER_EX::WEATHER_POWER_EFIC
      power_efic = 1 if power_efic < 1
      power = [[$game_system.weather[1] * power_efic, power_efic].max, 999].min
      for i in 0...power
          @weather_ex.push(Weather_EX.new(@viewport_weather_ex,$game_system.weather[0],$game_system.weather[2],index, @viewport_weather_ex.ox, @viewport_weather_ex.oy))
          index += 1
      end            
  end

 #--------------------------------------------------------------------------
 # ● Dispose Weather EX Viewport 
 #--------------------------------------------------------------------------                       
  def dispose_weather_ex_viewport
      return if @viewport_weather_ex == nil 
      @viewport_weather_ex.dispose
  end  
  
 #--------------------------------------------------------------------------
 # ● Dispose Weather EX
 #--------------------------------------------------------------------------                   
  def dispose_weather_ex_sprite
      return if @weather_ex == nil
      index = 0
      for i in @weather_ex
        next if i.disposed?
        $game_temp.weather_ex_set[index] = [] if $game_temp.weather_ex_set[index] == nil
        $game_temp.weather_ex_set[index].push(i.x,i.y,i.opacity,i.angle,i.zoom_x)
        i.dispose
        index += 1
      end
      @weather_ex.each {|sprite| sprite.dispose}  
      @weather_ex.clear
      @weather_ex = nil
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose Refresh
 #--------------------------------------------------------------------------                    
  def dispose_refresh
      $game_temp.weather_ex_set.clear
      return if @weather_ex == nil
      @weather_ex.each {|sprite| sprite.dispose}
      @weather_ex.clear
      @weather_ex = nil
  end  
  
 #--------------------------------------------------------------------------
 # ● Update Weather EX
 #--------------------------------------------------------------------------                   
  def update_weather_ex
      refresh_weather_ex
      update_weather_ex_viewport
      return if @weather_ex == nil
      @weather_ex.each {|sprite| sprite.update_weather(@viewport_weather_ex.ox,@viewport_weather_ex.oy)} 
  end
  
 #--------------------------------------------------------------------------
 # ● Update Weather Ex Viewport
 #--------------------------------------------------------------------------                     
  def update_weather_ex_viewport
      return if @viewport_weather_ex == nil 
      @viewport_weather_ex.ox = ($game_map.display_x * 32)
      @viewport_weather_ex.oy = ($game_map.display_y * 32)
  end
 
 #--------------------------------------------------------------------------
 # ● Refresh Weather EX
 #--------------------------------------------------------------------------                     
  def refresh_weather_ex
      return if @old_weather == nil
      return if @old_weather == $game_system.weather
      dispose_refresh
      create_weather_sprite
  end  
end  

#==============================================================================
# ■ Spriteset Map
#==============================================================================
class Spriteset_Map 
   include Module_Weather_EX  
   
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------                   
  alias mog_weather_ex_initialize initialize 
  def initialize          
      dispose_weather_ex    
      mog_weather_ex_initialize
      create_weather_ex
  end

 #--------------------------------------------------------------------------
 # ● Dispose
 #--------------------------------------------------------------------------                   
  alias mog_weather_ex_dispose dispose
  def dispose
      dispose_weather_ex    
      mog_weather_ex_dispose
  end  

 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------                   
  alias mog_weather_ex_update update
  def update
      mog_weather_ex_update
      update_weather_ex
  end  
    
end



if MOG_WEATHER_EX::WEATHER_BATTLE 
#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Spriteset_Battle  
  
   include Module_Weather_EX  
   
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------                   
  alias mog_weather_ex_initialize initialize 
  def initialize          
      dispose_weather_ex    
      mog_weather_ex_initialize
      create_weather_ex
  end

 #--------------------------------------------------------------------------
 # ● Dispose
 #--------------------------------------------------------------------------                   
  alias mog_weather_ex_dispose dispose
  def dispose
      dispose_weather_ex    
      mog_weather_ex_dispose
  end  

 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------                   
  alias mog_weather_ex_update update
  def update
      mog_weather_ex_update
      update_weather_ex
  end   
    
end

end

#=============================================================================
# ■ Scene Base
#=============================================================================
class Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Weather Recover Data
  #--------------------------------------------------------------------------  
  def weather_recover_data
      if $game_system.weather == nil or $game_system.weather_temp == nil or $game_system.weather_restore == nil or $game_system.weather_record_set == nil
         $game_system.weather = [-1,0,""] 
         $game_system.weather_temp = [-1,0,""] 
         $game_system.weather_restore = [-1,0,""] 
         $game_system.weather_record_set = [-1,0,""] 
      end
      if $game_system.weather.empty? or 
          $game_system.weather[0] == -1 
          if !$game_system.weather_restore.empty? and 
             $game_system.weather_restore[0] != -1
             v = $game_system.weather_restore
             $game_system.weather = [v[0],v[1],v[2]]
          end
      end         
  end
  
  #--------------------------------------------------------------------------
  # ● Weather Restore
  #--------------------------------------------------------------------------       
  def weather_recover_scene
      return if $game_system.weather_temp.empty?
      return if $game_system.weather_temp[0] == -1
      w = $game_system.weather_temp
      $game_system.weather = [w[0],w[1],w[2]]
      $game_system.weather_temp.clear
      $game_system.weather_temp = [-1,0,""]
  end  
 
  #--------------------------------------------------------------------------
  # ● Main
  #--------------------------------------------------------------------------         
  alias mog_weather_ex_main main
  def main
      dispose_weather_ex_base
      weather_recover_scene if can_recover_weather_scene?
      mog_weather_ex_main
  end    
  
  #--------------------------------------------------------------------------
  # ● Can Recover Weather Scene
  #--------------------------------------------------------------------------         
  def can_recover_weather_scene?
      return true if SceneManager.scene_is?(Scene_Map)
      return true if SceneManager.scene_is?(Scene_Battle)
      return false
  end  
  
  #--------------------------------------------------------------------------
  # ● terminate
  #--------------------------------------------------------------------------         
  alias mog_weather_ex_terminate_base terminate
  def terminate
      mog_weather_ex_terminate_base
      dispose_weather_ex_base      
  end  

  #--------------------------------------------------------------------------
  # ● Dispose Weather EX Base
  #--------------------------------------------------------------------------           
  def dispose_weather_ex_base
      return if @spriteset == nil
      @spriteset.dispose_weather_ex rescue nil
  end        
  
end

#=============================================================================
# ■ Scene Load
#=============================================================================
class Scene_Load < Scene_File
  
  #--------------------------------------------------------------------------
  # ● On Load Success
  #--------------------------------------------------------------------------
  alias mog_weather_ex_on_load_success on_load_success
  def on_load_success
      mog_weather_ex_on_load_success
      weather_recover_data
  end
end

#=============================================================================
# ■ Scene Manager
#=============================================================================
class << SceneManager
  
  #--------------------------------------------------------------------------
  # ● Call
  #--------------------------------------------------------------------------         
  alias mog_weather_ex_call call
  def call(scene_class)
      weather_dispose
      mog_weather_ex_call(scene_class)
  end
  
  #--------------------------------------------------------------------------
  # ● Weather Restore
  #--------------------------------------------------------------------------       
  def weather_dispose
      return if $game_system.weather.empty?
      return if $game_system.weather[0] == -1
      w = $game_system.weather
      $game_system.weather_temp = [w[0],w[1],w[2]]
      $game_system.weather.clear
      $game_system.weather = [-1,0,""]
  end
    
  
end
$mog_rgss3_weather_ex = true




#******************************************************************************
#
#    ＊ PNG 保存
#
#  --------------------------------------------------------------------------
#    バージョン ：  1.0.0
#    対      応 ：  RPGツクールVX Ace : RGSS3
#    制  作  者 ：  ＣＡＣＡＯ
#    配  布  元 ：  [url]http://cacaosoft.web.fc2.com/[/url]
#  --------------------------------------------------------------------------
#   == 概    要 ==
#
#    ： ピングファイルの出力機能を追加します。
#
#  --------------------------------------------------------------------------
#   == 使用方法 ==
#
#    ★ Bitmap#save_png(filename, alpha = false)
#     このビットマップをピングファイルで出力
#     filename : 保存するファイル名
#     alpha    : αチャンネルの有無
#
#
#******************************************************************************
 
 
#/////////////////////////////////////////////////////////////////////////////#
#                                                                             #
#                  このスクリプトに設定項目はありません。                     #
#                                                                             #
#/////////////////////////////////////////////////////////////////////////////#
 
 
class Bitmap
  #--------------------------------------------------------------------------
  # ● ピング画像として保存
  #     filename : ファイル名
  #     alpha    : アルファチャンネルの有無
  #--------------------------------------------------------------------------
  def save_png(filename, alpha = false)
   # width = 1280 
    #height = 704
    sgnt = "\x89PNG\r\n\x1a\n"
    ihdr = _chunk('IHDR', [width,height,8,(alpha ? 6 : 2),0,0,0].pack('N2C5'))
    data = []
    height.times do |y|
      data << 0
      width.times do |x|
        color = self.get_pixel(x, y)
        data << color.red << color.green << color.blue
        data << color.alpha if alpha
      end
    end
    idat = _chunk('IDAT', Zlib::Deflate.deflate(data.pack('C*')))
    iend = _chunk('IEND', "")
    File.open(filename, 'wb') do |file|
      file.write(sgnt)
      file.write(ihdr)
      file.write(idat)
      file.write(iend)
    end
  end
private
  #--------------------------------------------------------------------------
  # ● チャンクの作成
  #     name : チャンク名
  #     data : チャンクデータ
  #--------------------------------------------------------------------------
  def _chunk(name, data)
    return [data.size, name, data, Zlib.crc32(name + data)].pack('NA4A*N')
  end
end
 
 
#******************************************************************************
#
#    ＊ マップ画像の保存
#
#  --------------------------------------------------------------------------
#    バージョン ：  1.0.0
#    対      応 ：  RPGツクールVX Ace : RGSS3
#    制  作  者 ：  ＣＡＣＡＯ
#    配  布  元 ：  [url]http://cacaosoft.web.fc2.com/[/url]
#  --------------------------------------------------------------------------
#   == 概    要 ==
#
#    ： マップを１枚の画像にして保存します。
#
#  --------------------------------------------------------------------------
#   == 注意事項 ==
#
#    ※ 画像保存に『PNG 保存』スクリプトが必要になります。
#    ※ ゲーム配布時には、削除してください。
#    ※ 撮影時にプレイヤーは非表示になります。
#
#  --------------------------------------------------------------------------
#   == 使用方法 ==
#
#    ★ マップ画像を保存する
#     マップ画面で F7 キーを押してください。
#     右下まで移動すると停止しますが、画像を保存しています。
#     画面が元に戻るまで、しばらくお持ちください。
#     画像は、ゲームフォルダに保存されます。
#
#    ※ キーを変更するには、:F7 で検索してください。
#       １箇所のみ引っかかるので、そこを変更してください。
#
#
#******************************************************************************
 
 
#/////////////////////////////////////////////////////////////////////////////#
#                                                                             #
#                下記のスクリプトを変更する必要はありません。                 #
#                                                                             #
#/////////////////////////////////////////////////////////////////////////////#
 
 
class Sprite_Character < Sprite_Base_Ad
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update_snap
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z
    self.visible = !@character.transparent
 
    if @balloon_duration > 0
      @balloon_sprite.x = x
      @balloon_sprite.y = y - height
      @balloon_sprite.z = z + 200
    end
  end
end
 
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def update_snap
    @tilemap.ox = $game_map.display_x * 32
    @tilemap.oy = $game_map.display_y * 32
 
    @parallax.ox = $game_map.parallax_ox(@parallax.bitmap)
    @parallax.oy = $game_map.parallax_oy(@parallax.bitmap)
 
    @character_sprites.each {|sprite| sprite.update_snap }
 
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
 
    Graphics.update
  end
end
 
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias _cao_mapshot_update update
  def update
    _cao_mapshot_update
    #map_shop   if Input.press?(:F5) && $TEST
    #map_screen  if Input.press?(:F5) && $TEST  
  end

  def map_screen
    bitmap = Graphics.snap_to_bitmap
    bitmap.save_png("snap/screen"+"#{rand(10000)}"+".png")
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def map_shop
    # プレイヤーを非表示
    last_player_transparent = $game_player.transparent
    $game_player.transparent = true
    # マップの撮影
    bitmap = Bitmap.new($game_map.width * 32, $game_map.height * 32)
    screen_width = $game_map.screen_tile_x
    screen_height = $game_map.screen_tile_y

    v = SceneManager.scene.instance_variable_get("@map_status_window")
    v.visible = false
    v.hide_sprites
    

    ($game_map.width / screen_width.to_f).ceil.times do |x|
      ($game_map.height / screen_height.to_f).ceil.times do |y|

        $game_map.set_display_pos(screen_width * x, screen_height * y)
        @spriteset.update
        Graphics.update

        dx = $game_map.display_x * 32
        dy = $game_map.display_y * 32

        snap = Graphics.snap_to_bitmap
        bitmap.blt(dx, dy, snap, snap.rect)
      end
    end

    # マップ画像の保存
    Graphics.update
    filename = sprintf('ground%03d-1.png', $game_map.map_id,$game_map.display_name)
    bitmap.save_png("snap/"+filename)
    puts "`#{filename}' 保存完了！"
    # プレイヤーの状態を戻す
    $game_player.transparent = last_player_transparent
    $game_player.center($game_player.x, $game_player.y)
    $game_player.update

    v = SceneManager.scene.instance_variable_get("@map_status_window")
    v.visible = true
    v.refresh
    v.show_sprites
  end
end