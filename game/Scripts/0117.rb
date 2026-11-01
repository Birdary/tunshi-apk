#encoding:utf-8
# 目的: 解决编辑器命令【删除图片】这个功能会导致游戏卡

#------------------------------------------------------------------------------
class Game_Picture
  #--------------------------------------------------------------------------
  # ● ピクチャの消去
  #--------------------------------------------------------------------------
  alias vxace_sp1_erase erase
  def erase
    vxace_sp1_erase
    @origin = 0
  end
end

class Sprite_Picture
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップの更新
  #--------------------------------------------------------------------------
  alias vxace_sp1_update_bitmap update_bitmap
  def update_bitmap
    if @picture.name.empty?
      self.bitmap = nil
    else
      vxace_sp1_update_bitmap
    end
  end
end

