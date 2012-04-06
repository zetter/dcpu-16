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

  
  class Storage
    attr_accessor :memory
    def initialize
      @registers = Array.new(8)
      @memory = Array.new(0x10000)
      @program_counter = 0
      @stack_pointer = 0
      @overflow = 0
    end

    def [](location)
      case location
      when 0x00..0x07
        @registers[location]
      when 0x00..0x0f
        @memory[self[location - 0x08]]
      when 0x10..0x17
        # [next word + register]
      when 0x18
        #: POP / [SP++]
      when 0x19
        #: PEEK / [SP]
      when 0x1a
        #: PUSH / [--SP]
      when 0x1b
        @stack_pointer
      when 0x1c
        @program_counter
      when 0x1d
        @overflow
      when 0x1e
        #: [next word]
      when 0x1f
        #: next word (literal)
      when 0x20..0x3f
        location - 0x20
      end
    end

    def []=(location, data)
      case location
      when 0x00..0x07
        @registers[location] = data
      when 0x00..0x0f
        @memory[self[location - 0x08]] = data
      when 0x10..0x17
        # [next word + register]
      when 0x18
        #: POP / [SP++]
      when 0x19
        #: PEEK / [SP]
      when 0x1a
        #: PUSH / [--SP]
      when 0x1b
        @stack_pointer = data
      when 0x1c
        @program_counter = data
      when 0x1d
        @overflow = data
      when 0x1e
        #: [next word]
      when 0x1f
        #: next word (literal)
      when 0x20..0x3f
        # noop
      end
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
      5.downto(4).map { |n| instruction[n] }.join.to_i(2)
    end
  end

end