#encoding:utf-8
#==============================================================================
# ■ Scene_Loading
#------------------------------------------------------------------------------
# 　启动画面
#==============================================================================
class Scene_Loading < Scene_Base
  #--------------------------------------------------------------------------
  # ● 启动
  #--------------------------------------------------------------------------
  def start
    super
    unless $TEST #or $back_title
      @back = Sprite.new
      @back.bitmap = Bitmap.new("Graphics/System/loading_back")
      @back.bitmap.font.size = 16 + $game_variables[300]
      @back.bitmap.draw_text(15,0,300,45,"Twk Version 4.2")
      @back.z = 1
      @back.opacity = 0

      @backtext = Sprite.new
      @backtext.bitmap = Bitmap.new("Graphics/System/loading_text")
      @backtext.z = 2
      @backtext.opacity = 0

      for i in 0...26
        @backtext.opacity += 10
        @back.opacity += 10
        Graphics.update
      end
      #--------------------------------------------------------------------------
      @R_Key_BACK      = 0x08        # BACKSPACE key
      @R_Key_ENTER     = 0x0D        # ENTER key
      @R_Key_N         = 0x4E        # N key
      @R_Key_Y         = 0x59        # Y key
      @R_Key_ESC       = 0x1B        # ESC key
      #--------------------------------------------------------------------------
      @getKeyState = Win32API.new("user32","GetAsyncKeyState",['I'],'I')
      @getKeyboardState = Win32API.new("user32","GetKeyState",['I'],'I')
      @getSetKeyState = Win32API.new("user32","SetKeyboardState",['I'],'I')
      @full = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
      #--------------------------------------------------------------------------
      loop do 
        if @getKeyState.call(@R_Key_Y) & 0x01 == 1 or @getKeyState.call(@R_Key_ENTER) & 0x01 == 1
          unless $TEST
            @backtext.opacity = 0
            @full.call 0xA4, 0, 0, 0
            @full.call 13, 0, 0, 0
            @full.call 13, 0, 2, 0
            @full.call 0xA4, 0, 2, 0
            Graphics.wait(100)
          end
          break
        end
        if @getKeyState.call(@R_Key_N) & 0x01 == 1 or @getKeyState.call(@R_Key_ESC) & 0x01 == 1
          @backtext.opacity = 0
          break
        end
         Graphics.update 
      end


      if $TEST == false
        @full.call 0x90, 0, 0, 0
        Graphics.wait(10)
        @full.call 0x90, 0, 2, 0
        Graphics.wait(10)
        @full.call 0x90, 0, 0, 0
        Graphics.wait(10)
        @full.call 0x90, 0, 2, 0
        Graphics.wait(10)
      end   

      @backtext.bitmap.dispose
      @backtext.dispose

      @bar = Sprite.new
      @bar.bitmap = Bitmap.new("Graphics/System/loading_bar")
      @bar.x = 429
      @bar.y = 607+24
      @bar.z = 10
      @bar.src_rect = Rect.new(0,0,0,8)

      @mask = Sprite.new
      @mask.bitmap = Bitmap.new("Graphics/System/loading_bar_mask")
      @mask.x = 378
      @mask.y = 607
      @mask.z = 100

      @char = Sprite.new
      @char.bitmap = Bitmap.new(111,52)
      @char.bitmap.blt(0,0,Bitmap.new("Graphics/System/loading_c"),Rect.new(0,0,111,52))
      @char.x = 585
      @char.y = 550
      @char.z = 100

      count = 0
      c = 0
      total_count = 1

      for i in 0...147
        @bar.src_rect = Rect.new(0,0,count,8)
        if total_count%6 == 0
          @char.bitmap.clear
          @char.bitmap.blt(0,0,Bitmap.new("Graphics/System/loading_c"),Rect.new((c)*111,0,111,92))
          c += 1
          c = 0 if c > 3
        end 
        count += 3
        total_count += 1
        Graphics.update 
        Audio.se_play("Audio/SE/0decide1",90,100)  if i == 145
      end

      for i in 0...50
        @char.opacity -= 5
        @bar.opacity -= 5
        @mask.opacity -= 5
        @back.opacity -= 5
        Graphics.update
      end  

      @back.bitmap.dispose
      @back.dispose
      @bar.bitmap.dispose
      @bar.dispose
      @mask.bitmap.dispose
      @mask.dispose
      @char.bitmap.dispose
      @char.dispose
    end
    SceneManager.goto(Scene_Title)
  end

  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  # => 无需手动释放
  # def terminate

  #   if @backtext
  #      @back.bitmap.dispose
  #      @back.dispose
  #   end
  #   if @back
  #      @back.bitmap.dispose
  #      @back.dispose
  #   end  
  #   if @bar
  #      @bar.bitmap.dispose
  #      @bar.dispose
  #   end  
  #   if @mask
  #      @mask.bitmap.dispose
  #      @mask.dispose
  #   end  
  #   if @char
  #      @char.bitmap.dispose
  #      @char.dispose
  #   end
  # end

end
