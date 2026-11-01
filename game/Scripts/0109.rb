#encoding:utf-8

#==============================================================================
# ■ Window_Minimap
#------------------------------------------------------------------------------
# 　小地图窗口
#
#   @minimap = Window_Minimap.create
#   @minimap.update
#   @minimap.dispose
#
#==============================================================================

class Window_Minimap

  include DisableableObject

  # attr_accessor :point
  # attr_accessor :map_id
  attr_reader :opened


  # 地图ID => 初始坐标 , MAP_ID => [x,y]
  MAPID_CFG = {
    99 => [264,94],
    100 => [479,194],
    857 => [518,267],
    57 => [395,177],
    58 => [478,192],
    59 => [495,179],
    60 => [462,229],
    61 => [248,12],
    899 => [471,179],
    862=> [421,36],
    879=> [303,109],
    918=> [426,202],
    77=> [329,18],
    78=> [444,121],
    79=> [487,65],
    80=> [474,189],
    81=> [393,170],
    329=> [292,70],
    384=> [352,95],
    385=> [265,92],
    333=> [393,105],
    335=> [372,153],
    337=> [395,0],
    342=> [233,150],
    347=> [515,61],
    350=> [347,30],
    355=> [417,64],
    359=> [414,154],
    361=> [495,216],
    362=> [401,13],
    36=>  [515,59],
    365=> [558,212],
    914=> [318,256],
    915=> [324,257],
    415=> [278,100],
    416=> [252,119],
    417=> [252,97],
    418=> [374,-25],
    419=> [228,201],
    420=> [595,275],
    421=>  [305,66],
    422=>  [291,46],
    423 => [255,64]
  }

  # 照亮半径
  POINT_RADIUS = 20

  # 地图全开开关 地图ID => 开关编号
  FULL_OPEN_CONDITIONS = {
    99 => 1,
    100 => 1,
    857 => 1,
    57 => 1,
    58 => 1,
    59 => 1,
    60 => 1,
    61 => 1,
    899 => 1,
    862=> 1,
    879=> 1,
    918=> 1,
    77=> 1,
    78=> 1,
    79=> 1,
    80=> 1,
    81=> 1,
    329=> 1,
    384=> 1,
    385=> 1,
    333=> 1,
    335=> 1,
    337=> 1,
    342=> 1,
    347=> 1,
    350=> 1,
    355=> 1,
    359=> 1,
    361=> 1,
    362=> 1,
    36=>  1,
    365=> 1,
    914=> 1,
    915=> 1,
    415=> 1,
    416=> 1,
    417=> 1,
    418=> 1,
    419=> 1,
    420=> 1,
    421=> 1,
    422=> 1,
    423 => 1  
  }

  # POINT_BITMAP_FILENAME = "Graphics/system/minimap_point"
  MAP_BITMAP_DIR        = "Graphics/minimap"
  MAP_INFO_BITMAP_DIR   = MAP_BITMAP_DIR + "/info"
  MAP_SCALE_RATE        = 0.2
  MAP_GRID_SIZE         = (32 * MAP_SCALE_RATE).to_i
  MAP_GRID_SIZE_F       = (32 * MAP_SCALE_RATE).to_f

  MAP_BITMAP_LOGO_FILENAME          =  MAP_INFO_BITMAP_DIR + "/minimap_logo"
  MAP_BITMAP_FACE_FILENAME          =  MAP_INFO_BITMAP_DIR + "/mini_face"
  MAP_BITMAP_FACE_SHINE_FILENAME    =  MAP_INFO_BITMAP_DIR + "/mini_face_shine"
  MAP_BITMAP_MAP_SHINE_FILENAME     =  MAP_INFO_BITMAP_DIR + "/minimap_shine"

  SHINE_COUNT_ADD_PRE_FRAME_COUNT   = 5

  def initialize(map_id,cfg)
    @viewport = Viewport.new(0,0,1280,704)
    @viewport.z = 49

    @map_id = map_id

    @start_x = cfg[0]
    @start_y = cfg[1]

    @sprite_map_back = Sprite.new(@viewport)
    @sprite_map_back.bitmap = Cache.picture("00")
    @sprite_map_back.opacity = 200
    @sprite_map_back.visible = false

    @sprite_map_cache = Bitmap.new(map_name)

    @sprite_map = Sprite.new(@viewport)
    # @sprite_map.bitmap = @sprite_map_cache.clone
    @sprite_map.x = -50
    @sprite_map.y = 0
    @sprite_map.opacity = 0
    @sprite_map.z = 190
    @sprite_map.visible = false

    @logo = Sprite.new(@viewport)
    @logo.bitmap = Bitmap.new(MAP_BITMAP_LOGO_FILENAME)
    @logo.x = 0
    @logo.z = 0
    @logo.z = 195
    @logo.visible = false

    @point = Sprite.new(@viewport)
    @point.bitmap = Bitmap.new(MAP_BITMAP_FACE_FILENAME)
    @point.z = 191
    @point.visible = false

    @face_shine = Sprite.new(@viewport)
    @face_shine.bitmap = Bitmap.new(MAP_BITMAP_FACE_SHINE_FILENAME)
    @face_shine.z = 193
    @face_shine.visible = false

    @map_shine = Sprite.new(@viewport)
    @map_shine.bitmap = Bitmap.new(MAP_BITMAP_MAP_SHINE_FILENAME)
    # @map_shine.x = @logo.x + @logo.bitmap.width / 2
    @map_shine.x = -1
    # @map_shine.y = @logo.y + @logo.bitmap.height / 2
    @map_shine.y = 0
    @map_shine.z = 196
    @map_shine.visible = false

    @position = Sprite.new(@viewport)
    @position.bitmap = Bitmap.new(125,32)
    @position.z = 194
    @position.visible = false

    @share_count = 0
    @share_dir = :down

    # @opened = false
    # $game_temp.minimap_opened
    self.visible = false
    # self.visible = $game_temp.minimap_opened
  end

  def map_name
    MAP_BITMAP_DIR + "/" + format("mini_%s",@map_id)
  end

  def full_opened?
    return true
    open_switch_num = FULL_OPEN_CONDITIONS[@map_id]
    open_switch_num && $game_switches[open_switch_num]
  end

  def visible=(bool)
    @sprite_map.visible = bool
    @sprite_map_back.visible = bool
    @logo.visible = bool
    @point.visible = bool
    @face_shine.visible = bool
    @map_shine.visible = bool
    @position.visible = bool

    # $game_temp.minimap_opened = bool
    @opened = bool

    # 提前更新一次
    if bool
      update_point
      refresh_grid
    end

  end

  def refresh_grid

    if @sprite_map.bitmap
      @sprite_map.bitmap.clear
    end
    @sprite_map.bitmap = @sprite_map_cache.clone

    return if full_opened?
    return unless $game_system.minimap_grids


    minimap_girds = $game_system.minimap_grids[@map_id]
    min_x, min_y = *minimap_girds.first.split(",")
    min_x = min_x.to_i
    min_y = min_y.to_i
    max_x, max_y = min_x, min_y
    minimap_girds.each do |grid_str|
      _arr = grid_str.split(",")
      _x = _arr.first.to_i
      _y = _arr.last.to_i

      min_x = _x if _x < min_x
      max_x = _x if _x > max_x
      min_y = _y if _y < min_y
      max_y = _y if _y > max_y
    end

    min_x = [min_x,0].max
    min_y = [min_y,0].max
    max_x = [max_x, $game_map.width].min
    max_y = [max_x, $game_map.height].min

    @sprite_map.bitmap.clear_rect(0,0,min_x,704)
    @sprite_map.bitmap.clear_rect(0,0,1280,min_y)
    max_x_of_map = max_x * MAP_GRID_SIZE
    max_y_of_map = max_y * MAP_GRID_SIZE
    @sprite_map.bitmap.clear_rect(@start_x + max_x_of_map, 0, 1280 - @start_x - max_x_of_map, 704 )
    @sprite_map.bitmap.clear_rect(0, @start_y + max_y_of_map, 1280, 704 - @start_y - max_y_of_map)

    _count = 0
    for x in min_x .. max_x
      for y in min_y .. max_y
        unless minimap_girds.include?(format(format("%s,%s",x,y)))
          @sprite_map.bitmap.clear_rect(@start_x + x * MAP_GRID_SIZE, @start_y + y * MAP_GRID_SIZE,MAP_GRID_SIZE,MAP_GRID_SIZE)
          _count += 1
        end
      end
    end
  end

  # def z=(value)
  #   @viewport.z = value
  # end

  def dispose
    _dispose
  end

  # 无需手动释放
  # def dispose
  #   @sprite_map.dispose
  #   @sprite_map.bitmap.dispose if @sprite_map.bitmap

  #   @sprite_map_back.bitmap.dispose
  #   @sprite_map_back.dispose

  #   @point.bitmap.dispose
  #   @point.dispose

  #   @logo.bitmap.dispose
  #   @logo.dispose

  #   @face_shine.bitmap.dispose
  #   @face_shine.dispose

  #   @map_shine.bitmap.dispose
  #   @map_shine.dispose

  #   @position.bitmap.dispose
  #   @position.dispose

  #   @sprite_map_cache.dispose

  #   @viewport.dispose
  # end

  def check

  end

  def toggle_display
    self.visible = !@opened
    # self.visible = !$game_temp.minimap_opened
  end

  def update
    if $game_map.interpreter.running? && @opened
      self.visible = false
      return
    end
    if !$game_message.busy? and !$game_map.interpreter.running?
      if Keys.trigger?(Keys::M) or Keys.trigger?(Keys::TAB) or ($game_switches[742] == true and (Input.trigger?(:R) or Input.trigger?(:L)) )
        @sprite_map.x = -50
        @sprite_map.y = 0
        @sprite_map.opacity = 0
        if @position.visible == false
          Audio.se_play("Audio/SE/Cursor2",100)
          Audio.se_play("Audio/SE/book2",100,80)
          $game_switches[1] = false
          SceneManager.scene.show_status
        else
          Sound.play_cancel
        end
        toggle_display
      end
    end
    if @opened
      update_shine
      update_point
    end
  end

  def update_point
    _palyer_x = player_x
    _palyer_y = player_y
    _point_x  = point_x
    _point_y  = point_y

    if _palyer_x != _point_x
      move_y _palyer_y * MAP_GRID_SIZE_F
    end

    if  _palyer_y != _point_y
      move_x _palyer_x * MAP_GRID_SIZE_F
    end
  end

  def update_shine
    if @sprite_map.x < 0
      @sprite_map.x += 5
      @sprite_map.opacity += 26
    end

    case @share_dir
    when :down
      @map_shine.opacity -= SHINE_COUNT_ADD_PRE_FRAME_COUNT
      @face_shine.opacity -= SHINE_COUNT_ADD_PRE_FRAME_COUNT
      if @face_shine.opacity <= 0
        @share_dir = :up
      end
    when :up
      @map_shine.opacity += SHINE_COUNT_ADD_PRE_FRAME_COUNT
      @face_shine.opacity += SHINE_COUNT_ADD_PRE_FRAME_COUNT
      if @face_shine.opacity >= 255
        @share_dir = :down
      end
    end

    @face_shine.x = @point.x
    @face_shine.y = @point.y
  end

  def refresh_position
    @position.bitmap.clear
    @position.bitmap.font.size = 13 + $game_variables[300]
    x = @point.x + 32
    y = @point.y + 36
    w = @position.bitmap.width
    h = @position.bitmap.height

    str = format("X %s Y %s",player_x.to_s,player_y.to_s)
    @position.x = x-30
    @position.y = y+9
    @position.bitmap.font.size = 16 + $game_variables[300]
    #@position.bitmap.draw_text(0,0,w,h,str,1)
  end

  def player_position
    return $game_player.x, $game_player.y
  end

  def point_x
    return ((@point.x - @start_x) / MAP_GRID_SIZE).to_i
  end

  def point_y
    return ((@point.y - @start_y) / MAP_GRID_SIZE).to_i
  end

  def player_x
    player_position[0]
  end

  def player_y
    player_position[1]
  end

  def move_x(x)
    @point.x = @start_x + x - @point.bitmap.width / 2 + fixed_x
    refresh_position
  end

  def move_y(y)
    @point.y = @start_y + y - @point.bitmap.height / 2 + fixed_y
    refresh_position
  end

  # 由于格子为 32 / 缩放率 不是整数导致偏差，需修正坐标
  def fixed_x
    return 6
  end

  def fixed_y
    return 3
  end

  # Todo: not supported
  def scroll_x

  end

  # Todo: not supported
  def scroll_y

  end

  class << self

    def map_ids
      MAPID_CFG.keys
    end

    def map_cfg(map_id)
      MAPID_CFG[map_id]
    end

    def can_initialize?
      scene = SceneManager.scene
      scene.is_a?(Scene_Map) && map_ids.include?($game_map.map_id)
    end

    def create
      if self.can_initialize?
        map_id = $game_map.map_id
        map_cfg = self.map_cfg(map_id)
        new(map_id,map_cfg) 
      end
    end
  end
end
