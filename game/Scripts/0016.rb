#encoding:utf-8
class BugReport
  @@instance = nil

  OUT_TYPE_STDERR = 0
  OUT_TYPE_LOGFILE = 1

  ERROR_TEMPLATE = "游戏运行中发生异常:\n  %s\n %s"

  def initialize outtype
    @outtype = outtype

    @name = nil
    @method = nil
    @message = nil
    @backtrace = nil
  end

  def report! exception
    @message = exception.message
    @backtrace = exception.backtrace
    case @outtype
    when OUT_TYPE_STDERR
      _output_stderr
    when OUT_TYPE_LOGFILE
      _out_logfile
    end
  end

  private
  def _output_stderr
    _backtrace = @backtrace.join("\n").gsub("(eval)","[LINE] ")
    msgbox format(ERROR_TEMPLATE,@message, _backtrace)
  end

  def _out_logfile

  end

  class << self
    def shareObject
      if @@instance
        return @@instance
      else
        @@instance = BugReport.new(OUT_TYPE_STDERR)
      end
    end
  end
end
