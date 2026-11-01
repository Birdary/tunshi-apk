#encoding:utf-8

# 显示图形的方法
# sp = Sprite.create do |option|
#   option.attrset :x=>100,:y=>200,:opacity=>255

#   option.wave_amp = 80
#   option.wave_length = 240
#   option.wave_speed = 300

#   option.bitmap = Cache.picture("xxx") do |btm|
#       btm.font.size = 12 + $game_variables[300]
#       btm.font.color = Color.new(255,0,0,255)
#       btm.radial_blur(20, 2)
#       btm.draw_text(0,0,150,50,"iLoveRuby")
#   end
# end

class Object
  def attrset(options)
    options.each_pair do |k,v|
      self.send(k.to_s+"=",v) if self.respond_to?("#{k}=")
    end
    self
  end
  def ivarset(options)
    options.each_pair do |k,v|
      instance_variable_set("@"+k.to_s,v)
    end
  end
  def blank?
    [nil,0,[],{},""].include? self
  end
end

class Bitmap
  alias ori_dispose dispose
  def dispose
    # ori_dispose unless disposed?
  end
  def color=(c)
    self.font.color = c
  end
  def self.create(*args)
    bitmap = new(*args)
    yield bitmap if block_given?
    bitmap
  end
end

class Sprite
  alias ori_dispose dispose
  def dispose
    ori_dispose unless disposed?
  end
  def dispose_all
    dispose
    self.bitmap.dispose unless self.bitmap.nil?
  end
  def self.create(*args)
    sprite = new(*args)
    yield sprite if block_given?
    sprite
  end
end

class SpriteGroup
  def initialize
    @sprites = []
    @sprites << yield(self) if block_given?
  end
  def set(option)
    sp = Sprite.new(option[:v])
    sp.attrset(option)
    @sprites << sp
  end
  def dispose
    @sprites.each { |sp| sp.bitmap.dispose ; sp.dispose }
  end
end
=begin
SpriteGroup.new do |item|
  item.set :y=>0,:bitmap=>Bitmap.new,:v=>Viewport
  item.set :x=>0,:y=>0,:z=>100
end
=end

class ESprite
  def self.bcreate(bx,by,bitmap,n,v=nil)
    w = bitmap.width/n.to_i
    h = bitmap.height/n.to_i
    @sprites = []
    (n*n).times do
      @sprites << Sprite.create(v) do |sp|
        sp.bitmap = Bitmap.new(w,h)
      end
    end
    @sprites.each_with_index do |sp,index|
      x = index%n*w ; y = index/n*h 
      sp.bitmap.stretch_blt(Rect.new(0,0,w,h),bitmap,Rect.new(x,y,w,h),rand(255))
      sp.x = bx+x ; sp.y = by+y
    end
    bitmap.dispose
  end

  def self.create(bx,by,bitmap,n,v=nil)
    w = bitmap.width/n.to_i
    h = bitmap.height/n.to_i
    @sprites = Sprite.create(v) do |sp|
      sp.bitmap = Bitmap.new(bitmap.width,bitmap.height)
    end
    for index in 0...(n*n)
      x = index%n*w ; y = index/n*h 
      @sprites.bitmap.stretch_blt(Rect.new(x,y,w,h),bitmap,Rect.new(x,y,w,h),255)
    end
    @sprites.x = bx ; @sprites.y = by ;
    bitmap.dispose
  end

  def self.dispose_sprite
    @sprites.dispose
    @sprites.bitmap.dispose
  end


  def self.dispose
    @sprites.each do |sp|
      sp.dispose
      sp.bitmap.dispose
    end
  end  
end
