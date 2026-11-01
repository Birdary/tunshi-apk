#encoding:utf-8
module NowLoading
  def self.load_files
    sp = Sprite.new
    sp.bitmap = Bitmap.new(300,32)
    sp.bitmap.draw_text(0,0,300,32,"NOW LOADING")
    sp.x = 360
    sp.y = 360

    scripts = []
    dir = Dir.getwd + "/Scripts/"
    ["ext","module","game","sprite","window","scene","outer"].each do |subdir|
      scripts += Dir.entries(dir+subdir).grep(/.rb$/).sort.map{|s|dir+"#{subdir}/"+s}
    end
    scripts += Dir.entries(dir).grep(/.rb$/).sort.map{|s|dir+s}

    #Graphics.frame_rate = 30
    scripts.each_with_index do |script,index|
      Graphics.update
      sp.update
      p "#{index}:" + script+ "开始载入"
      if index > (scripts.size - 20)
        sp.opacity -= 25
      end
      load(script)
    end

    sp.bitmap.dispose
    sp.dispose

    # msgbox $__download

    SceneManager.run
  end

  def self.load_cache
    # 缓存动画 开线程加载
    $cache = {}

    @sp = Sprite.create do |sp|
      sp.attrset :x=> 20,:y=>10
      sp.bitmap = Bitmap.new(1280,32)
    end

    def @sp.out(n)
      self.bitmap.clear
      self.bitmap.draw_text(0,0,1280,32,n+" loaded")
    end

    # 需要缓存的目录加入其中
    cache_dir_hash = {
      "Animations" => :animation,
      "System" => :system,
      "Flash" => :flash,
      "hp" => :hp,
      "hp/dhp" => :dhp,
      "hp/boss" => :boss,
      "hp/cp" => :cp
    }
    def cache_dir(h)
      h.each_pair do |k,v|
        $cache[v] = Dir.foreach("Graphics/#{k}").map { |filename|
          if filename =~ /^(.*?).([pP][nN][gG]|[jJ][pP][gG])/
            begin ; Cache.send(v,$1,0) ; rescue ; end
            @sp.out($1) ; Graphics.update ; $1
          end
        }.compact!
      end
    end
    cache_dir cache_dir_hash
    @sp.dispose ; @sp.bitmap.dispose
  end
end