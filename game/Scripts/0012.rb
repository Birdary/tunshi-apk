#encoding:utf-8

module Net2nd
  # 2nd 网络队列
  module Queue
    @@list = []      # => 网络任务队列
    @@finished = []  # => 完成的任务记录

    module_function

    # 每一帧调用
    def update
      # @Thread.new
      mission = now_mission
      if mission
        mission.start
      end
    end

    def << mission
      @@list.push mission
    end

    def finished mission
      @@finished << mission
    end

    def finished_notice_missions
      @@finished.select{|m| m.type == "notice" && m.status == 2 }.first
    end

    def now_mission
      @@list.shift
    end
  end

  # 网络实例 网络任务
  class Mission
    attr_accessor :name
    attr_accessor :type
    attr_accessor :data
    attr_accessor :status     #=> 0 新建 1 开始 2 完成 3 已公告 -1 失败
    attr_accessor :is_timeout

    TYPE = { 1 => "notice", 2 => "login", 3 => "range", 4 => "userinfo"}

    def initialize name,type
      @name = name
      @type = type
      @data = nil
      @status = 0
      @is_timeout = false    
    end

    def success!
      @status = 2
      Queue.finished(self)
    end

    def failed!
      @status = -1
    end

    def start
      @status = 1
      send "parse_#{TYPE[@type]}"
    end

    def stop
      @thread.kill
    end

    def parse_notice
      @thread = Thread.new do
        begin
          v = WeAccount::RestClient.get("http://twk2nd.com/game_api/notice")
          @data = WeAccount::JSON.parse(v.body)
          success!
        rescue
          p "获取网络公告失败"
          failed!
        end
      end
    end

    def parse_login
      @thread = Thread.new do
        begin
          @data = WeAccount::Login.run("3", "1")
          success!
        rescue
          failed!
        end
      end
    end

    def parse_userinfo
      @thread = Thread.new do
        begin
          v = WeAccount::RestClient.get("http://twk2nd.com/game_api/userinfo")
          @data = WeAccount::JSON.parse(v.body)
          success!
        rescue
          failed!
        end
      end
    end
  end

  module_function

  # 登录
  def start_login
    # 登录超时时间
    timeout = 120
    is_timeout = false
    start_time = Time.now
    mission = Mission.new "登录",2

    sp = Sprite.new
    sp.bitmap = Bitmap.new(1280,720)
    sp.bitmap.font.color = Color.new(255,255,255,255)
    sp.bitmap.font.size = 19 + $game_variables[300]
    sp.bitmap.draw_text(1000,600,100,32,"请登录..",2)
    Graphics.update

    Queue << mission

    loop do
      Graphics.update
      Queue.update

      if Time.now - start_time < timeout
        case mission.status
        when 0
          p "正在准备开始登录"
        when 1
          p "正在登录请稍等"
        when 2
          p "登录成功"
          break
        when -1
          p "登录失败,请重新登录"
          break
        end
      else
        mission.is_timeout = true
        mission.stop
        p "超时"
        break
      end
      sleep 1
    end
    sp.bitmap.dispose
    sp.dispose

    return mission
  end

  # 获取最新公告
  def notice
    mission = Mission.new "公告",1
    Queue << mission
  end

  # 排行
  def range
    mission = Mission.new "排行",3
    Queue << mission
  end

  # 获取玩家信息
  def userinfo
    mission = Mission.new "公告",4
    Queue << mission
  end

end

