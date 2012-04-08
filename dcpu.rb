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

  def reader_writer(location, data = nil)
    store, key = store_and_key(location)

    return store if store.is_a?(Fixnum)
    if data
      store[key] = data
    else
      store[key]
    end
  end
  
  alias_method :[], :reader_writer
  alias_method :[]=, :reader_writer

private
  def store_and_key(location)
    case location
    when REGISTERS
      [@registers, location]
    when REGISTERS_MEM
      value_in_register = self[location - REGISTERS_MEM.begin]
      [memory, value_in_register]
    when REGISTERS_MEM_NEXT_WORD
      value_in_register = self[location - REGISTERS_MEM_NEXT_WORD.begin]
      [memory, value_in_register + self[NEXT_WORD_LITERAL]]
    when POP
      [memory, self[SP]].tap {
        self[SP] += 1
      }
    when PEEK
      [memory, self[SP]]
    when PUSH
      self[SP] -= 1
      [memory, self[SP]]
    when SP
      [@other, :stack_pointer]
    when PC
      [@other, :program_counter]
    when O
      [@other, :overflow]
    when NEXT_WORD
      [memory, self[NEXT_WORD_LITERAL]]
    when NEXT_WORD_LITERAL
      self[PC] += 1
      [memory, self[PC]]
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
  include StorageConstants

  class Word
    def initialize(word)
      @word = word
    end

    def to_i
      @word
    end

    def to_s
      @word.to_s(16)
    end

    def opcode
      @word % 0b10000
    end

    def a
      (@word >> 4) % 0b1000000
    end

    def b
      (@word >> 10) % 0b1000000
    end
  end
end

class Executor
  include InstructionConstants
  include StorageConstants
  attr_reader :storage

  def initialize(storage)
    @storage = storage
  end

  def execute(word)
    a = word.a
    b = word.b
    case word.opcode
    when SET
      storage[a] = storage[b]
    when ADD
      storage[a] = storage[a] + storage[b]
    when MUL
      storage[a] = storage[a] * storage[b]
    when DIV
      storage[a] = storage[a] / storage[b]
    when SHL
      storage[a] = storage[a] << storage[b]
    when SHR
      storage[a] = storage[a] >> storage[b]
    when AND
      storage[a] = storage[a] & storage[b]
    when BOR
      storage[a] = storage[a] | storage[b]
    when XOR
      storage[a] = storage[a] ^ storage[b]
    when IFE
      skip_next_instruction! if storage[a] == storage[b]
    when IFN
      skip_next_instruction! if storage[a] != storage[b]
    when IFG
      skip_next_instruction! if storage[a] > storage[b]
    when IFB
      skip_next_instruction! if (storage[a] & storage[b]) != 0
    end
  end

private
  def skip_next_instruction!
    next_instruction = Dcpu::Word.new(storage.memory[storage[PC]])
    skip_length = 1 + extra_word_count(next_instruction.a) + extra_word_count(next_instruction.b)
    storage[PC] += skip_length
  end
  
  def extra_word_count(value)
    [REGISTERS_MEM_NEXT_WORD, NEXT_WORD, NEXT_WORD_LITERAL].any?{|range| range === value} ? 1 : 0
  end
end