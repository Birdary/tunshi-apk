#encoding:utf-8
# class HTTP
#   Create   = Win32API.new('AHttp.dll', 'Create',   'pppp',   'l')
#   CreateEx = Win32API.new('AHttp.dll', 'CreateEx', 'pppppp', 'l')
#   Query    = Win32API.new('AHttp.dll', 'QueryEx',  'lpp',    'i')
#   Retrieve  = Win32API.new('AHttp.dll', 'Retrieve', 'lp',     'i')
#   Close    = Win32API.new('AHttp.dll', 'Close',    'l',      'l')
#   INVALID  = 0;    SUCCESS = 1;    FAILURE = 2;    PENDING = 3
#   def initialize(type, server, action, meth, data, ctype = "", browser = "")
#     @token = type == 0 ?
#               Create.call(server, action, meth, data) :
#               CreateEx.call(server, action, meth, ctype, browser)
#     @total = [0].pack("L")
#     @loaded = [0].pack("L")
#   end
#   def total_bytes
#     query
#     return @total.unpack("L").first
#   end
#   def loaded_bytes
#     query
#     return @loaded.unpack("L").first
#   end
#   def query
#     Query.call(@token, @total, @loaded)
#   end
#   def retrieve
#     if query == SUCCESS
#       length = Retrieve.call(@token, 0)
#       buffer = "\0" * length
#       Retrieve.call(@token, buffer)
#       return buffer
#     end
#   end
#   def close
#     Close.call(@token)
#   end
#   def self.create(server, action, meth, data={})
#     @conn = new(0, server, action, meth, data_encode(data))
#     if block_given?
#       yield @conn
#       @conn.close
#     else
#       return @conn
#     end
#   end
#   def self.create_ex(server, action, meth, ctype, browser, data={})
#     @conn = new(0, server, action, meth, data_encode(data), ctype, browser)
#     if block_given?
#       yield @conn
#       @conn.close
#     else
#       return @conn
#     end
#   end
#   def self.data_encode(data)
#     d = ""
#     data.each_pair do |k, v|
#       d += "%" + k.to_s.unpack("C*").map{|s|s.to_s(16)}.join("%") + "="
#       d += "%" + v.to_s.unpack("C*").map{|s|s.to_s(16)}.join("%") + "&"
#     end
#     return d.sub(/.$/, "")
#   end
#   private_class_method :new, :data_encode
# end


# s = Sprite.new
# b = Bitmap.new(640, 32)
# s.bitmap = b
# #HTTP.create("localhost", "projects/test.php", "POST", {"test"=>"hahahaha"}){ |h|
# HTTP.create("rm.66rpg.com", "forum.php", "GET"){ |h|
#         while(!h.retrieve)
#     b.clear
#     b.draw_text(0,0, 640, 32, "#{h.query}:#{h.loaded_bytes}/#{h.total_bytes}")
#     Graphics.update
#         end
#   b.clear
#   b.draw_text(0,0, 640, 32, "#{h.query}:#{h.loaded_bytes}/#{h.total_bytes}")
#   Graphics.update
#         print(h.retrieve)
# }