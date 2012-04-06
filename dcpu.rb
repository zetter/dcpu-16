class Dcpu
  def initialize
  end

  def execute(word1, word2)
    instruction = Instruction.new(word1)
    case instruction.opcode
    when 0x01 # SET
      @a = word2 - 0x20
    end
    
  end
  
  def a
    @a
  end
  
  class Storage
    def initialize
      @registers = Array.new(8)
    end

    def [](location)
      case location
      when 0..8
        @registers[location]
      end
    end

    def []=(location, data)
      @registers[location] = data
    end
  end
  
  
  class Instruction
    attr_reader :instruction
    def initialize(instruction)
      @instruction = instruction
    end

    def opcode
      3.downto(0).map { |n| instruction[n] }.join.to_i(2)
    end

    def a
      5.downto(4).map { |n| instruction[n] }.join.to_i(2)
    end
    
    def b
      
    end
  end

end