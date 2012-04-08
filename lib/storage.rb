class Storage
  include StorageConstants
  attr_accessor :memory
  def initialize
    @registers = Array.new(8)
    @memory = Array.new(0x10000, 0)
    @other = {
      program_counter: 0,
      stack_pointer: 0xffff,
      overflow: 0
    }
  end

  def next_instruction
    Instruction.new(memory[self[PC]])
  end

  def skip_next_instruction!
    self[PC] += next_instruction.word_count
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

  def load(words, offset = 0)
    memory[offset, words.length] = words
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
      [memory, self[PC]].tap {
        self[PC] += 1 
      }
    when LITERALS
      location - LITERALS.begin
    end
  end
end