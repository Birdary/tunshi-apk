#encoding:utf-8
class Sprite_Tip < Sprite
  DEFAULT_COLOR = Color.new 255,255,255,255
  RED_COLOR = Color.new 255,0,0,255
  GREEN_COLOR = Color.new 0,255,0,255
  attr_accessor :queue
  def initialize(v)
    super(v)
    @v = v
    self.x = -240
    self.y = 570+45
    self.z = 300
    self.opacity = 0

    self.bitmap = Bitmap.new(367,69)
    self.bitmap.font.size = 16 + $game_variables[300]+1


    @back = Sprite.new
    @back.bitmap = Cache.zdbg("Bmsg")
    @back.opacity = 0
    @back.z = 500

    @count = 0
    @queue = []

    @effect_duration = 0

  end

  def animation?
    @count > 0
  end

  def add text,color
    _color = case color
      when "red"; RED_COLOR
      when "green"; GREEN_COLOR
      else
        DEFAULT_COLOR
    end
    @queue << [text,_color]
  end

  def update
    super
    update_queue
    update_animation
    update_back
  end

  def update_queue
    if @queue.size > 0 && @count == 0
      arr = @queue.shift
      text = arr.first
      color = arr.last
    
      if text.length == 11
      name  = text[0,6]  
      state = text[6,2]  
      over  = text[8,20]
      self.bitmap.clear
      self.bitmap.color = Color.new 255,255,255,255
      self.bitmap.draw_text(110,4,367+100,69,name)
      self.bitmap.color = color
      self.bitmap.draw_text(110+84,4,367+100,69,state)
      self.bitmap.color = Color.new 255,255,255,255
      self.bitmap.draw_text(110+113,4,367+100,69,over)
      elsif text.length == 12
      name  = text[0,7]
      state = text[7,2]
      over  = text[9,21]
      self.bitmap.clear
      self.bitmap.color = Color.new 255,255,255,255
      self.bitmap.draw_text(110,4,367+100,69,name)
      self.bitmap.color = color
      self.bitmap.draw_text(110+84+14,4,367+100,69,state)
      self.bitmap.color = Color.new 255,255,255,255
      self.bitmap.draw_text(110+113+13,4,367+100,69,over)
      else
      name  = text[0,8]
      state = text[8,2]
      over  = text[10,22]
      self.bitmap.clear
      self.bitmap.color = Color.new 255,255,255,255
      self.bitmap.draw_text(110,4,367+100,69,name)
      self.bitmap.color = color
      self.bitmap.draw_text(110+84+14+14,4,367+100,69,state)
      self.bitmap.color = Color.new 255,255,255,255
      self.bitmap.draw_text(110+113+13+13,4,367+100,69,over)  
      end


      @count = 180
    end
  end

  def update_whiten
    @effect_duration -= 1
    self.color.set(255, 255, 255, 0)
    self.color.alpha = 128 - (16 - @effect_duration) * 5
  end

  def update_animation
    if @count > 0
#      p @count
        if $game_switches[395] == false
          self.opacity = 0
        end
      case @count
      when 166..180
        self.x += 10
        if $game_switches[395] == true
          self.opacity += 17
        else
          self.opacity = 0
        end 
      when 134..165
      when 133
        # @effect_duration = 40
        self.flash(Color.new(255,255,255,200), 100)
        @back.flash(Color.new(255,255,255,200), 100)
      when 16..132
      when 1..15
        self.x -= 10
          self.opacity -= 17 
      end

      @count -= 1
    end
  end

  def update_back
    @back.x = self.x - 10
    @back.y = self.y + 2
    @back.visible = self.visible
    @back.opacity = self.opacity
    @back.update
  end

  def dispose
    super
    self.bitmap.dispose
    if @back
      @back.dispose
      @back.bitmap.dispose
      @back = nil
    end
    if @v
      @v.dispose
      @v = nil
    end
  end
end  