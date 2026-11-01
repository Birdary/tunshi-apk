#encoding:utf-8
class Sprite_Damage < Sprite_Base
  attr_accessor :total
  def initialize(v)
    super(v)
    @total = false
    @duration = 40
    self.ox = 81
    self.oy = 20
    #self.zoom_x = 0.5
    #self.zoom_y = 0.5
    @dx = [1,-1,4,-4,7,-7][rand(4)]
    @dd = [1,3,5,7,9,11,13,15][rand(8)]
  end
  def update
    super
    if @duration > 0
      @duration -= 1
      # if @duration % @dd == 0 && @duration >= 28
      #   self.x += @dx # (@duration / @dd.to_f).round
      # end
      if @total
        if @duration > 70
          self.x -= 1
        end
        if @duration < 30
          self.opacity -= 10
        end
      end

        case @duration
        when 38..39
          self.y -= 4
        when 36..37
          self.y -= 2
        when 34..35
          self.y += 2
        when 28..33
          self.y += 4
        end
        self.opacity = 256 - (12 - @duration) * 32


      if false
      unless @total
        case @duration
        when 50..59
          self.y -= 3
          self.x -= 1
          #self.x += @dx * @dd
        when 40..49
          self.y += 3
          self.x -= 1
          #self.x += @dx * @dd
        when 10..29
          self.opacity -= 15
          #self.x += @dx * @dd
        end
      end
      end
      # self.opacity = 256 - (12 - @duration) * 32
      # if @duration == 0
      #   self.dispose if self
      # end
    end
  end
end  