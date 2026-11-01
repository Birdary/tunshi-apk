#encoding:utf-8
module DataExt
  module_function
  @@data = {}
  def create(mod,params)
    if mod.respond_to? :create
      o = mod.create params
      @@data[o.id] = o if o
      save(mod) if params[:save] == true
    end
  end
  def save(mod)
    if !@@data.empty?
      file = File.open("Ext/#{mod.to_s.sub("::","_")}.ext", "wb")
      Marshal.dump @@data,file
      file.close
    end
  end
  def load(file)
    Marshal.load file
  end
end

module SkGraph
  @@point = Config::DEFAULT_GRAPH_POINT 
  @@items = {}
  @@data = nil
  module_function

  def initialize_point!
    @@point = Config::DEFAULT_GRAPH_POINT
  end

  def create!
    File.open("Ext/SkGraph_Item.ext","rb") do |f|
      @@data = Marshal.load f
      self.data.values.each do |o|
        items[o.id] = 0  # id => level
      end
    end
  end
  def clear_all!
    @@point = @@items.values.inject{|a,b|a+b}
    @@items.each do |k,v|
      @@items[k] = 0
    end
  end
  def find_all_points_by_type(type)
    ids = case type
      when 1
        [1,2,3,4,5,6]
      when 2
        [10,11,12,13,14,15]
      when 3
        [20,21,22,23,24,25]
      when 4
        [30,31,32,33,34,35]
    end
    ids.map{|id| items[id] }.inject{|a,b|a+b}
  end

  def can_learn? id
    def can?
      return items[id] < data[id].max_level && point > 0 && check_condi(id)
    end
  end

  def check_condi id
    true
    # @condi || true # 临时用
  end

  def import(arr)
    @@data = Marshal.load File.open("Ext/SkGraph_Item.ext","rb")
    self.point = arr.last
    @@items = arr.first
  end

  def dump
    [items,point]
  end

  def used_point ; Config::DEFAULT_GRAPH_POINT - @@point ; end
  def data    ; @@data ; end
  def items   ; @@items  ; end
  def point ; @@point ; end
  def point=(n)
    @@point = n
  end
  def method_mission(name,para)
    if name =~ /^find_by_(.*)$/
      items = []
      condi = {:name=>para}
      key = $1 ; value = para
      items.each do |item|
        items << item if item.send(key) == value
      end
      return items.size == 1 ? items.first : items
    else
      super
    end
  end

  class Item
    def initialize
      @id = ""
      @name = ""
      @condi = nil
      @effects = nil # Effect 对象id集合
      @type = 0 # 1 力 2 技 3 策 4 速
      @pos = [] # [x,y]
      @icon = ""
      @max_level = 0
      @stru = {} # 结构 :left => id , :right => id , :up => id, :down => id
      @desc = "" # 描述
      @learn_text = "" # 习得条件文本
    end
    def add_effect ; @effects ; end
    def learn 
      @learn = true
      add_effect 
    end
    class << self
      def create(option={})
        obj = new
        obj.attrset(option)
        obj.condi = Conditions.new.attrset(option[:con]) if option[:con]
        if option[:effect]
          obj.effects = Effect.new(option[:effect])
          #obj.effects = Effect.new.attrset(option[:effect])
          #obj.effects.set_tag option[:effect].keys
        end
        obj
      end
    end
    attr_accessor :id,:name,:pos,:icon,:max_level,:condi,:effects,:type,:stru,:desc,:learn_text
  end

  class Conditions
    def initialize
      @point_requ = 0
      @level_requ = 0
      @item_requ = {} # :type => [type,point],:name => [name,point]
      @ability_requ = {} # str=>0,:ski=>0,:int=>0,:agi=>0
    end
    attr_accessor :point_requ
    attr_accessor :level_requ
    attr_accessor :item_requ
    attr_accessor :ability_requ
  end

  class Effect
    attr_accessor :data
    def initialize(option)
      @data = option
      # @str = []
      # @int = []
      # @agi = []
      # @ski = []
      # @atk = []
      # @def = []
      # @hp = []
      # @eva = []
      # @atk_hp = []          # 全队普通攻击的兵力加成提升
      # @damage_tp = []       # 每次攻击或受到攻击增加的怒气
      # @atk_damage_rate = [] # 全队普攻伤害提升
      # @ski_damage = []         # 技能伤害百分比
      # @item_effect_during = [] # 使用会心丹等物品时持续时间增加一回合
      # @atk_critical_rate = []  # 全队会心几率上升
      # @atk_critical_damage = [] # 全队会心一击伤害提升+10%
      # @marv_damage = []         # 全队策略威力上升    
      # @marv_use_sp_minus = []   # 全队使用策略消耗策略点减少
      # @boost = []          # 每次增加或减少的士气 
      # @start_boost = []    # 战斗初始士气提升
      # @marv_succ_rate = [] # 全队策略成功率提升

      # @ski_speed = []           # 全队技能补正速度上升
      # @marv_speed = []          # 全队策略补正速度上升
      # @map_walking_speed = []   # 地图行走速度提升
      # @agi_rate = []            # 全队速属性上升1

      # @atk_hit = []         # 全队普攻命中率上升
      # @ski_hit = []         # 全队技能命中率上升

      # @field = false     # 是否为野战

      # @tags = []
    end

    def data
      @data
    end

    # def set_tag t
    #   @tags = t
    # end

    # def tags;  @tags; end

    def method_mission(name,para)
      if name =~ /^get_(.*)$/
        level = para
        send($1.to_sym)[level-1]
      else
        super
      end
    end
  end
end

class BattleExt
  attr_accessor :str,:int,:agi,:ski,:atk,:def,:hp,:eva,:atk_hp,:damage_tp,:atk_damage_rate,:ski_damage
  attr_accessor :item_effect_during,:atk_critical_rate,:atk_critical_damage,:marv_damage,:marv_use_sp_minus,:boost,:start_boost,:marv_succ_rate
  attr_accessor :ski_speed,:marv_speed,:map_walking_speed,:agi_rate,:atk_hit,:ski_hit,:field_atk,:field_def

  def initialize
    # [值,百分比值]
    @atk = [0,0]                      # 攻击力上升
    @def = [0,0]                      # 防御力上上
    @str = [0,0]                      # 武力上升
    @int = [0,0]                      # 智力上升
    @hp = [0,0]                       # 兵力上升

    @field_atk = [0,0]                # 杂兵战攻击力上升
    @field_def = [0,0]                # 杂兵战防御力上升

    @ski_damage = [0,0]               # 技能傷害上升
    @atk_hp = [0,0]                   # 攻击时兵力上升
    @damage_tp = [0,0]                # 受到攻击时怒气(TP)增加
    @atk_damage_rate = [0,0]          # 全队普攻伤害提升(百分比)

    @ski = [0,0]                      # 技力上升
    @atk_hit = [0,0]                  # 普通攻击命中率
    @ski_hit = [0,0]                  # 技能命中率上升
    @item_effect_during = [0,0]       # 道具效果持续时间增加的回合数
    @atk_critical_rate = [0,0]        # 会心几率上升
    @atk_critical_damage = [0,0]      # 会心伤害上升(百分比)

    @int_plus = [0,0]                 # 智力上升
    @marv_damage = [0,0]              # 策略威力上升
    @marv_use_sp_minus = [0,0]        # 策略消耗sp减少
    @boost = [0,0]                    # 增加或减少士气
    @start_boost = [0,0]              # 初始士气增加
    @marv_succ_rate = [0,0]           # 策略成功率上升

    @agi = [0,0]                      # 敏捷上升
    @ski_speed = [0,0]                # 技能补正速度上升
    @marv_speed = [0,0]               # 策略补正速度上升
    @map_walking_speed = [0,0]        # 地图行走速度
    @eva = [0,0]                      # 回避率上升
    @agi_rate = [0,0]                 # 敏捷上升(百分比)
  end

  # 計算所有加权值
  def get_total
    SkGraph.items.each do |id,level|
      effect = SkGraph.data[id].effects
      if level > 0
        effect.data.each_pair do |k,v|
          ori_val = self.send(k)
          if v.last == "%"
            ori_val[1] = ori_val[1] + v[level-1]
          end
          if v.last == "all"
            ori_val[0] = ori_val[0] + v[level-1]
          end
          self.send "#{k.to_s}=",ori_val
        end
        #effect.tags.each do |tag|
        #  value = self.send tag,effect.send(tag)[level-1]
        #end
      end
    end
  end

  def set_battle_type(type)
    @battle_type = type
  end
end

module SkGraph
  def self.create_database
  # 勇气  力100  0/3  全队武属上升+1（2.3） 
  mod = SkGraph::Item
  DataExt.create mod,{:id=>1,:name=>"yq",:pos=>[100,119],:icon=>0,:max_level=>3,:type=>1,
                 :con=>{:ability_requ => {:str=>100}},:stru=>{6=>2,2=>3,8=>6,4=>30},
                 :effect=>{:str=>[1,2,3,"all"]},
                 :desc=>"全队武属上升+1(2,3)",:learn_text=>""}
  # 兵权  力120  0/2  杂兵战时攻击和防御加+5（10）需要【勇气】分配3点
  DataExt.create mod,{:id=>2,:name=>"bq",:pos=>[239,119],:icon=>1,:max_level=>2,:type=>1,
               :con=>{ :ability_requ => {:str=>120} ,  :item_requ=>{:name=>[1,3]} },:stru=>{8=>6,4=>1,6=>10,2=>3},
               :effect=>{:field_atk=>[5,10],:field_def=>[5,10,"all"]},
                 :desc=>"杂兵战时攻击和防御加+5(10)",:learn_text=>"需要【勇气】分配3点"}
  # 力150  残暴  0/3 全队技能伤害提升+3%（4.5% 6%）  需要力属性军师天赋分配3点
  DataExt.create mod,{:id=>3,:name=>"cb",:pos=>[167,180],:icon=>2,:max_level=>3,:type=>1,:stru=>{8=>2,6=>11,2=>4,4=>31},
               :con=>{:ability_requ=>{:str=>150},:item_requ=>{:type=>[1,3]}},
               :effect=>{:ski_damage=>[3,4.5,6,"%"]},
                 :desc=>"全队技能伤害提升+3%(4.5%)",:learn_text=>"需要力属性军师天赋分配3点"}
  # 力180   精锐 0/1 全队普通攻击的兵力加成提升+5%  需要力属性军师天赋分配3点
  DataExt.create mod,{:id=>4,:name=>"jr",:pos=>[167,242],:icon=>3,:max_level=>1,:type=>1,:stru=>{8=>3,6=>12,2=>5,4=>33},
               :con=>{:ability_requ=>{:str=>180},:item_requ=>{:type=>[1,3]}},
               :effect=>{:atk_hp=>[5,"%"]},
                 :desc=>"全队普通攻击的兵力加成提升+5%",:learn_text=>"需要力属性军师天赋分配3点"}
  # 力200  怒火  0/3 每次攻击或受到攻击增加的怒气+1（2.3） 需要力属性军师天赋分配5点
  DataExt.create mod,{:id=>5,:name=>"nh",:pos=>[239,303],:icon=>4,:max_level=>3,:type=>1,:stru=>{8=>4,6=>14,2=>6,4=>34},
               :con=>{:ability_requ=>{:str=>200},:item_requ=>{:type=>[1,5]}},
               :effect=>{:damage_tp=>[1,2,3,"all"]},
                 :desc=>"每次攻击或受到攻击增加的怒气+1(2.3)",:learn_text=>"需要力属性军师天赋分配5点"}
  # 力220  伤害  0/3 全队普攻伤害提升+1%（2.3%） 需要【怒火】分配3点
  DataExt.create mod,{:id=>6,:name=>"sh",:pos=>[239,365],:icon=>5,:max_level=>3,:type=>1,:stru=>{8=>5,6=>15,2=>2,4=>35},
               :con=>{:ability_requ=>{:str=>220},:item_requ=>{:name=>[5,3]}},
               :effect=>{:atk_damage_rate=>[1,2,3,"%"]},
                 :desc=>"全队普攻伤害提升+1%(2.3%)",:learn_text=>"需要【怒火】分配3点"}


  # 技100  兵技  0/3 全队技属性上升+3（4.5）  无
  DataExt.create mod,{:id=>10,:name=>"bj",:pos=>[376,119],:icon=>6,:max_level=>3,:type=>2,:stru=>{4=>2,6=>20,2=>11,8=>12},
                 :con=>{:ability_requ=>{:ski=>100}},
                 :effect=>{:ski=>[3,4,5,"all"]},
                 :desc=>"全队技属性上升+3(4.5)",:learn_text=>""}
  # 技120  精准  0/3 全队普攻命中率上升+1%（2.3%）  需要【兵技】分配3点
  DataExt.create mod,{:id=>11,:name=>"jz",:pos=>[376,180],:icon=>7,:max_level=>3,:type=>2,:stru=>{2=>12,4=>3,6=>13,8=>10},
                 :con=>{:ability_requ=>{:ski=>120},:item_requ=>{:name=>[10,3]}},
                 :effect=>{:atk_hit=>[1,2,3,"%"]},
                 :desc=>"全队普攻命中率上升+1%(2.3%)",:learn_text=>"需要【兵技】分配3点"}
  # 技180  精确  0/1 全队技能命中率上升+5%  需要【精准】分配3点
  DataExt.create mod,{:id=>12,:name=>"jq",:pos=>[376,242],:icon=>8,:max_level=>1,:type=>2,:stru=>{2=>14,4=>4,6=>23,8=>11},
                 :con=>{:ability_requ=>{:ski=>180},:item_requ=>{:name=>[11,3]}},
                 :effect=>{:ski_hit=>[5,"%"]},
                 :desc=>"全队技能命中率上升+5%",:learn_text=>"需要【精准】分配3点"}
  # 技150  均衡  0/1 使用会心丹等物品时持续时间增加一回合  需要技属性军师天赋分配3点
  DataExt.create mod,{:id=>13,:name=>"jh",:pos=>[520,180],:icon=>9,:max_level=>1,:type=>2,:stru=>{2=>14,4=>11,6=>22,8=>15},
                 :con=>{:ability_requ=>{:ski=>150},:item_requ=>{:type=>[2,3]}},
                 :effect=>{:item_effect_during=>[1,"all"]},
                 :desc=>"使用会心丹等物品时持续时间增加一回合",:learn_text=>"需要技属性军师天赋分配3点"}
  # 技200  技巧  0/3 全队会心几率上升+1%（2.3%） 需要技属性军师天赋分配5点
  DataExt.create mod,{:id=>14,:name=>"jiq",:pos=>[520,303],:icon=>10,:max_level=>3,:type=>2,:stru=>{2=>15,4=>5,6=>24,8=>13},
                 :con=>{:ability_requ=>{:ski=>200},:item_requ=>{:type=>[2,5]}},
                 :effect=>{:atk_critical_rate=>[1,2,3,"%"]},
                 :desc=>"全队会心几率上升+1%(2.3%)",:learn_text=>"需要技属性军师天赋分配5点"}
  # 技220  肆虐  0/1 全队会心一击伤害提升+10%  需要【技巧】分配3点
  DataExt.create mod,{:id=>15,:name=>"sn",:pos=>[520,366],:icon=>11,:max_level=>1,:type=>2,:stru=>{2=>13,4=>6,6=>25,8=>14},
                 :con=>{:ability_requ=>{:ski=>220},:item_requ=>{:name=>[14,3]}},
                 :effect=>{:atk_critical_damage=>[10,"%"]},
                 :desc=>"全队会心一击伤害提升+10%",:learn_text=>"需要【技巧】分配3点"}


  # 策100  智谋  0/3 全队智属上升+1（2.3） 无
  DataExt.create mod,{:id=>20,:name=>"zm",:pos=>[667,119],:icon=>12,:max_level=>3,:type=>3,:stru=>{2=>22,4=>10,6=>21,8=>25},
                 :con=>{:ability_requ=>{:int=>100}},
                 :effect=>{:int=>[1,2,3,"all"]},
                 :desc=>"全队智属上升+1(2.3)",:learn_text=>""}
  # 策120  谋士  0/2 全队策略威力上升+5（10）  需要【智谋】分配3点
  DataExt.create mod,{:id=>21,:name=>"ms",:pos=>[806,119],:icon=>13,:max_level=>2,:type=>3,:stru=>{2=>22,4=>20,6=>30,8=>25},
                 :con=>{:ability_requ=>{:int=>120},:item_requ=>{:name=>[20,3]}},
                 :effect=>{:marv_damage=>[5,10,"all"]},
                 :desc=>"全队策略威力上升+5(10)",:learn_text=>"需要【智谋】分配3点"}
  # 策150  凝神  0/1 全队使用策略消耗策略点减少-2 需要智属性军师天赋分配3点
  DataExt.create mod,{:id=>22,:name=>"ns",:pos=>[730,180],:icon=>14,:max_level=>1,:type=>3,:stru=>{2=>23,4=>13,6=>32,8=>21},
                 :con=>{:ability_requ=>{:int=>150},:item_requ=>{:type=>[3,3]}},
                 :effect=>{:marv_use_sp_minus=>[2,"all"]},
                 :desc=>"全队使用策略消耗策略点减少-2",:learn_text=>"需要智属性军师天赋分配3点"}
  # 策200  集气  0/3 每次增加或减少的士气+1（2.3） 需要【战气】分配1点
  DataExt.create mod,{:id=>23,:name=>"jqi",:pos=>[667,242],:icon=>15,:max_level=>3,:type=>3,:stru=>{2=>24,4=>12,6=>33,8=>22},
                 :con=>{:ability_requ=>{:int=>200},:item_requ=>{:name=>[24,1]}},
                 :effect=>{:boost=>[1,2,3,"all"]},
                 :desc=>"每次增加或减少的士气+1(2.3)",:learn_text=>"需要【战气】分配1点"}
  # 策180  战气  0/1 战斗初始士气提升+10 需要智属性军师天赋分配3点
  DataExt.create mod,{:id=>24,:name=>"zq",:pos=>[667,304],:icon=>16,:max_level=>1,:type=>3,:stru=>{2=>25,4=>14,6=>34,8=>23},
                 :con=>{:ability_requ=>{:int=>180},:item_requ=>{:type=>[3,3]}},
                 :effect=>{:start_boost=>[10,"all"]},
                 :desc=>"战斗初始士气提升+10",:learn_text=>"需要智属性军师天赋分配3点"}
  # 策220  策中  0/3 全队策略成功率提升+1%（2.3%）  需要智属性军师天赋分配8点
  DataExt.create mod,{:id=>25,:name=>"cz",:pos=>[730,365],:icon=>17,:max_level=>3,:type=>3,:stru=>{2=>20,4=>15,6=>35,8=>24},
                 :con=>{:ability_requ=>{:int=>220},:item_requ=>{:type=>[3,8]}},
                 :effect=>{:marv_succ_rate=>[1,2,3,"%"]},
                 :desc=>"全队策略成功率提升+1%(2.3%)",:learn_text=>"需要智属性军师天赋分配8点"}

  # 速100  兵速  0/3 全队速属性上升+3（4.5）  无
  DataExt.create mod,{:id=>30,:name=>"bs",:pos=>[953,119],:icon=>18,:max_level=>3,:type=>4,:stru=>{2=>32,4=>21,6=>1,8=>35},
                 :con=>{:ability_requ=>{:agi=>100}},
                 :effect=>{:agi=>[3,4,5,"all"]},
                 :desc=>"全队速属性上升+3(4.5)",:learn_text=>""}
  # 速150  技速  0/1 全队技能补正速度上升+20 需要【策速】分配3点
  DataExt.create mod,{:id=>31,:name=>"js",:pos=>[1092,181],:icon=>19,:max_level=>1,:type=>4,:stru=>{2=>33,4=>32,6=>3,8=>35},
                 :con=>{:ability_requ=>{:agi=>150},:item_requ=>{:name=>[32,3]}},
                 :effect=>{:ski_speed=>[20,"all"]},
                 :desc=>"全队技能补正速度上升+20",:learn_text=>"需要【策速】分配3点"}
  # 速120  策速  0/3 全队策略补正速度上升+5（10.15） 需要【兵速】分配3点
  DataExt.create mod,{:id=>32,:name=>"cs",:pos=>[953,180],:icon=>20,:max_level=>3,:type=>4,:stru=>{2=>33,4=>22,6=>31,8=>30},
                 :con=>{:ability_requ=>{:agi=>120},:item_requ=>{:name=>[30,3]}},
                 :effect=>{:marv_speed=>[5,10,15,"all"]},
                 :desc=>"全队策略补正速度上升+5(10.15)",:learn_text=>"需要【兵速】分配3点"}
  # 速180  行军  0/1 地图行走速度提升+10%  需要速属性军师天赋分配5点
  DataExt.create mod,{:id=>33,:name=>"xj",:pos=>[1011,242],:icon=>21,:max_level=>1,:type=>4,:stru=>{2=>34,4=>23,6=>4,8=>32},
                 :con=>{:ability_requ=>{:agi=>180},:item_requ=>{:type=>[4,5]}},
                 :effect=>{:map_walking_speed=>[10,"%"]},
                 :desc=>"地图行走速度提升+10%",:learn_text=>"需要速属性军师天赋分配5点"}
  # 速200  闪避  0/3 全队回避率上升+1（2.3）  需要速属性军师天赋分配5点
  DataExt.create mod,{:id=>34,:name=>"sb",:pos=>[953,304],:icon=>22,:max_level=>3,:type=>4,:stru=>{2=>35,4=>24,6=>5,8=>33},
                 :con=>{:ability_requ=>{:agi=>200},:item_requ=>{:type=>[4,5]}},
                 :effect=>{:eva=>[1,2,3,"all"]},
                 :desc=>"全队回避率上升+1(2.3)",:learn_text=>"需要速属性军师天赋分配5点"}
  # 速220  神速  0/3 全队速属性上升1%（2.3%） 需要【闪避】分配3点
  DataExt.create mod,{:id=>35,:name=>"ss",:pos=>[953,365],:icon=>23,:max_level=>3,:type=>4,:stru=>{2=>30,4=>25,6=>6,8=>34},
                 :con=>{:ability_requ=>{:agi=>220},:item_requ=>{:name=>[34,3]}},
                 :effect=>{:agi_rate=>[1,2,3,"%"]},:save=>true,
                 :desc=>"全队速属性上升1%(2.3%)",:learn_text=>"需要【闪避】分配3点"}
  #p SkGraph.items.map{|item| {:pos=>item.pos,:icon=>item.icon} }
  #p SkGraph.point
  end
end

# SkGraph.create_database
