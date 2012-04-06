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
    @other = {
      program_counter: 0,
      stack_pointer: 0xffff,
      overflow: 0
    }
  end

  def [](location)
    reader_writer(location)
  end

  def []=(location, data)
    reader_writer(location, data)
  end
  
private
  def lookup(obj, key, data = nil)
    if data
      obj[key] = data
    else
      obj[key]
    end
  end

  def reader_writer(location, data = nil)
    case location
    when REGISTERS
      lookup(@registers, location, data)
    when REGISTERS_MEM
      lookup(memory, self[location - REGISTERS_MEM.begin], data)
    when REGISTERS_MEM_NEXT_WORD
      lookup(memory, self[location - REGISTERS_MEM_NEXT_WORD.begin] + self[NEXT_WORD_LITERAL], data)
    when POP
      value = lookup(memory, @other[:stack_pointer], data)
      @other[:stack_pointer] += 1
      value
    when PEEK
      lookup(memory, @other[:stack_pointer], data)
    when PUSH
      @other[:stack_pointer] -= 1
      lookup(memory, @other[:stack_pointer], data)
    when SP
      lookup(@other, :stack_pointer, data)
    when PC
      lookup(@other, :program_counter, data)
    when O
      lookup(@other, :overflow, data)
    when NEXT_WORD
      lookup(memory, self[NEXT_WORD_LITERAL], data)
    when NEXT_WORD_LITERAL
      @other[:program_counter] += 1
      lookup(memory, @other[:program_counter], data)
    when LITERALS
      location - LITERALS.begin
    end
  end
end

module InstructionConstants
  SET = 0x1 # a, b - sets a to b
  ADD = 0x2 # a, b - sets a to a+b, sets O to 0x0001 if there's an overflow, 0x0 otherwise
  SUB = 0x3 # a, b - sets a to a-b, sets O to 0xffff if there's an underflow, 0x0 otherwise
  MUL = 0x4 # a, b - sets a to a*b, sets O to ((a*b)>>16)&0xffff
  DIV = 0x5 # a, b - sets a to a/b, sets O to ((a<<16)/b)&0xffff. if b==0, sets a and O to 0 instead.
  MOD = 0x6 # a, b - sets a to a%b. if b==0, sets a to 0 instead.
  SHL = 0x7 # a, b - sets a to a<<b, sets O to ((a<<b)>>16)&0xffff
  SHR = 0x8 # a, b - sets a to a>>b, sets O to ((a<<16)>>b)&0xffff
  AND = 0x9 # a, b - sets a to a&b
  BOR = 0xa # a, b - sets a to a|b
  XOR = 0xb # a, b - sets a to a^b
  IFE = 0xc # a, b - performs next instruction only if a==b
  IFN = 0xd # a, b - performs next instruction only if a!=b
  IFG = 0xe # a, b - performs next instruction only if a>b
  IFB = 0xf # a, b - performs next instruction only if (a&b)!=0
end

class Dcpu
  include InstructionConstants
  attr_reader :storage

  def initialize
    @storage = Storage.new
  end

  def execute(word)
    instruction = Instruction.new(word)
    case instruction.opcode
    when SET
      storage[instruction.a] = storage[instruction.b]
    when ADD
      storage[instruction.a] = storage[instruction.a] + storage[instruction.b]
    end
  
    
  end
  
  class Instruction
    attr_reader :instruction
    def initialize(instruction)
      @instruction = instruction
    end
    # bbbbbbaaaaaaoooo
    def opcode
      instruction % 0b10000
    end

    def a
      (instruction >> 4) % 0b1000000
    end
    
    def b
      (instruction >> 10) % 0b1000000
    end
  end

end