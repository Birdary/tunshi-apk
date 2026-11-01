#encoding:utf-8
class Sprite_Web_Notice < Sprite_Tip
  def update
    super
    update_web_notice
  end

  def update_web_notice
    notice = Net2nd::Queue.finished_notice_missions
    if notice
      self.add notice.data,nil
      notice.status = 3
    end
  end
end