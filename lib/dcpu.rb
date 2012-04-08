require 'storage_constants'
require 'termination_error'
require 'instruction_constants'
require 'instruction'
require 'storage'
require 'executor'

class Dcpu
  include StorageConstants
  def initialize
    @storage = Storage.new
    @executor = Executor.new(@storage)
  end

  def load(*args)
    @storage.load(*args)
  end

  def run
    loop do
      instruction = @storage.next_instruction
      @storage[PC] += 1
      @executor.execute(instruction)
    end
  rescue TerminationError
    @storage[A]
  end
end

