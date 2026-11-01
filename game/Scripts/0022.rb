#encoding:utf-8

class RPG::BaseItem
  def name
    @name.split("|").first
  end
  def color
    arr = @name.split("|")
    if arr.size > 1
      return case arr.last
      when "c1"; Color.new(138,215,108)
      when "c2"; Color.new(40,180,245)
      when "c3"; Color.new(155,120,255)
      when "c4"; Color.new(255,202,39)
      else
        nil
      end
    else
      nil
    end
  end
end

class RPG::UsableItem < RPG::BaseItem
  # 是否攻击性计策
  def is_hp_damage_marv?
     #@damage.type == 1
    @stype_id == 1 and ((@damage.element_id >= 1 and @damage.element_id <= 4) or (@damage.element_id == 7)) or [177,188,113,117].include? self.id
  end

  # 是否回复性计策
  def is_hp_recover_marv?
    @damage.element_id == 5
  end

  # 是否火系计策
  def is_fire_marv?
    @damage.element_id == 1
  end

  # 是否水系计策
  def is_water_marv?
    @damage.element_id == 2
  end

  # 是否石系计策
  def is_wood_marv?
    @damage.element_id == 3
  end

  # 是否风系计策
  def is_wind_marv?
    @damage.element_id == 4
  end
end

class RPG::Item < RPG::UsableItem
  CAN_TOGGLE_ALL = []
  FORGE_REQUIREMENT_START_ID = 35   # => 锻造材料起始ID
  def is_atk?;        false ;    end
  def is_marv? ;      false ;    end
  def is_skill? ;     false ;    end
  def is_formation? ; false ;    end
  def is_item?;       true  ;    end
  def can_all?
    CAN_TOGGLE_ALL.include? @id
  end
end


class RPG::Skill < RPG::UsableItem
  CAN_TOGGLE_ALL = [60,62,64,66,68,86,88,90,92,94,103,105,107,109,111,118,120,122,124,126,150,152,154,156,158]
  PARTY_SKILL_IDS = [39,178,179,183,184,185,187,189,192,193,194,195,196,197,198,199,206,208,211,214,215]

  # 可被解策计 解除的计策 ： 减策 血路 伪退 嘲骂 
  CAN_JIECE_IDS = [138,184,185,195,196,197,180,189,206]

  DEFAULT_FORMATION_ID = 4
  DEFAULT_FORMATION_ID = 4

  def can_all?
    CAN_TOGGLE_ALL.include? @id
  end

  # before_fiter :check_formation,:only=>[:pos,:atk]
	def is_marv? ; 		  @stype_id == 1 ;  	end
	def is_skill? ;  	  @stype_id == 2 ;  	end
	def is_formation? ;	@stype_id == 3 && @note[0,2] == "FC" ; 	end
  def is_item? ; false; end
  def is_bskill? ;    @stype_id == 4; end
  def is_atk? ;       @id == 1 ; end
  def is_def? ;       @id == 2 ; end
  def is_jm? ;        @stype_id == 5 ; end

  def physical?
    is_atk? or self.hit_type == 1
  end

  def magical?
    is_marv?
  end

  # 是否为散布类计策 疑心 离间 离反
  def is_sow_marv?
      [180,181,182].include? self.id
  end

  #是否策免，策反状态下，可以继续叠加的计策。
  def is_buff_marv?
    [34,179,183,186,190,192,193,199,200,201,202,203,204,205,207,209,210,212,213,214,225,229,231].include? self.id
  end

  #是否保护性策略，用于电脑AI判断的
  def is_defend_marv?
    [183,202,203,204,205,210,213].include? self.id
  end

  def wave_filename
    if $game_switches[486] == true
    begin
      c = "0"
      if is_formation?
        c = eval(@note.split("\r\n")[12])[:wave]
      elsif is_skill?
        c = eval(@note.split("\r\n")[0])[:wave]
      end
      return "skill_b_#{c}"
    rescue
      return "skill_b_1"
    end
  end
  end

  def wave_filename_num
    begin
      c = "0"
      if is_formation?
        c = eval(@note.split("\r\n")[12])[:wave]
      elsif is_skill?
        c = eval(@note.split("\r\n")[0])[:wave]
      end
      return c
    rescue
      return 0
    end
  end

  def get_note line
    if is_formation?
      @note.split("\r\n")[line].split(" = ").last.split(" ").map{|n|n.to_i}
    end
  end

  def get_note_8910 line
    if is_formation?
      @note.split("\r\n")[line].split(" = ").last.split(" ").map{|n|(n.to_i)*0.01}
    end
  end


  def hh
    if is_formation?
      @note.split("\r\n")[11].split(" = ").last.to_i
    end
  end

  def pos
    if is_formation?
      @note.split("\r\n")[1].split(" = ").last.split("").map(&:to_i)
    end
  end

  def pos_start
      @note.split("\r\n")[1].split(" = ").last.split("").map(&:to_i)
  end
  def atk ; get_note 2 ; end
  def def ; get_note 3 ; end
  def str ; get_note 4 ; end
  def dex ; get_note 5 ; end
  def int ; get_note 6 ; end
  def agi ; get_note 7 ; end
  def hit ; get_note_8910 8 ; end
  def eva ; get_note_8910 9 ; end
  def cri ; get_note_8910 10 ; end

  private
  def check_formation

  end
end
class RPG::EquipItem < RPG::BaseItem
  def initialize
    super
    @price = 0
    @etype_id = 0
    @params = [0] * 8
  end

  def mhp;  @params[0];   end    # 最大HP          Maximum Hit Point
  def mmp;  @params[1];   end    # 最大MP          Maximum Magic Point
  def str;  @params[2];   end    # 力量            ATtacK power
  def ski;  @params[3];   end    # 技力            DEFense power
  def int;  @params[4];   end    # 智力            Magic ATtack power
  def def;  @params[5];   end    # 魔法防御        Magic DeFense power
  def agi;  @params[6];   end    # 敏 捷 值        AGIlity
  def atk;  @params[7];   end    # 幸 运 值        LUcK

  attr_accessor :price
  attr_accessor :etype_id
  attr_accessor :params

  def can_forge?
    @note[0,2] == "#D"
  end

  # 锻造所需材料 [{id: 锻造物品id, num: 数量 }, {..}, {...}]
  def forge_requirement
    start_id = RPG::Item::FORGE_REQUIREMENT_START_ID
    #hash = {:equipment => self, :price => (@price / 2).to_i}
    #锻造价格
    hash = {:equipment => self, :price => (@price * 0).to_i}
    if self.can_forge?
      hash[:requirement] = @note.split("\r\n")[1].split(" ").map do |str|
        _arr = str.split("x")
        id  = _arr[0].to_i - 1 + start_id
        num = _arr[1].to_i
        { item_id: id, num: num }
      end
    end
    hash
  end


end

class RPG::Animation
  # 已经弃用
  ACTOR_ATK_ID = 10        # ACTOR 普通攻击 ID
  ENEMY_ATK_ID = 30        # ENEMY 普通攻击 ID
  ACTOR_ATK_HIT_ID = 11    # ACTOR 普通攻击HIT ID
  ENEMY_ATK_HIT_ID = 31    # ENEMY 普通攻击HIT ID

  ACTOR_ATK_MISS_ID = 12   # ACTOR 普通攻击MISS ID
  ENEMY_ATK_MISS_ID = 32   # ENEMY 普通攻击MISS ID
  GUARD_ID = 6             # 防御 ID
  USE_ITEM_ID = 5          # 使用道具ID
  ACTOR_USE_SKILL_ID = 3   # ACTOR 使用技能ID
  ENEMY_USE_SKILL_ID = 4   # ENEMY 使用技能ID
  ACTOR_USE_MARV_ID = 8    # ACTOR 使用计策ID
  ENEMY_USE_MARV_ID = 9    # ENEMY 使用计策ID
  USE_FORMATION_ID = 7     # 使用阵型ID
  DEAD_ID = 1              # 死亡ID
  ALIVE_ID = 2             # 复活ID
  FORMATION_OBJECT_ID = 51 # 阵型对象ID 开始时的编号 一共5个
  ACTOR_MISS_ID = 100      # 我方MISS动画
  ENEMY_MISS_ID = 101      # 敌方MISS动画
  ALL_ATK_ID = 58          # 总攻伤害动画
  VICTORY_ID = 102         # 胜利姿势动画

  # 攻击动画数组
  ATK_IDS = [10,14,18,30,34,38]
  ATK_TARGET_IDS = [11,15,19,31,35,39]
  def is_atk_ids?
    ATK_IDS.include? @id
  end

  def is_atk_target_ids?
    ATK_TARGET_IDS.include? @id
  end
end

class RPG::Animation::Timing
  def is_damage?
    [1,248].include?(@flash_color.alpha) && [1,2].include?(@flash_scope) 
  end
  def is_cure?
    [2,249].include?(@flash_color.alpha) && [1,2].include?(@flash_scope) 
  end
end

class RPG::State
  # 是否为散布类状态 疑心 离间 离反
  def is_sow?
    [27,28,29].include? self.id
  end
end

class RPG::Weapon < RPG::EquipItem
  def is_bow?
    @wtype_id == 5
  end
end
