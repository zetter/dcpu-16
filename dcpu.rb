class Dcpu

  def initialize
  end

  def execute(word)
    
  end
  
  def a
  end
  
  class Instruction
    attr_reader :instruction
    def initialize(instruction)
      @instruction = instruction
    end
    
    def opcode
      3.downto(0).map { |n| instruction[n] }.join.to_i(2)
    end
  end

end