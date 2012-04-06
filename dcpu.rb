module StorageConstants
  A = 0x00
  J = 0x07
  REGISTERS = A..J
  REGISTERS_MEM = 0x08..0x0f
  REGISTERS_MEM_NEXT_WORD = 0x10..0x17
  POP = 0x18
  PEEK = 0x19
  PUSH = 0x1a
  SP = 0x1b
  PC = 0x1c
  O = 0x1d

  NEXT_WORD = 0x1e
  NEXT_WORD_LITERAL = 0x1f
  LITERALS = 0x20..0x3f
end

class Storage
  include StorageConstants
  attr_accessor :memory
  def initialize
    @registers = Array.new(8)
    @memory = Array.new(0x10000)
    @program_counter = 0
    @stack_pointer = 0xffff
    @overflow = 0
  end

  def [](location)
    case location
    when REGISTERS
      @registers[location]
    when REGISTERS_MEM
      memory[self[location - REGISTERS_MEM.begin]]
    when REGISTERS_MEM_NEXT_WORD
      memory[self[location - REGISTERS_MEM_NEXT_WORD.begin] + self[NEXT_WORD_LITERAL]]
    when POP
      value = memory[@stack_pointer]
      @stack_pointer += 1
      value
    when PEEK
      memory[@stack_pointer]
    when PUSH
      @stack_pointer -= 1
      memory[@stack_pointer]
    when SP
      @stack_pointer
    when PC
      @program_counter
    when O
      @overflow
    when NEXT_WORD
      memory[self[NEXT_WORD_LITERAL]]
    when NEXT_WORD_LITERAL
      @program_counter += 1
      memory[@program_counter]
    when LITERALS
      location - LITERALS.begin
    end
  end

  def []=(location, data)
    case location
    when REGISTERS
      @registers[location] = data
    when REGISTERS_MEM
      memory[self[location - 0x08]] = data
    when REGISTERS_MEM_NEXT_WORD
      memory[self[location - 0x10] + self[0x1f]] = data
    when POP
      value = memory[@stack_pointer] = data
      @stack_pointer += 1
      value
    when PEEK
      memory[@stack_pointer] = data
    when PUSH
      @stack_pointer -= 1
      memory[@stack_pointer] = data
    when SP
      @stack_pointer = data
    when PC
      @program_counter = data
    when O
      @overflow = data
    when NEXT_WORD
      memory[self[0x1f]] = data
    when NEXT_WORD_LITERAL
      @program_counter += 1
      memory[@program_counter] = data
    when LITERALS
      # noop
    end
  end
end


class Dcpu
  attr_reader :storage

  def initialize
    @storage = Storage.new
  end

  def execute(word1, word2)
    instruction = Instruction.new(word1)
    case instruction.opcode
    when 0x01
      set(instruction.a, word2)
    end
    
  end
  
  def set(a, b)
    storage[a] = b - 0x20
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
      5.downto(4).map { |n| instruction[n] }.join.to_i(2)
    end
  end

end