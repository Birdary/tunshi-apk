#encoding:utf-8
module RPG
  module EXT
    module FlashSprite
      def create_flash_background(btm)
        @c = 0 ; @flash = 0
        @flash_background = Sprite.create do |sp|
          sp.bitmap = btm; sp.opacity = 0; sp.z = 201
        end
      end

      def dispose_flash_background
        if @flash_background
          @flash_background.dispose
          @flash_background.bitmap.dispose
        end
      end

      def update_flash_background
        if @flash_background
          if @c == 0
            @flash +=3
            @flash_background.opacity = @flash   
            if @flash >= 255
              @c = 1
            end  
          else
            @flash -=3
            @flash_background.opacity = @flash
            if @flash <= 10
              @c = 0
            end
          end
        end
      end
    end

    module Event
      def is_water?
        ["!$w1","!$w2","!$w3","!$w4","!$w5","!$w6","!$w7","!$w8","!$w9","!$w10","!$w11","!$w12","!$w21","!$w22","!$w13","!$w14","!$w15","!$w16","!$w23","!$w24"].include?(@character_name)
      end

      def is_big_water?
        ["!$w3","!$w4","!$w21","!$w22","!$w23","!$w24"].include?(@character_name)
      end

      #--------------------------------------------------------------------------
      # ● 更新水的事件 - - 
      #--------------------------------------------------------------------------  
      def update_water

      if $game_variables[41] > 0 #水流动变量开关
      if ["!$w21","!$w22","!$w23","!$w24"].include?(@character_name)
          if @wait_count > 0          # 等待
            @wait_count -= 1
          else
            @pattern += 1
            @wait_count = 8
            if @pattern >= 3 or (@direction ==6 and @pattern == 2 ) 
              @pattern = 0
              case @direction
              when 2
                @direction = 4
              when 4
                @direction = 6
              when 6
                #@pattern = 1
                @direction = 2
                @character_index = 0
              end
            end
          end  
        end
      end

      if ["!$w5","!$w6","!$w7","!$w8","!$w9","!$w10","!$w11","!$w12"].include?(@character_name)
          if @wait_count > 0          # 等待
            @wait_count -= 1
          else
            @pattern += 1
            @wait_count = 8
            if @pattern >= 3 or (@direction ==6 and @pattern == 2 ) 
              @pattern = 0
              case @direction
              when 2
                @direction = 4
              when 4
                @direction = 6
              when 6
                #@pattern = 1
                @direction = 2
                @character_index = 0
              end
            end
          end  
        end


      if ["!$w13","!$w14","!$w15","!$w16"].include?(@character_name)
          if @wait_count > 0          # 等待
            @wait_count -= 1
          else
            @pattern += 1
            @wait_count = 8
            if @pattern >= 3 or (@direction ==6 and @pattern == 2 ) 
              @pattern = 0
              case @direction
              when 2
                @direction = 4
              when 4
                @direction = 2
                #@pattern = 1
              #when 6
                 #@pattern = 4
                 #@direction = 2
                 #@character_index = 0
              end  
            end
          end  
        end




        if ["!$w1","!$w2"].include?(@character_name)
          if @wait_count > 0          # 等待
            @wait_count -= 1
          else
            @pattern += 1
            @wait_count = 8
            if @pattern >= 3
              @pattern = 0
              case @direction
              when 2
                @direction = 4
              when 4
                @direction = 6
              when 6
                @direction = 8
              when 8
                if @character_name == "!$w1"
                  @character_name = "!$w2"
                  @character_index = 0
                elsif @character_name == "!$w2"
                  @character_name = "!$w1"
                  @character_index = 0
                end
                @direction = 2
              end  
            end
          end  
        end  
        if ["!$w3","!$w4"].include?(@character_name)
          if @wait_count > 0          # 等待
            @wait_count -= 1
          else
            @pattern += 1
            @wait_count = 8
            if @pattern >= 3
              @pattern = 0
              case @direction
              when 2
                @direction = 4
              when 4
                @direction = 6
              when 6
                @direction = 8
              when 8
                if @character_name == "!$w3"
                  @character_name = "!$w4"
                  @character_index = 0
                elsif @character_name == "!$w4"
                  @character_name = "!$w3"
                  @character_index = 0
                end
                @direction = 2
              end  
            end
          end  
        end  
      end
    end
  end
end