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

  VALUES_REFERENCING_NEXT_WORD = [REGISTERS_MEM_NEXT_WORD, NEXT_WORD, NEXT_WORD_LITERAL]
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
  SET = 0x1
  ADD = 0x2
  SUB = 0x3
  MUL = 0x4
  DIV = 0x5
  MOD = 0x6
  SHL = 0x7
  SHR = 0x8
  AND = 0x9
  BOR = 0xa
  XOR = 0xb
  IFE = 0xc
  IFN = 0xd
  IFG = 0xe
  IFB = 0xf
end

class Dcpu
  include StorageConstants

  class Word
    include StorageConstants

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

    def instruction_word_count
      1 + [a, b].count do |value|
        VALUES_REFERENCING_NEXT_WORD.any?{|range| range === value}
      end
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
    storage[PC] += next_instruction.instruction_word_count
  end
end