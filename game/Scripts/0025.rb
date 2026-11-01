#encoding:utf-8
module RPG
  class Tree
    def initialize
      @name = ""
    end
    attr_accessor :name

    class Node
      def initialize
        @name = ""
        @ancestry = nil
      end
      class << self
        def create(option={})
          obj = new
          obj.attrset(option)
        end
      end
      attr_accessor :name
      attr_accessor :ancestry
    end
  end
end