#encoding:utf-8
#==============================================================================
# ■ Cache
#------------------------------------------------------------------------------
#  此模块载入所有图像，建立并保存 Bitmap 对象。为加快载入速度并节省内存，
#  此模块将以建立的 bitmap 对象保存在内部哈希表中，使得程序在需要已存在
#  的图像时能快速读取 bitmap 对象。
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # ● 获取动画图像
  #--------------------------------------------------------------------------
  def self.animation(filename, hue)
    bitmap = load_bitmap("Graphics/Animations/", filename, hue)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗背景（地面）图像
  #--------------------------------------------------------------------------
  def self.battleback1(filename)
    bitmap = load_bitmap("Graphics/Battlebacks1/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗背景（墙壁）图像
  #--------------------------------------------------------------------------
  def self.battleback2(filename)
    bitmap = load_bitmap("Graphics/Battlebacks2/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗图
  #--------------------------------------------------------------------------
  def self.battler(filename, hue)
    bitmap = load_bitmap("Graphics/Battlers/", filename, hue)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色行走图
  #--------------------------------------------------------------------------
  def self.character(filename)
    bitmap = load_bitmap("Graphics/Characters/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色半身像
  #--------------------------------------------------------------------------
  def self.body(filename)
    bitmap = load_bitmap("Graphics/body/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色肖像图
  #--------------------------------------------------------------------------
  def self.face(filename)
    bitmap = load_bitmap("Graphics/Faces/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色肖像图
  #--------------------------------------------------------------------------
  def self.bface(filename)
    bitmap = load_bitmap("Graphics/Faces/face/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色肖像图
  #--------------------------------------------------------------------------
  def self.ebface(filename)
    bitmap = load_bitmap("Graphics/Faces/ebface/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色肖像图
  #--------------------------------------------------------------------------
  def self.sface(filename)
    bitmap = load_bitmap("Graphics/Faces/sface/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取角色肖像图
  #--------------------------------------------------------------------------
  def self.bossface(filename)
    bitmap = load_bitmap("Graphics/Faces/bossface/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取远景图
  #--------------------------------------------------------------------------
  def self.parallax(filename)
    bitmap = load_bitmap("Graphics/Parallaxes/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取“图片”图像
  #--------------------------------------------------------------------------
  def self.picture(filename)
    bitmap = load_bitmap("Graphics/Pictures/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取系统图像
  #--------------------------------------------------------------------------
  def self.system(filename)
    bitmap = load_bitmap("Graphics/System/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取图块组图像
  #--------------------------------------------------------------------------
  def self.tileset(filename)
    bitmap = load_bitmap("Graphics/Tilesets/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取标题图像（背景）
  #--------------------------------------------------------------------------
  def self.title1(filename)
    bitmap = load_bitmap("Graphics/Titles1/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取标题图像（外框）
  #--------------------------------------------------------------------------
  def self.title2(filename)
    bitmap = load_bitmap("Graphics/Titles2/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * 战斗背景
  #--------------------------------------------------------------------------
  def self.zdbg(filename)
    bitmap = load_bitmap("Graphics/zdbg/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * hp
  #--------------------------------------------------------------------------
  def self.hp(filename)
    bitmap = load_bitmap("Graphics/hp/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * skillp
  #--------------------------------------------------------------------------
  def self.skillp(filename)
    bitmap = load_bitmap("Graphics/skillp/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * 敌人hp
  #--------------------------------------------------------------------------
  def self.dhp(filename)
    bitmap = load_bitmap("Graphics/hp/dhp/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * cp
  #--------------------------------------------------------------------------
  def self.cp(filename)
    bitmap = load_bitmap("Graphics/hp/cp/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * bosshp
  #--------------------------------------------------------------------------
  def self.boss(filename)
    bitmap = load_bitmap("Graphics/hp/boss/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * flash
  #--------------------------------------------------------------------------
  def self.flash(filename)
    bitmap = load_bitmap("Graphics/flash/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # * fc
  #--------------------------------------------------------------------------
  def self.fc(filename)
    bitmap = load_bitmap("Graphics/fc/", filename)
    yield bitmap if block_given?
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 读取位图
  #--------------------------------------------------------------------------
  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache ||= {}
    if filename.nil?
      empty_bitmap
    elsif filename.empty?
      empty_bitmap
    elsif hue == 0
      normal_bitmap(folder_name + filename)
    else
      hue_changed_bitmap(folder_name + filename, hue)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成空位图
  #--------------------------------------------------------------------------
  def self.empty_bitmap
    Bitmap.new(32, 32)
  end
  #--------------------------------------------------------------------------
  # ● 生成／获取普通的位图
  #--------------------------------------------------------------------------
  def self.normal_bitmap(path)
   @cache[path] = Bitmap.new(path) unless include?(path)
   @cache[path]
  end

  #--------------------------------------------------------------------------
  # ● 生成／获取色相变化后的位图
  #--------------------------------------------------------------------------
  def self.hue_changed_bitmap(path, hue)
    key = [path, hue]
    unless include?(key)
      @cache[key] = normal_bitmap(path).clone
      @cache[key].hue_change(hue)
    end
    @cache[key]
  end
  #--------------------------------------------------------------------------
  # ● 检查缓存是否存在
  #--------------------------------------------------------------------------
  def self.include?(key)
    @cache[key] && !@cache[key].disposed?
  end
  #--------------------------------------------------------------------------
  # ● 获取 cache
  #--------------------------------------------------------------------------
  def self.cache
    @cache
  end
  #--------------------------------------------------------------------------
  # ● 删除 key
  #--------------------------------------------------------------------------
  def self.delete(key)
    @cache.delete(key)
  end
  #--------------------------------------------------------------------------
  # ● 清空缓存
  #--------------------------------------------------------------------------
  def self.clear
    self.dispose_all if @cache
    @cache = nil

    GC.enable
    GC.start

    # @cache = {}
    # @cache.clear
    
  end

  def self.dispose_key key
    if @cache[key]
      @cache[key].dispose
      @cache[key] = nil
      @cache.delete(key)
    end
  end

  #--------------------------------------------------------------------------
  # ● 释放缓存
  #--------------------------------------------------------------------------
  def self.dispose_all
    @cache.each do |key, bitmap|
      bitmap.dispose unless bitmap.disposed?
      bitmap = nil
      @cache[key] = nil
      @cache.delete(key)
    end
  end
end

class CacheBattleBitmap

  def initialize

    # 动画相关
    @picture_Damage1 = Bitmap.new("Graphics/Pictures/Damage1")
    @picture_Damage1x = Bitmap.new("Graphics/Pictures/Damage1x")
    @system_marv_name = Bitmap.new("Graphics/System/marv_name")

    # 战斗图相关
    @battlers = []
  end

  def get(dir,key)
    instance_variable_get("@#{dir}_#{key}")
  end

  def battler_get(battler_name,index)
    return @battlers[index] if @battlers[index]
    @battlers[index] = Bitmap.new("Graphics/Battlers/#{battler_name}")

    # p "CacheBattleBitmap get -> index: #{index}"
    # p @battlers

    # @battlers[index].hue_change(hue)
    return @battlers[index]
  end

  def dispose
    @picture_Damage1.dispose
    @picture_Damage1x.dispose
    @system_marv_name.dispose

    @picture_Damage1 = nil
    @picture_Damage1x = nil
    @system_marv_name = nil

    @battlers.each_with_index do |bitmap,index|
      if bitmap
        @battlers[index].dispose
        @battlers[index] = nil
      end
    end

    @battlers.clear

    GC.enable
    GC.start
  end

  class << self

    def get(key,dir)
      if SceneManager.scene.is_a?(Scene_Battle)
        SceneManager.scene.cache_animation_bitmap.get(dir,key)
      else
        Cache.send(dir,key)
      end
    end

    def battler_get(battler_name,index)
      SceneManager.scene.cache_animation_bitmap.battler_get(battler_name,index)
    end

  end

end


module DisableableObject

  def _dispose_for_window
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Sprite)
        ivar.bitmap.dispose if ivar.bitmap
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Bitmap)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Viewport)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Plane)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Array)
        is_find_obj = false
        ivar.each_with_index do |obj, index|
          if obj.is_a?(Sprite)
            obj.bitmap.dispose if obj.bitmap
            obj.dispose
            ivar[index] = nil
            is_find_obj = true
          end

          if obj.is_a?(Hash)
            obj.each_pair do |k, v|
              if v.is_a?(Sprite)
                v.bitmap.dispose if v.bitmap
                v.dispose
                ivar[index][k] = nil
                is_find_obj = true
              end
            end
            ivar[index] = nil
          end
          if obj.respond_to?(:dispose)
            obj.dispose
            ivar[index] = nil
            is_find_obj = true
          end

        end
        instance_variable_set(varname,nil) if is_find_obj
      end
      ivar = nil
    end
  end


  def _dispose
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.dispose if ivar.is_a?(Window)
      if ivar.is_a?(Sprite)
        ivar.bitmap.dispose if ivar.bitmap
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Bitmap)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Viewport)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Plane)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      if ivar.is_a?(Array)
        is_find_obj = false
        ivar.each_with_index do |obj, index|
          if obj.is_a?(Sprite)
            obj.bitmap.dispose if obj.bitmap
            obj.dispose
            ivar[index] = nil
            is_find_obj = true
          end

          if obj.is_a?(Hash)
            obj.each_pair do |k, v|
              if v.is_a?(Sprite)
                v.bitmap.dispose if v.bitmap
                v.dispose
                ivar[index][k] = nil
                is_find_obj = true
              end
            end
            ivar[index] = nil
          end
          if obj.respond_to?(:dispose)
            obj.dispose
            ivar[index] = nil
            is_find_obj = true
          end

        end
        instance_variable_set(varname,nil) if is_find_obj
      end
      if ivar.respond_to?(:dispose)
        ivar.dispose
        instance_variable_set(varname,nil)
      end
      ivar = nil
    end
  end

  def _instance_clean
    instance_variables.each do |varname|
      instance_variable_set(varname,nil)
    end
  end
end

module GC
  def self.cache_start

    Cache.clear
    [Sprite, Bitmap, Plane, Tilemap,Viewport].each do |klass|
      ObjectSpace.each_object(klass) do |obj|
        if klass == Viewport
          obj.dispose
          obj = nil
        elsif klass == Sprite
          if obj.bitmap
            obj.bitmap.dispose unless obj.bitmap.disposed?
          end
          obj.dispose unless obj.disposed?
          obj = nil
        elsif klass == Bitmap
          unless obj.disposed?
            obj.dispose unless obj.disposed?
          end
          obj = nil
        else
          obj.dispose unless obj.disposed?
          obj = nil
        end
      end
    end
    GC.start
  end
end

