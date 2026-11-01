#encoding:utf-8
class Sprite_Flash < Sprite
  def initialize(v=nil)
    super(v)
    @c = 0
    @state = :up
  end
  def update
    super
    self.opacity += 4 if @state == :up
    self.opacity -= 4 if @state == :down
    if self.opacity >= 255
      self.opacity = 255
      @state = :down
    end
    if self.opacity <= 0
      self.opacity = 0
      @state = :up
    end
  end
end  