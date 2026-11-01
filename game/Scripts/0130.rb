#encoding:utf-8

$need_file_bitmap = []
if FileTest.exist?("log_bitmap.txt") 
  #f = File.open("./log_bitmap.txt","r")
  #$need_file_bitmap = f.read.split(/\n/)
  #f.close
end

class Bitmap < Object
 alias ini initialize
 def initialize(*arg)
   begin
     ini(*arg)
   rescue Errno::ENOENT
     filename=[*arg][0]
     unless $need_file_bitmap.include?(filename)
       #$need_file_bitmap.push(filename) 
       #f = File.open("./log_bitmap.txt","a")
       #f.write(filename + "\n")
       #f.close
     end
     ini(32,32)
   end
 end
end

$need_file_audio = []
if FileTest.exist?("log_audio.txt") 
 #f = File.open("./log_audio.txt","r")
 #$need_file_audio = f.read.split(/\n/)
 #f.close
end

module Audio
 @me_play = method("me_play")
 def self.me_play(*arg)
   begin
     @me_play.call(*arg)
   rescue Errno::ENOENT
     filename=[*arg][0]
     unless $need_file_audio.include?(filename)
       #$need_file_audio.push(filename) 
       #f = File.open("./log_audio.txt","a")
       #f.write(filename + "\n")
       #f.close
     end
     me_stop
   end
 end
 @bgm_play = method("bgm_play")
 def self.bgm_play(*arg)
   begin
     @bgm_play.call(*arg)
   rescue Errno::ENOENT
     filename=[*arg][0]
     unless $need_file_audio.include?(filename)
       #$need_file_audio.push(filename) 
       #f = File.open("./log_audio.txt","a")
       #f.write(filename + "\n")
       #f.close
     end
     bgm_stop
   end
 end
 @se_play = method("se_play")
 def self.se_play(*arg)
   begin
     @se_play.call(*arg)
   rescue Errno::ENOENT
     filename=[*arg][0]
     unless $need_file_audio.include?(filename)
       #$need_file_audio.push(filename) 
       #f = File.open("./log_audio.txt","a")
       #f.write(filename + "\n")
       #f.close
     end
     se_stop
   end
 end
 @bgs_play = method("bgs_play")
 def self.bgs_play(*arg)
   begin
     @bgs_play.call(*arg)
   rescue Errno::ENOENT
     filename=[*arg][0]
     unless $need_file_audio.include?(filename)
       #$need_file_audio.push(filename) 
       #f = File.open("./log_audio.txt","a")
       #f.write(filename + "\n")
       #f.close
     end
     bgs_stop
   end
 end
end

