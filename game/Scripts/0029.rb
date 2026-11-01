#encoding:utf-8

#============================================================================
# ■ WeAccount
#----------------------------------------------------------------------------
# 　顶层模块。
#============================================================================
module WeAccount
  
  unless :a.respond_to?:<=>
    class ::Symbol
      def <=>(other)
        self.to_s <=> other.to_s
      end
    end
  end

  if !defined?(Win32API)
    require 'Win32API'
  end

  module API

    CA_MD5 = Win32API.new('WeAccount', '__wa_md5', 'pip', 'i');
    CA_SHA1 = Win32API.new('WeAccount', '__wa_sha1', 'pip', 'i');

    module_function

    def md5(s, raw = false)
      s ||= ""
      r = 0.chr * 16
      raise 'unknown error...' if CA_MD5.call(s, s.bytesize, r).zero?
      r = r.unpack("C*").map{|c| format("%02x", c)}.join("") unless raw
      return r
    end

    def sha1(s, raw = false)
      s ||= ""
      r = 0.chr * 20
      raise 'unknown error...' if CA_SHA1.call(s, s.bytesize, r).zero?
      r = r.unpack("C*").map{|c| format("%02x", c)}.join("") unless raw
      return r
    end

  end

  # 
  #  example
  #
  #  j = "{\"status\":\"-1\",\"msg\":\"ok\",\"data\":{\"a\":123,\"b\":\"456\"}}" 
  #  msgbox JSON.parse j
  #
  module JSON
    class Context
      WHITE_SPACES = [" ", "\t", "\r", "\n"]
      NUMBER_LETTERS = '0123456789+-.eE'
      HEX_LETTERS = '0123456789abcdef'
      def initialize(s)
        s.force_encoding("utf-8") if s.respond_to?(:force_encoding)
        @buf = s
        @index = 0
        @length = s.size
      end
      def skip_white
        while WHITE_SPACES.include? @buf[@index, 1] do
          @index += 1
        end 
      end
      def has_next?
        @index < @length
      end
      def next
        b = @buf[@index, 1]
        @index += 1
        b
      end
      def back
        @index -= 1
      end
      def current
        return @buf[@index, 1]
      end
      def error(msg)
        raise "#{msg}: #{@buf[@index...-1]}"
      end
      def parse_constant(expect, value)
        s = ''
        pos = @index
        while self.has_next?
          c = self.next
          unless expect.include? c
            if s == expect
              self.back
              return value
            end
            @index = pos
            error 'Unknown token'
          end
          s += c
        end
        error 'Unknown token'
      end
      def parse_number
        s = self.next
        while self.has_next?
          c = self.next
          unless NUMBER_LETTERS.include? c
            self.back
            break
          end
          s += c
        end
        if s.include? '.'
          return s.to_f
        end
        return s.to_i
      end
      def parse_string
        self.next
        s = ''
        while self.has_next?
          c = self.next
          case c
          when '\\'
            c = self.next
            case c
            when '\\', '/'
              s += c
            when 'b'
              s += "\b"
            when 'f'
              s += "\f"
            when 'n'
              s += "\n"
            when 'r'
              s += "\r"
            when 't'
              s += "\t"
            when 'u'
              u = 0
              while self.has_next?
                c = self.next
                i = HEX_LETTERS.index(c.downcase)
                if i == nil
                  self.back
                  break
                end
                u = u * 16 | i
              end
              if u < 0x80
                s += u.chr
              elsif u < 0x800
                s += (0xc0 | (u >> 6)).chr
                s += (0x80 + (u & 0x3f)).chr
              elsif u < 0x10000
                s += (0xe0 | (u >> 12)).chr
                s += (0x80 | ((u >> 6) & 0x3f)).chr
                s += (0x80 | (u & 0x3f)).chr
              elsif u < 0x200000
                s += (0xf0 | (u >> 18)).chr
                s += (0x80 | ((u >> 12) & 0x3f)).chr
                s += (0x80 | ((u >> 6) & 0x3f)).chr
                s += (0x80 | (u & 0x3f)).chr
              elsif u < 0x4000000
                s += (0xf8 | (u >> 24)).chr
                s += (0x80 | ((u >> 18) & 0x3f)).chr
                s += (0x80 | ((u >> 12) & 0x3f)).chr
                s += (0x80 | ((u >> 6) & 0x3f)).chr
                s += (0x80 | (u & 0x3f)).chr
              else
                s += (0xfc | (u >> 30)).chr
                s += (0x80 | ((u >> 24) & 0x3f)).chr
                s += (0x80 | ((u >> 18) & 0x3f)).chr
                s += (0x80 | ((u >> 12) & 0x3f)).chr
                s += (0x80 | ((u >> 6) & 0x3f)).chr
                s += (0x80 | (u & 0x3f)).chr
              end
            else
              error 'Invalid string token'
            end
          when '"'
            return s
          else
            s += c
          end
        end
        error 'Invalid string token'
      end
      def parse_object
        self.next
        o = {}
        while self.has_next?
          self.skip_white
          c = self.next
          if c == '}'
            self.next
            break
          end
          if c != '"'
            error 'Expected "\"" but not found'
          end
          self.back
          k = self.parse_string
          self.skip_white
          c = self.next
          if c != ':'
            error 'Expected ":" but not found'
          end
          self.skip_white
          v = self.parse_value
          o[k] = v
          self.skip_white
          c = self.current
          if c == '}'
            self.next
            break
          end
          if c != ','
            error 'Expected "," or "}" but not found'
          end
          self.next
        end
        o
      end
      def parse_array
        self.next
        a = []
        while self.has_next?
          self.skip_white
          if self.current == ']'
            break
          end
          i = self.parse_value
          self.skip_white
          c = self.next
          a << i
          if c == ']'
            break
          end
          if c != ','
            error 'Expected "," or "]" but not found'
          end
        end
        a
      end
      def parse_value
        self.skip_white
        c = self.current
        case c
        when '{'
          return self.parse_object
        when '['
          return self.parse_array
        when '"'
          return self.parse_string
        when '0','1','2','3','4','5','6','7','8','9','-'
          return self.parse_number
        when 't'
          return self.parse_constant('true', true)
        when 'f'
          return self.parse_constant('false', false)
        when 'n'
          return self.parse_constant('null', nil)
        else
          error 'Invalid sequence'
        end
      end
    end
    def self.parse(text)
      JSON::Context.new(text).parse_value
    end
  end
  
  #==========================================================================
  # ■ WeAccount::Kconv
  #--------------------------------------------------------------------------
  # 　处理编码转换的模块。
  #     * 注意转码后的字符串默认都不是空终止的。
  #==========================================================================  
  module Kconv

    CP_ACP  = 0
    CP_UTF8 = 65001

    M2W     = Win32API.new("kernel32", "MultiByteToWideChar", "ilpipi", "i")
    W2M     = Win32API.new("kernel32", "WideCharToMultiByte", "ilpipipp", "i")

    module_function

    #----------------------------------------------------------------------
    # ● Ansi 转 Unicode
    #----------------------------------------------------------------------    
    def s2w(text, null_terminate = false)
      wlen = M2W.call(CP_ACP, 0, text, text.bytesize, nil, 0)
      wbuf = 0.chr * 2 * (wlen + (null_terminate ? 1 : 0))
      M2W.call(CP_ACP, 0, text, text.bytesize, wbuf, wlen)
      return wbuf
    end

    #----------------------------------------------------------------------
    # ● UTF8 转 Unicode
    #----------------------------------------------------------------------     
    def u2w(text, null_terminate = false)
      wlen = M2W.call(CP_UTF8, 0, text, text.bytesize, nil, 0)
      wbuf = 0.chr * 2 * (wlen + (null_terminate ? 1 : 0))
      M2W.call(CP_UTF8, 0, text, text.bytesize, wbuf, wlen)   
      return wbuf
    end

    #----------------------------------------------------------------------
    # ● Unicode 转 Ansi
    #----------------------------------------------------------------------    
    def w2s(text, null_terminate = false)
      slen = W2M.call(CP_ACP, 0, text, text.bytesize / 2, nil, 0, nil, nil)
      sbuf = 0.chr * (slen + (null_terminate ? 1 : 0))
      W2M.call(CP_ACP, 0, text, text.bytesize / 2, sbuf, sbuf.bytesize, nil, nil)
      return sbuf
    end

    #----------------------------------------------------------------------
    # ● Unicode 转 UTF8
    #----------------------------------------------------------------------    
    def w2u(text, null_terminate = false)
      ulen = W2M.call(CP_UTF8, 0, text, text.bytesize / 2, nil, 0, nil, nil)
      ubuf = 0.chr * (ulen + (null_terminate ? 1 : 0))
      W2M.call(CP_UTF8, 0, text, text.bytesize / 2, ubuf, ubuf.bytesize, nil, nil)  
      return ubuf
    end

    #----------------------------------------------------------------------
    # ● UTF8 转 Ansi
    #----------------------------------------------------------------------     
    def u2s(text, null_terminate = false)
      return w2s(u2w(text), null_terminate)
    end

    #----------------------------------------------------------------------
    # ● Ansi 转 UTF8
    #----------------------------------------------------------------------    
    def s2u(text, null_terminate = false)
      return w2u(s2w(text), null_terminate)
    end

    #----------------------------------------------------------------------
    # ● 扩展内部类 String
    #----------------------------------------------------------------------
    class ::String
      
      #--------------------------------------------------------------------
      # ● 兼容1.8系列
      #-------------------------------------------------------------------- 
      def bytesize
        size
      end unless ''.respond_to?(:bytesize)
      
      #--------------------------------------------------------------------
      # ● 添加转码相关函数
      #--------------------------------------------------------------------  
      ["s2w", "u2w", "w2s", "w2u", "u2s", "s2u"].each do |m|
        class_eval %Q(
          def #{m}(null_terminate = false)
            return WeAccount::Kconv.#{m}(self, null_terminate)
          end
          def #{m}!(null_terminate = false)
            self.replace(WeAccount::Kconv.#{m}(self, null_terminate))
          end
        )
      end

    end  
    
  end

  #==========================================================================
  # ■ WeAccount::RestClient
  #--------------------------------------------------------------------------
  # 　处理 HTTP 请求的模块，风格参考 RestClient。
  # ※ 采用 Windows 的 WinHttp 进行处理
  # ※ 参考：https://msdn.microsoft.com/en-us/library/windows/desktop/aa384257(v=vs.85).aspx
  #========================================================================== 
  class RestClient

    class Response

      attr_accessor :code, :text, :body, :headers

      def initialize(code, text, body, headers)
        @code, @text, @body, @headers = code, text, body, headers
      end

      {:success      => 200..299, :redirect     => 300..399,
       :client_error => 400..499, :server_error => 500..599}.each do |result, code_range|
        class_eval(<<-EVAL, __FILE__, __LINE__)
          def #{result}? 
            (#{code_range}).include? code
          end
        EVAL
      end      

    end

    def self.get url, args = nil
      new(url, args).request(:get)
    end

    def self.post url, args = nil
      new(url, args).request(:post)
    end

    def self.put url, args = nil
      new(url, args).request(:put)
    end

    def self.del url, args = nil
      new(url, args).request(:delete)
    end

    def initialize(url, args)
      parse_url(url)
      @args = args
    end

    def request(verb, headers = nil)      
      hsession = WinHttpOpen.call(DEFAULT_UA.u2w + "\0\0", 0, nil, nil, 0)
      raise 'init failed' if hsession.zero?

      hconnect = WinHttpConnect.call(hsession, @hostname.u2w + "\0\0", @port, 0)
      raise 'connect failed' if hconnect.zero?

      flag = @scheme == INTERNET_SCHEME_HTTPS ? WINHTTP_FLAG_SECURE : 0
      hrequest = WinHttpOpenRequest.call(hconnect, verb.to_s.upcase.u2w + "\0\0", @object_name.u2w + "\0\0", nil, nil, nil, flag)
      raise 'open request failed' if hrequest.zero?

      if headers
        headers.each do |k, v|
          header = "#{k}: #{v}\r\n".u2w
          raise 'add header failed' if WinHttpAddRequestHeaders.call(hrequest, headers, headers.bytesize / 2, WINHTTP_ADDREQ_FLAG_ADD).zero?
        end
      end

      body = @args.nil? ? '' : @args.keys.map{|k| "#{k}=#{@args[k]}"}.join('&')
      size = body.bytesize

      raise 'send request failed' if WinHttpSendRequest.call(hrequest, nil, 0, body, size, size, 0).zero?
      raise 'receive failed...' if WinHttpReceiveResponse.call(hrequest, 0).zero?

      # p query_info(hrequest, WINHTTP_QUERY_CONTENT_LENGTH)

      status_code = query_info(hrequest, WINHTTP_QUERY_STATUS_CODE).to_i
      status_text = query_info(hrequest, WINHTTP_QUERY_STATUS_TEXT)

      size = 1024
      buf = 0.chr * size
      sizeptr = [1024].pack("L")
      status_body = String.new
      loop do
        break if WinHttpReadData.call(hrequest, buf, buf.bytesize, sizeptr).zero?
        size = sizeptr.unpack('L').first
        break if size <= 0
        status_body << (size == buf.bytesize ? buf : buf[0, size])
      end
      # => TODO：
      return Response.new(status_code, status_text, status_body, {})
    ensure
      WinHttpCloseHandle.call(hrequest) if hrequest && hrequest != 0
      WinHttpCloseHandle.call(hconnect) if hconnect && hconnect != 0
      WinHttpCloseHandle.call(hsession) if hsession && hsession != 0
    end

    private

    def parse_url(url)
      ary = url.gsub("\\", "/").scan(/^(?:(http|https)\:\/\/)*?([\w.]+?)(?:\:(\d+))*?(\Z|\/.*$)/i)
      raise 'invalid url' if ary.empty?
      val = ary.first
      ssl = val.first != nil && val.first.downcase == "https"
      @hostname = val[1]
      @port = val[2].to_i if val[2]
      @object_name = val[3].to_s
      @object_name = '/' if @object_name.empty?
      if ssl
        @scheme = INTERNET_SCHEME_HTTPS
        @port ||= 443
      else
        @scheme = INTERNET_SCHEME_HTTP
        @port ||= 80
      end
    end
    
    def query_info(hrequest, query_type)
      size = 256
      buf = 0.chr * size
      sizeptr = [size].pack('L')
      return nil if WinHttpQueryHeaders.call(hrequest, query_type, nil, buf, sizeptr, nil).zero?
      size = sizeptr.unpack('L').first
      return buf[0, size].w2u
    end

    #----------------------------------------------------------------------
    # ● 各种常量定义
    #---------------------------------------------------------------------- 
    DEFAULT_UA  = 'WeAccount'

    DLLNAME     = 'winhttp'

    INTERNET_SCHEME_HTTP      = 1
    INTERNET_SCHEME_HTTPS     = 2
    WINHTTP_FLAG_SECURE       = 0x00800000
    WINHTTP_ADDREQ_FLAG_ADD   = 0x20000000

    WINHTTP_QUERY_CONTENT_LENGTH = 5
    WINHTTP_QUERY_VERSION     = 18
    WINHTTP_QUERY_STATUS_CODE = 19
    WINHTTP_QUERY_STATUS_TEXT = 20
    WINHTTP_QUERY_COOKIE      = 44
    
    WinHttpOpen               = Win32API.new(DLLNAME, 'WinHttpOpen', 'plppl', 'l')
    WinHttpConnect            = Win32API.new(DLLNAME, 'WinHttpConnect', 'lpil', 'l')
    WinHttpOpenRequest        = Win32API.new(DLLNAME, 'WinHttpOpenRequest', 'lpppppl', 'l')
    WinHttpAddRequestHeaders  = Win32API.new(DLLNAME, 'WinHttpAddRequestHeaders', 'lpll', 'i')
    WinHttpSendRequest        = Win32API.new(DLLNAME, 'WinHttpSendRequest', 'lplpllp', 'i')
    WinHttpReceiveResponse    = Win32API.new(DLLNAME, 'WinHttpReceiveResponse', 'lp', 'i')
    WinHttpQueryHeaders       = Win32API.new(DLLNAME, 'WinHttpQueryHeaders', 'llpppp', 'i')
    WinHttpReadData           = Win32API.new(DLLNAME, 'WinHttpReadData', 'lplp', 'i')
    WinHttpCloseHandle        = Win32API.new(DLLNAME, 'WinHttpCloseHandle', 'l', 'i')

  end

  class Login

    def self.run(appkey, appsecret)
      return new(appkey, appsecret).run
    end

    def initialize(appkey, appsecret)
      @appkey = appkey
      @appsecret = appsecret
    end

    def run
      # client_id=xxx&state=xxx&timestamp=xxx&sign=xxx
      args = {:client_id=>@appkey, :state=>:test, :timestamp=>Time.now.to_i}
      args[:sign] = calc_signature(args, @appsecret)
      resp = WeAccount::RestClient.post("http://weaccount.cn/open/applyforlogin", args)
      raise 'failed...' unless resp.success?
      json = WeAccount::JSON.parse(resp.body) rescue nil
      raise 'invalid resp' if json.nil?

      logincode=json['data']['login_code']

      args = {:client_id=>@appkey, :timestamp=>Time.now.to_i, :state=>rand(99999), :logincode=>logincode}
      args[:sign] = calc_signature(args, @appsecret)
      open_url("http://weaccount.cn/oauth?" + make_request_args(args))
      loop do
        args = {:client_id=>@appkey, :state=>:test, :timestamp=>Time.now.to_i, :logincode=>logincode}
        args[:sign] = calc_signature(args, @appsecret)
        resp = WeAccount::RestClient.post("http://weaccount.cn/open/queryforlogin", args)
        raise 'failed...' unless resp.success?
        json = WeAccount::JSON.parse(resp.body) rescue nil
        raise 'invalid resp' if json.nil?
        break if json['status'] != 2
        wait
      end
      code = json['data']['code']

      args = {'client_id'=>@appkey, 'code'=>code}
      args['sign'] = calc_signature(args, @appsecret)

      v = WeAccount::RestClient.post "http://weaccount.cn/open/exchange", args
      r = WeAccount::JSON.parse(v.body) rescue nil
      raise 'invalid resp' if r.nil?
      raise r['msg'] if r['status'].to_i < 0
      access_token = r['data']['access_token']

      args = {'access_token'=>access_token, 'client_id'=>@appkey}
      args['sign'] = calc_signature(args, @appsecret)
      v = RestClient.post "http://weaccount.cn/open/userinfo", args
      r = WeAccount::JSON.parse(v.body) rescue nil
      raise 'invalid resp' if r.nil?
      raise r['msg'] if r['status'].to_i < 0
      return r['data']
    end

    private

    if defined?(Graphics)
      def wait
        # Graphics.update
        sleep(0.2)
      end
    else
      def wait
        sleep(0.2)
      end
    end

    def open_url(url)
      shell = Win32API.new('shell32.dll', 'ShellExecuteA', %w(p p p p p i), 'i')
      raise 'failed...' if shell.call(0, 'open', url, 0, 0, 1) <= 32
    end

    def make_request_args(hash)
      # => TODO：url ecnode
      return hash.keys.sort.map{|k| "#{k}=#{hash[k].to_s}"}.join("&")
    end

    def calc_signature(hash, sign_key)
      return WeAccount::API.md5(make_request_args(hash) + sign_key)
    end    

  end

end

if __FILE__ == $0
#  p WeAccount::Login.run("3", "1")
  # p WeAccount::RestClient.post("http://192.168.1.107:9292/open/queryforlogin?a=x", :c=>3, :d=>55, :k=>'中文')
  # p WeAccount::RestClient.get("http://192.168.1.107:9292/contact?a=3&b=中文 sd")

  exit
end