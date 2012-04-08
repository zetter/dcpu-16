class Executor
  include InstructionConstants
  include StorageConstants
  attr_reader :storage

  def initialize(storage)
    @storage = storage
  end

  def execute(instruction)
    a = instruction.a
    b = instruction.b
    case instruction.opcode
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
    storage.skip_next_instruction!
  end
end